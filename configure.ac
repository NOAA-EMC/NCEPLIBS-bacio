## Put version control id tag in output configure script
AC_REVISION($Id: $)


## Initialise autoconf
AC_INIT([bacio], [2.0.1], [ncep.list.emc.nceplibs.support@noaa.gov])


# Output info for user
AC_MSG_NOTICE([bacio AC_PACKAGE_VERSION])


# Check for existence of unique file before proceeding
AC_CONFIG_SRCDIR([src/bacio.c])


# Define the configuration files
AC_CONFIG_FILES([Makefile src/Makefile])


# Check for programs
AC_PROG_CC(icc gcc xlc pgcc)
AC_PROG_FC(ifort gfortran xlf2003 pgf95)
AC_PROG_INSTALL


# Check compiler "family"
AC_MSG_CHECKING([if the C and Fortran compilers are "in family"])
case $CC in
  icc) matching_fc=ifort ;;
  gcc) matching_fc=gfortran ;;
  xlc) matching_fc=xlf2003 ;;
  pgcc) matching_fc=pgf95 ;;
  *) matching_fc=${FC} ;;
esac
if test "x${FC}" = "x${matching_fc}"; then
  AC_MSG_RESULT(yes)
else
  AC_MSG_RESULT(no)
  AC_MSG_WARN([
    C ($CC) and Fortran ($FC) compilers may be incompatible
    ])
fi


# Set the programming language
AC_LANG(Fortran)
AC_FC_SRCEXT(f)


# Establish the default type promotion
AC_ARG_ENABLE([promote],
  [AS_HELP_STRING([--enable-promote],[Promote defaults to 8. @<:@default: 4@:>@])],
  [promote=${enableval}],[promote=4])
case ${promote} in
  8) precision=${promote};;
  *) precision=4;;
esac
AC_MSG_NOTICE([Building precision ${precision} version.])
AC_SUBST(SUFFIX,[_${precision}])


# Set the default compiler flags

# ...C ones first
case $CC in
  icc)  CFLAGS="-O3 -DUNDERSCORE -DLINUX $CFLAGS" ;;
  gcc)  CFLAGS="-O3 -DUNDERSCORE -DLINUX $CFLAGS" ;;
  pgcc) CFLAGS="-O3 -DUNDERSCORE -DLINUX $CFLAGS" ;;
  xlc)  CFLAGS="-q64 -O3 $CFLAGS"
        if test "x${precision}" = x4; then
          CFLAGS="-DIBM4 $CFLAGS"
        else
          CFLAGS="-qlonglong -DIBM8 $CFLAGS"
        fi ;;
  *) ;;
esac

# ...and now Fortran
case $FC in
  ifort|gfortran|pgf95) 
    FCFLAGS="-O3 $FCFLAGS"
    if test "x${precision}" = x8; then
      FCFLAGS="-i8 -r8 $FCFLAGS"
    fi ;;
  xlf2003)  
    FCFLAGS="-O3 -qnosave $FCFLAGS"
    if test "x${precision}" = x8; then
      FCFLAGS="-qintsize=8 -qrealsize=8 $FCFLAGS"
    fi ;;
  *) ;;
esac

AC_OUTPUT
