subroutine s(a)
  real(16) :: a
  if (a) 10, 20, 30
10 print *, "negative"
20 print *, "zero"
30 print *, "positive"
end subroutine
