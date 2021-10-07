# This is the CMakeFile for the tests directory of the NCEPLIBS-bacio
# project.
#
# Kyle Gerheiser, Ed Hartnett

add_executable(test_bacio test_bacio.f90)
target_link_libraries(test_bacio bacio_4)
add_test(test_bacio test_bacio)

function(c_test name)
  add_executable(${name} ${name}.c)
  add_dependencies(${name} bacio_4)
  target_include_directories(${name} PRIVATE ${CMAKE_SOURCE_DIR}/src)
  target_link_libraries(${name} PRIVATE bacio_4)
  add_test(NAME ${name} COMMAND ${name})
endfunction()

c_test(test_bacio_c)

add_executable(test_bafrio test_bafrio.f90)
target_link_libraries(test_bafrio bacio_4)
add_test(test_bafrio test_bafrio)


