program main
  implicit none
  integer, allocatable :: a(:)
  allocate(a(0))
  call sub(a)
contains
  subroutine sub(x)
    integer, intent(in) :: x(:)
    ! ERROR: Default component initializations of equivalenced objects affect 'undeclared' more than once, distinctly
    equivalence (A, B, x, O1, O2, Undeclared)
    call p(x)
    call s()
    print *, x(1)
  end subroutine
end program
