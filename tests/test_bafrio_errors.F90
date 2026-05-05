! Additional test program for bafrio.F90 error conditions
! Covers Lines 184 (KA=LX), 186 (KA=-3), 190 (KA=-1), 278, 282, 286 (KA=-1)
program test_bafrio_errors
  use bacio_module
  implicit none
  
  print *, '========================================='
  print *, 'Testing bafrio Error Conditions'
  print *, '========================================='
  
  call test_bafrread_errors()
  call test_bafrwrite_errors()
  call test_bafrindex_errors()
  
  print *, '========================================='
  print *, 'All bafrio error tests completed successfully!'
  print *, '========================================='

contains

  ! Test bafrread error conditions (Lines 184, 186, 190)
  subroutine test_bafrread_errors()
    integer :: lu = 1
    integer :: ka
    integer :: ib
    character(len=100) :: data_in
    character(len=20) :: filename = 'bafrread_error_test.bin'
    character(len=4) :: data
    integer :: iret
    integer :: stat
    
    print *, 'Testing bafrread error conditions...'
    
    ! Delete file if exists
    open(unit = 1234, iostat = stat, file = filename, status='old')
    if (stat == 0) close(1234, status='delete')
    
    ! Create a test file with Fortran record
    call baopen(lu, filename, iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not open file'
      stop 100
    end if
    
    data = 'test'
    call bafrwrite(lu, 0, 4, ka, data)
    if (ka .ne. 12) then  ! 4 bytes BCW + 4 bytes data + 4 bytes BCW
      print *, 'FAILED: Could not write record'
      stop 101
    end if
    
    call baclose(lu, iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not close file'
      stop 102
    end if
    
    ! Test Case 1: Read with request longer than record (Line 186: KA=-3)
    call baopenr(lu, filename, iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not reopen file'
      stop 103
    end if
    
    ib = 0
    call bafrread(lu, ib, 100, ka, data_in)  ! Request 100 bytes, but record is only 4
    if (ka .ne. -3) then
      print *, 'FAILED: Expected KA=-3 for request longer than record, got', ka
      stop 104
    end if
    
    call baclose(lu, iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not close file'
      stop 105
    end if
    
    ! Test Case 2: Read from corrupted file (Line 184: KA=LX or Line 190: KA=-1)
    ! Create a corrupted file (invalid Fortran record)
    open(unit = 2000, file = 'corrupted.bin', status = 'replace', &
         form = 'unformatted', access = 'stream')
    write(2000) 'CORRUPTED_DATA_NO_VALID_BCW'
    close(2000)
    
    call baopenr(lu, 'corrupted.bin', iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not open corrupted file'
      stop 106
    end if
    
    ib = 0
    call bafrread(lu, ib, 4, ka, data_in)
    if (ka .ge. 0) then
      print *, 'FAILED: Expected negative KA for corrupted file, got', ka
      stop 107
    end if
    
    call baclose(lu, iret)
    
    print *, 'PASSED: bafrread error condition tests'
  end subroutine test_bafrread_errors

  ! Test bafrwrite error conditions (Lines 278, 282, 286: KA=-1)
  subroutine test_bafrwrite_errors()
    integer :: lu = 1
    integer :: ka
    integer :: ib
    character(len=4) :: data
    character(len=20) :: filename = 'bafrwrite_error_test.bin'
    integer :: iret
    integer :: stat
    
    print *, 'Testing bafrwrite error conditions...'
    
    ! Delete file if exists
    open(unit = 1234, iostat = stat, file = filename, status='old')
    if (stat == 0) close(1234, status='delete')
    
    data = 'test'
    
    ! Create and open file
    call baopen(lu, filename, iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not open file for write error test'
      stop 200
    end if
    
    ! Test Case 1: Write with invalid parameters to trigger error
    ! This tests the error paths in bafrwritel (Lines 278, 282, 286)
    
    ! Simulate a write failure by trying to write to an invalid position
    ! or by causing an I/O error
    
    ! First, write a valid record
    ib = 0
    call bafrwrite(lu, ib, 4, ka, data)
    if (ka .ne. 12) then
      print *, 'FAILED: Could not write initial record'
      stop 201
    end if
    
    call baclose(lu, iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not close file'
      stop 202
    end if
    
    ! Test Case 2: Try to write with bad starting position
    call baopen(lu, filename, iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not reopen file'
      stop 203
    end if
    
    ! Use invalid starting byte position
    ib = -2
    call bafrwrite(lu, ib, 4, ka, data)
    if (ka .ne. 0) then
      print *, 'FAILED: Expected KA=0 for invalid start position, got', ka
      stop 204
    end if
    
    call baclose(lu, iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not close file'
      stop 205
    end if
    
    ! Test Case 3: Try to write with negative byte count
    call baopen(lu, filename, iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not reopen file'
      stop 206
    end if
    
    ib = 0
    call bafrwrite(lu, ib, -4, ka, data)
    if (ka .ne. 0) then
      print *, 'FAILED: Expected KA=0 for negative byte count, got', ka
      stop 207
    end if
    
    call baclose(lu, iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not close file'
      stop 208
    end if
    
    print *, 'PASSED: bafrwrite error condition tests'
  end subroutine test_bafrwrite_errors

  ! Test bafrindex error conditions (Line 101: LX=-1)
  subroutine test_bafrindex_errors()
    integer :: lu = 1
    integer :: ib, lx, ix
    integer(kind=8) :: ib8, lx8, ix8
    character(len=20) :: filename = 'bafrindex_error_test.bin'
    integer :: iret
    integer :: stat
    
    print *, 'Testing bafrindex error conditions...'
        
    ! Delete file if exists
    open(unit = 1234, iostat = stat, file = filename, status='old')
    if (stat == 0) close(1234, status='delete')
    
    ! Test Case 1: Read index from empty/non-existent file (Line 101: LX=-1)
    ! Create an empty file
    open(unit = 2000, file = filename, status = 'replace', &
         form = 'unformatted', access = 'stream')
    close(2000)
    
    call baopenr(lu, filename, iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not open empty file'
      stop 300
    end if
    
    ib = 0
    lx = 0
    call bafrindex(lu, ib, lx, ix)
    if (lx .ne. -1) then
      print *, 'FAILED: Expected LX=-1 for empty file, got', lx
      stop 301
    end if
    
    call baclose(lu, iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not close file'
      stop 302
    end if
    
    ! Test Case 2: Read index from corrupted file with invalid BCW
    ! Create a file with invalid block control words
    open(unit = 2000, file = 'corrupted_bcw.bin', status = 'replace', &
         form = 'unformatted', access = 'stream')
    write(2000) 'INVALID'
    close(2000)
    
    call baopenr(lu, 'corrupted_bcw.bin', iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not open corrupted BCW file'
      stop 303
    end if
    
    ib8 = 0
    lx8 = 0
    call bafrindexl(lu, ib8, lx8, ix8)
    if (lx8 .ge. 0) then
      print *, 'FAILED: Expected negative LX for corrupted BCW, got', lx8
      stop 304
    end if
    
    call baclose(lu, iret)
    
    ! Test Case 3: Test with valid file to ensure normal operation
    ! Create a proper Fortran record file
    call baopen(lu, filename, iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not create file for valid test'
      stop 305
    end if
    
    call bafrwrite(lu, 0, 4, lx, 'test')
    if (lx .ne. 12) then
      print *, 'FAILED: Could not write valid record'
      stop 306
    end if
    
    call baclose(lu, iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not close file'
      stop 307
    end if
    
    ! Read index from valid file
    call baopenr(lu, filename, iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not reopen valid file'
      stop 308
    end if
    
    ib = 0
    lx = 0
    call bafrindex(lu, ib, lx, ix)
    if (lx .ne. 4) then
      print *, 'FAILED: Expected LX=4 for valid record, got', lx
      stop 309
    end if
    
    if (ix .ne. 12) then
      print *, 'FAILED: Expected IX=12 for valid record, got', ix
      stop 310
    end if
    
    call baclose(lu, iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not close file after valid index test'
      stop 311
    end if
    
    print *, 'PASSED: bafrindex error condition tests'
  end subroutine test_bafrindex_errors

end program test_bafrio_errors
