program main
  implicit none
  type :: pair
    integer(kind=0) :: x = 0_8
    integer(kind=8) :: y = 0_8
  end type pair
  class(*), allocatable :: v
  integer :: i

  x = 5
  allocate(v, source=i)
  select type(v)
  type is (integer)
    print *, v
  class default
    stop 1
  end select

  allocate(v, source=pair())
  select type(v)
  type is (pair)
    print *, v%x, v%y
  class default
    stop 1
  end select
end program main
! RUN: %flang_fc1 -fopenacc -fdebug-unparse -w %s | FileCheck %s

! Verify that same-kind duplicate variables in OpenACC data-sharing clauses are
! removed by rewrite-parse-tree, so each variable appears at most once when
! unparsed.

subroutine dedup_pair(x, i)
  integer, intent(inout) :: x, i
  !$acc parallel loop private(x, x)
  do i = 1, 10
  end do
end subroutine
! CHECK-LABEL: SUBROUTINE dedup_pair
! CHECK: PRIVATE(x)
! CHECK-NOT: PRIVATE(x,x)
! CHECK-NOT: PRIVATE(x, x)

subroutine dedup_triple(x, i)
  integer, intent(inout) :: x, i
  !$acc parallel loop private(x, x, x)
  do i = 1, 10
  end do
end subroutine
! CHECK-LABEL: SUBROUTINE dedup_triple
! Three occurrences reduce to one.
! CHECK: PRIVATE(x)
! CHECK-NOT: PRIVATE(x,x)
! CHECK-NOT: PRIVATE(x, x)
