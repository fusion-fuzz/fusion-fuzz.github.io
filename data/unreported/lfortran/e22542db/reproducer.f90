program main
  implicit none
  character(len=32) :: s
  real :: x
  integer :: i

  integer, parameter :: size = selected_int_kind(18)
  integer(kind=8), parameter :: big = ishft(1_8, 58)
  type :: chunk1
     character(len=1) :: padding(big)
     character(len=1) :: more_padding(big,1)
     character(len=1) :: data
  end type
  type :: chunk2
     character(len=1) :: padding(big,big,big)
     character(len=1) :: data
  end type
  type(chunk1) :: a
  type(chunk2), allocatable :: b
  integer(kind=8) :: off1, off2
  x = 12345.67
  write(s,'(f9.2)') x
  off1 = loc(a%data) - loc(a)
  allocate(b)
  off2 = loc(b%data) - loc(b)
  deallocate(b)

  do i = 1, len_trim(s)
     if (s(i:i) == '0') s(i:i) = ' '
  end do

  if (index(s, '.') == 0) then
     write(*,*) trim(s)
  else
     write(*,*) trim(adjustl(s))
  end if
end program main
subroutine ffl_donor_main
  implicit none
  integer, parameter :: size = selected_int_kind(18)
  integer(kind=8), parameter :: big = ishft(1_8, 58)
  type :: chunk1
     character(len=1) :: padding(big)
     character(len=1) :: more_padding(big,1)
     character(len=1) :: data
  end type
  type :: chunk2
     character(len=1) :: padding(big,big,big)
     character(len=1) :: data
  end type
  type(chunk1) :: a
  type(chunk2), allocatable :: b
  integer(kind=8) :: off1, off2
  off1 = loc(a%data) - loc(a)
  allocate(b)
  off2 = loc(b%data) - loc(b)
  deallocate(b)
end subroutine ffl_donor_main
