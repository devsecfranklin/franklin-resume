#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# update the Heroku CLI
heroku update

heroku ps -a franklin-resume

heroku buildpacks -a franklin-resume

# run a web dyno for this app
# heroku ps:scale web=1 -a franklin-resume

#heroku logs --tail -a franklin-resume
heroku logs -a franklin-resume

