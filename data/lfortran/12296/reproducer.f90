module m
  type t
   contains
    procedure :: tbp => f
  end type
 contains
  function f(this)
    class(t), pointer, intent(in) :: this
  end
end
  use m
  type(t), target :: xt
end
