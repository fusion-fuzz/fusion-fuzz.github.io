import Lean

-- ffl: expect-fail
class A (α : Type u) where
  a : Unit

class B (α : Type u) where
  a : Unit

instance [s : B (Array α)] : A α  where
  a := ()

instance [s : A (Array α)] : B α where
  a := ()

set_option warn.classDefReducibility false in
def f : B Nat :=
  inferInstance


open Lean in
open Lean.Meta in
def tst_ffl2 (declName : Name) : MetaM Unit := do
  let info ← getConstInfo declName
  trace[Meta.debug] ">> {info.value!.eta}"

def aux1_ffl2 := fun (x : Nat) y z => Nat.add y z
def aux2_ffl2 := fun y z => Nat.add y z
def aux3_ffl2 := (1+.)
def aux4_ffl2 := fun (x : Nat) y z => Nat.add z y
def aux5_ffl2 := fun y => Nat.add y y

set_option trace.Meta.debug true

open Lean in
open Lean.Meta in
def tst (declName : Name) : MetaM Unit := do
  let info ← getConstInfo declName
  trace[Meta.debug] ">> {info.value!.eta}"

def aux1 := fun (x : Nat) y z => Nat.add y z
def aux2 := fun y z => Nat.add y z
def aux3 := (1+.)
def aux4 := fun (x : Nat) y z => Nat.add z y
def aux5 := fun y => Nat.add y y

set_option trace.Meta.debug true
#eval tst `aux1
#eval tst `aux2
#eval tst `aux3
#eval tst `aux4
#eval tst `A

attribute [semireducible] aux4

open Lean in
open Lean.Meta in
def tst_ffl (declName : Name) : MetaM Unit := do
  let info ← getConstInfo declName
  trace[Meta.debug] ">> {info.value!.eta}"

def aux1_ffl := fun (x : Nat) y z => Nat.add y z
def aux2_ffl := fun y z => Nat.add y z
def aux3_ffl := (1+.)
def aux4_ffl := fun (x : Nat) y z => Nat.add z y
def aux5_ffl := fun y => Nat.add y y

set_option trace.Meta.debug true
#eval tst_ffl `aux1_ffl
#eval tst_ffl `aux2_ffl
#eval tst_ffl `aux3_ffl
#eval tst_ffl `aux4_ffl
#eval tst_ffl `aux5_ffl

#eval tst_ffl2 `aux1_ffl2
#eval tst_ffl2 `aux2_ffl2
#eval tst_ffl2 `aux3_ffl2
#eval tst_ffl2 `aux4_ffl2
#eval tst_ffl2 `aux5_ffl2
