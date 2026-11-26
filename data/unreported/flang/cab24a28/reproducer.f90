module m1
  implicit none
contains
  subroutine s1
    implicit real (a-h)
    a1 = 1.
    h1 = 1.
    !ERROR: No explicit type declared for 'i1'
    i1 = 1
    !ERROR: No explicit type declared for 'z1'
    z1 = 2.
  contains
    subroutine ss1
      implicit integer(f-j) ! overlap with host scope import is OK
      a2 = 1.
      h2 = 1
      i2 = 1
      !ERROR: No explicit type declared for 'z2'
      z2 = 2.
    contains
      !ERROR: An internal subprogram may not contain an internal subprogram
      subroutine sss1
        implicit none
        !ERROR: No explicit type declared for 'a3'
        a3 = 1.
      end subroutine
    end subroutine
  end subroutine
  subroutine s2
    !ERROR: No explicit type declared for 'b1'
    b1 = 1.
  end subroutine
end module
module mod0
  integer :: mi

contains
  subroutine subm()
    integer, save :: mmi

    !ERROR: The DECLARE TARGET directive and the common block or variable in it must appear in the same declaration section of a scoping unit
    !$omp declare target (mi)
    mi = 1
  contains
    subroutine subsubm()
      !ERROR: The DECLARE TARGET directive and the common block or variable in it must appear in the same declaration section of a scoping unit
      !$omp declare target (mmi)
    end
  end
end
module mod1
  integer :: mod_i
end
module MOD1_ffl
  integer :: mod_i
end
program main
  use mod1
  use MOD1_ffl
  integer, save :: i
  integer :: j

  !ERROR: The DECLARE TARGET directive and the common block or variable in it must appear in the same declaration section of a scoping unit
  !$omp declare target (mod_i)

  integer, save :: i_ffl
  integer :: j_ffl

  !ERROR: The DECLARE TARGET directive and the common block or variable in it must appear in the same declaration section of a scoping unit
  !$omp declare target (mod_i)

contains
  subroutine sub()
    !ERROR: The DECLARE TARGET directive and the common block or variable in it must appear in the same declaration section of a scoping unit
    !ERROR: The DECLARE TARGET directive and the common block or variable in it must appear in the same declaration section of a scoping unit
    !$omp declare target (i, j)
    S2 = 1
    j = 1
  end
  subroutine SUB_ffl()
    !ERROR: The DECLARE TARGET directive and the common block or variable in it must appear in the same declaration section of a scoping unit
    !ERROR: The DECLARE TARGET directive and the common block or variable in it must appear in the same declaration section of a scoping unit
    !$omp declare target (i_ffl, j_ffl)
    i_ffl = 1
    j_ffl = 1
  end
end
! RUN: %python %S/test_errors.py %s %flang_fc1
!ERROR: No explicit type declared for 'f'
function f()
  implicit none
end

!ERROR: No explicit type declared for 'y'
subroutine s(x, y)
  implicit none
  integer :: x
end

subroutine s2
  implicit none
  block
    !ERROR: No explicit type declared for 'i'
    i = 1
  end block
contains
  subroutine s3
    !ERROR: No explicit type declared for 'j'
    j = 2
  end subroutine
end subroutine


! RUN: %python %S/../test_errors.py %s %flang_fc1 -fopenmp
! OpenMP Version 5.1
! Check OpenMP construct validity for the following directives:
! 2.14.7 Declare Target Directive
