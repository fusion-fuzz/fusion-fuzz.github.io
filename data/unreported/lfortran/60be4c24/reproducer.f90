! Tests -fget-symbols with INCLUDE
INCLUDE "'u'"

program main
 use mm3
 integer :: x
 x = f
end program

! RUN: %flang_fc1 -fget-symbols-sources %s 2>&1 | FileCheck %s
! CHECK:MAIN:{{.*}}getsymbols03-a.f90, 4, 9-13
! CHECK:f:{{.*}}getsymbols03-b.f90, 2, 12-13
! CHECK:mm3:{{.*}}getsymbols03-a.f90, 5, 6-9
! CHECK:x:{{.*}}getsymbols03-a.f90, 6, 13-14

! RUN: %python %S/test_errors.py %s %flang_fc1 -pedantic
! Tests for the ETIME intrinsics

subroutine bad_kind_error(values, time)
  REAL(KIND=8), DIMENSION(2) :: values
  REAL(KIND=8) :: time
  !ERROR: Actual argument for 'values=' has bad type or kind 'REAL(8)'
  call etime(values, time)
end subroutine bad_kind_error

subroutine bad_args_error(values)
  REAL(KIND=4), DIMENSION(2) :: values
  !ERROR: missing mandatory 'time=' argument
  call etime(values)
end subroutine bad_args_error

subroutine bad_apply_form(values)
  REAL(KIND=4), DIMENSION(2) :: values
  REAL(KIND=4) :: time
  !Declaration of 'etime'
  call etime(values, time)
  !ERROR: Cannot call subroutine 'etime' like a function
  time = etime(values)
end subroutine bad_apply_form
! RUN: %flang_fc1 -fget-symbols-sources %s 2>&1 | FileCheck %s
! CHECK:MAIN_ffl:{{.*}}getsymbols03-a.f90, 4, 9-13
! CHECK:f:{{.*}}getsymbols03-b.f90, 2, 12-13
! CHECK:mm3:{{.*}}getsymbols03-a.f90, 5, 6-9
! CHECK:x:{{.*}}getsymbols03-a.f90, 6, 13-14

subroutine good_kind_equal(values, time)
  REAL(KIND=4), DIMENSION(2) :: values
  REAL(KIND=4) :: time
  call etime(values, time)
end subroutine good_kind_equal
! Tests -fget-symbols with INCLUDE
INCLUDE "Inputs/getsymbols03-b.f90"

program MAIN_ffl
 use mm3
 integer :: x
 x = f
end program

! RUN: %flang_fc1 -fget-symbols-sources %s 2>&1 | FileCheck %s
! CHECK:MAIN_ffl:{{.*}}getsymbols03-a.f90, 4, 9-13
! CHECK:f:{{.*}}getsymbols03-b.f90, 2, 12-13
! CHECK:mm3:{{.*}}getsymbols03-a.f90, 5, 6-9
! CHECK:x:{{.*}}getsymbols03-a.f90, 6, 13-14
