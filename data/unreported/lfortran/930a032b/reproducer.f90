program main
  implicit none
  real, parameter :: global_no_use = 12.0
  real, parameter :: global_used = 1.2
  real, pointer :: p

  enum, bind(c)
    enumerator :: a = 1, b = 2147483647, c = 3
  end enum

  integer :: x

  p => global_used
  x = a
  x = b
  if (associated(p)) continue
  x = c
  call ffl_donor_main
end program main
subroutine ffl_donor_main
  implicit none

  enum, bind(c)
    enumerator :: a = 1, b = 2, c = 3
  end enum

  integer :: x

  real :: global_no_use
  x = a
  x = b
  x = global_no_use
end subroutine ffl_donor_main
