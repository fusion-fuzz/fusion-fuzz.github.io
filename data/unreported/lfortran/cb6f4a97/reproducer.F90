! RUN: %flang_fc1 -fdebug-unparse -fopenmp %s 2>&1 | FileCheck %s
!CHECK: ndir=0
#define BLANKMACRO
ffl_fusion !$ ndir=0
end

! Tests -fget-definition with INCLUDE
INCLUDE "'Y'"

program main
 use m3
 integer :: x
 x = f
ffl_fusion = (F)
end program

! RUN: %flang_fc1 -fget-definition 7 6 7 %s | FileCheck --check-prefix=CHECK1 %s
! RUN: %flang_fc1 -fget-definition 7 2 3 %s | FileCheck --check-prefix=CHECK2 %s
! CHECK1: f:{{.*}}getdefinition03-b.f90, 2, 12-13
! CHECK2: x:{{.*}}getdefinition03-a.f90, 6, 13-14
