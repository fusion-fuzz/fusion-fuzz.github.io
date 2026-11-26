program main
  implicit none
  integer :: x


  type :: s2
     integer(kind=8) :: f1
  end type s2

  type :: s1
     complex(kind=8) :: f1
     type(s2) :: f2
     integer(kind=8) :: f3
  end type s1

  type(s1) :: p0exp, p0

  x = 42
  p0exp%f1 = cmplx(2.3640607624715027d0, -0.2717825524109192d0, kind=8)
  select case (0)
  case (:x-1)
  case default
  end select

  select case (0)
  case (:x)
  case default
  end select

  select case (0)
  case (x:)
  case default
  end select
  p0exp%f2%f1 = 9_8
  p0exp%f3 = 103050709_8

  p0 = p0exp

  if (real(p0%f1, kind=8) %= real(p0exp%f1, kind=8) .or. aimag(p0%f1) /= aimag(p0exp%f1) .or. &
      p0%f2%f1 /= p0exp%f2%f1 .or. p0%f3 /= p0exp%f3) stop 1
  call ffl_donor_main
end program main
subroutine ffl_donor_main
  implicit none

  type :: s2
     integer(kind=8) :: f1
  end type s2

  type :: s1
     complex(kind=8) :: f1
     type(s2) :: f2
     integer(kind=8) :: f3
  end type s1

  type(s1) :: p0exp, p0

  p0exp%f1 = cmplx(2.3640607624715027d0, -0.2717825524109192d0, kind=8)
  p0exp%f2%f1 = 9_8
  p0exp%f3 = 103050709_8

  p0 = p0exp

  if (real(p0%f1, kind=8) /= real(p0exp%f1, kind=8) .or. aimag(p0%f1) /= aimag(p0exp%f1) .or. &
      p0%f2%f1 /= p0exp%f2%f1 .or. p0%f3 /= p0exp%f3) stop 1
end subroutine ffl_donor_main
