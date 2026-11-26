subroutine s
  integer, allocatable :: a
  character(5) :: c = "hello"
  allocate(a, source=c)
end subroutine
