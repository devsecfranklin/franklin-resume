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
AC_OUTPUT
