# $OpenBSD: dot.profile,v 1.8 2022/08/10 07:40:37 tb Exp $
#
# sh/ksh initialization

PATH=$HOME/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/X11R6/bin:/usr/local/bin:/usr/local/sbin:/usr/games:/usr/local/heimdal/bin
export PATH
: ${HOME='/root'}
export HOME
umask 022

case "$-" in
*i*)    # interactive shell
        if [ -x /usr/bin/tset ]; then
                if [ X"$XTERM_VERSION" = X"" ]; then
                        eval `/usr/bin/tset -sQ '-munknown:?vt220' $TERM`
                else
                        eval `/usr/bin/tset -IsQ '-munknown:?vt220' $TERM`
                fi
        fi
        ;;
esac


#  install package openbsd-backgrounds
#  then uncomment:
#
if test -x /usr/local/bin/openbsd-wallpaper
then
  /usr/local/bin/openbsd-wallpaper
fi

neofetch
alias ls='colorls -G'

export ENV=$HOME/.kshrc
