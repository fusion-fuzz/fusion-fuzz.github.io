module m

character(:), pointer :: TEST_COMPONENT_FOLLOWED_BY_REF
character(2), pointer :: c2
type t1
    real :: x
  end type
type t2
    type(t1), pointer :: p
  end type
type t3
    character(:), allocatable :: a(:)
  end type
end module

subroutine test_pointer_component_followed_by_component_ref(x)
  use m
  type(t2) :: x
  call takes_real(x%p%x)
end subroutine

subroutine test_component_followed_by_ref(x)
  use m
  type(t3) :: x
  call test_char(x%a(10))
end subroutine
