subroutine s
  real :: x
  !$acc cache(x%y)
end
