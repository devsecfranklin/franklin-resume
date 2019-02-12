#!/bin/bash - 
#=================================================
#
#          FILE: env_setup.sh
# 
#         USAGE: ./env_setup.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 02/04/2019 11:16
#      REVISION:  ---
#==================================================
#set -o nounset   # Treat unset variables as an error

if [ ! $(command -v mdl) ]; then
  echo "gem: --no-document" >> ~/.gemrc
  gem install mdl
fi
