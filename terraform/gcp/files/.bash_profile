# SPDX-FileCopyrightText: © 2022-2024 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later
alias ls="ls --color"
export PAN_IP="192.168.0.3"
export PASS="123QWEasd"
export PATH=$PATH:/usr/local/go/bin:/mnt/development/workspace/lab-franklin/_test/bin:$HOME/go/bin

eval "$(ssh-agent -s)"
eval "$(direnv hook bash)"
