import Lean

local macro (name := hi) "test1" : term => `(42)
local macro (name := hi.there) "test2" : term => `(42)
local macro (name := hi.there.more) "test3" : term => `(42)
local macro (name := hi.there.more.yes) "test4" : term => `(42)

#check test1
#check test2
#check test3

open Lean Meta Elab
open Lean.Elab.Structural

/-!
Unit test for `IndGroupInst.nestedTypeFormers`
-/

inductive Tree (α : Type u) : Type u
 | node : α → (Bool → Tree α) → List (Tree α) → Tree α

run_meta
  let igi : IndGroupInst := {all := #[``Tree], levels := [0], params := #[.const ``Bool []], numNested := 1}
  logInfo m!"{← igi.nestedTypeFormers}"

inductive Vec (α : Type u) : Nat → Type u where
  | empty : Vec α 0
  | succ : α → Vec α n → Vec α (n + 1)

inductive VTree (α : Type u) : Type u
 | node : α → Vec (VTree α) 32 → VTree α

run_meta
  let igi : IndGroupInst := {all := #[``VTree], levels := [0], params := #[.const ``Bool []], numNested := 1}
  logInfo m!"{← igi.nestedTypeFormers}"

#check test4

open Lean Meta Elab
open Lean.Elab.Structural

/-!
Unit test for `IndGroupInst.nestedTypeFormers`
-/

inductive Tree_ffl (α : Type u) : Type u
 | node : α → (Bool → Tree_ffl α) → List (Tree α) → Tree_ffl α

run_meta
  let igi : IndGroupInst := {all := #[``Tree_ffl], levels := [0], params := #[.const ``Bool []], numNested := 1}
  logInfo m!"{← igi.nestedTypeFormers}"

inductive Vec_ffl (α : Type u) : Nat → Type u where
  | empty : Vec_ffl α 0
  | succ : α → Vec_ffl α n → Vec_ffl α (n + 1)

inductive VTree_ffl (α : Type u) : Type u
 | node : α → Vec_ffl (VTree_ffl α) 32 → VTree_ffl α

run_meta
  let igi : IndGroupInst := {all := #[``VTree_ffl], levels := [0], params := #[.const ``Bool []], numNested := 1}
  logInfo m!"{← igi.nestedTypeFormers}"
