#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# v0.1 | 02/15/2024 | initial version | franklin
# v0.2 | 05/28/2024 | combine to a single doc file for simplicity | franklin
# v0.3 | 09/09/2024 | integrate script with lab-franklin repo | franklin

#set -euo pipefail
#IFS=$'\n\t'

# TO-DO: try this out
# https://github.com/pdoc3/pdoc

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

RED='\033[0;31m'
LRED='\033[1;31m'
LGREEN='\033[1;32m'
LBLUE='\033[1;34m'
CYAN='\033[0;36m'
LPURP='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Some config Variables ----------------------------------------
DATA_DIR="/tmp/palo/data"
DOCS_DIR="/tmp/palo/data"
LOGGING_DIR="/tmp/palo/log"
MY_DATE=$(date '+%Y-%m-%d-%H')
RAW_OUTPUT="${LOGGING_DIR}/generate_pdf_docs_${MY_DATE}.txt" # log file name

function directory_setup() {
  if [ ! -d "${LOGGING_DIR}" ]; then
    echo -e "${LRED}Did not find log dir: ${LCYAN}${LOGGING_DIR}${NC}"
    mkdir -p ${LOGGING_DIR}
    echo -e "${LGREEN}Creating logging directory: ${LCYAN}${LOGGING_DIR}${NC}" | tee -a "${RAW_OUTPUT}"
  fi

  echo -e "\n${LCYAN}------------------ Starting Doc Generation Tool ------------------${NC}" | tee -a "${RAW_OUTPUT}"
  echo -e "${LGREEN}Log file path is: ${LCYAN}${RAW_OUTPUT}${NC}" | tee -a "${RAW_OUTPUT}"

  if [ ! -d "${DATA_DIR}" ]; then
    echo -e "${LRED}Did not find data dir: ${LCYAN}${DATA_DIR}${NC}"
    #DATA_DIR="."
    mkdir -p ${DATA_DIR}
  fi
  echo -e "${LGREEN}Data directory is: ${LCYAN}${DATA_DIR}${NC}" | tee -a "${RAW_OUTPUT}"

  if [ ! -d "${DOCS_DIR}" ]; then
    echo -e "${LRED}Did not find documentation directory: ${LCYAN}${DOCS_DIR}${NC}"
    mkdir -p ${DOCS_DIR}
  fi
  echo -e "${LGREEN}Doc build directory is: ${LCYAN}${DOCS_DIR}${NC}" | tee -a "${RAW_OUTPUT}"
}

function generate_customer_pdf() {
  echo "Generate the PDF documentation for this project"
  if [ ! -d "docs/pdf" ]; then
    echo -e "${LRED}Did not find documentation directory: ${LCYAN}docs/pdf${NC}"
    exit 1
  fi
  if [ ! -d "${DOCS_DIR}/pdf" ]; then mkdir -p ${DOCS_DIR}/pdf; fi
  pandoc --toc -f markdown-implicit_figures docs/markdown/customer.md -t pdf -o docs/pdf/customer.pdf
  cp docs/pdf/customer.pdf ${DOCS_DIR}/pdf
}

function generate_html() {
  if [ ! -d "/tmp/palo/docs/html" ]; then mkdir -p /tmp/palo/docs/html; fi
  #echo "Generate the HTML documentation for this project"
  pandoc docs/markdown/customer.md -s -o /tmp/palo/docs/html/customer.html
}

function generate_latex() {
  echo "Generate the LaTeX documentation for this project"
  LATEX_DIR="${DOCS_DIR}/latex/customer"
  if [ ! -d "${LATEX_DIR}/images/" ]; then mkdir -p ${LATEX_DIR}/images; fi
  cp -Rp docs/images/customer/*.png ${LATEX_DIR}/images
  pandoc --toc -f markdown-implicit_figures -t latex docs/markdown/customer.md -o ${LATEX_DIR}/customer_pre.tex
  cat docs/latex/customer/header.tex docs/latex/customer/customer_pre.tex docs/latex/customer/footer.tex >${LATEX_DIR}/customer.tex
  sed -i -e "s/includegraphics{docs\/customer\/images/includegraphics{\/tmp\/palo\/docs\/latex\/customer\/images/g" ${LATEX_DIR}/customer.tex # fix image directory
}

function main() {
  if [ ! -d "docs" ] && [ ! -d "bin" ]; then
    echo -e "${LRED}Run script from top level of repo"
    exit 1
  fi

  directory_setup
  generate_customer_pdf
  generate_html
  generate_latex
}

main "@"
