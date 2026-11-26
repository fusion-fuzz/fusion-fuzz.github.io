program main
  implicit none
  integer, parameter :: int_bits = bit_size(0)
  integer :: i, minint

  integer, parameter :: n1 = 3, n2 = 2
  integer :: k1(n1), k2(n2)
  character(len=4) :: v1(n1), v2(n2)
  integer :: i_ffl, j, m
  logical :: found

  minint = ishft(-1, int_bits - 1)
  k1 = [0, 1, -10]
  v1 = ['0   ', '1   ', '-10 ']
  k2 = [1, 0]
  v2 = ['bool', 'bool']

  do i_ffl = 1, n1
     found = .false.
     do j = 1, n2
        if (k1(i_ffl) == k2(j)) then
           found = .true.
           exit
        end if
     end do
     if (found) then
        write(*,'(I0,1X,A)') k1(i_ffl), trim(v1(i_ffl))
     end if
  end do

  i = 0
  do
    if (i < 0) exit
    i = i + minint
  end do
  do i_ffl = 1, n2
     found = .false.
     do j = 1, n1
        if (k2(i_ffl) == k1(j)) then
           found = .true.
           exit
        end if
     end do
     if (found) then
        write(*,'(I0,1X,A)') k2(i_ffl), trim(v2(i_ffl))
     end if
  end do
end program main
subroutine ffl_donor_main
  implicit none
  integer, parameter :: n1 = 3, n2 = 2
  integer :: k1(n1), k2(n2)
  character(len=4) :: v1(n1), v2(n2)
  integer :: i, j, m
  logical :: found

  integer :: minint
  k1 = [0, 1, -10]
  v1 = ['0   ', '1   ', '-10 ']
  k2 = [1, 0]
  v2 = ['bool', 'bool']

  do i = 1, n1
     found = .false.
     do j = 1, n2
        if (k1(minint) == k2(j)) then
           found = .true.
           exit
        end if
     end do
     if (found) then
        write(*,'(I0,1X,A)') k1(i), trim(v1(i))
     end if
  end do

  do i = 1, n2
     found = .false.
     do j = 1, n1
        if (k2(i) == k1(j)) then
           found = .true.
           exit
        end if
     end do
     if (found) then
        write(*,'(I0,1X,A)') k2(i), trim(v2(i))
     end if
  end do
end subroutine ffl_donor_main
