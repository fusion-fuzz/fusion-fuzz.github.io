# [MLIR][Canonicalize] Assertion op->use_empty() in RewriterBase::eraseOp when canonicalizing a self-referential builtin.unrealized_conversion_cast in a graph region

**Issue:** [https://github.com/llvm/llvm-project/issues/194824](https://github.com/llvm/llvm-project/issues/194824) &nbsp;·&nbsp; **State:** `open` &nbsp;·&nbsp; **Created:** `2026-04-29T10:07:41Z`

**Labels:** `mlir`, `crash`

## Description

**Description**

`mlir-opt --allow-unregistered-dialect --canonicalize` crashes with an assertion failure in `RewriterBase::eraseOp` (`"expected 'op' to have no uses"`) when the canonicalizer attempts to fold or erase a `builtin.unrealized_conversion_cast` op whose result is its own operand (a self-referential cast) inside a `test.graph_region`. Graph regions allow uses to precede definitions, so a self-referential SSA value is valid IR in this context. The canonicalizer's folder for `unrealized_conversion_cast` does not account for this case and attempts to erase the op while it still has a use (itself), triggering the assertion.

**Reproducer**

```mlir
module {
  test.graph_region {
    %0 = builtin.unrealized_conversion_cast %0 : i32 to i32
    "test.return"() : () -> ()
  }
}
```

**Command**

```
mlir-opt --allow-unregistered-dialect --canonicalize reproduce.mlir
```

**Expected behavior**

The canonicalizer should detect that the `unrealized_conversion_cast` op is self-referential and either leave it alone or handle it gracefully without attempting to erase an op that still has uses. It should not crash.

**Actual behavior**

```
mlir-opt: mlir/lib/IR/PatternMatch.cpp:156:
  virtual void mlir::RewriterBase::eraseOp(mlir::Operation*):
  Assertion `op->use_empty() && "expected 'op' to have no uses"' failed.
Aborted (core dumped)
```

**Call chain**

```
--canonicalize
  → Canonicalizer::runOnOperation
    → applyPatternsGreedily
      → GreedyPatternRewriteDriver::processWorklist
        → (unrealized_conversion_cast folder/canonicalization pattern)
          → RewriterBase::eraseOp       ← assertion: op still has uses
```

**Root cause**

`builtin.unrealized_conversion_cast` with identical input and output types (`i32 to i32`) is a candidate for folding — the canonicalizer replaces it with its input operand and erases it. In a normal region this is safe. However, in a graph region the cast's result `%0` is also its own operand, so after the folder replaces all uses of `%0` with the input (which is `%0` itself), the op still has a use through its own operand. The canonicalizer then calls `eraseOp` without checking `use_empty()`, triggering the assertion. The fix should add a self-use check in the `unrealized_conversion_cast` canonicalization pattern, or in `eraseOp`'s caller, to bail out when the op's operands include its own results.

**Environment**

- Tool: `mlir-opt`
- Pass: `--canonicalize` (with `--allow-unregistered-dialect`)
- Affected file: `mlir/lib/IR/PatternMatch.cpp:156` (`RewriterBase::eraseOp`)
- Triggered by: `builtin.unrealized_conversion_cast` folder in `--canonicalize`

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
