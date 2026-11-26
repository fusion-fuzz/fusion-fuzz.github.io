subroutine s(y)
  integer :: y(10, 10)
  forall(i=1:10, j=1:10) b(i, j) = y(i, j)
end subroutine
