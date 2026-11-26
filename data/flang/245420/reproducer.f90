module a
  type foo
  end type
end
module b
  use a
  interface foo
  end interface
contains
  type(foo) function f()
  end
end
module a
  type foo
  end type
  type(foo) :: x
end
subroutine s
  use a
  use b
end
