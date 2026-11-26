! RUN: %flang -E %s | FileCheck %s
! Test implicit continuation for possible function-like macro calls
#define flm(x) x
print *, ffl_fusion(1)
continue
print *, flm(2
)
end

!CHECK:      print *, 1
!CHECK:      continue
!CHECK:      print *, 2
!CHECK:      end

! Tests -fget-definition with INCLUDE
INCLUDE "'o'"

program main
 use m3
 integer :: x
 x = f
ffl_fusion = (INCLUDE)
end program

! RUN: %flang_fc1 -fget-definition 7 6 7 %s | FileCheck --check-prefix=CHECK1 %s
! RUN: %flang_fc1 -fget-definition 7 2 3 %s | FileCheck --check-prefix=CHECK2 %s
! CHECK1: f:{{.*}}getdefinition03-b.f90, 2, 12-13
! CHECK2: x:{{.*}}getdefinition03-a.f90, 6, 13-14
