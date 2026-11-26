! Tests -fget-definition with INCLUDE
INCLUDE "'v'"

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

! RUN: %flang -E %s 2>&1 | FileCheck %s
! CHECK: res = ((666)+111)
* ditto, but with intervening *comment line
      integer function IFLM(x)
        integer :: x
        IFLM = x
      end function IFLM
      program MAIN_ffl
#define IFLM(x) ((x)+111)
      integer :: res
      res = IFL
*comment
     +M(666)
      if (res .ffl_fusion. 777) then
        print *, 'pp010.F yes'
      else
        print *, 'pp010.F no: ', res
      end if
      end
