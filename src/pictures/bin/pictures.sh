#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# v0.1 | 01/20/2023 | copy in the pictures
# v0.2 | 04/17/2025 | working on it some more

#set -o nounset # Treat unset variables as an error

IFS=$'\n' # make newlines the only separator

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
CYAN='\033[0;36m'
LPURP='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# locations:
# /mnt/passport/Pictures
# /home/franklin/Pictures
declare -a FOLDERS=("/home/franklin/Pictures" "/home/franklin/Videos")
declare -a FILE_TYPES=("png" "gif" "jpg")
declare -a VIDEO_TYPES=("mov" "mp4")

DEBUG=false
TMP_FILE=$(mktemp --directory)

TOTAL_PICS=0
TOTAL_VIDS=0

while getopts "d" opt; do
  case $opt in
    d)
      echo "debug mode enabled"
      DEBUG=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Shift the arguments to remove the parsed options
shift $((OPTIND - 1))

# Remaining arguments can be accessed here
# echo "Remaining arguments: $@"

function find_media() {
  echo -e "${YELLOW}Searching for media files. This may take a moment.${NC}"
  for dir in "${FOLDERS[@]}"; do
    find "${dir}" -type f -print0 | xargs -0 ls -Rh >>"${TMP_FILE}/all_media.txt"
  done

  # echo -e "${YELLOW}Count the picture files.${NC}"
  for ft in "${FILE_TYPES[@]}"; do
    while read -r line; do
      if [[ $line =~ \.${ft}$ ]]; then
        #echo -e "${LPURP}Found picture: echo ${line}${NC}"
        echo "${line}" >>"${TMP_FILE}/pictures.txt"
        TOTAL_PICS=$((TOTAL_PICS + 1))
      fi
    done <"${TMP_FILE}/all_media.txt"
  done

  # echo -e "${YELLOW}Count the video files.${NC}"
  for vt in "${VIDEO_TYPES[@]}"; do
    while read -r line; do
      if [[ $line =~ \.${vt}$ ]]; then
        #echo -e "${LPURP}Found video: ${line}${NC}"
        echo "${line}" >>"${TMP_FILE}/videos.txt"
        TOTAL_VIDS=$((TOTAL_VIDS + 1))
      fi
    done <"${TMP_FILE}/all_media.txt"
  done

  echo -e "${YELLOW}Found ${TOTAL_PICS} pictures${NC}"
  echo -e "${YELLOW}Found ${TOTAL_VIDS} videos${NC}"
}

function find_duplicates() {
  file=$(mktemp /tmp/duplicates.XXXXX) || {
    echo "Error creating tmp file"
    exit 1
  }
  find $1 -type f | sort >"$file"
  awk -F/ '{print tolower($NF)}' "$file" | uniq -c | awk '$1>1 { sub(/^[[:space:]]+[[:digit:]]+[[:space:]]+/,""); print }' |
    while read -r line; do
      grep -i "$line" "$file"
    done

  # show number of suspected dupes
}

function fix_permissions() {
  # change file permissions to 644
  pass
}

function convert_case() {
  # convert picture file extensions to lower case
  echo -e "${CYAN}Converting all files to lower case.${NC}"
  #find . -name "*.${1}" -exec sh -c 'a=$(echo "$0" | sed -r "s/([^.]*)\$/\L\1/"); [ "$a" != "$0" ] && mv "$0" "$a" '{} \;
  # sudo apt install rename && rename 's/ /_/g' *

}

function pull_exif_data() {
  echo -e "${CYAN}Pull the exif data for the pictures.${NC}"
  for ft in "${FILE_TYPES[@]}"; do
    PWD=$(pwd)
    for line in $(eval ls -Rh "${PWD}/*.${ft}" 2>/dev/null); do
      file -- $line
      CREATE_DATE=$(exiftool -all "${line}" | grep Create | rev | cut -d" " -f2 | rev)
      if [ "${CREATE_DATE}" ]; then
        echo -e "${CYAN}File creation date: ${NC}${CREATE_DATE}"
      fi
      if [ -n "$CREATE_DATE" ]; then
        CREATE_YEAR=$(echo "${CREATE_DATE}" | cut -d":" -f1 | tr -d '[:space:]')
        CREATE_MONTH=$(echo "${CREATE_DATE}" | cut -d":" -f2 | tr -d '[:space:]')
        CREATE_DAY=$(echo "${CREATE_DATE}" | cut -d":" -f3 | tr -d '[:space:]')
      fi
      echo -e "${CYAN}File ${NC}${line}${CYAN} was created on ${NC}${CREATE_MONTH}/${CREATE_DAY}/${CREATE_YEAR}"
    done
  done
}

function main() {
  echo -e "${CYAN}Created working directory: ${TMP_FILE}.${NC}"

  if [[ "${DEBUG}" == "true" ]]; then
    echo -e "${LRED}Debug mode enabled${NC}"
    set -x # Enable tracing
  else
    echo -e "${LPURP}Debug mode disabled${NC}"
  fi

  find_media # locate the data files

  echo -e "${CYAN}Processing ${TOTAL_PICS} pics and ${TOTAL_VIDS} videos.${NC}" # show total number of pics to start
  convert_case
  pull_exif_data
  #find_duplicates
  #fix_permissions
}

main "@"
