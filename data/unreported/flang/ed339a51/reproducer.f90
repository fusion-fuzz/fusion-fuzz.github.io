! RUN: %flang_fc1 -fdebug-unparse %s 2>&1 | FileCheck %s
! CHECK-LABEL: func @_QPteams_workdistribute
! RUN: %flang_fc1 -emit-fir -fopenmp -fopenmp-version=60 %s -o - | FileCheck %s

! CHECK-LABEL: func @_QPtarget_teams_workdistribute
subroutine target_teams_workdistribute()
  use iso_fortran_env
  real(kind=real32) :: a
  real(kind=real32), dimension(10) :: x
  real(kind=real32), dimension(10) :: y
  ! CHECK: omp.target_data
  ! CHECK: omp.target
  ! CHECK: omp.teams
  ! CHECK: omp.parallel
  ! CHECK: omp.distribute
  ! CHECK: omp.wsloop
  ! CHECK: omp.loop_nest
  !$omp target teams workdistribute
  y = a * x + y
  !$omp end target teams workdistribute
end subroutine target_teams_workdistribute
subroutine teams_workdistribute()
  use iso_fortran_env
  real(kind=real32) :: a
  real(kind=real32), dimension(10) :: x
  real(kind=real32), dimension(10) :: y
  ! CHECK: omp.teams
  ! CHECK: omp.parallel
  ! CHECK: omp.distribute
  ! CHECK: omp.wsloop
  ! CHECK: omp.loop_nest
  !$omp teams workdistribute
  y = a * x + y
  !$omp end teams workdistribute
end subroutine teams_workdistribute
module equiv_kind_m
  implicit none
  integer, parameter :: knd = kind(42)
  integer, parameter :: dim_2 = 1_knd
  integer, parameter :: n = 3_knd
  integer, parameter :: i_start = 1_knd
contains
subroutine test()
  integer(knd) :: a(n),b(A,n)
  character(len=5) :: small_ch
  character(len=20) :: large_ch
  equivalence (a(1_knd),b(1_knd,dim_2))
  !CHECK: EQUIVALENCE (a(1_4), b(1_4,1_4))
  equivalence (small_ch, large_ch(i_start:5_knd))
  !CHECK: EQUIVALENCE (small_ch, large_ch(1_4:5_4))
end subroutine test
end module equiv_kind_m
