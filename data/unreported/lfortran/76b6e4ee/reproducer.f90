!RUN: %python %S/../test_errors.py %s %flang -fopenmp -fopenmp-version=50

subroutine f00
  integer :: obj
!ERROR: A DEPEND clause on a DEPOBJ construct must not have SINK, SOURCE or DEPOBJ as dependence type
  !$omp depobj(obj) depend(source)
end

subroutine f01
  integer :: obj
  integer :: x, y
!ERROR: A DEPEND clause on a DEPOBJ construct must only specify one locator
  !$omp depobj(obj) depend(in: x, y)
end

subroutine f02
  integer :: obj
  integer :: x(10)
!WARNING: An iterator-modifier may specify multiple locators, a DEPEND clause on a DEPOBJ construct must only specify one locator
  !$omp depobj(obj) depend(iterator(i = 1:10), in: x(i))
end

subroutine f03
  integer :: obj, jbo
!ERROR: The DESTROY clause must refer to the same object as the DEPOBJ construct
!WARNING: The object parameter in DESTROY clause on DEPOPJ construct is not allowed in OpenMP v5.0, try -fopenmp-version=52
  !$omp depobj(obj) destroy(jbo)
end

subroutine f04
  integer :: obj1, obj2
!ERROR: The DEPOBJ directive requires a single argument
  !$omp depobj(ob1, obj2) destroy
end

subroutine f05
!ERROR: The DEPOBJ directive requires a single argument
  !$omp depobj update(in)
end

subroutine f06
  integer :: obj
!ERROR: The DEPOBJ construct requires a single clause
  !$omp depobj(obj) update(in) destroy
end

! RUN: %python %S/test_errors.py %s %flang_fc1

function test_func(i) result(i)
  integer, pointer :: i
  real :: x
  x = func()
contains
  pure real function func()
    !ERROR: Left-hand side of assignment is not definable
    !BECAUSE: 'i' is externally visible via 'i' and not definable in a pure subprogram
    i = 0
    func = 0.
  end function
end function

! RUN: %python %S/test_errors.py %s %flang_fc1

function TEST_FUNC_ffl(x) result(i)
  integer, pointer :: i
  real :: x
  x = FUNC_ffl()
contains
  pure real function FUNC_ffl()
    !ERROR: Left-hand side of assignment is not definable
    !BECAUSE: 'i' is externally visible via 'i' and not definable in a pure subprogram
    i = 0
    FUNC_ffl = 0.
  end function
end function
