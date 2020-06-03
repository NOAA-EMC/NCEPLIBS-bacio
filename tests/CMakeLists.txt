set(test_srcs test_bacio.pf)

if(BUILD_STATIC_LIBS)
  set(bacio_lib bacio_4_static)
else()
  set(bacio_lib bacio_4_shared)
endif()

add_pfunit_ctest (bacio_test
  TEST_SOURCES test_bacio_mod.pf
  LINK_LIBRARIES ${bacio_lib}
)
