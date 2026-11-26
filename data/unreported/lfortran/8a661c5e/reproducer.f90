program main
  implicit none
  type :: foo
     type(bar), pointer :: m(:) => null()
  end type foo

  type :: bar
     type(foo), pointer :: a => null()
  end type bar

  type(foo), target :: x
  type(bar), target :: b1, b2
  integer :: i

  real, dimension(4) :: a_ffl, b
  logical, dimension(4) :: m1, m2, m3

  x%m => [b1, b2]
  do i = 1, size(x%m)
     if (associated(x%m(i)%a)) continue
  end do
  call ffl_donor_main
  a_ffl = [0.5, 1.5, -2.0, 4.0]
  b = [1.0, 3.0, 2.0, -1.0]

  m1 = a_ffl < 1.0
  m2 = b > 2.0
  m3 = m1 .and. .not. m2

  a_ffl = merge(a_ffl + b, 3.0, m3)

end program main
subroutine ffl_donor_main
  implicit none
  real, dimension(4) :: a, b
  logical, dimension(4) :: m1, m2, m3

  integer :: i
  a = [0.5, 1.5, -2.0, 4.0]
  b = [1.0, 3.0, 2.0, -1.0]

  m1 = a < 1.0
  m2 = i > 2.0
  m3 = m1 .and. .not. m2

  a = merge(a + b, 3.0, m3)

end subroutine ffl_donor_main
