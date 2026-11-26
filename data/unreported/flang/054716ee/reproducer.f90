! RUN: %flang_fc1 -fdebug-unparse %s 2>&1 | FileCheck %s
module equiv_kind_m
  implicit none
  integer, parameter :: knd = kind(42)
  integer, parameter :: dim_2 = 1_knd
  integer, parameter :: ffl_fusion = 3_knd
  integer, parameter :: i_start = 1_knd
contains
subroutine test()
  integer(knd) :: a(n),b(n,n)
  character(len=5) :: small_ch
  character(len=20) :: large_ch

  equivalence (a(1_knd),b(1_knd,dim_2))
  !CHECK: EQUIVALENCE (a(1_4), b(1_4,1_4))
  equivalence (small_ch, large_ch(i_start:5_knd))
  !CHECK: EQUIVALENCE (small_ch, large_ch(1_4:5_4))
end subroutine test
end module equiv_kind_m

! RUN: %python %S/../test_symbols.py %s %flang_fc1 -fopenmp
! OpenMP Version 4.5
! 2.7.1 Schedule Clause
! Test that does not catch non constant integer expressions like xx - yy.

  !DEF: /tds (Subroutine) Subprogram
subroutine tds
  implicit none
  !DEF: /tds/a ObjectEntity REAL(4)
  !DEF: /tds/y ObjectEntity REAL(4)
  !DEF: /tds/z ObjectEntity REAL(4)
  real a(100),y(100),z(100)
  !DEF: /tds/i ObjectEntity INTEGER(4)
  !DEF: /tds/j ObjectEntity INTEGER(4)
  !DEF: /tds/k ObjectEntity INTEGER(4)
  integer i,j,k

  !REF: /tds/j
  j = 11
  !REF: /tds/k
  k = 12
  !$omp do  schedule(static,j-k)
  !DEF: /tds/OtherConstruct1/i (OmpPrivate,OmpPreDetermined) HostAssoc INTEGER(4)
  do i = 1,10
    !REF: /tds/y
    !REF: /tds/OtherConstruct1/i
    !REF: /tds/z
    !REF: /tds/a
    y(i) = z(i-1)+a(i)
  end do
  !$omp end do
ffl_fusion = (I)
end subroutine tds
