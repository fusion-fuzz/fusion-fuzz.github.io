! RUN: %python %S/test_folding.py %s %flang_fc1

! Test fold parity intrinsic.
! This test checks lowering of atomic and atomic update constructs with HLFIR
! RUN: bbc -fopenacc -emit-hlfir %s -o - | FileCheck %s
! RUN: %flang_fc1 -emit-hlfir -fopenacc %s -o - | FileCheck %s

!CHECK-LABEL: @_QPsb
subroutine sb
!CHECK:   %[[W_REF:.*]] = fir.alloca i32 {bindc_name = "w", uniq_name = "_QFsbEw"}
!CHECK:   %[[W_DECL:.*]]:2 = hlfir.declare %[[W_REF]] {uniq_name = "_QFsbEw"} : (!fir.ref<i32>) -> (!fir.ref<i32>, !fir.ref<i32>)
!CHECK:   %[[X_REF:.*]] = fir.alloca i32 {bindc_name = "x", uniq_name = "_QFsbEx"}
!CHECK:   %[[X_DECL:.*]]:2 = hlfir.declare %[[X_REF]] {uniq_name = "_QFsbEx"} : (!fir.ref<i32>) -> (!fir.ref<i32>, !fir.ref<i32>)
!CHECK:   %[[Y_REF:.*]] = fir.alloca i32 {bindc_name = "y", uniq_name = "_QFsbEy"}
!CHECK:   %[[Y_DECL:.*]]:2 = hlfir.declare %[[Y_REF]] {uniq_name = "_QFsbEy"} : (!fir.ref<i32>) -> (!fir.ref<i32>, !fir.ref<i32>)
!CHECK:   %[[Z_REF:.*]] = fir.alloca i32 {bindc_name = "z", uniq_name = "_QFsbEz"}
!CHECK:   %[[Z_DECL:.*]]:2 = hlfir.declare %[[Z_REF]] {uniq_name = "_QFsbEz"} : (!fir.ref<i32>) -> (!fir.ref<i32>, !fir.ref<i32>)
  integer :: w, x, y, z
!CHECK:   %[[Y_VAL:.*]] = fir.load %[[Y_DECL]]#0 : !fir.ref<i32>
!CHECK:   acc.atomic.update   %[[X_DECL]]#0 : !fir.ref<i32> {
!CHECK:   ^bb0(%[[ARG_X:.*]]: i32):
!CHECK:     %[[X_UPDATE_VAL:.*]] = arith.addi %[[ARG_X]], %[[Y_VAL]] : i32
!CHECK:     acc.yield %[[X_UPDATE_VAL]] : i32
!CHECK:   }
  !$acc atomic update
    x = x + y
!CHECK:   %[[Y_VAL:.*]] = fir.load %[[Y_DECL]]#0 : !fir.ref<i32>
!CHECK:   acc.atomic.update %[[X_DECL]]#0 : !fir.ref<i32> {
!CHECK:   ^bb0(%[[ARG_X:.*]]: i32):
!CHECK:     %[[X_UPDATE_VAL:.*]] = arith.ori %[[ARG_X]], %[[Y_VAL]] : i32
!CHECK:     acc.yield %[[X_UPDATE_VAL]] : i32
!CHECK:   }
  !$acc atomic update
    x = ior(x,y)
!CHECK:   %[[W_VAL:.*]] = fir.load %[[W_DECL]]#0 : !fir.ref<i32>
!CHECK:   %[[X_VAL:.*]] = fir.load %[[X_DECL]]#0 : !fir.ref<i32>
!CHECK:   %[[Y_VAL:.*]] = fir.load %[[Y_DECL]]#0 : !fir.ref<i32>
!CHECK:   acc.atomic.update %[[Z_DECL]]#0 : !fir.ref<i32> {
!CHECK:   ^bb0(%[[ARG_Z:.*]]: i32):
!CHECK:     %[[WX_MIN:.*]] = arith.minsi %[[W_VAL]], %[[X_VAL]] : i32
!CHECK:     %[[WXY_MIN:.*]] = arith.minsi %[[WX_MIN]], %[[Y_VAL]] : i32
!CHECK:     %[[WXYZ_MIN:.*]] = arith.minsi %[[WXY_MIN]], %[[ARG_Z]] : i32
!CHECK:     acc.yield %[[WXYZ_MIN]] : i32
!CHECK:   }
  !$acc atomic update
    z = min(w,x,y,z)
!CHECK:   return
end subroutine
module paritytest
  logical, parameter :: test_1t = parity((/ .true. /))
  logical, parameter :: test_1f = .not. parity((/ .false. /))
  logical, parameter :: test_e1 = .not. parity((/ .true., .true. /))
  logical, parameter :: test_o1 = parity((/ .true., .true., .true. /))
  logical, parameter :: test_o12 = parity((/ .true., .true., .true., .false. /))
  logical, parameter, dimension(2, 3) :: a32 = reshape((/&
       .true., .true., .false., &
       .true., .true., .true. &
       /), shape(a32), X=(/2, 1/))
  logical, parameter, dimension(2, 3) :: a32t = reshape((/&
       .true., .true., .true., &
       .true., .true., .true. &
       /), shape(a32t))
  logical, parameter, dimension(2, 3) :: a32f = reshape((/&
       .false., .false., .false., &
       .false., .false., .false. &
       /), shape(a32f))
  logical, parameter :: test_a32 = parity(a32)
  logical, parameter :: test_a32t = .not. parity(a32t)
  logical, parameter :: test_a32f = .not. parity(a32f)
  logical, parameter :: test_a321 = &
       all(parity(a32, 1) .EQV. (/ .false., .false., .true. /))
  logical, parameter :: test_a322 = &
       all(parity(a32, 2) .EQV. (/ .false., .true. /))
end module paritytest
