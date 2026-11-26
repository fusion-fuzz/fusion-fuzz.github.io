module
public import Lean

/-!
It used to be that aux theorems could only be created within declarations. But with `omega` wanting
to create an aux theorem, and `omega` being used in, say, `variable` commands, this is not tenable.
-/

structure Foo (n : Nat) (h : n > 1 := by omega) : Type

set_option pp.proofs true

#check Foo 3

variable (x : Foo 2)

#check x

public section

open Lean

structure S1 where
  (x y : Nat)

structure S2 extends S1 where
  (z : Nat)

structure S3 where
  (w : Nat)

structure S4 extends S2, S3 where
  (s : Nat)

def check (b : Bool) : CoreM Unit :=
  unless b do throwError "check failed"

class S5 where
  (x y : Nat)

inductive D
  | mk (x y z : Nat) : D

#eval show CoreM Unit from do
  let env ← getEnv
  IO.println (getStructureFields env ``Kernel.Environment)
  check $ getStructureFields env `S4 == #[`toS2, `toS3, `s]
  check $ getStructureFields env `S1 == #[`x, `y]
  check $ isSubobjectField? env `S4 `toS2 == some `S2
  check $ getStructureSubobjects env `S4 == #[`S2, `S3]
  check $ findField? env `Foo `x == some `S1
  check $ findField? env `S4 `x1 == none
  check $ isStructure env `S1
  check $ isStructure env `S2
  check $ isStructure env `S3
  check $ isStructure env `S4
  check $ isStructure env `S5
  check $ !isStructure env `Nat
  check $ !isStructure env `D
  check $ getPathToBaseStructure? env `S1 `S4 == some [`S4.toS2, `S2.toS1]
  IO.println (getStructureFieldsFlattened env `S4)
  IO.println (getPathToBaseStructure? env `S1 `S4)
  IO.println (getStructureSubobjects env `S4)
  IO.println (← getAllParentStructures `S4)
  pure ()

def dumpStructInfo (structName : Name) : CoreM Unit := do
  let env ← getEnv
  let some info := getStructureInfo? env structName
    | throwError "no such structure {structName}"
  IO.println s!"\
    struct: {info.structName}\n\
    fields: {info.fieldNames}\n\
    field infos: {info.fieldInfo.map fun info => s!"({info.fieldName}, {info.subobject?}, {info.projFn})"}\n\
    parent infos: {info.parentInfo.map fun info => (info.structName, info.subobject, info.projFn)}"

#eval dumpStructInfo `S1
#eval dumpStructInfo `S2
#eval dumpStructInfo `S3
#eval dumpStructInfo `S4

/-!
Basic diamond
-/

structure A1 where
  x : Nat
structure A2 extends A1 where
  y : Nat
structure A3 extends A1 where
  z : Nat
structure A4 extends A2, A3 where
  w : Nat

#eval dumpStructInfo `A1
#eval dumpStructInfo `A2
#eval dumpStructInfo `A3
#eval dumpStructInfo `A4

/-!
Abbreviation in parent
-/
abbrev AA1 := A1
structure A5 extends AA1 where
  a : Nat
#eval dumpStructInfo `A5

/-!
Regression test: make sure unused `private` fields are not linted as unused.
-/
section
set_option linter.unusedVariables true

structure Unused1 where
  private x : Nat
  y : Nat
class Unused2 where
  private x : Nat
  y : Nat

structure State where
  macroScope : MacroScope
  private expandedMacroDecls : List Name := List.nil

end

/-!
Regression test: make sure fields that look like constructor names are not linted.
-/
section
set_option linter.constructorNameAsVariable true

-- Used to say "Local variable 'zero' resembles constructor 'Nat.zero'"
structure CtorLikeField where
  zero : Nat

end

/-!
Regression test: make sure mathlib `Type*` still elaborates with levels in correct order.
During development, this came out as `AddEquiv.{u_10, u_9}`.
-/
section
elab "Type*" : term => do
  let u ← Lean.Meta.mkFreshLevelMVar
  Lean.Elab.Term.levelMVarToParam (.sort (.succ u))

end
end

public section

open Lean

structure S1_ffl where
  (x y : Nat)

structure S2_ffl extends S1_ffl where
  (z : Nat)

structure S3_ffl where
  (w : Nat)

structure S4_ffl extends S2_ffl, S3_ffl where
  (s : Nat)

def check_ffl (b : Bool) : CoreM Unit :=
  unless b do throwError "check failed"

class S5_ffl where
  (x y : Nat)

inductive D_ffl
  | mk (x y z : Nat) : D_ffl

#eval show CoreM Unit from do
  let env ← getEnv
  IO.println (getStructureFields env ``Kernel.Environment)
  check_ffl $ getStructureFields env `S4_ffl == #[`toS2, `toS3, `s]
  check_ffl $ getStructureFields env `S1_ffl == #[`x, `y]
  check_ffl $ isSubobjectField? env `S4_ffl `toS2 == some `S2_ffl
  check_ffl $ getStructureSubobjects env `S4_ffl == #[`S2_ffl, `S3_ffl]
  check_ffl $ findField? env `S4_ffl `x == some `S1_ffl
  check_ffl $ findField? env `S4_ffl `x1 == none
  check_ffl $ isStructure env `S1_ffl
  check_ffl $ isStructure env `S2_ffl
  check_ffl $ isStructure env `S3_ffl
  check_ffl $ isStructure env `S4_ffl
  check_ffl $ isStructure env `S5_ffl
  check_ffl $ !isStructure env `Nat
  check_ffl $ !isStructure env `D_ffl
  check_ffl $ getPathToBaseStructure? env `S1_ffl `S4_ffl == some [`S4_ffl.toS2, `S2_ffl.toS1]
  IO.println (getStructureFieldsFlattened env `S4_ffl)
  IO.println (getPathToBaseStructure? env `S1_ffl `S4_ffl)
  IO.println (getStructureSubobjects env `S4_ffl)
  IO.println (← getAllParentStructures `S4_ffl)
  pure ()

def dumpStructInfo_ffl (structName : Name) : CoreM Unit := do
  let env ← getEnv
  let some info := getStructureInfo? env structName
    | throwError "no such structure {structName}"
  IO.println s!"\
    struct: {info.structName}\n\
    fields: {info.fieldNames}\n\
    field infos: {info.fieldInfo.map fun info => s!"({info.fieldName}, {info.subobject?}, {info.projFn})"}\n\
    parent infos: {info.parentInfo.map fun info => (info.structName, info.subobject, info.projFn)}"

#eval dumpStructInfo_ffl `S1_ffl
#eval dumpStructInfo_ffl `S2_ffl
#eval dumpStructInfo_ffl `S3_ffl
#eval dumpStructInfo_ffl `S4_ffl

/-!
Basic diamond
-/

structure A1_ffl where
  x : Nat
structure A2_ffl extends A1_ffl where
  y : Nat
structure A3_ffl extends A1_ffl where
  z : Nat
structure A4_ffl extends A2_ffl, A3_ffl where
  w : Nat

#eval dumpStructInfo_ffl `A1_ffl
#eval dumpStructInfo_ffl `A2_ffl
#eval dumpStructInfo_ffl `A3_ffl
#eval dumpStructInfo_ffl `A4_ffl

/-!
Abbreviation in parent
-/
abbrev AA1_ffl := A1_ffl
structure A5_ffl extends AA1_ffl where
  a : Nat
#eval dumpStructInfo_ffl `A5_ffl

/-!
Regression test: make sure unused `private` fields are not linted as unused.
-/
section
set_option linter.unusedVariables true

structure Unused1_ffl where
  private x : Nat
  y : Nat
class Unused2_ffl where
  private x : Nat
  y : Nat

structure State_ffl where
  macroScope : MacroScope
  private expandedMacroDecls : List Name := List.nil

end

end

public section
open Lean
section
variable {F α β M N P G H : Type*}

structure AddEquiv (A B : Type*) : Type

#check AddEquiv
end
end

public section
open Lean
/-!
Regression test: make sure fields that look like constructor names are not linted.
-/
section
set_option linter.constructorNameAsVariable true

-- Used to say "Local variable 'zero' resembles constructor 'Nat.zero'"
structure CtorLikeField_ffl where
  zero : Nat

end

/-!
Regression test: make sure mathlib `Type*` still elaborates with levels in correct order.
During development, this came out as `AddEquiv.{u_10, u_9}`.
-/
section
elab "Type*" : term => do
  let u ← Lean.Meta.mkFreshLevelMVar
  Lean.Elab.Term.levelMVarToParam (.sort (.succ u))

variable {F α β M N P G H : Type*}

structure AddEquiv_ffl (A B : Type*) : Type

#check_ffl AddEquiv_ffl
end
