## Put version control id tag in output configure script
AC_REVISION($Id: $)


## Initialise autoconf
AC_INIT([nceplibs bacio], [v2.1.0], [ncep.list.emc.nceplibs.support@noaa.gov], [bacio])


# Output info for user
AC_MSG_NOTICE([AC_PACKAGE_NAME AC_PACKAGE_VERSION])


# Check for existence of unique file before proceeding
AC_CONFIG_SRCDIR([src/bacio.c])


# Define the configuration files
AC_CONFIG_FILES([Makefile src/Makefile src/test/Makefile])


# Check for programs and tools
AC_PROG_CC(icc gcc xlc pgcc)
AC_PROG_FC(ifort gfortran xlf2003 pgf95)
AC_PROG_INSTALL
AC_CHECK_TOOL([AR], ar)
AC_CHECK_TOOL([RANLIB], ranlib)
# ...Set defaults for ARFLAGS since there is no autoconf macro
test -n "$ARFLAGS" || ARFLAGS="crvs"
AC_SUBST(ARFLAGS)


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
AC_FC_FREEFORM
AC_FC_SRCEXT(f)


# Check platform endian-ness
AC_MSG_CHECKING([if platform is little-endian])
if test 1 -eq `printf '\1' | od -dAn`; then
  AC_MSG_RESULT(yes)
  ENDIAN_TYPE="little"
else
  AC_MSG_RESULT(no)
  ENDIAN_TYPE="big"
fi


# Establish the default type promotion
AC_ARG_ENABLE([promote],
  [AS_HELP_STRING([--enable-promote],[Promote defaults to 8. @<:@default: 4@:>@])],
  [promote=${enableval}],[promote=4])
case ${promote} in
  8) precision=${promote};;
  *) precision=4;;
esac
AC_MSG_NOTICE([Building precision ${precision} version.])
AC_SUBST(PRECISION,[${precision}])


# Set the default type promotion compiler flags
# ...C ones first
case $CC in
  xlc|ncepxlc) CFLAGS="-DIBM${precision} $CFLAGS";;
  *) ;;
esac
# ...and now Fortran
case $FC in
  gfortran)
    if test "x${precision}" = x8; then
      FCFLAGS="-fdefault-integer-8 -fdefault-real-8 $FCFLAGS"
    fi ;;
  ifort|pgf95)
    if test "x${precision}" = x8; then
      FCFLAGS="-i8 -r8 $FCFLAGS"
    fi ;;
  xlf2003|ncepxlf)
    if test "x${precision}" = x8; then
      FCFLAGS="-qintsize=8 -qrealsize=8 $FCFLAGS"
    fi ;;
  *) AC_MSG_WARN([Precision promotion flags for $FC unknown and not set]);;
esac


# ==========================================================
# NOTE: The section below deals ONLY with the TESTS.
#       No library build options are affected here.

# Determine the I/O endian-type to use in testing.
AC_ARG_ENABLE([big-endian-test],
  [AS_HELP_STRING([--disable-big-endian-test],[Native I/O on little-endian machines for testing. @<:@default: big-endian@:>@])],
  [endian_test=little],[endian_test=big])


# Assign the Fortran compiler switches accordingly
if test "${endian_test}" = big -a "${ENDIAN_TYPE}" = little; then
  ENDIAN_TYPE=${endian_test}
  case ${FC} in
    ifort)    ENDIAN_FCFLAGS="-convert big_endian";;
    gfortran) ENDIAN_FCFLAGS="-fconvert=big-endian";;
    pgf95)    ENDIAN_FCFLAGS="-byteswapio";;
    g95)      ENDIAN_FCFLAGS="-fendian=big";;
    xlf2003)  ;;
    *)        AC_MSG_WARN([Endian swap flags for $FC unknown and not set]);;
  esac
else
  ENDIAN_FCFLAGS=""
fi
AC_SUBST(ENDIAN_TYPE)
AC_SUBST(ENDIAN_FCFLAGS)
AC_MSG_NOTICE([Building ${ENDIAN_TYPE}-endian tests])
# ==========================================================

AC_OUTPUT
