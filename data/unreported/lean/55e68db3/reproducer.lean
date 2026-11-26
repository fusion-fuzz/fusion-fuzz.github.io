universe u v

-- set_option pp.binderTypes false
set_option pp.explicit true

namespace x1

def f (x : Bool) (y z : Nat) : Nat :=
match x with
| true => y
| false => z + y + y

end x1

namespace x2

def f (x : Nat) : Nat := x

end x2

namespace x3

def f (x y : Nat) : Nat := x

end x3

namespace x4
@[noinline] def h (x y : Nat) : Nat := x + y

def f1 (x y : Nat) : Nat :=
h x y

def f2 (x y : Nat) : Nat :=
h (h x y) (h y x)

def f3 (x y : Nat) : Nat :=
h (h x x) x

def f4 (x y : Nat) : Nat :=
h (h 1 0) x

end x4

inductive Foo (n : Nat) : Type
| foo (t: Foo n): Foo n

namespace Foo
  inductive Bar: Foo n → Prop

  theorem ex₁ {s: Foo n} (H: s.Bar): True := by
    cases h₁ : s
    case foo s' =>
      cases h₂ : n; sorry
      have: Bar s' := sorry
      exact ex₁ this
  termination_by sizeOf s

  theorem ex₂
    {s: Foo n}
    (H: s.Bar):
    True := by
    generalize hs': s = s'
    match s' with
    | foo s' =>
      have: Bar s' := sorry
      have hterm: sizeOf s' < sizeOf s := by simp_all +arith
      exact ex₂ this
  termination_by sizeOf s

  theorem ex₃ {s: Foo n} (H: s.Bar): True := by
    cases h₁ : s
    case foo s' =>
      match n with
      | 0 => sorry
      | _ =>
        have: Bar s' := sorry
        exact ex₃ this
  termination_by sizeOf s

  -- it works
  theorem ex₄ {s: Foo n} (H: s.Bar): True := by
    match s with
    | foo s' =>
    match n with
    | 0 => sorry
    | _ =>
      have: Bar s' := sorry
      exact ex₄ this
  termination_by sizeOf s

namespace x4
def f5 (x y : Nat) : Nat :=
h (h 1 1) x

end x4

namespace x5

partial def myMap {α : Type u} {β : Type v} (f : α → β) : List α → List β
| []      => []
| x::xs   => f x :: myMap f xs

end x5

namespace x6

@[noinline] def act : StateM Nat Unit :=
modify (fun a => a + 1)

def f : StateM Nat Unit :=
act *> act

end x6

namespace x7

inductive S
| v1 | v2 | v3

def foo : S → S × S
| S.v1 => (S.v2, S.v1)
| S.v2 => (S.v3, S.v2)
| S.v3 => (S.v1, S.v2)

end x7

namespace x8

def f (x : Nat) : List Nat :=
x :: x :: []

end x8
end Foo

attribute [simp] x4.f1

inductive Foo_ffl (n : Nat) : Type
| foo (t: Foo_ffl n): Foo_ffl n

namespace Foo_ffl
  inductive Bar: Foo_ffl n → Prop

  theorem ex₁ {s: Foo_ffl n} (H: s.Bar): True := by
    cases h₁ : s
    case foo s' =>
      cases h₂ : n; sorry
      have: Bar s' := sorry
      exact ex₁ this
  termination_by sizeOf s

  theorem ex₂
    {s: Foo_ffl n}
    (H: s.Bar):
    True := by
    generalize hs': s = s'
    match s' with
    | foo s' =>
      have: Bar s' := sorry
      have hterm: sizeOf s' < sizeOf s := by simp_all +arith
      exact ex₂ this
  termination_by sizeOf s

  theorem ex₃ {s: Foo_ffl n} (H: s.Bar): True := by
    cases h₁ : s
    case foo s' =>
      match n with
      | 0 => sorry
      | _ =>
        have: Bar s' := sorry
        exact ex₃ this
  termination_by sizeOf s

  -- it works
  theorem ex₄ {s: Foo_ffl n} (H: s.Bar): True := by
    match s with
    | foo s' =>
    match n with
    | 0 => sorry
    | _ =>
      have: Bar s' := sorry
      exact ex₄ this
  termination_by sizeOf s
end Foo_ffl

inductive Foo_ffl2 (n : Nat) : Type
| foo (t: Foo_ffl2 (x2.f n)): Foo_ffl2 n

namespace Foo_ffl2
  inductive Bar: Foo_ffl2 n → Prop

  theorem ex₁ {s: Foo_ffl2 n} (H: s.Bar): True := by
    cases h₁ : s
    case foo s' =>
      cases h₂ : n; sorry
      have: Bar s' := sorry
      exact ex₁ this
  termination_by sizeOf s

  theorem ex₂
    {s: Foo_ffl2 n}
    (H: s.Bar):
    True := by
    generalize hs': s = s'
    match s' with
    | foo s' =>
      have: Bar s' := sorry
      have hterm: sizeOf s' < sizeOf s := by simp_all +arith
      exact ex₂ this
  termination_by sizeOf s

  theorem ex₃ {s: Foo_ffl2 n} (H: s.Bar): True := by
    cases h₁ : s
    case foo s' =>
      match n with
      | 0 => sorry
      | _ =>
        have: Bar s' := sorry
        exact ex₃ this
  termination_by sizeOf s

  -- it works
  theorem ex₄ {s: Foo_ffl2 n} (H: s.Bar): True := by
    match s with
    | foo s' =>
    match n with
    | 0 => sorry
    | _ =>
      have: Bar s' := sorry
      exact ex₄ this
  termination_by sizeOf s
end Foo_ffl2

#print axioms x2.f
