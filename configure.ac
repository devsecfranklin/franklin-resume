dnl Process this file with autoconf
AC_PREREQ([2.69])
AC_INIT(lab-franklin, 0.3, franklin@bitsmasher.net, https://github.com/devsecfranklin/lab-franklin)
AC_CONFIG_MACRO_DIR(config/m4)
AC_CONFIG_AUX_DIR(config)
AM_INIT_AUTOMAKE(foreign)

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
  src/cluster_test/Makefile
	src/nodebot/Makefile
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

AC_CHECK_PROG( [HAS_PODMAN], [podman], [found], [not-found])
test -z "$HAS_PODMAN"     && AC_MSG_ERROR([Could not find podman installed. This is OK for testing.])

AC_CHECK_PROG( [HAS_ANSIBLE], [ansible], [found], [not-found])
test -z "$HAS_ANSIBLE"     && AC_MSG_ERROR([Could not find ansible installed.])

AC_CHECK_PROG( [HAS_GPG], [gpg], [found], [not-found])
test -z "$HAS_GPG" && AC_MSG_ERROR([Could not find gpg installed.])

AC_CHECK_PROG( [HAS_XMLLINT], [xmllint], [found], [not-found])
test -z "$HAS_XMLLINT" && AC_MSG_ERROR([Could not find xmllint installed.])

AC_CHECK_PROG(HAVE_AS, [as], [found], [not-found])
test -z "$HAVE_AS"     && AC_MSG_ERROR([Could not find as. Please make sure you have it installed])

AC_CHECK_PROG(HAVE_NASM, [nasm], [found], [not-found])
test -z "$HAVE_NASM"     && AC_MSG_ERROR([Could not find nasm. Please make sure you have it installed])

AC_CHECK_PROG(HAVE_YASM, [yasm], [found], [not-found])
test -z "$HAVE_YASM"     && AC_MSG_ERROR([Could not find yasm. Please make sure you have it installed])

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

AC_SUBST([MY_SHELL],[$( echo $SHELL | cut -f1- -d"/" )])
echo "Shell: $MY_SHELL"

AC_OUTPUT
