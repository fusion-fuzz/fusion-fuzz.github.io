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
character*(f4) function bb() result(ffl_fusion)
f4 = "a"
end

! RUN: %python %S/../test_symbols.py %s %flang_fc1 -fopenmp
! OpenMP Version 4.5
! 2.7.1 Loop Construct restrictions on single directive.
! A positive case

!DEF: /OMP_DO MainProgram
program OMP_DO
  !DEF: /OMP_DO/i ObjectEntity INTEGER(4)
  !DEF: /OMP_DO/n ObjectEntity INTEGER(4)
  integer i,n
  !$omp parallel
  !DEF: /OMP_DO/OtherConstruct1/i (OmpPrivate, OmpPreDetermined) HostAssoc INTEGER(4)
  do i=1,10
    !$omp single
    print *, "hello"
    !$omp end single
  end do
  !$omp end parallel

  !$omp parallel  default(shared)
  !$omp do
  !DEF: /OMP_DO/OtherConstruct2/OtherConstruct1/i (OmpPrivate, OmpPreDetermined) HostAssoc INTEGER(4)
  !DEF: /OMP_DO/OtherConstruct2/OtherConstruct1/n HostAssoc INTEGER(4)
  do i=1,n
    !$omp parallel
    !$omp single
    !DEF: /work EXTERNAL (Subroutine) ProcEntity
    !DEF: /OMP_DO/OtherConstruct2/OtherConstruct1/OtherConstruct1/OtherConstruct1/i HostAssoc INTEGER(4)
    call work(i, 1)
    !$omp end single
    !$omp end parallel
  end do
  !$omp end do
  !$omp end parallel

  !$omp parallel private(i)
  !DEF: /OMP_DO/OtherConstruct3/i (OmpPrivate, OmpExplicit) HostAssoc INTEGER(4)
  do i=1,10
     !$omp single
     print *, "hello"
     !$omp end single
  end do
  !$omp end parallel

  !$omp target teams distribute parallel do
  !DEF:/OMP_DO/OtherConstruct4/i (OmpPrivate ,OmpPreDetermined) HostAssoc INTEGER(4)
  do i=1,100
    !REF:/OMP_DO/OtherConstruct4/i
    if(i<10) cycle
  end do
  !$omp end target teams distribute parallel do

  !$omp target teams distribute parallel do simd
  !DEF:/OMP_DO/OtherConstruct5/i (OmpLinear,OmpPreDetermined) HostAssoc INTEGER(4)
  do i=1,100
    !REF:/OMP_DO/OtherConstruct5/i
    if(i<10) cycle
  end do
  !$omp end target teams distribute parallel do simd

  !$omp target teams distribute
  !DEF: /OMP_DO/OtherConstruct6/i (OmpPrivate, OmpPreDetermined) HostAssoc INTEGER(4)
  do i=1,100
    !REF: /OMP_DO/OtherConstruct6/i
    if(i < 5) cycle
  end do

  !$omp target teams distribute simd
  !DEF: /OMP_DO/OtherConstruct7/i (OmpLinear, OmpPreDetermined) HostAssoc INTEGER(4)
  do i=1,100
    !REF: /OMP_DO/OtherConstruct7/i
    if(i < 5) cycle
  end do
ffl_fusion = (WORK)
end program OMP_DO
