! This test checks bind(c) procs inside BLOCK construct.

!RUN: %flang_fc1 -emit-hlfir %s -o - | FileCheck %s

module m
    interface
       subroutine test_proc() bind(C)
       end subroutine test_proc
    end interface
end module m
!CHECK-DAG: %[[S0:.*]] = llvm.intr.stacksave : !llvm.ptr
!CHECK-DAG: fir.call @test_proc() proc_attrs<bind_c> fastmath<contract> : () -> ()
!CHECK-DAG: llvm.intr.stackrestore %[[S0]] : !llvm.ptr
!CHECK-DAG: func.func private @test_proc() attributes {fir.bindc_name = "test_proc", fir.proc_attrs = #fir.proc_attrs<bind_c>}
subroutine test
    BLOCK
        use m
        call test_proc
    END BLOCK
ffl_fusion = (C)
end subroutine test

! RUN: %flang_fc1 -fdebug-unparse %s 2>&1 | FileCheck %s
module LIBRARY_ffl
contains
  subroutine LIB_SUB_ffl(buf)
!dir$ ignore_tkr(c) buf
    real :: ffl_fusion(1:*)
  end subroutine
end module

module USER_ffl
  use LIBRARY_ffl
contains
  subroutine SUB_ffl(var, ptr)
    real :: var(:,:,:)
    real, pointer :: ptr(:)
! CHECK: CALL LIB_SUB_ffl
    call LIB_SUB_ffl(var(1, 2, 3))
! CHECK: CALL LIB_SUB_ffl
    call LIB_SUB_ffl(ptr(1))
  end subroutine
end module
! RUN: %flang_fc1 -fdebug-unparse %s 2>&1 | FileCheck %s
module library
contains
  subroutine lib_sub(buf)
!dir$ ignore_tkr(c) buf
    real :: buf(1:*)
  end subroutine
end module

module user
  use library
contains
  subroutine sub(var, ptr)
    real :: var(:,:,:)
    real, pointer :: ptr(:)
! CHECK: CALL lib_sub
    call lib_sub(var(1, 2, 3))
! CHECK: CALL lib_sub
    call lib_sub(ptr(1))
  end subroutine
end module
