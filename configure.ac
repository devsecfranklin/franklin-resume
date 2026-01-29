AC_PREREQ([2.71])
AC_INIT([stash-house], [3.0], [smoooth.y62wj@passmail.net], [https://github.com/devsecfranklin/franklin-resume])
AC_CONFIG_MACRO_DIR([config/m4])
AC_CONFIG_AUX_DIR([config])
AM_INIT_AUTOMAKE
AC_CONFIG_COMMANDS([franklin-build],
 [echo "(⊃｡•‿•｡)⊃━⭑･ﾟﾟ･*:༅｡.｡༅:*ﾟ:*:✼✿ Configuring for $mypkgname ☽༓･*˚⁺‧"],
 [mypkgname=$PACKAGE_NAME])
AC_CONFIG_FILES([
  resume/Makefile
])
AC_PROG_CXX
AM_PATH_PYTHON(3.9) # minimum version of Python
PY39="python$PYTHON_VERSION" # define the python interpreter
dnl LDFLAGS="$LDFLAGS -l$PY39"
AC_SUBST(PY39, python$PYTHON_VERSION)
AC_CHECK_PROG(HAVE_GCLOUD, [direnv], [found], [not-found])
AC_OUTPUT