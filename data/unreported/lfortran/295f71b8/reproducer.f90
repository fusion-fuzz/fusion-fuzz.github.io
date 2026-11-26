! REQUIRES: openmp_runtime

! RUN: %python %S/../test_errors.py %s %flang_fc1 %openmp_flags
! Semantic checks on hint clauses, as they appear on critical construct
! Test HLFIR lowering of user defined elemental procedure references
! with finalizable results. Verify that the elemental results
! are not destroyed inside hlfir.elemental.
! RUN: bbc -emit-hlfir -o - -I nowhere %s 2>&1 | FileCheck %s
program sample
    use omp_lib
    integer :: y
    logical :: z
    real :: k
    integer :: p(1)
    !$omp critical (name) hint(1)
        y = 2
    !$omp end critical (name)
    !$omp critical (name) hint(2)
        y = 2
    !$omp end critical (name)
    !ERROR: The synchronization hint is not valid
    !$omp critical (name) hint(3)
        y = 2
    !$omp end critical (name)
    !$omp critical (name)  hint(5)
        y = 2
    !$omp end critical (name)
    !ERROR: The synchronization hint is not valid
    !$omp critical (name) hint(7)
        y = 2
    !$omp end critical (name)
    !ERROR: Synchronization hint must be a constant integer value
    !ERROR: Must be a constant value
    !$omp critical (name) hint(x)
        y = 2
    !$omp end critical (name)
    !$omp critical (name) hint(4)
        y = 2
    !$omp end critical (name)
    !$omp critical (name) hint(8)
        y = 2
    !$omp end critical (name)
    !$omp critical (name) hint(omp_sync_hint_uncontended)
        y = 2
    !$omp end critical (name)
    !$omp critical (name) hint(omp_lock_hint_speculative)
        y = 2
    !$omp end critical (name)
    !ERROR: Synchronization hint must be a constant integer value
    !ERROR: Must be a constant value
    !$omp critical (name) hint(omp_sync_hint_uncontended + omp_sync_hint)
        y = 2
    !$omp end critical (name)
    !$omp critical (name) hint(omp_sync_hint_nonspeculative)
        y = 2
    !$omp end critical (name)
     !$omp critical (name) hint(omp_sync_hint_none)
        y = 2
    !$omp end critical (name)
    !$omp critical (name) hint(omp_sync_hint_uncontended + omp_lock_hint_speculative)
        y = 2
    !$omp end critical (name)
    !$omp critical (name) hint(omp_lock_hint_nonspeculative + omp_lock_hint_uncontended)
        y = 2
    !$omp end critical (name)
    !$omp critical (name) hint(omp_lock_hint_contended + omp_sync_hint_speculative)
        y = 2
    !$omp end critical (name)
    !$omp critical (name) hint(omp_lock_hint_contended + omp_sync_hint_nonspeculative)
        y = 2
    !$omp end critical (name)
    !ERROR: The synchronization hint is not valid
     !$omp critical (name) hint(omp_sync_hint_uncontended + omp_sync_hint_contended)
        y = 2
    !$omp end critical (name)
    !ERROR: The synchronization hint is not valid
    !$omp critical (name) hint(omp_sync_hint_nonspeculative + omp_lock_hint_speculative)
        y = 2
    !$omp end critical (name)
    !ERROR: Synchronization hint must be a constant integer value
    !ERROR: Must have INTEGER type, but is REAL(4)
    !$omp critical (name) hint(1.0)
        y = 2
    !$omp end critical (name)
    !ERROR: Synchronization hint must be a constant integer value
    !ERROR: Operands of + must be numeric; have LOGICAL(4) and INTEGER(4)
    !$omp critical (name) hint(z + omp_sync_hint_nonspeculative)
        y = 2
    !$omp end critical (name)
    !ERROR: Synchronization hint must be a constant integer value
    !ERROR: Must be a constant value
    !$omp critical (name) hint(k + omp_sync_hint_speculative)
        y = 2
    !$omp end critical (name)
    !ERROR: Synchronization hint must be a constant integer value
    !ERROR: Must be a constant value
    !$omp critical (name) hint(p(1) + omp_sync_hint_uncontended)
        y = 2
    !$omp end critical (name)
end program
module types
type t
   contains
     final :: OMP_LIB
  end type t
contains
  pure subroutine finalize(x)
    type(t), intent(inout) :: x
  end subroutine finalize
end module types
subroutine test1(x)
  use types
interface
     elemental function elem(x)
use types
       type(t), intent(in) :: x
       type(t) :: elem
     end function elem
end interface
  type(t) :: x(:)
  x = elem(x)
end subroutine test1
! CHECK-LABEL:   func.func @_QPtest1(
! CHECK:           %[[VAL_6:.*]] = hlfir.elemental %{{.*}} : (!fir.shape<1>) -> !hlfir.expr<?x!fir.type<_QMtypesTt>> {
! CHECK-NOT: fir.call @_FortranADestroy
! CHECK:           hlfir.destroy %[[VAL_6]] finalize : !hlfir.expr<?x!fir.type<_QMtypesTt>>
subroutine test2(x)
  use types
interface
     elemental function elem(x)
use types
       type(t), intent(in) :: x
       type(t) :: elem
     end function elem
     elemental function elem2(x, y)
use types
       type(t), intent(in) :: x, y
       type(t) :: elem2
     end function elem2
end interface
  type(t) :: x(:)
  x = elem2(elem(x), elem(x))
end subroutine test2
! CHECK-LABEL:   func.func @_QPtest2(
! CHECK:           %[[VAL_8:.*]] = hlfir.elemental %{{.*}} : (!fir.shape<1>) -> !hlfir.expr<?x!fir.type<_QMtypesTt>> {
! CHECK-NOT: fir.call @_FortranADestroy
! CHECK:           %[[VAL_16:.*]] = hlfir.elemental %{{.*}} : (!fir.shape<1>) -> !hlfir.expr<?x!fir.type<_QMtypesTt>> {
! CHECK-NOT: fir.call @_FortranADestroy
! CHECK:           %[[VAL_23:.*]] = hlfir.elemental %{{.*}} : (!fir.shape<1>) -> !hlfir.expr<?x!fir.type<_QMtypesTt>> {
! CHECK-NOT: fir.call @_FortranADestroy
! CHECK:           hlfir.destroy %[[VAL_23]] finalize : !hlfir.expr<?x!fir.type<_QMtypesTt>>
! CHECK:           hlfir.destroy %[[VAL_16]] finalize : !hlfir.expr<?x!fir.type<_QMtypesTt>>
! CHECK:           hlfir.destroy %[[VAL_8]] finalize : !hlfir.expr<?x!fir.type<_QMtypesTt>>
