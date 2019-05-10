# *** manually set environments (for intel compiler) of bacio  ***

# !!! module environment (*THEIA*) !!!
 module load intel/18.1.163

 ANCHORDIR=..
 export BACIO_VER=v2.0.2
 export COMP=ips
 export BACIO_SRC=
 export BACIO_LIB4=$ANCHORDIR/libbacio_${BACIO_VER}_4.a
 export BACIO_LIB8=$ANCHORDIR/libbacio_${BACIO_VER}_8.a

 export CC=icc
 export FC=ifort
 export CPP=cpp
 export OMPCC="$CC -qopenmp"
 export OMPFC="$FC -qopenmp"
 export MPICC=mpiicc
 export MPIFC=mpiifort

 export DEBUG="-g -O0"
 export CFLAGS="-O3 -fPIC"
 export FFLAGS="-O3 -xHOST -traceback -fPIC"
 export FPPCPP="-cpp"
 export FREEFORM="-free"
 export CPPFLAGS="-P -traditional-cpp"
 export MPICFLAGS="-O3 -fPIC"
 export MPIFFLAGS="-O3 -xHOST -traceback -fPIC"
 export MODPATH="-module "
 export I4R4="-integer-size 32 -real-size 32"
 export I4R8="-integer-size 32 -real-size 64"
 export I8R8="-integer-size 64 -real-size 64"

 export CPPDEFS=""
 export CFLAGSDEFS="-DUNDERSCORE -DLINUX"
 export FFLAGSDEFS=""

 export USECC="YES"
 export USEFC="YES"
 export DEPS=""
