# [MLIR][Arith] UNREACHABLE in APFloat when constant-folding arith.truncf of -inf into f4E2M1FN

**Issue:** [https://github.com/llvm/llvm-project/issues/185351](https://github.com/llvm/llvm-project/issues/185351) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2026-03-09T06:01:53Z`

**Labels:** `crash`, `mlir:arith`

## Description

**Description**

`arith.truncf` from `f32` to `f4E2M1FN` crashes with an `UNREACHABLE` in `APFloat` when the input is a constant infinity (e.g. `-inf` = `0xFF800000`). The `f4E2M1FN` type has no infinity representation, so the fold hits an unsupported code path.

The crash is triggered after `--inline` propagates the `-inf` constant, enabling constant folding of the `truncf`.

**Reproducer**

```mlir
func.func @get_inf() -> f32 {
  %c = arith.constant 0xFF800000 : f32
  return %c : f32
}

func.func @entry() {
  %inf = func.call @get_inf() : () -> f32
  %trunc = arith.truncf %inf : f32 to f4E2M1FN
  %bitcast = arith.bitcast %trunc : f4E2M1FN to i4
  %ext = arith.extui %bitcast : i4 to i64
  return
}
```

**Command**

```
mlir-opt --inline reproduce.mlir
```

**Expected behavior**

Either the fold is skipped for inf inputs on types that don't support infinity, or a graceful error is emitted.

**Actual behavior**

```
UNREACHABLE executed at /workspace/llvm-project/llvm/lib/Support/APFloat.cpp:3535!
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and instructions to reproduce the bug.
Stack dump:
0.	Program arguments: ./llvm-mlir-build/bin/mlir-opt --inline --verify-diagnostics ../../output/bugs/mlir/Stderr_semantics_don_t_support_inf__6dcc9790/min.mlir
Stack dump without symbol names (ensure you have llvm-symbolizer in your PATH or set the environment var `LLVM_SYMBOLIZER_PATH` to point to it):
0  mlir-opt  0x000058bd42aa43db __interceptor_backtrace + 91
1  mlir-opt  0x000058bd42b71687 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) + 343
2  mlir-opt  0x000058bd42b6ba2f llvm::sys::RunSignalHandlers() + 207
3  mlir-opt  0x000058bd42b749a6
4  libc.so.6 0x0000789987a00520
5  libc.so.6 0x0000789987a549fc pthread_kill + 300
6  libc.so.6 0x0000789987a00476 raise + 22
7  libc.so.6 0x00007899879e67f3 abort + 211
8  mlir-opt  0x000058bd42b2a958 llvm::llvm_unreachable_internal(char const*, char const*, unsigned int) + 216
9  mlir-opt  0x000058bd42cc86ac llvm::APInt llvm::detail::IEEEFloat::convertIEEEFloatToAPInt<llvm::APFloatBase::semFloat4E2M1FN>() const + 1084
10 mlir-opt  0x000058bd42cc81ee llvm::detail::IEEEFloat::convertFloat4E2M1FNAPFloatToAPInt() const + 94
11 mlir-opt  0x000058bd42cc8965 llvm::detail::IEEEFloat::bitcastToAPInt() const + 485
12 mlir-opt  0x000058bd42cd9003
13 mlir-opt  0x000058bd565e7d5c mlir::arith::BitcastOp::fold(mlir::arith::BitcastOpGenericAdaptor<llvm::ArrayRef<mlir::Attribute>>) + 1404
14 mlir-opt  0x000058bd567f6b85
15 mlir-opt  0x000058bd567f4e89
16 mlir-opt  0x000058bd5737f5ce mlir::Operation::fold(llvm::ArrayRef<mlir::Attribute>, llvm::SmallVectorImpl<mlir::OpFoldResult>&) + 286
17 mlir-opt  0x000058bd57380335 mlir::Operation::fold(llvm::SmallVectorImpl<mlir::OpFoldResult>&) + 805
18 mlir-opt  0x000058bd56a47f5b
19 mlir-opt  0x000058bd56a46ea7
20 mlir-opt  0x000058bd56a41463 mlir::applyPatternsGreedily(mlir::Region&, mlir::FrozenRewritePatternSet const&, mlir::GreedyRewriteConfig, bool*) + 4115
21 mlir-opt  0x000058bd42df3993
22 mlir-opt  0x000058bd568fd561
23 mlir-opt  0x000058bd56bcbf44
24 mlir-opt  0x000058bd56bb4fcf mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int) + 3375
25 mlir-opt  0x000058bd56bb719c mlir::detail::OpToOpPassAdaptor::runPipeline(mlir::OpPassManager&, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int, mlir::PassInstrumentor*, mlir::PassInstrumentation::PipelineParentInfo const*) + 1740
26 mlir-opt  0x000058bd56bcb786
27 mlir-opt  0x000058bd56a4e056
28 mlir-opt  0x000058bd56a4ddf2 mlir::Inliner::Impl::optimizeCallable(mlir::CallGraphNode*, llvm::StringMap<mlir::OpPassManager, llvm::MallocAllocator>&) + 898
29 mlir-opt  0x000058bd56a5d377
30 mlir-opt  0x000058bd56a4d001 mlir::Inliner::Impl::optimizeSCCAsync(llvm::MutableArrayRef<mlir::CallGraphNode*>, mlir::MLIRContext*) + 1281
31 mlir-opt  0x000058bd56a4f669 mlir::Inliner::doInlining() + 3369
32 mlir-opt  0x000058bd569170d8
33 mlir-opt  0x000058bd56bcbf44
34 mlir-opt  0x000058bd56bb4fcf mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int) + 3375
35 mlir-opt  0x000058bd56bb719c mlir::detail::OpToOpPassAdaptor::runPipeline(mlir::OpPassManager&, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int, mlir::PassInstrumentor*, mlir::PassInstrumentation::PipelineParentInfo const*) + 1740
36 mlir-opt  0x000058bd56bc32e8 mlir::PassManager::runPasses(mlir::Operation*, mlir::AnalysisManager) + 776
37 mlir-opt  0x000058bd56bc1e58 mlir::PassManager::run(mlir::Operation*) + 6616
38 mlir-opt  0x000058bd42d5164f
39 mlir-opt  0x000058bd42d50270
40 mlir-opt  0x000058bd57434ce4
41 mlir-opt  0x000058bd574342e8 mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef) + 2584
42 mlir-opt  0x000058bd42d33720 mlir::MlirOptMain(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, mlir::DialectRegistry&, mlir::MlirOptMainConfig const&) + 1504
43 mlir-opt  0x000058bd42d3416a mlir::MlirOptMain(int, char**, llvm::StringRef, llvm::StringRef, mlir::DialectRegistry&) + 1146
44 mlir-opt  0x000058bd42d34936 mlir::MlirOptMain(int, char**, llvm::StringRef, mlir::DialectRegistry&) + 854
45 mlir-opt  0x000058bd42b29102 main + 1026
46 libc.so.6 0x00007899879e7d90
47 libc.so.6 0x00007899879e7e40 __libc_start_main + 128
48 mlir-opt  0x000058bd42a688a5 _start + 37
Aborted (core dumped)
```

**Root cause**

When `--inline` inlines `get_inf`, the `-inf` constant becomes available to the `truncf` folder. The constant folding path in `arith.truncf` calls into `APFloat` to convert the value, but `f4E2M1FN`'s semantics object does not define infinity, causing `llvm_unreachable` to fire.


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
