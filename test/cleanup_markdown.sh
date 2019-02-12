#!/bin/bash - 
#===============================================================================
#
#          FILE: cleanup_markdown.sh
# 
#         USAGE: ./cleanup_markdown.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 02/12/2019 10:17
#      REVISION:  ---
#===============================================================================
set -o nounset                              # Treat unset variables as an error

# MD009 Trailing spaces
function md009 {
  find markdown -name '*.md'|while read fname; do
    #echo "$fname"
    #echo "Check for trailing whitespace in ${fname}"
    sed -i 's/[ \t]*$//' "$fname"
  done
}

function md032 {
  find .. -name '*.md'|while read fname; do
    #echo "Check for headers in ${fname}"
    NEXT_LINE=$(sed -n -e '/^#/{n;p;}' "$fname")
    if [ ! -z "$NEXT_LINE" ]; 
    then
      sed -i '/^#/{G;}' "$fname"
    fi
  done
}

function main {

  md009
  md032

}

main $@
