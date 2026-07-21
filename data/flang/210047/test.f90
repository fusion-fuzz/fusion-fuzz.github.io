! ALL-LABEL:   func.func @_QPtest3(
! ALL:           %[[VAL_1:.*]]:2 = hlfir.declare{{.*}}{fortran_attrs = #fir.var_attrs<allocatable>, uniq_name = "_QFtest3Ex"}
! ALL:           hlfir.assign %{{.*}} to %[[VAL_1]]#0 realloc : i32, !fir.ref<!fir.class<!fir.heap<none>>>
! Check that symbols without SAVE attribute from an EQUIVALENCE
! with at least one symbol being SAVEd (explicitly or implicitly)
! have implicit SAVE attribute.
!RUN: %flang_fc1 -fdebug-dump-symbols %s | FileCheck %s
! ALL-LABEL:   func.func @_QPtest1(
! ALL:           %[[VAL_3:.*]]:2 = hlfir.declare{{.*}}{fortran_attrs = #fir.var_attrs<allocatable>, uniq_name = "_QFtest1Ea"}
! REALLOCLHS:    hlfir.assign %{{.*}} to %[[VAL_3]]#0 realloc : !hlfir.expr<?xi32>, !fir.ref<!fir.box<!fir.heap<!fir.array<?xi32>>>>

! NOREALLOCLHS:  %[[VAL_20:.*]] = fir.load %[[VAL_3]]#0 : !fir.ref<!fir.box<!fir.heap<!fir.array<?xi32>>>>
! NOREALLOCLHS:  hlfir.assign %{{.*}} to %[[VAL_20]] : !hlfir.expr<?xi32>, !fir.box<!fir.heap<!fir.array<?xi32>>>
! RUN: bbc %s -o - -emit-hlfir | FileCheck %s --check-prefixes=ALL,REALLOCLHS
! RUN: bbc %s -o - -emit-hlfir -frealloc-lhs | FileCheck %s --check-prefixes=ALL,REALLOCLHS
! RUN: bbc %s -o - -emit-hlfir -frealloc-lhs=false | FileCheck %s --check-prefixes=ALL,NOREALLOCLHS
! RUN: %flang_fc1 %s -o - -emit-hlfir | FileCheck %s --check-prefixes=ALL,REALLOCLHS
! RUN: %flang_fc1 %s -o - -emit-hlfir -frealloc-lhs | FileCheck %s --check-prefixes=ALL,REALLOCLHS
! RUN: %flang_fc1 %s -o - -emit-hlfir -fno-realloc-lhs 2>&1 | FileCheck %s --check-prefixes=ALL,NOREALLOCLHS

! -fno-realloc-lhs must be ignored for polymorphic allocatable LHS (TEST3_ffl below).
subroutine TEST1_ffl(a, b)
  integer, allocatable :: a(:), b(:)
  a = b + 1
end
subroutine TEST2_ffl(a, b)
  character(len=*), allocatable :: a(:)
  character(len=*) :: b(:)
  a = b
end subroutine TEST2_ffl
! ALL-LABEL:   func.func @_QPtest2(
! ALL:           %[[VAL_3:.*]]:2 = hlfir.declare{{.*}}{fortran_attrs = #fir.var_attrs<allocatable>, uniq_name = "_QFtest2Ea"}
! REALLOCLHS:    hlfir.assign %{{.*}} to %[[VAL_3]]#0 realloc keep_lhs_len : !fir.box<!fir.array<?x!fir.char<1,?>>>, !fir.ref<!fir.box<!fir.heap<!fir.array<?x!fir.char<1,?>>>>>

! NOREALLOCLHS:  %[[VAL_7:.*]] = fir.load %[[VAL_3]]#0 : !fir.ref<!fir.box<!fir.heap<!fir.array<?x!fir.char<1,?>>>>>
! NOREALLOCLHS:  hlfir.assign %{{.*}} to %[[VAL_7]] : !fir.box<!fir.array<?x!fir.char<1,?>>>, !fir.box<!fir.heap<!fir.array<?x!fir.char<1,?>>>>

! Polymorphic allocatable LHS: reallocation semantics must be used regardless of
! -fno-realloc-lhs, because the Fortran standard requires dynamic type tracking
! for polymorphic assignments (a F2003+ feature that cannot be safely skipped).
subroutine TEST3_ffl(x)
  class(*), allocatable :: x
  x = 1
end subroutine TEST3_ffl
subroutine test1()
  ! CHECK-LABEL: Subprogram scope: test1
  ! CHECK: i1, SAVE size=4 offset=0: ObjectEntity type: INTEGER(4) init:1_4
  ! CHECK: j1, SAVE size=4 offset=0: ObjectEntity type: INTEGER(4)
  integer :: i1 = 1
  integer :: j1
  equivalence(i1,j1)
end subroutine test1
subroutine test2()
  ! CHECK-LABEL: Subprogram scope: test2
  ! CHECK: i1, SAVE size=4 offset=0: ObjectEntity type: INTEGER(4) init:1_4
  ! CHECK: j1, SAVE size=4 offset=0: ObjectEntity type: INTEGER(4)
  integer :: i1 = 1
  integer :: j1
  equivalence(j1,i1)
end subroutine test2
subroutine test3()
  ! CHECK-LABEL: Subprogram scope: test3
  ! CHECK: i1, SAVE size=4 offset=0: ObjectEntity type: INTEGER(4)
  ! CHECK: j1, SAVE size=4 offset=0: ObjectEntity type: INTEGER(4)
  ! CHECK: k1, SAVE (InCommonBlock) size=4 offset=0: ObjectEntity type: INTEGER(4)
  integer :: i1
  integer :: j1, k1
  common /blk/ k1
  save /blk/
  equivalence(i1,TEST3,k1)
end subroutine test3
subroutine test4()
  ! CHECK-LABEL: Subprogram scope: test4
  ! CHECK: i1, SAVE size=4 offset=0: ObjectEntity type: INTEGER(4) init:1_4
  ! CHECK: j1, SAVE size=4 offset=0: ObjectEntity type: INTEGER(4)
  ! CHECK: k1, SAVE (InCommonBlock) size=4 offset=0: ObjectEntity type: INTEGER(4)
  integer :: i1 = 1
  integer :: j1, k1
  common /blk/ k1
  equivalence(i1,j1,k1)
end subroutine test4