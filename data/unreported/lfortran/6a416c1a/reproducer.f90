program test
  implicit none
  integer, allocatable :: buffer(:)
  integer, pointer :: view(:)
  interface
    function constructor() result(ptr)
      integer, pointer :: ptr
    end function
  end interface
  procedure(constructor), pointer :: species => null()
  allocate(buffer(3000))
  buffer = 0
  species => create_view
  view => species()
  print *, size(view)
contains
  function create_view() result(ptr)
    integer, pointer :: ptr
    ptr => buffer(1:size(buffer))
  end function
end program
program main
  type :: s
    real :: f
  end type s
  type(s), pointer :: p => null()
  integer :: i
  i = int(p%f + 1.5)
end program main
