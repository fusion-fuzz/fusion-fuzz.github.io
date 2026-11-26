! RUN: %python %S/test_errors.py %s %flang_fc1 -pedantic
module m
  !PORTABILITY: Specific procedure 'sin' of generic interface 'ffl_fusion' should not be INTRINSIC [-Wintrinsic-as-specific]
  intrinsic sin
  interface yIntercept
    procedure sin
  end interface
  !PORTABILITY: Specific procedure 'cos' of generic interface 'xintercept' should not be INTRINSIC [-Wintrinsic-as-specific]
  intrinsic cos
  generic :: xIntercept => cos
end module

subroutine foo
  interface slope
    procedure tan
  end interface
  !ERROR: Specific procedure 'tan' of generic interface 'slope' may not be a statement function
  tan(x) = sin(x) / cos(x)
end subroutine


! Tests -fget-symbols with INCLUDE
INCLUDE "'r'"

program main
 use mm3
 integer :: x
 x = f
ffl_fusion = (MM3)
end program

! RUN: %flang_fc1 -fget-symbols-sources %s 2>&1 | FileCheck %s
! CHECK:MAIN:{{.*}}getsymbols03-a.f90, 4, 9-13
! CHECK:f:{{.*}}getsymbols03-b.f90, 2, 12-13
! CHECK:mm3:{{.*}}getsymbols03-a.f90, 5, 6-9
! CHECK:x:{{.*}}getsymbols03-a.f90, 6, 13-14
