#!/usr/bin/env bash
# SPDX-FileCopyrightText: ©2026 franklin <smoooth.y62wj@passmail.net>
# SPDX-License-Identifier: MIT

# --- Configuration ---
DEB_PKG=(latexmk texlive-xetex libpcsclite-dev texlive-pictures texlive-latex-extra libssl-dev)
BLUE='\033[1;34m'; GREEN='\033[1;32m'; RED='\033[1;31m'; NC='\033[0m'

log() { echo -e "${BLUE}==>${NC} $1"; }
success() { echo -e "${GREEN}SUCCESS:${NC} $1"; }
error() { echo -e "${RED}ERROR:${NC} $1"; exit 1; }

# --- Dependency Management ---
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

# --- Main Build Process ---
main() {
    log "Starting project initialization..."

    # 1. Install system dependencies first
    install_deps

    # 2. Run Autotools to generate 'configure' and 'Makefile.in' 
    log "Generating build scripts..."
    autoreconf -i || error "autoreconf failed. Ensure 'autoconf' and 'automake' are installed."

    # 3. Final configuration 
    log "Configuring project..."
    ./configure || error "Configuration failed."

    # Optional: ensure dircolors exists for your terminal preference
    [[ ! -f ~/.dircolors ]] && dircolors -p > ~/.dircolors && log "Updated .dircolors"

    success "Ready to build. Now run 'cd resume && make'."
}

main "$@"