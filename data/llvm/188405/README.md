# [MLIR][Linalg][Canonicalize] Assertion getConstantIntValue(tile).value() == shape in getNewMixedTileSizes when FoldTensorCastUnPackOp folds a cast whose static tile size does not match the output dimension size

**Issue:** [https://github.com/llvm/llvm-project/issues/188405](https://github.com/llvm/llvm-project/issues/188405) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2026-03-25T03:49:34Z`

**Labels:** `mlir:linalg`, `crash`

## Description

**Description**

`mlir-opt --canonicalize --inline` crashes with an assertion failure in `getNewMixedTileSizes` when canonicalizing a `linalg.unpack` op that has a `tensor.cast` as its source and a tile size that, after inlining, becomes a compile-time constant that does not match the corresponding static output dimension size. `FoldTensorCastUnPackOp` fires and calls `getNewMixedTileSizes`, which asserts that the constant tile value must equal the static output shape dimension. When the tile size (256) differs from the output shape (7), the assertion fires.

This is related to but distinct from the `bad_optional_access` crash in the same function when the tile is not yet constant: both bugs share the same call site in `getNewMixedTileSizes` at `LinalgOps.cpp:5025`, with different preconditions. The underlying issue in both cases is that `FoldTensorCastUnPackOp` fires without sufficiently validating that the tile sizes are compatible with the output shape.

**Reproducer**

```mlir
module {
  func.func @get_tile() -> index {
    %c256 = arith.constant 256 : index
    return %c256 : index
  }

  func.func @f(%A: tensor<1x3x8x1xi32>) -> tensor<7x3xi32> {
    %tile_size = func.call @get_tile() : () -> index
    %empty = tensor.empty() : tensor<7x3xi32>
    %cast = tensor.cast %A : tensor<1x3x8x1xi32> to tensor<?x3x?x1xi32>
    %unpack = linalg.unpack %cast
      inner_dims_pos = [0, 1]
      inner_tiles = [%tile_size, 1]
      into %empty : tensor<?x3x?x1xi32> -> tensor<7x3xi32>
    return %unpack : tensor<7x3xi32>
  }
}
```

**Command**

```
mlir-opt --canonicalize --inline reproduce.mlir
```

**Expected behavior**

`FoldTensorCastUnPackOp` should bail out when a constant tile size does not match the corresponding static output dimension size, rather than asserting. The pattern should only fire when all constant tile sizes are consistent with the output shape, or `getNewMixedTileSizes` should return failure gracefully instead of asserting.

**Actual behavior**

```
mlir-opt: mlir/lib/Dialect/Linalg/IR/LinalgOps.cpp:5026:
  SmallVector<OpFoldResult> mlir::linalg::getNewMixedTileSizes(...):
  Assertion `getConstantIntValue(tile).value() == shape && "tile size and dim size don't match!"' failed.
Aborted (core dumped)
```

**Call chain**

```
--inline (propagates constant 256 from get_tile into f)
--canonicalize
  → FoldTensorCastUnPackOp::matchAndRewrite   (LinalgOps.cpp:6479)
    → getNewMixedTileSizes                    (LinalgOps.cpp:5025)
      → getConstantIntValue(tile).value()     ← returns 256
        → assert 256 == 7                     ← FAILS
```

**Root cause**

(LLM analysis, could be wrong)
After `--inline` propagates the constant `256` into `@f`, `--canonicalize` fires `FoldTensorCastUnPackOp` on the `linalg.unpack` whose source is a `tensor.cast`. The pattern calls `getNewMixedTileSizes` to compute updated tile sizes for the new static source type. Inside `getNewMixedTileSizes`, for each dimension where the tile is a constant integer, it asserts that this constant equals the corresponding static shape dimension of the output type. Here the tile is `256` but the output dimension is `7`, so the assertion fires.

The fix should be added in `FoldTensorCastUnPackOp::matchAndRewrite` — before calling `getNewMixedTileSizes`, the pattern should verify that every constant tile size is consistent with the corresponding static output dimension, and return failure if any mismatch is detected. This would prevent the pattern from firing in an invalid configuration, making both this crash and the related `bad_optional_access` crash safe.

**Environment**

- Tool: `mlir-opt`
- Passes: `--canonicalize --inline`
- Affected file: `mlir/lib/Dialect/Linalg/IR/LinalgOps.cpp` (lines 5025–5026 and 6479)

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
