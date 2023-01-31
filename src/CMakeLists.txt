# This is the CMake file for the src directory of the NCEPLIBS-bacio
# project.
#
# Kyle Gerheiser, Ed Hartnett

add_compile_definitions(UNDERSCORE)
if(APPLE)
  add_compile_definitions(APPLE)
elseif(UNIX)
  add_compile_definitions(LINUX)
endif()

# This is the Fortran source code.
set(fortran_src baciof.F90 bafrio.F90 chk_endianc.F90)

# This is the C source code.
set(c_src bacio.c byteswap.c)

set(lib_name ${PROJECT_NAME})
set(module_dir ${CMAKE_CURRENT_BINARY_DIR}/include)

# Build Fortran code.
add_library(${lib_name}_f OBJECT ${fortran_src})
set_target_properties(${lib_name}_f PROPERTIES COMPILE_FLAGS "${fortran_4_flags}")
set_target_properties(${lib_name}_f PROPERTIES Fortran_MODULE_DIRECTORY
  ${module_dir})

# Build C code.
add_library(${lib_name}_c OBJECT ${c_src})

# For shared, add fPIC.
if(BUILD_SHARED_LIBS)
  set_property(TARGET ${lib_name}_f PROPERTY POSITION_INDEPENDENT_CODE 1)
  set_property(TARGET ${lib_name}_c PROPERTY POSITION_INDEPENDENT_CODE 1)
endif()

# Create library with both Fortran and C code.
add_library(${lib_name} $<TARGET_OBJECTS:${lib_name}_f>
  $<TARGET_OBJECTS:${lib_name}_c>)

# For shared, set SOVERSION; increment it if API changes (other than
# adding new functions).
if(BUILD_SHARED_LIBS)
  set_target_properties(${lib_name} PROPERTIES SOVERSION 0)
endif()

target_include_directories(${lib_name} INTERFACE
  $<BUILD_INTERFACE:${module_dir}>
  $<INSTALL_INTERFACE:include>)
list(APPEND LIB_TARGETS ${lib_name})
install(DIRECTORY ${module_dir} DESTINATION ${CMAKE_INSTALL_PREFIX})

# Set up install.
install(
  TARGETS ${LIB_TARGETS}
  EXPORT ${PROJECT_NAME}Exports
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})

### Package config
include(CMakePackageConfigHelpers)
set(CONFIG_INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})

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
