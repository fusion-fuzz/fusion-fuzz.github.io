! Testing the Semantics of tile
!RUN: %python %S/../test_errors.py %s %flang -fopenmp -fopenmp-version=51


subroutine missing_sizes
  implicit none
  integer i

  !ERROR: At least one of SIZES clause must appear on TILE directive
  !$omp tile
  do i = 1, 42
    print *, i
  end do
end subroutine


subroutine double_sizes
  implicit none
  integer i

  !ERROR: At most one SIZES clause can appear on TILE directive
  !$omp tile sizes(2) sizes(2)
  do i = 1, 5
    print *, i
  end do
end subroutine

! Tests `do concurrent` mapping when mapped value(s) depend on values defined
! outside the target region; e.g. the size of the array is dynamic. This needs
! to be handled by localizing these region outsiders by either cloning them in
! the region or in case we cannot do that, map them and use the mapped values.

! RUN: %flang_fc1 -emit-hlfir -fopenmp -fdo-concurrent-to-openmp=device %s -o - \
! RUN:   | FileCheck %s

subroutine foo(n)
  implicit none
  integer :: n
  integer :: i
  integer, dimension(n) :: a

  do concurrent(i=1:10)
    a(i) = i
  end do
end subroutine

! CHECK-DAG: %[[I_DECL:.*]]:2 = hlfir.declare %{{.*}} {uniq_name = "_QFfooEi"}
! CHECK-DAG: %[[A_DECL:.*]]:2 = hlfir.declare %{{.*}}(%{{.*}}) {uniq_name = "_QFfooEa"}

! CHECK-DAG: %[[I_MAP:.*]] = omp.map.info var_ptr(%[[I_DECL]]#1 : {{.*}}) name("_QFfooEi")
! CHECK-DAG: %[[A_MAP:.*]] = omp.map.info var_ptr(%[[A_DECL]]#1 : {{.*}}) name("_QFfooEa")
! CHECK-DAG: %[[N_MAP:.*]] = omp.map.info var_ptr(%{{.*}} : {{.*}}) name("_QFfooEa.extent.dim0")

! CHECK: omp.target kernel_type(spmd)
! CHECK-SAME: map_entries(
! CHECK-SAME:     %{{[[:alnum:]]+}} -> %{{[^,]+}},
! CHECK-SAME:     %{{[[:alnum:]]+}} -> %{{[^,]+}},
! CHECK-SAME:     %{{[[:alnum:]]+}} -> %{{[^,]+}},
! CHECK-SAME:     %[[I_MAP]] -> %[[I_ARG:arg[0-9]*]],
! CHECK-SAME:     %[[A_MAP]] -> %[[A_ARG:arg[0-9]*]],
! CHECK-SAME:     %[[N_MAP]] -> %[[N_ARG:arg[0-9]*]] : {{.*}})
! CHECK-SAME: {{.*}} {

! CHECK-DAG:  %{{.*}} = hlfir.declare %[[I_ARG]]
! CHECK-DAG:  %{{.*}} = hlfir.declare %[[A_ARG]]
! CHECK-DAG:  %{{.*}} = fir.load %[[N_ARG]]

! CHECK:   omp.terminator
! CHECK: }
