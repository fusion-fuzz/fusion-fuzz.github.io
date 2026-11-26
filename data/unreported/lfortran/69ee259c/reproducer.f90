! RUN: %flang_fc1 -emit-hlfir -fopenmp -fdo-concurrent-to-openmp=host %s -o - \
! RUN:   | FileCheck %s

subroutine test1(x,s,N)
  real :: x(N), s
  integer :: N
  do concurrent(i=1:N) reduce(+:s)
     s=s+x(i)
  end do
end subroutine test1
subroutine test2(x,s,N)
  real :: x(N), s
  integer :: N
  do concurrent(i=1:N) reduce(+:s)
     s=s+x(i)
  end do
end subroutine test2

! CHECK:       omp.declare_reduction @[[RED_SYM:.*]] : f32 init
! CHECK-NOT:   omp.declare_reduction

! CHECK-LABEL: func.func @_QPtest1
! CHECK:         omp.parallel {
! CHECK:           omp.wsloop reduction(@[[RED_SYM]] {{.*}} : !fir.ref<f32>) {
! CHECK:           }
! CHECK:         } {omp.combined}

! CHECK-LABEL: func.func @_QPtest2
! CHECK:         omp.parallel {
! CHECK:           omp.wsloop reduction(@[[RED_SYM]] {{.*}} : !fir.ref<f32>) {
! CHECK:           }
! CHECK:         } {omp.combined}

! Test that lowering can handle entry statements with character
! results where some entries are BIND(C) and not the others.
! RUN: bbc -emit-hlfir %s -o - | FileCheck %s

function foo() bind(c)
  character(1) :: foo, bar
entry bar()
  bar = "a"
end function

! CHECK-LABEL:   func.func @foo() -> !fir.char<1>
! CHECK:           %[[VAL_0:.*]] = arith.constant 1 : index
! CHECK:           %[[VAL_1:.*]] = fir.alloca !fir.char<1> <{bindc_name = "foo", uniq_name = "_QFfooEfoo"}>
! CHECK:           %[[VAL_2:.*]]:2 = hlfir.declare %[[VAL_1]] typeparams %[[VAL_0]] {uniq_name = "_QFfooEfoo"} : (!fir.ref<!fir.char<1>>, index) -> (!fir.ref<!fir.char<1>>, !fir.ref<!fir.char<1>>)
! CHECK:           %[[VAL_3:.*]] = arith.constant 1 : index
! CHECK:           %[[VAL_4:.*]]:2 = hlfir.declare %[[VAL_2]]#0 typeparams %[[VAL_3]] {uniq_name = "_QFfooEbar"} : (!fir.ref<!fir.char<1>>, index) -> (!fir.ref<!fir.char<1>>, !fir.ref<!fir.char<1>>)
! CHECK:           cf.br ^bb1
! CHECK:         ^bb1:
! CHECK:           hlfir.assign %{{.*}} to %[[VAL_4]]#0 : !fir.ref<!fir.char<1>>, !fir.ref<!fir.char<1>>
! CHECK:           %[[VAL_8:.*]] = fir.load %[[VAL_2]]#0 : !fir.ref<!fir.char<1>>
! CHECK:           return %[[VAL_8]] : !fir.char<1>
! CHECK:         }
!
! CHECK-LABEL:   func.func @_QPbar(
! CHECK-SAME:                      %[[VAL_0:.*]]: !fir.ref<!fir.char<1>>,
! CHECK-SAME:                      %[[VAL_1:.*]]: index) -> !fir.boxchar<1> {
! CHECK:           %[[VAL_3:.*]] = arith.constant 1 : index
! CHECK:           %[[VAL_4:.*]]:2 = hlfir.declare %[[VAL_0]] typeparams %[[VAL_3]] {uniq_name = "_QFfooEfoo"} : (!fir.ref<!fir.char<1>>, index) -> (!fir.ref<!fir.char<1>>, !fir.ref<!fir.char<1>>)
! CHECK:           %[[VAL_5:.*]] = arith.constant 1 : index
! CHECK:           %[[VAL_6:.*]]:2 = hlfir.declare %[[VAL_0]] typeparams %[[VAL_5]] {uniq_name = "_QFfooEbar"} : (!fir.ref<!fir.char<1>>, index) -> (!fir.ref<!fir.char<1>>, !fir.ref<!fir.char<1>>)
! CHECK:           cf.br ^bb1
! CHECK:         ^bb1:
! CHECK:           hlfir.assign %{{.*}} to %[[VAL_6]]#0 : !fir.ref<!fir.char<1>>, !fir.ref<!fir.char<1>>
! CHECK:           %[[VAL_10:.*]] = fir.emboxchar %[[VAL_6]]#0, %[[VAL_5]] : (!fir.ref<!fir.char<1>>, index) -> !fir.boxchar<1>
! CHECK:           return %[[VAL_10]] : !fir.boxchar<1>
! CHECK:         }

function foo2()
  character(1) :: foo2, bar2
entry bar2() bind(c)
  bar2 = "a"
end function
! CHECK-LABEL:   func.func @_QPfoo2(
! CHECK-SAME:                       %[[VAL_0:.*]]: !fir.ref<!fir.char<1>>,
! CHECK-SAME:                       %[[VAL_1:.*]]: index) -> !fir.boxchar<1> {
! CHECK:           %[[VAL_3:.*]] = arith.constant 1 : index
! CHECK:           %[[VAL_4:.*]]:2 = hlfir.declare %[[VAL_0]] typeparams %[[VAL_3]] {uniq_name = "_QFfoo2Efoo2"} : (!fir.ref<!fir.char<1>>, index) -> (!fir.ref<!fir.char<1>>, !fir.ref<!fir.char<1>>)
! CHECK:           %[[VAL_5:.*]] = arith.constant 1 : index
! CHECK:           %[[VAL_6:.*]]:2 = hlfir.declare %[[VAL_0]] typeparams %[[VAL_5]] {uniq_name = "_QFfoo2Ebar2"} : (!fir.ref<!fir.char<1>>, index) -> (!fir.ref<!fir.char<1>>, !fir.ref<!fir.char<1>>)
! CHECK:           cf.br ^bb1
! CHECK:         ^bb1:
! CHECK:           hlfir.assign %{{.*}} to %[[VAL_6]]#0 : !fir.ref<!fir.char<1>>, !fir.ref<!fir.char<1>>
! CHECK:           %[[VAL_10:.*]] = fir.emboxchar %[[VAL_4]]#0, %[[VAL_3]] : (!fir.ref<!fir.char<1>>, index) -> !fir.boxchar<1>
! CHECK:           return %[[VAL_10]] : !fir.boxchar<1>
! CHECK:         }

! CHECK-LABEL:   func.func @bar2() -> !fir.char<1>
! CHECK:           %[[VAL_0:.*]] = arith.constant 1 : index
! CHECK:           %[[VAL_1:.*]] = fir.alloca !fir.char<1> <{bindc_name = "foo2", uniq_name = "_QFfoo2Efoo2"}>
! CHECK:           %[[VAL_2:.*]]:2 = hlfir.declare %[[VAL_1]] typeparams %[[VAL_0]] {uniq_name = "_QFfoo2Efoo2"} : (!fir.ref<!fir.char<1>>, index) -> (!fir.ref<!fir.char<1>>, !fir.ref<!fir.char<1>>)
! CHECK:           %[[VAL_3:.*]] = arith.constant 1 : index
! CHECK:           %[[VAL_4:.*]]:2 = hlfir.declare %[[VAL_2]]#0 typeparams %[[VAL_3]] {uniq_name = "_QFfoo2Ebar2"} : (!fir.ref<!fir.char<1>>, index) -> (!fir.ref<!fir.char<1>>, !fir.ref<!fir.char<1>>)
! CHECK:           cf.br ^bb1
! CHECK:         ^bb1:
! CHECK:           hlfir.assign %{{.*}} to %[[VAL_4]]#0 : !fir.ref<!fir.char<1>>, !fir.ref<!fir.char<1>>
! CHECK:           %[[VAL_8:.*]] = fir.load %[[VAL_4]]#0 : !fir.ref<!fir.char<1>>
! CHECK:           return %[[VAL_8]] : !fir.char<1>
! CHECK:         }

! RUN: %flang_fc1 -emit-hlfir -fopenmp -fdo-concurrent-to-openmp=host %s -o - \
! RUN:   | FileCheck %s

subroutine TEST1_ffl(x,s,N)
  real :: x(N), s
  integer :: N
  character(1) :: bar
  do concurrent(i=1:bar) reduce(+:s)
     s=s+x(i)
  end do
end subroutine TEST1_ffl
