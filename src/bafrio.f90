!> @file
!>
!> This version of bafrio.f is revised to have byteswap in FORTRAN
!> data file control words. It is designed to be run on on
!> WCOSS(little endian machine) and to generate big endian files.
!>
!> It does byteswap on fortran record control words(4 byte integer
!> before and after data field), not on data field itself. Users need
!> to byteswap their data after(for reading)/before(for writing)
!> calling subroutines this file. This is considered to be the best
!> way to keep subroutine inerfaces intact for backward compatible.
!>
!> ### Program History Log
!> Date | Programmer | Comments
!> -----|------------|--------- 
!> 1999-01-21 | iredell | Initial. 
!> Aug, 2012 | Jun Wang | bafrio for big and little endian files
!>
!> @author Mark Iredell @date 1999-01-21

!> This subprogram calls bafrindexl() to either read an unformatted
!> fortran record and return its length and start byte of the next
!> fortran record; or given the record length, without I/O it
!> determines the start byte of the next fortran record. The
!> difference between bafrindex() and bafrindexl() is the kind type of
!> integers in the argument list.
!>
!> ### Program History Log
!> Date | Programmer | Comments
!> -----|------------|--------- 
!> 1999-01-21 | Mark Iredell | Initial
!> 2009-04-20 | Jun Wang | Changes
!>
!> @param lu integer logical unit to read. if lu<=0, then determine ix
!> from lx.
!> @param ib integer fortran record start byte. (for the first fortran
!> record, ib should be 0).
!> @param lx integer record length in bytes if lu<=0. If lu>0, or
!> lx=-1 for i/o error (probable end of file), or lx=-2 for i/o error
!> (invalid fortran record).
!> @param ix integer start byte for the next fortran record. (computed
!> only if lx>=0).
!>
!> @author Mark Iredell @date 1999-01-21
SUBROUTINE BAFRINDEX(LU,IB,LX,IX)
  IMPLICIT NONE
  INTEGER,INTENT(IN):: LU,IB
  INTEGER,INTENT(INOUT):: LX
  INTEGER,INTENT(OUT):: IX
  integer(kind=8) :: LONG_IB,LONG_LX ,LONG_IX

  LONG_IB=IB
  LONG_LX=LX
  call BAFRINDEXL(LU,LONG_IB,LONG_LX,LONG_IX)
  LX=LONG_LX
  IX=LONG_IX

  return
end SUBROUTINE BAFRINDEX

!> This subprogram either reads an unformatted fortran record and
!> return its length and start byte of the next fortran record; or
!> given the record length, without i/o it determines the start byte
!> of the next fortran record.
!>
!> ### Program History Log
!> Date | Programmer | Comments
!> -----|------------|--------- 
!> 1999-01-21 | Mark Iredell | Initial
!> 2009-04-20 | Jun Wang | Changes
!>
!> @param lu integer logical unit to read. if lu<=0, then determine ix
!> from lx.
!> @param ib integer fortran record start byte. (for the first fortran
!> record, ib should be 0).
!> @param lx integer record length in bytes if lu<=0. If lu>0, or
!> lx=-1 for i/o error (probable end of file), or lx=-2 for i/o error
!> (invalid fortran record).
!> @param ix integer start byte for the next fortran record. (computed
!> only if lx>=0).
!>
!> @author Mark Iredell @date 1999-01-21
!>
SUBROUTINE BAFRINDEXL(LU,IB,LX,IX)
  IMPLICIT NONE
  INTEGER,INTENT(IN):: LU
  INTEGER(KIND=8),INTENT(IN):: IB
  INTEGER(KIND=8),INTENT(INOUT):: LX
  INTEGER(KIND=8),INTENT(OUT):: IX
  INTEGER(KIND=8),PARAMETER:: LBCW=4
  INTEGER(KIND=LBCW):: BCW1,BCW2
  INTEGER(KIND=8):: KR
  CHARACTER(16) :: MACHINE_ENDIAN
  LOGICAL :: DO_BYTESWAP
  ! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  !  COMPARE FIRST BLOCK CONTROL WORD AND TRAILING BLOCK CONTROL WORD
  IF(LU.GT.0) THEN
     !
     !-- set do_byteswap from machine endianness and file endianness
     CALL CHK_ENDIANC(MACHINE_ENDIAN)
     IF( LU<=999) THEN
        IF( trim(MACHINE_ENDIAN)=="big_endian") THEN
           DO_BYTESWAP=.false.
        ELSEIF( trim(MACHINE_ENDIAN)=="little_endian") THEN
           DO_BYTESWAP=.true.
        ENDIF
     ELSEIF(LU<=1999) THEN
        IF( trim(MACHINE_ENDIAN)=="big_endian") THEN
           DO_BYTESWAP=.true.
        ELSEIF( trim(MACHINE_ENDIAN)=="little_endian") THEN
           DO_BYTESWAP=.false.
        ENDIF
     ENDIF
     ! 
     !
     !-- read out control word      
     CALL BAREADL(LU,IB,LBCW,KR,BCW1)
     IF(DO_BYTESWAP) CALL Byteswap(BCW1,LBCW,1)
     !
     IF(KR.NE.LBCW) THEN
        LX=-1
     ELSE
        CALL BAREADL(LU,IB+LBCW+BCW1,LBCW,KR,BCW2)
        IF(DO_BYTESWAP) CALL Byteswap(BCW2,LBCW,1)
        !
        IF(KR.NE.LBCW.OR.BCW1.NE.BCW2) THEN
           LX=-2
        ELSE
           LX=BCW1
        ENDIF
     ENDIF
     !
     !end luif
  ENDIF
  ! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  !  COMPUTE START BYTE FOR THE NEXT FORTRAN RECORD
  IF(LX.GE.0) IX=IB+LBCW+LX+LBCW
END SUBROUTINE BAFRINDEXL

!> This subprogram calls bafread() to read an unformatted fortran
!> record. The difference between bafrread() and bafrreadl() is the
!> kind type of integers in the argument list.
!>
!> ### Program History Log
!> Date | Programmer | Comments
!> -----|------------|--------- 
!> 1999-01-21 | Mark Iredell | Initial
!> 2009-04-20 | Jun Wang | Changes
!>
!> @param lu integer logical unit to read.
!> @param ib integer fortran record start byte (for the first fortran
!> record, ib should be 0).
!> @param nb integer number of bytes to read.
!> @param ka integer number of bytes in fortran record (in which case
!> the next fortran record should have a start byte of ib+ka),
!> - or ka=-1 for i/o error (probable end of file),
!> - or ka=-2 for i/o error (invalid fortran record),
!> - or ka=-3 for i/o error (request longer than record)
!> @param a character*1 (nb) data read
!>
!> @author Mark Iredell @date 1999-01-21
!>
SUBROUTINE BAFRREAD(LU,IB,NB,KA,A)
  IMPLICIT NONE
  INTEGER,INTENT(IN):: LU,IB,NB
  INTEGER,INTENT(OUT):: KA
  CHARACTER,INTENT(OUT):: A(NB)
  INTEGER(KIND=8) :: LONG_IB,LONG_NB,LONG_KA

  if((IB<0.and.IB/=-1) .or. NB<0 ) THEN
     print *,'WRONG: in BAFRREAD starting postion IB or read '//    &
          'data size NB < 0, STOP! Consider use BAFREADL and long integer'
     KA=0
     return
  ENDIF
  LONG_IB=IB
  LONG_NB=NB
  CALL BAFRREADL(LU,LONG_IB,LONG_NB,LONG_KA,A)
  KA=LONG_KA
END SUBROUTINE BAFRREAD

!> This subprogram reads an unformatted fortran record.
!>
!> ### Program History Log
!> Date | Programmer | Comments
!> -----|------------|--------- 
!> 1999-01-21 | Iredell | Initial
!> 2009-04-20 | Jun Wang | Changes
!>
!> @param lu integer logical unit to read.
!> @param ib integer(8) fortran record start byte. (For the first
!> fortran record, ib should be 0.)
!> @param nb integer(8) number of bytes to read.
!> @param ka integer(8) number of bytes in fortran record (in which
!> case the next fortran record should have a start byte of ib+ka),
!> - or ka=-1 for i/o error (probable end of file),
!> - or ka=-2 for i/o error (invalid fortran record),
!> - or ka=-3 for i/o error (request longer than record)
!> @param a character*1 (nb) data read
!>
!> @author Mark Iredell @date 1999-01-21
!>
SUBROUTINE BAFRREADL(LU,IB,NB,KA,A)
  IMPLICIT NONE
  INTEGER,INTENT(IN):: LU
  INTEGER(kind=8),INTENT(IN):: IB,NB
  INTEGER(kind=8),INTENT(OUT):: KA
  CHARACTER,INTENT(OUT):: A(NB)
  INTEGER(kind=8),PARAMETER:: LBCW=4
  INTEGER(kind=8):: LX,IX
  INTEGER(kind=8):: KR

  !  VALIDATE FORTRAN RECORD
  CALL BAFRINDEXL(LU,IB,LX,IX)

  !  READ IF VALID
  IF(LX.LT.0) THEN
     KA=LX
  ELSEIF(LX.LT.NB) THEN
     KA=-3
  ELSE
     CALL BAREADL(LU,IB+LBCW,NB,KR,A)
     IF(KR.NE.NB) THEN
        KA=-1
     ELSE
        KA=LBCW+LX+LBCW
     ENDIF
  ENDIF
END SUBROUTINE BAFRREADL

!> This subprogram calls bafrwrite() to write an unformatted fortran
!> record. The difference between bafrwrite() and bafrwritel() is the
!> kind type of integers in the argument list.
!>
!> ### Program History Log
!> Date | Programmer | Comments
!> -----|------------|--------- 
!> 1999-01-21 | Iredell | Initial
!> 2009-04-20 | Jun Wang | Changes
!>
!> @param lu integer logical unit to write to.
!> @param ib integer(8) fortran record start byte. (For the first
!> fortran record, ib should be 0.)
!> @param nb integer(8) number of bytes to write.
!> @param a character*1 (nb) data to write.
!> @param ka integer number of bytes in fortran record (in which case
!> the next fortran record should have a start byte of ib+ka), or
!> ka=-1 for i/o error.
!>
!> @author Mark Iredell @date 1999-01-21
!>
SUBROUTINE BAFRWRITE(LU,IB,NB,KA,A)
  IMPLICIT NONE
  INTEGER,INTENT(IN):: LU,IB,NB
  INTEGER,INTENT(OUT):: KA
  CHARACTER,INTENT(IN):: A(NB)
  INTEGER(KIND=8) :: LONG_IB,LONG_NB,LONG_KA

  if((IB<0.and.IB/=-1) .or. NB<0 ) THEN
     print *,'WRONG: in BAFRWRITE starting postion IB or read '//   &
          'data size NB <0, STOP! ' //                                    &
          'Consider use BAFRRWRITEL and long integer'
     KA=0
     return
  ENDIF
  LONG_IB=IB
  LONG_NB=NB
  CALL BAFRWRITEL(LU,LONG_IB,LONG_NB,LONG_KA,A)
  KA=LONG_KA
END SUBROUTINE BAFRWRITE

!> This subprogram writes an unformatted fortran record.
!>
!> ### Program History Log
!> Date | Programmer | Comments
!> -----|------------|--------- 
!> 1999-01-21 | Iredell | Initial
!> 2009-04-20 | Jun Wang | Changes
!>
!> @param lu integer logical unit to write to.
!> @param ib integer(8) fortran record start byte. (For the first
!> fortran record, ib should be 0.)
!> @param nb integer(8) number of bytes to write.
!> @param a character*1 (nb) data to write.
!> @param ka integer number of bytes in fortran record (in which case
!> the next fortran record should have a start byte of ib+ka), or
!> ka=-1 for i/o error.
!>
!> @author Mark Iredell @date 1999-01-21
!>
SUBROUTINE BAFRWRITEL(LU,IB,NB,KA,A)
  IMPLICIT NONE
  INTEGER,INTENT(IN):: LU
  INTEGER(KIND=8),INTENT(IN):: IB,NB
  INTEGER(kind=8),INTENT(OUT):: KA
  CHARACTER,INTENT(IN):: A(NB)

  INTEGER(kind=8),PARAMETER:: LBCW=4
  INTEGER(kind=LBCW):: BCW
  INTEGER(kind=8):: KR
  INTEGER(LBCW):: BCW2,LBCW2
  CHARACTER(16) :: MACHINE_ENDIAN
  LOGICAL :: DO_BYTESWAP

  !  WRITE DATA BRACKETED BY BLOCK CONTROL WORDS

  !-- set do_byteswap from machine endianness and file endianness
  CALL CHK_ENDIANC(MACHINE_ENDIAN)
  IF( LU<=999) THEN
     IF( trim(MACHINE_ENDIAN)=="big_endian") THEN
        DO_BYTESWAP=.false.
     ELSEIF( trim(MACHINE_ENDIAN)=="little_endian") THEN
        DO_BYTESWAP=.true.
     ENDIF
  ELSEIF(LU<=1999) THEN
     IF( trim(MACHINE_ENDIAN)=="big_endian") THEN
        DO_BYTESWAP=.true.
     ELSEIF( trim(MACHINE_ENDIAN)=="little_endian") THEN
        DO_BYTESWAP=.false.
     ENDIF
  ENDIF

  BCW=NB
  IF(DO_BYTESWAP) CALL Byteswap(BCW,LBCW,1)
  CALL BAWRITEL(LU,IB,LBCW,KR,BCW)
  IF(KR.NE.LBCW) THEN
     KA=-1
  ELSE
     CALL BAWRITEL(LU,IB+LBCW,NB,KR,A)
     IF(KR.NE.NB) THEN
        KA=-1
     ELSE
        CALL BAWRITEL(LU,IB+LBCW+NB,LBCW,KR,BCW)
        IF(KR.NE.LBCW) THEN
           KA=-1
        ELSE
           KA=LBCW+NB+LBCW
        ENDIF
     ENDIF
  ENDIF
END SUBROUTINE  BAFRWRITEL
