module m
  type :: foo
    contains
    procedure :: bar => foo_bar
  end type foo
contains
  subroutine foo_bar(self, a)
    class(foo), intent(in) :: a
  end subroutine foo_bar
end module m
program test
  use m
  type(foo) :: f
  character(len=*), parameter :: fname = 'bug69441.phar'
  call f%bar(fname)
end program test
