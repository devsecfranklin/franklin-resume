#!/bin/bash

# Date: 01/20/2023
# franklin@dead10c5.org

# copy in the pictures

# /mnt/passport/Pictures
# /home/franklin/Pictures

# show total number of pics to start

# find dupes
file=$(mktemp /tmp/duplicates.XXXXX) || {
  echo "Error creating tmp file"
  exit 1
}
find $1 -type f | sort >$file
awk -F/ '{print tolower($NF)}' $file |
  uniq -c |
  awk '$1>1 { sub(/^[[:space:]]+[[:digit:]]+[[:space:]]+/,""); print }' |
  while read line; do
    grep -i "$line" $file
  done

# show number of suspected dupes

# change file permissions to 644

# convert picture file extensions to lower case
find . -name '*.*' -exec sh -c 'a=$(echo "$0" | sed -r "s/([^.]*)\$/\L\1/"); [ "$a" != "$0" ] && mv "$0" "$a" ' {} \;
#rename 's/\.([^.]+)$/.\L$1/' *
