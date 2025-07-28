#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2021-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: MIT


# Follow the guide at https://devcenter.heroku.com/articles/getting-started-with-go
# There's also a hello world sample app at https://github.com/heroku/go-getting-started

heroku update # update the Heroku CLI
heroku ps -a franklin-resume
heroku buildpacks -a franklin-resume # https://elements.heroku.com/buildpacks/heroku/heroku-buildpack-go

# run a web dyno for this app
# heroku ps:scale web=1 -a franklin-resume

#heroku logs --tail -a franklin-resume
heroku logs -a franklin-resume