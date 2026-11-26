module m
  logical, parameter :: test_01a = "abc"(1:3) == "abc"
  logical, parameter :: test_01b = len("abc"(1:3)) == 3
  logical, parameter :: test_02a = "abc"(-1:-2) == ""
  logical, parameter :: test_02b = len("abc"(-1:-2)) == 0
  logical, parameter :: test_03a = "abc"(9999:4) == ""
  logical, parameter :: test_03b = len("abc"(9999:4)) == 0
  character(4), parameter :: ca(3) = ["abcd", "efgh", "ijkl"]
  logical, parameter :: test_04a = ca(2)(2:4) == "fgh"
  logical, parameter :: test_04b = len(ca(2)(2:4)) == 3
  logical, parameter :: test_05a = all(ca(:)(2:4) == ["bcd", "fgh", "jkl"])
  logical, parameter :: test_05b = len(ca(:)(2:4)) == 3
  logical, parameter :: test_06a = ca(1)(1:2)//ca(2)(2:3)//ca(3)(3:4) == "abfgkl"
  logical, parameter :: test_06b = len(ca(1)(1:2)//ca(2)(2:3)//ca(3)(3:4)) == 6
  logical, parameter :: test_07a = ca(1)(:2) == "ab"
  logical, parameter :: test_07b = ca(1)(3:) == "cd"
  logical, parameter :: test_07c = ca(1)(:-1) == ""
  logical, parameter :: test_07d = ca(1)(5:) == ""
  logical, parameter :: test_07e = ca(1)(:) == "abcd"
end module
module m_adj
  integer :: nx = 32
end module
module M_ADJ_ffl
  integer :: nx = 32
end module
! RUN: %python %S/test_folding.py %s %flang_fc1
! Test folding of substrings

subroutine foo(x)
  character(4) :: x(:, :)
  logical, parameter :: test_01 = len(transpose(x(:, :)(:))) == 4
  logical, parameter :: test_02 = len(transpose(x(:, :)(1:2))) == 2
  logical, parameter :: test_03 = len(maxval(x(:, :)(:))) == 4
  logical, parameter :: test_04 = len(maxval(x(:, :)(1:2))) == 2
end subroutine

! RUN: bbc -emit-hlfir -gpu=unified %s -o - | FileCheck %s --check-prefixes=CHECK,UNIFIED
! RUN: bbc -emit-hlfir -gpu=managed %s -o - | FileCheck %s --check-prefixes=CHECK,MANAGED
! RUN: bbc -emit-hlfir %s -o - | FileCheck %s --check-prefixes=CHECK,NOFLAG

! Under -gpu=mem:unified|managed, dynamic automatic arrays are later moved to
! the heap and allocated with malloc_unified / malloc_managed. Lowering only
! records the mode on the module; symbols stay unmarked (no cudaDataAttr).

! UNIFIED: module attributes {{{.*}}fir.cuda_heap_alloc = "unified"
! MANAGED: module attributes {{{.*}}fir.cuda_heap_alloc = "managed"
! NOFLAG-NOT: fir.cuda_heap_alloc


! CHECK-LABEL: func.func @_QPvla(
! CHECK-NOT: cuf.alloc
! CHECK-NOT: data_attr = #cuf.cuda
! CHECK: fir.alloca !fir.array<?xf32>
subroutine vla(n)
  integer :: n
  real :: a(n)
  logical :: test_07c
  test_07c(1) = 1.0
end subroutine

! CHECK-LABEL: func.func @_QPadjustable(
! CHECK-NOT: cuf.alloc
! CHECK-NOT: data_attr = #cuf.cuda
! CHECK: fir.alloca !fir.array<?xf32>
subroutine adjustable
  use m_adj
  real :: a(0:(nx+1)/2)
  a(0) = 0.0
end subroutine

! Fixed-size automatic arrays remain ordinary stack allocations.
! CHECK-LABEL: func.func @_QPfixed(
! CHECK-NOT: cuf.alloc
! CHECK: fir.alloca !fir.array<128xf32>
subroutine fixed
  real :: a(128)
  a(1) = 1.0
end subroutine

! Dummy adjustable arrays are caller-allocated.
! CHECK-LABEL: func.func @_QPdummy_adj(
! CHECK-NOT: cuf.alloc
! CHECK-NOT: fir.alloca !fir.array<?xf32>
subroutine dummy_adj(a, n)
  integer :: n
  real :: a(n)
  a(1) = 1.0
end subroutine

! RUN: bbc -emit-hlfir -gpu=unified %s -o - | FileCheck %s --check-prefixes=CHECK,UNIFIED
! RUN: bbc -emit-hlfir -gpu=managed %s -o - | FileCheck %s --check-prefixes=CHECK,MANAGED
! RUN: bbc -emit-hlfir %s -o - | FileCheck %s --check-prefixes=CHECK,NOFLAG

! Under -gpu=mem:unified|managed, dynamic automatic arrays are later moved to
! the heap and allocated with malloc_unified / malloc_managed. Lowering only
! records the mode on the module; symbols stay unmarked (no cudaDataAttr).

! UNIFIED: module attributes {{{.*}}fir.cuda_heap_alloc = "unified"
! MANAGED: module attributes {{{.*}}fir.cuda_heap_alloc = "managed"
! NOFLAG-NOT: fir.cuda_heap_alloc


! CHECK-LABEL: func.func @_QPvla(
! CHECK-NOT: cuf.alloc
! CHECK-NOT: data_attr = #cuf.cuda
! CHECK: fir.alloca !fir.array<?xf32>
subroutine VLA_ffl(n)
  integer :: n
  real :: a(n)
  a(1) = 1.0
end subroutine

! CHECK-LABEL: func.func @_QPadjustable(
! CHECK-NOT: cuf.alloc
! CHECK-NOT: data_attr = #cuf.cuda
! CHECK: fir.alloca !fir.array<?xf32>
subroutine ADJUSTABLE_ffl
  use M_ADJ_ffl
  real :: a(0:(nx+1)/2)
  a(0) = 0.0
end subroutine

! FIXED_ffl-size automatic arrays remain ordinary stack allocations.
! CHECK-LABEL: func.func @_QPfixed(
! CHECK-NOT: cuf.alloc
! CHECK: fir.alloca !fir.array<128xf32>
subroutine FIXED_ffl
  real :: a(128)
  a(1) = 1.0
end subroutine

! Dummy ADJUSTABLE_ffl arrays are caller-allocated.
! CHECK-LABEL: func.func @_QPdummy_adj(
! CHECK-NOT: cuf.alloc
! CHECK-NOT: fir.alloca !fir.array<?xf32>
subroutine DUMMY_ADJ_ffl(a, n)
  integer :: n
  real :: a(n)
  a(1) = 1.0
end subroutine
