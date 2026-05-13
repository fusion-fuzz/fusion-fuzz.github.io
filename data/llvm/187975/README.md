# [MLIR][Linalg][Canonicalize] Crash in FoldTensorCastUnPackOp::matchAndRewrite via getNewMixedTileSizes when tile size is dynamic (bad_optional_access on nullopt from getConstantIntValue)

**Issue:** [https://github.com/llvm/llvm-project/issues/187975](https://github.com/llvm/llvm-project/issues/187975) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2026-03-23T05:06:15Z`

**Labels:** `mlir:linalg`, `crash`

## Description

**Description**

`mlir-opt --canonicalize --inline` crashes with `std::bad_optional_access` in `getNewMixedTileSizes` when canonicalizing a `linalg.unpack` op that has a `tensor.cast` as its source and a dynamic (non-constant) tile size. The `FoldTensorCastUnPackOp` pattern fires and calls `getNewMixedTileSizes`, which calls `getConstantIntValue(tile).value()` unconditionally. When the tile size is a dynamic `index` SSA value rather than a compile-time constant, `getConstantIntValue` returns `std::nullopt` and `.value()` aborts.

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

`FoldTensorCastUnPackOp` should bail out (return failure) when a tile size is not a compile-time constant, rather than unconditionally calling `.value()` on the result of `getConstantIntValue`. Alternatively it should only fire when all tile sizes are statically known.

**Actual behavior**

```
mlir-opt: optional:1013: std::optional<long>::value() &&: Assertion `this->_M_is_engaged()' failed.
Aborted (core dumped)
```

The crash is in `getNewMixedTileSizes` at `LinalgOps.cpp:5025`, called from `FoldTensorCastUnPackOp::matchAndRewrite` at `LinalgOps.cpp:6479`.

**Call chain**

```
--canonicalize (runs after --inline propagates call)
  → FoldTensorCastUnPackOp::matchAndRewrite   (LinalgOps.cpp:6479)
    → getNewMixedTileSizes                    (LinalgOps.cpp:5025)
      → getConstantIntValue(tile)             → nullopt (tile is dynamic)
        → optional::value()                   ← abort: bad_optional_access
```

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
