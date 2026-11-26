! RUN: %python %S/test_errors.py %s %flang_fc1
! C911 - abstract derived type can be used only when polymorphic
! REQUIRES: aarch64-registered-target && x86-registered-target
! DEFINE: %{triple} =
! DEFINE: %{compile} = %flang_fc1 -emit-mlir -triple %{triple} --dependent-lib=libtest %s -o - 2>&1
! REDEFINE: %{triple} = aarch64-pc-windows-msvc
! RUN: %{compile} | FileCheck %s
! REDEFINE: %{triple} = x86_64-pc-windows-msvc
! RUN: %{compile} | FileCheck %s
! REDEFINE: %{triple} = x86_64-linux-unknown-gnu
! RUN: not %{compile} | FileCheck %s --check-prefixes=CHECK-NOWIN
! REDEFINE: %{triple} = aarch64-apple-darwin
! RUN: not %{compile} | FileCheck %s --check-prefixes=CHECK-NOWIN

! CHECK: llvm.linker_options ["/DEFAULTLIB:libtest"]
! CHECK-NOWIN: --dependent-lib is only supported on Windows
program X
type, abstract :: abstract
    integer :: j
  end type
type, extends(abstract) :: concrete
    integer :: k
    class(concrete), allocatable :: a(:)
  end type
  type(concrete) :: x(2)
  call sub1(x(1)) ! ok
  call sub2(x) ! ok
  call sub1(x(1)%a(1)) ! ok
  call sub2(x(1)%a) ! ok
  !ERROR: Reference to object with abstract derived type 'abstract' must be polymorphic
  call sub1(x(1)%abstract) ! bad
  !ERROR: Reference to object with abstract derived type 'abstract' must be polymorphic
  call sub2(x%abstract) ! bad
  !ERROR: Reference to object with abstract derived type 'abstract' must be polymorphic
  call sub1(x(1)%a(1)%abstract) ! bad
  !ERROR: Reference to object with abstract derived type 'abstract' must be polymorphic
  call sub2(x(1)%a%abstract) ! bad
 contains
  subroutine sub1(d)
    class(abstract) d
  end subroutine
  subroutine sub2(d)
    class(abstract) d(:)
  end subroutine
end
program TEST_ffl
end program TEST_ffl
