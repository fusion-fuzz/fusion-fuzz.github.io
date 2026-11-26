mutual
def my_eq {A : Type _} (a b : A) : Prop := True
def bar : Nat → { _n : Nat // True }
  | 0 => ⟨0, trivial⟩
  | n + 1 =>
      let r := bar n
      ⟨r.1, r.2⟩
end
#check @bar.induct
