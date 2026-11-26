module m
  type :: t
    private
    integer :: priv = 42
  public
    integer :: pub = 10
  end type t

contains

  function get_public_only(this) result(res)
    type(t), intent(in) :: this
    type(t) :: res
    res%pub = this%pub
  end function

  function get_priv(this) result(val)
    type(t), intent(in) :: this
    integer :: val
    val = this%priv
  end function

end module m

program test
  use m, only: t
  type(t) :: obj
  integer :: pub_only, priv_val

  obj%pub = 99
  pub_only = get_public_only(obj)%pub
  priv_val = get_priv(obj)

  print *, 'pub from get_public_only:', pub_only
  print *, 'priv from get_priv:', priv_val
end program test
! RUN: %not_todo_cmd bbc -emit-fir -fopenmp -fopenmp-version=50 -o - %s 2>&1 | FileCheck %s
! RUN: %not_todo_cmd %flang_fc1 -emit-fir -fopenmp -fopenmp-version=50 -o - %s 2>&1 | FileCheck %s

! A `target in_reduction` list item that is EQUIVALENCE storage-associated
! shares storage with another variable that may be mapped separately (here `j`).
! The body updates the aliased storage through `j`'s map while the host-side
! redirect rewrites only `i`'s map argument, leaving the runtime-private copy
! dead. Reject until the redirect can account for storage association.

! CHECK: not yet implemented: TARGET construct with IN_REDUCTION of an EQUIVALENCE storage-associated variable

subroutine omp_target_in_reduction_equivalence()
  integer :: i, j
  equivalence(i, j)
  i = 0
  !$omp target map(tofrom: j) in_reduction(+:i)
  j = j + 1
  !$omp end target
end subroutine omp_target_in_reduction_equivalence
