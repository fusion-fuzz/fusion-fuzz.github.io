module

-- ffl: expect-fail


def foo 

-- ffl: expect-fail



mutual
def f (a : α) := a


def foo_ffl 
end
example (a b : α) (x y : β) : a ≍ x → x = y → y ≍ b → f a = f b := by
  grind

example (a b : α) (x y : β) : x = y → a ≍ x → y ≍ b → f a = f b := by
  grind
