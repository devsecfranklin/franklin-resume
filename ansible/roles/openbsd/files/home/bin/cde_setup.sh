doas pkg_add git ksh93
doas pkg_add motif gmake libtool bison opensp lmdb

if [ ! -d "/tmp/cdesktopenv" ]; then
  git clone git://git.code.sf.net/p/cdesktopenv/code /tmp/cdesktopenv-code
fi

echo "Autogen..."
AUTOCONF_VERSION=2.71 AUTOMAKE_VERSION=1.16 LIBRARY_PATH="/usr/local/lib" /tmp/cdesktopenv-code/cde/autogen.sh

echo "Configure..."
AUTOCONF_VERSION=2.71 AUTOMAKE_VERSION=1.16 LIBRARY_PATH="/usr/local/lib" \
--with-tcl=/usr/local/lib/tcl/tcl8.6 MAKE="gmake" /tmp/cdesktopenv-code/cde/configure

cd /tmp/cdesktopenv-code/cde && gmake

cd /tmp/cdesktopenv-code/cde && doas gmake install
