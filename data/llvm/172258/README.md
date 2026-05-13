# [mlir] SEGV when converting arith op to llvm

**Issue:** [https://github.com/llvm/llvm-project/issues/172258](https://github.com/llvm/llvm-project/issues/172258) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-12-15T07:53:58Z`

**Labels:** `mlir`, `crash`

## Description

```mlir
#CSR = #sparse_tensor.encoding<{map = (d0, d1) -> (d0 : dense, d1 : compressed)}>

module {
  func.func @crash_target(%arg0: tensor<10x20xf16, #CSR>) {
    // The pass attempts to convert this arith op and potentially reconciles 
    // the function signature, crashing on the unhandled sparse tensor type.
    %0 = arith.constant 0.0 : f64
    return
  }
}
```

reproduce: `mlir-opt -pass-pipeline="builtin.module(func.func(convert-arith-to-llvm))" ./test.mlir`

```
Segmentation fault (core dumped)
```

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
