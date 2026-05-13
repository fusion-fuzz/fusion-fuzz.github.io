# [MLIR][Inliner] UNREACHABLE in handleTerminator when inlining function containing multi-block functional_region_op

**Issue:** [https://github.com/llvm/llvm-project/issues/185350](https://github.com/llvm/llvm-project/issues/185350) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2026-03-09T05:56:11Z`

**Labels:** `mlir`, `crash`

## Description

**Description**

When running `--inline` on a function that contains a `test.functional_region_op` with multiple blocks (including a `cf.br` terminator branching to a successor block), `mlir-opt` crashes with an `UNREACHABLE` assertion in `DialectInlinerInterface::handleTerminator`.

**Reproducer**

```mlir
func.func @callee(%arg0: i32) -> i32 {
  %fn = "test.functional_region_op"() ({
  ^bb0(%a : i32):
    %b = arith.addi %a, %a : i32
    cf.br ^bb1(%b: i32)
  ^bb1(%c: i32):
    %d = arith.addi %c, %c : i32
    "test.return"(%d) : (i32) -> ()
  }) : () -> ((i32) -> i32)
  %0 = call_indirect %fn(%arg0) : (i32) -> i32
  return %0 : i32
}

func.func @caller(%arg0: i32) -> i32 {
  %0 = func.call @callee(%arg0) : (i32) -> i32
  return %0 : i32
}
```

**Command**

```
mlir-opt --inline reproduce.mlir
```

**Expected behavior**

Inlining completes successfully, or a graceful error is emitted indicating the operation cannot be inlined.

**Actual behavior**

```
UNREACHABLE executed at mlir/include/mlir/Transforms/DialectInlinerInterface.h.inc:70
Aborted (core dumped)
```

**Crash stack (key frames)**

```
Stack dump without symbol names (ensure you have llvm-symbolizer in your PATH or set the environment var `LLVM_SYMBOLIZER_PATH` to point to it):
0  mlir-opt  0x0000642d9c0ac3db __interceptor_backtrace + 91
1  mlir-opt  0x0000642d9c179687 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) + 343
2  mlir-opt  0x0000642d9c173a2f llvm::sys::RunSignalHandlers() + 207
3  mlir-opt  0x0000642d9c17c9a6
4  libc.so.6 0x00007aa71dfe5520
5  libc.so.6 0x00007aa71e0399fc pthread_kill + 300
6  libc.so.6 0x00007aa71dfe5476 raise + 22
7  libc.so.6 0x00007aa71dfcb7f3 abort + 211
8  mlir-opt  0x0000642d9c132958 llvm::llvm_unreachable_internal(char const*, char const*, unsigned int) + 216
9  mlir-opt  0x0000642d9ca98061
10 mlir-opt  0x0000642db0075ae9
11 mlir-opt  0x0000642db0077dc3 mlir::inlineCall(mlir::InlinerInterface&, llvm::function_ref<void (mlir::OpBuilder&, mlir::Region*, mlir::Block*, mlir::Block*, mlir::IRMapping&, bool)>, mlir::CallOpInterface, mlir::CallableOpInterface, mlir::Region*, bool) + 3715
12 mlir-opt  0x0000642db006c122
13 mlir-opt  0x0000642db0057783 mlir::Inliner::doInlining() + 3651
14 mlir-opt  0x0000642daff1f0d8
15 mlir-opt  0x0000642db01d3f44
16 mlir-opt  0x0000642db01bcfcf mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int) + 3375
17 mlir-opt  0x0000642db01bf19c mlir::detail::OpToOpPassAdaptor::runPipeline(mlir::OpPassManager&, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int, mlir::PassInstrumentor*, mlir::PassInstrumentation::PipelineParentInfo const*) + 1740
18 mlir-opt  0x0000642db01cb2e8 mlir::PassManager::runPasses(mlir::Operation*, mlir::AnalysisManager) + 776
19 mlir-opt  0x0000642db01c9e58 mlir::PassManager::run(mlir::Operation*) + 6616
20 mlir-opt  0x0000642d9c35964f
21 mlir-opt  0x0000642d9c358457
22 mlir-opt  0x0000642db0a3cce4
23 mlir-opt  0x0000642db0a3c2e8 mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef) + 2584
24 mlir-opt  0x0000642d9c33b720 mlir::MlirOptMain(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, mlir::DialectRegistry&, mlir::MlirOptMainConfig const&) + 1504
25 mlir-opt  0x0000642d9c33c16a mlir::MlirOptMain(int, char**, llvm::StringRef, llvm::StringRef, mlir::DialectRegistry&) + 1146
26 mlir-opt  0x0000642d9c33c936 mlir::MlirOptMain(int, char**, llvm::StringRef, mlir::DialectRegistry&) + 854
27 mlir-opt  0x0000642d9c131102 main + 1026
28 libc.so.6 0x00007aa71dfccd90
29 libc.so.6 0x00007aa71dfcce40 __libc_start_main + 128
30 mlir-opt  0x0000642d9c0708a5 _start + 37
Aborted (core dumped)
```

**Root cause**

`inlineRegionImpl` encounters the `cf.br` terminator in a non-entry block of the inlined region and dispatches to `handleTerminator(Operation*, Block*)`. The default implementation of that override unconditionally hits `llvm_unreachable`, indicating no dialect has registered a handler for this terminator/block combination.

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
