#!/usr/bin/env bash

# SPDX-FileCopyrightText: ©2026 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT

DEB_PKG=(latexmk texlive-xetex libpcsclite-dev texlive-pictures texlive-latex-extra libssl-dev)
BLUE='\033[1;34m'; GREEN='\033[1;32m'; RED='\033[1;31m'; NC='\033[0m'

log() { echo -e "${BLUE}==>${NC} $1"; }
success() { echo -e "${GREEN}SUCCESS:${NC} $1"; }
error() { echo -e "${RED}ERROR:${NC} $1"; exit 1; }

install_deps() {
    local missing=()
    for pkg in "${DEB_PKG[@]}"; do
        dpkg -s "$pkg" &>/dev/null || missing+=("$pkg")
    done

    if [ ${#missing[@]} -gt 0 ]; then
        log "Installing missing dependencies: ${missing[*]}"
        local runner=""
        [[ $(id -u) -ne 0 ]] && command -v sudo &>/dev/null && runner="sudo"
        
        $runner apt-get update -qq
        $runner apt-get install -y "${missing[@]}" || error "Package installation failed."
    else
        log "All dependencies already present."
    fi
}

main() {
    log "Starting project initialization..."
    install_deps
    log "Generating build scripts..."
    autoreconf -i || error "autoreconf failed. Ensure 'autoconf' and 'automake' are installed."
    log "Configuring project..."
    ./configure || error "Configuration failed."
    [[ ! -f ~/.dircolors ]] && dircolors -p > ~/.dircolors && log "Updated .dircolors"
    log "Go setup"
    go mod init github.com/devsecfranklin/franklin-resume
    go mod tidy
    go get assets_test.go
    success "Ready to build. Now run 'cd resume && make'."
}

main "$@"