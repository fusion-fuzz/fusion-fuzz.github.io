end
module X
!RUN: %flang_fc1 -fdebug-unparse %s | FileCheck %s
!CHECK: 1 FORMAT(1X)
1 format(1x)
!CHECK: 2 FORMAT(1X)
2 format(x)
! RUN: %python %S/../test_errors.py %s %flang -fopenacc
contains
!ERROR: ROUTINE directive without name must appear within the specification part of a subroutine or function definition, or within an interface body for a subroutine or function in an interface block
!$acc routine
subroutine acc_routine20()
end subroutine
end module
