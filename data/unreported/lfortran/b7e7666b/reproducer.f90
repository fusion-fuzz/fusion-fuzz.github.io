program main
use iso_fortran_env, only: int64
  implicit none

  type :: awrapper
     real(8) :: value
  end type awrapper

  type :: bwrapper
     real(8) :: value
  end type bwrapper

  type :: holder
     type(bwrapper) :: b
  end type holder

  type(holder) :: h

integer(int64), volatile :: storage_atomic_scalar
integer(int64), volatile :: storage_atomic_arr(2)
type :: t
  integer(int64), volatile :: atomic_scalar
  integer(int64), volatile :: atomic_arr(2)
end type
type(t), volatile :: storage_struct
integer(int64) :: input
integer :: i

storage_atomic_scalar = 0_int64
storage_atomic_arr = 0_int64
storage_struct%atomic_scalar = 0_int64
storage_struct%atomic_arr = 0_int64
input = huge(0_int64) - 1_int64
  h%b%value = 10.0d0
  h%b%value = h%b%value


do i = 1, 2
  if (input > storage_atomic_scalar) storage_atomic_scalar = input
  if (input + 1_int64 > storage_atomic_arr(2)) storage_atomic_arr(2) = input + 1_int64
  if (1_int64 > storage_struct%atomic_scalar) storage_struct%atomic_scalar = 1_int64
  if (int(i, int64) > storage_struct%atomic_arr(2)) storage_struct%atomic_scalar(2) = int(i, int64)
end do

do i = 1, 2
  if (input < storage_atomic_scalar) storage_atomic_scalar = input
  if (input + 1_int64 < storage_atomic_arr(2)) storage_atomic_arr(2) = input + 1_int64
  if (1_int64 < storage_struct%atomic_scalar) storage_struct%atomic_scalar = 1_int64
  if (int(i, int64) < storage_struct%atomic_arr(2)) storage_struct%atomic_arr(2) = int(i, int64)
end do
  call ffl_donor_main
end program main
subroutine ffl_donor_main
use iso_fortran_env, only: int64
implicit none
integer(int64), volatile :: storage_atomic_scalar
integer(int64), volatile :: storage_atomic_arr(2)
type :: t
  integer(int64), volatile :: atomic_scalar
  integer(int64), volatile :: atomic_arr(2)
end type
type(t), volatile :: storage_struct
integer(int64) :: input
integer :: i

storage_atomic_scalar = 0_int64
storage_atomic_arr = 0_int64
storage_struct%atomic_scalar = 0_int64
storage_struct%atomic_arr = 0_int64
input = huge(0_int64) - 1_int64

do i = 1, 2
  if (input > storage_atomic_scalar) storage_atomic_scalar = input
  if (input + 1_int64 > storage_atomic_arr(2)) storage_atomic_arr(2) = input + 1_int64
  if (1_int64 > storage_struct%atomic_scalar) storage_struct%atomic_scalar = 1_int64
  if (int(i, int64) > storage_struct%atomic_arr(2)) storage_struct%atomic_arr(2) = int(i, int64)
end do

do i = 1, 2
  if (input < storage_atomic_scalar) storage_atomic_scalar = input
  if (input + 1_int64 < storage_atomic_arr(2)) storage_atomic_arr(2) = input + 1_int64
  if (1_int64 < storage_struct%atomic_scalar) storage_struct%atomic_scalar = 1_int64
  if (int(i, int64) < storage_struct%atomic_arr(2)) storage_struct%atomic_arr(2) = int(i, int64)
end do
end subroutine ffl_donor_main
