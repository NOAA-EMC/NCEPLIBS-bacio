program test_runner
  implicit none
  external :: test_baciof
  external :: test_bafrio
  external :: test_wryte
  integer :: n_failures = 0
  
  call run_test('test_baciof',test_baciof) 
  call run_test('test_bafrio',test_bafrio) 
  call run_test('test_wryte' ,test_wryte ) 

contains

  subroutine run_test(test_name, test_procedure)
    character(*), intent(in) :: test_name
    external :: test_procedure
    call test_procedure()
  end subroutine run_test

end program test_runner
