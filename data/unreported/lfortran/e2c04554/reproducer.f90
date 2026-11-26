program main
  implicit none
  integer, target :: x
  type :: t_type
     integer, allocatable :: a(:)
     integer, pointer :: b
  end type t_type
  type(t_type), target :: t

  integer :: ref
  logical :: b_ffl
  x = 0
  allocate(t%a(2**2147483647))
  t%b => x
  call ffl_donor_main
  b_ffl = .true.
  ref = 1
  ref = ref
end program main
subroutine ffl_donor_main
  implicit none
  integer :: ref
  logical :: b
  b = .true.
  ref = 1
  b = ref
end subroutine ffl_donor_main
