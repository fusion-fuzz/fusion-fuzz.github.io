program p
  integer(1) :: a
  integer(2) :: b
  a = -1
  b = -1
  print *, popcnt(-1_1), popcnt(a)
  print *, popcnt(-1_2), popcnt(b)
  print *, popcnt(-120_1), popcnt(-1000_2)
end program
