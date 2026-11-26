import Lean.Meta.Tactic
import Lean.Meta.Sym

def f (x : Nat) :=
  let y := x + 1
  2*y

open Lean Meta Sym

run_meta SymM.run do
  withLocalDeclD `x Nat.mkType fun x => do
  let m ← mkFreshExprMVar <| mkNatLE x (mkApp (mkConst ``f) x)
  let mvarId := m.mvarId!
  let mvarId ← unfoldTarget mvarId ``f
  let mvarId ← mvarId.liftLets
  logInfo mvarId
  let .goal _ mvarId ← intros mvarId #[`y] | failure
  logInfo mvarId
  return ()


unsafe initialize no : Nat ← pure (unsafeCast (0 : Nat))

unsafe initialize no : Nat ← pure (unsafeCast (0 : Nat))
