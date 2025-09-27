#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023-2025 franklin <smoooth.y62wj@passmail.net>
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

PREFIX="/mnt/clusterfs2/scratch"
GPG_DIR="${PREFIX}/gnupg"
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
pushd "${PREFIX}" 2>&1 || exit 1

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
  echo -e "${CYAN}Installing packages to ${PREFIX}${NC}"
  sudo apt-get install -y debian-keyring debian-archive-keyring \
    gfortran libudev-dev libpciaccess-dev valgrind autopoint \
    texinfo help2man bison libxml2-dev doxygen valgrind
  sudo apt-key update # Warning: 'apt-key update' is deprecated and should not be used anymore!
  sudo apt-get update && sudo apt install -y figlet lolcat cowsay fortune

  echo "$(hostname) setup" | figlet | lolcat

  if [ ! -f "/usr/bin/clush" ]; then
    echo -e "${CYAN}Installing clustershell${NC}"
    sudo apt install -y clustershell
  fi

  if [ ! -d "${PREFIX}" ]; then mkdir -p "${PREFIX}" && echo -e "${LPURP}created dir: ${PREFIX}"; fi
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
  gpg --homedir "${PREFIX}/gnupg" --import ~/.gnupg/franklin.gpg
  if [ ! -d "${PREFIX}/gnupg" ]; then mkdir -p "${PREFIX}/gnupg" && echo -e "${LPURP}Created GnuPG dir${NC}"; fi
}

function update_keys() {
  SIG=$1
  MY_FILE=$2

  echo -e "${CYAN}update_keys from ${SIG}${NC}"

  # gpg --homedir "${PREFIX}/gnupg" --import "${PREFIX}/m4-latest.tar.xz.sig" # import the key into your local keyring
  # gpg --homedir "${BUILgpg --homedir "${PREFIX}/gnupg" D_DIR}/gnupg" --fingerprint # view the fingerprints in your local keyring
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
    #LOCAL_KEY=$(gpg --homedir ${PREFIX}/gnupg --export-options export-minimal --armor --export ${MY_KEY} 2>&1)
    LOCAL_KEY="$(gpg --homedir ${PREFIX}/gnupg --export-options export-minimal --armor --export "${MY_KEY}" 2>&1)"
    if [ -n "${LOCAL_KEY}" ]; then
      echo -e "${CYAN}Local copy of key not found, getting${NC}"
      gpg --homedir "${PREFIX}/gnupg" --keyserver "${server}" --recv-keys "${MY_KEY}"
      if [ $? -eq 0 ]; then
        echo -e "${LGREEN}Success importing key!"
        return
      else
        echo -e "${LRED}Not finding this key: ${MY_KEY} at server: ${server}${NC}"
      fi
    fi

    VERIFIED=$(gpg --homedir "${PREFIX}/gnupg" --verify "${SIG}" "${MY_FILE}" 2>&1 | grep 'Good signature')
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

    if [ ! -f "${PREFIX}/${packagenamefull}" ]; then
      echo -e "${CYAN}Downloading ${packagename} to ${PREFIX}${NC}"
      wget -O "${PREFIX}/${packagenamefull}" "${packageurl}"
      wget -O "${PREFIX}/${packagenamefull}.sig" "${packageurl}.sig"
    else
      echo -e "${LGREEN}${packagename} is already downloaded${NC}"
    fi

    update_keys "${PREFIX}/${packagenamefull}.sig" "${PREFIX}/${packagenamefull}"

    if [ ! -e "${PREFIX}/${packagenametar}" ]; then
      echo -e "${LPURP}Uncompress ${packagenamefull}${NC}"
      unxz "${PREFIX}/${packagenamefull}"
    else
      echo -e "${LPURP}${packagenametar} already uncompressed${NC}"
    fi

    if [ ! -f "${PREFIX}/${packagenametar}" ]; then
      echo "Untar ${packagenametar}" | figlet | lolcat
      tar xf "${PREFIX}/${packagenametar}" -C "${PREFIX}"
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
        "${PREFIX}/${goodname}/configure" --prefix="${PREFIX}" | tee "${PREFIX}/${goodname}-config.log"
        echo "build ${goodname}" | figlet | lolcat
        cd "${PREFIX}/${goodname}" && make all install | tee "${PREFIX}/${goodname}-make.log"
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

function build_flex() {
  git clone https://github.com/westes/flex.git "${PREFIX}/flex"
  cd "${PREFIX}/flex" && ./autogen.sh
  cd "${PREFIX}/flex" && ./configure --prefix="${PREFIX}" && make && make install
}

function build_munge() {
  #https://github.com/dun/munge/releases/download/munge-0.5.16/munge-0.5.16.tar.xz
  pushd "${PREFIX}/munge-0.5.16" || exit 1
  ./bootstrap
  ./configure --prefix="${PREFIX}"
  make
  make install
  popd || exit 1
}

function build_slurm() {
  pushd "${PREFIX}/slurm-21.08.6" || exit 1
  ./bootstrap
  ./configure --prefix="${PREFIX}"
  make
  make install
  popd || exit 1
}

function build_hwloc() {
  pushd ${PREFIX}/hwloc-2.12.0 || exit 1
  ./configure --with-x --prefix="${PREFIX}"
  make
  make install
  popd || exit 1
}

function build_pmix() {
  # depends on: hwloc
  if [ ! -d "${PREFIX}/openpmix" ]; then
    git clone https://github.com/openpmix/openpmix.git "${PREFIX}/openpmix"
  fi

  pushd "${PREFIX}/openpmix" || exit 1
  ./configure --prefix="${PREFIX}" --with-munge="${PREFIX}"
  make
  make install
  popd || exit 1
}

function build_prrte() {
  if [ ! -d "${PREFIX}/prrte" ]; then
    git clone https://github.com/openpmix/prrte.git "${PREFIX}/prrte"
  fi

  pushd "${PREFIX}/prrte" || exit 1
  git submodule update --init --recursive
  ./autogen.pl
  ./configure --with-slurm --with-hwloc="${PREFIX}" --with-pmix-libdir="${PREFIX}/lib" --prefix="${PREFIX}"
  make
  make install
  popd || exit 1
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
  if [ ! -f "${PREFIX}/${packagenamefull}" ]; then
    echo -e "${CYAN}Download ${packagenamefull}${NC}"
    wget -O "${PREFIX}/${packagenamefull}"
  else
    echo -e "${LPURP}${packagename} is already downloaded${NC}"
  fi

  SHA256=$(sha256sum -b "${PREFIX}/${OPEN_MPI_VER}.tar.bz2")
  echo -e "${YELLOW}Compare ${SHA256} with value: 119f2009936a403334d0df3c0d74d5595a32d99497f9b1d41e90019fee2fc2dd${NC}\n"

  if [ ! -f "${PREFIX}/${OPEN_MPI_VER}.tar" ]; then
    echo -e "${CYAN}Uncompress openmpi-5.0.7.tar.bz2${NC}"
    bunzip2 "${PREFIX}/${OPEN_MPI_VER}.tar.bz2"
  else
    echo -e "${LPURP}${packagenamefull} already uncompressed${NC}"
  fi

  if [ ! -d "${PREFIX}/${packagename}" ]; then
    echo -e "${CYAN}Untar ${packagenametar}... please be patient, its a lot of code${NC}"
    tar xf "${PREFIX}/${packagenametar}" -C "${PREFIX}"
  else
    echo -e "${LPURP}${packagenamefull} already untarred${NC}"
  fi

  if [ -d "${PREFIX}/${OPEN_MPI_VER}" ]; then
    echo -e "${CYAN}Configure ${OPEN_MPI_VER}.tar.bz2${NC}"

    # Configure command line: '--build=aarch64-linux-gnu' '--prefix=/usr' '--includedir=${prefix}/include' '--mandir=${prefix}/share/man'
    # '--infodir=${prefix}/share/info' '--sysconfdir=/etc' '--localstatedir=/var' '--disable-option-checking' '--disable-silent-rules'
    # '--libdir=${prefix}/lib/aarch64-linux-gnu' '--runstatedir=/run' '--disable-maintainer-mode' '--disable-dependency-tracking'
    # '--disable-silent-rules' '--disable-wrapper-runpath' '--with-package-string=Debian OpenMPI' '--with-verbs' '--with-libfabric'
    # '--with-ucx' '--with-pmix=/usr/lib/aarch64-linux-gnu/pmix2' '--with-jdk-dir=/usr/lib/jvm/default-java' '--enable-mpi-java'
    # '--enable-opal-btl-usnic-unit-tests' '--with-libevent=external' '--with-hwloc=external' '--disable-silent-rules' '--enable-mpi-cxx'
    # '--enable-ipv6' '--with-devel-headers' '--with-slurm' '--with-sge' '--without-tm' '--sysconfdir=/etc/openmpi'
    # '--libdir=${prefix}/lib/aarch64-linux-gnu/openmpi/lib' '--includedir=${prefix}/lib/aarch64-linux-gnu/openmpi/include'

    # CFLAGS="-m64 -mcpu=cortex-a53 -mfloat-abi=hard -mfpu=neon-fp-armv8" FCFLAGS="-m64"
    # CFLAGS=-march=armv7-a CCASFLAGS=-march=armv7-a ../configure"
    cd "${PREFIX}/${OPEN_MPI_VER}" &&
      CFLAGS="-O3 -DNDEBUG -finline -finline-functions" ./configure \
        --prefix="${PREFIX}" --exec-prefix="${PREFIX}" \
        --enable-mpi-fortran --enable-memchecker --with-slurm \
        --with-valgrind --with-gnu-ld --enable-ipv6 \
        --with-hwloc="${PREFIX}" 2>&1 | tee "${PREFIX}/openmpi-config.log"

    echo -e "${CYAN}Make ${OPEN_MPI_VER}.tar.bz2${NC}"
    cd "${PREFIX}/${OPEN_MPI_VER}" && make -j4 all 2>&1 | tee "${PREFIX}/openmpi-make.log"

    echo -e "${CYAN}Install ${OPEN_MPI_VER}.tar.bz2${NC}"
    cd "${PREFIX}/${OPEN_MPI_VER}" && sudo make install 2>&1 | tee "${PREFIX}/openmpi-install.log"

    sudo ldconfig
  else
    echo -e "${CYAN}Cannot find ${PREFIX}/${OPEN_MPI_VER}${NC}"
  fi
}

function cleanup() {
  echo "cleanup" | figlet | lolcat

  # delete the build directories
  for item in "${list[@]}"; do
    echo -e "${LPURP}Deleting ${item}${NC}"
    rm -rf "${PREFIX:?}/${item}" # https://www.shellcheck.net/wiki/SC2115
  done

  # delete the tar files
  for package in "${GNU_PACKAGES[@]}"; do
    packagenametar=$(echo "${package}" | rev | cut -f1 -d'/' | cut -f2- -d'.' | rev)
    echo -e "${LPURP}Deleting ${packagenametar}${NC}"
    rm "${PREFIX:?}/${packagenametar}"
  done
}

function main() {
  check_host
  case $HOSTNAME in
  *)
    install_packages # Warning :: You will have problems if you do not use recent versions of the GNU Autotools
    gpg_setup
    build_gnu_tools
    #build_flex
    #build_munge
    #build_hwloc
    #build_pmix
    #build_prrte
    #verify_gnu_tools
    #build_openmpi
    #cleanup
    echo -e "${YELLOW}Now add ${PREFIX}/bin to the start of your PATH var.${NC}"
    echo -e "${LGREEN}Setup complete!${NC}"
    ;;
  host*) echo -e "${LRED}Run this script on the cluster head node${NC}" ;;
  esac
}

main "$@"
