! RUN: %python %S/test_errors.py %s %flang_fc1
integer, parameter :: j = 5
real a(5)
!ERROR: 'j' is not a variable
read *, (a(j), j=1, 5)
!ERROR: 'j' is not a variable
print *, (a(j), j=1, 5)
end

program main
  implicit none
  character(len=5), dimension(:), allocatable :: arr
  arr = get_prop('arr')
  integer :: i
  do i = 1, size(arr)
    print *, arr(i)
  end do
  real a(5)
  !ERROR: 'j' is not a variable
  read *, (a(j), j=1, 5)
  !ERROR: 'j' is not a variable
  print *, (a(j), j=1, 5)
contains
  function get_prop(name) result(res)
    character(len=*), intent(in) :: name
    character(len=5), dimension(:), allocatable :: res
    if (name == 'arr') then
      res = (/ 'Hello', 'World' /)
    else
      allocate(res(0))
    end if
  end function get_prop
end program
