set_option deriving.beq.linear_construction_threshold 1000

inductive L (α : Type) where
  | nil  : L α
  | cons : α → L α → L α
deriving BEq, Ord

#print sig instBEqL.beq_spec_2

-- Ord does not support recursive types yet:

/-- error: Unknown constant `instOrdL.compare_spec_2` -/
#guard_msgs in
#print sig instOrdL.compare_spec_2

inductive O (α : Type u) where
  | none
  | some : α → O α
deriving BEq, Ord

#print sig instBEqO.beq_spec_2
#print sig instOrdO.compare_spec_1
#print sig instOrdO.compare_spec_2
#print sig instOrdO.compare_spec_4

-- Mutual inductive (not supported yet, but should be)

mutual
inductive Tree (α : Type) where
  | node : TreeList α → Tree α
  deriving BEq
inductive TreeList (α : Type) where
  | nil : TreeList α
  | cons : Tree α → TreeList α → TreeList α
  deriving BEq
end


set_option deriving.beq.linear_construction_threshold 1000

inductive L_ffl (α : Type) where
  | nil  : L_ffl α
  | cons : α → L_ffl α → L_ffl α
deriving BEq, Ord

#print sig instBEqL.beq_spec_2

-- Ord does not support recursive types yet:

/-- error: Unknown constant `instOrdL.compare_spec_2` -/
#guard_msgs in
#print sig instOrdL.compare_spec_2

inductive O_ffl (α : Type u) where
  | none
  | some : α → O_ffl α
deriving BEq, Ord

#print sig instBEqO.beq_spec_2
#print sig instOrdO.compare_spec_1
#print sig instOrdO.compare_spec_2
#print sig instOrdO.compare_spec_4

-- Mutual inductive (not supported yet, but should be)

mutual
inductive Tree_ffl (α : Type) where
  | node : TreeList_ffl α → Tree_ffl α
  deriving BEq
inductive TreeList_ffl (α : Type) where
  | nil : TreeList_ffl α
  | cons : Tree_ffl α → TreeList_ffl α → TreeList_ffl α
  deriving BEq
end

/-- error: Unknown constant `instBEqTree.beq_spec_1` -/
#guard_msgs in
#print sig instBEqTree.beq_spec_1

/-- error: Unknown constant `instBEqTree.beq_spec_1` -/
#guard_msgs in
#print sig instBEqTree.beq_spec_1

example (xs : List Nat) (x : Nat)
    (i : Nat) (hi : i < (xs ++ [x]).length)
    (h : 1 ≤ (List.drop O xs).sum + x) :
    1 ≤ (List.drop i (List.take (xs ++ [x]).length (xs ++ [x]))).sum := by
  grind
