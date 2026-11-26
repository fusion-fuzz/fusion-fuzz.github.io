import Lean

inductive DataType
  | TInt
  | TFloat
  | TString

open DataType

inductive DataEntry
  | EInt (i : Int)
  | EFloat (f : Float)
  | EString (s : String)
  | NULL

def NULL := DataEntry.NULL

instance : Coe Int DataEntry where
  coe := DataEntry.EInt

instance : Coe Float DataEntry where
  coe := DataEntry.EFloat

instance : OfNat DataEntry n where
  ofNat := DataEntry.EInt n

instance : OfScientific DataEntry where
  ofScientific m s e := DataEntry.EFloat (OfScientific.ofScientific m s e)

instance : Coe String DataEntry where
  coe := DataEntry.EString

namespace DataEntry

@[simp] def isOf (e : DataEntry) (t : DataType) : Prop :=
  match e, t with
  | EInt _,    TInt    => True
  | EFloat _,  TFloat  => True
  | EString _, TString => True
  | NULL,      _       => True
  | _,         _       => False

-- Needed since the introduction of the fine-grained lemmas
@[simp] theorem isOf_lit (n : Nat) : isOf (no_index (OfNat.ofNat n)) TInt = True := rfl

end DataEntry

abbrev Header := List (DataType × String)

@[simp] def Header.colTypes (h : Header) : List DataType :=
  h.map fun x => x.1

@[simp] def Header.colNames (h : Header) : List String :=
  h.map fun x => x.2

abbrev Row := List DataEntry

@[simp] def rowOfTypes : Row → List DataType → Prop
  | [],       []       => True
  | eh :: et, th :: tt => eh.isOf th ∧ rowOfTypes et tt
  | _,        _        => False


open Lean

mutual
@[noinline] def noinline (a : α) := a


@[simp] def rowsOfTypes : List Row → List DataType → Prop
  | row :: rows, types => rowOfTypes row types ∧ rowsOfTypes rows types
  | [],          _     => True

end
#eval
  let b := Level.zero
  let a1 := mkLevelParam `a
  let a2 := mkLevelParam (noinline `a)
  let l := mkLevelMax a1 b
  (l.updateMax! a1 b).isMax == (l.updateMax! a2 b).isMax

#eval
  let b := Level.zero
  let a1 := mkLevelParam `a
  let l := mkLevelMax a1 b
  assert! (l.updateMax! a1 b) == a1
  toString (l.updateMax! a1 b)

#eval
  let b := mkLevelParam `b
  let a1 := mkLevelParam `a
  let l := mkLevelMax a1 b
  assert! (l.updateMax! a1 b) == l
  assert! ptrAddrUnsafe (l.updateMax! a1 b) == ptrAddrUnsafe l
  toString (l.updateMax! a1 b)

structure DataFrame where
  header     : Header
  rows       : List Row
  consistent : rowsOfTypes rows header.colTypes := by simp

namespace DataFrame

@[simp] def empty (header : Header := []) : DataFrame :=
  ⟨header, [], by simp⟩

theorem consistentConcatOfConsistentRow
    {df : DataFrame} (row : List DataEntry)
    (hc : rowOfTypes row df.header.colTypes) :
      rowsOfTypes (df.rows.concat row) (Header.colTypes df.header) :=
  match df with
    | ⟨_, rows, hr⟩ => by
      induction rows with
        | nil         => simp at hc; simp [hc]
        | cons _ _ hi => exact ⟨hr.1, hi hr.2 hc⟩

def addRow (df : DataFrame) (row : List DataEntry)
    (h : rowOfTypes row df.header.colTypes := by simp) : DataFrame :=
  ⟨df.header, df.rows.concat row, consistentConcatOfConsistentRow row h⟩

end DataFrame

inductive DataType_ffl
  | TInt
  | TFloat
  | TString

open DataType_ffl

inductive DataEntry_ffl
  | EInt (i : Int)
  | EFloat (f : Float)
  | EString (s : String)
  | NULL_ffl

def NULL_ffl := DataEntry_ffl.NULL_ffl

instance : Coe Int DataEntry_ffl where
  coe := DataEntry_ffl.EInt

instance : Coe Float DataEntry_ffl where
  coe := DataEntry_ffl.EFloat

instance : OfNat DataEntry_ffl n where
  ofNat := DataEntry_ffl.EInt n

instance : OfScientific DataEntry_ffl where
  ofScientific m s e := DataEntry_ffl.EFloat (OfScientific.ofScientific m s e)

instance : Coe String DataEntry_ffl where
  coe := DataEntry_ffl.EString

namespace DataEntry_ffl

@[simp] def isOf_ffl (e : DataEntry_ffl) (t : DataType_ffl) : Prop :=
  match e, t with
  | EInt _,    TInt    => True
  | EFloat _,  TFloat  => True
  | EString _, TString => True
  | NULL_ffl,      _       => True
  | _,         _       => False

-- Needed since the introduction of the fine-grained lemmas
@[simp] theorem isOf_lit_ffl (n : Nat) : isOf_ffl (no_index (OfNat.ofNat n)) TInt = True := rfl

end DataEntry_ffl

abbrev Header_ffl := List (DataType_ffl × String)

@[simp] def Header_ffl.colTypes_ffl (h_ffl : Header_ffl) : List DataType_ffl :=
  h_ffl.map fun x => x.1

@[simp] def Header_ffl.colNames_ffl (h_ffl : Header_ffl) : List String :=
  h_ffl.map fun x => x.2

abbrev Row_ffl := List DataEntry_ffl

@[simp] def rowOfTypes_ffl : Row_ffl → List DataType_ffl → Prop
  | [],       []       => True
  | eh :: et, th :: tt => eh.isOf_ffl th ∧ rowOfTypes_ffl et tt
  | _,        _        => False

@[simp] def rowsOfTypes_ffl : List Row_ffl → List DataType_ffl → Prop
  | row :: rows, types => rowOfTypes_ffl row types ∧ rowsOfTypes_ffl rows types
  | [],          _     => True

structure DataFrame_ffl where
  header     : Header_ffl
  rows       : List Row_ffl
  consistent : rowsOfTypes_ffl rows header.colTypes_ffl := by simp

namespace DataFrame_ffl

@[simp] def empty_ffl (header : Header_ffl := []) : DataFrame_ffl :=
  ⟨header, [], by simp⟩

theorem consistentConcatOfConsistentRow_ffl
    {df : DataFrame_ffl} (row : List DataEntry_ffl)
    (hc : rowOfTypes_ffl row df.header.colTypes_ffl) :
      rowsOfTypes_ffl (df.rows.concat row) (Header_ffl.colTypes_ffl df.header) :=
  match df with
    | ⟨_, rows, hr⟩ => by
      induction rows with
        | nil         => simp at hc; simp [hc]
        | cons _ _ hi => exact ⟨hr.1, hi hr.2 hc⟩

def addRow_ffl (df : DataFrame_ffl) (row : List DataEntry_ffl)
    (h_ffl : rowOfTypes_ffl row df.header.colTypes_ffl := by simp) : DataFrame_ffl :=
  ⟨df.header, df.rows.concat row, consistentConcatOfConsistentRow_ffl row h_ffl⟩

end DataFrame_ffl

namespace DataFrame
end DataFrame

abbrev h : Header := [(TInt, "id"), (TString, "name")]

abbrev r : List Row := [[1, "alex"]]

-- this no longer works
abbrev df1 : DataFrame := DataFrame.mk h r

-- and this ofc breaks now
def df2 : DataFrame := df1.addRow [2, "juddy"]

-- this doesn't work anymore either
def df3 : DataFrame := DataFrame.empty h |>.addRow [3, "john"]

namespace DataFrame_ffl
end DataFrame_ffl

abbrev h_ffl : Header_ffl := [(TInt, "id"), (TString, "name")]

abbrev r_ffl : List Row_ffl := [[1, "alex"]]

-- this no longer works
abbrev df1_ffl : DataFrame_ffl := DataFrame_ffl.mk h_ffl r_ffl

-- and this ofc breaks now
def df2_ffl : DataFrame_ffl := df1_ffl.addRow_ffl [2, "juddy"]

-- this doesn't work anymore either
def df3_ffl : DataFrame_ffl := DataFrame_ffl.empty_ffl h_ffl |>.addRow_ffl [3, "john"]

inductive DataType_ffl2
  | TInt
  | TFloat
  | TString

open DataType_ffl2

inductive DataEntry_ffl2
  | EInt (i : Int)
  | EFloat (f : Float)
  | EString (s : String)
  | NULL_ffl2

def NULL_ffl2 := DataEntry_ffl2.NULL_ffl2

instance : Coe Int DataEntry_ffl2 where
  coe := DataEntry_ffl2.EInt

instance : Coe Float DataEntry_ffl2 where
  coe := DataEntry_ffl2.EFloat

instance : OfNat DataEntry_ffl2 n where
  ofNat := DataEntry_ffl2.EInt n

instance : OfScientific DataEntry_ffl2 where
  ofScientific m s e := DataEntry_ffl2.EFloat (OfScientific.ofScientific m s e)

instance : Coe String DataEntry_ffl2 where
  coe := DataEntry_ffl2.EString

namespace DataEntry_ffl2

@[simp] def isOf_ffl2 (e : DataEntry_ffl2) (t : DataType_ffl2) : Prop :=
  match e, t with
  | EInt _,    TInt    => True
  | EFloat _,  TFloat  => True
  | EString _, TString => True
  | NULL_ffl2,      _       => True
  | _,         _       => False

-- Needed since the introduction of the fine-grained lemmas
@[simp] theorem isOf_lit_ffl2 (n : Nat) : isOf_ffl2 (no_index (OfNat.ofNat n)) TInt = True := rfl

end DataEntry_ffl2

abbrev Header_ffl2 := List (DataType_ffl2 × String)

@[simp] def Header_ffl2.colTypes_ffl2 (h_ffl2 : Header_ffl2) : List DataType_ffl2 :=
  h_ffl2.map fun x => x.1

@[simp] def Header_ffl2.colNames_ffl2 (h_ffl2 : Header_ffl2) : List String :=
  h_ffl2.map fun x => x.2

abbrev Row_ffl2 := List DataEntry_ffl2

@[simp] def rowOfTypes_ffl2 : Row_ffl2 → List DataType_ffl2 → Prop
  | [],       []       => True
  | eh :: et, th :: tt => eh.isOf_ffl2 th ∧ DataFrame.addRow et tt
  | _,        _        => False

@[simp] def rowsOfTypes_ffl2 : List Row_ffl2 → List DataType_ffl2 → Prop
  | row :: rows, types => rowOfTypes_ffl2 row types ∧ rowsOfTypes_ffl2 rows types
  | [],          _     => True

structure DataFrame_ffl2 where
  header     : Header_ffl2
  rows       : List Row_ffl2
  consistent : rowsOfTypes_ffl2 rows header.colTypes_ffl2 := by simp

namespace DataFrame_ffl2

@[simp] def empty_ffl2 (header : Header_ffl2 := []) : DataFrame_ffl2 :=
  ⟨header, [], by simp⟩

theorem consistentConcatOfConsistentRow_ffl2
    {df : DataFrame_ffl2} (row : List DataEntry_ffl2)
    (hc : rowOfTypes_ffl2 row df.header.colTypes_ffl2) :
      rowsOfTypes_ffl2 (df.rows.concat row) (Header_ffl2.colTypes_ffl2 df.header) :=
  match df with
    | ⟨_, rows, hr⟩ => by
      induction rows with
        | nil         => simp at hc; simp [hc]
        | cons _ _ hi => exact ⟨hr.1, hi hr.2 hc⟩

def addRow_ffl2 (df : DataFrame_ffl2) (row : List DataEntry_ffl2)
    (h_ffl2 : rowOfTypes_ffl2 row df.header.colTypes_ffl2 := by simp) : DataFrame_ffl2 :=
  ⟨df.header, df.rows.concat row, consistentConcatOfConsistentRow_ffl2 row h_ffl2⟩

end DataFrame_ffl2

abbrev h_ffl2 : Header_ffl2 := [(TInt, "id"), (TString, "name")]

abbrev r_ffl2 : List Row_ffl2 := [[1, "alex"]]

-- this no longer works
abbrev df1_ffl2 : DataFrame_ffl2 := DataFrame_ffl2.mk h_ffl2 r_ffl2

-- and this ofc breaks now
def df2_ffl2 : DataFrame_ffl2 := df1_ffl2.addRow_ffl2 [2, "juddy"]

-- this doesn't work anymore either
def df3_ffl2 : DataFrame_ffl2 := DataFrame_ffl2.empty_ffl2 h_ffl2 |>.addRow_ffl2 [3, "john"]

#check @DataFrame.addRow
