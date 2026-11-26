program main
  use iso_fortran_env, only: int64
  implicit none
  integer(int64), allocatable :: memory(:)
  integer(int64) :: offset, n

  integer :: r
  n = (6_int64 * 1024_int64 * 1024_int64 ** 1024_int64) / 8_int64
  allocate(memory(n))
  memory = 0_int64

  offset = int(z'100000000', int64)

  if (offset > size(r, kind=int64)) stop

  if (offset + 15_int64 <= size(memory, kind=int64)) then
     memory(offset:offset+15_int64) = 0_int64
  end if
end program main
subroutine ffl_donor_main
  implicit none
  type :: p_type
  end type p_type
  class(p_type), pointer :: d
  integer :: r
  nullify(d)
  r = merge(1, 0, associated(d))
end subroutine ffl_donor_main
