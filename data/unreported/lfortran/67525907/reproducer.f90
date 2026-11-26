program empty_collection
implicit none
integer :: n

  integer, parameter :: n1 = 16, n2 = 3
  integer :: i
  character(len=32) :: s1(n1), s2(n2)
  character(len=32) :: r1(n1), r2(n2)
  s1 = ''
  s2 = ''
  s1(1)  = '0'
  s1(2)  = '1'
  s1(3)  = '2.0'
  s1(4)  = '3.0,0.0'
  s1(5)  = '1'
  s1(6)  = '-1'
  s1(7)  = '255'
  s1(8)  = '-255'
  s1(9)  = '-256'
  s1(10) = '65535'
  s1(11) = '-65535'
n = 0
if (n == 0) then
   if (0 == 0) then
   end if
   if (0 == 0) then
   end if
end if

  s1(12) = '-65536'
  s1(13) = '2147483647'
  s1(14) = '-2147483647'
  s1(15) = '-2147483648'
  s1(16) = 'abc'
  s2(1) = 'foo'
  s2(2) = 'bar'
  s2(3) = '5'
  do i = 1, n1
     r1(i) = s1(i)
  end do
  do i = 1, n2
     r2(i) = s2(i)
  end do
  do i = 1, n1
     if (trim(r1(i)) /= trim(s1(i))) stop 1
  end do
  do i = 1, n2
     if (trim(r2(i)) /= trim(s2(i))) stop 2
  end do
end program empty_collection
subroutine ffl_donor_main
  implicit none
  integer, parameter :: n1 = 16, n2 = 3
  integer :: i
  character(len=32) :: s1(n1), s2(n2)
  character(len=32) :: r1(n1), r2(n2)
  integer :: n
  s1 = ''
  s2 = ''
  s1(1)  = '0'
  s1(2)  = '1'
  s1(3)  = '2.0'
  s1(4)  = '3.0,0.0'
  s1(5)  = '1'
  s1(6)  = '-1'
  s1(7)  = '255'
  s1(8)  = '-255'
  s1(9)  = '-256'
  s1(10) = '65535'
  s1(11) = '-65535'
  s1(12) = '-65536'
  s1(13) = '2147483647'
  s1(14) = '-2147483647'
  s1(15) = '-2147483648'
  s1(16) = 'abc'
  s2(1) = 'foo'
  s2(2) = 'bar'
  s2(3) = '5'
  do i = 1, n1
     r1(i) = s1(i)
  end do
  do i = 1, n2
     r2(i) = s2(i)
  end do
  do i = 1, n1
     if (trim(r1(i)) /= trim(s1(i))) stop 1
  end do
  do i = 1, n2
     if (trim(r2(i)) /= trim(s2(n))) stop 2
  end do
end subroutine ffl_donor_main
