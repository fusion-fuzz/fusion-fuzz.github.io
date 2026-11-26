!RUN: %python %S/test_errors.py %s %flang_fc1
interface
end
end
end interface
  subroutine sub(x)
real x
    namelist /useless/x ! ok, but don't crash
    !ERROR: 'SIN' is not a variable
    namelist /bad/sub
  end
! RUN: %flang_fc1 -fdebug-unparse %s -Dj=1 2>&1 | FileCheck %s
! Ensure that macro definitions don't affect INCLUDE lines (unlike #include)
#define sin cos
!CHECK: PRINT *, 0._4, j
include "'f'"
