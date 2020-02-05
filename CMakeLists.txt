cmake_minimum_required(VERSION 3.15)
project(bacio VERSION 2.1.0)
set(${PROJECT_NAME}_VERSION ${PROJECT_VERSION} CACHE INTERNAL "${PROJECT_NAME} version number")
enable_language(Fortran)

if (NOT CMAKE_BUILD_TYPE)
  set (CMAKE_BUILD_TYPE RELEASE CACHE STRING
    "Choose the type of build, options are: PRODUCTION Debug Release."
    FORCE)
endif()

if(CMAKE_CXX_COMPILER_ID STREQUAL "Intel")
  set(IntelComp true)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU*" OR CMAKE_CXX_COMPILER_ID MATCHES "Clang*")
  set(GNUComp true)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "pgc*")
  set(PGIComp true)
endif()

STRING(COMPARE EQUAL ${CMAKE_BUILD_TYPE} "RelWithDebInfo" BUILD_RELEASE)
if(NOT BUILD_RELEASE)
  STRING(COMPARE EQUAL ${CMAKE_BUILD_TYPE} "RELEASE" BUILD_RELEASE)
endif()
STRING(COMPARE EQUAL ${CMAKE_BUILD_TYPE} "PRODUCTION" BUILD_PRODUCTION)
STRING(COMPARE EQUAL ${CMAKE_BUILD_TYPE} "DEBUG" BUILD_DEBUG)

if (APPLE)
  set(c_definitions "UNDERSCORE" "APPLE")
elseif(UNIX)
  set(c_definitions "UNDERSCORE" "LINUX")
endif(APPLE)

if((BUILD_RELEASE) OR (BUILD_PRODUCTION))
  if(IntelComp)
    set(c_flags)
    set(shared_fortran_flags "-fpp" "-free" "-xHOST" "-traceback" "-FR")
    set(fortran_8_flag "-i8" "-r8")
    set(fortran_4_flags) #no special flags for this case
  elseif(GNUComp)
    set(c_flags "-ggdb" "-Wall")
    set(shared_fortran_flags "-ffree-form" "-fbacktrace" "-funroll-loops" "-ggdb" "-Wall") 
    set(fortran_8_flags "-fdefault-integer-8" "-fdefault-real-8")
    set(fortran_4_flags)
  elseif(PGIComp)
    set(c_flags "-g" "-fast")
    set(shared_fortran_flags "-g" "-fast")
    set(fortran_8_flags "-i8" "-r8")
    set(fortran_4_flags)
  else()
    message("unknown compiler!")
    exit()
  endif()
endif()

file(GLOB fortran_src ${CMAKE_CURRENT_SOURCE_DIR}/src/*.f)
file(GLOB c_src ${CMAKE_CURRENT_SOURCE_DIR}/src/*.c)

# One target for real32 and one target for real64
set(kinds "4" "8")
foreach(kind ${kinds})
  set(lib_name ${PROJECT_NAME}_${kind})
  set(versioned_lib_name ${PROJECT_NAME}_v${PROJECT_VERSION}_${kind})

  add_library(${lib_name}_f OBJECT ${fortran_src})
  set_target_properties(${lib_name}_f PROPERTIES POSITION_INDEPENDENT_CODE ON)
  set_target_properties(${lib_name}_f PROPERTIES
    COMPILE_OPTIONS "${shared_fortran_flags};${fortran_${kind}_flags}")

  add_library(${lib_name}_c OBJECT ${c_src})
  set_target_properties(${lib_name}_c PROPERTIES POSITION_INDEPENDENT_CODE ON)
  set_target_properties(${lib_name}_c PROPERTIES
    COMPILE_OPTIONS "${c_flags}")
  set_target_properties(${lib_name}_c PROPERTIES
    COMPILE_DEFINITIONS "${c_definitions}")

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

install(EXPORT ${PROJECT_NAME}-config DESTINATION ${CMAKE_INSTALL_PREFIX})
