module m1
type pair
  end type
interface pair

subroutine s(var)

end subroutine s
!RUN: %python %S/test_errors.py %s %flang_fc1
    module procedure f
end interface

end
module m2
type pair
  end type
end
module REALVAR7
type pair
  end type
end
program main
  use m1
  use m2
  use m3
  !ERROR: Reference to 'pair' is ambiguous
  type(pair) error
end
