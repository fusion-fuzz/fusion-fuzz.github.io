module m
  type :: node
    type(node_ptr), pointer :: n
  end type
  type(node) :: v
  type :: node_ptr
    integer, private :: i
  end type
end
