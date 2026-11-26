module m
interface assignment(=)
  elemental pure subroutine logical_to_numeric(i, l)
    integer, intent(out) :: i
    logical, intent(in) :: l
  end subroutine
end interface
contains
subroutine s(i, l)
  integer :: i(:)
  logical :: l(:)
  i = l
end subroutine
end module
