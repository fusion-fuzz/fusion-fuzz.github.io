module m
  type :: t2
    type(t1) :: x = t1()
  end type
  type, extends(t2) :: t
    complex :: z
  end type
  type(t), parameter :: tz(*) = [t((3., 4.)), t((5., 6.))]
  logical, parameter :: test_6 = all(tz%z%im == [4., 6.])
end module
