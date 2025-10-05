dnl Process this file with autoconf
AC_PREREQ([2.69])
AC_INIT(franklin-resume, 0.4, franklin@dead10c5.org, https://github.com/devsecfranklin/franklin-resume)
AC_CONFIG_MACRO_DIR(config/m4)
AC_CONFIG_AUX_DIR(config)
AM_INIT_AUTOMAKE(foreign)

LT_INIT

AC_CONFIG_COMMANDS([franklin-build],
 [echo "(⊃｡•́‿•̀｡)⊃━⭑･ﾟﾟ･*:༅｡.｡༅:*ﾟ:*:✼✿ Configuring for $mypkgname ☽༓･*˚⁺‧͙"],
 [mypkgname=$PACKAGE_NAME])
AC_CONFIG_FILES([
 Makefile
 docker/Makefile
])

dnl le python
AM_PATH_PYTHON(3.9) # minimum version of Python
PY39="python$PYTHON_VERSION" # define the python interpreter
dnl LDFLAGS="$LDFLAGS -l$PY39"
AC_SUBST(PY39, python$PYTHON_VERSION)

# AC_CANONICAL_HOST is needed to access the 'host_os' variable
AC_CANONICAL_HOST
AC_OUTPUT
