type t
  real, pointer :: p
end type
type(t) :: a(1)
a(2)%p => null()
end
