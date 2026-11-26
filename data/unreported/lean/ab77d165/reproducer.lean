module

notation:50 a "**" b:50 => b * a * b
notation "~" a => a+a

namespace Foo
notation "~~" a => a+a
end Foo

syntax:60 term "+++" term:59 : term

syntax "<||" term "||>" : term


@[expose] public section -- TODO: remove after we fix congr_eq

def f (a : Option Nat) (h : a ≠ none) : Nat :=
 match a with
 | some a => a
 | none => by grind

def g (a : Option Nat) : Nat :=
  match h : a with
  | none => 1
  | some _ => f a (by grind) + 1

end --

macro_rules
| `($a +++ $b) => `($a + $b + $b)

macro_rules
| `(<|| $x ||>) => `($x +++ 1 ** 2)

#check <|| 2 ||>

#check <|| ~2 ||>

#check <|| ~~2 ||>

#check <|| <|| 3 ||> ||>

@[expose] public section -- TODO: remove after we fix congr_eq
example : g a > 0 := by
  unfold g
  grind
end --

@[expose] public section -- TODO: remove after we fix congr_eq

def f_ffl (a : Option Nat) (h : a ≠ none) : Nat :=
 match a with
 | some a => a
 | none => by grind

def g_ffl (a : Option Nat) : Nat :=
  match h : a with
  | none => 1
  | some _ => f_ffl f (by grind) + 1

example : g_ffl a > 0 := by
  unfold g_ffl
  grind
end --

#check @f
