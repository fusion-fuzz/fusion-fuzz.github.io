program main
  implicit none
  integer :: n, ios
  character(len=32) :: arg
  n = command_argument_count()
  if (n == 0) then
     call get_command_argument(0, arg)
     call execute_command_line(trim(arg)//' foo', wait=.true., exitstat=ios)
  else
     stop 259
  end if
  call ffl_donor_main
end program main
subroutine ffl_donor_main
  implicit none
  integer, parameter :: n = 64
  character(len=1) :: buf(n), buf2(n)
  character(len=1), pointer :: p(:), r(:)
  integer :: i, x, k

  character(len=32) :: arg
  buf = 'a'
  buf2 = 'b'
  p => buf(9:n)
  r => buf2

  x = 10
  do i = 0, x - 1
     do k = 1, i
        r(k) = p(k)
     end do
     if (i < n) then
        r => arg(i + 2:n)
     end if
     if (i < n) then
        p => r
     end if
  end do
end subroutine ffl_donor_main
