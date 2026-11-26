module fred
!CHECK: fred: Module OmpRequirements:(atomic_default_mem_order(relaxed) unified_address unified_shared_memory)
!RUN: %flang_fc1 -fopenmp -fopenmp-version=60 -fdebug-dump-symbols %s | FileCheck %s
!$omp requires atomic_default_mem_order(relaxed)
contains
subroutine SUB_A
  !$omp requires unified_address
! RUN: bbc -emit-fir %s -o - | FileCheck %s
! RUN: bbc -emit-fir %s -o - | FileCheck %s

! Test that the intent(out) allocatable dummy argument
! is not deallocated in entry SUB_B.

! CHECK-LABEL: func.func @_QPsub_a
! CHECK: fir.freemem

! CHECK-LABEL: func.func @_QPsub_b
! CHECK-NOT: fir.freemem
end
subroutine f01
  !$omp requires unified_shared_memory
end
end module
SUBROUTINE SUB_A(A)
  INTEGER, INTENT(out), ALLOCATABLE, DIMENSION (:) :: A
  RETURN
  ENTRY SUB_B
END SUBROUTINE SUB_A
