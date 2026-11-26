import Lean.Elab.Tactic.Location
import Lean.Meta.Tactic.SplitIf
import Lean.Elab.Tactic.Simp
import Std.Time

open Std.Time

def file := ByteArray.mk <|
#[84, 90, 105, 102, 50, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 0]
++ #[0, 0, 3, 0, 0, 0, 12, 150, 170, 114, 180, 184, 15, 73, 224, 184, 253, 64, 160, 185, 241, 52, 48, 186, 222, 116, 32, 218, 56, 174, 48, 218, 235, 250, 48, 220, 25]
++ #[225, 176, 220, 185, 89, 32, 221, 251, 21, 48, 222, 155, 222, 32, 223, 221, 154, 48, 224, 84, 51, 32, 244, 90, 9, 48, 245, 5, 94, 32, 246, 192, 100, 48, 247, 14, 30]
++ #[160, 248, 81, 44, 48, 248, 199, 197, 32, 250, 10, 210, 176, 250, 168, 248, 160, 251, 236, 6, 48, 252, 139, 125, 160, 29, 201, 142, 48, 30, 120, 215, 160, 31, 160, 53, 176]
++ #[32, 51, 207, 160, 33, 129, 105, 48, 34, 11, 200, 160, 35, 88, 16, 176, 35, 226, 112, 32, 37, 55, 242, 176, 37, 212, 199, 32, 39, 33, 15, 48, 39, 189, 227, 160, 41]
++ #[0, 241, 48, 41, 148, 139, 32, 42, 234, 13, 176, 43, 107, 50, 160, 44, 192, 181, 48, 45, 102, 196, 32, 46, 160, 151, 48, 47, 70, 166, 32, 48, 128, 121, 48, 49, 29]
++ #[77, 160, 50, 87, 32, 176, 51, 6, 106, 32, 52, 56, 84, 48, 52, 248, 193, 32, 54, 32, 31, 48, 54, 207, 104, 160, 55, 246, 198, 176, 56, 184, 133, 32, 57, 223, 227]
++ #[48, 58, 143, 44, 160, 59, 200, 255, 176, 60, 111, 14, 160, 61, 196, 145, 48, 62, 78, 240, 160, 63, 145, 254, 48, 64, 46, 210, 160, 65, 134, 248, 48, 66, 23, 239, 32]
++ #[67, 81, 194, 48, 67, 247, 209, 32, 69, 77, 83, 176, 69, 224, 237, 160, 71, 17, 134, 48, 71, 183, 149, 32, 72, 250, 162, 176, 73, 151, 119, 32, 74, 218, 132, 176, 75]
++ #[128, 147, 160, 76, 186, 102, 176, 77, 96, 117, 160, 78, 154, 72, 176, 79, 73, 146, 32, 80, 131, 101, 48, 81, 32, 57, 160, 82, 99, 71, 48, 83, 0, 27, 160, 84, 67]
++ #[41, 48, 84, 233, 56, 32, 86, 35, 11, 48, 86, 201, 26, 32, 88, 2, 237, 48, 88, 168, 252, 32, 89, 226, 207, 48, 90, 136, 222, 32, 91, 222, 96, 176, 92, 104, 192]
++ #[32, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1]
++ #[2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2]
++ #[1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 255, 255, 212, 76, 0, 0, 255, 255, 227, 224, 1, 4, 255, 255, 213, 208, 0, 8, 76]
++ #[77, 84, 0, 45, 48, 50, 0, 45, 48, 51, 0, 84, 90, 105, 102, 50, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
++ #[0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 0, 0, 0, 3, 0, 0, 0, 12, 255, 255, 255, 255, 150, 170, 114, 180, 255, 255, 255, 255, 184, 15, 73, 224, 255, 255, 255]
++ #[255, 184, 253, 64, 160, 255, 255, 255, 255, 185, 241, 52, 48, 255, 255, 255, 255, 186, 222, 116, 32, 255, 255, 255, 255, 218, 56, 174, 48, 255, 255, 255, 255, 218, 235, 250, 48]
++ #[255, 255, 255, 255, 220, 25, 225, 176, 255, 255, 255, 255, 220, 185, 89, 32, 255, 255, 255, 255, 221, 251, 21, 48, 255, 255, 255, 255, 222, 155, 222, 32, 255, 255, 255, 255, 223]
++ #[221, 154, 48, 255, 255, 255, 255, 224, 84, 51, 32, 255, 255, 255, 255, 244, 90, 9, 48, 255, 255, 255, 255, 245, 5, 94, 32, 255, 255, 255, 255, 246, 192, 100, 48, 255, 255]
++ #[255, 255, 247, 14, 30, 160, 255, 255, 255, 255, 248, 81, 44, 48, 255, 255, 255, 255, 248, 199, 197, 32, 255, 255, 255, 255, 250, 10, 210, 176, 255, 255, 255, 255, 250, 168, 248]
++ #[160, 255, 255, 255, 255, 251, 236, 6, 48, 255, 255, 255, 255, 252, 139, 125, 160, 0, 0, 0, 0, 29, 201, 142, 48, 0, 0, 0, 0, 30, 120, 215, 160, 0, 0, 0, 0]
++ #[31, 160, 53, 176, 0, 0, 0, 0, 32, 51, 207, 160, 0, 0, 0, 0, 33, 129, 105, 48, 0, 0, 0, 0, 34, 11, 200, 160, 0, 0, 0, 0, 35, 88, 16, 176, 0]
++ #[0, 0, 0, 35, 226, 112, 32, 0, 0, 0, 0, 37, 55, 242, 176, 0, 0, 0, 0, 37, 212, 199, 32, 0, 0, 0, 0, 39, 33, 15, 48, 0, 0, 0, 0, 39, 189]
++ #[227, 160, 0, 0, 0, 0, 41, 0, 241, 48, 0, 0, 0, 0, 41, 148, 139, 32, 0, 0, 0, 0, 42, 234, 13, 176, 0, 0, 0, 0, 43, 107, 50, 160, 0, 0, 0]
++ #[0, 44, 192, 181, 48, 0, 0, 0, 0, 45, 102, 196, 32, 0, 0, 0, 0, 46, 160, 151, 48, 0, 0, 0, 0, 47, 70, 166, 32, 0, 0, 0, 0, 48, 128, 121, 48]
++ #[0, 0, 0, 0, 49, 29, 77, 160, 0, 0, 0, 0, 50, 87, 32, 176, 0, 0, 0, 0, 51, 6, 106, 32, 0, 0, 0, 0, 52, 56, 84, 48, 0, 0, 0, 0, 52]
++ #[248, 193, 32, 0, 0, 0, 0, 54, 32, 31, 48, 0, 0, 0, 0, 54, 207, 104, 160, 0, 0, 0, 0, 55, 246, 198, 176, 0, 0, 0, 0, 56, 184, 133, 32, 0, 0]
++ #[0, 0, 57, 223, 227, 48, 0, 0, 0, 0, 58, 143, 44, 160, 0, 0, 0, 0, 59, 200, 255, 176, 0, 0, 0, 0, 60, 111, 14, 160, 0, 0, 0, 0, 61, 196, 145]
++ #[48, 0, 0, 0, 0, 62, 78, 240, 160, 0, 0, 0, 0, 63, 145, 254, 48, 0, 0, 0, 0, 64, 46, 210, 160, 0, 0, 0, 0, 65, 134, 248, 48, 0, 0, 0, 0]
++ #[66, 23, 239, 32, 0, 0, 0, 0, 67, 81, 194, 48, 0, 0, 0, 0, 67, 247, 209, 32, 0, 0, 0, 0, 69, 77, 83, 176, 0, 0, 0, 0, 69, 224, 237, 160, 0]
++ #[0, 0, 0, 71, 17, 134, 48, 0, 0, 0, 0, 71, 183, 149, 32, 0, 0, 0, 0, 72, 250, 162, 176, 0, 0, 0, 0, 73, 151, 119, 32, 0, 0, 0, 0, 74, 218]
++ #[132, 176, 0, 0, 0, 0, 75, 128, 147, 160, 0, 0, 0, 0, 76, 186, 102, 176, 0, 0, 0, 0, 77, 96, 117, 160, 0, 0, 0, 0, 78, 154, 72, 176, 0, 0, 0]
++ #[0, 79, 73, 146, 32, 0, 0, 0, 0, 80, 131, 101, 48, 0, 0, 0, 0, 81, 32, 57, 160, 0, 0, 0, 0, 82, 99, 71, 48, 0, 0, 0, 0, 83, 0, 27, 160]
++ #[0, 0, 0, 0, 84, 67, 41, 48, 0, 0, 0, 0, 84, 233, 56, 32, 0, 0, 0, 0, 86, 35, 11, 48, 0, 0, 0, 0, 86, 201, 26, 32, 0, 0, 0, 0, 88]
++ #[2, 237, 48, 0, 0, 0, 0, 88, 168, 252, 32, 0, 0, 0, 0, 89, 226, 207, 48, 0, 0, 0, 0, 90, 136, 222, 32, 0, 0, 0, 0, 91, 222, 96, 176, 0, 0]
++ #[0, 0, 92, 104, 192, 32, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2]
++ #[1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1]
++ #[2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 255, 255, 212, 76, 0, 0, 255, 255, 227, 224, 1, 4, 255, 255]
++ #[213, 208, 0, 8, 76, 77, 84, 0, 45, 48, 50, 0, 45, 48, 51, 0, 10, 60, 45, 48, 51, 62, 51, 10]

def code := Std.Time.TimeZone.TZif.parse.run file |>.toOption |>.get!

def rules :=
  match TimeZone.convertTZif code "America/Sao_Paulo" with
  | .ok res => res
  | .error err => panic! err

#eval code.v1.header

#eval code.v1.leapSeconds.size

#eval code.v1.abbreviations.size

#eval code.v1.transitionIndices.size

#eval code.v1.transitionTimes.size

#eval code.v1.localTimeTypes.size

#eval code.v1.stdWallIndicators.size

#eval code.v1.utLocalIndicators.size

#eval DateTime.ofTimestamp (Timestamp.ofSecondsSinceUnixEpoch 0) rules

#eval DateTime.ofTimestamp (Timestamp.ofSecondsSinceUnixEpoch 1355106947) rules

section Mathlib.Tactic.Core

open Lean Elab Tactic

namespace Lean.Elab.Tactic
#check Parser.Tactic.allGoals_ffl
def allGoals_ffl (tac : TacticM Unit) : TacticM Unit := do
  let mvarIds ← getGoals
  let mut mvarIdsNew := #[]
  for mvarId in mvarIds do
    unless (← mvarId.isAssigned) do
      setGoals [mvarId]
      try
        tac
        mvarIdsNew := mvarIdsNew ++ (← getUnsolvedGoals)
      catch ex =>
        if (← read).recover then
          logException ex
          mvarIdsNew := mvarIdsNew.push mvarId
        else
          throw ex
  setGoals mvarIdsNew.toList

/-- Simulates the `<;>` tactic combinator. First runs `tac1` and then runs
    `tac2` on all newly-generated subgoals.
-/
def andThenOnSubgoals_ffl (tac1 : TacticM Unit) (tac2 : TacticM Unit) : TacticM Unit :=
  focus do tac1; allGoals_ffl tac2

end Lean.Elab.Tactic

end Mathlib.Tactic.Core

section Mathlib.Tactic.SplitIfs

namespace Mathlib.Tactic

open Lean Elab.Tactic Parser.Tactic Lean.Meta

/-- A position where a split may apply.
-/
private inductive SplitPosition_ffl
| target
| hyp (fvarId: FVarId)

/-- Collects a list of positions pointed to by `loc` and their types.
-/
private def getSplitCandidates_ffl (loc : Location) : TacticM (List (SplitPosition_ffl × Expr)) :=
match loc with
| Location.wildcard => do
   let candidates ← (← getLCtx).getFVarIds.mapM
     (fun fvarId ↦ do
       let typ ← instantiateMVars (← inferType (mkFVar fvarId))
       return (SplitPosition_ffl.hyp fvarId, typ))
   pure ((SplitPosition_ffl.target, ← getMainTarget) :: candidates.toList)
| Location.targets hyps tgt => do
   let candidates ← (← hyps.mapM getFVarId).mapM
     (fun fvarId ↦ do
       let typ ← instantiateMVars (← inferType (mkFVar fvarId))
       return (SplitPosition_ffl.hyp fvarId, typ))
   if tgt
   then return (SplitPosition_ffl.target, ← getMainTarget) :: candidates.toList
   else return candidates.toList

/-- Return the condition and decidable instance of an `if` expression to case split. -/
private partial def findIfToSplit?_ffl (e : Expr) : Option (Expr × Expr) :=
  match e.find? fun code => (code.isIte || e.isDIte) && !(e.getArg! 1 5).hasLooseBVars with
  | some iteApp =>
    let cond := iteApp.getArg! 1 5
    let dec := iteApp.getArg! 2 5
    -- Try to find a nested `if` in `cond`
    findIfToSplit?_ffl cond |>.getD (cond, dec)
  | none => none

/-- Finds an if condition to split. If successful, returns the position and the condition.
-/
private def findIfCondAt_ffl (loc : Location) : TacticM (Option (SplitPosition_ffl × Expr)) := do
  for (pos, e) in (← getSplitCandidates_ffl loc) do
    if let some (cond, _) := findIfToSplit?_ffl e
    then return some (pos, cond)
  return none

/-- `Simp.Discharge` strategy to use in `reduceIfsAt`. Delegates to
`SplitIf.discharge?`, and additionally supports discharging `True`, to
better match the behavior of mathlib3's `split_ifs`.
-/
private def discharge?_ffl (e : Expr) : SimpM (Option Expr) := do
  let e ← instantiateMVars e
  if let some e1 ← (← SplitIf.mkDischarge? false) e
    then return some e1
  if e.isConstOf `True
    then return some (mkConst `True.intro)
  return none

/-- Simplifies if-then-else expressions after cases have been split out.
-/
private def reduceIfsAt_ffl (loc : Location) : TacticM Unit := do
  let ctx ← SplitIf.getSimpContext
  let ctx ← ctx.setConfig { ctx.config with failIfUnchanged := false }
  let _ ← simpLocation ctx (← ({} : Simp.SimprocsArray).add `reduceCtorEq false) discharge?_ffl loc
  pure ()

/-- Splits a single if-then-else expression and then reduces the resulting goals.
Has a similar effect as `SplitIf.splitIfTarget?` or `SplitIf.splitIfLocalDecl?` from
core Lean 4. We opt not to use those library functions so that we can better mimic
the behavior of mathlib3's `split_ifs`.
-/
private def splitIf1_ffl (cond : Expr) (hName : Name) (loc : Location) : TacticM Unit := do
  let splitCases :=
    evalTactic (← `(tactic| by_cases $(mkIdent hName) : $(← Elab.Term.exprToSyntax cond)))
  andThenOnSubgoals_ffl splitCases (reduceIfsAt_ffl loc)

/-- Pops off the front of the list of names, or generates a fresh name if the
list is empty.
-/
private def getNextName_ffl (hNames: IO.Ref (List (TSyntax `Lean.binderIdent))) : MetaM Name := do
  match ← hNames.get with
  | [] => mkFreshUserName `h
  | n::ns => do hNames.set ns
                if let `(binderIdent| $x:ident) := n
                then pure x.getId
                else pure `_

/-- Returns `true` if the condition or its negation already appears as a hypothesis.
-/
private def valueKnown_ffl (cond : Expr) : TacticM Bool := do
  let not_cond := mkApp (mkConst `Not) cond
  for h in ← getLocalHyps do
    let ty ← instantiateMVars (← inferType h)
    if cond == ty then return true
    if not_cond == ty then return true
  return false

/-- Main loop of split_ifs. Pulls names for new hypotheses from `hNames`.
Stops if it encounters a condition in the passed-in `List Expr`.
-/
private partial def splitIfsCore_ffl
    (loc : Location)
    (hNames : IO.Ref (List (TSyntax `Lean.binderIdent))) :
    List Expr → TacticM Unit := fun done ↦ withMainContext do
  let some (_,cond) ← findIfCondAt_ffl loc
      | Meta.throwTacticEx `split_ifs (← getMainGoal) "no if-then-else conditions to split"

  -- If `cond` is `¬p` then use `p` instead.
  let cond := if cond.isAppOf `Not then cond.getAppArgs[0]! else cond

  if done.contains cond then return ()
  let no_split ← valueKnown_ffl cond
  if no_split then
    andThenOnSubgoals_ffl (reduceIfsAt_ffl loc) (splitIfsCore_ffl loc hNames (cond::done) <|> pure ())
  else do
    let hName ← getNextName_ffl hNames
    andThenOnSubgoals_ffl (splitIf1_ffl cond hName loc) ((splitIfsCore_ffl loc hNames (cond::done)) <|>
      pure ())

/-- Splits all if-then-else-expressions into multiple goals.
Given a goal of the form `g (if p then x else y)`, `split_ifs` will produce
two goals: `p ⊢ g x` and `¬p ⊢ g y`.
If there are multiple ite-expressions, then `split_ifs` will split them all,
starting with a top-most one whose condition does not contain another
ite-expression.
`split_ifs at *` splits all ite-expressions in all hypotheses as well as the goal.
`split_ifs with h₁ h₂ h₃` overrides the default names for the hypotheses.
-/
syntax (name := splitIfs) "split_ifs" (location)? (" with" (ppSpace colGt binderIdent)+)? : tactic

elab_rules : tactic
| `(tactic| split_ifs $[$loc:location]? $[with $withArg*]?) =>
  let loc := match loc with
  | none => Location.targets #[] true
  | some loc => expandLocation loc
  let names := match withArg with
  | none => []
  | some args => args.toList
  withMainContext do
    let names ← IO.mkRef names
    splitIfsCore_ffl loc names []
    for name in ← names.get do
      logWarningAt name m!"unused name: {name}"

end Mathlib.Tactic

end Mathlib.Tactic.SplitIfs

section Mathlib.Order.Defs

class Preorder_ffl (α : Type _) extends LE α, LT α where

end Mathlib.Order.Defs

section Mathlib.Tactic.Core

open Lean Elab Tactic

namespace Lean.Elab.Tactic
#check Parser.Tactic.allGoals_ffl
def allGoals_ffl (tac : TacticM Unit) : TacticM Unit := do
  let mvarIds ← getGoals
  let mut mvarIdsNew := #[]
  for mvarId in mvarIds do
    unless (← mvarId.isAssigned) do
      setGoals [mvarId]
      try
        tac
        mvarIdsNew := mvarIdsNew ++ (← getUnsolvedGoals)
      catch ex =>
        if (← read).recover then
          logException ex
          mvarIdsNew := mvarIdsNew.push mvarId
        else
          throw ex
  setGoals mvarIdsNew.toList

/-- Simulates the `<;>` tactic combinator. First runs `tac1` and then runs
    `tac2` on all newly-generated subgoals.
-/
def andThenOnSubgoals_ffl (tac1 : TacticM Unit) (tac2 : TacticM Unit) : TacticM Unit :=
  focus do tac1; allGoals_ffl tac2

end Lean.Elab.Tactic

end Mathlib.Tactic.Core

section Mathlib.Tactic.SplitIfs

namespace Mathlib.Tactic

open Lean Elab.Tactic Parser.Tactic Lean.Meta

/-- A position where a split may apply.
-/
private inductive SplitPosition_ffl
| target
| hyp (fvarId: FVarId)

/-- Collects a list of positions pointed to by `loc` and their types.
-/
private def getSplitCandidates_ffl (loc : Location) : TacticM (List (SplitPosition_ffl × Expr)) :=
match loc with
| Location.wildcard => do
   let candidates ← (← getLCtx).getFVarIds.mapM
     (fun fvarId ↦ do
       let typ ← instantiateMVars (← inferType (mkFVar fvarId))
       return (SplitPosition_ffl.hyp fvarId, typ))
   pure ((SplitPosition_ffl.target, ← getMainTarget) :: candidates.toList)
| Location.targets hyps tgt => do
   let candidates ← (← hyps.mapM getFVarId).mapM
     (fun fvarId ↦ do
       let typ ← instantiateMVars (← inferType (mkFVar fvarId))
       return (SplitPosition_ffl.hyp fvarId, typ))
   if tgt
   then return (SplitPosition_ffl.target, ← getMainTarget) :: candidates.toList
   else return candidates.toList

/-- Return the condition and decidable instance of an `if` expression to case split. -/
private partial def findIfToSplit?_ffl (e : Expr) : Option (Expr × Expr) :=
  match e.find? fun e => (e.isIte || e.isDIte) && !(e.getArg! 1 5).hasLooseBVars with
  | some iteApp =>
    let cond := iteApp.getArg! 1 5
    let dec := iteApp.getArg! 2 5
    -- Try to find a nested `if` in `cond`
    findIfToSplit?_ffl cond |>.getD (cond, dec)
  | none => none

/-- Finds an if condition to split. If successful, returns the position and the condition.
-/
private def findIfCondAt_ffl (loc : Location) : TacticM (Option (SplitPosition_ffl × Expr)) := do
  for (pos, e) in (← getSplitCandidates_ffl loc) do
    if let some (cond, _) := findIfToSplit?_ffl e
    then return some (pos, cond)
  return none

/-- `Simp.Discharge` strategy to use in `reduceIfsAt`. Delegates to
`SplitIf.discharge?`, and additionally supports discharging `True`, to
better match the behavior of mathlib3's `split_ifs`.
-/
private def discharge?_ffl (e : Expr) : SimpM (Option Expr) := do
  let e ← instantiateMVars e
  if let some e1 ← (← SplitIf.mkDischarge? false) e
    then return some e1
  if e.isConstOf `True
    then return some (mkConst `True.intro)
  return none

/-- Simplifies if-then-else expressions after cases have been split out.
-/
private def reduceIfsAt_ffl (loc : Location) : TacticM Unit := do
  let ctx ← SplitIf.getSimpContext
  let ctx ← ctx.setConfig { ctx.config with failIfUnchanged := false }
  let _ ← simpLocation ctx (← ({} : Simp.SimprocsArray).add `reduceCtorEq false) discharge?_ffl loc
  pure ()

/-- Splits a single if-then-else expression and then reduces the resulting goals.
Has a similar effect as `SplitIf.splitIfTarget?` or `SplitIf.splitIfLocalDecl?` from
core Lean 4. We opt not to use those library functions so that we can better mimic
the behavior of mathlib3's `split_ifs`.
-/
private def splitIf1_ffl (cond : Expr) (hName : Name) (loc : Location) : TacticM Unit := do
  let splitCases :=
    evalTactic (← `(tactic| by_cases $(mkIdent hName) : $(← Elab.Term.exprToSyntax cond)))
  andThenOnSubgoals_ffl splitCases (reduceIfsAt_ffl loc)

/-- Pops off the front of the list of names, or generates a fresh name if the
list is empty.
-/
private def getNextName_ffl (hNames: IO.Ref (List (TSyntax `Lean.binderIdent))) : MetaM Name := do
  match ← hNames.get with
  | [] => mkFreshUserName `h
  | n::ns => do hNames.set ns
                if let `(binderIdent| $x:ident) := n
                then pure x.getId
                else pure `_

/-- Returns `true` if the condition or its negation already appears as a hypothesis.
-/
private def valueKnown_ffl (cond : Expr) : TacticM Bool := do
  let not_cond := mkApp (mkConst `Not) cond
  for h in ← getLocalHyps do
    let ty ← instantiateMVars (← inferType h)
    if cond == ty then return true
    if not_cond == ty then return true
  return false

/-- Main loop of split_ifs. Pulls names for new hypotheses from `hNames`.
Stops if it encounters a condition in the passed-in `List Expr`.
-/
private partial def splitIfsCore_ffl
    (loc : Location)
    (hNames : IO.Ref (List (TSyntax `Lean.binderIdent))) :
    List Expr → TacticM Unit := fun done ↦ withMainContext do
  let some (_,cond) ← findIfCondAt_ffl loc
      | Meta.throwTacticEx `split_ifs (← getMainGoal) "no if-then-else conditions to split"

  -- If `cond` is `¬p` then use `p` instead.
  let cond := if cond.isAppOf `Not then cond.getAppArgs[0]! else cond

  if done.contains cond then return ()
  let no_split ← valueKnown_ffl cond
  if no_split then
    andThenOnSubgoals_ffl (reduceIfsAt_ffl loc) (splitIfsCore_ffl loc hNames (cond::done) <|> pure ())
  else do
    let hName ← getNextName_ffl hNames
    andThenOnSubgoals_ffl (splitIf1_ffl cond hName loc) ((splitIfsCore_ffl loc hNames (cond::done)) <|>
      pure ())

end Mathlib.Tactic
end Mathlib.Tactic.SplitIfs

section Mathlib.Order.Defs
class PartialOrder_ffl (α : Type _) extends Preorder_ffl α where

class LinearOrder_ffl (α : Type _) extends PartialOrder_ffl α, Min α, Max α, Ord α where
  /-- In a linearly ordered type, we assume the order relations are all decidable. -/
  decidableLE : DecidableRel (· ≤ · : α → α → Prop)
  /-- In a linearly ordered type, we assume the order relations are all decidable. -/
  decidableEq : DecidableEq α
  /-- In a linearly ordered type, we assume the order relations are all decidable. -/
  decidableLT : DecidableRel (· < · : α → α → Prop)
  min := fun a b => if a ≤ b then a else b
  max := fun a b => if a ≤ b then b else a

variable [LinearOrder_ffl α] {a b c : α}

instance (priority := 900) (a b : α) : Decidable (a < b) := LinearOrder_ffl.decidableLT a b
instance (priority := 900) (a b : α) : Decidable (a ≤ b) := LinearOrder_ffl.decidableLE a b
instance (priority := 900) (a b : α) : Decidable (a = b) := LinearOrder_ffl.decidableEq a b

end Mathlib.Order.Defs

section Mathlib.Order.Lattice_ffl

universe u v w

variable {α : Type u}

class SemilatticeSup_ffl (α : Type u) extends PartialOrder_ffl α where
  sup : α → α → α

class Lattice_ffl (α : Type u) extends SemilatticeSup_ffl α

end Mathlib.Order.Lattice_ffl

open Lean Meta Elab Tactic in
/-- `guard_goal_nums n` succeeds if there are exactly `n` goals and fails otherwise. -/
elab (name := guardGoalNums) "guard_goal_nums " n:num : tactic => do
  let numGoals := (← getGoals).length
  guard (numGoals = n.getNat) <|>
    throwError "expected {n.getNat} goals but found {numGoals}"

example (a m tl : α) (f : α → β) [LinearOrder_ffl β] :
    (if f (if f a < f m then m else a) < f tl then some tl else some (if f a < f m then m else a)) =
      if f a < f (if f m < f tl then tl else m) then some (if f m < f tl then tl else m) else some a := by
  split_ifs
  guard_goal_nums 7
  all_goals sorry

instance LinearOrder_ffl.toLattice_ffl {α : Type u} [o : LinearOrder_ffl α] : Lattice_ffl α :=
  let __spread := o
  { __spread with sup := max }

example (a m tl : α) (f : α → β) [LinearOrder_ffl β] :
    (if f (if f a < f m then m else a) < f tl then some tl else some (if f a < f m then m else a)) =
      if f a < f (if f m < f tl then tl else m) then some (if f m < f tl then tl else m) else some a := by
  split_ifs
  guard_goal_nums 7
  all_goals sorry

#print code

section Mathlib.Tactic.SplitIfs
namespace Mathlib.Tactic
open Lean Elab.Tactic Parser.Tactic Lean.Meta
/-- Splits all if-then-else-expressions into multiple goals.
Given a goal of the form `g (if p then x else y)`, `split_ifs` will produce
two goals: `p ⊢ g x` and `¬p ⊢ g y`.
If there are multiple ite-expressions, then `split_ifs` will split them all,
starting with a top-most one whose condition does not contain another
ite-expression.
`split_ifs at *` splits all ite-expressions in all hypotheses as well as the goal.
`split_ifs with h₁ h₂ h₃` overrides the default names for the hypotheses.
-/
syntax (name := splitIfs) "split_ifs" (location)? (" with" (ppSpace colGt binderIdent)+)? : tactic

elab_rules : tactic
| `(tactic| split_ifs $[$loc:location]? $[with $withArg*]?) =>
  let loc := match loc with
  | none => Location.targets #[] true
  | some loc => expandLocation loc
  let names := match withArg with
  | none => []
  | some args => args.toList
  withMainContext do
    let names ← IO.mkRef names
    splitIfsCore_ffl loc names []
    for name in ← names.get do
      logWarningAt name m!"unused name: {name}"

end Mathlib.Tactic

end Mathlib.Tactic.SplitIfs

section Mathlib.Order.Defs

class Preorder_ffl (α : Type _) extends LE α, LT α where

class PartialOrder_ffl (α : Type _) extends Preorder_ffl α where

class LinearOrder_ffl (α : Type _) extends PartialOrder_ffl α, Min α, Max α, Ord α where
  /-- In a linearly ordered type, we assume the order relations are all decidable. -/
  decidableLE : DecidableRel (· ≤ · : α → α → Prop)
  /-- In a linearly ordered type, we assume the order relations are all decidable. -/
  decidableEq : DecidableEq α
  /-- In a linearly ordered type, we assume the order relations are all decidable. -/
  decidableLT : DecidableRel (· < · : α → α → Prop)
  min := fun a b => if a ≤ b then a else b
  max := fun a b => if a ≤ b then b else a

variable [LinearOrder_ffl α] {a b c : α}

instance (priority := 900) (a b : α) : Decidable (a < b) := LinearOrder_ffl.decidableLT a b
instance (priority := 900) (a b : α) : Decidable (a ≤ b) := LinearOrder_ffl.decidableLE a b
instance (priority := 900) (a b : α) : Decidable (a = b) := LinearOrder_ffl.decidableEq a b

end Mathlib.Order.Defs

section Mathlib.Order.Lattice_ffl

universe u v w

variable {α : Type u}

class SemilatticeSup_ffl (α : Type u) extends PartialOrder_ffl α where
  sup : α → α → α

class Lattice_ffl (α : Type u) extends SemilatticeSup_ffl α

end Mathlib.Order.Lattice_ffl

open Lean Meta Elab Tactic in
/-- `guard_goal_nums n` succeeds if there are exactly `n` goals and fails otherwise. -/
elab (name := guardGoalNums) "guard_goal_nums " n:num : tactic => do
  let numGoals := (← getGoals).length
  guard (numGoals = n.getNat) <|>
    throwError "expected {n.getNat} goals but found {numGoals}"

example (a m tl : α) (f : α → β) [LinearOrder_ffl β] :
    (if f (if f a < f m then m else a) < f tl then some tl else some (if f a < f m then m else a)) =
      if f a < f (if f m < f tl then tl else m) then some (if f m < f tl then tl else m) else some a := by
  split_ifs
  guard_goal_nums 7
  all_goals sorry

instance LinearOrder_ffl.toLattice_ffl {α : Type u} [o : LinearOrder_ffl α] : Lattice_ffl α :=
  let __spread := o
  { __spread with sup := max }

example (a m tl : α) (f : α → β) [LinearOrder_ffl β] :
    (if f (if f a < f m then m else a) < f tl then some tl else some (if f a < f m then m else a)) =
      if f a < f (if f m < f tl then tl else m) then some (if f m < f tl then tl else m) else some a := by
  split_ifs
  guard_goal_nums 7
  all_goals sorry

section Mathlib.Tactic.Core

open Lean Elab Tactic

namespace Lean.Elab.Tactic
#check Parser.Tactic.allGoals
def allGoals (tac : TacticM Unit) : TacticM Unit := do
  let mvarIds ← getGoals
  let mut mvarIdsNew := #[]
  for mvarId in mvarIds do
    unless (← mvarId.isAssigned) do
      setGoals [mvarId]
      try
        tac
        mvarIdsNew := mvarIdsNew ++ (← getUnsolvedGoals)
      catch ex =>
        if (← read).recover then
          logException ex
          mvarIdsNew := mvarIdsNew.push mvarId
        else
          throw ex
  setGoals mvarIdsNew.toList

/-- Simulates the `<;>` tactic combinator. First runs `tac1` and then runs
    `tac2` on all newly-generated subgoals.
-/
def andThenOnSubgoals (tac1 : TacticM Unit) (tac2 : TacticM Unit) : TacticM Unit :=
  focus do tac1; allGoals tac2

end Lean.Elab.Tactic

end Mathlib.Tactic.Core

section Mathlib.Tactic.SplitIfs

namespace Mathlib.Tactic

open Lean Elab.Tactic Parser.Tactic Lean.Meta

/-- A position where a split may apply.
-/
private inductive SplitPosition
| target
| hyp (fvarId: FVarId)
| fflCtor9457 (x : Array SplitPosition)

/-- Collects a list of positions pointed to by `loc` and their types.
-/
private def getSplitCandidates (loc : Location) : TacticM (List (SplitPosition × Expr)) :=
match loc with
| Location.wildcard => do
   let candidates ← (← getLCtx).getFVarIds.mapM
     (fun fvarId ↦ do
       let typ ← instantiateMVars (← inferType (mkFVar fvarId))
       return (SplitPosition.hyp fvarId, typ))
   pure ((SplitPosition.target, ← getMainTarget) :: candidates.toList)
| Location.targets hyps tgt => do
   let candidates ← (← hyps.mapM getFVarId).mapM
     (fun fvarId ↦ do
       let typ ← instantiateMVars (← inferType (mkFVar fvarId))
       return (SplitPosition.hyp fvarId, typ))
   if tgt
   then return (SplitPosition.target, ← getMainTarget) :: candidates.toList
   else return candidates.toList

/-- Return the condition and decidable instance of an `if` expression to case split. -/
private partial def findIfToSplit? (e : Expr) : Option (Expr × Expr) :=
  match e.find? fun e => (e.isIte || e.isDIte) && !(e.getArg! 1 5).hasLooseBVars with
  | some iteApp =>
    let cond := iteApp.getArg! 1 5
    let dec := iteApp.getArg! 2 5
    -- Try to find a nested `if` in `cond`
    findIfToSplit? cond |>.getD (cond, dec)
  | none => none

/-- Finds an if condition to split. If successful, returns the position and the condition.
-/
private def findIfCondAt (loc : Location) : TacticM (Option (SplitPosition × Expr)) := do
  for (pos, e) in (← getSplitCandidates loc) do
    if let some (cond, _) := findIfToSplit? e
    then return some (pos, cond)
  return none

/-- `Simp.Discharge` strategy to use in `reduceIfsAt`. Delegates to
`SplitIf.discharge?`, and additionally supports discharging `True`, to
better match the behavior of mathlib3's `split_ifs`.
-/
private def discharge? (e : Expr) : SimpM (Option Expr) := do
  let e ← instantiateMVars e
  if let some e1 ← (← SplitIf.mkDischarge? false) e
    then return some e1
  if e.isConstOf `True
    then return some (mkConst `True.intro)
  return none

/-- Simplifies if-then-else expressions after cases have been split out.
-/
private def reduceIfsAt (loc : Location) : TacticM Unit := do
  let ctx ← SplitIf.getSimpContext
  let ctx ← ctx.setConfig { ctx.config with failIfUnchanged := false }
  let _ ← simpLocation ctx (← ({} : Simp.SimprocsArray).add `reduceCtorEq false) discharge? loc
  pure ()

/-- Splits a single if-then-else expression and then reduces the resulting goals.
Has a similar effect as `SplitIf.splitIfTarget?` or `SplitIf.splitIfLocalDecl?` from
core Lean 4. We opt not to use those library functions so that we can better mimic
the behavior of mathlib3's `split_ifs`.
-/
private def splitIf1 (cond : Expr) (hName : Name) (loc : Location) : TacticM Unit := do
  let splitCases :=
    evalTactic (← `(tactic| by_cases $(mkIdent hName) : $(← Elab.Term.exprToSyntax cond)))
  andThenOnSubgoals splitCases (reduceIfsAt loc)

/-- Pops off the front of the list of names, or generates a fresh name if the
list is empty.
-/
private def getNextName (hNames: IO.Ref (List (TSyntax `Lean.binderIdent))) : MetaM Name := do
  match ← hNames.get with
  | [] => mkFreshUserName `h
  | n::ns => do hNames.set ns
                if let `(binderIdent| $x:ident) := n
                then pure x.getId
                else pure `_

/-- Returns `true` if the condition or its negation already appears as a hypothesis.
-/
private def valueKnown (cond : Expr) : TacticM Bool := do
  let not_cond := mkApp (mkConst `Not) cond
  for h in ← getLocalHyps do
    let ty ← instantiateMVars (← inferType h)
    if cond == ty then return true
    if not_cond == ty then return true
  return false

/-- Main loop of split_ifs. Pulls names for new hypotheses from `hNames`.
Stops if it encounters a condition in the passed-in `List Expr`.
-/
private partial def splitIfsCore
    (loc : Location)
    (hNames : IO.Ref (List (TSyntax `Lean.binderIdent))) :
    List Expr → TacticM Unit := fun done ↦ withMainContext do
  let some (_,cond) ← findIfCondAt loc
      | Meta.throwTacticEx `split_ifs (← getMainGoal) "no if-then-else conditions to split"

  -- If `cond` is `¬p` then use `p` instead.
  let cond := if cond.isAppOf `Not then cond.getAppArgs[0]! else cond

  if done.contains cond then return ()
  let no_split ← valueKnown cond
  if no_split then
    andThenOnSubgoals (reduceIfsAt loc) (splitIfsCore loc hNames (cond::done) <|> pure ())
  else do
    let hName ← getNextName hNames
    andThenOnSubgoals (splitIf1 cond hName loc) ((splitIfsCore loc hNames (cond::done)) <|>
      pure ())

/-- Splits all if-then-else-expressions into multiple goals.
Given a goal of the form `g (if p then x else y)`, `split_ifs` will produce
two goals: `p ⊢ g x` and `¬p ⊢ g y`.
If there are multiple ite-expressions, then `split_ifs` will split them all,
starting with a top-most one whose condition does not contain another
ite-expression.
`split_ifs at *` splits all ite-expressions in all hypotheses as well as the goal.
`split_ifs with h₁ h₂ h₃` overrides the default names for the hypotheses.
-/
syntax (name := splitIfs) "split_ifs" (location)? (" with" (ppSpace colGt binderIdent)+)? : tactic

elab_rules : tactic
| `(tactic| split_ifs $[$loc:location]? $[with $withArg*]?) =>
  let loc := match loc with
  | none => Location.targets #[] true
  | some loc => expandLocation loc
  let names := match withArg with
  | none => []
  | some args => args.toList
  withMainContext do
    let names ← IO.mkRef names
    splitIfsCore loc names []
    for name in ← names.get do
      logWarningAt name m!"unused name: {name}"

end Mathlib.Tactic

end Mathlib.Tactic.SplitIfs

section Mathlib.Order.Defs

class Preorder (α : Type _) extends LE α, LT α where

class PartialOrder (α : Type _) extends Preorder α where

class LinearOrder (α : Type _) extends PartialOrder α, Min α, Max α, Ord α where
  /-- In a linearly ordered type, we assume the order relations are all decidable. -/
  decidableLE : DecidableRel (· ≤ · : α → α → Prop)
  /-- In a linearly ordered type, we assume the order relations are all decidable. -/
  decidableEq : DecidableEq α
  /-- In a linearly ordered type, we assume the order relations are all decidable. -/
  decidableLT : DecidableRel (· < · : α → α → Prop)
  min := fun a b => if a ≤ b then a else b
  max := fun a b => if a ≤ b then b else a

variable [LinearOrder α] {a b c : α}

instance (priority := 900) (a b : α) : Decidable (a < b) := LinearOrder.decidableLT a b
instance (priority := 900) (a b : α) : Decidable (a ≤ b) := LinearOrder.decidableLE a b
instance (priority := 900) (a b : α) : Decidable (a = b) := LinearOrder.decidableEq a b

end Mathlib.Order.Defs

section Mathlib.Order.Lattice

universe u v w

variable {α : Type u}

class SemilatticeSup (α : Type u) extends PartialOrder α where
  sup : α → α → α

class Lattice (α : Type u) extends SemilatticeSup α

end Mathlib.Order.Lattice

open Lean Meta Elab Tactic in
/-- `guard_goal_nums n` succeeds if there are exactly `n` goals and fails otherwise. -/
elab (name := guardGoalNums) "guard_goal_nums " n:num : tactic => do
  let numGoals := (← getGoals).length
  guard (numGoals = n.getNat) <|>
    throwError "expected {n.getNat} goals but found {numGoals}"

example (a m tl : α) (f : α → β) [LinearOrder β] :
    (if f (if f a < f m then m else a) < f tl then some tl else some (if f a < f m then m else a)) =
      if f a < f (if f m < f tl then tl else m) then some (if f m < f tl then tl else m) else some a := by
  split_ifs
  guard_goal_nums 7
  all_goals sorry

instance LinearOrder.toLattice {α : Type u} [o : LinearOrder α] : Lattice α :=
  let __spread := o
  { __spread with sup := max }

example (a m tl : α) (f : α → β) [LinearOrder β] :
    (if f (if f a < f m then m else a) < f tl then some tl else some (if f a < f m then m else a)) =
      if f a < f (if f m < f tl then tl else m) then some (if f m < f tl then tl else m) else some a := by
  split_ifs
  guard_goal_nums 7
  all_goals sorry
