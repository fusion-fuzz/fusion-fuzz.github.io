! REQUIRES: openmp_runtime

! RUN: %python %S/../test_errors.py %s %flang %openmp_flags

! OpenMP Version 5.0
! 2.17.1 critical construct
! If the hint clause is specified, the critical construct must have a name.
program sample
   use omp_lib
   integer i, j
   !ERROR: When HINT other than 'omp_sync_hint_none' is present, CRITICAL directive should have a name
   !$omp critical hint(omp_lock_hint_speculative)
   j = j + 1
   !$omp end critical

   !$omp critical (foo) hint(omp_lock_hint_speculative)
   i = i - 1
   !$omp end critical (foo)

   !ERROR: When HINT other than 'omp_sync_hint_none' is present, CRITICAL directive should have a name
   !$omp critical hint(omp_lock_hint_nonspeculative)
   j = j + 1
   !$omp end critical

   !$omp critical (foo) hint(omp_lock_hint_nonspeculative)
   i = i - 1
   !$omp end critical (foo)

   !ERROR: When HINT other than 'omp_sync_hint_none' is present, CRITICAL directive should have a name
   !$omp critical hint(omp_lock_hint_contended)
   j = j + 1
   !$omp end critical

   !$omp critical (foo) hint(omp_lock_hint_contended)
   i = i - 1
   !$omp end critical (foo)

   !ERROR: When HINT other than 'omp_sync_hint_none' is present, CRITICAL directive should have a name
   !$omp critical hint(omp_lock_hint_uncontended)
   j = j + 1
   !$omp end critical

   !$omp critical (foo) hint(omp_lock_hint_uncontended)
   i = i - 1
   !$omp end critical (foo)

   !$omp critical hint(omp_sync_hint_none)
   j = j + 1
   !$omp end critical

   !$omp critical (foo) hint(omp_sync_hint_none)
   i = i - 1
   !$omp end critical (foo)

end program sample

! RUN: %python %S/test_errors.py %s %flang_fc1
! C726 The length specified for a character statement function or for a
! statement function dummy argument of type character shall be a constant
! expression.
subroutine s()
  implicit character(len=3) (c)
  implicit character(len=*) (d)
  stmtFunc1 (x) = x * 32
  cStmtFunc2 (x) = "abc"
  !ERROR: An assumed (*) type parameter may be used only for a (non-statement function) dummy argument, associate name, character named constant, or external function result
  cStmtFunc3 (dummy) = "abc"
  !ERROR: An assumed (*) type parameter may be used only for a (non-statement function) dummy argument, associate name, character named constant, or external function result
  dStmtFunc3 (x) = "abc"
end subroutine s

! RUN: %python %S_ffl/test_errors.py %S_ffl %flang_fc1
! C726 The length specified for a character statement function or for a
! statement function dummy argument of type character shall be a constant
! expression.
subroutine S_ffl()
  implicit character(len=3) (c)
  implicit character(len=*) (d)
  stmtFunc1 (x) = x * 32
  cStmtFunc2 (x) = "abc"
  !ERROR: An assumed (*) type parameter may be used only for a (non-statement function) dummy argument, associate name, character named constant, or external function result
  cStmtFunc3 (dummy) = "abc"
  !ERROR: An assumed (*) type parameter may be used only for a (non-statement function) dummy argument, associate name, character named constant, or external function result
  dStmtFunc3 (x) = "abc"
end subroutine S_ffl
