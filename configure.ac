#                                               -*- Autoconf -*-

# This is the autoconf file for the bacio package, which performs I/O
# for NCEP models.

# Ed Hartnett, 11/1/19

# Running autoconf on this file will trigger a warning if autoconf is
# not at least the specified version.
AC_PREREQ([2.59])

# Initialize with name, version, and support email address.
AC_INIT([bacio], [2.0.2], [NCEP.List.EMC.nceplibs.Developers@noaa.gov], [bacio])

# Keep libtool macros in an m4 directory.
AC_CONFIG_MACRO_DIR([m4])

# Find out about the host we're building on.
AC_CANONICAL_HOST

# Find out about the target we're building for.
AC_CANONICAL_TARGET

#AC_CONFIG_HEADERS([config.h])

# Initialize automake.
AM_INIT_AUTOMAKE([foreign dist-zip subdir-objects])
AM_MAINTAINER_MODE()

# Check for the existence of this file before proceeding.
AC_CONFIG_SRCDIR([src/bacio.c])

# Find the C compiler.
AC_MSG_NOTICE([finding C compiler])
AC_PROG_CC
AM_PROG_CC_C_O
AC_C_CONST

# Find the Fortran compiler.
AC_MSG_NOTICE([finding Fortran compiler])
AC_PROG_F77

# Set up libtool.
AC_MSG_NOTICE([setting up libtool])
LT_PREREQ([2.2])
LT_INIT()

AC_MSG_NOTICE([finding other utilities])

# Find the install program.
AC_PROG_INSTALL

# Check to see if any macros must be set to enable large (>2GB) files.
AC_SYS_LARGEFILE

AC_MSG_NOTICE([checking types, headers, and functions])

# These defines are required for the build.
AC_DEFINE([LINUX], [1])

AC_HEADER_STDC
#AC_CHECK_HEADERS([locale.h stdio.h stdarg.h fcntl.h malloc.h stdlib.h string.h strings.h unistd.h sys/stat.h getopt.h sys/time.h sys/types.h])

# Check for these functions...
dnl AC_CHECK_FUNCS([strlcat snprintf strcasecmp fileno \
dnl                 strdup strtoll strtoull \
dnl 		mkstemp mktemp random \
dnl 		getrlimit gettimeofday fsync MPI_Comm_f2c MPI_Info_f2c])

# We need the math library
AC_CHECK_LIB([m], [floor], [],
[AC_MSG_ERROR([Can't find or link to the math library.])])

AC_CONFIG_FILES([Makefile
                 src/Makefile
                 test/Makefile
                 ])
AC_OUTPUT()

