program main
  implicit none
  type :: foo_t
  contains
    procedure, nopass :: bar
  end type foo_t

  type(foo_t) :: x

  call x%bar()

contains

  subroutine bar()
  end subroutine bar

end program main
