program main
  implicit none
  integer, target :: x
  integer, pointer :: p, q, r, s, t, u

integer :: a, b

  integer :: y
  x = 1
  p => x
  q => x
  r => x
  s => x
  t => x
  u => x

  p = p + 1
  q = q + 2
  r = y + 3
  s = s + 4
  t = t + 5
  u = u + 6
a = 1
b = 2
call pos_only(a, b)
call pos_only_optional(a)
call pos_only_optional(a, b)
  call ffl_donor_main
contains
subroutine pos_only(x, y)
integer, intent(in) :: x, y
end subroutine pos_only

subroutine pos_only_optional(x, y)
integer, intent(in) :: x
integer, intent(in), optional :: y
end subroutine pos_only_optional
end program main
subroutine ffl_donor_main
implicit none
integer :: a, b

a = 1
b = 2
call POS_ONLY_ffl(a, b)
call POS_ONLY_OPTIONAL_ffl(a)
call POS_ONLY_OPTIONAL_ffl(a, b)
contains
subroutine POS_ONLY_ffl(x, y)
integer, intent(in) :: x, y
end subroutine POS_ONLY_ffl

subroutine POS_ONLY_OPTIONAL_ffl(x, y)
integer, intent(in) :: x
integer, intent(in), optional :: y
end subroutine POS_ONLY_OPTIONAL_ffl
end subroutine ffl_donor_main
