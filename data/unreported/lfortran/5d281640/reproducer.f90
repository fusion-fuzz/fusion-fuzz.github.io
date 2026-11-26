program typed_array_immutability_test
  use, intrinsic :: iso_c_binding
  implicit none

  integer(c_int), allocatable :: empty_arr(:)
  integer(c_int), allocatable :: nonempty_arr(:)
  integer(c_int), pointer :: ext_arr(:)
  type(c_ptr) :: c_mem
  integer :: i

  allocate(empty_arr(0))
  allocate(nonempty_arr(42))

  do i = 1, size(nonempty_arr)
    nonempty_arr(i) = i
  end do

  c_mem = c_malloc(42 * c_sizeof(i))
  call c_f_pointer(c_mem, ext_arr, [42])
  do i = 1, 42
    ext_arr(i) = i
  end do

  deallocate(empty_arr)
  deallocate(nonempty_arr)
  call c_free(c_mem)

end program typed_array_immutability_test
program main
  implicit none
  integer, target :: src(1) = [42]
  integer, pointer :: arr(:) => null_
  integer(kind=1), pointer :: ta(:) => null_
  arr => src
  integer, target :: empty(0)
  arr => empty
  ta => src
end program main
