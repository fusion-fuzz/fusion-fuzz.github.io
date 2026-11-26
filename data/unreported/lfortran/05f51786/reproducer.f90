program p
  type :: t2
    integer :: k = 567
  end type
  type, extends(t2) :: t3
    integer :: j
  end type
  type(t3) :: x = t3(1, 2)
  print *, x%j
end program
