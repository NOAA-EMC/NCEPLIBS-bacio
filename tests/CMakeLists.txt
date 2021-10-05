# This is the CMakeFile for the tests directory of the NCEPLIBS-bacio
# project.
#
# Kyle Gerheiser, Ed Hartnett

add_executable(test_bacio test_bacio.f90)
target_link_libraries(test_bacio bacio_4)
add_test(test_bacio test_bacio)

