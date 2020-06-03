cmake_minimum_required(VERSION 3.15)

file(STRINGS "VERSION" pVersion)

project(
  bacio
  VERSION ${pVersion}
  LANGUAGES C Fortran)

include(GNUInstallDirs)

### Configuration options
option(BUILD_STATIC_LIBS "Build static libraries" ON)
option(BUILD_SHARED_LIBS "Build shared libraries" OFF)

# Ensure at least one of BUILD_SHARED_LIBS and BUILD_STATIC_LIBS is set
if(NOT (BUILD_STATIC_LIBS OR BUILD_SHARED_LIBS))
  message(WARNING "Niether BUILD_STATIC_LIBS nor BUILD_SHARED_LIBS is set.  Defaulting to BUILD_STATIC_LIBS=ON")
  set(BUILD_STATIC_LIBS ON CACHE BOOL "[FORCE ENABLED] Build static libraries" FORCE)
  set(BUILD_STATIC_LIBS ON)
endif()

message(STATUS "Option: BUILD_STATIC_LIBS: ${BUILD_STATIC_LIBS}")
message(STATUS "Option: BUILD_SHARED_LIBS: ${BUILD_SHARED_LIBS}")


if(NOT CMAKE_BUILD_TYPE MATCHES "^(Debug|Release|RelWithDebInfo|MinSizeRel)$")
  message(STATUS "Setting build type to 'Release' as none was specified.")
  set(CMAKE_BUILD_TYPE
      "Release"
      CACHE STRING "Choose the type of build." FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release"
                                               "MinSizeRel" "RelWithDebInfo")
endif()

if(NOT CMAKE_C_COMPILER_ID MATCHES "^(Intel|GNU|Clang|AppleClang)$")
  message(WARNING "Compiler not officially supported: ${CMAKE_C_COMPILER_ID}")
endif()

add_subdirectory(src)

if (${ENABLE_TESTS})
  find_package(PFUNIT REQUIRED)
  enable_testing()
  add_subdirectory(tests)
endif()
