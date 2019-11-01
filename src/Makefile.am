# This is the automake file for the NCEP bacio library.

# Ed Hartnett 11/1/2019.

# Build this convenience library with the C code.
noinst_LTLIBRARIES = libbacioc.la
libbacioc_la_SOURCES = bacio.c byteswap.c

# This is the library we will install.
lib_LTLIBRARIES = libbacio.la
libbacio_la_SOURCES = baciof.f bafrio.f chk_endianc.f baciof.h	\
fast-byteswap.h clib.h

# Add the C-base convenience library.
libbacio_la_LIBADD = libbacioc.la

# These linker flags specify libtool version info.
# See http://www.gnu.org/software/libtool/manual/libtool.html#Libtool-versioning
# for information regarding incrementing `-version-info`.
libbacio_la_LDFLAGS = -version-info 0:0:0

# Each mod file depends on the .o file.
bacio_module.mod: baciof.$(OBJEXT)

# Mod files are built and then installed as headers.
MODFILES = bacio_module.mod
include_HEADERS = $(MODFILES)
BUILT_SOURCES = $(MODFILES)

CLEANFILES = *.mod
