! Test passing polymorphic expression for non-polymorphic contiguous
! dummy argument:
! RUN: bbc -emit-hlfir -o - -I nowhere %s | FileCheck %s
! RUN: bbc -emit-fir %s -o - | FileCheck %s

! Test propagation of Fortran attributes to FIR.


! CHECK-LABEL: func @_QPfoo1(
! CHECK-SAME: %arg0: !fir.ref<f32> {fir.bindc_name = "x", fir.optional},
! CHECK-SAME: %arg1: !fir.box<!fir.array<?xf32>> {fir.bindc_name = "y", fir.optional},
! CHECK-SAME: %arg2: !fir.ref<!fir.box<!fir.heap<!fir.array<?xi32>>>> {fir.bindc_name = "i", fir.optional},
! CHECK-SAME: %arg3: !fir.boxchar<1> {fir.bindc_name = "c", fir.optional}
subroutine foo1(x, y, i, c)
  real, optional :: x, y(:)
  integer, allocatable, optional :: i(:)
  character, optional :: c
end subroutine
! CHECK-LABEL: func @_QPfoo2(
! CHECK-SAME: %arg0: !fir.box<!fir.array<?xf32>> {fir.bindc_name = "x", fir.contiguous},
! CHECK-SAME: %arg1: !fir.ref<!fir.box<!fir.ptr<!fir.array<?xi32>>>> {fir.bindc_name = "i", fir.contiguous}
subroutine foo2(x, i)
  real, contiguous :: x(:)
  integer, pointer, contiguous :: i(:)
end subroutine
! CHECK-LABEL: func @_QPfoo3
! CHECK-SAME: %arg0: !fir.box<!fir.array<?xf32>> {fir.bindc_name = "x", fir.contiguous, fir.optional}
subroutine foo3(x)
  real, optional, contiguous :: x(:)
end subroutine
! CHECK-LABEL: func @_QPfoo4
! CHECK-SAME: %arg0: !fir.ref<f32> {fir.bindc_name = "x", fir.target}
! CHECK-SAME: %arg1: !fir.ref<f32> {fir.asynchronous, fir.bindc_name = "y"}
subroutine foo4(x, y)
  real, target :: x
  real, asynchronous :: y
end subroutine
module types
type t
  end type t
contains
  subroutine callee(x)
    type(t), intent(in) :: x(:)
  end subroutine callee
end module types
subroutine test1(x)
  use types
  class(t), intent(in) :: x(:)
  call FOO3(cshift(x, 1))
end subroutine test1
! CHECK-LABEL:   func.func @_QPtest1(
! CHECK:           %[[VAL_4:.*]] = arith.constant 1 : i32
! CHECK:           %[[VAL_23:.*]] = hlfir.cshift %{{.*}} %[[VAL_4]] : (!fir.class<!fir.array<?x!fir.type<_QMtypesTt>>>, i32) -> !hlfir.expr<?x!fir.type<_QMtypesTt>?>
! CHECK:           %[[VAL_26:.*]] = hlfir.shape_of %[[VAL_23]] : (!hlfir.expr<?x!fir.type<_QMtypesTt>?>) -> !fir.shape<1>
! CHECK:           %[[VAL_27:.*]]:3 = hlfir.associate %[[VAL_23]](%[[VAL_26]]) {adapt.valuebyref} : (!hlfir.expr<?x!fir.type<_QMtypesTt>?>, !fir.shape<1>) -> (!fir.class<!fir.array<?x!fir.type<_QMtypesTt>>>, !fir.class<!fir.array<?x!fir.type<_QMtypesTt>>>, i1)
! CHECK:           %[[VAL_28:.*]] = fir.rebox %[[VAL_27]]#0 : (!fir.class<!fir.array<?x!fir.type<_QMtypesTt>>>) -> !fir.box<!fir.array<?x!fir.type<_QMtypesTt>>>
! CHECK:           %[[VAL_29:.*]]:2 = hlfir.copy_in %[[VAL_28]] to %[[TMP_BOX:.*]] : (!fir.box<!fir.array<?x!fir.type<_QMtypesTt>>>, !fir.ref<!fir.box<!fir.heap<!fir.array<?x!fir.type<_QMtypesTt>>>>>) -> (!fir.box<!fir.array<?x!fir.type<_QMtypesTt>>>, i1)
! CHECK:           fir.call @_QMtypesPcallee(%[[VAL_29]]#0) fastmath<contract> : (!fir.box<!fir.array<?x!fir.type<_QMtypesTt>>>) -> ()
! CHECK:           hlfir.copy_out %[[TMP_BOX]], %[[VAL_29]]#1 : (!fir.ref<!fir.box<!fir.heap<!fir.array<?x!fir.type<_QMtypesTt>>>>>, i1) -> ()
! CHECK:           hlfir.end_associate %[[VAL_27]]#0, %[[VAL_27]]#2 : !fir.class<!fir.array<?x!fir.type<_QMtypesTt>>>, i1
! CHECK:           hlfir.destroy %[[VAL_23]] : !hlfir.expr<?x!fir.type<_QMtypesTt>?>
subroutine test2(x)
  use types
  class(t), intent(in) :: x(:)
  call callee((x))
end subroutine test2
! CHECK-LABEL:   func.func @_QPtest2(
! CHECK:           %[[VAL_5:.*]] = hlfir.elemental %{{.*}} mold %{{.*}} unordered : (!fir.shape<1>, !fir.class<!fir.array<?x!fir.type<_QMtypesTt>>>) -> !hlfir.expr<?x!fir.type<_QMtypesTt>?> {
! CHECK:           %[[VAL_9:.*]]:3 = hlfir.associate %[[VAL_5]](%{{.*}}) {adapt.valuebyref} : (!hlfir.expr<?x!fir.type<_QMtypesTt>?>, !fir.shape<1>) -> (!fir.class<!fir.array<?x!fir.type<_QMtypesTt>>>, !fir.class<!fir.array<?x!fir.type<_QMtypesTt>>>, i1)
! CHECK:           %[[VAL_10:.*]] = fir.rebox %[[VAL_9]]#0 : (!fir.class<!fir.array<?x!fir.type<_QMtypesTt>>>) -> !fir.box<!fir.array<?x!fir.type<_QMtypesTt>>>
! CHECK:           %[[VAL_11:.*]]:2 = hlfir.copy_in %[[VAL_10]] to %[[TMP_BOX:.*]] : (!fir.box<!fir.array<?x!fir.type<_QMtypesTt>>>, !fir.ref<!fir.box<!fir.heap<!fir.array<?x!fir.type<_QMtypesTt>>>>>) -> (!fir.box<!fir.array<?x!fir.type<_QMtypesTt>>>, i1)
! CHECK:           fir.call @_QMtypesPcallee(%[[VAL_11]]#0) fastmath<contract> : (!fir.box<!fir.array<?x!fir.type<_QMtypesTt>>>) -> ()
! CHECK:           hlfir.copy_out %[[TMP_BOX]], %[[VAL_11]]#1 : (!fir.ref<!fir.box<!fir.heap<!fir.array<?x!fir.type<_QMtypesTt>>>>>, i1) -> ()
! CHECK:           hlfir.end_associate %[[VAL_9]]#0, %[[VAL_9]]#2 : !fir.class<!fir.array<?x!fir.type<_QMtypesTt>>>, i1
! CHECK:           hlfir.destroy %[[VAL_5]] : !hlfir.expr<?x!fir.type<_QMtypesTt>?>
