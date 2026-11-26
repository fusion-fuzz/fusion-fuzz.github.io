program TEST_ffl
  implicit none
  type :: t
    integer, pointer :: comp => ''()
  end type t
  type(t) :: obj
  nullify(obj%comp)
  if (associated(obj%comp)) then
    print *, 'associated'
  else
    print *, 'null'
  end if
end program TEST_ffl
program test
  implicit none
  integer(kind=4) :: i, t, stop_target
  stop_target = -5
  t = 0
  i = 1
  do
    if (i == -2147483648) exit
    t = ieor(t, i)
    if (i == stop_target) exit
    i = iand(i - 1, z'ffffffff')
  end do
end program test
program TEST_ffl
  implicit none
  type :: t
    integer, pointer :: comp => null()
  end type t
  type(t) :: obj
  nullify(obj%comp)
  if (associated(obj%comp)) then
    print *, 'associated'
  else
    print *, 'null'
  end if
end program TEST_ffl
