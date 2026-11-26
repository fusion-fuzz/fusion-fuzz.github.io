program main
  implicit none
  integer :: x, y, z
  x = 0
  y = 0
  z = 0
  print *, x + y + z
  call ffl_donor_main
end program main
subroutine ffl_donor_main
! RUN: %python %S/test_errors.py %s %flang_fc1
! ERROR: Must be a scalar value, but is x rank-1 array
! ERROR: Shape of initialized object 'a' must be constant
complex:: a(n) = SUM([1])
INTEGER, parameter :: n(2) = [2,2]
end subroutine ffl_donor_main
