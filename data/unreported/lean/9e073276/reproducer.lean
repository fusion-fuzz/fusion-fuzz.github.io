module
import Lean

structure S where
  decls : Array Nat

structure E where
  s : S

structure Inp (s : S) where
  x : Nat

def myF (s : S) (_ : Inp s) : E := ⟨s⟩

def composed (s : S) (a b : Nat) : E :=
  let res := myF s ⟨a⟩
  myF res.s ⟨b⟩

-- Sanity check: with the linter off (default), no warning is emitted.

set_option warn.sorry false in
example (s : S) (a b idx : Nat) (h1 : idx < s.decls.size)
    (h2 : idx < (composed s a b).s.decls.size) :
    (composed s a b).s.decls[idx]'h2 = s.decls[idx]'h1 := by
  unfold composed
  sorry

set_option linter.tacticCheckInstances true

/--
@ +4:2...17
warning: produced tactic goal is not type-correct at `.implicit` transparency; consider using propositional rewriting or marking some of the following as `@[implicit_reducible]`:
  composed
  myF
Full error:
  Application type mismatch: The argument
    h2
  has type
    idx < (composed s a b).s.decls.size
  but is expected to have type
    idx <
      (have res := myF s { x := a };
            myF res.s { x := b }).s.decls.size
  in the application
    (have res := myF s { x := a };
          myF res.s { x := b }).s.decls[idx]

Note: This linter can be disabled with `set_option linter.tacticCheckInstances false`
-/
#guard_msgs (positions := true) in
example (s : S) (a b idx : Nat) (h1 : idx < s.decls.size)
    (h2 : idx < (composed s a b).s.decls.size) :
    (composed s a b).s.decls[idx]'h2 = s.decls[idx]'h1 := by
  unfold composed
  rfl


/-!
Rolling back an environment change through `SavedState.restore` drops the type class resolution
cache entries recorded after it, as a different change could later bring the recorded generations or
declaration change log position back, or reuse the name of a removed constant, and keeps the entries
recorded before the rollback point. The latest recording start is carried over the rollback, so that
changes the surviving entries depend on stay logged.
-/

open Lean Meta Elab Command

class Foo where
  val : Nat

@[instance_reducible] def a : Foo := ⟨1⟩
@[instance_reducible] def b : Foo := ⟨2⟩

run_meta do
  let s ← saveState
  liftCommandElabM <| elabCommand (← `(attribute [instance] a))
  let r₁ ← synthInstance (mkConst ``Foo)
  s.restore
  liftCommandElabM <| elabCommand (← `(attribute [instance] b))
  let r₂ ← synthInstance (mkConst ``Foo)
  logInfo m!"{r₁} then {r₂}"

class Bar where

instance : Bar := ⟨⟩

class Baz where

run_meta do
  let cmd ← `(instance : Baz := ⟨⟩)
  withOptions (·.setBool `trace.Meta.synthInstance.cache true) do
    discard <| synthInstance (mkConst ``Bar)
    let s ← saveState
    liftCommandElabM <| elabCommand cmd
    s.restore
    discard <| synthInstance (mkConst ``Bar)

class Q (α : Type) where

instance : Q Nat := ⟨⟩

def X := Nat
def Y := Nat

-- A logged reducibility change rolled back and replaced by another logged change at the same
-- position of the declaration change log: the entry recorded in between must not be served.


/--
@ +3:2...5
warning: initial tactic goal is not type-correct at `.implicit` transparency; consider rephrasing the goal or marking some of the following as `@[implicit_reducible]`:
  composed
  myF
Full error:
  Application type mismatch: The argument
    h1
  has type
    idx < s.decls.size
  but is expected to have type
    idx < (composed s a b).s.decls.size
  in the application
    (composed s a b).s.decls[idx]

Note: This linter can be disabled with `set_option linter.tacticCheckInstances false`
-/
#guard_msgs (positions := true) in
example (s : S) (a b idx : Nat) (h1 : idx < s.decls.size) :
    (composed s a b).s.decls[idx] = s.decls[idx] := by
  rfl

run_meta do
  let before := (← synthInstance? (mkApp (mkConst ``Q) (mkConst ``X))).isSome
  let s ← saveState
  liftCommandElabM <| elabCommand (← `(attribute [reducible] X))
  let during := (← synthInstance? (mkApp (mkConst ``Q) (mkConst ``X))).isSome
  s.restore
  liftCommandElabM <| elabCommand (← `(attribute [reducible] Y))
  let after := (← synthInstance? (mkApp (mkConst ``Q) (mkConst ``X))).isSome
  logInfo m!"{before} then {during} then {after}"

class Q' (α : Type) where

instance : Q' Nat := ⟨⟩

-- `D` is added after the latest recording start, and the query observing it runs after the save
-- point. Restoring must not roll the recording start back past `D`, as `D`'s later reducibility
-- change would then go unlogged while the entry survives.

run_meta do
  addDecl <| .defnDecl {
    name := `D, levelParams := [], type := mkSort 1, value := mkConst ``Nat,
    hints := .regular 0, safety := .safe }
  let q := mkApp (mkConst ``Q') (mkConst `D)
  let s ← saveState
  let during := (← synthInstance? q).isSome
  s.restore
  (Attribute.add `D `reducible .missing : CoreM Unit)
  let after := (← synthInstance? q).isSome
  logInfo m!"{during} then {after}"

-- A constant added after the save point is observed and then removed by the restore; a constant of
-- the same name added after another one gets a later generation than the entry's recording start,
-- so the entry must not survive the rollback.

run_meta do
  let mkDef (n : Name) : Declaration := .defnDecl {
    name := n, levelParams := [], type := mkSort 1, value := mkConst ``Nat,
    hints := .regular 0, safety := .safe }
  let q := mkApp (mkConst ``Q') (mkConst `E)
  let s ← saveState
  addDecl (mkDef `E)
  let during := (← synthInstance? q).isSome
  s.restore
  addDecl (mkDef `F)
  addDecl (mkDef `E)
  (Attribute.add `E `reducible .missing : CoreM Unit)
  let after := (← synthInstance? q).isSome
  logInfo m!"{during} then {after}"

-- `Term.observing` followed by `applyResult` rolls back a constant and restores it again: the
-- entries recorded after the constant must be served again rather than recomputed.

run_meta do
  let s0 ← saveState
  addDecl <| .defnDecl {
    name := `G, levelParams := [], type := mkSort 1, value := mkConst ``Nat,
    hints := .regular 0, safety := .safe }
  let q := mkApp (mkConst ``Q') (mkConst ``Nat)
  withOptions (·.setBool `trace.Meta.synthInstance.cache true) do
    discard <| synthInstance? q
  let s1 ← saveState
  s0.restore
  s1.restore
  withOptions (·.setBool `trace.Meta.synthInstance.cache true) do
    discard <| synthInstance? q

attribute [noinline] b

/-!
Rolling back an environment change through `SavedState.restore` drops the type class resolution
cache entries recorded after it, as a different change could later bring the recorded generations or
declaration change log position back, or reuse the name of a removed constant, and keeps the entries
recorded before the rollback point. The latest recording start is carried over the rollback, so that
changes the surviving entries depend on stay logged.
-/

open Lean Meta Elab Command

class Foo_ffl where
  val : Nat

@[instance_reducible] def a_ffl : Foo_ffl := ⟨1⟩
@[instance_reducible] def b_ffl : Foo_ffl := ⟨2⟩

run_meta do
  let s ← saveState
  liftCommandElabM <| elabCommand (← `(attribute [instance] a_ffl))
  let r₁ ← synthInstance (mkConst ``Foo_ffl)
  s.restore
  liftCommandElabM <| elabCommand (← `(attribute [instance] b_ffl))
  let r₂ ← synthInstance (mkConst ``Foo_ffl)
  logInfo m!"{r₁} then {r₂}"

class Bar_ffl where

instance : Bar_ffl := ⟨⟩

class Baz_ffl where

run_meta do
  let cmd ← `(instance : Baz_ffl := ⟨⟩)
  withOptions (·.setBool `trace.Meta.synthInstance.cache true) do
    discard <| synthInstance (mkConst ``Bar_ffl)
    let s ← saveState
    liftCommandElabM <| elabCommand cmd
    s.restore
    discard <| synthInstance (mkConst ``Bar_ffl)

class Q_ffl (α : Type) where

instance : Q_ffl Nat := ⟨⟩

def X_ffl := Nat
def Y_ffl := Nat

-- A logged reducibility change rolled back and replaced by another logged change at the same
-- position of the declaration change log: the entry recorded in between must not be served.

run_meta do
  let before := (← synthInstance? (mkApp (mkConst ``Q_ffl) (mkConst ``X_ffl))).isSome
  let s ← saveState
  liftCommandElabM <| elabCommand (← `(attribute [reducible] X_ffl))
  let during := (← synthInstance? (mkApp (mkConst ``Q_ffl) (mkConst ``X_ffl))).isSome
  s.restore
  liftCommandElabM <| elabCommand (← `(attribute [reducible] Y_ffl))
  let after := (← synthInstance? (mkApp (mkConst ``Q_ffl) (mkConst ``X_ffl))).isSome
  logInfo m!"{before} then {during} then {after}"

class Q'_ffl (α : Type) where

instance : Q'_ffl Nat := ⟨⟩

-- `D` is added after the latest recording start, and the query observing it runs after the save
-- point. Restoring must not roll the recording start back past `D`, as `D`'s later reducibility
-- change would then go unlogged while the entry survives.

run_meta do
  addDecl <| .defnDecl {
    name := `D, levelParams := [], type := mkSort 1, value := mkConst ``Nat,
    hints := .regular 0, safety := .safe }
  let q := mkApp (mkConst ``Q'_ffl) (mkConst `D)
  let s ← saveState
  let during := (← synthInstance? q).isSome
  s.restore
  (Attribute.add `D `reducible .missing : CoreM Unit)
  let after := (← synthInstance? q).isSome
  logInfo m!"{during} then {after}"

-- A constant added after the save point is observed and then removed by the restore; a constant of
-- the same name added after another one gets a later generation than the entry's recording start,
-- so the entry must not survive the rollback.

run_meta do
  let mkDef (n : Name) : Declaration := .defnDecl {
    name := n, levelParams := [], type := mkSort 1, value := mkConst ``Nat,
    hints := .regular 0, safety := .safe }
  let q := mkApp (mkConst ``Q'_ffl) (mkConst `E)
  let s ← saveState
  addDecl (mkDef `E)
  let during := (← synthInstance? q).isSome
  s.restore
  addDecl (mkDef `F)
  addDecl (mkDef `E)
  (Attribute.add `E `reducible .missing : CoreM Unit)
  let after := (← synthInstance? q).isSome
  logInfo m!"{during} then {after}"

-- `Term.observing` followed by `applyResult` rolls back a constant and restores it again: the
-- entries recorded after the constant must be served again rather than recomputed.

run_meta do
  let s0 ← saveState
  addDecl <| .defnDecl {
    name := `G, levelParams := [], type := mkSort 1, value := mkConst ``Nat,
    hints := .regular 0, safety := .safe }
  let q := mkApp (mkConst ``Q'_ffl) (mkConst ``Nat)
  withOptions (·.setBool `trace.Meta.synthInstance.cache true) do
    discard <| synthInstance? q
  let s1 ← saveState
  s0.restore
  s1.restore
  withOptions (·.setBool `trace.Meta.synthInstance.cache true) do
    discard <| synthInstance? q
