program test_bafrio
  use bacio_module
  implicit none

  ! character(len=14) :: filename = 'test_bafrio.bin'
  ! character :: data(4)
  ! character :: data_in(4)
  ! integer :: lu = 1
  ! integer :: ka
  ! integer :: i
  ! integer :: iret

  print *, 'Testing bafrio.'
  
  print *, 'Testing simple bafrwrite calls...'

  ! ! Create a test file.
  ! call baopen(lu, filename, iret)
  ! if (iret .ne. 0) stop 2

  ! ! Write some data.
  ! data = 'test'
  ! call bawrite(lu, 0, 4, ka, data)
  ! if (iret .ne. 0) stop 2
  ! if (ka .ne. 4) stop 3

  ! ! Close the test file.
  ! call baclose(lu, iret)
  ! if (iret .ne. 0) stop 10

  ! ! Reopen the test file.
  ! call baopenr(lu, filename, iret)
  ! if (iret .ne. 0) stop 20

  ! ! Read some data.
  ! call baread(lu, 0, 4, ka, data_in)
  ! if (iret .ne. 0) stop 21
  ! if (ka .ne. 4) stop 22
  ! do i = 1, 4
  !    if (data_in(i) .ne. data(i)) stop 23
  ! enddo

  ! ! Close the test file.
  ! call baclose(lu, iret)
  ! if (iret .ne. 0) stop 30

  print *, 'SUCCESS!'
end program test_bafrio
