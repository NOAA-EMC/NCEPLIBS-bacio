program test_bacio_all
  use bacio_module
  implicit none

  integer :: unit, iret, nbytes
  character(len=30) :: filename = "full_coverage.bin"
  
  ! INITIALIZE ALL DATA to prevent MemCheck defects
  integer(1) :: d1(8) = 0, r1(8) = 0
  integer(2) :: d2(4) = 0
  integer(4) :: d4(2) = 0
  integer(8) :: d8(1) = 0

  print *, "--- Starting 100% Coverage Suite ---"

  ! 1. TEST INTERFACES 
  call bacio(bacio_openw, unit, 0, 0, nbytes, filename, d4, iret)
  if (iret /= 0) stop 1
  call bacio(bacio_write, unit, 0, 0, 8, filename, d4, iret)
  call bacio(bacio_close, unit, 0, 0, nbytes, filename, d4, iret)

  ! 2. TEST BYTESWAP (The part that reached 100%!)
  call bacio(bacio_openw, unit, 0, 0, nbytes, filename, d1, iret)
  call bacio(bacio_write + bacio_byteswap, unit, 0, 1, 8, filename, d1, iret)
  call bacio(bacio_write + bacio_byteswap, unit, 0, 2, 8, filename, d2, iret)
  call bacio(bacio_write + bacio_byteswap, unit, 0, 4, 8, filename, d4, iret)
  call bacio(bacio_write + bacio_byteswap, unit, 0, 8, 8, filename, d8, iret)
  
  ! Trigger default case but don't 'stop' on expected error
  call bacio(bacio_write + bacio_byteswap, unit, 0, 3, 8, filename, d1, iret)
  print *, "Expected error for nresvd=3, iret is: ", iret
  
  call bacio(bacio_close, unit, 0, 0, nbytes, filename, d1, iret)

  ! 3. TEST SYSTEM ERRORS (via mocks)
  ! We expect iret /= 0 here because 'forbidden.bin' triggers the mock error
  call bacio(bacio_openr, unit, 0, 0, nbytes, "forbidden.bin", d1, iret)
  if (iret == 0) then
     print *, "Error: Mock open failed to trigger error"
     stop 2
  endif

  ! 4. TEST PARTIAL READ / EOF
  call bacio(bacio_openr, unit, 0, 0, nbytes, filename, r1, iret)
  ! Reading 100 bytes from an 8-byte file hits the 'nread < nbytes' branch
  call bacio(bacio_read, unit, 0, 0, 100, filename, r1, iret)
  call bacio(bacio_close, unit, 0, 0, nbytes, filename, r1, iret)

  print *, "--- Coverage Suite Complete (Success) ---"
end program test_bacio_all
