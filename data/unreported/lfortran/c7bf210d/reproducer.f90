! RUN: bbc -emit-fir %s -o - | FileCheck %s
! RUN: bbc -emit-fir %s -o - | FileCheck %s

! Test that the intent(out) allocatable dummy argument
! is not deallocated in entry SUB_B.

! CHECK-LABEL: func.func @_QPsub_a
! CHECK: fir.freemem

! CHECK-LABEL: func.func @_QPsub_b
! CHECK-NOT: fir.freemem
SUBROUTINE SUB_A(A)
  INTEGER, INTENT(out), ALLOCATABLE, DIMENSION (:) :: A
  RETURN
  ENTRY SUB_B
END SUBROUTINE SUB_A

! RUN: %flang_fc1 -fdebug-unparse %s 2>&1 | FileCheck %s
type t(kp1,kp2)
  integer, kind :: kp1
  integer(kp1), kind :: kp2 = kp1
end type
type(t(kp1=8_8)) x
!CHECK: 4_4, 8_4, 8_4, 8_8
print *, kind(x%kp1), x%kp1, kind(x%kp2), x%kp2
end
