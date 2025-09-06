#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2021-2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT

# ChangeLog:
#
# v0.1 02/25/2022 Maintainer script
# v0.2 09/24/2022 Update this script
# v0.3 10/19/2022 Add tool functions
# v0.4 11/10/2022 Add automake check
# v0.5 11/16/2022 Handle container builds
# v0.6 07/13/2023 Add required_files and OpenBSD support
# v0.7 04/22/2024 More OpenBSD support
# v0.8 09/06/2024 Support GCP Linux
# v0.9 02/18/2025 Updates for Mac
# v1.0 02/26/2025 Optimize some functions using Gemini 2.0 Flash
# v1.1 05/29/2025 Update the OS Detection function, add HW Detection function

#set -euo pipefail

# The special shell variable IFS determines how Bash
# recognizes word boundaries while splitting a sequence of character strings.
#IFS=$'\n\t'

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
LBLUE='\033[1;34m'
CYAN='\033[0;36m'
LPURP='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Some config Variables ----------------------------------------
CONTAINER=false
DEB_PKG=(ansible figlet libglib2.0-dev libonig-dev tox sshpass libxml2-utils shellcheck screen make gcc git automake sqlite3 libsqlite3-dev podman libtool doxygen latexmk gawk doxygen-latex nodejs npm apt-transport-https ca-certificates curl gnupg lsb-release direnv clustershell)
#DOCUMENTATION=false
KERNEL=$(uname -r)       # the kernel version
MACHINE_TYPE=$(uname -m) # the machine type
MY_DATE=$(date '+%Y-%m-%d-%H')
MY_OS=$(uname | tr '[:upper:]' '[:lower:]') # usually "linux"
MY_UNAME=$(uname)
OS_RELEASE="$(cat /etc/os-release | grep "^ID=" | cut -d"=" -f2)"
PRIV_CMD="sudo"
RAW_OUTPUT="/tmp/bootstrap_lab_${MY_DATE}.log"

# Check if we are inside a container
function check_container() {
  echo -e "\n${LPURP}# --- Check Container Status ------------------------------------------\n${NC}" | tee -a "${RAW_OUTPUT}"
  if [ -f /.dockerenv ]; then
    echo -e "${YELLOW}Containerized build environment...${NC}"
    CONTAINER=true
  else
    echo -e "${LBLUE}NOT a containerized build environment...${NC}"
  fi
}

function check_python_version() {
  echo -e "\n${LPURP}# --- Check Python Version -------------------------------------------\n${NC}" | tee -a "${RAW_OUTPUT}"
  if command -v python &>/dev/null; then
    PYTHON_VERSION=$(python -c 'import sys; print(sys.version_info.major)')
    if [[ "$PYTHON_VERSION" -eq 3 ]]; then
      echo -e "${LBLUE}The 'python' command points to Python 3.${NC}"
      # Use 'python'
      PYTHON_CMD="python"
    elif [[ "$PYTHON_VERSION" -eq 2 ]]; then
      echo -e "${LBLUE}The 'python' command points to Python 2.${NC}"

      # Decide what to do: try python3, or exit
      if command -v python3 &>/dev/null; then
        echo -e "Using 'python3' instead."
        PYTHON_CMD="python3"
      else
        echo -e "${LRED}Error: Python 3 not found. Exiting.${NC}"
        exit 1
      fi
    else
      echo -e "${LRED}The 'python' command points to an unknown Python version ($PYTHON_VERSION).${NC}"
      # Decide what to do
      if command -v python3 &>/dev/null; then
        echo "Attempting to use 'python3' instead.${NC}"
        PYTHON_CMD="python3"
      else
        echo -e "${LRED}Error: Python 3 not found. Exiting.${NC}"
        exit 1
      fi
    fi
  elif command -v python3 &>/dev/null; then
    echo "'python' command not found, using 'python3'.${NC}"
    PYTHON_CMD="python3"
  else
    echo -e "${LRED}Error: Neither 'python' nor 'python3' found. Please install Python 3. Exiting.${NC}"
    exit 1
  fi

  echo -e "${LBLUE}Using Python command: ${PYTHON_CMD}${NC}"
}

function detect_hardware() {
  # FIXME: need to detect ubuntu running on nvidia
  echo -e "\n${LPURP}# --- Hardware Detection ----------------------------------------------\n${NC}" | tee -a "${RAW_OUTPUT}"

  echo -e "${LBLUE}Machine type: ${MACHINE_TYPE}${NC}"
  echo -e "${LBLUE}Kernel: ${MACHINE_TYPE}${NC}"

  # ---------- # RASPBERRY PI #----------#
  # $PYTHON_CMD -c "import platform; print ('raspberrypi') in platform.uname()"
  # check /proc/cpuinfo for "Model"
  IS_RASPI="$(grep Model /proc/cpuinfo | cut -f2 -d':')"
  if [ -n "${IS_RASPI}" ]; then
    echo -e "${YELLOW}Found Raspberry Pi: ${IS_RASPI}${NC}"
    install_raspberry_pi
    # cat /proc/device-tree/model
  fi
}

function detect_os() {
  # FIXME: need to detect ubuntu running on nvidia
  echo -e "\n${LPURP}# --- Operating System Detection --------------------------------------\n${NC}" | tee -a "${RAW_OUTPUT}"

  # first know the OS
  if [ -n "${MY_OS}" ]; then
    echo -e "${LBLUE}Operating System based on uname: ${MY_OS}${NC}"
  fi

  case $MY_OS in

  linux)
    # if linux, check the distro. check for the /etc/os-release file
    if [ -n "${OS_RELEASE}" ]; then
      echo -e "${LBLUE}Found /etc/os-release file: ${OS_RELEASE}${NC}"
      if [ "${OS_RELEASE}" == "debian" ]; then install_debian; fi
    fi

    #if [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]; then
    #  echo -e "${CYAN}Detected Debian/Ubuntu/Mint${NC}"
    #fi

    if [ -f "/etc/redhat-release" ]; then
      echo -e "${CYAN}Detected Red Hat/CentOS/RHEL${NC}\n"
      MY_OS="rh"
      install_redhat
    fi

    if grep -q Microsoft /proc/version; then
      echo -e "${CYAN}Detected Windows pretending to be Linux${NC}\n"
      MY_OS="win"
    fi
    ;;
  openbsd)
    echo -e "${LBLUE}Detected OpenBSD${NC}\n"
    PRIV_CMD="doas" # there is no sudo
    install_openbsd
    ;;
  darwin)
    echo -e "${CYAN}Detected MacOS${NC}\n"
    check_installed brew
    install_macos
    ;;
  *)
    echo -e "${YELLOW}Unrecongnized architecture. Time to panic!${NC}\n"
    exit 1
    ;;
  esac
}

function run_autopoint() {
  echo "Checking autopoint version..."
  ver=$(autopoint --version | awk '{print $NF; exit}')
  ap_maj=$(echo $ver | sed 's;\..*;;g')
  ap_min=$(echo $ver | sed -e 's;^[0-9]*\.;;g' -e 's;\..*$;;g')
  ap_teeny=$(echo $ver | sed -e 's;^[0-9]*\.[0-9]*\.;;g')
  echo "    $ver"

  case $ap_maj in
  0)
    if test $ap_min -lt 14; then
      echo "You must have gettext >= 0.14.0 but you seem to have $ver"
      exit 1
    fi
    ;;
  esac
  echo "Running autopoint..."
  autopoint --force || exit 1
}

function run_libtoolize() {
  echo -e "\n${LPURP}# --- Run libtoolize --------------------------------------------------\n${NC}" | tee -a "${RAW_OUTPUT}"
  echo -e "Checking libtoolize version...\n"
  libtoolize --version 2>&1 >/dev/null
  rc=$?
  if test $rc -ne 0; then
    echo "Could not determine the version of libtool on your machine"
    echo "libtool --version produced:"
    libtool --version
    exit 1
  fi
  lt_ver=$(libtoolize --version | awk '{print $NF; exit}')
  lt_maj=$(echo $lt_ver | sed 's;\..*;;g')
  lt_min=$(echo $lt_ver | sed -e 's;^[0-9]*\.;;g' -e 's;\..*$;;g')
  #lt_teeny=$(echo $lt_ver | sed -e 's;^[0-9]*\.[0-9]*\.;;g')
  echo "    $lt_ver"

  case $lt_maj in
  0)
    echo "You must have libtool >= 1.4.0 but you seem to have ${lt_ver}"
    exit 1
    ;;
  1)
    if test "${lt_min}" -lt 4; then
      echo "You must have libtool >= 1.4.0 but you seem to have ${lt_ver}"
      exit 1
    fi
    ;;
  2) ;;
  *)
    echo "You are running a newer libtool than gerbv has been tested with."
    echo "It will probably work, but this is a warning that it may not."
    ;;
  esac
  echo "Running libtoolize..."
  libtoolize --force --copy --automake || exit 1
}

function run_aclocal() {
  echo -e "\n${LPURP}# --- Running aclocal -------------------------------------------------\n${NC}" | tee -a "${RAW_OUTPUT}"
  if [ "${MY_OS}" != "openbsd" ]; then
    echo -e "${LBLUE}Checking aclocal version...${NC}"
    acl_ver=$(aclocal --version | awk '{print $NF; exit}')
    echo "    $acl_ver"

    echo -e "${CYAN}Running aclocal...${NC}"
    #aclocal -I m4 $ACLOCAL_FLAGS || exit 1
    aclocal -Iaclocal/latex-m4 || exit 1
  else
    AUTOCONF_VERSION=2.71 AUTOMAKE_VERSION=1.16 aclocal -Iaclocal/latex-m4 || exit 1
  fi
  echo -e "${CYAN}.. done with aclocal.${NC}"
}

function run_autoheader() {
  echo -e "\n${LPURP}# --- Running autoheader ----------------------------------------------\n${NC}" | tee -a "${RAW_OUTPUT}"
  echo "Checking autoheader version..."
  ah_ver=$(autoheader --version | awk '{print $NF; exit}')
  echo "    $ah_ver"

  echo "Running autoheader..."
  autoheader || exit 1
  echo "... done with autoheader."
}

function run_automake() {
  echo -e "\n${LPURP}# --- Running automake ------------------------------------------------\n${NC}" | tee -a "${RAW_OUTPUT}"
  if [ "${MY_OS}" != "openbsd" ]; then
    echo "Checking automake version..."
    am_ver=$(automake --version | awk '{print $NF; exit}')
    echo "    $am_ver"

    echo "Running automake..."
    automake -a -c --add-missing || exit 1
    #automake --force --copy --add-missing || exit 1
  else
    AUTOCONF_VERSION=2.71 AUTOMAKE_VERSION=1.16 automake -a -c --add-missing || exit 1
  fi
  echo "... done with automake."
}

function run_autoconf() {
  echo -e "\n${LPURP}# --- Running autoconf ------------------------------------------------\n${NC}" | tee -a "${RAW_OUTPUT}"
  if [ "${MY_OS}" != "openbsd" ]; then
    echo -e "${LGREEN}Checking autoconf version...${NC}"
    ac_ver=$(autoconf --version | awk '{print $NF; exit}')
    echo -e "${LGREEN}Autoconf version: $ac_ver${NC}"
    echo "Running autoconf..."
    autoreconf -i || exit 1
  else
    # this is for OpenBSD systems
    ac_ver="2.71"
    echo "Running autoconf..."
    AUTOCONF_VERSION=2.71 AUTOMAKE_VERSION=1.16 autoreconf -i || exit 1
  fi
  echo "... done with autoconf."
}

function check_installed() {
  if command -v "$1" &>/dev/null; then
    printf "${LBLUE}Found command: %s${NC}\n" "$1"
    return 0
  else
    printf "${LRED}%s could was not found${NC}\n" "$1"
    return 1
  fi
}

function install_macos() {
  echo -e "\n${LPURP}# --- Installing for MacOS --------------------------------------------\n${NC}" | tee -a "${RAW_OUTPUT}"
  #declare -a Packages=("ac")
  declare -a Packages=("docker" "docker-compose" "google-cloud-sdk" "git" "bash" "make" "automake" "gsed" "gawk" "direnv" "terraform" "libtool" "jq" "google-cloud-sdk" "coreutils")

  echo -e "${CYAN}Updating brew for MacOS (this may take a while...)${NC}"
  brew update
  #brew upgrade google-cloud-sdk # this is to avoid the error: ModuleNotFoundError: No module named 'imp'

  for i in "${Packages[@]}"; do
    if brew list "${i}" &>/dev/null; then
      echo -e "${LGREEN}${i} is already installed${NC}"
      brew upgrade "${i}"
    else
      brew install "${i}"
    fi
  done

  echo -e "${CYAN}Updating Google gcloud for MacOS (this may take a while...)${NC}"
  (yes || true) | "${HOME}/homebrew/bin/gcloud" components update

  if [ ! -f "./config.status" ]; then
    echo -e "${CYAN}Running libtool/autoconf/automake...${NC}"
    # glibtoolize
    aclocal -I config
    autoreconf -i
    automake -a -c --add-missing
  else
    echo -e "${CYAN}Your system is already configured. (Delete config.status to reconfigure)${NC}"
    ./config.status
  fi
  echo -e "${CYAN}HINT: now type \"./configure\"${NC}"

  # https://github.com/kreuzwerker/m1-terraform-provider-helper/blob/main/README.md
  brew install kreuzwerker/taps/m1-terraform-provider-helper
  brew tap hashicorp/tap
  brew install hashicorp/tap/terraform
  brew install yasm
  m1-terraform-provider-helper activate
  #m1-terraform-provider-helper install hashicorp/template -v v2.2.0 # DEPRECATED
  #terraform providers lock -platform=darwin_arm64
  #terraform providers lock -platform=linux_amd64

  echo -e "${CYAN}Running brew cleanup...${NC}"
  brew cleanup
}

function install_debian() {
  # Container package installs will fail unless you do an initial update, the upgrade is optional
  if [ "${CONTAINER}" = true ]; then
    echo -e "${LBLUE}Upgrading container packages${NC}"
    sudo apt-get update && apt-get upgrade -y
    sudo apt-get autoremove -y
  fi

  for i in "${DEB_PKG[@]}"; do
    if [ $(dpkg-query -W -f='${Status}' ${i} 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
      echo -e "${LBLUE}Installing ${i} since it is not found.${NC}"
      # If we are in a container there is no sudo in Debian
      if [ "${CONTAINER}" = true ]; then
        $PRIV_CMD apt-get --yes install "${i}"
        $PRIV_CMD apt-get autoremove -y
      else
        $PRIV_CMD apt-get install "${i}" -y
        $PRIV_CMD apt-get autoremove -y
      fi
    fi
  done

  if ! check_installed dircolors && [ ! -d "${HOME}/.dircolors" ]; then
    dircolors -p >~/.dircolors
    echo -e "${LBLUE}Updating the dircolors configuration.${NC}"
  fi
}

function install_az_cli() {
  # Install az cli tool for Azure
  #curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
  # sudo apt-get update
  # sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release
  # sudo mkdir -p /etc/apt/keyrings
  # curl -sLS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null
  # sudo chmod go+r /etc/apt/keyrings/microsoft.gpg
  # AZ_DIST=$(lsb_release -cs)
  # echo "Types: deb
  # URIs: https://packages.microsoft.com/repos/azure-cli/
  # Suites: ${AZ_DIST}
  # Components: main
  # Architectures: $(dpkg --print-architecture)
  # Signed-by: /etc/apt/keyrings/microsoft.gpg" | sudo tee /etc/apt/sources.list.d/azure-cli.sources
  # sudo apt-get update
  # sudo apt-get install azure-cli
  echo "" #pass
}

function debian() {
  # sudo apt install gnuplot gawk libtool psutils make autopoint
  # run_autopoint
  run_aclocal
  autoreconf -i
  run_automake
  ./configure
  #./config.status
}

function redhat() {
  if [ ! -f "./config.status" ]; then
    mkdir -p aclocal # Create aclocal if needed
    run_aclocal
    autoreconf -i
    run_automake
    ./configure
  else
    ./config.status
  fi
}

function install_redhat() {
  echo -e "${CYAN}RedHat 8 setup${NC}"
  dnf upgrade -y
  yum -y --disableplugin=subscription-manager update
  dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

  declare -a Packages=("make" "automake" "autoconf" "libtool" "texlive")
  for i in "${Packages[@]}"; do
    dnf install -y "${i}" --skip-broken
  done
}

function required_files() {
  echo -e "\n${LPURP}# --- Check GNU Autotools files ----------------------------------------\n${NC}" | tee -a "${RAW_OUTPUT}"
  local required_files=("AUTHORS" "ChangeLog" "NEWS")

  for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
      printf "${LGREEN}Creating required file %s since it is not found.${NC}\n" "$file"
      ln -sf README.md "$file" # Use -sf to force and be silent
    else
      printf "${LBLUE}Found required file %s.${NC}\n" "$file"
    fi
  done
}

function install_openbsd() {
  echo -e "${LPURP}# --- OpenBSD Installation ----------------------------------------------\n${NC}" | tee -a "${RAW_OUTPUT}"
  doas pkg_add colorls
  LINE="alias ls=\"colorls -G\""
  grep -qF -- "$LINE" "$HOME/.bashrc" || echo "$LINE" >>"$HOME/.bashrc"
}

function configure_ansible() {
  echo -e "\n${LBLUE}# --- Configuring Ansible ---------------------------------------------\n${NC}" | tee -a "${RAW_OUTPUT}"
  if [ -d "/var/log/ansible" ]; then
    echo -e "${LBLUE}Found /var/log/ansible.${NC}"
  else
    echo -e "${LBLUE}Attempting to create /var/log/ansible...${NC}"
    $PRIV_CMD mkdir /var/log/ansible
    $PRIV_CMD chown nobody:engr /var/log/ansible
    $PRIV_CMD chmod 770 /var/log/ansible
    if ! $?; then
      echo -e "${LGREEN}The /var/log/ansible directory already exists.${NC}\n"
    fi
  fi
}

function install_raspberry_pi() {
  R_PI=$($PYTHON_CMD -c "import platform; print('raspberrypi') in platform.uname()")
  echo -e "\n${LPURP}# --- Raspberry Pi Setup ----------------------------------------------\n${NC}" | tee -a "${RAW_OUTPUT}"
  # sudo apt-get install netselect netselect-apt -y
  # netselect-apt testing
  # netselect-apt stable
  # netselect-apt unstable # for debian x64

  # if [ "$R_PI" = "raspberrypi" ]; then
  #   echo -e "${LBLUE}Running netselect.${NC}"
  #   sudo netselect-apt bookworm # for raspi
  #   # yes | bash <(curl -s https://gist.githubusercontent.com/blacktm/8302741/raw/install_ruby_rpi.sh)
  # fi

}

function cleanup() {
  echo -e "\n${LPURP}# --- Cleanup ---------------------------------------------------------\n${NC}" | tee -a "${RAW_OUTPUT}"
  echo -e "${LPURP}Cleanup!${NC}"
  find . -type d -print0 | xargs -0 chmod 755
  find . -type f -print0 | xargs -0 chmod 644
}

# --- The main() function ----------------------------------------
function main() {
  check_container
  check_python_version

  if [ ! -d "aclocal" ]; then
    echo "create aclocal dir"
    mkdir -p aclocal
  fi

  if [ ! -d "config/m4" ]; then
    echo "create congif/m4 dir"
    mkdir -p config/m4
  fi

  if [ ! -f "Makefile.in" ] && [ -f "./config.status" ]; then
    rm config.status # if Makefile.in is missing, then erase stale config.status
  fi

  detect_os
  detect_hardware
  # check_installed doxygen
  required_files
  configure_ansible

  echo -e "\n${LPURP}# --- Configure the build ---------------------------------------------\n${NC}" | tee -a "${RAW_OUTPUT}"
  if [ ! -f "./config.status" ]; then
    echo -e "${YELLOW}no config.status${NC}"
    # libtoolize
    if [ ! -d "aclocal" ]; then mkdir aclocal; fi
    #aclocal -I config
    run_aclocal
    if [ "${MY_OS}" == "openbsd" ]; then
      AUTOCONF_VERSION=2.71 AUTOMAKE_VERSION=1.16 autoreconf -i || exit 1
    else
      autoreconf -i
    fi
    #automake -a -c --add-missing
    run_automake
    ./configure
  else
    ./config.status
  fi

  # cleanup
}

main "$@"
