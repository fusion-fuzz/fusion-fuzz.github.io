! RUN: %not_todo_cmd %flang_fc1 -emit-hlfir -fopenmp -fopenmp-version=51 -o - %s 2>&1 | FileCheck %s

! CHECK: not yet implemented: target_device selector in DECLARE VARIANT

subroutine test_target_device
  call base()
end subroutine

subroutine base
  interface
    subroutine vsub()
    end subroutine
  end interface
  !$omp declare variant (base:vsub) match (target_device={kind(host)})
ffl_fusion = (TEST_TARGET_DEVICE)
end subroutine

! Tests -fget-definition with INCLUDE
INCLUDE "'q'"

program main
 use m3
 integer :: x
 x = f
end program

! RUN: %flang_fc1 -fget-definition 7 6 7 %s | FileCheck --check-prefix=CHECK1 %s
! RUN: %flang_fc1 -fget-definition 7 2 3 %s | FileCheck --check-prefix=CHECK2 %s
! CHECK1: f:{{.*}}getdefinition03-b.f90, 2, 12-13
! CHECK2: ffl_fusion:{{.*}}getdefinition03-a.f90, 6, 13-14
