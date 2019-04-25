# *** for WCOSS IBM phase1/phase2 (intel) ***
 module load ics/17.0.3
#module load bacio/2.0.2
 module load bacio/v2.0.1

 export CC=icc
 export FC=ifort
 export OMPCC="$CC -qopenmp"
 export OMPFC="$FC -qopenmp"

 export DEBUG="-g -O0"
 export CFLAGS="-O3 -DUNDERSCORE -DLINUX -fPIC"
 export FFLAGS="-O3 -xHOST -traceback -fPIC"
 export I4R4="-integer-size 32 -real-size 32"
 export I4R8="-integer-size 32 -real-size 64"
 export I8R8="-integer-size 64 -real-size 64"

 export CPPDEFS=""
 export CFLAGSDEFS=""
 export FFLAGSDEFS=""
 export USECC="YES"
 export USEFC="YES"
 export DEPS=""
