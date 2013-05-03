program test_runner

  implicit none
  ! The list of external test functions
  integer, external :: test_baciof
  integer, external :: test_bafrio
  integer, external :: test_wryte
  ! The test result counters
  integer :: n_success = 0
  integer :: n_failure = 0
  integer :: n_tests
  
  ! Run the tests
  call run_test('test_baciof',test_baciof) 
  call run_test('test_bafrio',test_bafrio) 
  call run_test('test_wryte' ,test_wryte ) 

  ! Report on the tests
  n_tests = n_success + n_failure
  write(*,'(/,40("-"))')
  write(*,'(2x,"Passed ",i5," of ",i5," tests")' ) n_success, n_tests
  write(*,'(2x,"Failed ",i5," of ",i5," tests")' ) n_failure, n_tests
  write(*,'(40("-"))')

contains

  subroutine run_test(test_name, test_procedure)
    character(*), intent(in) :: test_name
    integer     , external   :: test_procedure
    integer :: err_stat

    ! Run the test
    write(*,'(/5x,"Running ",a," test...")') trim(test_name)
    err_stat = test_procedure()

    ! Check the result
    if ( err_stat /= 0 ) then
      write(*,'(5x,"FAILURE!")')
      n_failure = n_failure + 1
    else
      write(*,'(5x,"SUCCESS!")')
      n_success = n_success + 1
    endif
    
  end subroutine run_test

end program test_runner
