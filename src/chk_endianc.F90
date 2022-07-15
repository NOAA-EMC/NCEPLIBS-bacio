!> @file
!> Find endianness of files on a machine.
!> @author J. Wang @date Aug, 2012

!> Obtain machine endianness.
!>
!> @param mendian character(16) machine endianness
!>
!> @author J. Wang @date Aug, 2012
subroutine chk_endianc(mendian)
  implicit none
  character(16),intent(out)  :: mendian
  INTEGER,PARAMETER :: ASCII_0 = 48,ASCII_1 = 49,ASCII_2 = 50,    &
       ASCII_3 = 51
  INTEGER(4) :: I
  common// I

  I = ASCII_0 + ASCII_1*256 + ASCII_2*(256**2) + ASCII_3*(256**3)
  call findendian(mendian)
end subroutine chk_endianc

!> Obtain machine endianness.
!>
!> @param mendian character(16) machine endianness
!>
!> @author J. Wang @date Aug, 2012
subroutine findendian(mendian)
  implicit none
  character(16),intent(out)        :: mendian
  character :: i*4
  common//  i

  if(i .eq. '0123') then
     mendian='little_endian'
     return
  elseif (i .eq. '3210') then
     mendian='big_endian'
     return
  else
     mendian='mixed_endian'
     return
  endif
end subroutine findendian
