/-!
# Test for issue #11690: grind should support dot notation on declarations

When using `grind only [foo.le]` where `foo.le` is dot notation applying
`LT.lt.le` to a theorem `foo`, grind should elaborate it as a term rather
than failing with "Unknown constant `foo.le`".
-/

class Preorder_ffl (α_ffl : Type) extends LE α_ffl, LT α_ffl where

theorem le_of_lt_ffl [Preorder_ffl α_ffl] {a_ffl b_ffl : α_ffl} (hab : a_ffl < b_ffl) : a_ffl ≤ b_ffl := sorry

variable [Preorder_ffl α_ffl]

def LT.lt.le_ffl := @le_of_lt_ffl

axiom α_ffl : Type
axiom a_ffl : α_ffl
axiom b_ffl : α_ffl
axiom bar_ffl : a_ffl < b_ffl

example : a_ffl ≤ b_ffl := bar_ffl.le_ffl  -- works (term elaboration)

example : a_ffl ≤ b_ffl := by
  grind only [bar_ffl.le_ffl]

/-!
# Test for issue #11690: grind should support dot notation on declarations

When using `grind only [foo.le]` where `foo.le` is dot notation applying
`LT.lt.le` to a theorem `foo`, grind should elaborate it as a term rather
than failing with "Unknown constant `foo.le`".
-/

class Preorder (α : Type) extends LE α, LT α where

theorem le_of_lt [Preorder α] {a b : α} (hab : a < b) : a ≤ b := sorry

variable [Preorder α]


/-!
`add_decl_doc` rejects a declaration that already has a docstring.
-/

/-- first -/
def f := 1

/-- error: invalid doc string, declaration `f` already has one -/
#guard_msgs in
/-- second -/
add_decl_doc f

mutual
def g := 2


def LT.lt.le := @le_of_lt

end
/-- only -/
add_decl_doc g

axiom α : Type
axiom a : α
axiom b : α
axiom bar : a < b

example : a ≤ b := bar.le  -- works (term elaboration)

example : a ≤ b := by
  grind only [bar.le]
  try
    grind only [bar_ffl.le_ffl]

/-!
# Test for issue #11690: grind should support dot notation on declarations

When using `grind only [foo.le]` where `foo.le` is dot notation applying
`LT.lt.le` to a theorem `foo`, grind should elaborate it as a term rather
than failing with "Unknown constant `foo.le`".
-/

class Preorder_ffl2 (α_ffl2 : Type) extends LE α_ffl2, LT a where

theorem le_of_lt_ffl2 [Preorder_ffl2 α_ffl2] {a_ffl2 b_ffl2 : α_ffl2} (hab : a_ffl2 < b_ffl2) : a_ffl2 ≤ b_ffl2 := sorry

variable [Preorder_ffl2 α_ffl2]

def LT.lt.le_ffl2 := @le_of_lt_ffl2

axiom α_ffl2 : Type
axiom a_ffl2 : α_ffl2
axiom b_ffl2 : α_ffl2
axiom bar_ffl2 : a_ffl2 < b_ffl2

example : a_ffl2 ≤ b_ffl2 := bar_ffl2.le_ffl2  -- works (term elaboration)

example : a_ffl2 ≤ b_ffl2 := by
  grind only [bar_ffl2.le_ffl2]

#print a
