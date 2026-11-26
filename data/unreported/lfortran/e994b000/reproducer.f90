subroutine s(b)
  real :: x, b(3)
  forall (x=1:3) b(1) = 0
end subroutine
