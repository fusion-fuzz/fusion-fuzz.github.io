module m
  implicit none

  type :: t
  contains
    procedure, pass :: m
  end type t

  abstract interface
    subroutine f_iface(obj)
      import :: t
      class(t), intent(inout) :: obj
    end subroutine f_iface
  end interface

contains

  subroutine m(this, f)
    class(t), intent(inout) :: this
    procedure(f_iface), pointer :: f
  end subroutine m

end module m

program test
  use m
  implicit none

  type(t) :: obj
  procedure(f_iface), pointer :: fp

  fp => obj%m

end program test
program mime_test
  implicit none
  character(len=:), allocatable :: filepath
  integer :: unit, ios, pos
  character(len=256) :: buffer

  filepath = "67647.mov"

  inquire(file=filepath, exist=ios)
  if (ios /= 0) stop

  open(newunit=unit, file=filepath, access='stream', form='unformatted', &
       status='old', action='read', iostat=ios)
  if (ios /= 0) stop

  read(unit, iostat=ios) buffer
  if (ios /= 0) stop

  close(unit)
end program mime_test
