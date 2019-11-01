# THis is the automake file for the bacio library tests.

# Ed Hartnett 11/1/19

AM_FCFLAGS = -I$(top_builddir)/src
AM_FFLAGS = ${AM_FCFLAGS}

# Link to bacio library.
LDADD = ${top_builddir}/src/libbacio.la

# The F90 API tests.
check_PROGRAMS = tst_bacio
TESTS = tst_bacio
tst_bacio_SOURCES = tst_bacio.F90

#CLEANFILES = 
