cmake_minimum_required( VERSION 3.15 )

project( bacio VERSION 2.1.0 LANGUAGES C Fortran )

if( NOT CMAKE_BUILD_TYPE MATCHES "^(Debug|Release|RelWithDebInfo|MinSizeRel)$" )
  message( STATUS "Setting build type to 'Release' as none was specified." )
  set( CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose the type of build." FORCE )
  set_property( CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
    "Debug" "Release" "MinSizeRel" "RelWithDebInfo" )
endif()

if( NOT CMAKE_C_COMPILER_ID MATCHES "^(Intel|GNU|Clang|AppleClang|PGI)$" )
  message( WARNING "Compiler not officially supported: ${CMAKE_C_COMPILER_ID}" )
endif()

add_compile_definitions( UNDERSCORE )
if( APPLE )
  add_compile_definitions( APPLE )
elseif( UNIX )
  add_compile_definitions( LINUX )
endif()

if( CMAKE_C_COMPILER_ID MATCHES "^(Intel)$" )
  set( CMAKE_Fortran_FLAGS "-fpp -free -xHOST -traceback -FR")
  set( CMAKE_Fortran_FLAGS_DEBUG "-g")
  set( fortran_8_flag "-i8" "-r8")
elseif( CMAKE_C_COMPILER_ID MATCHES "^(GNU|Clang|AppleClang)$" )
  set( CMAKE_C_FLAGS "-ggdb -Wall")
  set( CMAKE_Fortran_FLAGS "-ggdb -Wall -ffree-form -fbacktrace -funroll-loops")
  set( CMAKE_Fortran_FLAGS_DEBUG "-g")
  set( fortran_8_flags "-fdefault-integer-8" "-fdefault-real-8")
elseif( {CMAKE_C_COMPILER_ID MATCHES "^(PGI)$" )
  set( CMAKE_C_FLAGS "-g -fast")
  set( CMAKE_Fortran_FLAGS "-g -fast" )
  set( fortran_8_flags "-i8" "-r8")
endif()

set( fortran_src src/baciof.f src/bafrio.f src/chk_endianc.f )
set( c_src src/bacio.c src/byteswap.c )

# One target for real32 and one target for real64
set(kinds "4" "8")
foreach(kind ${kinds})
  set(lib_name ${PROJECT_NAME}_${kind})
  set(versioned_lib_name ${PROJECT_NAME}_v${PROJECT_VERSION}_${kind})
  #set( versioned_lib_name ${lib_name}.${PROJECT_VERSION} )

  add_library(${lib_name}_f OBJECT ${fortran_src})
  set_target_properties(${lib_name}_f PROPERTIES POSITION_INDEPENDENT_CODE ON)
  set_target_properties(${lib_name}_f PROPERTIES COMPILE_OPTIONS "${fortran_${kind}_flags}")

  add_library(${lib_name}_c OBJECT ${c_src})
  set_target_properties(${lib_name}_c PROPERTIES POSITION_INDEPENDENT_CODE ON)

  set(module_dir "${CMAKE_CURRENT_BINARY_DIR}/include_${kind}")
  set_target_properties(${lib_name}_f PROPERTIES Fortran_MODULE_DIRECTORY "${module_dir}")

  add_library(${lib_name} STATIC $<TARGET_OBJECTS:${lib_name}_f> $<TARGET_OBJECTS:${lib_name}_c>)

  set_target_properties(${lib_name} PROPERTIES OUTPUT_NAME "${versioned_lib_name}")

  target_include_directories(${lib_name} PUBLIC
    $<BUILD_INTERFACE:${module_dir}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_PREFIX}/include_${kind}>)

  install(TARGETS ${lib_name}
    EXPORT ${PROJECT_NAME}-config
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib)

  install(DIRECTORY ${module_dir} DESTINATION ${CMAKE_INSTALL_PREFIX})
endforeach()

install( EXPORT ${PROJECT_NAME}-config DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/cmake/${PROJECT_NAME} )
