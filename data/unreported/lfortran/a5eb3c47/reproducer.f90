program main
  use iso_fortran_env, only: int64
  implicit none
  integer(int64) :: a, b, c, t, r

  a = 9_int64
  b = 2_int64
  c = 1_int64
  t = iand(a + b, huge(0_int64) * 2_int64 + 1_int64)
  r = t + c

  a = 1_int64
  b = -2_int64
  c = 1_int64
  t = iand(a + b, huge(0_int64) * 2_int64 + 1_int64)
  r = t + c

  call ffl_donor_main
end program main
subroutine ffl_donor_main
  use, intrinsic :: iso_fortran_env, only: int64
  implicit none
  type :: p_type
  contains
    procedure :: meth1
  end type
  type :: i_type
  end type
  type, extends(i_type) :: i2_c_type
  end type
  type(p_type) :: p
  type(i_type) :: i
  type(i2_c_type) :: ic
  integer(int64) :: a
  call p%meth1()
  call p%a()
contains
  subroutine meth1(self)
    class(p_type), intent(in) :: self
  end subroutine
end subroutine ffl_donor_main
