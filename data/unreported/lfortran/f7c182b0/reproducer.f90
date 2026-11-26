program main
  implicit none

  type, abstract :: parent
    class(parent), pointer :: object => null()
  contains
    procedure(recurse_iface), deferred :: recurse
  end type parent

  abstract interface
    subroutine recurse_iface(self, t)
      import :: parent
      class(parent), intent(inout) :: self
      integer, intent(in) :: t
    end subroutine recurse_iface
  end interface

  type, extends(parent) :: child
  contains
    procedure :: recurse => child_recurse
  end type child

  class(parent), allocatable :: p
  integer :: i

  allocate(child :: p)
  p%object => p

  do i = 1, 5
    call p%recurse(0)
  end do

  do
  end do
contains

  recursive subroutine child_recurse(self, t)
    class(child), intent(inout) :: self
    integer, intent(in) :: t
    integer :: i

    if (t /= 10) then
      do i = 1, 5
        call self%object%recurse(t + 1)
      end do
    end if
  end subroutine child_recurse

end program main
