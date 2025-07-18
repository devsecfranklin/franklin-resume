dnl Process this file with autoconf
AC_PREREQ([2.69])
AC_INIT([lab-franklin], [0.2], [franklin@bitsmasher.net], [https://github.com/devsecfranklin/lab-franklin])
AC_CONFIG_MACRO_DIR([config/m4])
AC_CONFIG_AUX_DIR([config])
AM_INIT_AUTOMAKE
LT_INIT # Initialize Libtool for shared library support

AC_ARG_ENABLE([debug],
[  --enable-debug    Turn on debugging],
[case "${enableval}" in
  yes) debug=true ;;
  no)  debug=false ;;
  *) AC_MSG_ERROR([bad value ${enableval} for --enable-debug]) ;;
esac],[debug=false])
AM_CONDITIONAL([DEBUG], [test x$debug = xtrue])

LT_INIT

AC_CONFIG_COMMANDS([franklin-build],
 [echo "(⊃｡•́‿•̀｡)⊃━⭑･ﾟﾟ･*:༅｡.｡༅:*ﾟ:*:✼✿ Configuring for $mypkgname ☽༓･*˚⁺‧͙"],
 [mypkgname=$PACKAGE_NAME])

AC_CONFIG_FILES([
  Makefile
  ansible/Makefile
  assembly/Makefile
  assembly/src/Makefile
  container/Makefile
  container/kerberos-containers/kdc-server/Makefile
  container/kerberos-containers/kdc-ssh-server/Makefile
  container/kerberos-containers/ssh-container/Makefile
  test/test_cluster/Makefile
  test/test_gui/Makefile
])

dnl Checks for programs.
AC_PROG_CXX

AM_PATH_PYTHON(3.9) # minimum version of Python
PY39="python$PYTHON_VERSION" # define the python interpreter
dnl LDFLAGS="$LDFLAGS -l$PY39"
AC_SUBST(PY39, python$PYTHON_VERSION)

AC_CHECK_PROG(HAVE_NODE, [node], [found], [not-found])
test -z "$HAVE_NODE"     && AC_MSG_ERROR([Could not find node.js. Please make sure you have it installed])

AC_CHECK_PROG( [HAS_CURL], [curl], [found], [not-found])
test -z "$HAS_CURL"     && AC_MSG_ERROR([Could not find curl. Please make sure you have it installed.])

dnl Check for mandatory programs with more robust error messages.
dnl AC_CHECK_PROG([HAVE_XMLLINT], [xmllint], [xmllint])
dnl AS_IF([test -z "$HAVE_NODE"], [AC_MSG_ERROR([node.js not found. Please install node.js to proceed.])])

AC_CHECK_PROG( [HAS_PODMAN], [podman], [found], [not-found])
test -z "$HAS_PODMAN"     && AC_MSG_ERROR([Could not find podman installed. This is OK for testing.])

AC_CHECK_PROG( [HAS_ANSIBLE], [ansible], [found], [not-found])
test -z "$HAS_ANSIBLE"     && AC_MSG_ERROR([Could not find ansible installed.])

AC_CHECK_PROG( [HAS_GPG], [gpg], [found], [not-found])
test -z "$HAS_GPG" && AC_MSG_ERROR([Could not find gpg installed.])

dnl AC_CHECK_PROG([HAS_XMLLINT], [xmllint], [xmllint])
dnl AS_IF([test -z "$HAS_XMLLINT"], [AC_MSG_ERROR([xmllint not found. Please install libxml2-utils or equivalent.])])

dnl AC_CHECK_PROG([HAVE_AS], [as], [as])
dnl AS_IF([test -z "$HAVE_AS"], [AC_MSG_ERROR([Assembler 'as' not found. Please ensure your build essential tools are installed.])])

dnl AC_CHECK_PROG([HAVE_NASM], [nasm], [nasm])
dnl AS_IF([test -z "$HAVE_NASM"], [AC_MSG_ERROR([NASM assembler not found. Please install nasm.])])

dnl AC_CHECK_PROG([HAVE_YASM], [yasm], [yasm])
dnl AS_IF([test -z "$HAVE_YASM"], [AC_MSG_ERROR([YASM assembler not found. Please install yasm.])])

AC_SUBST([GITVERSION])
AC_SUBST([GITTAG])
AC_SUBST([GITBRANCH])

if test -e $srcdir/.git
then
AC_CHECK_PROG([HAS_GIT], [git], [found], [not-found])
else
HAS_GIT=no-repository
fi

if test $HAS_GIT = found
then
    GITVERSION="git --git-dir \$(srcdir)/.git rev-parse --short HEAD"
    GITTAG="git --git-dir \$(srcdir)/.git describe --all --always --dirty"
    GITBRANCH="git --git-dir \$(srcdir)/.git name-rev --name-only HEAD"
else
    GITVERSION=""
    GITTAG=""
    GITBRANCH=""
fi

AM_CONDITIONAL(HAS_DOCKER, [test "docker" = "found"])

dnl       ****************** Multi target builds *************************
dnl Note that if `host' and `target' are the same string, you can assume
dnl a native configuration. If they are different, you can assume a cross
dnl configuration.

AC_CANONICAL_HOST # AC_CANONICAL_HOST is needed to access the 'host_os' variable
echo "Attempting to configure a build for host: $host"
AC_SUBST(UNAME_P,$(uname -p))
AC_SUBST(UNAME_S,$(uname -s))

AC_SUBST(WORKDIR, $ac_pwd)
AC_SUBST(BUILDDIR, $ac_pwd/_build/$host)
AC_SUBST(MYSRCDIR, $ac_pwd/_build/$host/src)
AC_SUBST(MYLIBDIR, $ac_pwd/_build/$host/lib)
AC_MSG_NOTICE([build directory: $ac_pwd/_build/$host])

if test $UNAME_S = "Linux"
then
  echo "This is a LINUX host: $host"
  mkdir -p "$ac_pwd/_build/$host"
  AC_SUBST(MYSRCDIR, $ac_pwd/_build/$host/src)

fi

if test $UNAME_S = "OpenBSD"
then
  echo "This is an OpenBSD host: $host"
  mkdir -p "$ac_pwd/_build/$host"
fi

dnl the script will prob always detect BASH if you run it from bootstrap.sh
AC_SUBST([MYSHELL], $(echo $SHELL | rev | cut -f1 -d"/" | rev ) )
CONFIG_SHELL=$SHELL
if test "$MYSHELL" = "bash"; then
  echo "Using BASH shell"
  AC_SUBST([ACTIVATE], activate)
elif test "$MYSHELL" = "bash"; then
  # the script will prob always detect BASH if you run it from bootstrap.sh
  echo "Using FISH shell"
AC_SUBST([ACTIVATE], activate.fish)
fi

# Determine a C compiler to use. If CC is not already set in the environment,
# check for gcc and cc, then for other C compilers. Set output variable CC to the name of the compiler found. 
AC_PROG_CC([gcc cl cc])
dnl Check for toolchain and install components
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_RANLIB

dnl Check that our compiler can do const and inline
AC_C_CONST
AC_C_INLINE

dnl Check for standard headers:
m4_warn([obsolete],
[The preprocessor macro `STDC_HEADERS' is obsolete.
  Except in unusual embedded environments, you can safely include all
  ISO C90 headers unconditionally.])dnl
# Autoupdate added the next two lines to ensure that your configure
# script's behavior did not change.  They are probably safe to remove.
AC_CHECK_INCLUDES_DEFAULT dnl  check for the presence of a default set of standard C header files. These headers are commonly assumed to exist on most modern systems, but Autoconf includes this check for maximum portability
AC_PROG_EGREP

AC_HEADER_DIRENT
AC_CHECK_HEADERS([stdlib.h stdio.h libintl.h locale.h arpa/inet.h netdb.h strings.h sys/socket.h unistd.h])
AC_CONFIG_HEADERS([config.h])
AC_CHECK_HEADER_STDBOOL # Checks for typedefs, structures, and compiler characteristics.


dnl Check for libraries:
# AC_CHECK_LIB(ssl, SSL_free)
AC_CHECK_FUNCS([setlocale strtol socket]) # Checks for library functions.


#AC_ARG_WITH([gtk], AS_HELP_STRING([--with-gtk], [Build with the GTK+ interface]))
#if test "x$with_gtk" = "xyes"; then
#   PKG_CHECK_MODULES([GTK], [gtk+-2.0])
#fi
# PKG_CHECK_MODULES([GLIB], [glib-2.0])

AC_OUTPUT
