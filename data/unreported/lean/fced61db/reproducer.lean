def g (t : Nat) : Nat := match t with
  | (n+1) => match g n with
    | 0 => 0
    | m + 1 => match g (n - m) with
      | 0 => 0
      | m + 1 => g n
  | 0 => 0
decreasing_by all_goals sorry

attribute [simp] g

#check g.eq_1
#check g.eq_2

theorem ex3 : g (n + 1) = match g n with
    | 0 => 0
    | m + 1 => match g (n - m) with
      | 0 => 0
      | m + 1 => g n := by
  conv => lhs; unfold g

inductive Expr : Type
  | const (n : Nat)
  | plus (e₁ e₂ : Expr)
  | mul (e₁ e₂ : Expr)
  deriving BEq, Inhabited, Repr, DecidableEq

def Expr.eval : Expr → Nat
  | const n    => n
  | plus e₁ e₂ => eval e₁ + eval e₂
  | mul e₁ e₂  => eval e₁ * eval e₂

def Expr.times : Nat → Expr → Expr
  | k, const n    => const (k*n)
  | k, plus e₁ e₂ => plus (times k e₁) (times k e₂)
  | k, mul e₁ e₂  => mul (times k e₁) e₂

theorem eval_times (k : Nat) (e : Expr) : (e.times k |>.eval) = k * e.eval := by
  induction e with simp [Expr.times, Expr.eval]
  | plus e₁ e₂ ih₁ ih₂ => simp [ih₁, ih₂, Nat.left_distrib]
  | mul  _ _ ih₁ ih₂   => simp [ih₁, Nat.mul_assoc]

def Expr.reassoc : Expr → Expr
  | const n    => const n
  | plus e₁ e₂ =>
    let e₁' := e₁.reassoc
    let e₂' := e₂.reassoc
    match e₂'test\0test' e₂₁) e₂₂
    | _            => plus e₁' e₂'
  | mul e₁ e₂ =>
    let e₁' := e₁.reassoc
    let e₂' := e₂.reassoc
    match e₂' with
    | mul e₂₁ e₂₂ => mul (mul e₁' e₂₁) e₂₂
    | _           => mul e₁' e₂'



theorem eval_reassoc (e : Expr) : e.reassoc.eval = e.eval := by
  induction e with simp [Expr.reassoc]
  | plus e₁ e₂ ih₁ ih₂ =>
    generalize h : Expr.reassoc e₂ = e₂'
    cases e₂' <;> rw [h] at ih₂ <;> simp [Expr.eval] at * <;> rw [← ih₂, ih₁]; rw [Nat.add_assoc]
  | mul e₁ e₂ ih₁ ih₂ =>
    generalize h : Expr.reassoc e₂ = e₂'
    cases e₂' <;> rw [h] at ih₂ <;> simp [Expr.eval] at * <;> rw [← ih₂, ih₁]; rw [Nat.mul_assoc]

attribute [match_pattern] Expr.reassoc

def g_ffl (t : Nat) : Nat := match t with
  | (n+1) => match g_ffl n with
    | 0 => 0
    | m + 1 => match g_ffl (n - m) with
      | 0 => 0
      | m + 1 => g_ffl n
  | 0 => 0
decreasing_by all_goals sorry

attribute [simp] g_ffl

#check g_ffl.eq_1
#check g_ffl.eq_2

theorem ex3_ffl : g_ffl (n + 1) = match g_ffl n with
    | 0 => 0
    | m + 1 => match g_ffl (n - m) with
      | 0 => 0
      | m + 1 => g_ffl n := by
  conv => lhs; unfold g_ffl
