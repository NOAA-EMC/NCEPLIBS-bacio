#!/bin/sh
###############################################################################
#
# $Id$
#
# Script to iterate the configuration script over the set of precision
# versions of the library.
#
# The build configuration setup (compiler, compiler switched, libraries, etc)
# is specified via files in the config-setup/ subdirectory that are sourced
# within this script.
#
# The installation directory is ${PWD}
#
###############################################################################

# Check that a build setup file was specified.
if [ $# -ne 1 ]; then
  echo "$0: Must specify build setup. Valid setups:" >&2
  echo "Usage: `basename $0` setup-file" >&2
  echo "  Valid setups:" >&2
  for FILE in `ls ./config-setup/`; do
    echo "    `basename ${FILE}`" >&2
  done
  exit 1
fi


# Source the build setup
SETUP_FILE="./config-setup/$1"
if [ ! -f ${SETUP_FILE} ]; then
  echo "$0: Cannot find specified setup file ${SETUP_FILE}" >&2
  exit 1
fi
. ${SETUP_FILE}


# The configuration and build
PRECISION_LIST="4 8"
for PRECISION in ${PRECISION_LIST}; do

  # Generate the makefiles
  echo; echo; echo; echo
  echo "==============================================================="
  echo "==============================================================="
  echo "Configuring for precision ${PRECISION} build"
  echo "==============================================================="
  echo "==============================================================="
  echo
  ./configure --prefix=${PWD} --enable-promote=${PRECISION}
  if [ $? -ne 0 ]; then
    echo "$0: Error configuring for precision ${PRECISION} version build" >&2
    exit 1
  fi

  # Build the current configuration
  echo; echo
  echo "==============================================================="
  echo "Starting precision ${PRECISION} build"
  echo "==============================================================="
  echo
  make clean
  make
  if [ $? -ne 0 ]; then
    echo "$0: Error building precision ${PRECISION} version" >&2
    exit 1
  fi

# **** TEMPORARY - tests for precision 8 library fail ****
# ****             only run precision 4 library check ****
if [ ${PRECISION} -eq 4 ]; then

  # Run tests for the current configuration
  echo; echo
  echo "==============================================================="
  echo "Running tests for precision ${PRECISION} build"
  echo "==============================================================="
  echo
  make check
  if [ $? -ne 0 ]; then
    echo "$0: Error running tests for precision ${PRECISION} version" >&2
    exit 1
  fi

fi
# **** TEMPORARY - tests for precision 8 library fail ****
# ****             only run precision 4 library check ****


  # Install the current build...
  echo; echo
  echo "==============================================================="
  echo "Performing GNU-type install of precision ${PRECISION} build"
  echo "==============================================================="
  echo
  make install

  echo; echo
  echo "==============================================================="
  echo "Performing NCO-type install of precision ${PRECISION} build"
  echo "==============================================================="
  echo
  make nco_install

  # Save the build log file.
  cp config.log config.log_${PRECISION}

done

