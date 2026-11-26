program main
  implicit none
  integer, target :: a(1)
  integer, pointer :: p(:)

  type :: wrapper
     integer :: x
  end type wrapper

  type :: local
     integer :: t
     integer :: u
  end type local

  type(wrapper) :: w
  type(local) :: l

  w%x = 0
  l%t = 1
  a(1) = 0
  p(1:1) => a(1:1)
  p(1) = p(1)
  l%u = 2

  if (w%x /= 0 .or. l%t + l%u /= 3) stop 1
end program main
