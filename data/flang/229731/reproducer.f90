type t
  type(undefined) :: c
end type
print *, transfer(0, t())
end
