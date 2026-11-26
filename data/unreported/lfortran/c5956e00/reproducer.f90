program k
  print *, 1
end program
subroutine s(a)
  integer :: a(2)
  a = [(1, k=1,2)]
end subroutine
