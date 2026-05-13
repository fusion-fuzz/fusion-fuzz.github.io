# [MLIR] Assertion "incorrect fold result type" in tosa.transpose folder when folding identity permutation on ranked input with unranked result type

**Issue:** [https://github.com/llvm/llvm-project/issues/187974](https://github.com/llvm/llvm-project/issues/187974) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2026-03-23T04:58:09Z`

**Labels:** `crash`, `mlir:tosa`

## Description

**Description**

`mlir-opt --sccp` crashes with an assertion failure in `checkFoldResultTypes` when processing a `tosa.transpose` op whose input is a ranked tensor, whose permutation is the identity, and whose declared result type is unranked (`tensor<*xi32>`). The `tosa.transpose` folder recognizes the identity permutation and folds the op by returning the input value directly. However, the input has type `tensor<3x2xi32>` while the declared result type is `tensor<*xi32>`. The fold result type does not match the op's declared result type, triggering the assertion.

**Reproducer**

```mlir
module {
  func.func @f(%arg0: tensor<3x2xi32>) -> tensor<*xi32> {
    %0 = tosa.transpose %arg0 {perms = array<i32: 0, 1>}: (tensor<3x2xi32>) -> tensor<*xi32>
    return %0 : tensor<*xi32>
  }
}
```

**Command**

```
mlir-opt --sccp reproduce.mlir
```

**Expected behavior**

`--sccp` either processes the file successfully or emits a diagnostic. The folder should not return a value whose type differs from the op's declared result type, or should bail out of folding when the types do not match.

**Actual behavior**

```
reproduce.mlir:3:10: error: 'tosa.transpose' op folder produced a value of incorrect type:
  'tensor<3x2xi32>', expected: 'tensor<*xi32>'
mlir-opt: mlir/lib/IR/Operation.cpp:621:
  void checkFoldResultTypes(Operation*, SmallVectorImpl<OpFoldResult>&):
  Assertion `false && "incorrect fold result type"' failed.
```

**Call chain**

```
SCCP::runOnOperation
  → DataFlowSolver::initializeAndRun
    → SparseConstantPropagation::visitOperation
      → Operation::fold
        → tosa.transpose folder  ← returns input directly (type mismatch)
          → checkFoldResultTypes ← assertion: fold result type != declared result type
```

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
