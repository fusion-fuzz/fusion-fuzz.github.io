# [MLIR][SCCP][OpenACC] Assertion mightHaveTerminator() in Block::getTerminator when DeadCodeAnalysis::initializeRecursively walks into acc.kernel_environment containing acc.compute_region

**Issue:** [https://github.com/llvm/llvm-project/issues/188408](https://github.com/llvm/llvm-project/issues/188408) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2026-03-25T04:14:43Z`

**Labels:** `crash`, `mlir:dataflow`

## Description

Related issue: #159650

**Description**

`mlir-opt --sccp` crashes with an assertion failure in `Block::getTerminator()` when `DeadCodeAnalysis::initializeRecursively` walks into a function containing an `acc.kernel_environment` op that itself contains an `acc.compute_region` op. The `isRegionOrCallableReturn` helper calls `block->getTerminator()` on a block that `mightHaveTerminator()` returns true for but that has no terminator op, triggering the assertion.

**Reproducer**

```mlir
module {
  func.func @fusion_bridge() -> index {
    %c = arith.constant 128 : index
    return %c : index
  }

  func.func @f(%data: memref<8xi32>) {
    acc.kernel_environment {
      acc.compute_region {
        acc.yield
      } {origin = "acc.parallel"}
    }
    return
  }

  %fusion_tmp = func.call @fusion_bridge() : () -> index
}
```

**Command**

```
mlir-opt --sccp --symbol-dce --cse --inline --canonicalize reproduce.mlir
```

**Expected behavior**

`--sccp` should process the file successfully or emit a diagnostic. `DeadCodeAnalysis` should not call `getTerminator()` on a block without first verifying it has a terminator, or `isRegionOrCallableReturn` should guard the `getTerminator()` call.

**Actual behavior**

```
mlir-opt: mlir/lib/IR/Block.cpp:250:
  Operation *mlir::Block::getTerminator():
  Assertion `mightHaveTerminator()' failed.
Aborted (core dumped)
```

**Call chain**

```
--sccp
  → DataFlowSolver::initializeAndRun
    → DeadCodeAnalysis::initialize
      → DeadCodeAnalysis::initializeRecursively
        → isRegionOrCallableReturn            (DeadCodeAnalysis.cpp:252)
          → Block::getTerminator()            (Block.cpp:250)
            ← assertion: mightHaveTerminator() failed
```

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
