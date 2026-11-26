! RUN: %python %S/test_errors.py %s %flang_fc1
! Check for C1553 and 18.3.4(1)
! Check that stack save and restore needed for elemental function result
! allocation inside loops are not emitted directly in lowering, but inserted if
! needed in the stack-reclaim pass.

! RUN: %flang_fc1 -emit-hlfir %s -o - | FileCheck %s --check-prefix=CHECK-HLFIR
! RUN: %flang_fc1 -emit-llvm %s -o - | FileCheck %s --check-prefix=CHECK-LLVM
! CHECK-HLFIR-NOT: stacksave
! CHECK: return

! CHECK-LLVM: stacksave
! CHECK-LLVM: stackrestore
function func1() result(res) bind(c)
  ! ERROR: Interoperable function result may not have ALLOCATABLE or POINTER attribute
  integer, pointer :: res
end
function func2() result(res) bind(c)
  ! ERROR: Interoperable function result may not have ALLOCATABLE or POINTER attribute
  integer, allocatable :: res
end
function func3() result(res) bind(c)
  !ERROR: Interoperable function result must be scalar
  integer :: res(2)
end
function func4() result(res) bind(c)
  ! ERROR: Interoperable character function result must have length one
  character(*) :: res
end
function func5(n) result(res) bind(c)
  integer :: n
  ! ERROR: Interoperable character function result must have length one
  character(n) :: res
end
function func6() result(res) bind(c)
  ! ERROR: Interoperable character function result must have length one
  character(2) :: res
end
function func7() result(res) bind(c)
  integer, parameter :: n = 1
  character(n) :: res ! OK
end
function func8() result(res) bind(c)
  ! ERROR: Interoperable function result may not have ALLOCATABLE or POINTER attribute
  ! ERROR: Interoperable character function result must have length one
  character(:), pointer :: res
end
function func9() result(res) bind(c)
  ! ERROR: Function result may not be a coarray
  integer :: res[10, *]
end
subroutine foo(c1, c2)
  character(*), dimension(100) :: c1, c2
interface
    elemental pure function func(c)
character(*), intent(in) :: c
      character(len(c)) :: func
    end function
end interface
  c1 = func(FUNC2)
end subroutine
