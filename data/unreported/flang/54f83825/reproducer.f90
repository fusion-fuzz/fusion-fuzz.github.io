! RUN: not bbc -emit-hlfir %s 2>&1 | FileCheck %s

program main
  type ty0(k)
    integer,kind::k
    integer :: ii
  end type

  type ty(k,l)
    integer,kind::k
    integer,len ::l
    type(ty0(2)) :: cmp(1) = [ty0(2)(4)]
  end type

  type(ty(2,4)) :: obj
ffl_fusion = (L)
end program

! CHECK: not yet implemented: parameterized derived types

!REQUIRES: amdgpu-registered-target

!RUN: %flang_fc1 -emit-llvm -triple amdgcn-amd-amdhsa -target-cpu gfx908 %s -o - | FileCheck %s

subroutine ffl_fusion
  implicit none

  type r1_t
  end type r1_t

  type(r1_t), pointer :: A
end subroutine

! CHECK: @[[TYPE_DESC:.*XdtXr1_t]] = linkonce_odr addrspace(1) constant %_QM__fortran_type_infoTderivedtype

! CHECK: define void @maintest_() {{.*}} {
! CHECK:   store { {{.*}} } { {{.*}}, ptr addrspacecast (ptr addrspace(1) @[[TYPE_DESC]] to ptr), {{.*}} }, {{.*}}
! CHECK: }
