
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

set(fortran_src baciof.f bafrio.f chk_endianc.f)
set(c_src bacio.c byteswap.c)

# One target for real32 and one target for real64
set(kinds "4" "8")
foreach(kind ${kinds})
  set(lib_name ${PROJECT_NAME}_${kind})
  set(module_dir ${CMAKE_CURRENT_BINARY_DIR}/include_${kind})

  add_library(${lib_name}_f OBJECT ${fortran_src})
  set_target_properties(${lib_name}_f PROPERTIES COMPILE_FLAGS
    "${fortran_${kind}_flags}")
  set_target_properties(${lib_name}_f PROPERTIES Fortran_MODULE_DIRECTORY
    ${module_dir})

  add_library(${lib_name}_c OBJECT ${c_src})

  add_library(${lib_name} STATIC $<TARGET_OBJECTS:${lib_name}_f>
    $<TARGET_OBJECTS:${lib_name}_c>)
  target_include_directories(${lib_name} INTERFACE
    $<BUILD_INTERFACE:${module_dir}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_PREFIX}/include_${kind}>)
  list(APPEND LIB_TARGETS ${lib_name})
  install(DIRECTORY ${module_dir} DESTINATION ${CMAKE_INSTALL_PREFIX})
endforeach()

install(
  TARGETS ${LIB_TARGETS}
  EXPORT ${PROJECT_NAME}Exports
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib)

### Package config
include(CMakePackageConfigHelpers)
set(CONFIG_INSTALL_DESTINATION lib/cmake/${PROJECT_NAME})

export(EXPORT ${PROJECT_NAME}Exports
  NAMESPACE ${PROJECT_NAME}::
  FILE ${PROJECT_NAME}-targets.cmake)

# bacio-config.cmake
configure_package_config_file(
  ${CMAKE_SOURCE_DIR}/cmake/PackageConfig.cmake.in ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-config.cmake
  INSTALL_DESTINATION ${CONFIG_INSTALL_DESTINATION})
install(FILES ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-config.cmake
  DESTINATION ${CONFIG_INSTALL_DESTINATION})

# bacio-config-version.cmake
write_basic_package_version_file(
  ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY AnyNewerVersion)
install(FILES ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake
  DESTINATION ${CONFIG_INSTALL_DESTINATION})

# bacio-targets.cmake and bacio-targets-<build-type>.cmake
install(EXPORT ${PROJECT_NAME}Exports
  NAMESPACE ${PROJECT_NAME}::
  FILE ${PROJECT_NAME}-targets.cmake
  DESTINATION ${CONFIG_INSTALL_DESTINATION})
