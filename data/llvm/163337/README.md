# [mlir] SEGV `--test-bytecode-roundtrip=test-kind=4`

**Issue:** [https://github.com/llvm/llvm-project/issues/163337](https://github.com/llvm/llvm-project/issues/163337) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-14T08:24:13Z`

**Labels:** `mlir`, `crash`

## Description

PoC:
```mlir
spirv.module Logical GLSL450 {
    spirv.func @callee() -> () "None" {
      spirv.Kill
    }
    spirv.func @do_not_inline_kill() -> () "None" {
      spirv.FunctionCall @callee() : () -> ()
      spirv.Return
    }
  }
  func.func @fusion_bridge_698938439() -> i32 {
    %c = arith.constant 0 : i32
    return %c : i32
  }
  %fusion_tmp = func.call @fusion_bridge_698938439() : () -> i32
  "test.versionedC"() <{attribute = #test.attr_params<42, 24>}> : () -> ()
```

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
