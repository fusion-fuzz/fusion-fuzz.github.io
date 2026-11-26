program main
  use iso_fortran_env, only: int8, int16, int64
  use iso_fortran_env, only: int64
  implicit none

  type :: wrapper
     integer(int16) :: a = 10_int16
     integer(int8)  :: b = 0_int8
  end type wrapper

  type :: misalign
     integer(int8) :: pad = 0_int8
     type(wrapper) :: w
  end type misalign

  type(misalign), target :: m
  type(wrapper), pointer :: p
  integer(int64) :: addr

  integer(int64), target :: a_ffl(2)
  integer(int64), pointer :: p_ffl(:)
  integer :: capacity

  m%pad = 0_int8
  m%w%a = 10_int16
  m%w%b = 0_int8

  p => m%w
  addr = transfer(c_loc(p), addr)
  if (mod(addr, 2_int64) /= 0_int64) stop 1

  a_ffl = [1_int64, 2_int64]
  p_ffl => a_ffl
  capacity = 2
  p_ffl(1) = -p_ffl(1)
  p_ffl(2) = -p(2)
  call ffl_donor_main
end program main
subroutine ffl_donor_main
  use iso_fortran_env, only: int64
  implicit none
  integer(int64), target :: a(2)
  integer(int64), pointer :: p(:)
  integer :: capacity

  a = [1_int64, 2_int64]
  p => a
  capacity = 2
  p(1) = -p(1)
  p(2) = -p(2)
end subroutine ffl_donor_main
