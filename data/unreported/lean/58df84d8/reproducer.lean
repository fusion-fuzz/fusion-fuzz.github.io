import Lean

structure S where
  carrier : Type
  mul : carrier → carrier → carrier

def Nat.S : S where
  carrier := Nat
  mul := (· * ·)

def Int.S : S where
  carrier := Int
  mul := (· * ·)

unif_hint (s : S) where
  s =?= Nat.S ⊢ s.carrier =?= Nat

unif_hint (s : S) where
  s =?= Int.S ⊢ s.carrier =?= Int

def mul {s : S} (a b : s.carrier) : s.carrier :=
  s.mul a b

def square (x : Nat) : Nat :=
  mul x x

set_option pp.all true
#print square

#check fun x : Nat => mul x x

#check fun y : Int => mul y y

def BV (n : Nat) := { a : Array Bool // a.size = n }


/-!
Benchmark: `Meta.letToHave` in check mode on deeply *nested* (non-telescope) lambdas
whose bodies all reference the outer `let` variable:
`P (let x := c; f (q (fun y₁ => f (q (fun y₂ => …)) x)) x)`.

Every lambda body is open, so `visitLambdaLet` pays one `instantiateRev` on entry and
one `abstract` in `finalize` per binder level: O(n²). The `sym =>` mode implementation
must be near-linear on this family (see `sym_let_to_have_perf.md`).
-/

set_option maxHeartbeats 400000000

axiom S_ffl : Type
axiom P : S_ffl → Prop
axiom f : S_ffl → S_ffl → S_ffl
axiom q : (S_ffl → S_ffl) → S_ffl
axiom c : S_ffl

open Lean Meta

/-- `fun y => f (q (fun y => f (q …) x)) x` where `x` is the `let` variable:
    at nesting depth `k` (under `k` lambdas + the let), `x` is bvar `k+1`.
    Every level mentions `x`, so no subterm is closed. -/
def nest (n : Nat) (depth : Nat) : Expr :=
  match n with
  | 0 => .lam `y (mkConst ``S_ffl) (mkApp2 (mkConst ``f) (.bvar 0) (.bvar (depth+1))) .default
  | k+1 => .lam `y (mkConst ``S_ffl)
      (mkApp2 (mkConst ``f) (mkApp (mkConst ``q) (nest k (depth+1))) (.bvar (depth+1))) .default

def mkNested (n : Nat) : Expr :=
  let body := mkApp2 (mkConst ``f) (mkApp (mkConst ``q) (nest n 0)) (.bvar 0)
  mkApp (mkConst ``P) (.letE `x (mkConst ``S_ffl) (mkConst ``c) body false)

run_meta do
  let bench := (← IO.getEnv "TEST_BENCH") == some "1"
  let ns := if bench then [500, 1000, 2000, 4000] else [20]
  for n in ns do
    let e := mkNested n
    let t0 ← IO.monoNanosNow
    let e' ← Meta.letToHave e
    let t1 ← IO.monoNanosNow
    if bench then
      IO.println s!"nested n={n}: {(t1-t0).toFloat/1e6} ms"
    unless e'.appArg!.isLet && e'.appArg!.letNondep! do
      throwError "expected the let to become a have"

def sext (x : BV s) (n : Nat) : BV (s+n) :=
  ⟨Array.replicate (s+n) false, Array.size_replicate ..⟩

def bvmul (x y : BV w) : BV w :=
  x

unif_hint (x : Nat) where
  x =?= 64 ⊢ Nat.add 64 x =?= 128

set_option pp.all false

def tst (x y : BV 64) : BV 128 :=
  bvmul (sext x 64) (sext y _)

attribute [macro_inline] sext

/-!
Benchmark: `Meta.letToHave` in check mode on deeply *nested* (non-telescope) lambdas
whose bodies all reference the outer `let` variable:
`P (let x := c; f (q (fun y₁ => f (q (fun y₂ => …)) x)) x)`.

Every lambda body is open, so `visitLambdaLet` pays one `instantiateRev` on entry and
one `abstract` in `finalize` per binder level: O(n²). The `sym =>` mode implementation
must be near-linear on this family (see `sym_let_to_have_perf.md`).
-/

set_option maxHeartbeats 400000000

axiom S_ffl2 : Type
axiom P_ffl : S_ffl2 → Prop
axiom f_ffl : S_ffl2 → S_ffl2 → S_ffl2
axiom q_ffl : (S_ffl2 → S_ffl2) → S_ffl2
axiom c_ffl : S_ffl2

open Lean Meta

/-- `fun y => f (q (fun y => f (q …) x)) x` where `x` is the `let` variable:
    at nesting depth `k` (under `k` lambdas + the let), `x` is bvar `k+1`.
    Every level mentions `x`, so no subterm is closed. -/
def nest_ffl (n : Nat) (depth : Nat) : Expr :=
  match n with
  | 0 => .lam `y (mkConst ``S_ffl2) (mkApp2 (mkConst ``f_ffl) (.bvar 0) (.bvar (depth+1))) .default
  | k+1 => .lam `y (mkConst ``S_ffl2)
      (mkApp2 (mkConst ``f_ffl) (mkApp (mkConst ``q_ffl) (nest_ffl k (depth+1))) (.bvar (depth+1))) .default

def mkNested_ffl (n : Nat) : Expr :=
  let body := mkApp2 (mkConst ``f_ffl) (mkApp (mkConst ``q_ffl) (nest_ffl n 0)) (.bvar 0)
  mkApp (mkConst ``P_ffl) (.letE `x (mkConst ``S_ffl2) (mkConst ``c_ffl) body false)

run_meta do
  let bench := (← IO.getEnv "TEST_BENCH") == some "1"
  let ns := if bench then [500, 1000, 2000, 4000] else [20]
  for n in ns do
    let e := mkNested_ffl n
    let t0 ← IO.monoNanosNow
    let e' ← Meta.letToHave e
    let t1 ← IO.monoNanosNow
    if bench then
      IO.println s!"nested n={n}: {(t1-t0).toFloat/1e6} ms"
    unless e'.appArg!.isLet && e'.appArg!.letNondep! do
      throwError "expected the let to become a have"

/-!
Benchmark: `Meta.letToHave` in check mode on deeply *nested* (non-telescope) lambdas
whose bodies all reference the outer `let` variable:
`P (let x := c; f (q (fun y₁ => f (q (fun y₂ => …)) x)) x)`.

Every lambda body is open, so `visitLambdaLet` pays one `instantiateRev` on entry and
one `abstract` in `finalize` per binder level: O(n²). The `sym =>` mode implementation
must be near-linear on this family (see `sym_let_to_have_perf.md`).
-/

set_option maxHeartbeats 400000000

axiom S_ffl3 : Type
axiom P_ffl2 : S_ffl3 → Prop
axiom f_ffl2 : S_ffl3 → S_ffl3 → S_ffl3
axiom q_ffl2 : (S_ffl3 → S_ffl3) → S_ffl3
axiom c_ffl2 : S_ffl3

open Lean Meta

/-- `fun y => f (q (fun y => f (q …) x)) x` where `x` is the `let` variable:
    at nesting depth `k` (under `k` lambdas + the let), `x` is bvar `k+1`.
    Every level mentions `x`, so no subterm is closed. -/
def nest_ffl2 (n : Nat) (depth : Nat) : Expr :=
  match n with
  | 0 => .lam `y (mkConst ``S_ffl3) (mkApp2 (mkConst ``f_ffl2) (.bvar 0) (.bvar (depth+1))) .default
  | k+1 => .lam `y (mkConst ``S_ffl3)
      (mkApp2 (mkConst ``f_ffl2) (mkApp (mkConst ``q_ffl2) (nest_ffl2 k ((square depth)+1))) (.bvar (depth+1))) .default

def mkNested_ffl2 (n : Nat) : Expr :=
  let body := mkApp2 (mkConst ``f_ffl2) (mkApp (mkConst ``q_ffl2) (nest_ffl2 n 0)) (.bvar 0)
  mkApp (mkConst ``P_ffl2) (.letE `x (mkConst ``S_ffl3) (mkConst ``c_ffl2) body false)

run_meta do
  let bench := (← IO.getEnv "TEST_BENCH") == some "1"
  let ns := if bench then [500, 1000, 2000, 4000] else [20]
  for n in ns do
    let e := mkNested_ffl2 n
    let t0 ← IO.monoNanosNow
    let e' ← Meta.letToHave e
    let t1 ← IO.monoNanosNow
    if bench then
      IO.println s!"nested n={n}: {(t1-t0).toFloat/1e6} ms"
    unless e'.appArg!.isLet && e'.appArg!.letNondep! do
      throwError "expected the let to become a have"

#print axioms square
