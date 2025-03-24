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
DOCS_DIR="/tmp/palo/docs"
HTML_DIR="${DOCS_DIR}/html"
LATEX_DIR="${DOCS_DIR}/latex/customer"
LOGGING_DIR="/tmp/palo/log"
MARKDOWN_DIR="${DOCS_DIR}/markdown"
MY_DATE=$(date '+%Y-%m-%d-%H')
PDF_DIR="${DOCS_DIR}/pdf"
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
    echo -e "${LRED}Did not find data dir, creating: ${LCYAN}${DATA_DIR}${NC}"
    mkdir -p ${DATA_DIR}
  fi
  echo -e "${LGREEN}Data directory is: ${LCYAN}${DATA_DIR}${NC}" | tee -a "${RAW_OUTPUT}"

  if [ ! -d "${DOCS_DIR}" ]; then
    echo -e "${LRED}Did not find documentation directory, creating: ${LCYAN}${DOCS_DIR}${NC}"
    mkdir -p ${DOCS_DIR}
  fi
  echo -e "${LGREEN}Doc build directory is: ${LCYAN}${DOCS_DIR}${NC}" | tee -a "${RAW_OUTPUT}"
}

function markdown() {
  echo -e "${CYAN}Copy markdown files.${NC}"
  if [ ! -d "${MARKDOWN_DIR}" ]; then mkdir -p ${MARKDOWN_DIR}; fi
  cp -Rp docs/markdown ${DOCS_DIR} # copy the whole markdown folder to tmp
  cp ${MARKDOWN_DIR}/customer.md ${MARKDOWN_DIR}/customer_fixed.md
  sed -i -e "s/docs\/images\/customer//g" ${MARKDOWN_DIR}/customer_fixed.md # fix image directory from markdown
}

function generate_html() {
  echo -e "${CYAN}Generate the HTML documentation for this project.${NC}"
  if [ ! -d "${HTML_DIR}" ]; then mkdir -p ${HTML_DIR}; fi
  if check_installed pandoc; then
    echo -e "${CYAN}Running pandoc to generate PDF.${NC}"
    pandoc ${MARKDOWN_DIR}/customer.md -s -o ${HTML_DIR}/customer.html
  else
    echo -e "${YELLOW}Unable to generate PDF from markdown files. Is pandoc installed?${NC}"
  fi
}

function generate_latex() {
  echo -e "${CYAN}Generate the LaTeX documentation for this project${NC}"
  if [ ! -d "${LATEX_DIR}/images/" ]; then mkdir -p ${LATEX_DIR}/images; fi # check latex and image dir in one shot
  cp -Rp docs/latex/customer/*.tex ${LATEX_DIR}
  cp -Rp docs/images/customer/*.png ${LATEX_DIR}/images
  if check_installed pandoc; then
    echo -e "${CYAN}Running pandoc to generate PDF.${NC}"
    pandoc --toc -f markdown-implicit_figures -t latex ${MARKDOWN_DIR}/customer_fixed.md -o ${LATEX_DIR}/customer_pre.tex
    cat ${LATEX_DIR}/header.tex ${LATEX_DIR}/customer_pre.tex ${LATEX_DIR}/footer.tex >${LATEX_DIR}/customer.tex
  else
    echo -e "${YELLOW}Unable to generate PDF from markdown files. Is pandoc installed?${NC}"
  fi
}

function generate_customer_pdf() {
  echo -e "${CYAN}Generate the PDF documentation for this project.${NC}"

  if [ ! -d "docs/pdf" ]; then echo -e "${LRED}Did not find documentation directory: ${LCYAN}docs/pdf${NC}" && exit 1; fi
  if [ ! -d "${PDF_DIR}" ]; then mkdir -p ${PDF_DIR}; fi

  if check_installed pandoc; then
    echo -e "${CYAN}Running pandoc to generate PDF.${NC}"
    pandoc --toc -f markdown-implicit_figures ${MARKDOWN_DIR}/customer.md -t pdf -o ${PDF_DIR}/customer_pandoc.pdf
  else
    echo -e "${YELLOW}Unable to generate PDF from markdown files. Is pandoc installed?${NC}"
  fi

  if check_installed latexmk; then
    latexmk -pdf -file-line-error -interaction=nonstopmode -synctex=1 -shell-escape customer
    echo -e "${LBLUE}Running latexmk to generate PDF.${NC}"
  else
    echo -e "${YELLOW}Unable to generate PDF from LaTeX files. Is latexmk installed?${NC}"
  fi

  if [ -f "${PDF_DIR}/customer.pdf" ]; then cp -r ${PDF_DIR}/customer.pdf docs/pdf/customer.pdf; fi # copy the results back to repo
}

function check_installed() {
  if ! command -v "${1}" &>/dev/null; then
    echo -e "${LRED}${1} could not be found${NC}"
    return 1
  else
    echo -e "${LPURP}Found command: ${1}${NC}"
    return 0
  fi
}

function main() {
  if [ ! -d "docs" ] && [ ! -d "bin" ]; then
    echo -e "${LRED}Run script from top level of repo"
    exit 1
  fi

  directory_setup
  markdown
  generate_html
  generate_latex
  generate_customer_pdf

}

main "@"
