program main
  implicit none
  real(8) :: a(8), b(8)

  type :: foo
  end type foo

  class(*), allocatable :: x
  class(*), allocatable :: y
  procedure(), pointer :: p

  a = a + b
  allocate(x, source=foo())

  p => null()
  allocate(y, source=p)

end program main
