#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.71])
AC_INIT([gui-test],[0.1],[franklin@bitsmasher.net])
AC_CONFIG_SRCDIR([src])
AC_CONFIG_HEADERS([config.h])

# Checks for programs.
AC_PROG_CC
AC_PROG_INSTALL

AC_ARG_WITH([gtk], AS_HELP_STRING([--with-gtk], [Build with the GTK+ interface]))

if test "x$with_gtk" = "xyes"; then
   PKG_CHECK_MODULES([GTK], [gtk+-2.0])
fi

PKG_CHECK_MODULES([GLIB], [glib-2.0])

# Checks for header files.
AC_CHECK_HEADERS([arpa/inet.h netdb.h strings.h sys/socket.h unistd.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_CHECK_HEADER_STDBOOL

# Checks for library functions.
AC_CHECK_FUNCS([socket])

AC_CONFIG_FILES([Makefile])

echo "Attempting to configure a build for host: $host"
AC_SUBST(UNAME_P,$(uname -p))
AC_SUBST(UNAME_S,$(uname -s))

AC_SUBST(WORKDIR, $ac_pwd)
AC_SUBST(BUILDDIR, $ac_pwd/build/$host)
AC_SUBST(MYSRCDIR, $ac_pwd/build/$host/src)
AC_SUBST(MYLIBDIR, $ac_pwd/build/$host/lib)
AC_MSG_NOTICE([build directory: $ac_pwd/build/$host])

if test $UNAME_S = "Linux"
then
  echo "This is a LINUX host: $host"
  mkdir -p "$ac_pwd/build/$host"
dnl AC_SUBST(MYSRCDIR, $ac_pwd/build/$host/src)
fi

if test $UNAME_S = "OpenBSD"
then
  echo "This is an OpenBSD host: $host"
  mkdir -p "$ac_pwd/build/$host"
fi


AC_OUTPUT
