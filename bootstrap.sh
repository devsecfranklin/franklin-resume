#!/usr/bin/env bash

# SPDX-FileCopyrightText: ©2026 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT

set -euo pipefail

DEB_PKG=(
    inkscape
    latexmk
    fonts-roboto
    texlive-fonts-extra
    texlive-xetex
    libpcsclite-dev
    texlive-pictures
    texlive-latex-extra
    libssl-dev
    fonts-montserrat
    texlive-fonts-recommended
)

BLUE='\033[1;34m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; RED='\033[1;31m'; NC='\033[0m'

log() { echo -e "${BLUE}==>${NC} $1"; }
warn() { echo -e "${YELLOW}WARN:${NC} $1"; }
success() { echo -e "${GREEN}SUCCESS:${NC} $1"; }
error() { echo -e "${RED}ERROR:${NC} $1" >&2; exit 1; }

install_deps() {
    if ! command -v dpkg &>/dev/null; then
        warn "dpkg not found; skipping Debian/Ubuntu package verification."
        return 0
    fi

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
        log "Updating font cache after package installation..."
        fc-cache -f || true
    else
        log "All dependencies already present."
    fi
}

setup_go() {
    local go_bin
    if command -v go &>/dev/null; then
        go_bin="$(command -v go)"
    elif [[ -x "/usr/local/go/bin/go" ]]; then
        go_bin="/usr/local/go/bin/go"
    else
        warn "Go binary not found; skipping Go module setup."
        return 0
    fi

    log "Go setup using $go_bin"
    if [[ ! -f "go.mod" ]]; then
        "$go_bin" mod init github.com/devsecfranklin/franklin-resume
    fi
    "$go_bin" mod tidy
}

main() {
    log "Starting project initialization..."
    install_deps
    log "Generating build scripts..."
    mkdir -p aclocal config/m4
    autoreconf -i || error "autoreconf failed. Ensure 'autoconf' and 'automake' are installed."
    log "Configuring project..."
    ./configure || error "Configuration failed."
    setup_go
    success "Ready to build. Now run 'cd resume && make'."
}

main "$@"
