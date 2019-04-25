#!/bin/sh

 (( $# == 0 )) && {
   echo "*** Usage: $0 wcoss|dell|cray|theia|intel_general|gnu_general [debug|build] [[local]install[only]]"
   exit 1
 }

 sys=${1,,}
 [[ $sys == wcoss || $sys == dell || $sys == cray ||\
    $sys == theia || $sys == intel_general || $sys == gnu_general ]] || {
   echo "*** Usage: $0 wcoss|dell|cray|theia|intel_general|gnu_general [debug|build] [[local]install[only]]"
   exit 1
 }
 debg=false
 inst=false
 skip=false
 local=false
 (( $# > 1 )) && {
   [[ ${2,,} == build ]] && debg=false
   [[ ${2,,} == debug ]] && debg=true
   [[ ${2,,} == install ]] && inst=true
   [[ ${2,,} == localinstall ]] && { local=true; inst=true; }
   [[ ${2,,} == installonly ]] && { inst=true; skip=true; }
   [[ ${2,,} == localinstallonly ]] && { local=true; inst=true; skip=true; }
 }
 (( $# > 2 )) && {
   [[ ${3,,} == build ]] && debg=false
   [[ ${3,,} == debug ]] && debg=true
   [[ ${3,,} == install ]] && inst=true
   [[ ${3,,} == localinstall ]] && { local=true; inst=true; }
   [[ ${3,,} == installonly ]] && { inst=true; skip=true; }
   [[ ${3,,} == localinstallonly ]] && { local=true; inst=true; skip=true; }
 }
 if [[ ${sys} == "intel_general" ]]; then
   sys6=${sys:6}
   source ./Conf/Bacio_${sys:0:5}_${sys6^}.sh
 elif [[ ${sys} == "gnu_general" ]]; then
   sys4=${sys:4}
   source ./Conf/Bacio_${sys:0:3}_${sys4^}.sh
 else
   source ./Conf/Bacio_intel_${sys^}.sh
 fi

 [[ -z $BACIO_VER || -z $BACIO_LIB4 ]] && {
   echo "??? BACIO: module/environment not set."
   exit 1
 }
 echo "*info* BACIO Version from module file: $BACIO_VER"

 source ./Conf/Collect_info.sh
 source ./Conf/Gen_cfunction.sh

set -x
 bacioLib4=$(basename ${BACIO_LIB4})
 bacioLib8=$(basename ${BACIO_LIB8})

#################
 cd src
#################

 $skip || {
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
 }

 $inst && {
#
#     Install libraries and source files 
#
   $local && {
              LIB_DIR4=..
              LIB_DIR8=..
             } || {
                   LIB_DIR4=$(dirname ${BACIO_LIB4})
                   LIB_DIR8=$(dirname ${BACIO_LIB8})
                  }
   [ -d $LIB_DIR4 ] || mkdir -p $LIB_DIR4
   [ -d $LIB_DIR8 ] || mkdir -p $LIB_DIR8
   SRC_DIR=$BACIO_SRC
   $local && SRC_DIR=
   [ -z $SRC_DIR ] || {
     [ -d $SRC_DIR ] || mkdir -p $SRC_DIR
   }
   make clean LIB=
   make install LIB=$bacioLib4 LIB_DIR=$LIB_DIR4 SRC_DIR=
   make install LIB=$bacioLib8 LIB_DIR=$LIB_DIR8 SRC_DIR=$SRC_DIR
 }
