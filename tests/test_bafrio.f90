! This is a test program for the NCEPLIBS-bacio library. It tests the
! formatted file functionality of bacio.
!
! Ed Hartnett 10/6/21
program test_bafrio
  use bacio_module
  implicit none

  character(len=15) :: filename = 'test_bafrio.bin'
  character (len = 4) :: data
  character (len = 4) :: data_in
  integer :: lu = 1
  integer :: ka
  integer (kind = 8) :: ib8, lx8, ix8
  integer :: iret

  print *, 'Testing bafrio.'
  
  print *, 'Testing simple bafrwrite calls...'

  ! Create a test file.
  call baopen(lu, filename, iret)
  if (iret .ne. 0) stop 2

  data = 'test'

  ! Try to write some data - will fail.
  call bafrwrite(lu, -2, 4, ka, data)
  if (ka .ne. 0) stop 3
  call bafrwrite(lu, 0, -4, ka, data)
  if (ka .ne. 0) stop 3

  ! Write some data.
  call bafrwrite(lu, 0, 4, ka, data)
  if (ka .ne. 12) stop 3

  ! Close the test file.
  call baclose(lu, iret)
  if (iret .ne. 0) stop 10

  ! Reopen the test file.
  call baopenr(lu, filename, iret)
  if (iret .ne. 0) stop 20

  ! Try to read some data with bad start byte.
  call bafrread(lu, -2, 4, ka, data_in)
  if (ka .ne. 0) stop 21

  ! Try to read some data with length.
  call bafrread(lu, 0, -4, ka, data_in)
  if (ka .ne. 0) stop 22

  ! Read some data.
  call bafrread(lu, 0, 4, ka, data_in)
  if (ka .ne. 12) stop 23
  if (data_in .ne. data) stop 24

  ! Close the test file.
  call baclose(lu, iret)
  if (iret .ne. 0) stop 30

  print *, 'Testing bafrindex calls...'

  ! Open the test file.
  call baopen(lu, filename, iret)
  if (iret .ne. 0) stop 100

  ! Check record length.
  ib8 = 0
  lx8 = 0
  call bafrindex(lu, ib8, lx8, ix8)
  if (ix8 .ne. 12) then
     print *, ix8
     stop 110
  end if
  
  ! Close the test file.
  call baclose(lu, iret)
  if (iret .ne. 0) stop 120

  print *, 'Testing bafrindex calls with large lu...'

  ! Open the test file.
  lu = 1999
  call baopen(lu, filename, iret)
  if (iret .ne. 0) stop 130

  ! Check record length.
  ib8 = 0
  lx8 = 0
  call bafrindex(lu, ib8, lx8, ix8)
  print *, ix8
!  if (ix8 .ne. 1344903776) stop 110  
  
  ! Close the test file.
  call baclose(lu, iret)
  if (iret .ne. 0) stop 140

  print *, 'SUCCESS!'
end program test_bafrio
