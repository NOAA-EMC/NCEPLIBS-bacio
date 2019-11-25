#!/bin/bash

 : ${THISDIR:=$(dirname $(readlink -f -n ${BASH_SOURCE[0]}))}
 CDIR=$PWD; cd $THISDIR

 source ./Conf/Analyse_args.sh
 source ./Conf/Collect_info.sh
 source ./Conf/Gen_cfunction.sh
 source ./Conf/Reset_version.sh

 if [[ ${sys} == "intel_general" ]]; then
   sys6=${sys:6}
   source ./Conf/Bacio_${sys:0:5}_${sys6^}.sh
   rinst=false
 elif [[ ${sys} == "gnu_general" ]]; then
   sys4=${sys:4}
   source ./Conf/Bacio_${sys:0:3}_${sys4^}.sh
   rinst=false
 else
   source ./Conf/Bacio_intel_${sys^}.sh
 fi
 $CC --version &> /dev/null || {
   echo "??? BACIO: compilers not set." >&2
   exit 1
 }
 [[ -z ${BACIO_VER+x} || -z ${BACIO_LIB4+x} ]] && {
   [[ -z ${libver+x} || -z ${libver} ]] && {
     echo "??? BACIO: \"libver\" not set." >&2
     exit
   }
   BACIO_LIB4=lib${libver}_4.a
   BACIO_LIB8=lib${libver}_8.a
   BACIO_VER=v${libver##*_v}
 }

set -x
 bacioLib4=$(basename ${BACIO_LIB4})
 bacioLib8=$(basename ${BACIO_LIB8})

#################
 cd src
#################

#-------------------------------------------------------------------
# Start building libraries
#
 echo
 echo "   ... build i4/r4 bacio library ..."
 echo
   make clean LIB=$bacioLib4
   FFLAGS4="$I4R4 $FFLAGS"
   collect_info bacio 4 OneLine4 LibInfo4
   bacioInfo4=bacio_info_and_log4.txt
   $debg && make debug FFLAGS="$FFLAGS4" LIB=$bacioLib4 &> $bacioInfo4 \
         || make build FFLAGS="$FFLAGS4" LIB=$bacioLib4 &> $bacioInfo4 
   make message MSGSRC="$(gen_cfunction $bacioInfo4 OneLine4 LibInfo4)" LIB=$bacioLib4

 echo
 echo "   ... build i8/r8 bacio library ..."
 echo
   make clean LIB=$bacioLib8
   FFLAGS8="$I8R8 $FFLAGS"
   collect_info bacio 8 OneLine8 LibInfo8
   bacioInfo8=bacio_info_and_log8.txt
   $debg && make debug FFLAGS="$FFLAGS8" LIB=$bacioLib8 &> $bacioInfo8 \
         || make build FFLAGS="$FFLAGS8" LIB=$bacioLib8 &> $bacioInfo8 
   make message MSGSRC="$(gen_cfunction $bacioInfo8 OneLine8 LibInfo8)" LIB=$bacioLib8

 $inst && {
#
#     Install libraries and source files 
#
   $local && {
     instloc=..
     LIB_DIR=$instloc/lib
     [ -d $LIB_DIR ] || { mkdir -p $LIB_DIR; }
     LIB_DIR4=$LIB_DIR
     LIB_DIR8=$LIB_DIR
     SRC_DIR=
   } || {
     $rinst && {
       LIB_DIR4=$(dirname ${BACIO_LIB4})
       LIB_DIR8=$(dirname ${BACIO_LIB8})
       SRC_DIR=$BACIO_SRC
     } || {
       LIB_DIR=$instloc/lib
       LIB_DIR4=$LIB_DIR
       LIB_DIR8=$LIB_DIR
       SRC_DIR=$instloc/src/${libver}
       [[ $instloc == .. ]] && SRC_DIR=
     }
     [ -d $LIB_DIR4 ] || mkdir -p $LIB_DIR4
     [ -d $LIB_DIR8 ] || mkdir -p $LIB_DIR8
     [ -z $SRC_DIR ] || { [ -d $SRC_DIR ] || mkdir -p $SRC_DIR; }
   }

   make clean LIB=
   make install LIB=$bacioLib4 LIB_DIR=$LIB_DIR4 SRC_DIR=
   make install LIB=$bacioLib8 LIB_DIR=$LIB_DIR8 SRC_DIR=$SRC_DIR
 }

