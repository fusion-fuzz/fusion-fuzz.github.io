module
public meta import Lean.Elab.Command

axiom n : Type → Type
section
local notation "ℕ" x => n x
end
#check n Nat -- should *not* be `ℕ Nat : Type`

-- Tests that `wrapInstance` auxiliary definitions work correctly
-- when used inside a `meta` section, for both `inferInstanceAs` and `deriving`.



public meta section

namespace Test

open Lean

-- `@[expose]` forces `wrapInstance` to create aux wrapper definitions,
-- which is where the meta marking matters.
@[expose] def Foo := Unit
deriving Inhabited

@[expose] def Bar := Name
deriving Inhabited

@[expose] def Baz := List Nat
instance : EmptyCollection n := inferInstanceAs (EmptyCollection (List Nat))

end Test
end

#print axioms n


-- Tests that `wrapInstance` auxiliary definitions work correctly
-- when used inside a `meta` section, for both `inferInstanceAs` and `deriving`.



public meta section

namespace Test

open Lean

-- `@[expose]` forces `wrapInstance` to create aux wrapper definitions,
-- which is where the meta marking matters.
@[expose] def Foo_ffl2 := Unit
deriving Inhabited

@[expose] def Bar_ffl2 := Name
deriving Inhabited

end Test
end

attribute [always_inline] Test.Foo

-- Tests that `wrapInstance` auxiliary definitions work correctly
-- when used inside a `meta` section, for both `inferInstanceAs` and `deriving`.



public meta section

namespace Test

open Lean

-- `@[expose]` forces `wrapInstance` to create aux wrapper definitions,
-- which is where the meta marking matters.
@[expose] def Foo_ffl := Unit
deriving Inhabited

@[expose] def Bar_ffl := Name
deriving Inhabited

@[expose] def Baz_ffl := List Nat
instance : EmptyCollection Baz_ffl := inferInstanceAs (EmptyCollection (List Nat))

end Test

public meta section
namespace Test
open Lean

-- `@[expose]` forces `wrapInstance` to create aux wrapper definitions,
-- which is where the meta marking matters.
@[expose] def Baz_ffl2 := List Nat
instance : EmptyCollection Baz_ffl2 := inferInstanceAs (EmptyCollection (List Nat))

end Test
