#!/bin/sh

# Change Wallpaper, dmenu version, by Ian LeCorbeau

ln -sf "$(find ~/Pictures -type f | sort -n | xargs -r0 | dmenu -l 15 -p chwall)" ~/Pictures/20231108_100325.jpg && xwallpaper --stretch ~/Pictures/20231108_100325.jpg
