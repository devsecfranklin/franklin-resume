#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2024 Palo Alto Networks, Inc.  All rights reserved. <fdiaz@paloaltonetworks.com>
#
# SPDX-License-Identifier: https://www.paloaltonetworks.com/legal/script-software-license-1-0.pdf

# deletes the temp directory
function cleanup() {
    rm -rf "$WORK_DIR"
    echo "Deleted temp working directory $WORK_DIR"
}

function main() {

    # the temp directory used, within $DIR
    # omit the -p parameter to create a temporal directory in the default location
    WORK_DIR=$(mktemp -d -p "/tmp")

    # check if tmp dir was created
    if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
        echo "Could not create temp dir"
        exit 1
    fi

    # register the cleanup function to be called on the EXIT signal
    trap cleanup EXIT

    mkdir "${WORK_DIR}/bin"           && cp -Rp ./bin/customer/* "${WORK_DIR}/bin"
    mkdir "${WORK_DIR}/docs"          && cp -Rp ./docs/customer/* "${WORK_DIR}/docs"
    mkdir "${WORK_DIR}/docs/drawings" && cp -Rp ./docs/drawings/customer "${WORK_DIR}/docs/drawings"
    mkdir "${WORK_DIR}/images"        && cp -R ./docs/images/customer/* "${WORK_DIR}/images/" \
      && ln -s "${WORK_DIR}/images" "${WORK_DIR}/images/customer"
    mkdir "${WORK_DIR}/latex"         && cp -R ./docs/latex/customer/* "${WORK_DIR}/latex/"
    mkdir "${WORK_DIR}/src"           && cp -Rp ./src/customer/* "${WORK_DIR}/src"

    echo "genrate the TEX from MD with Pandoc"
    pandoc -s -f markdown -t latex "${WORK_DIR}/docs/logging.md" -o "${WORK_DIR}/docs/logging.tex"
    echo "fix the graphics path in tex file" # fix image path in tex file
    sed -i -e "s|includegraphics{docs/images|includegraphics{../images|" "${WORK_DIR}/docs/logging.tex"
    #sed -i -e "s|images/customer/diagram1|images/diagram1|" "${WORK_DIR}/docs/logging.tex" 

    pandoc -s -f markdown -t latex "${WORK_DIR}/docs/customer.md" -o "${WORK_DIR}/docs/customer.tex" \
     && sed -i "s|includegraphics{docs/images|includegraphics{../images|" "${WORK_DIR}/docs/customer.tex"

    # copy the files back
    cp -R "${WORK_DIR}/docs/customer.tex" "${WORK_DIR}/docs/logging.tex" docs/latex/customer 
}

main "$@"
