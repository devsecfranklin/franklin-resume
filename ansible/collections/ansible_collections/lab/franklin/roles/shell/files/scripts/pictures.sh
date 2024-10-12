#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# v0.1 01/20/2023 copy in the pictures

set -o nounset # Treat unset variables as an error

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

declare -a FILE_TYPES=("png" "gif" "jpg")
TOTAL_PICS=0

function find_pictures() {
  for ft in ${FILE_TYPES[@]}; do
    convert_case
    for line in $(eval ls "./*.${ft}"); do
      CREATE_DATE=$(exiftool -all "${line}" | grep Create | rev | cut -d" " -f2 | rev)

      if [ ! -z "$CREATE_DATE" ]; then
        CREATE_YEAR=$(echo "${CREATE_DATE}" | cut -d":" -f1)
        CREATE_MONTH=$(echo "${CREATE_DATE}" | cut -d":" -f2)
        CREATE_DAY=$(echo "${CREATE_DATE}" | cut -d":" -f3)
        echo -e "${CYAN}File ${NC}${line}${CYAN} was created on ${NC}${CREATE_DATE}"
      fi
      TOTAL_PICS=$((${TOTAL_PICS} + 1))
    done
    #echo -e "${CYAN}Found ${TOTAL_PICS} pictures${NC}" # show total number of pics to start
  done

}

function find_duplicates() {
  file=$(mktemp /tmp/duplicates.XXXXX) || {
    echo "Error creating tmp file"
    exit 1
  }
  find $1 -type f | sort >$file
  awk -F/ '{print tolower($NF)}' $file | uniq -c | awk '$1>1 { sub(/^[[:space:]]+[[:digit:]]+[[:space:]]+/,""); print }' |
    while read line; do
      grep -i "$line" $file
    done

  # show number of suspected dupes
}

function fix_permissions() {
  # change file permissions to 644
  pass
}

function convert_case() {
  # convert picture file extensions to lower case
  echo "convert_case"
  #find . -name "*.${1}" -exec sh -c 'a=$(echo "$0" | sed -r "s/([^.]*)\$/\L\1/"); [ "$a" != "$0" ] && mv "$0" "$a" '{} \;

}

function main() {
  find_pictures
  echo -e "${CYAN}Processing ${TOTAL_PICS} pictures${NC}" # show total number of pics to start
  #find_duplicates
  #fix_permissions
  #convert_case
}

main
