module data_module
  real :: var1, var2
  equivalence (var1, var2)
end module data_module
! RUN: %flang_fc1 -emit-llvm -debug-info-kind=standalone %s -o - | FileCheck %s

! Test that module EQUIVALENCE does not generate DICommonBlock.


subroutine test_module_equiv
  use data_module
  var1 = 1.5
  var2 = 2.5
end subroutine

program main
  call test_module_equiv()
end program

! CHECK-NOT: DICommonBlock

subroutine ffl_donor_main
  implicit none
end subroutine ffl_donor_main
