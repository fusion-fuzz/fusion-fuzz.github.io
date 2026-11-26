module
import Lean

open Prod

theorem swap_swap : ∀ x : α × β, swap (swap x) = x
  | ⟨_, _⟩ => by grind

theorem fst_swap {p : α × β} : (swap p).1 = p.2 := by grind

theorem snd_swap {p : α × β} : (swap p).2 = p.1 := by grind

open Lean

set_option pp.letVarTypes true in
example (p : ∀ a, a) :
    (let y := Prop; let x : y := True; swap_swap x) = swap_swap True := by
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
