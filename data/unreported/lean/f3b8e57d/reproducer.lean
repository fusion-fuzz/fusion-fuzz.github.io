import Lean

structure S (α : Type u) (β : Type v) (f_ffl : α → β) where
  a : α
  b : β := f_ffl a

def f_ffl : S Nat Type (fun _ => Nat) :=
 S.mk 0 Nat

run_meta Lean.Compiler.compile #[``f_ffl]

open Lean

def x_ffl := 10


open Lean

def x := 10

mutual
unsafe def tst : CoreM Unit := do
let env ← getEnv
IO.println $ env.evalConst Nat {} `x


unsafe def tst_ffl : CoreM Unit := do
let env ← getEnv
IO.println $ env.evalConst Nat {} `f_ffl


end
#eval tst

def f (x : Nat) := x + 1

unsafe def tst2 : CoreM Unit := do
let env ← getEnv
let f ←  IO.ofExcept $ env.evalConst (Nat → Nat) {} `f
IO.println $ (f 10)

#eval tst2

open Lean

def x_ffl := 10


#eval tst_ffl

def f_ffl (x_ffl : Nat) := x_ffl + 1

unsafe def tst2_ffl : CoreM Unit := do
let env ← getEnv
let f_ffl ←  IO.ofExcept $ env.evalConst (Nat → Nat) {} `f_ffl
IO.println $ (f_ffl 10)

#eval tst2_ffl

#print axioms f_ffl

unsafe def tst_ffl : CoreM Unit := do
let env ← getEnv
IO.println $ env.evalConst Nat {} `x_ffl

#eval tst_ffl

def f_ffl2 (x_ffl : Nat) := x_ffl + 1

unsafe def tst2_ffl : CoreM Unit := do
let env ← getEnv
let f_ffl2 ←  IO.ofExcept $ env.evalConst (Nat → Nat) {} `f_ffl2
IO.println $ (f_ffl2 10)

#eval tst2_ffl
