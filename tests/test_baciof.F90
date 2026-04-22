program test_baciof
  use bacio_module
  implicit none

  integer :: unit, iret, nbytes, i
  integer(4) :: data4(10), read4(10)
  integer(2) :: data2(10), read2(10)
  integer(8) :: data8(5), read8(5)
  character(len=20) :: filename = "test_coverage.bin"

  ! --- 1. Test 4-byte Swapping (Standard) ---
  data4 = [(i*1111, i=1,10)]
  nbytes = 40
  call bacio(bacio_openw, unit, 0, 0, nbytes, filename, data4, iret)
  ! nresvd=4 triggers 4-byte swapping
  call bacio(bacio_write + bacio_byteswap, unit, 0, 4, nbytes, filename, data4, iret)
  call bacio(bacio_close, unit, 0, 0, nbytes, filename, data4, iret)

  ! --- 2. Test 8-byte Swapping (Covers byteswap.c 64-bit paths) ---
  data8 = [z'0102030405060708', z'1122334455667788', z'0', z'1', z'99']
  nbytes = 40
  call bacio(bacio_openw, unit, 0, 0, nbytes, filename, data8, iret)
  ! nresvd=8 triggers 8-byte swapping
  call bacio(bacio_write + bacio_byteswap, unit, 0, 8, nbytes, filename, data8, iret)
  call bacio(bacio_close, unit, 0, 0, nbytes, filename, data8, iret)

  ! --- 3. Test 2-byte Swapping (Covers byteswap.c 16-bit paths) ---
  data2 = [(i, i=1,10)]
  nbytes = 20
  call bacio(bacio_openw, unit, 0, 0, nbytes, filename, data2, iret)
  ! nresvd=2 triggers 2-byte swapping
  call bacio(bacio_write + bacio_byteswap, unit, 0, 2, nbytes, filename, data2, iret)
  call bacio(bacio_close, unit, 0, 0, nbytes, filename, data2, iret)

  ! --- 4. Trigger Error Paths (Covers bacio.c error branches) ---
  
  ! Attempt to read a non-existent file (Covers 'open' failure)
  call bacio(bacio_openr, unit, 0, 0, nbytes, "ghost_file.bin", data4, iret)
  if (iret == 0) print *, "Warning: Open failure path not triggered"

  ! Attempt to write with an invalid unit (Covers 'write' failure)
  ! We use a unit number that was never opened
  call bacio(bacio_write, 999, 0, 0, nbytes, filename, data4, iret)

  ! Seek to an invalid negative offset (Covers 'lseek' failure)
  call bacio(bacio_openr, unit, 0, 0, nbytes, filename, data4, iret)
  call bacio(bacio_seek, unit, -100, 0, nbytes, filename, data4, iret)
  call bacio(bacio_close, unit, 0, 0, nbytes, filename, data4, iret)

  ! --- 5. Zero-byte Operation (Covers optimization branches) ---
  nbytes = 0
  call bacio(bacio_openw, unit, 0, 0, nbytes, filename, data4, iret)
  call bacio(bacio_write, unit, 0, 0, nbytes, filename, data4, iret)
  call bacio(bacio_close, unit, 0, 0, nbytes, filename, data4, iret)

  print *, "Comprehensive Coverage Test Completed."
end program test_baciof
