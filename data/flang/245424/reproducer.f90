module m1
  type t1
    integer n
  end type
end
module m2
  type t1
    integer n
  end type
end
program main
  use m1
  use m2
  implicit type(t1) (x)
end
