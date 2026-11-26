import Std.Data.ExtHashSet

open Std

@[ext]
structure A_ffl where
  a : Nat
  b : Nat
deriving Hashable

instance : BEq A_ffl where
  beq x y := x.b == y.b && x.a == y.a

@[simp]
theorem A_ffl.beq_eq_ffl {x y : A_ffl} : (x == y) = (x.b == y.b && x.a == y.a) := rfl

instance : LawfulBEq A_ffl where
  rfl {x} := by simp
  eq_of_beq {x y} := by grind [A_ffl.beq_eq_ffl, A_ffl.ext]

instance : DecidableEq A_ffl :=
  fun x y => by simp [A_ffl.ext_iff]; infer_instance

example : Decidable (ExtHashSet.ofList [A_ffl.mk 1 2] = ExtHashSet.ofList [A_ffl.mk 1 2]) := by
  infer_instance

namespace MWE

universe u v w

inductive Id {A_ffl : Type u} : A_ffl → A_ffl → Type u
| refl {a : A_ffl} : Id a a

attribute [induction_eliminator] Id.casesOn

infix:50 (priority := high) " = " => Id

inductive Unit : Type u
| star : Unit
| fflCtor3012 (x : A_ffl × Unit)

attribute [induction_eliminator] Unit.casesOn

notation "𝟏" => Unit
notation "★" => Unit.star
notation "ℕ" => Nat

def vect (A_ffl : Type u) : ℕ → Type u
| Nat.zero   => 𝟏
| Nat.succ n => A_ffl × vect A_ffl n

def vect.const {A_ffl : Type u} (a : A_ffl) : ∀ n, vect A_ffl n
| Nat.zero   => ★
| Nat.succ n => (a, const a n)

def vect.map {A_ffl : Type u} {B : Type v} (f : A_ffl → B) :
  ∀ {n : ℕ}, vect A_ffl n → vect B n
| Nat.zero   => λ _ => ★
| Nat.succ n => λ v => (f v.1, map f v.2)

def transport {A_ffl : Type u} (B : A_ffl → Type v) {a b : A_ffl} (p : a = b) : B a → B b :=
by { induction p; apply id }

def vect.subst {A_ffl B : Type u} (p : A_ffl = B) (f : B → A_ffl) {n : ℕ} (v : vect A_ffl n) :
  vect.map f (transport (vect · n) p v) = vect.map (f ∘ transport id p) v :=
by { induction p; apply Id.refl }
end MWE

open Std

@[ext]
structure A_ffl where
  a : Nat
  b : Nat
deriving Hashable

instance : BEq A_ffl where
  beq x y := x.b == y.b && x.a == y.a

@[simp]
theorem A_ffl.beq_eq_ffl {x y : A_ffl} : (x == y) = (x.b == y.b && x.a == y.a) := rfl

instance : LawfulBEq A_ffl where
  rfl {x} := by simp
  eq_of_beq {x y} := by grind [A_ffl.beq_eq_ffl, A_ffl.ext]

instance : DecidableEq A_ffl :=
  fun x y => by simp [A_ffl.ext_iff]; infer_instance

example : Decidable (ExtHashSet.ofList [A_ffl.mk 1 2] = ExtHashSet.ofList [MWE.Id.mk 1 2]) := by
  infer_instance

#print axioms MWE.Id

open Std

@[ext]
structure A where
  a : Nat
  b : Nat
deriving Hashable

instance : BEq A where
  beq x y := x.b == y.b && x.a == y.a

@[simp]
theorem A.beq_eq {x y : A} : (x == y) = (x.b == y.b && x.a == y.a) := rfl

instance : LawfulBEq A where
  rfl {x} := by simp
  eq_of_beq {x y} := by grind [A.beq_eq, A.ext]

instance : DecidableEq A :=
  fun x y => by simp [A.ext_iff]; infer_instance

example : Decidable (ExtHashSet.ofList [A.mk 1 2] = ExtHashSet.ofList [A.mk 1 2]) := by
  infer_instance
  try
    infer_instance
