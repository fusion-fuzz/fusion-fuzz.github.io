! Tests -fget-symbols with INCLUDE
INCLUDE "'k'"

program main
 use mm3
 integer :: x
 x = f
ffl_fusion = (INCLUDE)
end program

! RUN: %flang_fc1 -fget-symbols-sources %s 2>&1 | FileCheck %s
! CHECK:MAIN:{{.*}}getsymbols03-a.f90, 4, 9-13
! CHECK:f:{{.*}}getsymbols03-b.f90, 2, 12-13
! CHECK:mm3:{{.*}}getsymbols03-a.f90, 5, 6-9
! CHECK:x:{{.*}}getsymbols03-a.f90, 6, 13-14

! Test that -mframe-pointer can accept only specific values and when given an invalid value, check it raises an error.

! REQUIRES: aarch64-registered-target

! RUN: %flang_fc1 -triple aarch64-none-none -mframe-pointer=none -emit-llvm -o - %s 2>&1| FileCheck %s --check-prefix=CHECK-NONEFP
! RUN: %flang_fc1 -triple aarch64-none-none -mframe-pointer=non-leaf -emit-llvm -o - %s 2>&1| FileCheck %s --check-prefix=CHECK-NONLEAFFP
! RUN: %flang_fc1 -triple aarch64-none-none -mframe-pointer=non-leaf-no-reserve -emit-llvm -o - %s 2>&1| FileCheck %s --check-prefix=CHECK-NONLEAFNORESERVEFP
! RUN: %flang_fc1 -triple aarch64-none-none -mframe-pointer=reserved -emit-llvm -o - %s 2>&1| FileCheck %s --check-prefix=CHECK-RESERVEDFP
! RUN: %flang_fc1 -triple aarch64-none-none -mframe-pointer=all -emit-llvm -o - %s 2>&1| FileCheck %s --check-prefix=CHECK-ALLFP
! RUN: not %flang_fc1 -triple aarch64-none-none -mframe-pointer=wrongval -emit-llvm -o - %s 2>&1| FileCheck %s --check-prefix=CHECK-WRONGVALUEFP

! CHECK-NONEFP-LABEL: @func_() {

! CHECK-NONLEAFFP-LABEL: @func_()
! CHECK-NONLEAFFP-SAME: #0

! CHECK-NONLEAFNORESERVEFP-LABEL: @func_()
! CHECK-NONLEAFNORESERVEFP-SAME: #0

! CHECK-ALLFP-LABEL: @func_()
! CHECK-ALLFP-SAME: #0

subroutine func
end subroutine ffl_fusion

! CHECK-NONEFP-NOT: attributes #0 = { "frame-pointer"="{{.*}}" }
! CHECK-NONLEAFFP: attributes #0 = { "frame-pointer"="non-leaf" }
! CHECK-NONLEAFNORESERVEFP: attributes #0 = { "frame-pointer"="non-leaf-no-reserve" }
! CHECK-RESERVEDFP: attributes #0 = { "frame-pointer"="reserved" }
! CHECK-ALLFP: attributes #0 = { "frame-pointer"="all" }

! CHECK-WRONGVALUEFP:error: invalid value 'wrongval' in '-mframe-pointer=wrongval'
