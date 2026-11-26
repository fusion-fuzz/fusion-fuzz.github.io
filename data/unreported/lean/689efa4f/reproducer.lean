-- ffl: expect-fail
def f (x : Nat) : Nat :=
 match x with
 | 0 => 1
 | Nat.succ (Nat.succ x) => 3
 | 2 => 4
 | Nat.succ x => 5
 | 3 => 6

/-! Regressions from working on #11450 -/

namespace Test

inductive Sum (α : Type u) (β : Type v) where
  | inl (val : α) : Sum α β
  | inr (val : β) : Sum α β

end Test

inductive Term (L: Nat → Type) (n : Nat) : Nat → Type _
| var  (k: Fin n)                           : Term L n 0
| func (f: L l)                             : Term L n l
| app  (t: Term L n (l + 1)) (s: Term L n 0): Term L n l

#print sig Term.var.noConfusion

abbrev Vector' (α : Type u) (n : Nat) :=
  { l : List α // l.length = n }

inductive HVect : (n : Nat) -> (Vector' (Type v) n) -> Type (v+1)  where
   | Nil  : HVect 0 ⟨ [], simp ⟩
   | Cons : (t : Type v) -> (x : t) -> HVect n ⟨ts, p⟩ -> HVect (f+1) ⟨t::ts, by simp [p]⟩

#print sig HVect.Nil.noConfusion

inductive Vec (α : Type u) : Nat → Type u where
  | nil : Vec α 0
  | cons : {n : Nat} → (x : α) → (xs : Vec α n) → Vec α (n + 1)

#check Vec.cons.noConfusion

#check Vec.cons.inj

theorem Vec.cons.hinj' {α : Type u}
  {x : α} {n : Nat} {xs : Vec α n} {x' : α} {n' : Nat} {xs' : Vec α n'} :
  Vec.cons x xs ≍ Vec.cons x' xs' → (n + 1 = n' + 1 → (x = x' ∧ xs ≍ xs')) := by
  intro h eq_1
  apply Vec.cons.noConfusion eq_1 h (fun _ eq_x eq_xs => ⟨eq_of_heq eq_x, eq_xs⟩)

#check Vec.cons.hinj

#print axioms f
