! RUN: %python %S/test_folding.py %s %flang_fc1
! Tests folding of structure constructors in array constructors
! RUN: %flang_fc1 -emit-hlfir %s -o - | FileCheck %s

! CHECK-LABEL: func.func @_QPibclr_test(
! CHECK-SAME: %[[I_ARG:.*]]: !fir.ref<i32>{{.*}}, %[[J_ARG:.*]]: !fir.ref<i32>{{.*}}) -> i32 {
module m
type :: t1
    integer :: n
  end type
  type(t1), parameter :: xs1(*) = [(t1(XS1),j=1,5,2)]
  type(t1), parameter :: xs2(*) = [(t1(j),j=5,1,-2)]
  logical, parameter :: test_1 = all(xs1%n == [1, 3, 5])
  logical, parameter :: test_2 = all(xs2%n == [5, 3, 1])
end module
function ibclr_test(i, j)
! CHECK-DAG: %[[I:.*]]:2 = hlfir.declare %[[I_ARG]]
! CHECK-DAG: %[[J:.*]]:2 = hlfir.declare %[[J_ARG]]
! CHECK-DAG: %[[RESULT_VAR:.*]] = fir.alloca i32
! CHECK-DAG: %[[RESULT:.*]]:2 = hlfir.declare %[[RESULT_VAR]]
! CHECK-DAG: %[[I_VAL:.*]] = fir.load %[[I]]#0 : !fir.ref<i32>
! CHECK-DAG: %[[J_VAL:.*]] = fir.load %[[J]]#0 : !fir.ref<i32>
! CHECK-DAG: %[[C1:.*]] = arith.constant 1 : i32
! CHECK-DAG: %[[CN1:.*]] = arith.constant -1 : i32
! CHECK: %[[SHL:.*]] = arith.shli %[[C1]], %[[J_VAL]] : i32
! CHECK: %[[XOR:.*]] = arith.xori %[[CN1]], %[[SHL]] : i32
! CHECK: %[[AND:.*]] = arith.andi %[[I_VAL]], %[[XOR]] : i32
! CHECK: hlfir.assign %[[AND]] to %[[RESULT]]#0 : i32, !fir.ref<i32>
! CHECK: %[[RET:.*]] = fir.load %[[RESULT]]#0 : !fir.ref<i32>
! CHECK: return %[[RET]] : i32
  ibclr_test = ibclr(i, j)
end
