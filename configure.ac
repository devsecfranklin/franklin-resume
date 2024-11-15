dnl Process this file with autoconf
AC_PREREQ([2.69])
AC_INIT(lab-franklin, 0.3, franklin@dead10c5.org, https://github.com/devsecfranklin/lab-franklin)
AC_CONFIG_MACRO_DIR(config/m4)
AC_CONFIG_AUX_DIR(config)
AM_INIT_AUTOMAKE(foreign)
AC_MSG_NOTICE([build directory: $ac_pwd])
AC_SUBST(WORKDIR, $ac_pwd)

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

# AC_CANONICAL_HOST is needed to access the 'host_os' variable
AC_CANONICAL_HOST

build_linux=no
build_windows=no
build_mac=no

# Detect the target system
case "${host_os}" in
    linux*)
        build_linux=yes
        ;;
    cygwin*|mingw*)
        build_windows=yes
        ;;
    darwin*)
        build_mac=yes
        ;;
    *)
        AC_MSG_ERROR(["OS $host_os is not supported"])
        ;;
esac

# Pass the conditionals to automake
AM_CONDITIONAL([LINUX], [test "$build_linux" = "yes"])
AM_CONDITIONAL([WINDOWS], [test "$build_windows" = "yes"])
AM_CONDITIONAL([OSX], [test "$build_mac" = "yes"])
AM_CONDITIONAL(HAS_DOCKER, [test "docker" = "found"])

AC_OUTPUT
