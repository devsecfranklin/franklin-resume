#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2021-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: MIT

# A helper script to manage and run Civilization II under Wine.

# ChangeLog:
#
# v0.1 02/25/2022 Maintainer script
# v0.2 06/25/2025 Used goog ai studio to make improvements

# --- Script Configuration ---
# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error.
set -u
# The return value of a pipeline is the status of the last command to exit
# with a non-zero status, or zero if no command failed.
set -o pipefail

# --- Wine and Game Configuration ---
# Use a dedicated WINEPREFIX for the game to avoid conflicts with other apps.
# This can be overridden by setting the WINEPREFIX environment variable before running the script.
# Example: WINEPREFIX=/path/to/my/prefix ./run_civ2.sh run
WINEPREFIX="${WINEPREFIX:-$HOME/.wine_civ2}"

# Civilization II is a 32-bit application.
#readonly WINEARCH="win32"
WINEARCH="win32"

# Path to the game executable RELATIVE to the WINEPREFIX.
# Using a variable makes it easy to change if needed.
readonly GAME_PATH_IN_PREFIX="drive_c/Program Files/MPS/CIV2/CIV2.EXE"
readonly GAME_EXE_FULL_PATH="${WINEPREFIX}/${GAME_PATH_IN_PREFIX}"

# Suppress most of Wine's debug chatter for a cleaner experience.
export WINEDEBUG="-all"

# --- Functions ---

# Displays help and usage information.
function usage() {
  cat <<EOF
Usage: $(basename "$0") <command>

A helper script to manage and run Civilization II with Wine.

Commands:
  run       (Default) Runs the game.
  config    Opens 'winecfg' to configure the Wine prefix.
  init      Initializes a new, clean 32-bit Wine prefix for the game.
  help      Displays this help message.

Environment Variables:
  WINEPREFIX  Set this to use a different Wine prefix location.
              Default: "$HOME/.wine_civ2"
EOF
}

# Checks for required dependencies.
function check_dependencies() {
  if ! command -v wine &> /dev/null; then
    echo "Error: 'wine' command not found."
    echo "Please install Wine to continue."
    exit 1
  fi
}

# Initializes a new 32-bit Wine prefix for the game.
function init_prefix() {
  if [ -d "$WINEPREFIX" ]; then
    echo "Error: Wine prefix already exists at '$WINEPREFIX'."
    echo "Please remove it first if you want to re-initialize."
    exit 1
  fi

  echo "==> Creating new 32-bit Wine prefix at '$WINEPREFIX'..."
  # Set WINEARCH and WINEPREFIX for the wineboot command to create the prefix correctly.
  WINEARCH="$WINEARCH" WINEPREFIX="$WINEPREFIX" wineboot -u
  echo "==> Wine prefix created successfully."
  echo "Now, please install Civilization II into '$WINEPREFIX'."
  echo "You can run your installer with:"
  echo "WINEPREFIX=\"$WINEPREFIX\" wine /path/to/your/setup.exe"
}

# Runs the Wine configuration utility.
function run_config() {
  echo "==> Opening winecfg for '$WINEPREFIX'..."
  # The script's environment variables ensure winecfg targets the correct prefix.
  WINEARCH="$WINEARCH" WINEPREFIX="$WINEPREFIX" wine winecfg
}

# Runs the main game executable.
function run_game() {
  # Check if the prefix exists.
  if [ ! -d "$WINEPREFIX" ]; then
    echo "Error: Wine prefix not found at '$WINEPREFIX'."
    echo "Did you run the 'init' command first?"
    exit 1
  fi

  # Check if the game executable exists before trying to run it.
  if [ ! -f "$GAME_EXE_FULL_PATH" ]; then
    echo "Error: Game executable not found at '$GAME_EXE_FULL_PATH'."
    echo "Please make sure Civilization II is installed correctly in the prefix."
    exit 1
  fi

  echo "==> Starting Civilization II..."
  # Navigate to the game's directory before running to ensure it finds its assets.
  cd "$(dirname "$GAME_EXE_FULL_PATH")"
  WINEARCH="$WINEARCH" WINEPREFIX="$WINEPREFIX" wine "$(basename "$GAME_EXE_FULL_PATH")"
}


# --- Main Logic ---

# Check dependencies first.
check_dependencies

# Use the first command-line argument to decide what to do.
# If no argument is given, default to "run".
COMMAND="${1:-run}"

case "$COMMAND" in
  run)
    run_game
    ;;
  config)
    run_config
    ;;
  init)
    init_prefix
    ;;
  help|--help|-h)
    usage
    ;;
  *)
    echo "Error: Unknown command '$COMMAND'." >&2
    usage
    exit 1
    ;;
esac
