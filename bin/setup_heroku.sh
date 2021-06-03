#!/bin/bash - 
#===============================================================================
#
#          FILE: setup_heroku.sh
# 
#         USAGE: ./setup_heroku.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 02/12/2019 10:41
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

heroku buildpacks:add https://github.com/illustrativemathematics/pandoc-buildpack.git -a franklin-resume
