subroutine s(obj)
  type :: t2
    integer :: x
  end type
  type, extends(t2) :: t
    real :: y
  end type
  type(t) :: obj
  !$acc host_data use_device(obj%y)
  !$acc end host_data
end
