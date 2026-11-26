program main
  use iso_c_binding
  implicit none
  integer :: repllen, len, i
  integer, target :: rp(1), text(1), t(1)
  integer, pointer :: matchstart(:), matchend(:), scan(:)

  type :: u_t
    integer(c_int) :: i_ffl, j
  end type
  type(u_t), target :: u, v
  type(c_ptr) :: p, p2
  type(c_ptr), pointer :: pp
  integer(c_intptr_t) :: a, b, same1, same2

  repllen = 1
  rp(1) = 0
  text(1) = 0
  t(1) = 0

  repllen = repllen - 1

  matchstart => t(1:1)
  matchend => rp(1:1)
  len = size(matchstart) - size(text) + repllen * (size(matchend) - size(matchstart))
  do while (len /= 0)
    len = 0
  end do

  do i = 1, size(text)
    if (i == rp(1)) exit
  end do

  if (associated(matchstart)) then
    text = matchend
  end if
  u%i_ffl = 97531_c_int
  u%j = 86420_c_int
  p = c_loc(u)
  call c_f_pointer(p, pp)
  call move_alloc(transfer(pp, [0_c_intptr_t]), [0_c_intptr_t])
  call c_f_pointer(p, pp)
  a = transfer(pp, a)
  v%i_ffl = 123_c_int
  v%j = 456_c_int
  p2 = c_loc(v)
  b = transfer(c_loc(u), b)
  same1 = merge(1_c_intptr_t, 0_c_intptr_t, c_associated(p, p))
  same2 = merge(1_c_intptr_t, 0_c_intptr_t, c_associated(p, p2))
  print *, u%i_ffl, u%j, same1, same2
end program main
