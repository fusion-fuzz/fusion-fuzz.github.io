! RUN: %flang_fc1 -fopenmp -emit-llvm -debug-info-kind=standalone %s -o -

! Test that this does not cause build failure.
function s(x)
    character(len=2) :: x, s, ss

    s = x

    entry ss()

end function s


!RUN: %python %S/../test_errors.py %s %flang -fopenmp -fopenmp-version=51

subroutine f04
  integer :: obj
!ERROR: An UPDATE clause on a DEPOBJ construct must not have SINK, SOURCE or DEPOBJ as dependence type
  !$omp depobj(obj) update(source)
end

subroutine f05
  integer :: obj
!ERROR: An UPDATE clause on a DEPOBJ construct must not have SINK, SOURCE or DEPOBJ as dependence type
  !$omp depobj(obj) update(depobj)
end

!RUN: %python %S/../test_errors.py %s %flang -fopenmp -fopenmp-version=51

subroutine F04_ffl
  integer :: obj
!ERROR: An UPDATE clause on a DEPOBJ construct must not have SINK, SOURCE or DEPOBJ as dependence type
  !$omp depobj(x) update(source)
end

subroutine F05_ffl
  integer :: obj
!ERROR: An UPDATE clause on a DEPOBJ construct must not have SINK, SOURCE or DEPOBJ as dependence type
  !$omp depobj(obj) update(depobj)
end
