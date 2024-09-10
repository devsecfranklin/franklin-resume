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

# --- Some config Variables ----------------------------------------
DATA_DIR="/tmp/palo/data"
LOGGING_DIR="/tmp/palo/log"
MY_DATE=$(date '+%Y-%m-%d-%H')
RAW_OUTPUT="generate_pdf_docs_${MY_DATE}.txt" # log file name

function directory_setup() {
  if [ ! -d "${LOGGING_DIR}" ]; then
    echo -e "${LRED}Did not find log dir: ${LCYAN}${LOGGING_DIR}${NC}"
    mkdir -p ${LOGGING_DIR}
    echo -e "${LGREEN}Creating logging directory: ${LCYAN}${LOGGING_DIR}${NC}" | tee -a "${RAW_OUTPUT}"
  fi

  RAW_OUTPUT="${LOGGING_DIR}/${RAW_OUTPUT}"
  echo -e "\n${LCYAN}------------------ Starting Doc Generation Tool ------------------${NC}" | tee -a "${RAW_OUTPUT}"
  #echo -e "${LGREEN}Using log dir: ${LCYAN}${LOGGING_DIR}${NC}" | tee -a "${RAW_OUTPUT}"
  echo -e "${LGREEN}Log file path is: ${LCYAN}${RAW_OUTPUT}${NC}" | tee -a "${RAW_OUTPUT}"

  if [ ! -d "${DATA_DIR}" ]; then
    echo -e "${LRED}Did not find data dir: ${LCYAN}${DATA_DIR}${NC}"
    #DATA_DIR="."
    mkdir -p ${DATA_DIR}
  fi
  echo -e "${LGREEN}Data directory is: ${LCYAN}${DATA_DIR}${NC}" | tee -a "${RAW_OUTPUT}"
}

function generate_pdf() {
  echo "Generate the PDF documentation for this project"
  if [ ! -d "docs/pdf" ]; then mkdir docs/pdf; fi
  if [ ! -d "/tmp/palo/docs/pdf" ]; then mkdir -p /tmp/palo/docs/pdf; fi
  pandoc --toc -f markdown-implicit_figures docs/markdown/customer.md -t pdf -o docs/pdf/customer.pdf
  cp docs/pdf/customer.pdf /tmp/palo/docs/pdf
}

function generate_html() {
  if [ ! -d "/tmp/palo/docs/html" ]; then mkdir -p /tmp/palo/docs/html; fi
  #echo "Generate the HTML documentation for this project"
  pandoc docs/markdown/customer.md -s -o /tmp/palo/docs/html/customer.html
}

function generate_latex() {
  echo "Generate the LaTeX documentation for this project"
  if [ ! -d "/tmp/palo/docs/latex/images/" ]; then mkdir -p /tmp/palo/docs/latex/images; fi
  cp -Rp docs/images/*.png /tmp/palo/docs/latex/images
  pandoc --toc -f markdown-implicit_figures -t latex docs/markdown/customer.md -o /tmp/palo/docs/latex/customer_pre.tex
  cat docs/latex/header.tex docs/latex/customer_pre.tex docs/latex/footer.tex >/tmp/palo/docs/latex/customer.tex
  sed -i -e "s/includegraphics{docs\/images/includegraphics{\/tmp\/palo\/docs\/latex\/images/g" /tmp/palo/docs/latex/customer.tex # fix image directory
}

function main() {
  if [ ! -d "docs" ] && [ ! -d "bin" ]; then
    echo "Run script from top level of repo"
    exit 1
  fi

  generate_pdf
  generate_html
  generate_latex
}

main "@"
