type t(l)
  integer, len :: l
  character(l) :: c
end type
type(t(4)) :: a
print *, transfer(1., a)
end
