program main
  implicit none
  integer, parameter :: irt(2) = [1, 2]
  integer, pointer :: ir(:)


  type :: foo_t
  contains
    procedure, pass :: method1 => FOO_METHOD1_ffl
    procedure, pass :: method2 => FOO_METHOD2_ffl
    procedure, pass :: method3 => FOO_METHOD3_ffl
  end type

  type :: bar_t
  contains
    procedure, pass :: method1 => BAR_METHOD1_ffl
    procedure, pass :: method2 => BAR_METHOD2_ffl
    procedure, pass :: method3 => BAR_METHOD3_ffl
  end type

  type(foo_t) :: foo
  type(bar_t) :: bar

  ir => irt
  call foo%method1()
  call foo%method2()
  call foo%method3()

  call ffl_donor_main
  call bar%method1()
  call bar%method2()
  call bar%method3()

contains

  subroutine FOO_METHOD1_ffl(self)
    class(foo_t), intent(inout) :: self
  end subroutine

  subroutine FOO_METHOD2_ffl(self)
    class(foo_t), intent(inout) :: self
  end subroutine

  subroutine FOO_METHOD3_ffl(self)
    class(foo_t), intent(inout) :: self
  end subroutine

  subroutine BAR_METHOD1_ffl(self)
    class(bar_t), intent(inout) :: self
  end subroutine

  subroutine BAR_METHOD2_ffl(self)
    class(bar_t), intent(inout) :: self
  end subroutine

  subroutine BAR_METHOD3_ffl(self)
    class(bar_t), intent(inout) :: self
  end subroutine

end program main
subroutine ffl_donor_main
  implicit none

  type :: foo_t
  contains
    procedure, pass :: method1 => foo_method1
    procedure, pass :: method2 => foo_method2
    procedure, pass :: method3 => foo_method3
  end type

  type :: bar_t
  contains
    procedure, pass :: method1 => bar_method1
    procedure, pass :: method2 => bar_method2
    procedure, pass :: method3 => bar_method3
  end type

  type(foo_t) :: foo
  type(bar_t) :: bar

  call foo%method1()
  call foo%method2()
  call foo%method3()

  call bar%method1()
  call bar%method2()
  call bar%method3()

contains

  subroutine foo_method1(self)
    class(foo_t), intent(inout) :: self
  end subroutine

  subroutine foo_method2(self)
    class(foo_t), intent(inout) :: self
  end subroutine

  subroutine foo_method3(self)
    class(foo_t), intent(inout) :: self
  end subroutine

  subroutine bar_method1(self)
    class(bar_t), intent(inout) :: self
  end subroutine

  subroutine bar_method2(self)
    class(bar_t), intent(inout) :: self
  end subroutine

  subroutine bar_method3(self)
    class(bar_t), intent(inout) :: self
  end subroutine

end subroutine ffl_donor_main
