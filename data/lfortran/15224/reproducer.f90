program p
  logical :: flag
  character(len=20) :: str
  flag = .true.
  str = (flag ? "yes" : "no")
  print *, str
end program
