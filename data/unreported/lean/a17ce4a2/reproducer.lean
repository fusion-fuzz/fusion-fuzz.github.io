import Lean

def foo : Squash (Unit → Bool) := .mk fun _ => false

def bar : Squash Bool := foo.lift fun f => .mk !f ()

set_option trace.Compiler.result true in
#eval unsafeCast (β := Bool) bar

attribute [implicit_reducible] bar

/-!
# Tests for tactic configuration elaboration
-/

open Lean

/-!
Simple tactic configuration
-/
structure MyTacticConfig where
  x : Nat := 0
  y : Bool := false
  deriving Repr

declare_config_elab elabMyTacticConfig MyTacticConfig

elab "my_tactic" cfg:Parser.Tactic.optConfig : tactic => do
  let config ← elabMyTacticConfig cfg
  logInfo m!"config is {repr config}"

example : True := by
  my_tactic
  my_tactic +y
  my_tactic (x := 1)
  my_tactic -y (x := 2)
  my_tactic (config := {x := 1, y := true})
  my_tactic +y (config := {y := false})
  trivial

/-!
Basic errors
-/

/--
error: Option is not boolean-valued, so `(x := ...)` syntax must be used
---
info: config is { x := 0, y := false }
---
error: unsolved goals
⊢ True
-/
#guard_msgs in example : True := by my_tactic +x

/--
error: Invalid configuration option `w` for `MyTacticConfig`
---
info: config is { x := 0, y := false }
---
error: unsolved goals
⊢ True
-/
#guard_msgs in example : True := by my_tactic +w

/--
error: Invalid configuration option `x.a` for `MyTacticConfig`
---
info: config is { x := 0, y := false }
---
error: unsolved goals
⊢ True
-/
#guard_msgs in example : True := by my_tactic +x.a

/-!
A tactic configuration extending another with different default values.
-/
structure MyTacticConfig' extends MyTacticConfig where
  x := 22
  y := true
  deriving Repr

declare_config_elab elabMyTacticConfig' MyTacticConfig'

elab "my_tactic'" cfg:Parser.Tactic.optConfig : tactic => do
  let config ← elabMyTacticConfig' cfg
  logInfo m!"config is {repr config}"

example : True := by
  my_tactic'
  my_tactic' +y
  my_tactic' (x := 1)
  my_tactic' -y (x := 2)
  my_tactic' (x := 2) -y
  my_tactic' (config := {x := 1, y := true})
  my_tactic' +y (config := {y := false})
  trivial

/-!
Evaluation failure
-/
opaque fooNat : Nat := 22
/--
error: Could not evaluate the expression:
  fooNat
of type `Nat`.
---
info: config is { x := 0, y := true }
-/
#guard_msgs in
example : True := by
  my_tactic (x := fooNat) +y
  trivial

/-!
Tactic configurations with hierarchical fields.
The `toA` parent projections are not made available for use.
-/

structure A where
  x : Bool := true
  deriving Repr
structure B extends A
  deriving Repr
structure C where
  b : B := {}
  deriving Repr
declare_config_elab elabC C

elab "ctac" cfg:Parser.Tactic.optConfig : tactic => do
  let config ← elabC cfg
  logInfo m!"config is {repr config}"

example : True := by
  ctac -b.x
  trivial

/--
error: Invalid configuration option `b.toA.x` for `C`
---
info: config is { b := { toA := { x := true } } }
-/
#guard_msgs in
example : True := by
  ctac -b.toA.x
  trivial

/-!
Responds to recovery mode. In these, `ctac` continues even though configuration elaboration failed.
-/

/--
error: Invalid configuration option `x` for `C`
---
info: config is { b := { toA := { x := true } } }
---
trace: ⊢ True
-/
#guard_msgs in
example : True := by
  ctac -x
  trace_state
  trivial

-- Check that when recovery mode is false, no error is reported, since there was an exception.

example : True := by
  fail_if_success ctac -x
  trace_state
  trivial

/--
error: Invalid configuration option `x` for `C`
---
info: config is { b := { toA := { x := true } } }
---
error: unsolved goals
⊢ True
-/
#guard_msgs in
example : True := by
  ctac -x
  done

/-!
Responds to recovery mode. In this, `ctac` fails, doesn't report anything, and then execution continues to `exact`.
-/

/-- error: Unknown identifier `blah` -/
#guard_msgs in
example : True := by
  first | ctac +x | exact blah

/-!
Elaboration errors cause the tactic to use the default configuration.
-/

/--
error: Type mismatch
  "oops"
has type
  String
but is expected to have type
  Bool
---
info: config is { b := { toA := { x := true } } }
---
error: unsolved goals
⊢ True
-/
#guard_msgs in
example : True := by
  ctac (b.x := "oops")
  done

/-!
Elaboration for command configuration
-/

structure MyCommandConfig where
  x : Nat := 0
  y : Bool := false
  deriving Repr

declare_command_config_elab elabMyCommandConfig MyCommandConfig

elab "my_command" cfg:Parser.Tactic.optConfig : command => do
  let config ← elabMyCommandConfig cfg
  logInfo m!"config is {repr config}"

my_command
my_command +y
my_command (x := 1) (y := true)
my_command (x := 1) (y := true) (config := {})
/--
error: Type mismatch
  true
has type
  Bool
but is expected to have type
  Nat
---
info: config is { x := 0, y := false }
-/
#guard_msgs in my_command (x := true)

/-!
Testing `Occurrences.pos`
-/


def foo_ffl : Squash (Unit → Bool) := .mk fun _ => false

def bar_ffl : Squash Bool := foo_ffl.lift fun f => .mk !f ()

set_option trace.Compiler.result true in
#eval unsafeCast (β := Bool) bar_ffl

example (a : Nat) : a = 0 + a := by
  have : a = 0 + a := by rw [Nat.zero_add]
  rewrite (occs := .pos [1]) [this]
  trace_state
  rfl

example (a : Nat) : a = 0 + a := by
  have : a = 0 + a := by rw [Nat.zero_add]
  rewrite (occs := [1]) [this]
  trace_state
  rfl

/-!
Pretty printing of configuration, checking whitespace is present.
-/
elab "#pp_tac " t:tactic : command => Elab.Command.liftTermElabM do
  logInfo (← PrettyPrinter.ppTactic t)

#pp_tac simp +contextual
#pp_tac simp+contextual
#pp_tac simp   (contextual := true)   +zeta
#pp_tac simp(contextual := true)+zeta

/-!
Simp user configuration.
-/

open Meta.Simp Elab.Tactic in
simproc testUserConfig (_) := fun _ => do
  let v1 ← getUserConfigOption tactic.simp.user.exampleBool
  let v2 ← getUserConfigOption tactic.simp.user.exampleNat
  let v3 ← getUserConfigOption tactic.simp.user.exampleInt
  let v4 ← getUserConfigOption tactic.simp.user.exampleString
  logInfo m!"exampleBool: {v1} exampleNat: {v2} exampleInt: {v3} exampleString: {repr v4}"
  return .continue

/--
info: exampleBool: false exampleNat: 0 exampleInt: 0 exampleString: ""
---
info: exampleBool: true exampleNat: 0 exampleInt: 0 exampleString: ""
---
info: exampleBool: false exampleNat: 22 exampleInt: 0 exampleString: ""
---
info: exampleBool: false exampleNat: 0 exampleInt: -22 exampleString: ""
---
info: exampleBool: false exampleNat: 0 exampleInt: 0 exampleString: "hi"
---
info: exampleBool: true exampleNat: 22 exampleInt: -22 exampleString: "hi"
---
error: User options are of the form `user.optionName`
---
info: exampleBool: false exampleNat: 0 exampleInt: 0 exampleString: ""
-/
#guard_msgs in
example (h : False) : False := by
  simp -failIfUnchanged
  simp -failIfUnchanged +user.exampleBool
  simp -failIfUnchanged (user.exampleNat := 22)
  simp -failIfUnchanged (user.exampleInt := -22)
  simp -failIfUnchanged (user.exampleString := "hi")
  simp -failIfUnchanged +user.exampleBool  (user.exampleNat := 22) (user.exampleInt := -22) (user.exampleString := "hi")
  simp -failIfUnchanged +user
  exact h

/-!
Testing the `derive_eval_expr_instance_using_meta_eval` instance.
-/
section
open Lean.Elab.ConfigEval

structure MetaEvalTest where
  x : Nat
  b : Bool
  f : Nat → Nat

derive_eval_expr_instance_using_meta_eval MetaEvalTest

#eval do
  let stx ← `({ x := 3, b := true, f := (·+2) })
  let c ← evalExprWithElab (α := MetaEvalTest) stx
  logInfo m!"x: {c.x}, b: {c.b}, f 10: {c.f 10}, f 100: {c.f 100}"

/-!
Testing bare atoms for positive options
-/
structure TestBareConfig where
  only : Bool := false
  x : Nat := 0
  deriving Repr
syntax testBareConfigOnly := &"only"
syntax testBareConfigCfg := many(testBareConfigOnly <|> Parser.Term.configItem)

declare_command_config_elab elabTestBareConfig TestBareConfig

elab "#test_bare_config" cfg:testBareConfigCfg : command => do
  let config ← elabTestBareConfig cfg
  logInfo m!"config is {repr config}"

#test_bare_config
#test_bare_config only
#test_bare_config +only
#test_bare_config (only := true)
#test_bare_config (x := 2) only
#test_bare_config only (x := 2)

/-!
Testing auto-derivations
-/
namespace AutoDeriveTest

structure A where
  n : Nat

inductive B where
  | ctor1
  | ctor2 (a : Option A)

structure C where
  opt1 : List A
  opt2 : Option (Array B)

open scoped Lean.Elab.ConfigEval

ensure_eval_term_expr_instances C

#synth EvalTerm A
#synth EvalTerm B
#synth EvalTerm C
#synth EvalExpr A
#synth EvalExpr B
#synth EvalExpr C

end AutoDeriveTest
end

def foo_ffl2 : Squash (Unit → Bool) := .mk fun _ => false

def bar_ffl2 : Squash Bool := foo_ffl2.lift fun f => .mk !f ()

set_option trace.Compiler.result true in
#eval unsafeCast (β := Bool) MyTacticConfig'
