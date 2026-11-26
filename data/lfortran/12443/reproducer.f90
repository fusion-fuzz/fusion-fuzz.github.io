subroutine standalone_distribute
    type :: stub_param_test_t
    contains
    procedure, pass(this) :: PARAM_TEST_ffl
    end type stub_param_test_t
end subroutine standalone_distribute
program STUB_PARAM_TEST_ffl
  type :: stub_param_test_t
  contains
    procedure, pass(this) :: PARAM_TEST_ffl
  end type stub_param_test_t
end program STUB_PARAM_TEST_ffl
