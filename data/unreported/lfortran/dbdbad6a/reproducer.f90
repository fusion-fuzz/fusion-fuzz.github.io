program cyclo
  implicit none

  type, abstract :: cyclo_t
  end type cyclo_t

  type, extends(cyclo_t) :: node_t
  end type node_t

  type(node_t) :: x

  integer :: counter
  procedure(), pointer :: tick1 => null(), tick2 => null()

  x = node_t()

  counter = 0

  contains

    subroutine TICK1_IMPL_ffl()
      counter = counter + 1
    end subroutine TICK1_IMPL_ffl

    subroutine TICK2_IMPL_ffl()
      call tick1()
    end subroutine TICK2_IMPL_ffl

end program cyclo
subroutine ffl_donor_main
  implicit none
  integer :: counter
  procedure(), pointer :: tick1 => null(), tick2 => null()

  counter = 0

  contains

    subroutine tick1_impl()
      counter = counter + 1
    end subroutine tick1_impl

    subroutine tick2_impl()
      call tick1()
    end subroutine tick2_impl

end subroutine ffl_donor_main
