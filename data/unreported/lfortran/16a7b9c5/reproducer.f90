program main
  implicit none

  type :: s
  contains
    procedure, nopass :: from_int
    procedure, nopass :: from_real
  end type s

  type(s) :: x
  integer :: i
  real :: r

  integer(kind=1) :: u, v, w
  u = 0_1
  i = 1
  r = 1.0
  call u%from_int(i)
  call x%from_real(r)

  v = 0_1
  w = 0_1
  if (iand(u - v - w, int(z'80', kind=1)) /= 0_1) v = 1_1
contains

  subroutine from_int(v)
    integer, intent(in) :: v
    if (v /= 0) continue
  end subroutine from_int

  subroutine from_real(v)
    real, intent(in) :: v
    if (v /= 0.0) continue
  end subroutine from_real

end program main
subroutine ffl_donor_main
  implicit none
  integer(kind=1) :: u, v, w
  u = 0_1
  v = 0_1
  w = 0_1
  if (iand(u - v - w, int(z'80', kind=1)) /= 0_1) v = 1_1
end subroutine ffl_donor_main
