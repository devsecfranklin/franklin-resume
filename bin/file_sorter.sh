#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2022-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# ChangeLog:
#

# Check if a directory is provided as an argument
if [ $# -ne 1 ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

directory="$1" # get the contents of this current dir and subdirs

# Check if the directory exists and is a directory
if [ ! -d "$directory" ]; then
  echo "Error: Directory '$directory' does not exist or is not a directory."
  exit 1
fi

# determine the file type

# sort by file extension
# remove executable perms from text files, pics, etc. (basically clean up after microshaft)

file_extension="${file##*.}"

if [[ "$file_extension" == "$extension" ]]; then
  echo "The file has the extension .$extension"
else
  echo "The file does not have the extension .$extension"
fi

# Create a temporary directory to store the sorted files
temp_dir=$(mktemp -d)

# Iterate through each file in the directory
for file in "$directory"/*; do
  if [ -f "$file" ]; then
    # Get the file extension
    extension="${file##*.}"
    filename="${file##*/}" #get just the filename.

    # If the extension is empty, it means the file has no extension
    if [ -z "$extension" ]; then
      extension="no_extension"
    fi

    # Create a subdirectory for the extension if it doesn't exist
    extension_dir="$temp_dir/$extension"
    mkdir -p "$extension_dir"

    # Move the file to the corresponding extension subdirectory
    mv "$file" "$extension_dir/$filename"
  fi
done
