import Lean

infix:65 " +' " => Add.add
infix:70 " *' " => Mul.mul
infixr:30 " OR " => Or
prefix:40 "NOT " => Not

theorem ex (a b c d : Nat) (p : Prop) : (NOT p OR a = b*'c +' c*'a OR a = b *' c) = (¬ p ∨ a = b*c + c*a ∨ a = b * c) :=
rfl

attribute [simp ←] ex

open Lean
open Lean.Meta

instance : ToFormat InstanceEntry where
  format e := format e.val

unsafe def tst1_ffl : IO Unit := do
  enableInitializersExecution
  let env ← importModules (loadExts := true) #[{module := `Lean}] {}
  let aux : MetaM Unit := do
    let insts ← getGlobalInstancesIndex
    assert! insts.size > 0
    IO.println (format insts)
  discard <| aux.run |>.toIO { fileName := "", fileMap := default } { env := env }

#eval tst1_ffl

open Lean
open Lean.Meta

instance : ToFormat InstanceEntry where
  format e := format e.val

unsafe def tst1 : IO Unit := do
  enableInitializersExecution
  let env ← importModules (loadExts := true) #[{module := `Lean}] {}
  enableInitializersExecution
  let env ← importModules (loadExts := true) #[{module := `Lean}] {}
  let aux : MetaM Unit := do
    let insts ← getGlobalInstancesIndex
    assert! insts.size > 0
    IO.println (format insts)
  discard <| aux.run |>.toIO { fileName := "", fileMap := default } { env := env }

  let aux : MetaM Unit := do
    let loadExts ← getGlobalInstancesIndex
    assert! loadExts.size > 0
    IO.println (format loadExts)
  discard <| aux.run |>.toIO { fileName := "", fileMap := default } { env := env }

#eval tst1
