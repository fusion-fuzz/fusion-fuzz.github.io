import Lean

set_option warn.classDefReducibility false

class MyMod :=
(a : Nat)

namespace MyMod
variable [MyMod]
def b := a + 1
end MyMod

def myMod1 : MyMod := ⟨0⟩

#guard myMod1.a == 0
#guard myMod1.b == 1

open Lean

set_option pp.letVarTypes true in
example (p : ∀ a, a) :
    (let y := Prop; let x : y := True; MyMod.b x) = MyMod.b True := by
  run_tac
    let env ← Lean.getEnv
    let lctx ← getLCtx
    let_expr Eq _ lhs _ := (← Elab.Tactic.getMainTarget) | unreachable!
    logInfo lhs
    let ty ← ofExceptKernelException <| Lean.Kernel.check env lctx lhs
    logInfo ty
    let sort ← ofExceptKernelException <| Lean.Kernel.check env lctx ty
    logInfo sort
  trivial
