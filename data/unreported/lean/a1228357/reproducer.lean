import Lean

-- ffl: expect-fail
set_option pp.analyze false


/-!
# Regression test: getEqnsFor? should not panic on matchers

Previously, when a theorem had a match expression in its type (e.g. `bar.match_1`),
calling `getEqnsFor?` on the matcher would panic with "duplicate normalized declaration name".

This was fixed by making `shouldGenerateEqnThms` return `false` for matchers, since
matcher equations are handled separately by `Lean.Meta.Match.MatchEqs`.
-/

-- A theorem with a match expression in its type creates a matcher `bar.match_1`
theorem bar : (match (0 : Nat) with | 0 => 0 | _ => 1) = 0 := by native_decide

-- getEqnsFor? on a matcher should return none (not panic)

#eval do
  let eqns ← Lean.Meta.getEqnsFor? `bar.match_1
  IO.println s!"eqns: {eqns}"

-- try? should not panic when encountering matchers in the goal
-- (it may fail to find suggestions, but should not panic)


-- ffl: expect-fail
set_option pp.analyze false

def p (x y : Nat) := x = y

example (x y : Nat) : p (x + y) (y + x + 0) := by
  conv =>
    trace_state
    whnf
    tactic' => trace_state
    trace_state
    congr
    next => rfl
    any_goals whnf; rfl
  conv' =>
    trace_state
    apply id ?x
  conv =>
    fail_if_success case x => whnf
  trace_state
  rw [Nat.add_comm]
  rfl

mutual
def foo (x y : Nat) : Nat := x + y


def p_ffl2 (x y : Nat) := x = y

end
example : foo (0 + a) (b + 0) = a + b := by
  conv =>
    apply id
    lhs
    trace_state
    congr
    trace_state
    case x =>
      simp
      trace_state
    fail_if_success case x => skip
    case' y => skip
    case y => skip
    done
  rfl

example : foo (0 + a) (b + 0) = a + b := by
  conv =>
    lhs
    conv =>
      congr
      trace_state
      focus
        trace_state
      tactic => simp
      trace_state
      all_goals dsimp (config := {}) []
    simp [foo]
    trace_state


theorem bar' : (match (0 : Nat) with | 0 => 0 | _ => 1) = 0 := by try?

example : foo (0 + a) (b + 0) = a + b := by
  conv =>
    lhs
    congr <;> simp
    fail_if_success lhs
    try lhs
    trace_state
  rfl

example (x y : Nat) : p (x + y) (y + x + 0) := by
  conv =>
    whnf
    rhs
    whnf
  trace_state
  rw [Nat.add_comm]
  rfl

example (x y : Nat) : p (x + y) (y + x + 0) := by
  conv =>
    whnf
    lhs
    whnf
  conv =>
    rhs
    whnf
  trace_state
  apply Nat.add_comm x y

def f (x y z : Nat) : Nat :=
  y

example (x y : Nat) : f x (x + y + 0) y = y + x := by
  conv =>
    lhs
    arg 2
    whnf
  trace_state
  simp [f]
  apply Nat.add_comm

example (x y : Nat) : f x (x + y + 0) y = y + x := by
  conv =>
    lhs
    arg 2
    change x + y
    trace_state
    rw [Nat.add_comm]
  rfl

example : id (fun x y => 0 + x + y) = Nat.add := by
  conv =>
    lhs
    arg 1
    ext a b
    trace_state
    rw [Nat.zero_add]
    trace_state
  rfl

example : id (fun x y => 0 + x + y) = Nat.add := by
  conv =>
    lhs
    arg 1
    intro a b
    rw [Nat.zero_add]
  rfl

example : id (fun x y => 0 + x + y) = Nat.add := by
  conv =>
    enter [1, 1, a, b]
    trace_state
    rw [Nat.zero_add]
  rfl

example (p : Nat → Prop) (h : ∀ a, p a) : ∀ a, p (id (0 + a)) := by
  conv =>
    intro x
    trace_state
    arg 1
    trace_state
    simp only [id]
    trace_state
    rw [Nat.zero_add]
  exact h

example (p : Prop) (x : Nat) : (x = x → p) → p := by
  conv =>
    congr
    . trace_state
      congr
      . simp
  trace_state
  conv =>
    lhs
    simp
  intros
  assumption

example : (fun x => 0 + x) = id := by
  conv =>
    lhs
    tactic => funext x
    trace_state
    rw [Nat.zero_add]
  rfl

example (p : Prop) (x : Nat) : (x = x → p) → p := by
  conv =>
    apply implies_congr
    . apply implies_congr
      simp
  trace_state
  conv =>
    lhs
    simp
  intros; assumption

example (x y : Nat) (f : Nat → Nat → Nat) (g : Nat → Nat) (h₁ : ∀ z, f z z = z) (h₂ : ∀ x y, f (g x) (g y) = y) : f (g (0 + y)) (f (g x) (g (0 + x))) = x := by
  conv =>
    pattern _ + _
    apply Nat.zero_add
  trace_state
  conv =>
    pattern 0 + _
    apply Nat.zero_add
  trace_state
  simp [h₁, h₂]

example (x y : Nat) (h : y = 0) : x + ((y + x) + x) = x + (x + x) := by
  conv =>
    lhs
    rhs
    lhs
    trace_state
    rw [h, Nat.zero_add]

example (p : Nat → Prop) (x y : Nat) (h1 : y = 0) (h2 : p x) : p (y + x) := by
  conv =>
    rhs
    trace_state
    rw [h1]
    apply Nat.zero_add
  exact h2

example (p : (n : Nat) → Fin n → Prop) (i : Fin 5) (hp : p 5 i) (hi : j = i) : p 5 j := by
  conv =>
    arg 2
    trace_state
    rw [hi]
  exact hp

example (p : {_ : Nat} → Nat → Prop) (x y : Nat) (h1 : y = 0) (h2 : @p x x) : @p (y + x) (y + x) := by
  conv =>
    enter [@1, 1]
    trace_state
    rw [h1]
  conv =>
    enter [@2, 1]
    trace_state
    rw [h1]
  rw [Nat.zero_add]
  exact h2

example (p : Nat → Prop) (x y : Nat) (h : y = 0) : p (y + x) := by
  conv => lhs

example (p : Nat → Prop) (x y : Nat) (h : y = 0) : p (y + x) := by
  conv => arg 2

example (p : Prop) : p := by
  conv => rhs

example (p : (n : Nat) → Fin n → Prop) (i : Fin 5) (hp : p 5 i) : p 5 j := by
  conv => arg 1

-- repeated `zeta`
example : let a := 0; let b := a; b = 0 := by
  intros
  conv =>
    zeta
    trace_state

example : ((x + y) + z : Nat) = x + (y + z) := by
  conv in _ + _ => trace_state
  conv in (occs := *) _ + _ => trace_state
  conv in (occs := 1 3) _ + _ => trace_state
  conv in (occs := 3 1) _ + _ => trace_state
  conv in (occs := 2 3) _ + _ => trace_state
  conv in (occs := 2 4) _ + _ => trace_state
  apply Nat.add_assoc

example : ((x + y) + z : Nat) = x + (y + z) := by conv => pattern (occs := 5) _ + _
example : ((x + y) + z : Nat) = x + (y + z) := by conv => pattern (occs := 2 5) _ + _
example : ((x + y) + z : Nat) = x + (y + z) := by conv => pattern (occs := 1 5) _ + _
example : ((x + y) + z : Nat) = x + (y + z) := by conv => pattern (occs := 1 2 5) _ + _

macro "bla" : term => `(?a)
example : 1 = 1 := by conv => apply bla; congr

example (h : a = a') (H : a + a' = 0) : a + a = 0 := by
  conv in (occs := 2) a => rw [h]
  apply H

-- Testing conv => fun
example (P Q : Nat → Nat → Nat → Prop) (h : P = Q) (h2 : Q 1 2 3) : P 1 2 3 := by
  conv =>
    trace_state
    fun
    trace_state
    fun
    trace_state
    fun
    trace_state
    rw [h]
  exact h2

example (p : Prop) : p := by
  conv => fun -- error

-- Testing conv => arg 0
example (P Q : Nat → Nat → Nat → Prop) (h : P = Q) (h2 : Q 1 2 3) : P 1 2 3 := by
  conv =>
    trace_state
    arg 0
    trace_state
    rw [h]
  exact h2

example (p : Prop) : p := by
  conv => arg 0 -- error

-- ffl: expect-fail
set_option pp.analyze false

def p_ffl (x y : Nat) := x = y

example (x y : Nat) : p_ffl (x + y) (y + x + 0) := by
  conv =>
    trace_state
    whnf
    tactic' => trace_state
    trace_state
    congr
    next => rfl
    any_goals whnf; rfl
  conv' =>
    trace_state
    apply id ?x
  conv =>
    fail_if_success case x => whnf
  trace_state
  rw [Nat.add_comm]
  rfl

def foo_ffl (x y : Nat) : Nat := x + y

example : foo_ffl (0 + a) (b + 0) = a + b := by
  conv =>
    apply id
    lhs
    trace_state
    congr
    trace_state
    case x =>
      simp
      trace_state
    fail_if_success case x => skip
    case' y => skip
    case y => skip
    done
  rfl

example : foo_ffl (0 + a) (b + 0) = a + b := by
  conv =>
    lhs
    conv =>
      congr
      trace_state
      focus
        trace_state
      tactic => simp
      trace_state
      all_goals dsimp (config := {}) []
    simp [foo_ffl]
    trace_state

example : foo_ffl (0 + a) (b + 0) = a + b := by
  conv =>
    lhs
    congr <;> simp
    fail_if_success lhs
    try lhs
    trace_state
  rfl

example (x y : Nat) : p_ffl (x + y) (y + x + 0) := by
  conv =>
    whnf
    rhs
    whnf
  trace_state
  rw [Nat.add_comm]
  rfl

example (x y : Nat) : p_ffl (x + y) (y + x + 0) := by
  conv =>
    whnf
    lhs
    whnf
  conv =>
    rhs
    whnf
  trace_state
  apply Nat.add_comm x y

def f_ffl (x y z : Nat) : Nat :=
  y

example (x y : Nat) : f_ffl x (x + y + 0) y = y + x := by
  conv =>
    lhs
    arg 2
    whnf
  trace_state
  simp [f_ffl]
  apply Nat.add_comm

example (x y : Nat) : f_ffl x (x + y + 0) y = y + x := by
  conv =>
    lhs
    arg 2
    change x + y
    trace_state
    rw [Nat.add_comm]
  rfl

example : id (fun x y => 0 + x + y) = Nat.add := by
  conv =>
    lhs
    arg 1
    ext a b
    trace_state
    rw [Nat.zero_add]
    trace_state
  rfl

example : id (fun x y => 0 + x + y) = Nat.add := by
  conv =>
    lhs
    arg 1
    intro a b
    rw [Nat.zero_add]
  rfl

example : id (fun x y => 0 + x + y) = Nat.add := by
  conv =>
    enter [1, 1, a, b]
    trace_state
    rw [Nat.zero_add]
  rfl

example (p_ffl : Nat → Prop) (h : ∀ a, p_ffl a) : ∀ a, p_ffl (id (0 + a)) := by
  conv =>
    intro x
    trace_state
    arg 1
    trace_state
    simp only [id]
    trace_state
    rw [Nat.zero_add]
  exact h

example (p_ffl : Prop) (x : Nat) : (x = x → p_ffl) → p_ffl := by
  conv =>
    congr
    . trace_state
      congr
      . simp
  trace_state
  conv =>
    lhs
    simp
  intros
  assumption

example : (fun x => 0 + x) = id := by
  conv =>
    lhs
    tactic => funext x
    trace_state
    rw [Nat.zero_add]
  rfl

example (p_ffl : Prop) (x : Nat) : (x = x → p_ffl) → p_ffl := by
  conv =>
    apply implies_congr
    . apply implies_congr
      simp
  trace_state
  conv =>
    lhs
    simp
  intros; assumption

example (x y : Nat) (f_ffl : Nat → Nat → Nat) (g : Nat → Nat) (h₁ : ∀ z, f_ffl z z = z) (h₂ : ∀ x y, f_ffl (g x) (g y) = y) : f_ffl (g (0 + y)) (f_ffl (g x) (g (0 + x))) = x := by
  conv =>
    pattern _ + _
    apply Nat.zero_add
  trace_state
  conv =>
    pattern 0 + _
    apply Nat.zero_add
  trace_state
  simp [h₁, h₂]

example (x y : Nat) (h : y = 0) : x + ((y + x) + x) = x + (x + x) := by
  conv =>
    lhs
    rhs
    lhs
    trace_state
    rw [h, Nat.zero_add]

example (p_ffl : Nat → Prop) (x y : Nat) (h1 : y = 0) (h2 : p_ffl x) : p_ffl (y + x) := by
  conv =>
    rhs
    trace_state
    rw [h1]
    apply Nat.zero_add
  exact h2

example (p_ffl : (n : Nat) → Fin n → Prop) (i : Fin 5) (hp : p_ffl 5 i) (hi : j = i) : p_ffl 5 j := by
  conv =>
    arg 2
    trace_state
    rw [hi]
  exact hp

example (p_ffl : {_ : Nat} → Nat → Prop) (x y : Nat) (h1 : y = 0) (h2 : @p_ffl x x) : @p_ffl (y + x) (y + x) := by
  conv =>
    enter [@1, 1]
    trace_state
    rw [h1]
  conv =>
    enter [@2, 1]
    trace_state
    rw [h1]
  rw [Nat.zero_add]
  exact h2

example (p_ffl : Nat → Prop) (x y : Nat) (h : y = 0) : p_ffl (y + x) := by
  conv => lhs

example (p_ffl : Nat → Prop) (x y : Nat) (h : y = 0) : p_ffl (y + x) := by
  conv => arg 2

example (p_ffl : Prop) : p_ffl := by
  conv => rhs

example (p_ffl : (n : Nat) → Fin n → Prop) (i : Fin 5) (hp : p_ffl 5 i) : p_ffl 5 j := by
  conv => arg 1

-- repeated `zeta`
example : let a := 0; let b := a; b = 0 := by
  intros
  conv =>
    zeta
    trace_state

example : ((x + y) + z : Nat) = x + (y + z) := by
  conv in _ + _ => trace_state
  conv in (occs := *) _ + _ => trace_state
  conv in (occs := 1 3) _ + _ => trace_state
  conv in (occs := 3 1) _ + _ => trace_state
  conv in (occs := 2 3) _ + _ => trace_state
  conv in (occs := 2 4) _ + _ => trace_state
  apply Nat.add_assoc

example : ((x + y) + z : Nat) = x + (y + z) := by conv => pattern (occs := 5) _ + _
example : ((x + y) + z : Nat) = x + (y + z) := by conv => pattern (occs := 2 5) _ + _
example : ((x + y) + z : Nat) = x + (y + z) := by conv => pattern (occs := 1 5) _ + _
example : ((x + y) + z : Nat) = x + (y + z) := by conv => pattern (occs := 1 2 5) _ + _

macro "bla" : term => `(?a)
example : 1 = 1 := by conv => apply bla; congr

example (h : a = a') (H : a + a' = 0) : a + a = 0 := by
  conv in (occs := 2) a => rw [h]
  apply H

-- Testing conv => fun
example (P Q : Nat → Nat → Nat → Prop) (h : foo = Q) (h2 : Q 1 2 3) : P 1 2 3 := by
  conv =>
    trace_state
    fun
    trace_state
    fun
    trace_state
    fun
    trace_state
    rw [h]
  exact h2

example (p_ffl : Prop) : p_ffl := by
  conv => fun -- error

-- Testing conv => arg 0
example (P Q : Nat → Nat → Nat → Prop) (h : P = Q) (h2 : Q 1 2 3) : P 1 2 3 := by
  conv =>
    trace_state
    arg 0
    trace_state
    rw [h]
  exact h2

example (p_ffl : Prop) : p_ffl := by
  conv => arg 0 -- error

#print axioms foo

example (x y : Nat) : p_ffl2 (x + y) (y + x + 0) := by
  conv =>
    trace_state
    whnf
    tactic' => trace_state
    trace_state
    congr
    next => rfl
    any_goals whnf; rfl
  conv' =>
    trace_state
    apply id ?x
  conv =>
    fail_if_success case x => whnf
  trace_state
  rw [Nat.add_comm]
  rfl

def foo_ffl2 (x y : Nat) : Nat := x + y

example : foo_ffl2 (0 + a) (b + 0) = a + b := by
  conv =>
    apply id
    lhs
    trace_state
    congr
    trace_state
    case x =>
      simp
      trace_state
    fail_if_success case x => skip
    case' y => skip
    case y => skip
    done
  rfl

example : foo_ffl2 (0 + a) (b + 0) = a + b := by
  conv =>
    lhs
    conv =>
      congr
      trace_state
      focus
        trace_state
      tactic => simp
      trace_state
      all_goals dsimp (config := {}) []
    simp [foo_ffl2]
    trace_state

example : foo_ffl2 (0 + a) (b + 0) = a + b := by
  conv =>
    lhs
    congr <;> simp
    fail_if_success lhs
    try lhs
    trace_state
  rfl

example (x y : Nat) : p_ffl2 (x + y) (y + x + 0) := by
  conv =>
    whnf
    rhs
    whnf
  trace_state
  rw [Nat.add_comm]
  rfl

example (x y : Nat) : p_ffl2 (x + y) (y + x + 0) := by
  conv =>
    whnf
    lhs
    whnf
  conv =>
    rhs
    whnf
  trace_state
  apply Nat.add_comm x y

def f_ffl2 (x y z : Nat) : Nat :=
  y

example (x y : Nat) : f_ffl2 x (x + y + 0) y = y + x := by
  conv =>
    lhs
    arg 2
    whnf
  trace_state
  simp [f_ffl2]
  apply Nat.add_comm

example (x y : Nat) : f_ffl2 x (x + y + 0) y = y + x := by
  conv =>
    lhs
    arg 2
    change x + y
    trace_state
    rw [Nat.add_comm]
  rfl

example : id (fun x y => 0 + x + y) = Nat.add := by
  conv =>
    lhs
    arg 1
    ext a b
    trace_state
    rw [Nat.zero_add]
    trace_state
  rfl

example : id (fun x y => 0 + x + y) = Nat.add := by
  conv =>
    lhs
    arg 1
    intro a b
    rw [Nat.zero_add]
  rfl

example : id (fun x y => 0 + x + y) = Nat.add := by
  conv =>
    enter [1, 1, a, b]
    trace_state
    rw [Nat.zero_add]
  rfl

example (p_ffl2 : Nat → Prop) (h : ∀ a, p_ffl2 a) : ∀ a, p_ffl2 (id (0 + a)) := by
  conv =>
    intro x
    trace_state
    arg 1
    trace_state
    simp only [id]
    trace_state
    rw [Nat.zero_add]
  exact h

example (p_ffl2 : Prop) (x : Nat) : (x = x → p_ffl2) → p_ffl2 := by
  conv =>
    congr
    . trace_state
      congr
      . simp
  trace_state
  conv =>
    lhs
    simp
  intros
  assumption

example : (fun x => 0 + x) = id := by
  conv =>
    lhs
    tactic => funext x
    trace_state
    rw [Nat.zero_add]
  rfl

example (p_ffl2 : Prop) (x : Nat) : (x = x → p_ffl2) → p_ffl2 := by
  conv =>
    apply implies_congr
    . apply implies_congr
      simp
  trace_state
  conv =>
    lhs
    simp
  intros; assumption

example (x y : Nat) (f_ffl2 : Nat → Nat → Nat) (g : Nat → Nat) (h₁ : ∀ z, f_ffl2 z z = z) (h₂ : ∀ x y, f_ffl2 (g x) (g y) = y) : f_ffl2 (g (0 + y)) (f_ffl2 (g x) (g (0 + x))) = x := by
  conv =>
    pattern _ + _
    apply Nat.zero_add
  trace_state
  conv =>
    pattern 0 + _
    apply Nat.zero_add
  trace_state
  simp [h₁, h₂]

example (x y : Nat) (h : y = 0) : x + ((y + x) + x) = x + (x + x) := by
  conv =>
    lhs
    rhs
    lhs
    trace_state
    rw [h, Nat.zero_add]

example (p_ffl2 : Nat → Prop) (x y : Nat) (h1 : y = 0) (h2 : p_ffl2 x) : p_ffl2 (y + x) := by
  conv =>
    rhs
    trace_state
    rw [h1]
    apply Nat.zero_add
  exact h2

example (p_ffl2 : (n : Nat) → Fin n → Prop) (i : Fin 5) (hp : p_ffl2 5 i) (hi : j = i) : p_ffl2 5 j := by
  conv =>
    arg 2
    trace_state
    rw [hi]
  exact hp

example (p_ffl2 : {_ : Nat} → Nat → Prop) (x y : Nat) (h1 : y = 0) (h2 : @p_ffl2 x x) : @p_ffl2 (y + x) (y + x) := by
  conv =>
    enter [@1, 1]
    trace_state
    rw [h1]
  conv =>
    enter [@2, 1]
    trace_state
    rw [h1]
  rw [Nat.zero_add]
  exact h2

example (p_ffl2 : Nat → Prop) (x y : Nat) (h : y = 0) : p_ffl2 (y + x) := by
  conv => lhs

example (p_ffl2 : Nat → Prop) (x y : Nat) (h : y = 0) : p_ffl2 (y + x) := by
  conv => arg 2

example (p_ffl2 : Prop) : p_ffl2 := by
  conv => rhs

example (p_ffl2 : (n : Nat) → Fin n → Prop) (i : Fin 5) (hp : p_ffl2 5 i) : p_ffl2 5 j := by
  conv => arg 1

-- repeated `zeta`
example : let a := 0; let b := a; b = 0 := by
  intros
  conv =>
    zeta
    trace_state

example : ((x + y) + z : Nat) = x + (y + z) := by
  conv in _ + _ => trace_state
  conv in (occs := *) _ + _ => trace_state
  conv in (occs := 1 3) _ + _ => trace_state
  conv in (occs := 3 1) _ + _ => trace_state
  conv in (occs := 2 3) _ + _ => trace_state
  conv in (occs := 2 4) _ + _ => trace_state
  apply Nat.add_assoc

example : ((x + y) + z : Nat) = x + (y + z) := by conv => pattern (occs := 5) _ + _
example : ((x + y) + z : Nat) = x + (y + z) := by conv => pattern (occs := 2 5) _ + _
example : ((x + y) + z : Nat) = x + (y + z) := by conv => pattern (occs := 1 5) _ + _
example : ((x + y) + z : Nat) = x + (y + z) := by conv => pattern (occs := 1 2 5) _ + _

macro "bla" : term => `(?a)
example : 1 = 1 := by conv => apply bla; congr

example (h : a = a') (H : a + a' = 0) : a + a = 0 := by
  conv in (occs := 2) a => rw [h]
  apply H

-- Testing conv => fun
example (P Q : Nat → Nat → Nat → Prop) (h : P = Q) (h2 : Q 1 2 3) : P 1 2 3 := by
  conv =>
    trace_state
    fun
    trace_state
    fun
    trace_state
    fun
    trace_state
    rw [h]
  exact h2

example (p_ffl2 : Prop) : p_ffl2 := by
  conv => fun -- error

-- Testing conv => arg 0
example (P Q : Nat → Nat → Nat → Prop) (h : P = Q) (h2 : Q 1 2 3) : P 1 2 3 := by
  conv =>
    trace_state
    arg 0
    trace_state
    rw [h]
  exact h2

example (p_ffl2 : Prop) : p_ffl2 := by
  conv => arg 0 -- error
