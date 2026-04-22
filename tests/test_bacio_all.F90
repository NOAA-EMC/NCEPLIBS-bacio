program test_bacio_all
  use bacio_module
  implicit none

  integer :: unit, iret, nbytes, i
  character(len=30) :: filename = "full_coverage.bin"
  
  ! Data buffers for various word sizes
  integer(1) :: d1(8) = [1,2,3,4,5,6,7,8]
  integer(2) :: d2(4) = [z'0102', z'0304', z'0506', z'0708']
  integer(4) :: d4(2) = [z'01020304', z'05060708']
  integer(8) :: d8(1) = [z'0102030405060708']

  print *, "--- Starting 100% Coverage Suite ---"

  ! 1. TEST INTERFACES (baciof.F90 & bacio.v1.1.c modes)
  call bacio(bacio_openw, unit, 0, 0, nbytes, filename, d4, iret)  ! Open Write
  call bacio(bacio_write, unit, 0, 0, 8, filename, d4, iret)       ! Write
  call bacio(bacio_close, unit, 0, 0, nbytes, filename, d4, iret)  ! Close

  call bacio(bacio_openro, unit, 0, 0, nbytes, filename, d4, iret) ! Open Read-Only
  call bacio(bacio_close, unit, 0, 0, nbytes, filename, d4, iret)

  call bacio(bacio_openrw, unit, 0, 0, nbytes, filename, d4, iret) ! Open Read-Write
  call bacio(bacio_seek, unit, 0, 0, nbytes, filename, d4, iret)   ! Seek current (optimization)
  call bacio(bacio_close, unit, 0, 0, nbytes, filename, d4, iret)

  call bacio(bacio_openwa, unit, 0, 0, nbytes, filename, d4, iret) ! Open Append
  call bacio(bacio_close, unit, 0, 0, nbytes, filename, d4, iret)

  ! 2. TEST BYTESWAP (byteswap.c - Every case)
  call bacio(bacio_openw, unit, 0, 0, nbytes, filename, d1, iret)
  call bacio(bacio_write + bacio_byteswap, unit, 0, 1, 8, filename, d1, iret) ! Case 1
  call bacio(bacio_write + bacio_byteswap, unit, 0, 2, 8, filename, d2, iret) ! Case 2
  call bacio(bacio_write + bacio_byteswap, unit, 0, 4, 8, filename, d4, iret) ! Case 4
  call bacio(bacio_write + bacio_byteswap, unit, 0, 8, 8, filename, d8, iret) ! Case 8
  call bacio(bacio_write + bacio_byteswap, unit, 0, 3, 8, filename, d1, iret) ! Default (Error)
  call bacio(bacio_close, unit, 0, 0, nbytes, filename, d1, iret)

  ! 3. TEST ERROR BRANCHES (bacio.c via mock_sys.c)
  call bacio(bacio_openr, unit, 0, 0, nbytes, "forbidden.bin", d1, iret) ! Open fail
  
  call bacio(bacio_openw, unit, 0, 0, nbytes, filename, d1, iret)
  call bacio(bacio_seek, unit, -9999, 0, nbytes, filename, d1, iret)     ! Seek fail
  call bacio(bacio_write, unit, 0, 0, 8, filename, d1, iret)            ! Triggers Mock EINTR
  call bacio(bacio_close, unit, 0, 0, nbytes, filename, d1, iret)

  ! 4. EDGE CASES
  call bacio(bacio_openr, unit, 0, 0, nbytes, filename, d1, iret)
  call bacio(bacio_read, unit, 0, 0, 0, filename, d1, iret)             ! 0-byte read
  call bacio(bacio_read, unit, 0, 0, 100, filename, d1, iret)           ! Partial read (EOF)
  call bacio(bacio_close, unit, 0, 0, nbytes, filename, d1, iret)

  print *, "--- Coverage Suite Complete ---"
end program test_bacio_all
