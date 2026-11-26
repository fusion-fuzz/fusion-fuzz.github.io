program main
  implicit none
  integer :: i
  integer :: argc
  integer, target :: aa, bb
  integer, pointer :: p
  integer :: fp
  integer :: x
  character(len=:), allocatable :: arg

  argc = command_argument_count()
  i = 0
  do while (.false.)
     i = i + 1
  end do
  aa = 1
  bb = 0

  if (argc == 0) then
    p => aa
  else
    p => bb
  end if
  p = 0

  if (argc == 0) then
    fp = 0
  else
    fp = 2
  end if
  aa = fp

  x = 0
  if (argc == 0) then
    x = x + 1
  else
    x = x - 1
  end if

end program main
subroutine ffl_donor_main
  implicit none
  integer :: argc
  integer, target :: aa, bb
  integer, pointer :: p
  integer :: fp
  integer :: x
  character(len=:), allocatable :: arg

  integer :: i
  argc = command_argument_count()
  aa = 1
  bb = 0

  if (argc == 0) then
    p => aa
  else
    p => bb
  end if
  i = 0

  if (argc == 0) then
    fp = 0
  else
    fp = 2
  end if
  aa = fp

  x = 0
  if (argc == 0) then
    x = x + 1
  else
    x = x - 1
  end if

end subroutine ffl_donor_main
