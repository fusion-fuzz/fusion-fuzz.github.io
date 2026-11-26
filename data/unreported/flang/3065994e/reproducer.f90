type t2
  type(t1), pointer :: p
end type
type t0
  type(t1) c
end type
type, extends(t0) :: t1
end type
end
