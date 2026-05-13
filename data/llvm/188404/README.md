# [MLIR][Vector][Fold] Assertion hasSameNumElementsOrSplat failed in DenseElementsAttr::get when folding vector.insert with out-of-bounds dynamic index

**Issue:** [https://github.com/llvm/llvm-project/issues/188404](https://github.com/llvm/llvm-project/issues/188404) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2026-03-25T03:44:13Z`

**Labels:** `crash`, `mlir:vector`

## Description

Related issue: #108360

**Description**

`mlir-opt --inline --cse` crashes with an assertion failure in `DenseElementsAttr::get` when folding a `vector.insert` op whose index is a negative (out-of-bounds) constant. The `foldDenseElementsAttrDestInsertOp` folder receives an index of `-1`, computes an invalid position within the destination vector's element array, and then attempts to construct a `DenseElementsAttr` with a mismatched number of elements, triggering the assertion.

**Reproducer**

```mlir
module {
  func.func @f() -> vector<2xf16> {
    %cst = arith.constant dense<0.0> : vector<2xf16>
    %idx = arith.constant -1 : index
    %val = arith.constant 2.5 : f16
    %0 = vector.insert %val, %cst [%idx] : f16 into vector<2xf16>
    return %0 : vector<2xf16>
  }
}
```

**Command**

```
mlir-opt --inline --cse reproduce.mlir
```

**Expected behavior**

The folder should validate that the index is within bounds before attempting to fold. When the index is out of bounds (negative or ≥ vector size), the folder should return failure rather than proceeding with an invalid array access. Alternatively, the verifier should reject `vector.insert` with a statically out-of-bounds index before folding is attempted.

**Actual behavior**

```
mlir-opt: mlir/lib/IR/BuiltinAttributes.cpp:872:
  static DenseElementsAttr mlir::DenseElementsAttr::get(ShapedType, ArrayRef<Attribute>):
  Assertion `hasSameNumElementsOrSplat(type, values)' failed.
Aborted (core dumped)
```

**Call chain**

```
--cse / --inline (triggers constant folding)
  → vector.insert fold
    → foldDenseElementsAttrDestInsertOp   (VectorOps.cpp:3796)
      → DenseElementsAttr::get            (BuiltinAttributes.cpp:872)
        ← assertion: hasSameNumElementsOrSplat failed
```

**Root cause**

(LLM Analysis, could be incorrect)
`foldDenseElementsAttrDestInsertOp` retrieves the flat linear index from the `vector.insert` position operand and uses it directly to index into the destination vector's element list. When the index is `-1` (or any negative value), the unsigned arithmetic wraps around to a very large position, causing the element replacement to produce a values array with the wrong number of elements. The fix should add a bounds check in `foldDenseElementsAttrDestInsertOp` — if the computed linear index is negative or exceeds the number of elements in the destination vector, return failure immediately.

**Environment**

- Tool: `mlir-opt`
- Passes: `--inline --cse`
- Affected file: `mlir/lib/Dialect/Vector/IR/VectorOps.cpp` (`foldDenseElementsAttrDestInsertOp` at line 3796)
- Crash site: `mlir/lib/IR/BuiltinAttributes.cpp:872`

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
