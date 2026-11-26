subroutine s(r, x)
  real :: r(10), x
  integer :: i
  !$acc parallel loop
  do i = 1, x
    r(i) = 0
  end do
end subroutine
