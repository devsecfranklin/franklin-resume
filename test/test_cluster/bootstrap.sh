#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2021-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: MIT

# ChangeLog:
#
# v0.1

#set -euo pipefail

# The special shell variable IFS determines how Bash
# recognizes word boundaries while splitting a sequence of character strings.
IFS=$'\n\t'

#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37

#RED='\033[0;31m'
LRED='\033[1;31m'
LGREEN='\033[1;32m'
#LBLUE='\033[1;34m'
CYAN='\033[0;36m'
LPURP='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BUILD_DIR="/home/franklin/workspace/build"
GPG_DIR="${BUILD_DIR}/gnupg"
OPEN_MPI_VER="openmpi-5.0.5"
ompi_package="https://download.open-mpi.org/release/open-mpi/v5.0/${OPEN_MPI_VER}.tar.bz2"

declare GNU_PACKAGES=(
  "https://ftp.gnu.org/gnu/m4/m4-latest.tar.xz"
  "https://ftp.gnu.org/gnu/autoconf/autoconf-latest.tar.xz"
  "https://ftp.gnu.org/gnu/automake/automake-1.17.tar.xz"
  "https://ftp.gnu.org/gnu/libtool/libtool-2.5.4.tar.xz"
)

declare -a KEYSERVERS=(
  "hkp://keyserver.ubuntu.com:80"
  "keyserver.ubuntu.com"
  "ha.pool.sks-keyservers.net"
  "hkp://ha.pool.sks-keyservers.net:80"
  "p80.pool.sks-keyservers.net"
  "hkp://p80.pool.sks-keyservers.net:80"
  "pgp.mit.edu"
  "hkp://pgp.mit.edu:80"
)

declare list=(
  'm4-latest|m4-1.4.19'
  'autoconf-latest|autoconf-2.72'
  'automake-1.17|automake-1.17'
  'libtool-2.5.4|libtool-2.5.4'
)

# change to working dir 
pushd "${BUILD_DIR}" 2>&1 || exit 1

function check_host() {
  MY_ARCH=$(getconf LONG_BIT)
  # arch
  # dpkg --print-architecture
  #MY_ARCH=$(dpkg-architecture | grep DEB_BUILD_ARCH_BITS= | cut -f2 -d=)
  if [ "${MY_ARCH}" == "32" ]; then
    echo -e "${LRED}This is a 32 bit system. Unable to build.${NC}"
    echo -e "${YELLOW}$(dpkg-architecture)${NC}"
    exit 1
  fi
}

function install_packages() {
  echo -e "${CYAN}Installing packages to ${BUILD_DIR}${NC}"
  sudo apt-get install -y debian-keyring debian-archive-keyring gfortran libudev-dev libpciaccess-dev valgrind
  sudo apt-key update # Warning: 'apt-key update' is deprecated and should not be used anymore!
  sudo apt-get update && sudo apt install -y figlet lolcat cowsay fortune

  echo "$(hostname) setup" | figlet | lolcat

  if [ ! -f "/usr/bin/clush" ]; then
    echo -e "${CYAN}Installing clustershell${NC}"
    sudo apt install -y clustershell
  fi

  if [ ! -d "${BUILD_DIR}" ]; then mkdir -p "${BUILD_DIR}" && echo -e "${LPURP}created dir: ${BUILD_DIR}"; fi
  # install software
  #apt-get -y install openssh-server git htop python3-pip mpich mpi-default-dev libopenmpi-dev
}

function gpg_setup() {
  echo -e "${CYAN}Configure GnuPG${NC}"

  sudo apt install -y gnupg # make sure gnupg is installed
  if [ ! -d "${GPG_DIR}" ]; then mkdir -p "${GPG_DIR}" && echo -e "${LPURP}created dir: ${GPG_DIR}${NC}"; fi

  chown -R "$(whoami):engr" "${GPG_DIR}"
  chmod 750 "${GPG_DIR}"

  echo -e "${CYAN}importing my public key to the work folder: ${GPG_DIR}${NC}"
  gpg --homedir "${BUILD_DIR}/gnupg" --import ~/.gnupg/franklin.gpg
  if [ ! -d "${BUILD_DIR}/gnupg" ]; then mkdir -p "${BUILD_DIR}/gnupg" && echo -e "${LPURP}Created GnuPG dir${NC}"; fi
}

function update_keys() {
  SIG=$1
  MY_FILE=$2

  echo -e "${CYAN}update_keys from ${SIG}${NC}"

  # gpg --homedir "${BUILD_DIR}/gnupg" --import "${BUILD_DIR}/m4-latest.tar.xz.sig" # import the key into your local keyring
  # gpg --homedir "${BUILgpg --homedir "${BUILD_DIR}/gnupg" D_DIR}/gnupg" --fingerprint # view the fingerprints in your local keyring
  MY_KEY="$("${SIG}" 2>&1 | grep RSA | awk '{print $5}')"

  # check if the MY_KEY string is blank
  if [ -n "${MY_KEY}" ]; then
    echo -e "${LGREEN}Found key: ${MY_KEY}${NC}"
  else
    echo -e "${LRED}No key found in ${SIG}${NC}"
    return
  fi

  for server in "${KEYSERVERS[@]}"; do
    # check if MY_KEY already exists locally
    #LOCAL_KEY=$(gpg --homedir ${BUILD_DIR}/gnupg --export-options export-minimal --armor --export ${MY_KEY} 2>&1)
    LOCAL_KEY="$(gpg --homedir ${BUILD_DIR}/gnupg --export-options export-minimal --armor --export "${MY_KEY}" 2>&1)"
    if [ -n "${LOCAL_KEY}" ]; then
      echo -e "${CYAN}Local copy of key not found, getting${NC}"
      gpg --homedir "${BUILD_DIR}/gnupg" --keyserver "${server}" --recv-keys "${MY_KEY}"
      if [ $? -eq 0 ]; then
        echo -e "${LGREEN}Success importing key!"
        return
      else
        echo -e "${LRED}Not finding this key: ${MY_KEY} at server: ${server}${NC}"
      fi
    fi

    VERIFIED=$(gpg --homedir "${BUILD_DIR}/gnupg" --verify "${SIG}" "${MY_FILE}" 2>&1 | grep 'Good signature')
    if [[ "$VERIFIED" ]]; then
      echo -e "${LGREEN}gpg keys verified. Installing...${NC}"
    else
      echo -e "${LRED}gpg key cannot be verifed. Aborting installation of ${MY_FILE}${NC}"
      exit 1
    fi
  done
}

# Warning :: You will have problems if you do not use recent versions of the GNU Autotools.
#
# https://docs.open-mpi.org/en/v5.0.2/developers/gnu-autotools.html
#

# You must install the last three tools (Autoconf, Automake, Libtool) into the same prefix
# directory. These three tools are somewhat inter-related, and if they’re going to be used
# together, they must share a common installation prefix.

# You can install m4 anywhere as long as it can be found in the path; it may be convenient
# to install it in the same prefix as the other three. Or you can use any recent-enough
# m4 that is in your path.

function build_gnu_tools() {
  echo -e "${CYAN}Building GNU packages${NC}"

  for package in "${GNU_PACKAGES[@]}"; do

    packageurl="${package}"
    packagenamefull=$(echo "${package}" | rev | cut -f1 -d'/' | rev)
    #echo "full package name: ${packagenamefull}"
    packagename=$(echo "${package}" | rev | cut -f1 -d"/" | cut -f3- -d'.' | rev)
    echo "preparing ${packagename}" | figlet | lolcat
    packagenametar=$(echo "${package}" | rev | cut -f1 -d"/" | cut -f2- -d'.' | rev)

    if [ ! -f "${BUILD_DIR}/${packagenamefull}" ]; then
      echo -e "${CYAN}Downloading ${packagename} to ${BUILD_DIR}${NC}"
      wget -O "${BUILD_DIR}/${packagenamefull}" "${packageurl}"
      wget -O "${BUILD_DIR}/${packagenamefull}.sig" "${packageurl}.sig"
    else
      echo -e "${LGREEN}${packagename} is already downloaded${NC}"
    fi

    update_keys "${BUILD_DIR}/${packagenamefull}.sig" "${BUILD_DIR}/${packagenamefull}"

    if [ ! -e "${BUILD_DIR}/${packagenametar}" ]; then
      echo -e "${LPURP}Uncompress ${packagenamefull}${NC}"
      unxz "${BUILD_DIR}/${packagenamefull}"
    else
      echo -e "${LPURP}${packagenametar} already uncompressed${NC}"
    fi

    if [ ! -f "${BUILD_DIR}/${packagenametar}" ]; then
      echo "Untar ${packagenametar}" | figlet | lolcat
      tar xf "${BUILD_DIR}/${packagenametar}" -C "${BUILD_DIR}"
    else
      echo -e "${LPURP}${packagenametar} already untarred${NC}"
    fi

    # You must build and install the GNU Autotools in the following order:
    #
    # m4
    # Autoconf
    # Automake
    # Libtool
    for element in "${list[@]}"; do
      this_element=$(echo "${element}" | cut -f1 -d'|')
      if [ "${packagename}" == "${this_element}" ]; then
        goodname=$(echo "${element}" | cut -f2 -d'|')
        echo "configure ${goodname}" | figlet | lolcat
        "${BUILD_DIR}/${goodname}/configure" --prefix="${BUILD_DIR}" | tee "${BUILD_DIR}/${goodname}-config.log"
        echo "build ${goodname}" | figlet | lolcat
        cd "${BUILD_DIR}/${goodname}" && make all install | tee "${BUILD_DIR}/${goodname}-make.log"
      fi
    done
  done

}

function verify_gnu_tools() {
  echo "verifiying GNU tools installation" | figlet | lolcat
  declare -a GNUTOOLS=(
    "m4"
    "autoconf"
    "automake"
    "libtoolize"
  )

  for package in "${GNUTOOLS[@]}"; do
    echo -e "${LGREEN}$(${package} --version | head -1)${NC}"
  done

}

function build_prrte() {
  sudo apt install -y flex bison
  git clone https://github.com/openpmix/prrte.git "${HOME}"/workspace/build
  cd "${HOME}"/workspace/build/prrte && git submodule update --init --recursive
  "${HOME}"/workspace/build/prrte/autogen.pl
  cd "${HOME}"/workspace/build/prrte && ./configure
}

function build_hwloc() {
  cd ${HOME}/workspace/build/ && ./configure --enable-doxygen --enable-netloc --prefix=/home/franklin/workspace/build
}

function build_openmpi() {
  echo "Build Open MPI: ${OPEN_MPI_VER}" | figlet | lolcat

  packagenamefull=$(echo "${ompi_package}" | rev | cut -f1 -d'/' | rev)
  #echo "full package name: ${packagenamefull}"
  packagename=$(echo "${ompi_package}" | rev | cut -f1 -d"/" | cut -f3- -d'.' | rev)
  #echo "Building ${packagename}" | figlet | lolcat
  packagenametar=$(echo "${ompi_package}" | rev | cut -f1 -d"/" | cut -f2- -d'.' | rev)

  # MD5: 0529027472015810e5f0d749136ca0a3
  # SHA1: edfb7c60aecdd3080dab70aba252ee20518252d1
  # SHA256: 119f2009936a403334d0df3c0d74d5595a32d99497f9b1d41e90019fee2fc2dd
  if [ ! -f "${BUILD_DIR}/${packagenamefull}" ]; then
    echo -e "${CYAN}Download ${packagenamefull}${NC}"
    wget -O "${BUILD_DIR}/${packagenamefull}"
  else
    echo -e "${LPURP}${packagename} is already downloaded${NC}"
  fi

  SHA256=$(sha256sum -b "${BUILD_DIR}/${OPEN_MPI_VER}.tar.bz2")
  echo -e "${YELLOW}Compare ${SHA256} with value: 119f2009936a403334d0df3c0d74d5595a32d99497f9b1d41e90019fee2fc2dd${NC}\n"

  if [ ! -f "${BUILD_DIR}/${OPEN_MPI_VER}.tar" ]; then
    echo -e "${CYAN}Uncompress openmpi-5.0.7.tar.bz2${NC}"
    bunzip2 "${BUILD_DIR}/${OPEN_MPI_VER}.tar.bz2"
  else
    echo -e "${LPURP}${packagenamefull} already uncompressed${NC}"
  fi

  if [ ! -d "${BUILD_DIR}/${packagename}" ]; then
    echo -e "${CYAN}Untar ${packagenametar}... please be patient, it\'s a lot of code!${NC}"
    tar xf "${BUILD_DIR}/${packagenametar}" -C "${BUILD_DIR}"
  else
    echo -e "${LPURP}${packagenamefull} already untarred${NC}"
  fi

  if [ -d "${BUILD_DIR}/${OPEN_MPI_VER}" ]; then
    echo -e "${CYAN}Configure ${OPEN_MPI_VER}.tar.bz2${NC}"

    # CFLAGS="-m64 -mcpu=cortex-a53 -mfloat-abi=hard -mfpu=neon-fp-armv8" FCFLAGS="-m64"
    # CFLAGS=-march=armv7-a CCASFLAGS=-march=armv7-a ../configure"
    cd "${BUILD_DIR}/${OPEN_MPI_VER}" && \
      CFLAGS="-O3 -DNDEBUG -finline -finline-functions" ./configure \
      --prefix="${BUILD_DIR}" --exec-prefix="${BUILD_DIR}" --enable-mpi-java --enable-mpi-fortran --enable-memchecker --with-slurm \
      --with-valgrind --with-gnu-ld --enable-ipv6 \
      --with-hwloc="/home/franklin/workspace/build" 2>&1 | tee "${BUILD_DIR}/openmpi-config.log"
    
    echo -e "${CYAN}Make ${OPEN_MPI_VER}.tar.bz2${NC}"
    cd "${BUILD_DIR}/${OPEN_MPI_VER}" && make -j4 all 2>&1 | tee "${BUILD_DIR}/openmpi-make.log"

    echo -e "${CYAN}Install ${OPEN_MPI_VER}.tar.bz2${NC}"
    cd "${BUILD_DIR}/${OPEN_MPI_VER}" && sudo make install 2>&1 | tee "${BUILD_DIR}/openmpi-install.log"

    sudo ldconfig
  else
    echo -e "${CYAN}Cannot find ${BUILD_DIR}/${OPEN_MPI_VER}${NC}"
  fi
}

function cleanup() {
  echo "cleanup" | figlet | lolcat

  # delete the build directories
  for item in "${list[@]}"; do
    echo -e "${LPURP}Deleting ${item}${NC}"
    rm -rf "${BUILD_DIR:?}/${item}" # https://www.shellcheck.net/wiki/SC2115
  done

  # delete the tar files
  for package in "${GNU_PACKAGES[@]}"; do
    packagenametar=$(echo "${package}" | rev | cut -f1 -d'/' | cut -f2- -d'.' | rev)
    echo -e "${LPURP}Deleting ${packagenametar}${NC}"
    rm "${BUILD_DIR:?}/${packagenametar}"
  done
}

function main() {
  check_host
  case $HOSTNAME in
  head1)
    install_packages # Warning :: You will have problems if you do not use recent versions of the GNU Autotools
    gpg_setup
    build_gnu_tools
    verify_gnu_tools
    build_openmpi
    #cleanup
    echo -e "${YELLOW}Now add ${BUILD_DIR}/bin to the start of your PATH var.${NC}"
    echo -e "${LGREEN}Setup complete!${NC}"
    ;;
  *) echo -e "${LRED}Run this script on the cluster head node${NC}" ;;
  esac
}

main "$@"
