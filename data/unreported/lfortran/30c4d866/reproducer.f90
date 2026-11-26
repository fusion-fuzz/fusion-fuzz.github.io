program main
  implicit none
  integer :: i, j

  type :: x_int_2
     integer :: ary(2)
  end type
  type :: x_real_1
     real :: scalar
  end type
  type(x_int_2) :: q
  type(x_real_1) :: p
  j = ishft(5, 100)
  i = 5 / 0
  q%ary = 0

  q%ary(1) = 5
  p%scalar = 4.0
end program main
subroutine ffl_donor_main
  implicit none
  type :: x_int_2
     integer :: ary(2)
  end type
  type :: x_real_1
     real :: scalar
  end type
  type(x_int_2) :: q
  type(x_real_1) :: p
  q%ary = 0
  q%ary(1) = 5
  p%scalar = 4.0
end subroutine ffl_donor_main
