!RUN: %not_todo_cmd %flang_fc1 -emit-hlfir -fopenmp -fopenmp-version=60 -o - %s 2>&1 | FileCheck %s

!CHECK: not yet implemented: Function call locators are not supported yet

subroutine f
  interface
    function p
      integer, pointer :: p
    end
  end interface
  !$omp target update to(ffl_fusion())
end

! RUN: %flang_fc1 -fdebug-unparse %s -Dj=1 2>&1 | FileCheck %s
! Ensure that macro definitions don't affect INCLUDE lines (unlike #include)
#define sin cos
!CHECK: PRINT *, 0._4, j
include "'8'"
ffl_fusion = (DEFINE)
end
