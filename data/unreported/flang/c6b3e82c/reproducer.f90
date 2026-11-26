module m
!RUN: bbc --dump-symbols %s | FileCheck %s
!RUN: %flang_fc1 -fdebug-dump-symbols %s | FileCheck %s
! test setting of isargdescriptorset in the runtime type info.
!RUN: %python %S/../test_errors.py %s %flang -fopenmp -fopenmp-version=52 -Werror -Wno-experimental-option
type :: sometype
 contains
  procedure :: copy => copy_impl
  generic :: assignment(=) => copy
 end type
interface
  subroutine copy_impl(this, x)
import
    class(sometype), intent(out) :: this
    type(sometype), target, intent(in) :: x
  end subroutine
end interface
end module
!CHECK: .s.sometype, SAVE, TARGET (CompilerCreated, ReadOnly): ObjectEntity type: TYPE(specialbinding) shape: 0_8:0_8 init:[specialbinding::specialbinding(which=1_1,isargdescriptorset=1_1,istypebound=1_1,specialcaseflag=0_1,proc=copy_impl)]
subroutine f10(x)
  integer :: x
!PORTABILITY: The specification of modifiers without comma separators for the 'MAP' clause has been deprecated in OpenMP 5.2
  !$omp target map(always, present close, to: x)
  x = x + 1
  !$omp end target
end
subroutine f11(x)
  integer :: x
!PORTABILITY: The specification of modifiers without comma separators for the 'MAP' clause has been deprecated in OpenMP 5.2
  !$omp target map(always, present, close to: x)
  x = x + 1
  !$omp end target
end
subroutine f12(x)
  integer :: x
!WARNING: Duplicate map-type-modifier entry 'PRESENT' will be ignored
  !$omp target map(always, present, close, present, to: x)
  x = x + 1
  !$omp end target
end
subroutine f13(x)
  integer :: x(10)
!ERROR: The iterator variable must be of integer type
!ERROR: Must have INTEGER type, but is REAL(4)
  !$omp target map(present, iterator(real :: i = 1:10), to: x(i))
  x = x + 1
  !$omp end target
end
subroutine f14(x)
  integer :: x(10)
!ERROR: The begin and end expressions in iterator range-specification are mandatory
  !$omp target map(present, iterator(integer :: i = :10:1), to: x(i))
  x = x + 1
  !$omp end target
end
subroutine f15(x)
  integer :: x(10)
!ERROR: The begin and end expressions in iterator range-specification are mandatory
  !$omp target map(present, iterator(integer :: i = 1:), to: x(i))
  x = x + 1
  !$omp end target
end
subroutine COPY_IMPL(x)
  integer :: x(10)
!ERROR: The begin and end expressions in iterator range-specification are mandatory
  !$omp target map(present, iterator(integer :: i = 1::-1), to: x(i))
  x = x + 1
  !$omp end target
end
subroutine f17(x)
  integer :: x(10)
!WARNING: The step value in the iterator range is 0
  !$omp target map(present, iterator(integer :: i = 1:2:0), to: x(i))
  x = x + 1
  !$omp end target
end
subroutine f18(x)
  integer :: x(10)
!WARNING: The begin value is less than the end value in iterator range-specification with a negative step
  !$omp target map(present, iterator(integer :: i = 1:10:-2), to: x(i))
  x = x + 1
  !$omp end target
end
subroutine f19(x)
  integer :: x(10)
!WARNING: The begin value is greater than the end value in iterator range-specification with a positive step
  !$omp target map(present, iterator(integer :: i = 12:1:2), to: x(i))
  x = x + 1
  !$omp end target
end
subroutine f1a(x)
  integer :: x(10)
!ERROR: 'iterator' modifier cannot occur multiple times
  !$omp target map(present, iterator(i = 1:2), iterator(j = 1:2), to: x(i + j))
  x = x + 1
  !$omp end target
end
subroutine f23(x)
  integer :: x(10)
!ERROR: 'map-type' should be the last modifier
  !$omp target map(present, from, iterator(i = 1:10): x(i))
  x = x + 1
  !$omp end target
end
