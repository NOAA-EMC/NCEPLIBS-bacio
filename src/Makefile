SHELL=/bin/sh

# sources, headers, objects, library and etc.
SRCS_C   = bacio.c byteswap.c
SRCS_F   = baciof.f bafrio.f chk_endianc.f
DEPS     = clib.h
OBJS     = $(patsubst %.c, %.o, $(SRCS_C)) \
           $(patsubst %.f, %.o, $(SRCS_F))

all: build

build: $(LIB)

$(LIB): $(OBJS)
	$(AR) $(ARFLAGS) $@ $^

debug: dbg_build

dbg_build: override CFLAGS += $(DEBUG)
dbg_build: override FFLAGS += $(DEBUG)
dbg_build: $(LIB)

%.o: %.c
	$(CC) -c $(CFLAGS) $(CFLAGSDEFS) $<

%.o: %.f
	$(FC) -c $(FFLAGS) $(FFLAGSDEFS) $<

message: $(MSGSRC)
	$(CC) -c $(firstword $(MSGSRC))
	$(FC) -c $(lastword $(MSGSRC))
	$(AR) $(ARFLAGS) $(LIB) $(patsubst %.c, %.o, $(firstword $(MSGSRC)))
	$(AR) $(ARFLAGS) $(LIB) $(patsubst %.f, %.o, $(lastword $(MSGSRC)))
	$(RM) $(patsubst %.c, %.o, $(firstword $(MSGSRC)))
	$(RM) $(patsubst %.f, %.o, $(lastword $(MSGSRC)))
	$(RM) $(MSGSRC)

install:
	[[ -z "$(LIB)" || -z "$(LIB_DIR)" ]] || mv $(LIB) $(LIB_DIR)
	[[ -z "$(SRC_DIR)" ]] || cp ./* $(SRC_DIR)

test:
	cd ../unit_test/scripts && ./test_bacio.sh

clean:
	$(RM) $(OBJS) $(LIB) *.mod

.SUFFIXES: .c .h .f .o

# Specify targets that do not generate filesystem objects
.PHONY: all build install debug dbg_build message test clean

