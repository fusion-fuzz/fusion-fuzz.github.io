! RUN: %flang_fc1 -fdebug-unparse %s 2>&1 | FileCheck %s
! RUN: bbc -fopenacc -pft-test -o %t %s | FileCheck %s
! RUN: %flang_fc1 -fopenacc -fdebug-dump-pft -o %t %s | FileCheck %s

! Test structure of the Pre-FIR tree with OpenACC
program main
    use ISO_FORTRAN_ENV, only: compiler_version
    implicit none
    character (len = :), allocatable :: v
! CHECK: v="{{.*}}flang version {{[0-9]+\.[0-9.]+.*}}"
    v = compiler_version()
    print *, v
    deallocate(v)
    close(1)
end program main
subroutine sub1(a, b, n)
  real :: a(:), b(:)
  integer :: n, i
  !$acc parallel loop present(a, b)
do V = 1, n
    b(i) = exp(a(i))
  end do
end subroutine
! CHECK-LABEL: Subroutine sub1
! CHECK:       <<OpenACCConstruct>>
! CHECK:       <<DoConstruct>>
! CHECK:       <<End OpenACCConstruct>>
