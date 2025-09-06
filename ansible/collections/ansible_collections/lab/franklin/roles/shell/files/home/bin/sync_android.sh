#!/usr/bin/env bash

# SPDX-FileCopyrightText: ©2021-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: MIT

# v0.1 02/25/2022 Maintainer script
# v0.2 06/24/2025 A robust tool to back up media from an MTP device (Android phone)
#        to a local machine, with optional date-based organization.

# --- Script Configuration ---
# Exit immediately if a command exits with a non-zero status.
#set -e
# Treat unset variables as an error.
#set -u
# The return value of a pipeline is the status of the last command to exit
# with a non-zero status, or zero if no command failed.
#set -o pipefail

# --- Color and Logging Functions ---
if tput setaf 1 &> /dev/null; then
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    CYAN=$(tput setaf 6)
    BOLD=$(tput bold)
    NC=$(tput sgr0) # No Color
else
    RED=""
    GREEN=""
    YELLOW=""
    CYAN=""
    BOLD=""
    NC=""
fi

log_info() { echo -e "${CYAN}==>${NC} ${BOLD}$1${NC}"; }
log_success() { echo -e "${GREEN}==>${NC} ${BOLD}$1${NC}"; }
log_warn() { >&2 echo -e "${YELLOW}WARN:${NC} $1"; }
log_error() { >&2 echo -e "${RED}ERROR:${NC} $1"; }

# --- Configuration (Source and Destination Mappings) ---
# Base directory for all local backups. Uses $HOME to be portable.
readonly DEST_BASE_DIR="${HOME}"

# Using associative arrays to map source folders on the phone to destination folders on the PC.
# This makes the script easily configurable and removes redundant code.
declare -rA MUSIC_MAP=(
    ["Music"]="${DEST_BASE_DIR}/Music"
)
declare -rA PICTURE_MAP=(
    ["Download"]="${DEST_BASE_DIR}/Pictures/Phone/Download"
    ["Pictures"]="${DEST_BASE_DIR}/Pictures/Phone/Pictures"
    ["DCIM/Screenshots"]="${DEST_BASE_DIR}/Pictures/Phone/DCIM/Screenshots"
    ["DCIM/Camera"]="${DEST_BASE_DIR}/Pictures/Phone/DCIM/Camera" # Special handling for photos
)
declare -rA MOVIE_MAP=(
    ["Movies"]="${DEST_BASE_DIR}/Videos/Phone/Movies"
    ["DCIM/Videocaptures"]="${DEST_BASE_DIR}/Videos/Phone/DCIM/Videocaptures"
    ["DCIM/Camera"]="${DEST_BASE_DIR}/Videos/Phone/DCIM/Camera" # Special handling for videos
)

# --- Prerequisite and Setup Functions ---

usage() {
    cat <<EOF
Usage: $(basename "$0") [options]

Backs up media from a connected MTP device (Android phone).

Options:
  --dry-run        Show what would be copied without actually copying anything.
  --no-organize    Do not organize photos by date (YYYY/MM). Just copy them.
  -f, --force      Skip the confirmation prompt and run the backup immediately.
  -h, --help       Display this help message.
EOF
}

check_dependencies() {
    local missing=0
    for cmd in rsync exiftool; do
        if ! command -v "$cmd" &> /dev/null; then
            log_error "'$cmd' command is required but not found. Please install it."
            missing=1
        fi
    done
    (( missing )) && exit 1
}

find_mtp_mount() {
    local gvfs_path="/var/run/user/$(id -u)/gvfs"
    if [[ ! -d "$gvfs_path" ]]; then
        log_error "GVFS mount directory not found: '$gvfs_path'"
        log_error "Is your phone connected and mounted via MTP?"
        exit 1
    fi

    # Find the MTP mount point dynamically.
    local mounts
    mounts=$(find "$gvfs_path" -maxdepth 1 -type d -name 'mtp:host=*')
    if [[ -z "$mounts" ]]; then
        log_error "No MTP device found in '$gvfs_path'."
        exit 1
    fi
    # If multiple devices, this will pick the first. Could be improved to ask user if needed.
    echo "${mounts%%$'\n'}/Internal storage"
}

create_target_dirs() {
    log_info "Ensuring destination directories exist..."
    # Combine all destination paths, sort them uniquely, and create them.
    for dir in "${MUSIC_MAP[@]}" "${PICTURE_MAP[@]}" "${MOVIE_MAP[@]}"; do
        mkdir -p "$dir"
    done
}

# --- Core Logic Functions ---

# A generic function to sync files using rsync.
sync_files() {
    local source_dir="$1"
    local dest_dir="$2"
    local rsync_opts=("-av" "--info=progress2" "--no-perms") # -a archive, -v verbose

    # Add dry-run option if enabled
    [[ "$DRY_RUN" == true ]] && rsync_opts+=("--dry-run")

    if [[ -d "$source_dir" ]]; then
        log_info "Syncing '${source_dir##*/}' to '${dest_dir##*/}'..."
        rsync "${rsync_opts[@]}" "$source_dir/" "$dest_dir/"
    else
        log_warn "Source directory not found on device, skipping: $source_dir"
    fi
}

# Organize photos from the camera roll into YYYY/MM folders based on EXIF data.
function organize_photos_by_date() {
    local camera_dir="${PICTURE_MAP['DCIM/Camera']}"
    log_info "Organizing photos in '$camera_dir' by date..."

    # Find all JPG files in the base camera directory.
    find "$camera_dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) | while read -r file; do
        # Get date in YYYY:MM:DD format. Fallback to file modification time if EXIF fails.
        local date_str
        date_str=$(exiftool -q -p '$CreateDate' -d '%Y:%m' "$file" 2>/dev/null || stat -c '%y' "$file" | cut -d' ' -f1 | sed 's/-/:/')
        
        if [[ -z "$date_str" ]]; then
            log_warn "Could not determine date for '$file'. Skipping organization."
            continue
        fi

        local year="${date_str%%:*}"
        local month="${date_str#*:}"
        month="${month%%:*}"
        
        local target_dir="$camera_dir/$year/$month"
        mkdir -p "$target_dir"

        log_info "  -> Moving '$(basename "$file")' to '$year/$month/'"
        [[ "$DRY_RUN" == false ]] && mv "$file" "$target_dir/"
    done
    log_success "Photo organization complete."
}

# --- Main Execution ---
function main() {
    # Default options
    local DRY_RUN=false
    local ORGANIZE=true
    local FORCE=false

    # Parse command-line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run) DRY_RUN=true; shift ;;
            --no-organize) ORGANIZE=false; shift ;;
            -f|--force) FORCE=true; shift ;;
            -h|--help) usage; exit 0 ;;
            *) log_error "Unknown option: $1"; usage; exit 1 ;;
        esac
    done

    check_dependencies
    
    # Dynamically find the MTP mount point.
    local source_base_dir
    source_base_dir=$(find_mtp_mount)
    log_success "Found MTP device at: $source_base_dir"
    
    create_target_dirs

    if [[ "$FORCE" == false && "$DRY_RUN" == false ]]; then
        read -p "${YELLOW}Ready to start backup. Are you sure? (y/n) ${NC}" -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Backup cancelled by user."
            exit 1
        fi
    fi

    # --- Execute Sync ---
    log_info "--- Starting Music Sync ---"
    for src in "${!MUSIC_MAP[@]}"; do
        sync_files "$source_base_dir/$src" "${MUSIC_MAP[$src]}"
    done
    
    log_info "--- Starting Picture & Movie Sync ---"
    # Sync pictures and videos, handling shared Camera directory correctly
    for src in "${!PICTURE_MAP[@]}"; do
        # Sync JPGs for pictures
        sync_files "$source_base_dir/$src" "${PICTURE_MAP[$src]}"
    done
    for src in "${!MOVIE_MAP[@]}"; do
        # Sync MP4s for movies
        sync_files "$source_base_dir/$src" "${MOVIE_MAP[$src]}"
    done

    if [[ "$ORGANIZE" == true ]]; then
        organize_photos_by_date
    fi

    log_success "Backup process complete!"
}

main "$@"
