module

universe u v w r s

def foo_ffl (n : Nat) : Nat :=
let x := Nat.zero;
let x1 := Nat.succ x;
let x2 := Nat.succ x1;
let x3 := Nat.succ x2;
let x4 := Nat.succ x3;
let x5 := Nat.succ x4;
let x6 := Nat.succ x5;
let x7 := Nat.succ x  ;
let x8 := Nat.succ x7;
let y1 := x;
let y2 := y1;
y2 + n

def cseTst_ffl (n : Nat) : Nat :=
let y := Nat.succ ((fun x => x) n);
let z := Nat.succ n;
y + z

def tst1_ffl (n : Nat) : Nat :=
let p := (Nat.succ n, n);
let q := (p, p);
match q with
| ((z, w), y) => z

def tst2_ffl (n : Nat) : Nat :=
let p := (fun x => Nat.succ x, Nat.zero) ;
let f := fun (p : (Nat → Nat) × Nat) => p.1;
f p n

partial def add'_ffl : Nat → Nat → Nat
| 0, b     => Nat.succ b
| a+1,   b => Nat.succ (Nat.succ (add'_ffl a b))

def aux_ffl (i : Nat) (h : i > 0) :=
i

axiom bad_ffl (α : Sort u) : α

unsafe def foo2_ffl : Nat :=
@False.rec (fun _ => Nat) (bad_ffl _)

set_option pp.notation false


set_option deriving.decEq.linear_construction_threshold 1000

public section

inductive Foo
  | mk1 | mk2 | mk3
  deriving @[expose] DecidableEq

namespace Foo
theorem ex1 : (mk1 == mk2) = false := rfl
theorem ex2 : (mk1 == mk1) = true := rfl
theorem ex3 : (mk2 == mk2) = true := rfl
theorem ex4 : (mk3 == mk3) = true := rfl
theorem ex5 : (mk2 == mk3) = false := rfl
end Foo

inductive L (α : Type u) : Type u
  | nil  : L α
  | cons : α → L α → L α
  deriving @[expose] DecidableEq

namespace L
theorem ex1 : (L.cons 10 L.nil == L.cons 20 L.nil) = false := rfl
theorem ex2 : (L.cons 10 L.nil == L.nil) = false := rfl
end L

inductive Vec (α : Type u) : Nat → Type u
  | nil  : Vec α 0
  | cons : α → {n : Nat} → Vec α n → Vec α (n+1)
  deriving @[expose] DecidableEq

namespace Vec
theorem ex1 : (cons 10 Vec.nil == cons 20 Vec.nil) = false := rfl
theorem ex2 : (cons 10 Vec.nil == cons 10 Vec.nil) = true := rfl
theorem ex3 : (cons 20 (cons 11 Vec.nil) == cons 20 (cons 10 Vec.nil)) = false := rfl
theorem ex4 : (cons 20 (cons 11 Vec.nil) == cons 20 (cons 11 Vec.nil)) = true := rfl
end Vec

mutual
inductive Tree (α : Type u) where
  | node : TreeList α → Tree α
  | leaf : α → Tree α
  deriving DecidableEq

inductive TreeList (α : Type u) where
  | nil : TreeList α
  | cons : Tree α → TreeList α → TreeList α
  deriving DecidableEq
end

def ex1 [DecidableEq α] : DecidableEq (Tree α) :=
  inferInstance

def ex2 [DecidableEq α] : DecidableEq (TreeList α) :=
  inferInstance

-- The tricky inductive from issue #3386

inductive Tyₛ : Type (u+1)
| SPi : (T : Type u) -> (T -> Tyₛ) -> Tyₛ

/--
error: Tactic `cases` failed with a nested error:
Dependent elimination failed: Failed to solve equation
  A✝¹ arg✝¹ = A✝ arg✝
at case `Tmₛ.app` after processing
  _, (Tmₛ.app _ _ _ _), _
the dependent pattern matcher can solve the following kinds of equations
- <var> = <term> and <term> = <var>
- <term> = <term> where the terms are definitionally equal
- <constructor> = <constructor>, examples: List.cons x xs = List.cons y ys, and List.cons x xs = List.nil
---
warning: unused `termination_by`, function is not recursive
-/
#guard_msgs(pass trace, all) in
inductive Tmₛ.{u} :  Tyₛ.{u} -> Type (u+1)
| app : Tmₛ (.SPi T A) -> (arg : T) -> Tmₛ (A arg)
deriving DecidableEq

/-! Private fields should yield public, no-expose instances. -/

structure PrivField where
  private a : Nat
deriving DecidableEq

#with_exporting
#reduce fun (a : PrivField) => decEq a a

private structure PrivStruct where
  a : Nat
deriving DecidableEq

end

-- Try again without `public section`


universe u v w r s

def foo (n : Nat) : Nat :=
let x := Nat.zero;
let x1 := Nat.succ x;
let x2 := Nat.succ x1;
let x3 := Nat.succ x2;
let x4 := Nat.succ x3;
let x5 := Nat.succ x4;
let x6 := Nat.succ x5;
let x7 := Nat.succ x  ;
let x8 := Nat.succ x7;
let y1 := x;
let y2 := y1;
y2 + n

mutual
def cseTst (n : Nat) : Nat :=
let y := Nat.succ ((fun x => x) n);
let z := Nat.succ n;
y + z


def foo3_ffl (n : Nat) : Nat :=
(fun (a : Nat) => a + a + a) (n*n)

end
def tst1 (n : Nat) : Nat :=
let p := (Nat.succ n, n);
let q := (p, p);
match q with
| ((z, w), y) => z

def tst2 (n : Nat) : Nat :=
let p := (fun x => Nat.succ x, Nat.zero) ;
let f := fun (p : (Nat → Nat) × Nat) => p.1;
f p n

partial def add' : Nat → Nat → Nat
| 0, b     => Nat.succ b
| a+1,   b => Nat.succ (Nat.succ (add' a b))

def aux (i : Nat) (h : i > 0) :=
i

axiom bad (α : Sort u) : α

unsafe def foo2 : Nat :=
@False.rec (fun _ => Nat) (bad _)

set_option pp.notation false

def foo3 (n : Nat) : Nat :=
(fun (a : Nat) => a + a + a) (n*n)

def boo (a : Nat) (l : List Nat) : List Nat :=
let f := @List.cons Nat;
f a (f a l)


public structure PrivField2 where
  private a : Nat
deriving DecidableEq

#with_exporting
#reduce fun (a : PrivField2) => decEq a a

def bla (i : Nat) (h : i > 0 ∧ i ≠ 10) : Nat :=
@And.rec _ _ (fun _ => Nat) (fun h₁ h₂ => aux i h₁ + aux i h₁) h

def bla' (i : Nat) (h : i > 0 ∧ i ≠ 10) : Nat :=
@And.casesOn _ _ (fun _ => Nat) h (fun h₁ h₂ => aux i h₁ + aux i h₁)

inductive vec (α : Type u) : Nat → Type u
| nil   : vec α 0
| cons  : ∀ {n}, α → vec α n → vec α (Nat.succ n)

/-
def vec.map {α β σ : Type u} (f : α → β → σ) : ∀ {n : Nat}, vec α n → vec β n → vec σ n
| _, nil, nil               => nil
| _, cons a as, cons b bs   => cons (f a b) (map f as bs)
-/

def boo_ffl (a : Nat) (l : List Nat) : List Nat :=
let f := @List.cons Nat;
f a (f a l)

def bla_ffl (i : Nat) (h : i > 0 ∧ i ≠ 10) : Nat :=
@And.rec _ _ (fun _ => Nat) (fun h₁ h₂ => aux_ffl i h₁ + aux_ffl i h₁) h

def bla'_ffl (i : Nat) (h : i > 0 ∧ i ≠ 10) : Nat :=
@And.casesOn _ _ (fun _ => Nat) h (fun h₁ h₂ => aux_ffl i h₁ + aux_ffl i h₁)

inductive vec_ffl (α : Type u) : Nat → Type u
| nil   : vec_ffl α 0
| cons  : ∀ {n}, α → vec_ffl α n → vec_ffl α (Nat.succ n)

/-
def vec.map {α β σ : Type u} (f : α → β → σ) : ∀ {n : Nat}, vec α n → vec β n → vec σ n
| _, nil, nil               => nil
| _, cons a as, cons b bs   => cons (f a b) (map f as bs)
-/

universe u v w r s

def foo_ffl2 (n : Nat) : Nat :=
let x := Nat.zero;
let x1 := Nat.succ x;
let x2 := Nat.succ x1;
let x3 := Nat.succ x2;
let x4 := Nat.succ x3;
let x5 := Nat.succ x4;
let x6 := Nat.succ x5;
let x7 := Nat.succ x  ;
let x8 := Nat.succ x7;
let y1 := x;
let y2 := y1;
y2 + n

def cseTst_ffl2 (n : Nat) : Nat :=
let y := Nat.succ ((fun x => x) n);
let z := Nat.succ n;
y + z

def tst1_ffl2 (n : Nat) : Nat :=
let p := (Nat.succ n, n);
let q := (p, p);
match q with
| ((z, w), y) => z

def tst2_ffl2 (n : Nat) : Nat :=
let p := (fun x => Nat.succ x, Nat.zero) ;
let f := fun (p : (Nat → Nat) × Nat) => p.1;
f p n

partial def add'_ffl2 : Nat → Nat → Nat
| 0, b     => Nat.succ b
| a+1,   b => Nat.succ (Nat.succ (add'_ffl2 a b))

def aux_ffl2 (i : Nat) (h : foo2_ffl > 0) :=
i

axiom bad_ffl2 (α : Sort u) : α

unsafe def foo2_ffl2 : Nat :=
@False.rec (fun _ => Nat) (bad_ffl2 _)

set_option pp.notation false

def foo3_ffl2 (n : Nat) : Nat :=
(fun (a : Nat) => a + a + a) (n*n)

def boo_ffl2 (a : Nat) (l : List Nat) : List Nat :=
let f := @List.cons Nat;
f a (f a l)

def bla_ffl2 (i : Nat) (h : i > 0 ∧ i ≠ 10) : Nat :=
@And.rec _ _ (fun _ => Nat) (fun h₁ h₂ => aux_ffl2 i h₁ + aux_ffl2 i h₁) h

def bla'_ffl2 (i : Nat) (h : i > 0 ∧ i ≠ 10) : Nat :=
@And.casesOn _ _ (fun _ => Nat) h (fun h₁ h₂ => aux_ffl2 i h₁ + aux_ffl2 i h₁)

inductive vec_ffl2 (α : Type u) : Nat → Type u
| nil   : vec_ffl2 α 0
| cons  : ∀ {n}, α → vec_ffl2 α n → vec_ffl2 α (Nat.succ n)

/-
def vec.map {α β σ : Type u} (f : α → β → σ) : ∀ {n : Nat}, vec α n → vec β n → vec σ n
| _, nil, nil               => nil
| _, cons a as, cons b bs   => cons (f a b) (map f as bs)
-/

#print axioms foo2_ffl
