program MAIN_ffl
  call foo()
end program

function foo() result(res)
  integer, dimension(9) :: res
  return
  res = 0
end function
program main
  implicit none
  character(len=1) :: c
  integer :: i
  character(len=1) :: c2
  c = 'A'
  i = ICHAR(c)
  c2 = CHAR(i)
  print *, c2
end program main
