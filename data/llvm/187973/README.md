# [MLIR] Assertion !getType().isSignlessInteger() in IntegerAttr::getInt() when running --sccp on emitc.switch with unsigned integer condition

**Issue:** [https://github.com/llvm/llvm-project/issues/187973](https://github.com/llvm/llvm-project/issues/187973) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2026-03-23T04:53:47Z`

**Labels:** `crash`, `mlir:emitc`

## Description

Related: #111242

**Description**

`mlir-opt --sccp` crashes with an assertion failure in `IntegerAttr::getInt()` when processing a function containing an `emitc.switch` op whose condition has an unsigned integer type (e.g. `ui32`). The `DeadCodeAnalysis` pass invoked by SCCP calls `SwitchOp::getEntrySuccessorRegions`, which calls `IntegerAttr::getInt()` on the case value attributes to determine which branch is statically taken. However, `getInt()` asserts that the attribute type must be a signless integer or index — unsigned integer types such as `ui32` satisfy neither condition, triggering the assertion.

**Reproducer**

```mlir
module {
  func.func @f() {
    %0 = "emitc.constant"() {value = 1 : ui32} : () -> ui32
    emitc.switch %0 : ui32
    case 2 {
      emitc.yield
    }
    default {
      emitc.yield
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

`--sccp` either processes the file successfully or emits a diagnostic. It should not crash when `emitc.switch` uses an unsigned integer condition type.

**Actual behavior**

```
mlir-opt: mlir/lib/IR/BuiltinAttributes.cpp:367:
  int64_t mlir::IntegerAttr::getInt() const:
  Assertion `(getType().isIndex() || getType().isSignlessInteger()) && "must be signless integer"' failed.
```

**Call chain**

```
SCCP::runOnOperation
  → DataFlowSolver::initializeAndRun
    → DeadCodeAnalysis::visit
      → DeadCodeAnalysis::visitRegionBranchOperation
        → SwitchOp::getEntrySuccessorRegions   (EmitC.cpp:1569)
          → IntegerAttr::getInt()              ← assertion: not signless integer or index
```

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
