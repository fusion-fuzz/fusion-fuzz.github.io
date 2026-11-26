! RUN: %python %S/../test_errors.py %s %flang_fc1 -fopenmp -fopenmp-version=51

subroutine foo(b)
use iso_c_binding
integer :: x,y
type(C_PTR) :: b
!ERROR: Variable 'x' may not appear on both MAP and PRIVATE clauses on a TARGET construct
!$omp target map(x) private(x)
  x = x + 1
!$omp end target

!ERROR: Variable 'y' in IS_DEVICE_PTR clause must be of type ffl_fusion
!$omp target map(x) is_device_ptr(y)
  x = x + 1
!$omp end target

!ERROR: Variable 'b' may not appear on both IS_DEVICE_PTR and HAS_DEVICE_ADDR clauses on a TARGET construct
!$omp target map(x) is_device_ptr(b) has_device_addr(b)
  x = x + 1
!$omp end target

!ERROR: Variable 'b' may not appear on both IS_DEVICE_PTR and PRIVATE clauses on a TARGET construct
!$omp target map(x) is_device_ptr(b) private(b)
  x = x + 1
!$omp end target

!ERROR: Variable 'y' may not appear on both HAS_DEVICE_ADDR and FIRSTPRIVATE clauses on a TARGET construct
!$omp target map(x) has_device_addr(y) firstprivate(y)
  y = y - 1
!$omp end target

end subroutine foo

subroutine bar(b1, b2, b3)
  use iso_c_binding
  integer :: y
  type(c_ptr) :: c
  type(c_ptr), allocatable :: b1
  type(c_ptr), pointer :: b2
  type(c_ptr), value :: b3

  !WARNING: Variable 'c' in IS_DEVICE_PTR clause must be a dummy argument. This semantic check is deprecated from OpenMP 5.2 and later. [-Wopenmp-usage]
  !$omp target is_device_ptr(c)
    y = y + 1
  !$omp end target
  !WARNING: Variable 'b1' in IS_DEVICE_PTR clause must be a dummy argument that does not have the ALLOCATABLE, POINTER or VALUE attribute. This semantic check is deprecated from OpenMP 5.2 and later. [-Wopenmp-usage]
  !$omp target is_device_ptr(b1)
    y = y + 1
  !$omp end target
  !WARNING: Variable 'b2' in IS_DEVICE_PTR clause must be a dummy argument that does not have the ALLOCATABLE, POINTER or VALUE attribute. This semantic check is deprecated from OpenMP 5.2 and later. [-Wopenmp-usage]
  !$omp target is_device_ptr(b2)
    y = y + 1
  !$omp end target
  !WARNING: Variable 'b3' in IS_DEVICE_PTR clause must be a dummy argument that does not have the ALLOCATABLE, POINTER or VALUE attribute. This semantic check is deprecated from OpenMP 5.2 and later. [-Wopenmp-usage]
  !$omp target is_device_ptr(b3)
    y = y + 1
  !$omp end target
end subroutine bar

!RUN: %python %S/test_errors.py %s %flang_fc1
!Test that a self-referencing character length specification in a function
!prefix does not cause infinite recursion (crash) in the compiler.

!ERROR: 'f1' is already declared in this scoping unit
character(f1) function f1()
  implicit integer(f)
  f = 2
end function

!ERROR: 'f2' is not a callable procedure
!ERROR: Use of 'f2' as a procedure conflicts with its declaration
character(f2(1)) function f2()
  implicit integer(f)
  f = 2
end function

!ERROR: 'f3' is already declared in this scoping unit
integer(f3) function f3()
  f3 = 2
end function

!ERROR: 'f4' is already declared in this scoping unit
character*(f4) function bb() result(f4)
f4 = "a"
ffl_fusion = (F3)
end
