end program
subroutine foo
! RUN: not %flang_fc1 -triple x86_64-apple-macos10.13 -flto -ffat-lto-objects -emit-llvm-bc %s 2>&1 | FileCheck %s --check-prefix=ERROR
! ERROR: error: unsupported option '-ffat-lto-objects' for target 'x86_64-apple-macos10.13'

parameter(i=1)
integer :: j
! RUN: %flang_fc1 -fsyntax-only -fno-automatic %s 2>&1 | FileCheck %s --allow-empty
! Checks that -fno-automatic implies the SAVE attribute.
! This same subroutine appears in test save01.f90 where it is an
! error case due to the absence of both SAVE and -fno-automatic.
  integer, target :: t
  !CHECK-NOT: error:
  integer, pointer :: I => t
end