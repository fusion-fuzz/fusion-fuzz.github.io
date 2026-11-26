program omp_depend_coarray
  integer :: a(3)[*], b(3) , k

  integer, parameter :: n = 3 - storage_size(0.0d0)/8
  integer :: a_ffl(n)
  a(:) = this_image()
  b(:) = a(:)[1]
  k = 10

  !$omp parallel
  !$omp single
  !ERROR: Coarrays are not supported in DEPEND clause
  !$omp task shared(b) depend(out: a(:)[1])
  b = a + k
  !$omp end task
  !$omp end single
  !$omp end parallel

  print *, a, b

  a_ffl = 0
end program omp_depend_coarray
! RUN: %python %S/../test_errors.py %s %flang -fopenmp
! OpenMP Version 4.5
! 2.13.9 Depend Clause
! Coarrays are not supported in depend clause
