# [MLIR] Assertion !NodePtr->isKnownSentinel() in DeadCodeAnalysis::visitRegionBranchEdges when processing acc.serial with empty region

**Issue:** [https://github.com/llvm/llvm-project/issues/187972](https://github.com/llvm/llvm-project/issues/187972) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2026-03-23T04:48:30Z`

**Labels:** `crash`, `mlir:dataflow`

## Description

Related: #132160

**Description**

`mlir-opt --sccp` crashes with an assertion failure in `llvm::ilist_iterator::operator*()` when processing a function containing an `acc.serial` op with an empty region body. The `DeadCodeAnalysis` pass, invoked by SCCP, calls `getProgramPointBefore(Block*)` on a block pointer obtained by iterating over the regions of `acc.serial`. When a region has no blocks, the iterator is a sentinel, and dereferencing it triggers the assertion.

**Reproducer**

```mlir
module {
  func.func @f() {
    acc.serial {
    }
    return
  }
}
```

**Command**

```
mlir-opt --sccp reproduce.mlir
```

**Expected behavior**

`--sccp` either processes the file successfully or emits a diagnostic. It should not crash when encountering an `acc.serial` op whose region has no blocks.

**Actual behavior**

```
mlir-opt: llvm/include/llvm/ADT/ilist_iterator.h:168:
  reference llvm::ilist_iterator<...>::operator*() const:
  Assertion `!NodePtr->isKnownSentinel()' failed.
```

**Call chain:**

```
SCCP::runOnOperation
  → DataFlowSolver::initializeAndRun
    → DeadCodeAnalysis::initialize
      → DeadCodeAnalysis::initializeRecursively
        → DeadCodeAnalysis::visitRegionBranchOperation
          → DeadCodeAnalysis::visitRegionBranchEdges
            → DataFlowAnalysis::getProgramPointBefore(Block*)
              → ilist_iterator::operator*()  ← assertion: sentinel dereference
```

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
