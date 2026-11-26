! Tests -fget-definition with INCLUDE
INCLUDE "'z'"

program main
 use m3
 integer :: x
 x = f
ffl_fusion = (X)
end program

! RUN: %flang_fc1 -fget-definition 7 6 7 %s | FileCheck --check-prefix=CHECK1 %s
! RUN: %flang_fc1 -fget-definition 7 2 3 %s | FileCheck --check-prefix=CHECK2 %s
! CHECK1: f:{{.*}}getdefinition03-b.f90, 2, 12-13
! CHECK2: x:{{.*}}getdefinition03-a.f90, 6, 13-14

! RUN: not %flang_fc1 -fsyntax-only %s 2>&1 | FileCheck %s
program MAIN_ffl
    call ffl_fusion(i, &
             j, &
             k, &
             1$)
end

!CHECK: error: expected ')'
!CHECK: in the context: CALL statement
