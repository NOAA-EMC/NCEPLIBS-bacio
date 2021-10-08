! This is a test for the Fortran API of the NCEPLIBS-bacio library.
!
! Ed Hartnett 10/8/21
program test_bacio2
  use bacio_module
  implicit none

  character(len=14) :: filename = 'test_bacio2.bin'
  character (len = 4) :: data
  character (len = 4) :: new_data
  character (len = 4) :: data_in
  character (len = 8) :: data_in_2
  character (len = 12) :: data_in_3
  integer :: lu = 1
  integer :: ka
  integer(kind=8) :: ka8, ib8, nb8, lu8
  integer :: stat
  integer :: iret

  print *, 'Testing bacio.'
  
  print *, 'Testing simple wryte() calls - error messages are expected...'

  ! Delete the test file, if it remains from previous runs.
  open(unit = 1234, iostat = stat, file = filename, status='old')
  if (stat == 0) close(1234, status='delete')  

  ! Initialize our data.
  data = 'fred'

  ! Create a test file.
  call baopen(lu, filename, iret)
  if (iret .ne. 0) stop 3

  ! Try to write some data - won't work, does nothing due to negative size.
  call wrytel(lu, -4_8, data)

  ! Write some data.
  call wrytel(lu, 4_8, data)

  ! Close the test file.
  call baclose(lu, iret)
  if (iret .ne. 0) stop 12

  ! Reopen the test file.
  call baopenr(lu, filename, iret)
  if (iret .ne. 0) stop 22

  ! Read some data.
  call baread(lu, 0, 4, ka, data_in)
  if (ka .ne. 4) stop 31
  if (data_in .ne. data) stop 32

  ! Close the test file.
  call baclose(lu, iret)
  if (iret .ne. 0) stop 40

  print *, 'Testing simple wrytel() calls - error messages are expected...'

  data = 'bill'
  
  ! Create a test file.
  call baopenwt(lu, filename, iret)
  if (iret .ne. 0) stop 3

  ! Try to write some data - won't work, does nothing due to negative size.
  call wryte(lu, -4, data)

  ! Write some data.
  call wryte(lu, 4, data)

  ! Close the test file.
  call baclose(lu, iret)
  if (iret .ne. 0) stop 12

  ! Reopen the test file.
  call baopenr(lu, filename, iret)
  if (iret .ne. 0) stop 22

  ! Read some data.
  call baread(lu, 0, 4, ka, data_in)
  if (ka .ne. 4) stop 31
  if (data_in .ne. data) stop 32

  ! Close the test file.
  call baclose(lu, iret)
  if (iret .ne. 0) stop 40

  print *, 'SUCCESS!'
end program test_bacio2
