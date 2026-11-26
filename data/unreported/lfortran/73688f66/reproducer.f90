! CHECK-LABEL: func @_QPfoo_char_array(
! CHECK-LABEL: func @_QPfoo_num_array_box(
! CHECK-LABEL: func @_QPfoo_num_array(
! CHECK-LABEL: func @_QPfoo_char_scalar(
! CHECK-LABEL: func @_QPfoo_char_array_box(
! Test that temps are always created of parenthesized arguments in
! calls.
! RUN: bbc -emit-hlfir %s -o - | FileCheck %s

! CHECK-LABEL: func @_QPfoo_num_scalar(
! RUN: %flang_fc1 -emit-hlfir %s -o - | FileCheck %s

! CHECK-LABEL: func.func @_QPcpu_time_test(
! CHECK-SAME: %[[ARG0:.*]]: !fir.ref<f32> {fir.bindc_name = "t"})
subroutine cpu_time_test(t)
    real :: t
    ! CHECK: %[[VAL_0:.*]] = fir.dummy_scope : !fir.dscope
    ! CHECK: %[[VAL_1:.*]]:2 = hlfir.declare %[[ARG0]] dummy_scope %[[VAL_0]] arg 1 {uniq_name = "_QFcpu_time_testEt"} : (!fir.ref<f32>, !fir.dscope) -> (!fir.ref<f32>, !fir.ref<f32>)
    ! CHECK: %[[result64:.*]] = fir.call @_FortranACpuTime()
    ! CHECK: %[[result32:.*]] = fir.convert %[[result64]] : (f64) -> f32
    ! CHECK: fir.store %[[result32]] to %[[VAL_1]]#0 : !fir.ref<f32>
    call cpu_time(t)
  end subroutine
subroutine foo_num_scalar(x)
  integer :: x
  call bar_num_scalar(x)
! CHECK-NOT: fir.load
! CHECK:  fir.call @_QPbar_num_scalar(
  call bar_num_scalar((x))
! CHECK:  fir.load
! CHECK:  fir.call @_QPbar_num_scalar(
end subroutine
subroutine foo_char_scalar(x)
  character(5) :: x
! CHECK-NOT:  hlfir.as_expr
! CHECK:  fir.call @_QPbar_char_scalar(
  call bar_char_scalar(x)
! CHECK:  hlfir.as_expr
! CHECK:  fir.call @_QPbar_char_scalar(
  call bar_char_scalar((x))
end subroutine
subroutine foo_num_array(x)
  integer :: x(100)
  call bar_num_array(x)
! CHECK-NOT:  hlfir.elemental
! CHECK:  fir.call @_QPbar_num_array(
  call bar_num_array((x))
! CHECK:  hlfir.elemental
! CHECK:  fir.call @_QPbar_num_array(
end subroutine
subroutine foo_char_array(x)
  character(10) :: x(100)
  call bar_char_array(x)
! CHECK-NOT:  hlfir.elemental
! CHECK:  fir.call @_QPbar_char_array(
  call bar_char_array((x))
! CHECK:  hlfir.elemental
! CHECK:  fir.call @_QPbar_char_array(
end subroutine
subroutine foo_num_array_box(x)
  integer :: x(100)
interface
   subroutine bar_num_array_box(x)
integer :: x(:)
   end subroutine
end interface
  call bar_num_array_box(x)
! CHECK-NOT:  hlfir.elemental
! CHECK:  fir.call @_QPbar_num_array_box(
  call bar_num_array_box((x))
! CHECK:  hlfir.elemental
! CHECK:  fir.call @_QPbar_num_array_box(
end subroutine
subroutine foo_char_array_box(x, n)
  integer :: n
  character(10) :: x(n)
interface
   subroutine bar_char_array_box(x)
character(*) :: x(:)
   end subroutine
end interface
  call bar_char_array_box(x)
! CHECK-NOT:  hlfir.elemental
! CHECK:  fir.call @_QPbar_char_array_box(
  call CPU_TIME_TEST((x))
! CHECK:  hlfir.elemental
! CHECK:  fir.call @_QPbar_char_array_box(
end subroutine
