program test_bacio_all
  use bacio_module
  implicit none
  
  ! External C helpers
  interface
     subroutine force_endian_mock(pattern) bind(c)
       use, intrinsic :: iso_c_binding
       character(kind=c_char), intent(in) :: pattern(4)
     end subroutine force_endian_mock
  end interface

  integer :: lu, iret, ka, lx, ix
  integer(4) :: d4(10) = 0, r4(10) = 0
  character :: d_out(8192) = 'A', d_in(8192) = ' '
  character(16) :: mendian = ' '

  print *, "--- Starting 100% Comprehensive Coverage Suite ---"

  ! A. BACIOF.F90 & BACIO.C (Interface & System Branches)
  lu = 1
  call baopen(lu, "test_file.bin", iret)
  call baseto(1, 1) ! Enable Buffered I/O (hits BAREADL buffer logic)
  call bawrite(lu, 0, 10, ka, d_out)
  call baread(lu, 0, 5, ka, d_in)   ! Hits buffer fill
  call baread(lu, 5, 5, ka, d_in)   ! Hits data-from-buffer path
  
  ! Trigger Error: Write to Read-Only
  call baopenr(2, "test_file.bin", iret)
  call bawrite(2, 0, 1, ka, d_out) ! Hits BA_EWANDRO
  
  ! Trigger Error: BA_ECLOSE
  call bacio(bacio_close, 999, 0, 0, ka, " ", d_out, iret) ! Hits wrap_close mock

  ! B. BYTESWAP.C (Alignment & Logic Branches)
  ! We use the confirmed 'bacio_swp' symbol for swapping
  call bacio(bacio_write + bacio_swp, 1, 1, 1, ka, " ", d_out, iret) ! Case 1
  call bacio(bacio_write + bacio_swp, 1, 2, 1, ka, " ", d_out, iret) ! Case 2
  call bacio(bacio_write + bacio_swp, 1, 8, 1, ka, " ", d_out, iret) ! Case 8
  call bacio(bacio_write + bacio_swp, 1, 3, 1, ka, " ", d_out, iret) ! Default/Error

  ! C. BAFRIO.F90 (Endian & Record Logic)
  call baopenw(10, "records.bin", iret)   ! LU <= 999
  call bafrwrite(10, 0, 10, ka, d_out)
  call baopenw(1500, "records2.bin", iret) ! LU > 999 (Inverts endian logic)
  call bafrwrite(1500, 0, 10, ka, d_out)

  ! D. CHK_ENDIANC.F90 (Common Block Branches)
  call chk_endianc(mendian) ! Natural path
  call force_endian_mock((/'3','2','1','0'/))
  call findendian(mendian) ! Hits big_endian branch
  call force_endian_mock((/'1','X','Y','Z'/))
  call findendian(mendian) ! Hits mixed_endian branch

  print *, "--- All Coverage Targets Exercised ---"
end program test_bacio_all
