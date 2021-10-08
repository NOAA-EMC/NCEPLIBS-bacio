program test_bacio
  use bacio_module
  implicit none

  character(len=14) :: filename = 'test_bacio.bin'
  character :: data(4)
  character :: data_in(4)
  integer :: lu = 1
  integer :: ka
  integer(kind=8) :: ka8, ib8, nb8, lu8
  integer :: i
  integer :: iret

  print *, 'Testing bacio.'
  
  print *, 'Testing simple baopen/baclose calls - error messages are expected...'

  ! Try to create a test file - won't work, bad lu.
  call baopen(0, filename, iret)
  if (iret .ne. 6) stop 1
  call baopen(FDDIM + 1, filename, iret)
  if (iret .ne. 6) stop 2

  ! Create a test file.
  call baopen(lu, filename, iret)
  if (iret .ne. 0) stop 3

  ! Try to write some data - won't work, negative size.
  call bawrite(lu, 0, -4, ka, data)
  if (ka .ne. 0) stop 4

  ! Write some data.
  data = 'test'
  call bawrite(lu, 0, 4, ka, data)
  if (ka .ne. 4) stop 5

  ! Try to close the test file - won't work, bad lu.
  call baclose(0, iret)
  if (iret .ne. 6) stop 10
  call baclose(FDDIM + 1, iret)
  if (iret .ne. 6) stop 10

  ! Close the test file.
  call baclose(lu, iret)
  if (iret .ne. 0) stop 10

  ! Try to reopen the test file - won't work, bad lu.
  call baopenr(0, filename, iret)
  if (iret .ne. 6) stop 20
  call baopenr(FDDIM + 1, filename, iret)
  if (iret .ne. 6) stop 21

  ! Reopen the test file.
  call baopenr(lu, filename, iret)
  if (iret .ne. 0) stop 22

  ! Try to read some data - won't work, negative size.
  call baread(lu, 0, -4, ka, data_in)
  if (ka .ne. 0) stop 23

  ! Read some data.
  call baread(lu, 0, 4, ka, data_in)
  if (ka .ne. 4) stop 31
  do i = 1, 4
     if (data_in(i) .ne. data(i)) stop 32
  enddo

  ! Reread with l function.
  ib8 = 0
  nb8 = 4
  call bareadl(lu, ib8, nb8, ka8, data_in)
  if (ka8 .ne. 4) stop 33
  do i = 1, 4
     if (data_in(i) .ne. data(i)) stop 34
  enddo

  ! Try to reread with l function - won't work, negative bytes to skip.
  call bareadl(lu, -1_8, nb8, ka8, data_in)
  if (ka8 .ne. 0) stop 33

  ! Try to reread with l function - won't work, negative bytes to read.
  call bareadl(lu, ib8, -1_8, ka8, data_in)
  if (ka8 .ne. 0) stop 33

  ! Try to reread with l function - won't work, bad lu. These cause
  ! address santizer failures. See
  ! https://github.com/NOAA-EMC/NCEPLIBS-bacio/issues/64.
  ! call bareadl(0, ib8, nb8, ka8, data_in)
  ! if (ka8 .ne. 0) stop 32
  ! call bareadl(FDDIM + 1, ib8, nb8, ka8, data_in)
  ! if (ka8 .ne. 0) stop 32

  ! Close the test file.
  call baclose(lu, iret)
  if (iret .ne. 0) stop 40

  ! Reopen the test file for writing.
  call baopenw(lu, filename, iret)
  if (iret .ne. 0) stop 50

  ! Close the test file.
  call baclose(lu, iret)
  if (iret .ne. 0) stop 60


  print *, 'SUCCESS!'
end program test_bacio
