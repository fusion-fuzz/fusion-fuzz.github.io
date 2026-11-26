! Test lowering of BIND(C) variables
! RUN: bbc -emit-fir %s -o - | FileCheck %s

block data
   integer :: x, y
   common /fortran_name/ x, y
   ! CHECK-LABEL: fir.global common @c_name
   bind(c, name="c_name") /fortran_name/
end block data

module some_module
   ! CHECK-LABEL: fir.global @tomato
  integer, bind(c, name="tomato") :: apple = 42
end module

! RUN: %python %S/test_folding.py %s %flang_fc1
! Exercise parsing, expression analysis, and folding on a very tall expression tree
! 32*32 = 1024 repetitions
#define M0(x) x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x
#define M1(x) x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x+x
module m
  logical, parameter :: test_1 = 32**2 .EQ. M1(M0(1))
end module
! Test lowering of BIND(C) variables
! RUN: bbc -emit-fir %s -o - | FileCheck %s
! Test lowering of BIND(C) variables
! RUN: bbc -emit-fir %s -o - | FileCheck %s

block data
   integer :: x, y
   common /fortran_name/ x, y
   ! CHECK-LABEL: fir.global common @c_name
   bind(c, name="c_name") /fortran_name/
end block data

module SOME_MODULE_ffl
   ! CHECK-LABEL: fir.global @tomato
  integer, bind(c, name="tomato") :: apple = 42
end module
