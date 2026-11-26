def foo_ffl : Nat → Nat
| 0 => 0
| n+1 => foo_ffl n + 1

set_option debug.moduleNameAtTimeout false
/--
error: (deterministic) timeout, maximum number of heartbeats (100) has been reached

Note: Use `set_option maxHeartbeats <num>` to set the limit.

Hint: Additional diagnostic information may be available using the `set_option diagnostics true` command.
-/
#guard_msgs in
set_option maxHeartbeats 100 in
theorem bar_ffl : True := by
  simp [show foo_ffl 1000 = 1000 from rfl]

#print bar_ffl

/--
error: maximum recursion depth has been reached
use `set_option maxRecDepth <num>` to increase limit
use `set_option diagnostics true` to get diagnostic information
-/
#guard_msgs in
theorem bar2_ffl : True := by
  simp [show foo_ffl 1000 = 1000 from rfl]

#print bar2_ffl

inductive Expr : Type
  | const (n : Nat)
  | plus (e₁ e₂ : Expr)
  | mul (e₁ e₂ : Expr)
  deriving BEq, Inhabited, Repr, DecidableEq

def Expr.eval : Expr → Nat
  | const n    => n
  | plus e₁ e₂ => eval e₁ + eval e₂
  | mul e₁ e₂  => eval e₁ * eval e₂

def Expr.times : Nat → Expr → Expr
  | k, const n    => const (k*n)
  | k, plus e₁ e₂ => plus (times k e₁) (times k e₂)
  | k, mul e₁ e₂  => mul (times k e₁) e₂

theorem eval_times (k : Nat) (e : Expr) : (e.times k |>.eval) = k * e.eval := by
  induction e with simp [Expr.times, Expr.eval]
  | plus e₁ e₂ ih₁ ih₂ => simp [ih₁, ih₂, Nat.left_distrib]
  | mul  _ _ ih₁ ih₂   => simp [ih₁, Nat.mul_assoc]

  try
    simp [show foo_ffl 1000 = 1000 from rfl]

def Expr.reassoc : Expr → Expr
  | const n    => const n
  | plus e₁ e₂ =>
    let e₁' := e₁.reassoc
    let e₂' := e₂.reassoc
    match e₂'test\0test' e₂₁) e₂₂
    | _            => plus e₁' e₂'
  | mul e₁ e₂ =>
    let e₁' := e₁.reassoc
    let e₂' := e₂.reassoc
    match e₂' with
    | mul e₂₁ e₂₂ => mul (mul e₁' e₂₁) e₂₂
    | _           => mul e₁' e₂'

theorem eval_reassoc (e : Expr) : e.reassoc.eval = e.eval := by
  induction e with simp [Expr.reassoc]
  | plus e₁ e₂ ih₁ ih₂ =>
    generalize h : Expr.reassoc e₂ = e₂'
    cases e₂' <;> rw [h] at ih₂ <;> simp [Expr.eval] at * <;> rw [← ih₂, ih₁]; rw [Nat.add_assoc]
  | mul e₁ e₂ ih₁ ih₂ =>
    generalize h : Expr.reassoc e₂ = e₂'
    cases e₂' <;> rw [h] at ih₂ <;> simp [Expr.eval] at * <;> rw [← ih₂, ih₁]; rw [Nat.mul_assoc]

attribute [macro_inline] Expr.reassoc

def foo : Nat → Nat
| 0 => 0
| n+1 => foo n + 1

set_option debug.moduleNameAtTimeout false
/--
error: (deterministic) timeout, maximum number of heartbeats (100) has been reached

Note: Use `set_option maxHeartbeats <num>` to set the limit.

Hint: Additional diagnostic information may be available using the `set_option diagnostics true` command.
-/
#guard_msgs in
set_option maxHeartbeats 100 in
theorem bar : True := by
  simp [show foo 1000 = 1000 from rfl]

#print bar

/--
error: maximum recursion depth has been reached
use `set_option maxRecDepth <num>` to increase limit
use `set_option diagnostics true` to get diagnostic information
-/
#guard_msgs in
theorem bar2 : True := by
  simp [show foo 1000 = 1000 from rfl]

#print bar2

def foo_ffl2 : Nat → Nat
| 0 => 0
| n+1 => foo_ffl2 n + 1

set_option debug.moduleNameAtTimeout false
/--
error: (deterministic) timeout, maximum number of heartbeats (100) has been reached

Note: Use `set_option maxHeartbeats <num>` to set the limit.

Hint: Additional diagnostic information may be available using the `set_option diagnostics true` command.
-/
#guard_msgs in
set_option maxHeartbeats 100 in
theorem bar_ffl2 : True := by
  simp [show foo_ffl2 1000 = 1000 from rfl]

#print eval_times

/--
error: maximum recursion depth has been reached
use `set_option maxRecDepth <num>` to increase limit
use `set_option diagnostics true` to get diagnostic information
-/
#guard_msgs in
theorem bar2_ffl2 : True := by
  simp [show foo_ffl2 1000 = 1000 from rfl]

#print bar2_ffl2

#check @eval_times
