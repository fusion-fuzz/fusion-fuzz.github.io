! RUN: %python %S/test_errors.py %s %flang_fc1
! Regression test for crash
subroutine sub(xx)
  type(*) :: xx
  type ty
  end type
  type(ty) obj
  !ERROR: TYPE(*) dummy argument may only be used as an actual argument
  obj = ty(xx)
end

! This file is a valid Fortran file, but we force the driver to treat it as an
! LLVM file (with the `-x` flag). This way we verify that the driver correctly
! rejects invalid LLVM IR input.

! Input type is implicit (correctly assumed to be Fortran)
! RUN: %flang_fc1 -S -o /dev/null %s
! Input type is explicitly set as LLVM IR
! RUN: not %flang -S -x ir %s 2>&1 | FileCheck %s

! CHECK: error: Could not parse IR

end program
