module m
  implicit none
  class(*), allocatable :: x
end module

program TEST_ffl
  use m
  implicit none

  allocate(character(len=7) :: x)
  x = 'default'

  deallocate(x)
  allocate(integer :: x)
  x = 42

  select type (x)
  type is (character)
    print *, 'Character: ', x
  type is (integer)
    print *, 'Integer: ', x
  class default
    print *, 'Other type'
  end select
end program
program test
  use, intrinsic :: iso_fortran_env, only: int16
  implicit none
  integer(int16) :: x, bar
  x = 13579
  bar = ior(ishft(x, -8), ishft(x, 8))
  print *, bar
end program test
