# This is the main CMake file for NCEPLIBS-sp.
#
# Mark Potts, Kyle Gerheiser, Ed Hartnett
cmake_minimum_required(VERSION 3.15)

# Get the version from the VERSION file.
file(STRINGS "VERSION" pVersion)

# Set up the cmake project.
project(bacio VERSION ${pVersion} LANGUAGES C Fortran)

# Load GNU standard install paths.
include(GNUInstallDirs)

# Handle user options.
option(ENABLE_DOCS "Enable generation of doxygen-based documentation." OFF)
option(BUILD_TESTING "Build tests of the library" ON)

# Set the build type.
if(NOT CMAKE_BUILD_TYPE MATCHES "^(Debug|Release|RelWithDebInfo|MinSizeRel)$")
  message(STATUS "Setting build type to 'Release' as none was specified.")
  set(CMAKE_BUILD_TYPE
      "Release"
      CACHE STRING "Choose the type of build." FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release"
                                               "MinSizeRel" "RelWithDebInfo")
endif()

# This is the source code directiroy.
add_subdirectory(src)

# Turn on testing if desired.
if (BUILD_TESTING)
  include(CTest)
  add_subdirectory(tests)
endif()

# Build docs if required.
if(ENABLE_DOCS)
  find_package(Doxygen REQUIRED)
  add_subdirectory(docs)  
endif()
