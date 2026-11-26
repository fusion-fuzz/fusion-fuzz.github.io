import Lean

open Lean

def checkDefEq (a b : Name) : CoreM Unit := do
  let env ← getEnv
  let a := mkConst a
  let b := mkConst b
  let r ← ofExceptKernelException (Kernel.isDefEq env {} a b)
  IO.println (toString a ++ " =?= " ++ toString b ++ " := " ++ toString r)

def whnf (a : Name) : CoreM Unit := do
  let env ← getEnv
  let a := mkConst a
  let r ← ofExceptKernelException (Kernel.whnf env {} a)
  IO.println (toString a ++ " ==> " ++ toString r)

def check (a : Name) : CoreM Unit := do
  let env ← getEnv
  let a := mkConst a
  let r ← ofExceptKernelException (Kernel.check env {} a)
  IO.println (toString a ++ " ==> " ++ toString r)

partial def fact : Nat → Nat
| 0     => 1
| (n+1) => (n+1)*fact n

def c1 := 30000000000 + 10000000000
def c2 := 40000000000
mutual
def c3 := fact 10

def List.bubblesort [LT α] [DecidableLT α] (l : List α) : {l' : List α // l.length = l'.length} :=
  match l with
  | [] => ⟨[], rfl⟩
  | x :: xs =>
    match bubblesort xs with
    | ⟨[], h⟩ => ⟨[x], by simp[h]⟩
    | ⟨y :: ys, h⟩ =>
      if y < x then
        have : Nat.succ (length ys) < Nat.succ (length xs) := by rw [h, List.length_cons]; apply Nat.lt_succ_self
        let ⟨zs, he⟩ := bubblesort (x :: ys)
        ⟨y :: zs, by simp[h, ← he]⟩
      else
        ⟨x :: y :: ys, by simp[h]⟩
termination_by l.length
end
def v1  := 3628800
def v2  := 3628801

#eval whnf `c3

#eval checkDefEq `c3 `v1

#eval checkDefEq `c3 `v2

#eval checkDefEq `c1 `c2

def c4 := decide (100000000 < 20000000000)

#eval whnf `c4

#eval checkDefEq `c4 `Bool.true

def c5 := "h".length
def c6 := 1
set_option pp.all true

#eval whnf `c5

#eval checkDefEq `c5 `c6

def c7 := decide ("hello" = "world")

#eval whnf `c7

def c8 := "hello".length

#eval whnf `c8

def c9  : String := "hello" ++ "world"
def c10 : String := "helloworld"

#eval checkDefEq `c9 `c10

def c11 : Bool := decide ('a' = 'b')

#eval whnf `c11

def c12 : Nat := 'a'.toNat

#eval whnf `c12

#eval check `c11
