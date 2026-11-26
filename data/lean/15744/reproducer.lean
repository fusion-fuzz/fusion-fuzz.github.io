import Lean.Elab.Tactic.Try
open Lean Meta Elab Tactic
opaque P : Prop
axiom p : P
variable {α : Type} [Inhabited α]
mutual
def usesVar : α := default
@[try_suggestion]
def sugg (goal : MVarId) (_ : Try.Info) : MetaM (Array (TSyntax `tactic)) := goal.withContext do
  let term ← PrettyPrinter.delab (mkConst ``p)
  return #[← `(tactic| exact $term)]
end
example : P := by try?
