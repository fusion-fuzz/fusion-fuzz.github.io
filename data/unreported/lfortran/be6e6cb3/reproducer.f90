program p
  print *, f(1, :)
contains
  integer function f(i, j)
    integer :: i, j
    f = i
  end function
end program
