! Tests -fget-definition with INCLUDE
INCLUDE "'l'"

program main
 use m3
 integer :: x
 x = f
end program

! RUN: %flang_fc1 -fget-definition 7 6 7 %s | FileCheck --check-prefix=CHECK1 %s
! RUN: %flang_fc1 -fget-definition 7 2 3 %s | FileCheck --check-prefix=CHECK2 %s
! CHECK1: f:{{.*}}getdefinition03-b.f90, 2, 12-13
! CHECK2: x:{{.*}}getdefinition03-a.f90, 6, 13-14

program test
  integer :: a
  a = 0
  if (a == 1) then
    integer :: x, y
    x = 5
    y = 3
    x = x - y
    stop 1
  end if
end program
end program
    stop 1
  end if
