dnl Process this file with autoconf
AC_PREREQ([2.69])
AC_INIT(customer, 0.2, fdiaz@paloaltonetworks.com, https://github.com/devsecfranklin/customer)
AC_CONFIG_MACRO_DIR(config/m4)
AC_CONFIG_AUX_DIR(config)
AC_MSG_NOTICE([build directory: $ac_pwd])
AC_SUBST(WORKDIR, $ac_pwd)
AM_INIT_AUTOMAKE(foreign)

LT_INIT

dnl Checks for programs.
AC_PROG_CXX

AM_PATH_PYTHON(3.9) # minimum version of Python
PY39="python$PYTHON_VERSION" # define the python interpreter
dnl LDFLAGS="$LDFLAGS -l$PY39"
AC_SUBST(PY39, python$PYTHON_VERSION)

AC_CHECK_PROG( [HAS_CURL], [curl], [found], [not-found])
test -z "$HAS_CURL"     && AC_MSG_ERROR([Could not find curl. Please make sure you have it installed.])

AC_CHECK_PROG( [HAS_GPG], [gpg], [found], [not-found])
AC_CHECK_PROG( [HAS_XMLLINT], [xmllint], [found], [not-found])

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

AC_CONFIG_COMMANDS([franklin-build],
 [echo "(⊃｡•‿•｡)⊃━⭑･ﾟﾟ･*:༅｡.｡༅:*ﾟ:*:✼✿ Configuring for $mypkgname ☽༓･*˚⁺‧"],
 [mypkgname=$PACKAGE_NAME])
AC_CONFIG_FILES([
 Makefile
 docker/Makefile
])

AC_OUTPUT
