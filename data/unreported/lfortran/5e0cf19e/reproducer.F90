end
! RUN: %flang_fc1 -fdebug-unparse %s -Dj=1 2>&1 | FileCheck %s
! Ensure that macro definitions don't affect INCLUDE lines (unlike #include)
#EXT sin cos
!CHECK: PRINT *, 0._4, j
include "'d'"
end
! RUN: %python %S/test_errors.py %s %flang_fc1
external ext
integer caf[*]
!ERROR: OPERATION= argument of CO_REDUCE() must be a pure function of two data arguments
call co_reduce(caf, ext)
