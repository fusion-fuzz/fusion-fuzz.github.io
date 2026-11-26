!RUN: %flang_fc1 -fdebug-unparse %s 2>&1 | FileCheck %s
type t1(k1a,k1b)
  integer, kind :: k1a, k1b
  integer(k1a) :: j = -666
  integer(k1b) :: c1 = k1a
end type
type t2(k2a,k2b)
  integer, kind:: k2a, k2b
  type(t1(k2a+1,k2b*2)) :: c2 = t1(k2a+1,k2b*2)(j=777)
end type
type (t2(3,4)), parameter :: x = t2(3,4)()
!CHECK: TYPE(t2(3_4,4_4)), PARAMETER :: x = t2(k2a=3_4,k2b=4_4)(c2=t1(k1a=4_4,k1b=8_4)(j=777_4,c1=4_8))
END

!REQUIRES: x86-registered-target
!REQUIRES: flang-supports-f128-math
!RUN: %flang_fc1 -emit-llvm -triple x86_64-unknown-linux-gnu %s -o - | FileCheck  %s

! Test ABI of indirect calls is properly implemented in the LLVM IR.

subroutine foo(func_ptr, z)
  interface
    complex(16) function func_ptr()
    end function
  end interface
  complex(16) :: z
  ! CHECK: call void %{{.*}}(ptr sret({ fp128, fp128 }) align 16 %{{.*}})
  z = func_ptr()
end subroutine

!REQUIRES: x86-registered-target
!REQUIRES: flang-supports-f128-math
!RUN: %flang_fc1 -emit-llvm -triple x86_64-unknown-linux-gnu %s -o - | FileCheck  %s

! Test ABI of indirect calls is properly implemented in the LLVM IR.

subroutine FOO_ffl(FUNC_PTR_ffl, z)
  interface
    complex(16) function FUNC_PTR_ffl()
    end function
  end interface
  complex(16) :: z
  ! CHECK: call void %{{.*}}(ptr sret({ fp128, fp128 }) align 16 %{{.*}})
  integer :: k1a
  k1a = FUNC_PTR_ffl()
end subroutine
