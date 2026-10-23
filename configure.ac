AC_PREREQ([2.71])
AC_INIT([franklin-resume], [3.0], [smoooth.y62wj@passmail.net], [https://github.com/devsecfranklin/franklin-resume])
AC_CONFIG_MACRO_DIR([config/m4])
AC_CONFIG_AUX_DIR([config])
AM_INIT_AUTOMAKE([-Wno-override foreign])

dnl Check for xelatex (required)
AC_CHECK_PROG([HAVE_XELATEX], [xelatex], [found], [not-found])
if test "x$HAVE_XELATEX" = "xnot-found"; then
  AC_MSG_ERROR([xelatex is required but not found on this system. Install texlive-xetex.])
fi

dnl Check for latexmk (required)
AC_CHECK_PROG([HAVE_LATEXMK], [latexmk], [found], [not-found])
if test "x$HAVE_LATEXMK" = "xnot-found"; then
  AC_MSG_ERROR([latexmk is required but not found on this system. Install latexmk.])
fi

dnl Check for chktex (optional, for lint target)
AC_CHECK_PROG([HAVE_CHKTEX], [chktex], [found], [not-found])
AM_CONDITIONAL([HAVE_CHKTEX], [test "x$HAVE_CHKTEX" = "xfound"])

dnl Check for direnv (used by .envrc, optional)
AC_CHECK_PROG([HAVE_DIRENV], [direnv], [found], [not-found])

AC_CONFIG_COMMANDS([franklin-build],
  [echo "(⊃｡•‿•｡)⊃━⭑･ﾟﾟ･*:༅｡.｡༅:*ﾟ:*:✼✿ Configuring for $mypkgname ☽༓･*˚⁺‧"],
  [mypkgname=$PACKAGE_NAME])

AC_CONFIG_FILES([
  Makefile
  resume/Makefile
  biography/Makefile
])

AC_OUTPUT
