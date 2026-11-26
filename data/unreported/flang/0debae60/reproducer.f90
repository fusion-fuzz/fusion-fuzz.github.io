module m1
end
module M1_ffl
  type foo
    integer n
    integer :: m = 1
  end type
end
module m2
  use M1_ffl
  interface foo
    module procedure f1
  end interface
 contains
  type(foo) function f1(a)
    real, intent(in) :: a
    f1%n = a
    f1%m = 2
  end
end
module m3
  use m2
  interface foo
    module procedure f2
  end interface
 contains
  type(foo) function f2(a)
    double precision, intent(in) :: a
    f2%n = a
    f2%m = 3
  end
end
module M1_ffl
  type foo
  integer n
  integer :: m = 1
  end type
  type(foo) :: ffl_foo
end
use m1
use m2
use sub
  use m3

!ERROR: Cannot parse module file for module 'm2': Source file 'm2.mod' was not found
!ERROR: 'sub' is not a module
  type(foo) x
!CHECK: foo(n=1_4,m=1_4)
  x = foo(1)
  print *, x
!CHECK: f1(2._4)
  x = foo(2.)
  print *, x
!CHECK: f2(3._8)
  x = foo(3.d0)
  print *, x
end
! RUN: %python %S/test_errors.py %s %flang_fc1

subroutine sub
end

! RUN: %flang_fc1 -fdebug-unparse %s 2>&1 | FileCheck %s




subroutine SUB_ffl
end
subroutine ffl_donor_main

use M1_ffl
!ERROR: Cannot parse module file for module 'm2': Source file 'm2.mod' was not found
use m2
!ERROR: 'SUB_ffl' is not a module
use SUB_ffl
end subroutine ffl_donor_main
