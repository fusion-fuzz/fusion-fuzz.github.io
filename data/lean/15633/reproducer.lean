import Std
open Std
def frequencies (xs : List Nat) : TreeMap Nat Nat (fun a b => compare b a) :=
  xs.foldl (init := ∅) (fun freq x => freq.alter x (fun | none => some 1 | some n => some (n+1)))
def search (xs : List Nat) : Int :=
  let fr := frequencies xs
  let kv := fr.iter |>.map (fun (k, _) => k) |>.first?
  kv.getD (-1)
example : search [3, 2] = 3 := by cbv
