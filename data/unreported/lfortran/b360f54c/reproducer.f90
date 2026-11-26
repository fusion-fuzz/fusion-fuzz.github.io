! RUN: %flang_fc1 -fdebug-unparse %s 2>&1 | FileCheck %s
program main
  type t
    integer, allocatable :: ia(:)
  end type
  type(t) x
  integer, allocatable :: ja(:)
  allocate(ja(2:2))
  print *, cmplx(x, y)
  ! CHECK-DAG:  %[[X:.*]]:2 = hlfir.declare %[[VAL_0]]
  ! CHECK-DAG:  %[[Y:.*]]:2 = hlfir.declare %[[VAL_1]]
  ! CHECK:  %[[VAL_8:.*]] = fir.load %[[Y]]#0 : !fir.ref<!fir.box<!fir.ptr<f32>>>
  ! CHECK:  %[[VAL_9:.*]] = fir.box_addr %[[VAL_8]] : (!fir.box<!fir.ptr<f32>>) -> !fir.ptr<f32>
  ! CHECK:  %[[VAL_10:.*]] = fir.convert %[[VAL_9]] : (!fir.ptr<f32>) -> i64
  ! CHECK:  %[[VAL_11:.*]] = arith.constant 0 : i64
  ! CHECK:  %[[VAL_12:.*]] = arith.cmpi ne, %[[VAL_10]], %[[VAL_11]] : i64
  ! CHECK:  %[[VAL_7:.*]] = fir.load %[[X]]#0 : !fir.ref<f32>
  ! CHECK:  %[[VAL_13:.*]] = fir.if %[[VAL_12]] -> (f32) {
  ! CHECK:    %[[VAL_14:.*]] = fir.load %[[Y]]#0 : !fir.ref<!fir.box<!fir.ptr<f32>>>
  ! CHECK:    %[[VAL_15:.*]] = fir.box_addr %[[VAL_14]] : (!fir.box<!fir.ptr<f32>>) -> !fir.ptr<f32>
  ! CHECK:    %[[VAL_16:.*]] = fir.load %[[VAL_15]] : !fir.ptr<f32>
  ! CHECK:    fir.result %[[VAL_16]] : f32
  ! CHECK:  } else {
  ! CHECK:    %[[VAL_17:.*]] = arith.constant 0.000000e+00 : f32
  ! CHECK:    fir.result %[[VAL_17]] : f32
  ! CHECK:  }
  ! CHECK:  %[[VAL_18:.*]] = fir.undefined complex<f32>
  ! CHECK:  %[[VAL_19:.*]] = fir.insert_value %[[VAL_18]], %[[VAL_7]], [0 : index] : (complex<f32>, f32) -> complex<f32>
  ! CHECK:  %[[VAL_20:.*]] = fir.insert_value %[[VAL_19]], %[[VAL_13]], [1 : index] : (complex<f32>, f32) -> complex<f32>
  ja(2) = 2
  !CHECK: x=t(ia=(ja))
  x = t(+ja)            ! must be t(ia=(ja)), not t(ia=ja)
  print *, lbound(x%ia) ! must be 1, not 2
end
