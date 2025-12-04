#!/bin/bash

# Date: 01/20/2023
# devsecfranklin@duck.com

#set -eu

#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36                                                                                     
#Light Gray   0;37     White         1;37                                                                                     
RED='\033[0;31m'                                                                          
LRED='\033[1;31m'                                                                                                             
LGREEN='\033[1;32m'                                                                                                           
LBLUE='\033[1;34m'                                                                                                            
CYAN='\033[0;36m'                                                                                                             
LPURP='\033[1;35m'                                                                                                            
YELLOW='\033[1;33m'                                                                                                           
NC='\033[0m' # No Color                                                                                                       
                                                                                                                              
BASE_DIR="/var/run/user/$(id -u)/gvfs/mtp:host=SAMSUNG_SAMSUNG_Android_R5CW72QACHT//Internal\ storage"                         
declare -a TARGET_DIRS=( "/home/franklin/Pictures/Phone/Download" "/home/franklin/Pictures/Phone/Pictures" "/home/franklin/Pictures/Phone/DCIM/Camera" "/home/franklin/Pictures/Phone/DCIM/Screenshots" "/home/franklin/Videos/Phone/DCIM/Camera" "/home/franklin/Videos/Phone/DCIM/Videocaptures" "/home/franklin/Videos/Phone/Movies")                                                  
                                                                                                                              
function create_target_dirs() {                                                                                               
  # Create the target directories on local host                                                                               
  for td in ${TARGET_DIRS[@]};                                                                                                
  do                                                                                                                          
    if [ ! -d "${td}" ]; then mkdir -p ${td}; echo -e "${LGREEN}Created directory: ${td}${NC}\n"; fi                          
  done                                                                                                                        
}                                                                                                                             

function copy_music() {
  echo -e "${LGREEN}Copying Music - START${NC}\n"
  # Copy Internal storage/Music to ${HOME}/Music
  eval ls "${BASE_DIR}/Music"
  eval cp "${BASE_DIR}/Music/*" /home/franklin/Music
  echo -e "\n${LGREEN}Copying Music - COMPLETE${NC}\n"
}


function copy_pictures() {
  echo -e "${LGREEN}Copying Pictures - START${NC}\n"

  # copy DCIM/Camera, mix of mp4 and jpg
  eval ls "${BASE_DIR}/DCIM/Camera/*.jpg"
  eval cp "${BASE_DIR}/DCIM/Camera/*.jpg" /home/franklin/Pictures/Phone/DCIM/Camera
  
  # copy DCIM/Screenshots .jpg files
  eval ls "${BASE_DIR}/DCIM/Screenshots/*"
  eval cp "${BASE_DIR}/DCIM/Screenshots/*" /home/franklin/Pictures/Phone/DCIM/Screenshots
  
  # copy /Internal storage/Pictures .jpg .gif and sub folders
  eval ls "${BASE_DIR}/Pictures/*"
  eval cp "${BASE_DIR}/Pictures/*" /home/franklin/Pictures/Phone/Pictures

  # copy Internal storage/Download
  eval ls "${BASE_DIR}/Download/*"
  eval cp "${BASE_DIR}/Download/*" /home/franklin/Pictures/Phone/Download

  # convert file extensions to lower case in /home/franklin/Pictures/Phone
  # change permissions on jpg, png, etc. in /home/franklin/Pictures/Phone
  
  echo -e "\n${LGREEN}Copying Pictures - COMPLETE${NC}\n"
}

function copy_movies() {
  echo -e "${LGREEN}Copying Movies - START${NC}\n"
  
  # copy Internal storage/Movies to ~/Videos/Phone/Movies , this can have subfolders
  eval ls "${BASE_DIR}/Movies"
  eval cp -r "${BASE_DIR}/Movies" /home/franklin/Videos/Phone/Movies

  # copy DCIM/Camera, mix of mp4 and jpg
  eval ls "${BASE_DIR}/DCIM/Camera/*.mp4"
  eval cp "${BASE_DIR}/DCIM/Camera/*.mp4" /home/franklin/Videos/Phone/DCIM/Camera
  
  # copy DCIM/Videocaptures
  eval ls "${BASE_DIR}/DCIM/Videocaptures/"
  eval cp -r "${BASE_DIR}/DCIM/Videocaptures" /home/franklin/Videos/Phone/DCIM/Videocaptures

  echo -e "\n${LGREEN}Copying Movies - COMPLETE${NC}\n"
}


function main() {
  echo -e "${LGREEN}Finding device: ${NC}" ; lsusb | grep Samsung
  echo -e "\n"
  
  # see all the top level folders in phone filesystem
  # eval ls "${BASE_DIR}"
  
  create_target_dirs
  
  copy_music
  copy_pictures
  copy_movies
}

main "$@"
