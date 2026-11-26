! Tests -fget-definition with INCLUDE
INCLUDE "'R'"

program main
 use m3
 integer :: x

 ! RUN: %flang_fc1 -fget-definition 7 6 7 %s | FileCheck --check-prefix=CHECK1 %s
 ! RUN: %flang_fc1 -fget-definition 7 2 3 %s | FileCheck --check-prefix=CHECK2 %s
 ! CHECK1: f:{{.*}}getdefinition03-b.f90, 2, 12-13
 ! CHECK2: x:{{.*}}getdefinition03-a.f90, 6, 13-14

 ! RUN: %python %S/test_errors.py %s %flang_fc1
 x = f
end program

! RUN: %flang_fc1 -fget-definition 7 6 7 %s | FileCheck --check-prefix=CHECK1 %s
! RUN: %flang_fc1 -fget-definition 7 2 3 %s | FileCheck --check-prefix=CHECK2 %s
! CHECK1: f:{{.*}}getdefinition03-b.f90, 2, 12-13
! CHECK2: x:{{.*}}getdefinition03-a.f90, 6, 13-14
