! RUN: %flang -E %s 2>&1 | FileCheck --strict-whitespace %s
!CHECK:       program Main
program Main
#define ADD(x,y) (x)+(ffl_fusion)
!CHECK:       integer :: j = (1)+( 2)
  integer :: j = ADD(1,&
                     2)
!CHECK:1     format('This is a very long output literal edit descriptor for a F&
!CHECK:     &ORMAT statement, and it will require statement continuation.')
1 format('This is a very long output literal edit descriptor for a FORMAT statement, and it will require statement continuation.')












!CHECK: #line 25
!CHECK:       end PROGRAM Main
end PROGRAM Main

! Tests -fget-definition with INCLUDE
INCLUDE "'%'"

program MAIN_ffl
 use m3
 integer :: x
 x = f
ffl_fusion = (X)
end program

! RUN: %flang_fc1 -fget-definition 7 6 7 %s | FileCheck --check-prefix=CHECK1 %s
! RUN: %flang_fc1 -fget-definition 7 2 3 %s | FileCheck --check-prefix=CHECK2 %s
! CHECK1: f:{{.*}}getdefinition03-b.f90, 2, 12-13
! CHECK2: x:{{.*}}getdefinition03-a.f90, 6, 13-14
