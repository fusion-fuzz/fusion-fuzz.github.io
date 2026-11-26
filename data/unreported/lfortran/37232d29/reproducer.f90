program main
  implicit none

  type :: p_iface
  contains
    procedure, nopass :: do_something_in_protocol
    procedure, nopass :: do_something_classy_in_protocol
    procedure, nopass :: do_nothing_in_protocol
    procedure, nopass :: do_nothing_classy_in_protocol
  end type p_iface

  type :: i_iface
  contains
    procedure, nopass :: do_something
    procedure, nopass :: do_something_classy
  end type i_iface

  type :: bar
  contains
    procedure, nopass :: do_something_int
    procedure, nopass :: do_something_classy_real
    procedure, nopass :: do_something_in_protocol_obj
    procedure, nopass :: do_something_classy_in_protocol_obj
  end type bar

  type(p_iface) :: p
  type(i_iface) :: i
  type(bar) :: b
  real :: r
  integer :: n

  integer :: x
  r = 1.0
  n = 1

  call p%do_something_in_protocol(r)
  call p%do_something_classy_in_protocol(r)
  call p%do_nothing_in_protocol(r)
  call p%do_nothing_classy_in_protocol(r)

  call i%do_something(r)
  call i%do_something_classy(n)

  call b%do_something_int(n)
  call b%do_something_classy_real(r)
  call b%x(n)
  call b%do_something_classy_in_protocol_obj(n)
  x = 1
  select case (x)
  case (2)
     write(*,'(A)',advance='no') 'foo'
  case (3)
     write(*,'(A)',advance='no') 'bar'
  case default
     write(*,'(I0)',advance='no') 1
  end select
end program main

subroutine do_something_in_protocol(x)
  real, intent(in) :: x
end subroutine

subroutine do_something_classy_in_protocol(x)
  real, intent(in) :: x
end subroutine

subroutine do_nothing_in_protocol(x)
  real, intent(in) :: x
end subroutine

subroutine do_nothing_classy_in_protocol(x)
  real, intent(in) :: x
end subroutine

subroutine do_something(x)
  real, intent(in) :: x
end subroutine

subroutine do_something_classy(x)
  integer, intent(in) :: x
end subroutine

subroutine do_something_int(x)
  integer, intent(in) :: x
end subroutine

subroutine do_something_classy_real(x)
  real, intent(in) :: x
end subroutine

subroutine do_something_in_protocol_obj(x)
  class(*), intent(in) :: x
end subroutine

subroutine do_something_classy_in_protocol_obj(x)
  class(*), intent(in) :: x
end subroutine
subroutine ffl_donor_main
  implicit none
  integer :: x
  x = 1
  select case (x)
  case (2)
     write(*,'(A)',advance='no') 'foo'
  case (3)
     write(*,'(A)',advance='no') 'bar'
  case default
     write(*,'(I0)',advance='no') 1
  end select
end subroutine ffl_donor_main
