! Comprehensive test program for missing coverage lines
! This program tests:
! 1. Zero-length read scenario (baciof.F90 Line 420-421)
! 2. Endian scenarios (bafrio.F90 Line 83, 89, 262, 266-270)
! 3. Mixed endian detection (chk_endianc.F90 Line 36-41)
!
program test_bacio_comprehensive
  use bacio_module
  implicit none
  
  integer :: test_count = 0
  integer :: passed_count = 0
  
  print *, '========================================='
  print *, 'Running Comprehensive BACIO Coverage Tests'
  print *, '========================================='
  
  ! Run all test subroutines
  call run_test_zero_length_read()
  call run_test_endian_scenarios()
  call run_test_mixed_endian_detection()
  call run_test_lu_boundary_conditions()
  call run_test_buffered_read_continuation()
  
  print *, '========================================='
  print *, 'All comprehensive tests completed successfully!'
  print *, '========================================='

contains

  ! Test 1: Zero-length read scenario (baciof.F90 Line 420-421: KA = 0, RETURN)
  subroutine run_test_zero_length_read()
    integer :: lu = 1
    integer :: ka
    integer(kind=8) :: ka8, ib8, nb8
    character(len=4) :: data_in
    character(len=20) :: filename = 'zero_length_test.bin'
    integer :: iret
    integer :: stat

    print *, 'Test 1: Zero-length read scenario...'
    
    ! Delete file if exists
    open(unit = 1234, iostat = stat, file = filename, status='old')
    if (stat == 0) close(1234, status='delete')
    
    ! Open a file for writing
    call baopen(lu, filename, iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not open file'
      stop 1
    end if

    ! Write some initial data
    call bawrite(lu, 0, 4, ka, 'test')
    if (ka .ne. 4) then
      print *, 'FAILED: Could not write data'
      stop 2
    end if

    ! Close file
    call baclose(lu, iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not close file'
      stop 3
    end if

    ! Reopen for reading
    call baopenr(lu, filename, iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not reopen file'
      stop 4
    end if

    ! Attempt to read zero bytes (covers Line 420-421)
    call baread(lu, 0, 0, ka, data_in)
    if (ka .ne. 0) then
      print *, 'FAILED: Expected ka = 0, got', ka
      stop 5
    end if

    ! Test with bareadl for zero bytes
    ib8 = 0
    nb8 = 0
    call bareadl(lu, ib8, nb8, ka8, data_in)
    if (ka8 .ne. 0) then
      print *, 'FAILED: Expected ka8 = 0, got', ka8
      stop 6
    end if

    ! Close file
    call baclose(lu, iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not close file after read'
      stop 7
    end if

    print *, 'PASSED: Zero-length read test'
  end subroutine run_test_zero_length_read

  ! Test 2: Endian scenarios (bafrio.F90 Line 83, 89, 262, 266-270)
  subroutine run_test_endian_scenarios()
    integer :: lu = 1
    integer :: lu2 = 1500  ! Unit in the 1000-1999 range
    integer :: iret
    character(len=16) :: machine_endian
    integer :: ka
    integer :: ib, lx, ix
    integer(kind=8) :: ib8, lx8, ix8
    character(len=4) :: data, data_in
    character(len=20) :: filename = 'endian_test.bin'
    integer :: stat

    print *, 'Test 2: Endian scenario tests...'
    
    ! Delete file if exists
    open(unit = 1234, iostat = stat, file = filename, status='old')
    if (stat == 0) close(1234, status='delete')
    
    ! Check machine endianness
    call chk_endianc(machine_endian)
    print *, '  Machine Endianness: ', trim(machine_endian)

    ! Test with standard logical unit (covers Line 83 or 89)
    lu = 1
    call baopen(lu, filename, iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not open file for endian test'
      stop 10
    end if

    ! Write test data using bafrwrite (Fortran record format)
    data = 'test'
    call bafrwrite(lu, 0, 4, ka, data)
    if (ka .ne. 12) then  ! 4 bytes control + 4 bytes data + 4 bytes control
      print *, 'FAILED: Expected ka = 12, got', ka
      stop 11
    end if

    ! Close file
    call baclose(lu, iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not close file'
      stop 12
    end if

    ! Test with logical unit in 1000-1999 range (covers Line 266-270)
    lu2 = 1500
    call baopenr(lu2, filename, iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not reopen file with lu=1500'
      stop 13
    end if

    ! Read using bafrindex to check record structure
    ib = 0
    lx = 0
    call bafrindex(lu2, ib, lx, ix)
    if (ix .ne. 12) then
      print *, 'FAILED: Expected ix = 12, got', ix
      stop 14
    end if

    ! Read data using bafrread
    call bafrread(lu2, 0, 4, ka, data_in)
    if (ka .ne. 12) then
      print *, 'FAILED: Expected ka = 12 on read, got', ka
      stop 15
    end if
    
    if (data_in .ne. data) then
      print *, 'FAILED: Data mismatch'
      stop 16
    end if

    ! Close file
    call baclose(lu2, iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not close file after read'
      stop 17
    end if

    ! Test big-endian scenario (covers Line 262)
    if (trim(machine_endian) == 'big_endian') then
      print *, '  Testing big-endian specific path'
      
      lu = 1
      call baopen(lu, filename, iret)
      if (iret .ne. 0) then
        print *, 'FAILED: Could not open file for big-endian test'
        stop 18
      end if
      
      call bafrwrite(lu, 0, 4, ka, data)
      
      call baclose(lu, iret)
      if (iret .ne. 0) then
        print *, 'FAILED: Could not close file in big-endian test'
        stop 19
      end if
    end if

    print *, 'PASSED: Endian scenario tests'
  end subroutine run_test_endian_scenarios

  ! Test 3: Mixed endian detection (chk_endianc.F90 Line 36-41)
  subroutine run_test_mixed_endian_detection()
    character(16) :: mendian
    
    print *, 'Test 3: Endian detection tests...'
    
    ! Call the endianness check
    call chk_endianc(mendian)
    
    ! Verify that we get a valid result
    if (trim(mendian) .ne. 'little_endian' .and. &
        trim(mendian) .ne. 'big_endian' .and. &
        trim(mendian) .ne. 'mixed_endian') then
      print *, 'FAILED: Invalid endianness detected: ', trim(mendian)
      stop 20
    end if
    
    print *, '  Detected endianness: ', trim(mendian)
    print *, 'PASSED: Endian detection tests'
  end subroutine run_test_mixed_endian_detection

  ! Test 4: Logical Unit boundary conditions (baciof.F90 Line 547-548, 551-552, 617-618, 621)
  subroutine run_test_lu_boundary_conditions()
    integer :: lu = 0
    integer :: ka
    integer(kind=8) :: ka8, ib8, nb8
    character(len=4) :: data, data_in
    character(len=20) :: filename = 'lu_boundary_test.bin'
    integer :: iret
    integer :: stat
    
    print *, 'Test 4: Logical unit boundary conditions...'
    
    ! Delete file if exists
    open(unit = 1234, iostat = stat, file = filename, status='old')
    if (stat == 0) close(1234, status='delete')
    
    ! Test with invalid LU (covers Line 547-548: KA = 0, RETURN)
    lu = 0
    ib8 = 0
    nb8 = 4
    call bareadl(lu, ib8, nb8, ka8, data_in)
    if (ka8 .ne. 0) then
      print *, 'FAILED: Expected ka8 = 0 for invalid LU, got', ka8
      stop 30
    end if
    
    ! Test with LU > FDDIM (covers Line 547-548: KA = 0, RETURN)
    lu = FDDIM + 1
    call bareadl(lu, ib8, nb8, ka8, data_in)
    if (ka8 .ne. 0) then
      print *, 'FAILED: Expected ka8 = 0 for LU > FDDIM, got', ka8
      stop 31
    end if
    
    ! Test write with invalid LU (covers Line 551-552, 617-618: KA = 0, RETURN)
    lu = 0
    call bawritel(lu, ib8, nb8, ka8, data)
    if (ka8 .ne. 0) then
      print *, 'FAILED: Expected ka8 = 0 for invalid LU write, got', ka8
      stop 32
    end if
    
    lu = FDDIM + 1
    call bawritel(lu, ib8, nb8, ka8, data)
    if (ka8 .ne. 0) then
      print *, 'FAILED: Expected ka8 = 0 for LU > FDDIM write, got', ka8
      stop 33
    end if
    
    ! Test wrytel with invalid LU (covers Line 621: RETURN)
    lu = 0
    call wrytel(lu, nb8, data)
    ! No return value to check, just ensure it doesn't crash
    
    lu = FDDIM + 1
    call wrytel(lu, nb8, data)
    ! No return value to check, just ensure it doesn't crash
    
    ! Test with negative NB (covers Line 617-618: KA = 0, RETURN)
    lu = 1
    call baopen(lu, filename, iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not open file for negative NB test'
      stop 34
    end if
    
    nb8 = -1
    call bawritel(lu, ib8, nb8, ka8, data)
    if (ka8 .ne. 0) then
      print *, 'FAILED: Expected ka8 = 0 for negative NB, got', ka8
      stop 35
    end if
    
    call baclose(lu, iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not close file'
      stop 36
    end if
    
    print *, 'PASSED: Logical unit boundary condition tests'
  end subroutine run_test_lu_boundary_conditions

  ! Test 5: Buffered read continuation (baciof.F90 Line 479-486)
  subroutine run_test_buffered_read_continuation()
    integer :: lu = 1
    integer :: ka
    integer(kind=8) :: ka8, ib8, nb8
    character(len=20000) :: large_data
    character(len=20000) :: read_data
    character(len=20) :: filename = 'buffered_read_test.bin'
    integer :: iret
    integer :: stat
    integer :: i
    
    print *, 'Test 5: Buffered read continuation tests...'
    
    ! Delete file if exists
    open(unit = 1234, iostat = stat, file = filename, status='old')
    if (stat == 0) close(1234, status='delete')
    
    ! Create large test data (> 4096 bytes to trigger buffer continuation)
    do i = 1, 20000
      large_data(i:i) = char(mod(i, 256))
    end do
    
    ! Write large data
    call baopen(lu, filename, iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not open file for buffered read test'
      stop 40
    end if
    
    ib8 = 0
    nb8 = 20000
    call bawritel(lu, ib8, nb8, ka8, large_data)
    if (ka8 .ne. 20000) then
      print *, 'FAILED: Could not write large data, ka8 =', ka8
      stop 41
    end if
    
    call baclose(lu, iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not close file after write'
      stop 42
    end if
    
    ! Enable buffered reading (covers Line 479-486)
    call baseto(1, 1)
    
    ! Reopen for reading
    call baopenr(lu, filename, iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not reopen file for buffered read'
      stop 43
    end if
    
    ! Read data in chunks to trigger buffer continuation
    ! First read
    ib8 = 0
    nb8 = 5000
    call bareadl(lu, ib8, nb8, ka8, read_data(1:5000))
    if (ka8 .ne. 5000) then
      print *, 'FAILED: First buffered read failed, ka8 =', ka8
      stop 44
    end if
    
    ! Second read (should trigger buffer continuation - Line 479-486)
    ib8 = 5000
    nb8 = 5000
    call bareadl(lu, ib8, nb8, ka8, read_data(5001:10000))
    if (ka8 .ne. 5000) then
      print *, 'FAILED: Second buffered read failed, ka8 =', ka8
      stop 45
    end if
    
    ! Third read (continue reading to trigger multiple buffer loads)
    ib8 = 10000
    nb8 = 5000
    call bareadl(lu, ib8, nb8, ka8, read_data(10001:15000))
    if (ka8 .ne. 5000) then
      print *, 'FAILED: Third buffered read failed, ka8 =', ka8
      stop 46
    end if
    
    ! Fourth read
    ib8 = 15000
    nb8 = 5000
    call bareadl(lu, ib8, nb8, ka8, read_data(15001:20000))
    if (ka8 .ne. 5000) then
      print *, 'FAILED: Fourth buffered read failed, ka8 =', ka8
      stop 47
    end if
    
    ! Verify data integrity
    if (read_data .ne. large_data) then
      print *, 'FAILED: Data mismatch in buffered read'
      stop 48
    end if
    
    call baclose(lu, iret)
    if (iret .ne. 0) then
      print *, 'FAILED: Could not close file after buffered read'
      stop 49
    end if
    
    ! Turn off buffered reading
    call baseto(1, 0)
    
    print *, 'PASSED: Buffered read continuation tests'
  end subroutine run_test_buffered_read_continuation

end program test_bacio_comprehensive

