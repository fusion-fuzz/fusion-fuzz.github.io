! RUN: %python %S/../test_errors.py %s %flang_fc1 -fopenmp
! OpenMP Version 5.2
! Minus operation is deprecated in reduction
end
subroutine reduction_subtract
  integer :: x
  !ERROR: The minus reduction operator is deprecated since OpenMP 5.2 and is not supported in the REDUCTION clause.
  !$omp do reduction(-:x)
! RUN: %flang_fc1 -fsyntax-only -pedantic %s 2>&1 | FileCheck --allow-empty %s
! CHECK-NOT: error:
! Regression test for https://github.com/llvm/llvm-project/issues/124191
character(3) :: arr(5) = ['aa.', 'bb.', 'cc.', 'dd.', 'ee.']
arr([(mod(iachar(arr(i:i-1:-1)(1:1)),5)+1, ARR=2,5,3)]) = arr(5:2:-1)
do i=1, 100
    !$omp end do
    x = x - i
  end do
  !$omp end do
end subroutine
