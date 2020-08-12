cmake_minimum_required(VERSION 3.15)

file(STRINGS "VERSION" pVersion)

project(
  bacio
  VERSION ${pVersion}
  LANGUAGES C Fortran)

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

add_compile_definitions(UNDERSCORE)
if(APPLE)
  add_compile_definitions(APPLE)
elseif(UNIX)
  add_compile_definitions(LINUX)
endif()

if(CMAKE_C_COMPILER_ID MATCHES "^(Intel)$")
  set(CMAKE_Fortran_FLAGS "-g -fpp -free -xHOST -traceback -FR")
  set(fortran_8_flags "-i8 -r8")
elseif(CMAKE_C_COMPILER_ID MATCHES "^(GNU|Clang|AppleClang)$")
  set(CMAKE_C_FLAGS_DEBUG "-ggdb -Wall")
  set(CMAKE_Fortran_FLAGS "-g -ffree-form -fbacktrace -funroll-loops")
  set(CMAKE_Fortran_FLAGS_DEBUG "-ggdb -Wall")
  set(fortran_8_flags "-fdefault-integer-8 -fdefault-real-8")
endif()

# For gfortran-10+ backward compatibility
if(${CMAKE_Fortran_COMPILER_ID} STREQUAL "GNU" AND ${CMAKE_Fortran_COMPILER_VERSION} VERSION_GREATER 9.9)
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -w -fallow-argument-mismatch")
endif()

set(fortran_src src/baciof.f src/bafrio.f src/chk_endianc.f)
set(c_src src/bacio.c src/byteswap.c)

# One target for real32 and one target for real64
set(kinds "4" "8")
foreach(kind ${kinds})
  set(lib_name ${PROJECT_NAME}_${kind})
  set(versioned_lib_name ${PROJECT_NAME}_v${PROJECT_VERSION}_${kind})
  set(module_dir ${CMAKE_CURRENT_BINARY_DIR}/include_${kind})

  add_library(${lib_name}_f OBJECT ${fortran_src})
  set_target_properties(${lib_name}_f PROPERTIES COMPILE_FLAGS
                                                 "${fortran_${kind}_flags}")
  set_target_properties(${lib_name}_f PROPERTIES Fortran_MODULE_DIRECTORY
                                                 ${module_dir})

  add_library(${lib_name}_c OBJECT ${c_src})

  add_library(${lib_name} STATIC $<TARGET_OBJECTS:${lib_name}_f>
                                 $<TARGET_OBJECTS:${lib_name}_c>)
  set_target_properties(${lib_name} PROPERTIES OUTPUT_NAME
                                               ${versioned_lib_name})
  target_include_directories(
    ${lib_name}
    PUBLIC $<BUILD_INTERFACE:${module_dir}>
           $<INSTALL_INTERFACE:${CMAKE_INSTALL_PREFIX}/include_${kind}>)

  install(
    TARGETS ${lib_name}
    EXPORT ${PROJECT_NAME}-config
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib)

  install(DIRECTORY ${module_dir} DESTINATION ${CMAKE_INSTALL_PREFIX})
endforeach()

install(EXPORT ${PROJECT_NAME}-config
        DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/cmake/${PROJECT_NAME})
