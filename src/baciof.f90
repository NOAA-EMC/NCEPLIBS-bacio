!> @file
!> @brief Contains subroutines to read/write binary files.
!> @author Mark Iredell @date 98-06-04

!> @brief Contains subroutines to read/write binary files.
!>
!> This is a module to do binary file I/O.
!>
!> @author Mark Iredell @date 98-06-04
MODULE BACIO_MODULE

  !> The bacio function in the C code.
  INTEGER,EXTERNAL:: BACIO

  !> The baciol function in the C code.
  INTEGER,EXTERNAL:: BACIOL

  !> Maximum number of open files in bacio library.
  INTEGER,PARAMETER :: FDDIM = 9999

  !> Array IDs of currently open files.
  INTEGER,DIMENSION(FDDIM),SAVE:: FD = FDDIM*0

  !> Array of option settings. Only the first element of the array
  !> is used.
  INTEGER,DIMENSION(20),SAVE:: BAOPTS = 0

  INTEGER,PARAMETER:: BACIO_OPENR = 1    !< Open file for read only.
  INTEGER,PARAMETER:: BACIO_OPENW = 2    !< Open file for write only.
  INTEGER,PARAMETER:: BACIO_OPENRW = 4   !< Open file for read or write.
  INTEGER,PARAMETER:: BACIO_CLOSE = 8    !< Close file.
  INTEGER,PARAMETER:: BACIO_READ = 16    !< Read from the file.
  INTEGER,PARAMETER:: BACIO_WRITE = 32   !< Write to the file.
  INTEGER,PARAMETER:: BACIO_NOSEEK = 64  !< Start I/O from previous spot.
  INTEGER,PARAMETER:: BACIO_OPENWT = 128 !< Open for write only with truncation.
  INTEGER,PARAMETER:: BACIO_OPENWA = 256 !< Open for write only with append.
END MODULE BACIO_MODULE

!> Set options for byte-addressable I/O. (There is currently only one
!> valid option.)
!>
!> All options default to 0.
!>
!> Option 1: Blocked reading option:
!>
!> If the option value is 1, then the reading is blocked into four
!> 4096-byte buffers. This may be efficient if the reads will be
!> requested in much smaller chunks.  otherwise, each call to baread
!> initiates a physical read.
!>
!> @param nopt option number.
!> @param vopt option value.
!>
!> @author Mark Iredell @date 98-06-04
SUBROUTINE BASETO(NOPT, VOPT)
  USE BACIO_MODULE
  IMPLICIT NONE
  INTEGER NOPT, VOPT

  IF (NOPT .GE. 1 .AND. NOPT .LE. 20) BAOPTS(NOPT) = VOPT
END SUBROUTINE BASETO

!> Open a byte-addressable file.
!>
!> @param lu unit to open.
!> @param cfn filename to open (consisting of nonblank
!> printable characters).
!> @param iret return code
!>
!> @author Mark Iredell @date 98-06-04
SUBROUTINE BAOPEN(LU, CFN, IRET)
  USE BACIO_MODULE
  IMPLICIT NONE
  INTEGER, intent(in) :: LU
  CHARACTER, intent(in) :: CFN*(*)
  INTEGER, intent(out) :: IRET
  integer(kind=8) IB, JB, NB, KA
  CHARACTER :: A(1)

  IF (LU .LT. 001 .OR. LU .GT. FDDIM) THEN
     IRET = 6
     RETURN
  ENDIF

  IRET = BACIOL(BACIO_OPENRW, IB, JB, 1, NB, KA, FD(LU), CFN, A)
END SUBROUTINE BAOPEN

!> Open a byte-addressable file for read only.
!>
!> @param lu unit to open.
!> @param cfn filename to open (consisting of nonblank
!> printable characters).
!> @param iret return code.
!>
!> @author Mark Iredell @date 98-06-04
SUBROUTINE BAOPENR(LU, CFN, IRET)
  USE BACIO_MODULE
  IMPLICIT NONE
  INTEGER, intent(in) :: LU
  CHARACTER, intent(in) :: CFN*(*)
  INTEGER, intent(out) :: IRET
  integer(kind=8) IB, JB, NB, KA
  CHARACTER :: A(1)

  IF (LU .LT. 001 .OR. LU .GT. FDDIM) THEN
     IRET = 6
     RETURN
  ENDIF

  IRET = BACIOL(BACIO_OPENR, IB, JB, 1, NB, KA, FD(LU), CFN, A)
END SUBROUTINE BAOPENR

!> Open a byte-addressable file for write only.
!>
!> @param lu unit to open.
!> @param cfn filename to open (consisting of nonblank
!> printable characters).
!> @param iret return code.
!>
!> @author Mark Iredell @date 98-06-04
SUBROUTINE BAOPENW(LU, CFN, IRET)
  USE BACIO_MODULE
  IMPLICIT NONE
  INTEGER, intent(in) :: LU
  CHARACTER, intent(in) :: CFN*(*)
  INTEGER, intent(out) :: IRET
  integer(kind=8) IB,JB,NB,KA
  CHARACTER :: A(1)

  IF (LU .LT. 001 .OR. LU .GT. FDDIM) THEN
     IRET = 6
     RETURN
  ENDIF

  IRET = BACIOL(BACIO_OPENW, IB, JB, 1, NB, KA, FD(LU), CFN, A)
END SUBROUTINE BAOPENW

!> Open a byte-addressable file for write only with truncation.
!>
!> @param lu unit to open.
!> @param cfn filename to open (consisting of nonblank
!> printable characters).
!> @param iret return code.
!>
!> @author Mark Iredell @date 98-06-04
SUBROUTINE BAOPENWT(LU, CFN, IRET)
  USE BACIO_MODULE
  IMPLICIT NONE
  INTEGER, intent(in) :: LU
  CHARACTER, intent(in) :: CFN*(*)
  INTEGER, intent(out) :: IRET
  integer(kind=8) IB,JB,NB,KA
  CHARACTER :: A(1)

  IF (LU .LT. 001 .OR. LU .GT. FDDIM) THEN
     IRET = 6
     RETURN
  ENDIF

  IRET = BACIOL(BACIO_OPENWT, IB, JB, 1, NB, KA, FD(LU), CFN, A)
END SUBROUTINE BAOPENWT

!> Open a byte-addressable file for write only with append.
!>
!> @param lu unit to open.
!> @param cfn filename to open (consisting of nonblank
!> printable characters).
!> @param iret return code.
!>
!> @author Mark Iredell @date 98-06-04
SUBROUTINE BAOPENWA(LU, CFN, IRET)
  USE BACIO_MODULE
  IMPLICIT NONE
  INTEGER, intent(in) :: LU
  CHARACTER, intent(in) :: CFN*(*)
  INTEGER, intent(out) :: IRET
  integer(kind=8) IB,JB,NB,KA
  CHARACTER :: A(1)

  IF (LU .LT. 001 .OR. LU .GT. FDDIM) THEN
     IRET = 6
     RETURN
  ENDIF

  IRET = BACIOL(BACIO_OPENWA, IB, JB, 1, NB, KA, FD(LU), CFN, A)
END SUBROUTINE BAOPENWA

!> Close a byte-addressable file.
!>
!> @param lu unit to close.
!> @param iret return code.
!>
!> @author Mark Iredell @date 98-06-04
SUBROUTINE BACLOSE(LU, IRET)
  USE BACIO_MODULE
  IMPLICIT NONE
  INTEGER, intent(in) :: LU
  INTEGER, intent(out) :: IRET
  integer(kind=8) IB, JB, NB, KA
  CHARACTER :: A(1)

  IF (LU .LT. 001 .OR. LU .GT. FDDIM) THEN
     IRET = 6
     RETURN
  ENDIF

  IRET = BACIOL(BACIO_CLOSE, IB, JB, 1, NB, KA, FD(LU), CHAR(0), A)
  IF (IRET .EQ. 0) FD(LU) = 0
END SUBROUTINE BACLOSE

!> This subroutine calls bareadl() to read a given number of
!> bytes from an unblocked file, skipping a given number of bytes.
!>
!> The physical I/O is blocked into four 4096-byte buffers if the
!> byte-addressable option 1 has been set to 1 by baseto. This
!> buffered reading is incompatible with no-seek reading.
!>
!> @note The data in the I/O buffer is not cleared when the file is
!> closed and reopened, or when any other operation on the file is
!> done. So it may contian out-of-date data, if the data file has been
!> changed after the buffers were filled. Use with caution.
!>
!> ### Program History Log
!> Date | Programmer | Comments
!> -----|------------|---------
!> 1998-06-04 | Mark Iredell | Initial.
!> 2009-04-20 | Jun Wang | Modifications.
!>
!> @param lu unit to read.
!> @param ib number of bytes to skip. (If ib<0, then the file
!> is accessed with no seeking)
!> @param nb number of bytes to read.
!> @param ka number of bytes actually read.
!> @param a Buffer where data are copied to from file. Must be of
!> sufficient size to hold data.
!>
!> @note A baopen() must have already been called.
!>
!> @author Mark Iredell @date 98-06-04
SUBROUTINE BAREAD(LU, IB, NB, KA, A)
  IMPLICIT NONE
  INTEGER,INTENT(IN) :: LU, IB, NB
  INTEGER,INTENT(OUT) :: KA
  CHARACTER,INTENT(OUT) :: A(NB)
  INTEGER(KIND=8) :: LONG_IB, LONG_NB, LONG_KA

  if (NB < 0) THEN
     print *,'WRONG: in BAREAD read data size NB < 0, STOP! '//&
          'Consider using BAREADL and long integer'
     KA = 0
     return
  ENDIF
  LONG_IB = IB
  LONG_NB = NB
  CALL BAREADL(LU, LONG_IB, LONG_NB, LONG_KA, A)
  KA = INT(LONG_KA)
END SUBROUTINE BAREAD

!> This subrouytine is using updated baciol() I/O package to read a
!> given number of bytes from an unblocked file, skipping a given
!> number of bytes.
!>
!> The physical I/O is blocked into four 4096-byte buffers if the
!> byte-addressable option 1 has been set to 1 by baseto. This
!> buffered reading is incompatible with no-seek reading.
!>
!> @note The data in the I/O buffer is not cleared when the file is
!> closed and reopened, or when any other operation on the file is
!> done. So it may contian out-of-date data, if the data file has been
!> changed after the buffers were filled. Use with caution.
!>
!> ### Program History Log
!> Date | Programmer | Comments
!> -----|------------|---------
!> 1998-06-04 | Mark Iredell | Initial.
!> 2009-04-20 | Jun Wang | Modifications.
!>
!> @param[in] lu unit to read.
!> @param[in] ib number of bytes to skip (if ib<0, then the
!> file is accessed with no seeking).
!> @param[in] nb number of bytes to read.
!> @param[out] ka number of bytes actually read.
!> @param[out] a Buffer where data are copied to from file. Must be of
!> sufficient size to hold data.
!>
!> @note A baopen() must have already been called.
!>
!> @author Mark Iredell @date 98-06-04
SUBROUTINE BAREADL(LU, IB, NB, KA, A)
  USE BACIO_MODULE
  IMPLICIT NONE
  INTEGER, intent(in) :: LU
  INTEGER(kind=8), intent(in) :: IB,NB
  INTEGER(kind=8), intent(out) :: KA
  CHARACTER, intent(out) :: A(NB)
  integer(kind=8), PARAMETER :: NY=4096, MY=4
  INTEGER(KIND=8) NS(MY), NN(MY)
  INTEGER(kind=8) JB, LONG_0, KY, I, K, IY, JY, LUX
  INTEGER IRET
  CHARACTER Y(NY, MY)
  DATA LUX/0/
  SAVE JY, NS, NN, Y, LUX

  IF (LU .LT. 001 .OR. LU .GT. FDDIM) THEN
     KA = 0
     RETURN
  ENDIF
  IF (FD(LU) .LE. 0) THEN
     KA = 0
     RETURN
  ENDIF
  IF (IB .LT. 0 .AND. BAOPTS(1) .EQ. 1) THEN
     KA = 0
     RETURN
  ENDIF
  IF (NB .LE. 0) THEN
     KA = 0
     RETURN
  ENDIF

  LONG_0 = 0

  !  UNBUFFERED I/O
  IF (BAOPTS(1) .NE. 1) THEN
     KA = 0
     IF (IB .GE. 0) THEN
        IRET = BACIOL(BACIO_READ, IB, JB, 1, NB, KA, FD(LU), CHAR(0), A)
     ELSE
        IRET = BACIOL(BACIO_READ + BACIO_NOSEEK, LONG_0, JB, 1, NB, KA,&
             FD(LU), CHAR(0), A)
     ENDIF

     !  BUFFERED I/O
     !  GET DATA FROM PREVIOUS CALL IF POSSIBLE
  ELSE
     KA = 0
     IF (LUX .NE. LU) THEN
        JY = 0
        NS = 0
        NN = 0
     ELSE
        DO I = 1, MY
           IY = MOD(JY + I - 1, MY) + 1
           KY = IB + KA - NS(IY)
           IF (KA .LT. NB .AND. KY .GE. LONG_0 .AND. KY .LT. NN(IY)) THEN
              K = MIN(NB - KA, NN(IY) - KY)
              A(KA + 1:KA + K) = Y(KY + 1:KY + K, IY)
              KA = KA + K
           ENDIF
        ENDDO
     ENDIF

     !  SET POSITION AND READ BUFFER AND GET DATA
     IF (KA .LT. NB) THEN
        LUX = ABS(LU)
        JY = MOD(JY, MY)+1
        NS(JY) = IB+KA
        IRET = BACIOL(BACIO_READ, NS(JY), JB, 1, NY, NN(JY), &
             FD(LUX), CHAR(0), Y(1, JY))
        IF (NN(JY).GT.0) THEN
           K = MIN(NB-KA, NN(JY))
           A(KA+1:KA+K) = Y(1:K, JY)
           KA = KA+K
        ENDIF

        !  CONTINUE TO READ BUFFER AND GET DATA
        DO WHILE(NN(JY).EQ.NY.AND.KA.LT.NB)
           JY = MOD(JY, MY)+1
           NS(JY) = NS(JY)+NN(JY)
           IRET = BACIOL(BACIO_READ+BACIO_NOSEEK, NS(JY), JB, 1, NY, NN(JY), &
                FD(LUX), CHAR(0), Y(1, JY))
           IF (NN(JY).GT.0) THEN
              K = MIN(NB-KA, NN(JY))
              A(KA+1:KA+K) = Y(1:K, JY)
              KA = KA+K
           ENDIF
        ENDDO
     ENDIF
  ENDIF
END SUBROUTINE BAREADL

!> This program is calling bawritel() to write a given number of bytes to
!> an unblocked file, skipping a given number of bytes.
!>
!> @param[in] lu unit to write.
!> @param[in] ib number of bytes to skip. (If ib<0, then the file is
!> accessed with no seeking.)
!> @param[in] nb number of bytes to write.
!> @param[out] ka integer number of bytes actually written.
!> @param[in] a data to write.
!>
!> @note A baopen() must have already been called.
!>
SUBROUTINE BAWRITE(LU, IB, NB, KA, A)
  IMPLICIT NONE
  INTEGER, INTENT(IN) :: LU, IB, NB
  INTEGER, INTENT(OUT) :: KA
  CHARACTER, INTENT(IN) :: A(NB)
  INTEGER(KIND = 8) :: LONG_IB, LONG_NB, LONG_KA

  if (NB < 0) THEN
     print *, 'WRONG: in BAWRITE read data size NB <0,  STOP! '//&
          'Consider using BAWRITEL and long integer'
     KA = 0
     return
  ENDIF

  LONG_IB = IB
  LONG_NB = NB
  CALL BAWRITEL(LU, LONG_IB, LONG_NB, LONG_KA, A)
  KA = INT(LONG_KA)
END SUBROUTINE BAWRITE

!> This subrouytine writes a given number of bytes to an unblocked
!> file, skipping a given number of bytes.
!>
!> @param[in] lu unit to write.
!> @param[in] ib number of bytes to skip. (If ib < 0, then the
!> file is accessed with no seeking).
!> @param[in] nb number of bytes to write.
!> @param[out] ka number of bytes actually written.
!> @param[in] a data to write.
!>
SUBROUTINE BAWRITEL(LU, IB, NB, KA, A)
  USE BACIO_MODULE
  IMPLICIT NONE
  INTEGER, intent(in)         :: LU
  INTEGER(kind = 8), intent(in) :: IB, NB
  INTEGER(kind = 8), intent(out):: KA
  CHARACTER, intent(in) ::  A(NB)
  INTEGER(kind = 8) :: JB, LONG_0
  INTEGER :: IRET

  IF (LU .LT. 001 .OR. LU .GT. FDDIM) THEN
     KA = 0
     RETURN
  ENDIF
  IF (FD(LU) .LE. 0) THEN
     KA = 0
     RETURN
  ENDIF
  IF (NB .LE. 0) THEN
     KA = 0
     RETURN
  ENDIF

  LONG_0 = 0

  IF (IB .GE. 0) THEN
     KA = 0
     IRET = BACIOL(BACIO_WRITE, IB, JB, 1, NB, KA, FD(LU), CHAR(0), A)
  ELSE
     KA = 0
     IRET = BACIOL(BACIO_WRITE+BACIO_NOSEEK, LONG_0, JB, 1, NB, KA, &
          FD(LU), CHAR(0), A)
  ENDIF
END SUBROUTINE  BAWRITEL

!> This subroutine is calling wrytel() to write a given number of
!> bytes to an unblocked file.
!>
!> ### Program History Log
!> Date | Programmer | Comments
!> -----|------------|---------
!> 92-10-31 | Mark Iredell | Initial.
!> 95-10-31 | Mark Iredell | workstation version
!> 1998-06-04 | Mark Iredell | bacio version
!> 2009-04-20 | Jun Wang | wrytel version
!>
!> @param[in] lu unit to which to write.
!> @param[in] nb number of bytes to write.
!> @param[in] a data to write.
!>

!> @note A baopen must have already been called.
SUBROUTINE WRYTE(LU, NB, A)
  USE BACIO_MODULE
  IMPLICIT NONE

  INTEGER, intent(in) :: LU
  INTEGER, intent(in) :: NB
  CHARACTER, intent(in) ::  A(NB)
  INTEGER(kind = 8) :: LONG_NB

  IF (NB < 0) THEN
     PRINT *, 'WRONG: NB: the number of bytes to write  <0, STOP!'
     RETURN
  ENDIF
  LONG_NB = NB
  CALL WRYTEL(LU, LONG_NB, A)
END SUBROUTINE WRYTE

!> Write a given number of bytes to an unblocked file.
!>
!> ### Program History Log
!> Date | Programmer | Comments
!> -----|------------|---------
!> 92-10-31 | Mark Iredell | Initial.
!> 95-10-31 | Mark Iredell | workstation version
!> 1998-06-04 | Mark Iredell | bacio version
!> 2009-04-20 | Jun Wang | wrytel version
!>
!> @param[in] lu unit to which to write.
!> @param[in] nb number of bytes to write.
!> @param[in] a data to write.
!>

!> @note A baopen must have already been called.
SUBROUTINE WRYTEL(LU, NB, A)
  USE BACIO_MODULE
  IMPLICIT NONE
  INTEGER, intent(in) :: LU
  INTEGER(kind = 8), intent(in) :: NB
  CHARACTER, INTENT(in)       :: A(NB)
  INTEGER(kind = 8) :: LONG_0, JB, KA
  INTEGER :: IRET

  IF (LU .LT. 001 .OR. LU .GT. FDDIM) THEN
     KA = 0
     RETURN
  ENDIF
  IF (FD(LU) .LE. 0) THEN
     RETURN
  ENDIF
  IF (NB .LE. 0) THEN
     RETURN
  ENDIF

  LONG_0 = 0
  KA = 0
  JB = 0
  IRET = BACIOL(BACIO_WRITE + BACIO_NOSEEK, LONG_0, JB, 1, NB, KA, &
       FD(LU), CHAR(0), A)
  RETURN
END SUBROUTINE WRYTEL
