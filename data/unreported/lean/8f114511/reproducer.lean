inductive Term : Type
| const : Nat -> Term
| app   : List Term -> Term

namespace Term
instance : Inhabited Term := ⟨Term.const 0⟩
partial def hasToString : Term -> String | const n   => "CONST(" ++ toString n ++ ")" | app ts    => "APP"
instance : ToString Term := ⟨hasToString⟩
end Term

open Term

structure MyState : Type := (ts : List Term)
def emit (t : Term) : StateM MyState Unit := modify (λ ms => ⟨t::ms.ts⟩)

partial def foo : MyState -> Term -> Term -> List Term
| ms₀, t, u =>
  let stateT : StateM MyState Unit := do {

    match t with
    | const _  => pure ()
    | app _   => emit (const 1);

    match t, u with
    | app _,  app _   => emit (app [])
    | _, _ => pure () ;

    match t, u with
    | app _,  app _   => emit (app [])
    | _, _ => emit (const 2)

  } ;

  (stateT.run ⟨[]⟩).2.ts.reverse


#grind_lint mute Array.getElem_swap

/--
error: `Array.swap_swap` is not marked with the `@[grind]` attribute for theorem instantiation
-/
#guard_msgs in
#grind_lint mute Array.swap_swap

/-- error: `Array.getElem_swap` is already in the `#grind_lint` mute set -/
#guard_msgs in
#grind_lint mute Array.getElem_swap

#grind_lint skip Array.getElem_swap

/--
error: `Array.swap_swap` is not marked with the `@[grind]` attribute for theorem instantiation
-/
#guard_msgs in
#grind_lint skip Array.swap_swap


def main : IO Unit := IO.println $ foo ⟨[]⟩ (app []) (app [])

/-- error: `Array.getElem_swap` is already in the `#grind_lint` skip set -/
#guard_msgs in
#grind_lint skip Array.getElem_swap

#grind_lint inspect Array.range_succ

#grind_lint mute Array.append_assoc -- It is not used during E-matching by `#grind_lint check` and `#grind_lint inspect`

#grind_lint inspect Array.range_succ Array.range'_succ

-- These go slightly over 20, but seem reasonable.
#grind_lint skip Array.back_singleton
#grind_lint skip Array.count_singleton
#grind_lint skip Array.foldl_empty
#grind_lint skip Array.foldr_empty
#grind_lint skip Array.getElem_zero_filter
#grind_lint skip Array.getElem_zero_filterMap

#grind_lint check (min := 20) in Array

#grind_lint inspect Array.filterMap_some

#grind_lint check (min := 20) in module Init.Data.Array

/-! Test suffix skipping -/

#grind_lint skip suffix succ

/-- error: `succ` is already in the `#grind_lint` skip suffix set -/
#guard_msgs in
#grind_lint skip suffix succ

-- Now verify that theorems ending in `succ` are skipped in check
-- Note: The suffix skip should apply during check, but inspect bypasses it
-- Array.range'_succ should NOT appear in the output

#grind_lint check (min := 15) in Array
