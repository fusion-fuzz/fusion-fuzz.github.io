universe u
variable {α : Type u}

def split : List α → List α × List α
| []       => ([], [])
| [a]      => ([a], [])
| a::b::as => (a :: (split as).1, b :: (split as).2)

theorem ex1 : split [1, 2, 3, 4, 5] = ([1, 3, 5], [2, 4]) :=
rfl


example (x : Fin n) (h : n = 0) : False :=
  nomatch x, h


example (x : Fin n) (h : n = 0) : False :=
  nomatch split, h

example (x : Nat) (f : Nat → Fin n) (h : n = 0 ∧ True) : False :=
  nomatch f x, h.1

#print axioms split

example (x : Nat) (f : Nat → Fin n) (h : n = 0 ∧ True) : False :=
  nomatch f x, h.1
