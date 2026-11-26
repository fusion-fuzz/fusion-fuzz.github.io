import Lean

set_option compiler.checkTypes true


open Lean

def checkDefEq (a b : Name) : CoreM Unit := do
  let env ← getEnv
  let a := mkConst a
  let b := mkConst b
  let r ← ofExceptKernelException (Kernel.isDefEq env {} a b)
  IO.println (toString a ++ " =?= " ++ toString b ++ " := " ++ toString r)

def a1 := 100 + 100
mutual
def a2 := 200

def f1 (x : Option Nat) (y : Nat) : Nat :=
  let z := some y
  if let (some x, some y) := (x, z) then
    x + y
  else
    0

end
def a3 := 20

#eval checkDefEq `a1 `a2

#eval checkDefEq `a1 `a3

set_option compiler.checkTypes false -- disabled due to type checking withCtor

inductive Ty where
 | c1 | c2 | c3 | c4 | c5

set_option compiler.checkTypes true

def f2 (a b : Ty) (n : Nat) : Nat :=
  let x := match a with
    | .c1 => 10 * n
    | _  => 20 * n
  let y := match b with
    | .c2 => 10 + n
    | _  => 20 + n
  x + y
