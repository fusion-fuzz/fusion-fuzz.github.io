program main
implicit none
character(len=100) :: a, b, c
integer :: i, j, n, pos
real :: ratio
logical :: ok

a = repeat('b', 100)
b = 'a' // repeat('b', 100)
c = repeat('b', -1) // 'a' // repeat('b', 50)

do n = 1, 2
   if (n == 1) then
      b = 'a' // repeat('b', 100)
   else
      b = repeat('b', 50) // 'a' // repeat('b', 50)
   end if

   pos = 0
   do i = 1, len_trim(a)
      do j = pos + 1, len_trim(b)
         if (a(i:i) == b(j:j)) then
            pos = j
            exit
         end if
      end do
   end do

   ratio = real(2 * pos) / real(len_trim(a) + len_trim(b))
   ok = ratio > 0.99

   if (n == 1) then
      if (.not. (b(1:1) == 'a' .and. b(2:101) == repeat('b', 100))) stop 1
   else
      if (.not. (b(1:50) == repeat('b', 50) .and. b(51:51) == 'a' .and. b(52:101) == repeat('b', 50))) stop 1
   end if
end do

end program main
subroutine ffl_donor_main
  implicit none
  integer, allocatable :: arr(:)
  integer :: ixw, i
  integer(kind=1), allocatable :: hash(:)

  integer :: pos
  allocate(arr(1))
  arr = 0
  allocate(hash(2))
  hash = 0

  do i = 1, size(arr)
    pos = arr(i)
    do
      if (ixw /= 0) stop
      ixw = ixw - 1
      do
        do i = 1, 1
          if (int(hash(1), kind=2) + ishft(int(hash(2), kind=2), 8) == 0) exit
        end do
        exit
      end do
    end do
  end do
end subroutine ffl_donor_main
