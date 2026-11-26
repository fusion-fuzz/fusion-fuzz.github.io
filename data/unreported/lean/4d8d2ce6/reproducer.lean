inductive Sign_ffl where
  | zero | neg | pos
  deriving DecidableEq

instance : OfNat Sign_ffl (nat_lit 0) where
  ofNat := .zero

instance : OfNat Sign_ffl (nat_lit 1) where
  ofNat := .pos

instance : Neg Sign_ffl where
  neg | .zero => .zero
      | .pos  => .neg
      | .neg  => .pos

namespace Sign_ffl

@[simp] theorem zero_eq_ffl : zero = 0 := rfl
@[simp] theorem neg_eq_ffl : neg  = -1 := rfl
@[simp] theorem pos_eq_ffl : pos = 1 := rfl

def mul_ffl : Sign_ffl → Sign_ffl → Sign_ffl
  | neg,  neg  => pos
  | neg,  pos  => neg
  | neg,  zero => zero
  | zero, _    => zero
  | pos,  s    => s

instance : Mul Sign_ffl where
  mul_ffl a b := Sign_ffl.mul_ffl a b

def le_ffl : Sign_ffl → Sign_ffl → Bool
  | neg,  _    => true
  | zero, zero => true
  | _,    pos  => true
  | _,    _    => false

instance : LE Sign_ffl where
  le_ffl a b := Sign_ffl.le_ffl a b

instance : DecidableRel (· ≤ · : Sign_ffl → Sign_ffl → Prop) :=
  fun a b => inferInstanceAs (Decidable (le_ffl a b = true))

theorem neg_bot_ffl {s : Sign_ffl} : s ≤ -1 → s = -1 := by
  cases s <;> decide

theorem pos_top_ffl {s : Sign_ffl} : 1 ≤ s → s = 1 := by
  cases s <;> decide

end Sign_ffl

mutual
inductive Tree (α : Type u) where
  | node : TreeList α → Tree α
  | leaf : α → Tree α

inductive TreeList (α : Type u) where
  | nil : TreeList α
  | cons : Tree α → TreeList α → TreeList α
end

def Tree.size : Tree α → Nat
  | Tree.node l =>
    -- see "TODO: linarith" in Init.WFTactics
    have : sizeOf l < 1 + sizeOf l := by
      rw [Nat.add_comm]
      apply Nat.lt_succ_self
    sizeList l
  | Tree.leaf _ => 1
-- use automatically synthesized size function, which is not quite the number of leaves
termination_by t => sizeOf t
where
  sizeList : TreeList α → Nat
  | TreeList.nil => 0
  | TreeList.cons t l =>
    have : sizeOf t < 1 + sizeOf t + sizeOf l := by
      rw [Nat.add_comm 1, Nat.add_assoc, Nat.add_comm 1, ← Nat.add_assoc]
      apply Nat.lt_succ_of_le
      apply Nat.le_add_right
    have : sizeOf l < 1 + sizeOf t + sizeOf l := by
      rw [Nat.add_comm 1, Nat.add_assoc, Nat.add_comm 1, ← Nat.add_assoc]
      apply Nat.lt_succ_of_le
      apply Nat.le_add_left
    t.size + sizeList l
  termination_by l => sizeOf l

inductive Sign where
  | zero | neg | pos
  deriving DecidableEq



instance : OfNat Sign (nat_lit 0) where
  ofNat := .zero

instance : OfNat Sign (nat_lit 1) where
  ofNat := .pos

instance : Neg Sign where
  neg | .zero => .zero
      | .pos  => .neg
      | .neg  => .pos

namespace Sign

@[simp] theorem zero_eq : zero = 0 := rfl
@[simp] theorem neg_eq : neg  = -1 := rfl
@[simp] theorem pos_eq : pos = 1 := rfl

def mul : Sign → Sign → Sign
  | neg,  neg  => pos
  | neg,  pos  => neg
  | neg,  zero => zero
  | zero, _    => zero
  | pos,  s    => s

instance : Mul Sign where
  mul a b := Sign.mul a b

def le : Sign → Sign → Bool
  | neg,  _    => true
  | zero, zero => true
  | _,    pos  => true
  | _,    _    => false

instance : LE Sign where
  le a b := Sign.le a b

instance : DecidableRel (· ≤ · : Sign → Sign → Prop) :=
  fun a b => inferInstanceAs (Decidable (le a b = true))

theorem neg_bot {s : Sign} : s ≤ -1 → s = -1 := by
  cases s <;> decide

theorem pos_top {s : Sign} : 1 ≤ s → s = 1 := by
  cases s <;> decide

end Sign

inductive FflMix47524 where
  | host : (TreeList Nat) → FflMix47524
  | donor : Sign_ffl → FflMix47524
  | both : (TreeList Nat) → Sign_ffl → List FflMix47524 → FflMix47524
  deriving Repr
