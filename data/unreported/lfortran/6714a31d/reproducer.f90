! RUN: %python %S/test_errors.py %s %flang_fc1
subroutine test1
  !WARNING: Generic interface 'foo' has both a function and a subroutine [-Wsubroutine-and-function-specifics]
  interface foo
    subroutine s1(x)
    end subroutine
    subroutine s2(x, y)
    end subroutine
    function f()
    end function
  end interface
end subroutine

subroutine test2
  !WARNING: Generic interface 'foo' has both a function and a subroutine [-Wsubroutine-and-function-specifics]
  interface foo
    function t2f1(x)
    end function
    subroutine s()
    end subroutine
    function t2f2(x, y)
    end function
  end interface
end subroutine

module test3
  !WARNING: Generic interface 'foo' has both a function and a subroutine [-Wsubroutine-and-function-specifics]
  interface foo
    module procedure s
    module procedure f
  end interface
contains
  subroutine s(x)
  end subroutine
  function f()
  end function
end module

subroutine test4
  type foo
  end type
  !WARNING: Generic interface 'foo' should only contain functions due to derived type with same name [-Wsubroutine-and-function-specifics]
  interface foo
    subroutine s()
    end subroutine
  end interface
end subroutine

subroutine test5
  interface foo
    function t5f1()
    end function
  end interface
  interface bar
    subroutine t5s1()
    end subroutine
    subroutine t5s2(x)
    end subroutine
  end interface
  !ERROR: Cannot call function 'foo' like a subroutine
  call foo()
  !ERROR: Cannot call subroutine 'bar' like a function
  x = bar()
end subroutine

! Tests that when a loop bound is used in the body, that the mapped version of
! the loop bound (rather than the host-eval one) is the one used inside the loop.

! RUN: %flang_fc1 -emit-hlfir -fopenmp -fdo-concurrent-to-openmp=device %s -o - \
! RUN:   | FileCheck %s
! RUN: bbc -emit-hlfir -fopenmp -fdo-concurrent-to-openmp=device %s -o - \
! RUN:   | FileCheck %s

subroutine foo(a, n)
  implicit none
  integer :: i, n
  real, dimension(n) :: a

  do concurrent (i=1:n)
    a(i) = n
  end do
end subroutine

! CHECK-LABEL: func.func @_QPfoo
! CHECK: omp.target kernel_type(spmd)
! CHECK-SAME: host_eval(%{{.*}} -> %{{.*}}, %{{.*}} -> %[[N_HOST_EVAL:.*]], %{{.*}} -> %{{.*}} : index, index, index)
! CHECK-SAME: map_entries({{[^[:space:]]*}} -> {{[^[:space:]]*}},
! CHECK-SAME:   {{[^[:space:]]*}} -> {{[^[:space:]]*}}, {{[^[:space:]]*}} -> {{[^[:space:]]*}},
! CHECK-SAME:   {{[^[:space:]]*}} -> {{[^[:space:]]*}}, {{[^[:space:]]*}} -> %[[N_MAP_ARG:[^[:space:]]*]], {{.*}}) {
! CHECK:   %[[N_MAPPED:.*]]:2 = hlfir.declare %[[N_MAP_ARG]] {uniq_name = "_QFfooEn"}
! CHECK:   omp.teams {
! CHECK:     omp.parallel {
! CHECK:       omp.distribute {
! CHECK:         omp.wsloop {
! CHECK:           omp.loop_nest (%{{.*}}) : index = (%{{.*}}) to (%[[N_HOST_EVAL]]) inclusive step (%{{.*}}) {
! CHECK:             %[[N_VAL:.*]] = fir.load %[[N_MAPPED]]#0 : !fir.ref<i32>
! CHECK:             %[[N_VAL_CVT:.*]] = fir.convert %[[N_VAL]] : (i32) -> f32
! CHECK:             hlfir.assign %[[N_VAL_CVT]] to {{.*}}
! CHECK-NEXT:        omp.yield
! CHECK:           }
! CHECK:         } {omp.composite}
! CHECK:       } {omp.composite}
! CHECK:     } {omp.composite}
! CHECK:   } {omp.combined}
! CHECK: } {omp.combined}
