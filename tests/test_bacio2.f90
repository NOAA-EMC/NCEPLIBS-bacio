! This is a test for the Fortran API of the NCEPLIBS-bacio library.
!
! Ed Hartnett 10/8/21
program test_bacio2
  use bacio_module
  implicit none

  character(len=15) :: filename = 'test_bacio2.bin'
  character (len = 4) :: data
  character (len = 4) :: data_in
  integer, parameter :: lots = 5000
  character (len = lots) :: lots_of_data
  integer :: lu = 1
  integer :: ka
  integer(kind=8) :: ka8
  integer :: stat
  integer :: iret

  print *, 'Testing bacio.'
  
  ! Delete the test file, if it remains from previous runs.
  open(unit = 1234, iostat = stat, file = filename, status='old')
  if (stat == 0) close(1234, status='delete')  

  print *, 'Testing simple wryte() calls - error messages are expected...'

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
  if (iret .ne. 0) stop 10

  ! Reopen the test file.
  call baopenr(lu, filename, iret)
  if (iret .ne. 0) stop 11

  ! Read some data.
  call baread(lu, 0, 4, ka, data_in)
  if (ka .ne. 4) stop 12
  if (data_in .ne. data) stop 13

  ! Close the test file.
  call baclose(lu, iret)
  if (iret .ne. 0) stop 14

  print *, 'Testing simple wrytel() calls - error messages are expected...'

  data = 'bill'
  
  ! Create a test file.
  call baopenwt(lu, filename, iret)
  if (iret .ne. 0) stop 100

  ! Try to write some data - won't work, does nothing due to negative size.
  call wryte(lu, -4, data)

  ! Write some data.
  call wryte(lu, 4, data)

  ! Close the test file.
  call baclose(lu, iret)
  if (iret .ne. 0) stop 101

  ! Reopen the test file.
  call baopenr(lu, filename, iret)
  if (iret .ne. 0) stop 102

  ! Read some data.
  call baread(lu, 0, 4, ka, data_in)
  if (ka .ne. 4) stop 103
  if (data_in .ne. data) stop 104

  ! Close the test file.
  call baclose(lu, iret)
  if (iret .ne. 0) stop 105

  print *, 'Testing buffered reads - error messages are expected...'

  ! Reopen the test file.
  call baopenr(lu, filename, iret)
  if (iret .ne. 0) stop 200

  ! Turn on buffered reads.
  call baseto(1, 1)

  ! Read some data.
  call baread(lu, 0, 4, ka, data_in)
  if (ka .ne. 4) stop 201
  if (data_in .ne. data) stop 202

  ! Close the test file.
  call baclose(lu, iret)
  if (iret .ne. 0) stop 203

  print *, 'Testing wryte() calls with negative seek - error messages are expected...'

  ! Turn off buffered reads.
  call baseto(1, 1)

  ! Initialize our data.
  data = 'joey'

  ! Without changing the lu, the test fails because read buffer
  ! contians previous results. See
  ! https://github.com/NOAA-EMC/NCEPLIBS-bacio/issues/65.
  lu = 2 

  ! Create a test file.
  call baopen(lu, filename, iret)
  if (iret .ne. 0) stop 300

  ! Write some data.
  call bawritel(lu, -1_8, 4_8, ka8, data)
  if (ka8 .ne. 4) stop 301

  ! Close the test file.
  call baclose(lu, iret)
  if (iret .ne. 0) stop 302

  ! Reopen the test file.
  call baopenr(lu, filename, iret)
  if (iret .ne. 0) stop 303

  ! Read some data.
  call baread(lu, 0, 4, ka, data_in)
  if (ka .ne. 4) stop 304
  if (data_in .ne. data) stop 305

  ! Close the test file.
  call baclose(lu, iret)
  if (iret .ne. 0) stop 306

  print *, 'Testing buffered with lots of data - error messages are expected...'

  lu = 3

  ! Create a test file for lots of data.
  call baopen(lu, filename, iret)
  if (iret .ne. 0) stop 300

  ! Write lots of data.
  call bawritel(lu, 0_8, 5000_8, ka8, lots_of_data)
  if (ka8 .ne. 5000) stop 301

  ! Close the test file.
  call baclose(lu, iret)
  if (iret .ne. 0) stop 302

  ! Reopen the test file.
  call baopenr(lu, filename, iret)
  if (iret .ne. 0) stop 200

  ! Turn on buffered reads.
  call baseto(1, 1)

  ! Read some data.
  call baread(lu, 0, 4, ka, data_in)
  if (ka .ne. 4) stop 201

  ! Read some more data.
  call baread(lu, 4092, 4, ka, data_in)
  if (ka .ne. 4) stop 201

  ! Close the test file.
  call baclose(lu, iret)
  if (iret .ne. 0) stop 203

  print *, 'SUCCESS!'
end program test_bacio2
