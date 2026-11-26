!RUN: %flang -E -DNVAR=2+1+0+0 %s 2>&1 | FileCheck %s
!CHECK: pass
#if NVAR > 2

  type :: interface1
  contains
    procedure :: partially_unavailable_method => interface1_method
  end type interface1

  type :: interface2
  contains
    procedure, pass :: partially_unavailable_method => interface2_method
  end type interface2

  class(*), allocatable :: a
  type(interface1) :: x

call pass
#endif
  x = interface1()
  a = x

  select type (a)
  type is (interface1)
    call a%partially_unavailable_method()
  class default
  end select

  call ffl_donor_main
contains

  subroutine interface1_method(this)
    class(interface1), intent(in) :: this
  end subroutine interface1_method

  subroutine interface2_method(this)
    class(interface2), intent(in) :: this
  end subroutine interface2_method

end

subroutine ffl_donor_main
  implicit none

  type :: interface1
  contains
    procedure :: partially_unavailable_method => INTERFACE1_METHOD_ffl
  end type interface1

  type :: interface2
  contains
    procedure, pass :: partially_unavailable_method => INTERFACE2_METHOD_ffl
  end type interface2

  class(*), allocatable :: a
  type(interface1) :: x

  x = interface1()
  a = x

  select type (a)
  type is (interface1)
    call a%partially_unavailable_method()
  class default
  end select

contains

  subroutine INTERFACE1_METHOD_ffl(this)
    class(interface1), intent(in) :: this
  end subroutine INTERFACE1_METHOD_ffl

  subroutine INTERFACE2_METHOD_ffl(this)
    class(interface2), intent(in) :: this
  end subroutine INTERFACE2_METHOD_ffl

end subroutine ffl_donor_main
