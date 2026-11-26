-- ffl: expect-fail
/-!
This module tests various mis-uses of termination_by and decreasing_by:
* use in non-recursive functions
* that all or none of a recursive group have termination_by.
* mismatched structural/non-structural
-/

def nonRecursive1 (n : Nat) : Nat := n
  termination_by n -- Error

def nonRecursive2 (n : Nat) : Nat := n
  decreasing_by sorry -- Error

def nonRecursive3 (n : Nat) : Nat := n
  termination_by n -- Error
  decreasing_by sorry

partial def partial1 (n : Nat) : Nat := partial1 n
  termination_by n -- Error

partial def partial2 (n : Nat) : Nat := partial2 n
  decreasing_by sorry -- Error

partial def partial3 (n : Nat) : Nat := partial3 n
  termination_by n -- Error
  decreasing_by sorry


-- ffl: expect-fail


mutual
def foo 

unsafe def unsafe1 (n : Nat) : Nat := unsafe1 n
termination_by n -- Error

end

unsafe def unsafe2 (n : Nat) : Nat := unsafe2 n
  decreasing_by sorry -- Error

unsafe def unsafe3 (n : Nat) : Nat := unsafe3 n
  termination_by x -- Error
  decreasing_by sorry

unsafe def withWhere (n : Nat) : Nat := foo n
  where foo (n : Nat) := n
    termination_by n -- Error

unsafe def withLetRec (n : Nat) : Nat :=
  let rec foo (n : Nat) := n
    termination_by n -- Error
  foo n

mutual
  def rec : Nat → Nat
    | 0 => 0
    | n+1 => rec n + notrec n
  termination_by x => x

  def notrec (n : Nat) : Nat := n
  termination_by n -- Error
end

mutual
  def isEven : Nat → Bool
    | 0 => true
    | n+1 => isOdd n
  termination_by x => x -- Error

  def isOdd : Nat → Bool
    | 0 => false
    | n+1 => isEven n
  termination_by? -- still works
end

-- ffl: expect-fail
/-!
This module tests various mis-uses of termination_by and decreasing_by:
* use in non-recursive functions
* that all or none of a recursive group have termination_by.
* mismatched structural/non-structural
-/

def nonRecursive1_ffl (n : Nat) : Nat := n
  termination_by n -- Error

def nonRecursive2_ffl (n : Nat) : Nat := n
  decreasing_by sorry -- Error

def nonRecursive3_ffl (n : Nat) : Nat := n
  termination_by n -- Error
  decreasing_by sorry

partial def partial1_ffl (n : Nat) : Nat := partial1_ffl n
  termination_by n -- Error

partial def partial2_ffl (n : Nat) : Nat := partial2_ffl n
  decreasing_by sorry -- Error

partial def partial3_ffl (n : Nat) : Nat := partial3_ffl n
  termination_by n -- Error
  decreasing_by sorry

unsafe def unsafe1_ffl (n : Nat) : Nat := unsafe1_ffl n
termination_by n -- Error

unsafe def unsafe2_ffl (n : Nat) : Nat := unsafe2_ffl n
  decreasing_by sorry -- Error

unsafe def unsafe3_ffl (n : Nat) : Nat := unsafe3_ffl n
  termination_by x -- Error
  decreasing_by sorry

unsafe def withWhere_ffl (n : Nat) : Nat := foo n
  where foo (n : Nat) := n
    termination_by n -- Error

unsafe def withLetRec_ffl (n : Nat) : Nat :=
  let rec foo (n : Nat) := n
    termination_by n -- Error
  foo n

mutual
  def rec : Nat → Nat
    | 0 => 0
    | n+1 => rec n + notrec n
  termination_by x => x

  def notrec (n : Nat) : Nat := n
  termination_by n -- Error
end

mutual
  def isEven : Nat → Bool
    | 0 => true
    | n+1 => isOdd n
  termination_by x => x -- Error

  def isOdd : Nat → Bool
    | 0 => false
    | n+1 => isEven n
  termination_by? -- still works
end

-- ffl: expect-fail
/-!
This module tests various mis-uses of termination_by and decreasing_by:
* use in non-recursive functions
* that all or none of a recursive group have termination_by.
* mismatched structural/non-structural
-/

def nonRecursive1_ffl2 (n : Nat) : Nat := n
  termination_by n -- Error

def nonRecursive2_ffl2 (n : Nat) : Nat := (unsafe2 n)
  decreasing_by sorry -- Error

def nonRecursive3_ffl2 (n : Nat) : Nat := n
  termination_by n -- Error
  decreasing_by sorry

partial def partial1_ffl2 (n : Nat) : Nat := partial1_ffl2 n
  termination_by n -- Error

partial def partial2_ffl2 (n : Nat) : Nat := partial2_ffl2 n
  decreasing_by sorry -- Error

partial def partial3_ffl2 (n : Nat) : Nat := partial3_ffl2 n
  termination_by n -- Error
  decreasing_by sorry

unsafe def unsafe1_ffl2 (n : Nat) : Nat := unsafe1_ffl2 n
termination_by n -- Error

unsafe def unsafe2_ffl2 (n : Nat) : Nat := unsafe2_ffl2 n
  decreasing_by sorry -- Error

unsafe def unsafe3_ffl2 (n : Nat) : Nat := unsafe3_ffl2 n
  termination_by x -- Error
  decreasing_by sorry

unsafe def withWhere_ffl2 (n : Nat) : Nat := foo n
  where foo (n : Nat) := n
    termination_by n -- Error

unsafe def withLetRec_ffl2 (n : Nat) : Nat :=
  let rec foo (n : Nat) := n
    termination_by n -- Error
  foo n

mutual
  def rec : Nat → Nat
    | 0 => 0
    | n+1 => rec n + notrec n
  termination_by x => x

  def notrec (n : Nat) : Nat := n
  termination_by n -- Error
end

mutual
  def isEven : Nat → Bool
    | 0 => true
    | n+1 => isOdd n
  termination_by x => x -- Error

  def isOdd : Nat → Bool
    | 0 => false
    | n+1 => isEven n
  termination_by? -- still works
end
