import Std.Data.HashMap
import Lean.Meta.Sym
import Lean.Meta.DiscrTree.Basic

/-!
# Tests for recursive structures
-/

/-!
No parameters, variables, or universes.
-/
structure A1 where
  xs : List A1

#check A1

/-!
Projections
-/
section
variable (a : A1)
#check a.xs
#check a.1
end

/-!
A parameter
-/
structure A2 (n : Nat) where
  x : Fin n
  xs : List (A2 n)

#check A2

/-!
Numeric projections
-/
section
variable (a : A2 2)
#check a.x
#check a.xs
#check a.1
#check a.2
end

/-!
A `variable`
-/
section
variable (n : Nat)

structure A3 where
  x : Fin n
  xs : List A3

#check A3
end

/-!
A variable and parameter with universe metavariables
-/
section
variable (α : Type _)

structure A4 (β : Type _) where
  x : α
  y : β
  xs : List (A4 β)

#check A4
end

/-!
Example from https://github.com/leanprover/lean4/issues/2512
-/
structure Foo where
  name     : String
  children : List Foo

/-!
Defining a recursive function on a recursive structure
-/
structure Foo' where
  name     : String
  n : Nat
  children : Fin n → Foo'

def Foo'.preorder : Foo' → String
  | {name, n, children} => Id.run do
    let mut acc := name
    for h : i in *...n do
      acc := acc ++ (children ⟨i, h⟩).preorder
    return acc

#check Foo'.preorder

/-!
Extending with default values.
-/
structure A5 extends A4 Nat Bool where
  x := 0
  y := true

/-!
Default value whose type depends on the recursive structure.
Reported in https://github.com/leanprover/lean4/issues/6140
-/

structure RecS where
  n : Nat
  recS : Option RecS := none

#check ({ n := 0 } : RecS)

/-!
Incidental new feature: checking projections when the structure is Prop.
-/
/--
error: failed to generate projection `Exists'.x` for the 'Prop'-valued type `Exists'`, field must be a proof, but it has type
  α
-/
#guard_msgs in
structure Exists' {α : Sort _} (p : α → Prop) : Prop where
  x : α
  h : p x

/-!
Testing numeric projections on recursive inductive types now that the elaborator isn't restricted to non-recursive structures.
-/
inductive I1 where
  | mk (x : Nat) (xs : I1)
#check fun (v : I1) => v.1
#check fun (v : I1) => v.2

inductive I2 : Nat → Type where
  | mk (x : Nat) (xs : I2 (x + 1)) : I2 x
#check fun (v : I2 2) => v.1
#check fun (v : I2 2) => v.2

open Lean Meta Sym Grind
set_option sym.debug true
opaque p [Ring α] : α → α → Prop
axiom pax [CommRing α] [NoNatZeroDivisors α] (x y : α) : p x y → p (y + 1) x
opaque a : Int
opaque b : Int
def ex₁ := p (a + 1) b

def test₁ : SymM Unit := do
  let pEx ← mkPatternFromDecl ``pax
  let e ← shareCommon (← getConstInfo ``ex₁).value!
  let some r₁ ← pEx.match? e | throwError "failed"
  let h := mkAppN (mkConst ``pax r₁.us) r₁.args
  check h
  logInfo h
  logInfo r₁.args

#eval SymM.run test₁

theorem mk_forall_and (P Q : α → Prop) : (∀ x, P x) → (∀ x, Q x) → (∀ x, Foo'.preorder x ∧ Q x) := by
  grind

opaque q : Nat → Nat → Prop
opaque f : Nat → Nat

def ex₂ := ∀ x, q x 0 ∧ q (f (f x)) (f x + f (f 1))

def test₂ : SymM Unit := do
  /- We use `some 5` because we want the pattern to be `(∀ x, ?P x ∧ ?Q x)`-/
  let p ← mkPatternFromDecl ``mk_forall_and (some 5)
  let e ← shareCommon (← getConstInfo ``ex₂).value!
  logInfo p.pattern
  logInfo e
  let some r₁ ← p.unify? e | throwError "failed"
  let h := mkAppN (mkConst ``mk_forall_and r₁.us) r₁.args
  check h
  logInfo h
  logInfo (← Sym.inferType r₁.args[3]!)
  logInfo (← Sym.inferType r₁.args[4]!)

#eval SymM.run test₂

theorem forall_and_eq (P Q : α → Prop) : (∀ x, P x ∧ Q x) = ((∀ x, P x) ∧ (∀ x, Q x)):= by
  grind

def logPatternKey (p : Pattern) : MetaM Unit := do
  let k := p.mkDiscrTreeKeys
  logInfo m!"{k.toList.map (·.format)}"

def logPatternKeyFor (declName : Name) : MetaM Unit := do
  let (p, _) ← mkEqPatternFromDecl declName
  logPatternKey p

#eval SymM.run do
  logPatternKeyFor ``Nat.zero_add
  logPatternKeyFor ``Grind.Semiring.zero_mul
  logPatternKeyFor ``forall_and_eq
  logPatternKeyFor ``Array.eraseIdx_append
  logPatternKeyFor ``List.map_map
  logPatternKeyFor ``Std.HashMap.insertMany_append
  logPatternKeyFor ``Std.HashMap.getElem_insert
