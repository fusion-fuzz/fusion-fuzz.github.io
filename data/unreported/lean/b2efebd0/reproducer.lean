import Lean

--

def f : List Int → Bool := fun _ => true

def ex3 : IO Bool := do
let xs ← pure [1, 2, 3];
pure $ f xs -- Works

inductive Expr
| val : Nat → Expr
| app : Expr → Expr → Expr

instance : Coe Nat Expr := ⟨Expr.val⟩
instance : OfNat Expr n where
  ofNat := Expr.val n

def foo : Expr → Expr := fun e => e

def ex1 : Bool :=
f [1, 2, 3]  -- Works

def ex2 : Bool :=
let xs := [1, 2, 3];
f xs -- Works

def ex4 :=
[1, 2, 3].map $ fun x => x+1

def ex5 (xs : List String) :=
xs.foldl (fun r x => r.push x) Array.empty


open Lean

def x := 10

unsafe def tst : CoreM Unit := do
let env ← getEnv
IO.println $ env.evalConst Nat {} `x

#eval tst


set_option pp.all true in

#check foo 1

def ex6 :=
foo 1

def f_ffl (x : Nat) := x + 1

unsafe def tst2 : CoreM Unit := do
let env ← getEnv
let f_ffl ←  IO.ofExcept $ env.evalConst (Nat → Nat) {} `f_ffl
IO.println $ (f_ffl 10)

#eval tst2

open Lean

def x_ffl := 10

unsafe def tst_ffl : CoreM Unit := do
let env ← getEnv
IO.println $ env.evalConst Nat {} `f_ffl

#eval tst_ffl

def f_ffl2 (x_ffl : Nat) := x_ffl + 1

unsafe def tst2_ffl : CoreM Unit := do
let env ← getEnv
let f_ffl2 ←  IO.ofExcept $ env.evalConst (Nat → Nat) {} `f_ffl2
IO.println $ (f_ffl2 10)

#eval tst2_ffl

#check @f_ffl
