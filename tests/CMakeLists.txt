set(test_srcs test_bacio.pf)

if(TARGET bacio_4_static)
  set(bacio_lib bacio_4_static)
else()
  set(bacio_lib bacio_4_shared)
endif()


add_pfunit_ctest (bacio_test
  TEST_SOURCES test_bacio_mod.pf
  LINK_LIBRARIES ${bacio_lib}
)
