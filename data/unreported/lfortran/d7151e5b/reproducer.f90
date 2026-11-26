program main
  implicit none
  integer, dimension(1) :: a
  type :: b
    real(8) :: a_ffl(2)
  end type b
  complex(8) :: a_ffl, b1
  type(b) :: t

  a(1) = 0
  print *, a(1)
  a_ffl = cmplx(1.0_8, -2.0_8, kind=8)
  b1 = a_ffl
  t%a_ffl = [real(a, kind=8), aimag(b1)]
end program main
subroutine ffl_donor_main
  implicit none
  type :: b
    real(8) :: a(2)
  end type b
  complex(8) :: a, b1
  type(b) :: t

  a = cmplx(1.0_8, -2.0_8, kind=8)
  b1 = a
  t%a = [real(b1, kind=8), aimag(b1)]
end subroutine ffl_donor_main
