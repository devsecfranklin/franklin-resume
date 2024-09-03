# use UTF-8 EVERYWHere
export LANG=en_US.UTF-8

# specify location of kshrc
export ENV=$HOME/.kshrc

# load Xresources file
xrdb -merge $HOME/.Xresources

# set your background color
# xsetroot -solid dimgray
xsetroot -solid '#4C566A'

# xidle will lock your display after a period of inactivity
# xidle &

# sadly, xclock has a bug where the font selection is ignored when UTF-8
# is enabled, so we unset LANG here.
LANG= xclock -strftime "%a %e %b %Y %H:%M" &

# disable system beep
xset b off

# polybar -c ~/.config/polybar/mockup top &

# Run xterm
xterm &

# Fix scaling of some X/QT programs
xrandr --dpi 96

# Automatically lock X
xidle -delay 5 -sw -timeout 300 -program "/usr/X11R6/bin/xlock -mode qix" &

# Run our window manager.
# Can later be replaced with `exec startxfce4` if desired.
# exec runs it in the foreground - X will exit when the cwm proc exits.
# start cwm!
exec cwm
