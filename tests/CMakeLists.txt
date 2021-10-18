# This is the CMakeFile for the tests directory of the NCEPLIBS-bacio
# project.
#
# Kyle Gerheiser, Ed Hartnett

add_executable(test_bacio test_bacio.f90)
target_link_libraries(test_bacio bacio)
add_test(test_bacio test_bacio)
add_executable(test_bacio2 test_bacio2.f90)
target_link_libraries(test_bacio2 bacio)
add_test(test_bacio2 test_bacio2)

function(c_test name)
  add_executable(${name} ${name}.c)
  add_dependencies(${name} bacio)
  target_include_directories(${name} PRIVATE ${CMAKE_SOURCE_DIR}/src)
  target_link_libraries(${name} PRIVATE bacio)
  add_test(NAME ${name} COMMAND ${name})
endfunction()

c_test(test_bacio_c)
c_test(test_byteswap)

add_executable(test_bafrio test_bafrio.f90)
target_link_libraries(test_bafrio bacio)
add_test(test_bafrio test_bafrio)


