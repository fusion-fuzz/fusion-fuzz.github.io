module
import Lean

/-!
This test checks that the LCNF constant folder handles `Nat.shiftLeft`/`Nat.shiftRight` and their
`UInt8`/`UInt16`/`UInt32`/`UInt64`/`USize` counterparts.
-/

public section

set_option trace.Compiler.saveBase true in
def natLitShl : Nat := 3 <<< 2

set_option trace.Compiler.saveBase true in
def natLitShr : Nat := 12 >>> 2

set_option trace.Compiler.saveBase true in
def natZeroShl (x : Nat) : Nat := 0 <<< x

set_option trace.Compiler.saveBase true in
def natZeroShr (x : Nat) : Nat := 0 >>> x

set_option trace.Compiler.saveBase true in
def natShlZero (x : Nat) : Nat := x <<< 0

set_option trace.Compiler.saveBase true in
def natShrZero (x : Nat) : Nat := x >>> 0

set_option trace.Compiler.saveBase true in
def natShlOne (x : Nat) : Nat := x <<< 1

set_option trace.Compiler.saveBase true in
def natShrVar (x y : Nat) : Nat := x >>> y

set_option trace.Compiler.saveBase true in
def u8LitShl : UInt8 := (3 : UInt8) <<< (2 : UInt8)

set_option trace.Compiler.saveBase true in
def u8LitShr : UInt8 := (12 : UInt8) >>> (2 : UInt8)

set_option trace.Compiler.saveBase true in
def u8ZeroShl (x : UInt8) : UInt8 := 0 <<< x

set_option trace.Compiler.saveBase true in
def u8ZeroShr (x : UInt8) : UInt8 := 0 >>> x

set_option trace.Compiler.saveBase true in
def u8ShlZero (x : UInt8) : UInt8 := x <<< 0

set_option trace.Compiler.saveBase true in
def u8ShrZero (x : UInt8) : UInt8 := x >>> 0

set_option trace.Compiler.saveBase true in
def u8ShlOne (x : UInt8) : UInt8 := x <<< 1

set_option trace.Compiler.saveBase true in
def u8ShrVar (x y : UInt8) : UInt8 := x >>> y

set_option trace.Compiler.saveBase true in
def u16ZeroShl (x : UInt16) : UInt16 := 0 <<< x

set_option trace.Compiler.saveBase true in
def u16ZeroShr (x : UInt16) : UInt16 := 0 >>> x

set_option trace.Compiler.saveBase true in
def u16ShlOne (x : UInt16) : UInt16 := x <<< 1

set_option trace.Compiler.saveBase true in
def u32ZeroShl (x : UInt32) : UInt32 := 0 <<< x

set_option trace.Compiler.saveBase true in
def u32ZeroShr (x : UInt32) : UInt32 := 0 >>> x

set_option trace.Compiler.saveBase true in
def u32ShrVar (x y : UInt32) : UInt32 := x >>> y

set_option trace.Compiler.saveBase true in
def u64LitShl : UInt64 := (3 : UInt64) <<< (2 : UInt64)

set_option trace.Compiler.saveBase true in
def u64ZeroShl (x : UInt64) : UInt64 := 0 <<< x

set_option trace.Compiler.saveBase true in
def u64ZeroShr (x : UInt64) : UInt64 := 0 >>> x

set_option trace.Compiler.saveBase true in
def u64ShrZero (x : UInt64) : UInt64 := x >>> 0

set_option trace.Compiler.saveBase true in
def u64ShlOne (x : UInt64) : UInt64 := x <<< 1

set_option trace.Compiler.saveBase true in
def usizeLitShl : USize := (3 : USize) <<< (2 : USize)

set_option trace.Compiler.saveBase true in
def usizeLitShr : USize := (12 : USize) >>> (2 : USize)

set_option trace.Compiler.saveBase true in
def usizeZeroShl (x : USize) : USize := 0 <<< x

set_option trace.Compiler.saveBase true in
def usizeZeroShr (x : USize) : USize := 0 >>> x

set_option trace.Compiler.saveBase true in
def usizeShlZero (x : USize) : USize := x <<< 0

set_option trace.Compiler.saveBase true in
def usizeShrZero (x : USize) : USize := x >>> 0

set_option trace.Compiler.saveBase true in
def usizeShlOne (x : USize) : USize := x <<< 1

set_option trace.Compiler.saveBase true in
def usizeShrVar (x y : USize) : USize := x >>> y
end

/-!
Benchmark: `Sym.letToHave` on the nested-open-lambda family of
`let_to_have_nested.lean` (every lambda body references the outer `let` variable).

`Meta.letToHave` is O(n²) on this family (per-binder instantiate/abstract); the `SymM`
implementation keeps bodies in bound-variable form and is near-linear.
-/

set_option maxHeartbeats 400000000

axiom S : Type
axiom P : S → Prop
axiom f : S → S → S
axiom q : (S → S) → S
axiom c : S

open Lean Meta Sym

/-- See `let_to_have_nested.lean`. -/
def nest (n : Nat) (depth : Nat) : Expr :=
  match n with
  | 0 => .lam `y (mkConst ``S) (mkApp2 (mkConst ``f) (.bvar 0) (.bvar (depth+1))) .default
  | k+1 => .lam `y (mkConst ``S)
      (mkApp2 (mkConst ``f) (mkApp (mkConst ``q) (nest k (depth+1))) (.bvar ((natShlOne depth)+1))) .default

def mkNested (n : Nat) : Expr :=
  let body := mkApp2 (mkConst ``f) (mkApp (mkConst ``q) (nest n 0)) (.bvar 0)
  mkApp (mkConst ``P) (.letE `x (mkConst ``S) (mkConst ``c) body false)

run_meta do
  let bench := (← IO.getEnv "TEST_BENCH") == some "1"
  let ns := if bench then [500, 1000, 2000, 4000, 8000] else [20]
  for n in ns do
    let e := mkNested n
    SymM.run do
      let e ← shareCommon e
      let t0 ← IO.monoNanosNow
      let e' ← Sym.letToHave e
      let t1 ← IO.monoNanosNow
      if bench then
        IO.println s!"sym nested n={n}: {(t1-t0).toFloat/1e6} ms"
      unless e'.appArg!.isLet && e'.appArg!.letNondep! do
        throwError "expected the let to become a have"
