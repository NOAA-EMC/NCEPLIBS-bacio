set(test_srcs test_bacio.pf)

add_pfunit_ctest (bacio_test
  TEST_SOURCES test_bacio_mod.pf
  LINK_LIBRARIES bacio_4_static
)
