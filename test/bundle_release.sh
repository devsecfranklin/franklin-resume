#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023-2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT


# the `-r` flag does subdirs
# zip -r scripts.zip <directory name>

zip release_tool_v0.2.0.zip ../bin/stage_release.sh \
  ../bin/fw_health.sh \
  ../bin/check_certs.sh \
  ../docs/stage_release.md \
  ../docs/stage_release.pdf \
  ../data/ip_address.txt
