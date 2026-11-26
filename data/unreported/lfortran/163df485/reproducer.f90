program main
  implicit none
  type :: t
    integer :: x
  end type t
  type(t), allocatable :: a(:)
  integer :: i

  type :: message
     character(len=:), allocatable :: header(:)
  end type message
  type(message) :: m
  character(len=0), allocatable :: tmp(:)

  allocate(a(1))
  a(1)%x = 1
  i = a(1)%x
  allocate(character(len=0) :: m%header(0))
  allocate(character(len=0) :: tmp(1))
  m%header = tmp
end program main
