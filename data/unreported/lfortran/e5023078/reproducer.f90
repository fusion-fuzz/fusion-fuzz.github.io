subroutine s(t)
  real :: t, f, y
  f(t) = t + 1
  t(t) = f(t)
  y = f(t)
end subroutine
