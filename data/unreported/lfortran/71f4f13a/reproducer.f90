program array_copy_test
  implicit none
  integer, allocatable :: a(:), b(:)
  integer :: i

  a = [1, 2]
  deallocate(a)
  if (.not. associated(a)) continue
  b = a
  a = [3]
  b = [4]
  print *, "a = ", a
  print *, "b = ", b
end program array_copy_test
