module
import Lean

inductive BoundShape where
  | «open» : BoundShape
  | closed : BoundShape
  | unbounded : BoundShape

structure RangeShape where
  lower : BoundShape
  upper : BoundShape

abbrev Bound (shape : BoundShape) (α : Type u) : Type u :=
  match shape with
  | .open | .closed => α
  | .unbounded => PUnit

structure PRange {shape : RangeShape} (α : Type u) where
  lower : Bound shape.lower α
  upper : Bound shape.upper α

structure T where
  upper_bound : Nat

def T.range (a : T) := PRange.mk (shape := ⟨.closed, .open⟩) 0 a.upper_bound

theorem range_lower (a : T) : a.range.lower = 0 := by rfl

set_option pp.explicit true in
#check range_lower

set_option warn.sorry false

theorem test (p : T) (n: Nat) : n ≤ p.range.upper := by
  fail_if_success grind only [range_lower]
  sorry


open Lean Meta Sym.Simp

cbv_simproc_decl myDeclProc (Nat.succ _) := fun _ => do
  return .rfl

cbv_simproc myPostProc (Nat.add _ _) := fun _ => do
  return .rfl

cbv_simproc ↓ myPreProc (Nat.mul _ _) := fun _ => do
  return .rfl

cbv_simproc cbv_eval myEvalProc (Nat.sub _ _) := fun _ => do
  return .rfl

cbv_simproc ↑ myExplicitPostProc (Nat.mod _ _) := fun _ => do
  return .rfl

cbv_simproc_decl myLateProc (Nat.div _ _) := fun _ => do
  return .rfl

attribute [cbv_simproc cbv_eval] myLateProc

opaque myFun : Nat → Nat

-- Pre simproc sees unreduced arguments
section
local cbv_simproc ↓ preTest (myFun _) := fun e => do
  let .app _f arg := e | return .rfl
  logInfo m!"pre saw: {arg}"
  return .rfl

example : myFun (1 + 2) = myFun 3 := by cbv
end

-- Eval simproc sees reduced arguments (fires before handleApp)
section
local cbv_simproc cbv_eval evalTest (myFun _) := fun e => do
  let .app _f arg := e | return .rfl
  logInfo m!"eval saw: {arg}"
  return .rfl

/--
info: eval saw: 3
---
info: eval saw: 3
---
info: eval saw: 4
---
error: unsolved goals
⊢ myFun 3 = myFun 4
-/
#guard_msgs in
example : myFun (1 + 2) = myFun 4 := by cbv
end

-- Post simproc sees reduced arguments (fires after handleApp)
section
local cbv_simproc ↑ postTest (myFun _) := fun e => do
  let .app _f arg := e | return .rfl
  logInfo m!"post saw: {arg}"
  return .rfl

/--
info: post saw: 3
---
info: post saw: 3
---
info: post saw: 4
---
error: unsolved goals
⊢ myFun 3 = myFun 4
-/
#guard_msgs in
example : myFun (1 + 2) = myFun 4 := by cbv
end

section
cbv_simproc ↓ stringToList (String.toList _) := fun e => do
  let_expr String.toList s := e | return .rfl
  let some str := getStringValue? s | return .rfl
  let result ← Sym.share <| toExpr str.toList
  let typeExpr := mkApp (mkConst ``List [Lean.Level.zero]) (mkConst ``Char)
  return .step result (mkApp2 (mkConst ``Eq.refl [1]) typeExpr result) (done := true)

theorem simprocTest : "a".toList = ['a'] := by cbv

#print simprocTest
end

-- Erase attribute test
cbv_simproc_decl erasableProc (Nat.gcd _ _) := fun _ => return .rfl (done := true)

theorem erasableProcTest : Nat.gcd 1 2 = 1 := by cbv


example (p : T) (n: Nat) : n ≥ p.range.lower := by
  set_option trace.Meta.debug true in
  grind only [range_lower]

#print erasableProcTest

/-- error: `erasableProc` does not have a [cbv_simproc] attribute -/
#guard_msgs in
attribute [-cbvSimprocAttr] erasableProc

attribute [cbv_simproc] erasableProc
attribute [-cbvSimprocAttr] erasableProc

-- Pattern with @
section
local cbv_simproc ↓ testAt (@Nat.succ _) := fun e => do
  let_expr Nat.succ arg := e | return .rfl
  logInfo m!"@ saw: {arg}"
  return .rfl

example : Nat.succ (1 + 2) = 4 := by cbv
end

-- Pattern with explicit type args via @
section
local cbv_simproc ↓ testExplicitList (@List.cons Nat _ _) := fun _ => do
  logInfo m!"explicit list cons"
  return .rfl

example : ([1, 2, 3] : List Nat) = [1, 2, 3] := by cbv
end

-- Implicit args are auto-filled: `List.cons _ _` works the same as `@List.cons Nat _ _`
section
local cbv_simproc ↓ testImplicitList (List.cons _ _) := fun _ => do
  logInfo m!"implicit list cons"
  return .rfl

example : ([1, 2, 3] : List Nat) = [1, 2, 3] := by cbv
end

-- Typeclass-heavy pattern
section
local cbv_simproc ↓ testHAdd (HAdd.hAdd _ _) := fun _ => do
  logInfo m!"HAdd matched"
  return .rfl

example : (1 : Nat) + 2 = 3 := by cbv
end

-- Nested pattern
section
local cbv_simproc ↓ testNested (Nat.succ (Nat.succ _)) := fun _ => do
  logInfo m!"nested succ"
  return .rfl

example : Nat.succ (Nat.succ 0) = 2 := by cbv
end

-- Explicit type args on Prod.mk
section
local cbv_simproc ↓ testProd (@Prod.mk Nat Nat _ _) := fun _ => do
  logInfo m!"prod matched"
  return .rfl

example : (1 + 2, 3) = (3, 3) := by cbv
end

-- Scoped simproc: active when namespace is open, inactive when closed
namespace ScopedTest
scoped cbv_simproc ↓ scopedProc (myFun _) := fun e => do
  let .app _f arg := e | return .rfl
  logInfo m!"scoped saw: {arg}"
  return .rfl

example : myFun 0 = myFun 0 := by cbv
end ScopedTest

-- Outside the namespace, the simproc should not fire
example : myFun 0 = myFun 0 := by cbv

-- Re-opening the namespace reactivates the simproc
open ScopedTest in

example : myFun 0 = myFun 0 := by cbv

-- Over-applied pattern: simproc registered for `myBinFun _` fires on `myBinFun x y`
opaque myBinFun : Nat → Nat → Nat

section
local cbv_simproc ↓ overAppliedProc (myBinFun _) := fun e => do
  logInfo m!"over-applied saw: {e}"
  return .rfl

example : myBinFun (1 + 2) 4 = myBinFun 3 4 := by cbv
end

-- Multiple simprocs matching the same head: first non-rfl result wins
section
local cbv_simproc ↓ multiFirst (myFun _) := fun _ => do
  logInfo m!"first fired"
  return .rfl (done := true)

local cbv_simproc ↓ multiSecond (myFun _) := fun _ => do
  logInfo m!"second fired"
  return .rfl

example : myFun 0 = myFun 0 := by cbv
end

-- Multiple simprocs: first returns .rfl (skip), second succeeds with .step
section
@[irreducible] def myConst : Nat := 42

local cbv_simproc ↓ skipFirst (myConst) := fun _e => do
  logInfo m!"first skipped"
  return .rfl

local cbv_simproc ↓ succeedSecond (myConst) := fun _e => do
  logInfo m!"second succeeded"
  let result := toExpr (42 : Nat)
  return .step result (mkConst ``myConst.eq_def) (done := true)

example : myConst = 42 := by cbv
end

attribute [specialize] T.range

open Lean Meta Sym.Simp

cbv_simproc_decl myDeclProc (Nat.succ _) := fun _ => do
  return .rfl

cbv_simproc myPostProc (Nat.add _ _) := fun _ => do
  return .rfl

cbv_simproc ↓ myPreProc (Nat.mul _ _) := fun _ => do
  return .rfl

cbv_simproc cbv_eval myEvalProc (Nat.sub _ _) := fun _ => do
  return .rfl

cbv_simproc ↑ myExplicitPostProc (Nat.mod _ _) := fun _ => do
  return .rfl

cbv_simproc_decl myLateProc (Nat.div _ _) := fun _ => do
  return .rfl

attribute [cbv_simproc cbv_eval] myLateProc

opaque myFun_ffl : Nat → Nat

-- Pre simproc sees unreduced arguments
section
local cbv_simproc ↓ preTest (myFun_ffl _) := fun e => do
  let .app _f arg := e | return .rfl
  logInfo m!"pre saw: {arg}"
  return .rfl

example : myFun_ffl (1 + 2) = myFun_ffl 3 := by cbv
end

-- Eval simproc sees reduced arguments (fires before handleApp)
section
local cbv_simproc cbv_eval evalTest (myFun_ffl _) := fun e => do
  let .app _f arg := e | return .rfl
  logInfo m!"eval saw: {arg}"
  return .rfl

/--
info: eval saw: 3
---
info: eval saw: 3
---
info: eval saw: 4
---
error: unsolved goals
⊢ myFun 3 = myFun 4
-/
#guard_msgs in
example : myFun_ffl (1 + 2) = myFun_ffl 4 := by cbv
end

-- Post simproc sees reduced arguments (fires after handleApp)
section
local cbv_simproc ↑ postTest (myFun_ffl _) := fun e => do
  let .app _f arg := e | return .rfl
  logInfo m!"post saw: {arg}"
  return .rfl

/--
info: post saw: 3
---
info: post saw: 3
---
info: post saw: 4
---
error: unsolved goals
⊢ myFun 3 = myFun 4
-/
#guard_msgs in
example : myFun_ffl (1 + 2) = myFun_ffl 4 := by cbv
end

section
cbv_simproc ↓ stringToList (String.toList _) := fun e => do
  let_expr String.toList s := e | return .rfl
  let some str := getStringValue? s | return .rfl
  let result ← Sym.share <| toExpr str.toList
  let typeExpr := mkApp (mkConst ``List [Lean.Level.zero]) (mkConst ``Char)
  return .step result (mkApp2 (mkConst ``Eq.refl [1]) typeExpr result) (done := true)

theorem simprocTest_ffl : "a".toList = ['a'] := by cbv

#print simprocTest_ffl
end

-- Erase attribute test
cbv_simproc_decl erasableProc (Nat.gcd _ _) := fun _ => return .rfl (done := true)

theorem erasableProcTest_ffl : Nat.gcd 1 2 = 1 := by cbv

#print erasableProcTest_ffl

/-- error: `erasableProc` does not have a [cbv_simproc] attribute -/
#guard_msgs in
attribute [-cbvSimprocAttr] erasableProc

attribute [cbv_simproc] erasableProc
attribute [-cbvSimprocAttr] erasableProc

-- Pattern with @
section
local cbv_simproc ↓ testAt (@Nat.succ _) := fun e => do
  let_expr Nat.succ arg := e | return .rfl
  logInfo m!"@ saw: {arg}"
  return .rfl

example : Nat.succ (1 + 2) = 4 := by cbv
end

-- Pattern with explicit type args via @
section
local cbv_simproc ↓ testExplicitList (@List.cons Nat _ _) := fun _ => do
  logInfo m!"explicit list cons"
  return .rfl

example : ([1, 2, 3] : List Nat) = [1, 2, 3] := by cbv
end

-- Implicit args are auto-filled: `List.cons _ _` works the same as `@List.cons Nat _ _`
section
local cbv_simproc ↓ testImplicitList (List.cons _ _) := fun _ => do
  logInfo m!"implicit list cons"
  return .rfl

example : ([1, 2, 3] : List Nat) = [1, 2, 3] := by cbv
end

-- Typeclass-heavy pattern
section
local cbv_simproc ↓ testHAdd (HAdd.hAdd _ _) := fun _ => do
  logInfo m!"HAdd matched"
  return .rfl

example : (1 : Nat) + 2 = 3 := by cbv
end

-- Nested pattern
section
local cbv_simproc ↓ testNested (Nat.succ (Nat.succ _)) := fun _ => do
  logInfo m!"nested succ"
  return .rfl

example : Nat.succ (Nat.succ 0) = 2 := by cbv
end

-- Explicit type args on Prod.mk
section
local cbv_simproc ↓ testProd (@Prod.mk Nat Nat _ _) := fun _ => do
  logInfo m!"prod matched"
  return .rfl

example : (1 + 2, 3) = (3, 3) := by cbv
end

-- Scoped simproc: active when namespace is open, inactive when closed
namespace ScopedTest
scoped cbv_simproc ↓ scopedProc (myFun_ffl _) := fun e => do
  let .app _f arg := e | return .rfl
  logInfo m!"scoped saw: {arg}"
  return .rfl

example : myFun_ffl 0 = myFun_ffl 0 := by cbv
end ScopedTest

-- Outside the namespace, the simproc should not fire
example : myFun_ffl 0 = myFun_ffl 0 := by cbv

-- Re-opening the namespace reactivates the simproc
open ScopedTest in

example : myFun_ffl 0 = myFun_ffl 0 := by cbv

-- Over-applied pattern: simproc registered for `myBinFun _` fires on `myBinFun x y`
opaque myBinFun_ffl : Nat → Nat → Nat

section
local cbv_simproc ↓ overAppliedProc (myBinFun_ffl _) := fun e => do
  logInfo m!"over-applied saw: {e}"
  return .rfl

example : myBinFun_ffl (1 + 2) 4 = myBinFun_ffl 3 4 := by cbv
end

-- Multiple simprocs matching the same head: first non-rfl result wins
section
local cbv_simproc ↓ multiFirst (myFun_ffl _) := fun _ => do
  logInfo m!"first fired"
  return .rfl (done := true)

local cbv_simproc ↓ multiSecond (myFun_ffl _) := fun _ => do
  logInfo m!"second fired"
  return .rfl

example : myFun_ffl 0 = myFun_ffl 0 := by cbv
end

-- Multiple simprocs: first returns .rfl (skip), second succeeds with .step
section
@[irreducible] def myConst_ffl : Nat := 42

local cbv_simproc ↓ skipFirst (myConst_ffl) := fun _e => do
  logInfo m!"first skipped"
  return .rfl

local cbv_simproc ↓ succeedSecond (myConst_ffl) := fun _e => do
  logInfo m!"second succeeded"
  let result := toExpr (42 : Nat)
  return .step result (mkConst ``myConst_ffl.eq_def) (done := true)

example : myConst_ffl = 42 := by cbv
end

open Lean Meta Sym.Simp

cbv_simproc_decl myDeclProc (Nat.succ _) := fun _ => do
  return .rfl

cbv_simproc myPostProc (Nat.add _ _) := fun _ => do
  return .rfl

cbv_simproc ↓ myPreProc (Nat.mul _ _) := fun _ => do
  return .rfl

cbv_simproc cbv_eval myEvalProc (Nat.sub _ _) := fun _ => do
  return .rfl

cbv_simproc ↑ myExplicitPostProc (Nat.mod _ _) := fun _ => do
  return .rfl

cbv_simproc_decl myLateProc (Nat.div _ _) := fun _ => do
  return .rfl

attribute [cbv_simproc cbv_eval] myLateProc

opaque myFun_ffl2 : Nat → Nat

-- Pre simproc sees unreduced arguments
section
local cbv_simproc ↓ preTest (myFun_ffl2 _) := fun e => do
  let .app _f arg := e | return .rfl
  logInfo m!"pre saw: {arg}"
  return .rfl

example : myFun_ffl2 (1 + 2) = myFun_ffl2 3 := by cbv
end

-- Eval simproc sees reduced arguments (fires before handleApp)
section
local cbv_simproc cbv_eval evalTest (myFun_ffl2 _) := fun e => do
  let .app _f arg := e | return .rfl
  logInfo m!"eval saw: {arg}"
  return .rfl

/--
info: eval saw: 3
---
info: eval saw: 3
---
info: eval saw: 4
---
error: unsolved goals
⊢ myFun 3 = myFun 4
-/
#guard_msgs in
example : myFun_ffl2 (1 + 2) = myFun_ffl2 4 := by cbv
end

-- Post simproc sees reduced arguments (fires after handleApp)
section
local cbv_simproc ↑ postTest (myFun_ffl2 _) := fun e => do
  let .app _f arg := e | return .rfl
  logInfo m!"post saw: {arg}"
  return .rfl

/--
info: post saw: 3
---
info: post saw: 3
---
info: post saw: 4
---
error: unsolved goals
⊢ myFun 3 = myFun 4
-/
#guard_msgs in
example : myFun_ffl2 (1 + 2) = myFun_ffl2 4 := by cbv
end

section
cbv_simproc ↓ stringToList (String.toList _) := fun e => do
  let_expr String.toList s := e | return .rfl
  let some str := getStringValue? s | return .rfl
  let result ← Sym.share <| toExpr str.toList
  let typeExpr := mkApp (mkConst ``List [Lean.Level.zero]) (mkConst ``Char)
  return .step result (mkApp2 (mkConst ``Eq.refl [1]) typeExpr result) (done := true)

theorem simprocTest_ffl2 : "a".toList = ['a'] := by cbv

#print simprocTest_ffl2
end

-- Erase attribute test
cbv_simproc_decl erasableProc (Nat.gcd _ _) := fun _ => return .rfl (done := true)

theorem erasableProcTest_ffl2 : Nat.gcd 1 2 = 1 := by cbv

#print erasableProcTest_ffl2

/-- error: `erasableProc` does not have a [cbv_simproc] attribute -/
#guard_msgs in
attribute [-cbvSimprocAttr] erasableProc

attribute [cbv_simproc] erasableProc
attribute [-cbvSimprocAttr] erasableProc

-- Pattern with @
section
local cbv_simproc ↓ testAt (@Nat.succ _) := fun e => do
  let_expr Nat.succ arg := e | return .rfl
  logInfo m!"@ saw: {arg}"
  return .rfl

example : Nat.succ (1 + 2) = 4 := by cbv
end

-- Pattern with explicit type args via @
section
local cbv_simproc ↓ testExplicitList (@List.cons Nat _ _) := fun _ => do
  logInfo m!"explicit list cons"
  return .rfl

example : ([1, 2, 3] : List Nat) = [1, 2, 3] := by cbv
end

-- Implicit args are auto-filled: `List.cons _ _` works the same as `@List.cons Nat _ _`
section
local cbv_simproc ↓ testImplicitList (List.cons _ _) := fun _ => do
  logInfo m!"implicit list cons"
  return .rfl

example : ([1, 2, 3] : List Nat) = [1, 2, 3] := by cbv
end

-- Typeclass-heavy pattern
section
local cbv_simproc ↓ testHAdd (HAdd.hAdd _ _) := fun _ => do
  logInfo m!"HAdd matched"
  return .rfl

example : (1 : Nat) + 2 = 3 := by cbv
end

-- Nested pattern
section
local cbv_simproc ↓ testNested (Nat.succ (Nat.succ _)) := fun _ => do
  logInfo m!"nested succ"
  return .rfl

example : Nat.succ (Nat.succ 0) = 2 := by cbv
end

-- Explicit type args on Prod.mk
section
local cbv_simproc ↓ testProd (@Prod.mk Nat Nat _ _) := fun _ => do
  logInfo m!"prod matched"
  return .rfl

example : (1 + 2, 3) = (3, 3) := by cbv
end

-- Scoped simproc: active when namespace is open, inactive when closed
namespace ScopedTest
scoped cbv_simproc ↓ scopedProc (myFun_ffl2 _) := fun e => do
  let .app _f arg := e | return .rfl
  logInfo m!"scoped saw: {arg}"
  return .rfl

example : myFun_ffl2 0 = myFun_ffl2 0 := by cbv
end ScopedTest

-- Outside the namespace, the simproc should not fire
example : myFun_ffl2 0 = myFun_ffl2 0 := by cbv

-- Re-opening the namespace reactivates the simproc
open ScopedTest in

example : myFun_ffl2 0 = myFun_ffl2 0 := by cbv

-- Over-applied pattern: simproc registered for `myBinFun _` fires on `myBinFun x y`
opaque myBinFun_ffl2 : Nat → Nat → Nat

section
local cbv_simproc ↓ overAppliedProc (myBinFun_ffl2 _) := fun e => do
  logInfo m!"over-applied saw: {e}"
  return .rfl

example : myBinFun_ffl2 (1 + 2) 4 = myBinFun 3 4 := by cbv
end

-- Multiple simprocs matching the same head: first non-rfl result wins
section
local cbv_simproc ↓ multiFirst (myFun_ffl2 _) := fun _ => do
  logInfo m!"first fired"
  return .rfl (done := true)

local cbv_simproc ↓ multiSecond (myFun_ffl2 _) := fun _ => do
  logInfo m!"second fired"
  return .rfl

example : myFun_ffl2 0 = myFun_ffl2 0 := by cbv
end

-- Multiple simprocs: first returns .rfl (skip), second succeeds with .step
section
@[irreducible] def myConst_ffl2 : Nat := 42

local cbv_simproc ↓ skipFirst (myConst_ffl2) := fun _e => do
  logInfo m!"first skipped"
  return .rfl

local cbv_simproc ↓ succeedSecond (myConst_ffl2) := fun _e => do
  logInfo m!"second succeeded"
  let result := toExpr (42 : Nat)
  return .step result (mkConst ``myConst_ffl2.eq_def) (done := true)

example : myConst_ffl2 = 42 := by cbv
end
