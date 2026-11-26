module m
  type t
  end type
  type, extends(t) :: p
    integer :: a
  end type
  type, extends(p) :: c
    integer :: b
  end type
  type(c), parameter :: x = c(1, 2)
  type(p), parameter :: y = x%p
end module
