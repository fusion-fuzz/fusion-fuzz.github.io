# [MLIR][MemRef][Canonicalize] Assertion succeeded(MemRefType::verifyInvariants) in MemRefType::get when ReinterpretCastOpConstantFolder folds a reinterpret_cast with a negative constant size

**Issue:** [https://github.com/llvm/llvm-project/issues/188407](https://github.com/llvm/llvm-project/issues/188407) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2026-03-25T04:02:40Z`

**Labels:** `crash`, `mlir:memref`

## Description

Related issue: #61309

**Description**

`mlir-opt --canonicalize` crashes with an assertion failure in `MemRefType::get` when the `ReinterpretCastOpConstantFolder` pattern folds a `memref.reinterpret_cast` op whose size operand is a negative constant (e.g. `-1 : index`). The folder propagates the constant into the result `MemRefType`'s static shape, but `MemRefType::get` asserts that all static dimension sizes must be valid (non-negative), triggering the `invalid memref size` error and the subsequent assertion failure.

**Reproducer**

```mlir
module {
  func.func @f(%input: memref<2x3xf32>) -> memref<?x?xf32, strided<[?, ?], offset: ?>> {
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %sz = arith.constant -1 : index
    %output = memref.reinterpret_cast %input to
              offset: [%c0], sizes: [%c1, %sz], strides: [%sz, %c1]
              : memref<2x3xf32> to memref<?x?xf32, strided<[?, ?], offset: ?>>
    return %output : memref<?x?xf32, strided<[?, ?], offset: ?>>
  }
}
```

**Command**

```
mlir-opt --canonicalize reproduce.mlir
```

**Expected behavior**

`ReinterpretCastOpConstantFolder` should validate that all constant size operands are non-negative before attempting to construct a static `MemRefType`. When a constant size is negative, the folder should return failure rather than passing an invalid size to `MemRefType::get`. Alternatively, the verifier should reject `memref.reinterpret_cast` with statically known negative sizes before canonicalization is attempted.

**Actual behavior**

```
<unknown>:0: error: invalid memref size
mlir-opt: mlir/include/mlir/IR/StorageUniquerSupport.h:180:
  static ConcreteT mlir::detail::StorageUserBase<...>::get(...):
  Assertion `succeeded(ConcreteT::verifyInvariants(getDefaultDiagnosticEmitFn(ctx), args...))' failed.
Aborted (core dumped)
```

**Call chain**

```
--canonicalize
  → ReinterpretCastOpConstantFolder::matchAndRewrite   (MemRefOps.cpp:2294)
    → memref::ReinterpretCastOp::build
      → MemRefType::get(shape=[-1], ...)               (BuiltinTypes.cpp:667)
        → MemRefType::verifyInvariants                 ← "invalid memref size"
          → assertion failure
```

**Root cause**

(Generated, could be incorrect)
`ReinterpretCastOpConstantFolder` iterates over the size operands of `memref.reinterpret_cast`, and when it finds a constant integer value it replaces the dynamic size with that constant in the new static `MemRefType`. It does not check whether the constant is a valid memref dimension size (i.e. non-negative). When the constant is `-1`, it is passed directly to `MemRefType::get` as a static dimension size, which calls `MemRefType::verifyInvariants` and fails the assertion. The fix should add a non-negativity check in `ReinterpretCastOpConstantFolder` for each constant size operand before constructing the new type, returning failure if any size is negative.

**Environment**

- Tool: `mlir-opt`
- Pass: `--canonicalize` (also reproduces with `--inline --canonicalize`)
- Affected file: `mlir/lib/Dialect/MemRef/IR/MemRefOps.cpp` (`ReinterpretCastOpConstantFolder::matchAndRewrite` at line 2294)
- Crash site: `mlir/include/mlir/IR/StorageUniquerSupport.h:180`

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
