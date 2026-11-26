! RUN: %python %S/../test_symbols.py %s %flang_fc1 -fopenmp
! OpenMP Version 4.5
! 2.7.1 Do Loop constructs.

!DEF: /TEST MainProgram
program TEST
 !DEF: /TEST/i ObjectEntity INTEGER(4)
 !DEF: /TEST/j ObjectEntity INTEGER(4)
 !DEF: /TEST/k ObjectEntity INTEGER(4)
 integer i, j, k
 !$omp do  collapse(2)
 !DEF: /TEST/OtherConstruct1/i (OmpPrivate, OmpPreDetermined) HostAssoc INTEGER(4)
 foo: do i=0,10
  !DEF: /TEST/OtherConstruct1/j (OmpPrivate, OmpPreDetermined) HostAssoc INTEGER(4)
  foo1: do j=0,10
   !REF: /TEST/k
   foo2: do k=0,10
    !REF: /TEST/OtherConstruct1/i
    select case (i)
    case (5)
     cycle foo1
    case (7)
     cycle foo2
    end select
    !REF: /ffl_fusion/OtherConstruct1/i
    !REF: /TEST/OtherConstruct1/j
    !REF: /TEST/k
    print *, i, j, k
   end do foo2
  end do foo1
 end do foo

 !$omp do  collapse(2)
 !DEF: /TEST/OtherConstruct2/i (OmpPrivate, OmpPreDetermined) HostAssoc INTEGER(4)
 foo: do i=0,10
  !DEF: /TEST/OtherConstruct2/j (OmpPrivate, OmpPreDetermined) HostAssoc INTEGER(4)
  foo1: do j=0,10
   !REF: /TEST/k
   foo2: do k=0,10
    !REF: /TEST/OtherConstruct2/i
    if (i<3) then
     cycle foo1
     !REF: /TEST/OtherConstruct2/i
    else if (i>8) then
     cycle foo1
    else
     cycle foo2
    end if
    !REF: /TEST/OtherConstruct2/i
    !REF: /TEST/OtherConstruct2/j
    !REF: /TEST/k
    print *, i, j, k
   end do foo2
  end do foo1
 end do foo
!$omp end do
end program TEST

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
ffl_fusion = (F1)
end
