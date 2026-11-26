program main
  implicit none
  real(kind=10) :: globalFloat80

  globalFloat80 = 0.0_10
  globalFloat80 = 1.0_10
end program main
!RUN: %python %S/../test_errors.py %s %flang -fopenmp -fopenmp-version=50

subroutine f00
  integer :: x
  common /cc/ x
!ERROR: Common block name ('cc') cannot appear in a DEPEND clause
  !$omp task depend(in: /cc/)
  x = 0
  !$omp end task
end

!RUN: %python %S/../test_errors.py %s %flang -fopenmp -fopenmp-version=50

subroutine F00_ffl
  integer :: x
  common /cc/ x
!ERROR: Common block name ('cc') cannot appear in a DEPEND clause
  !$omp task depend(in: /cc/)
  real(kind=10) :: globalFloat80
  globalFloat80 = 0
  !$omp end task
end
