# [MLIR][Linalg] UBSan division-by-zero in PackOp::requirePaddingValue when dynamic tile size is propagated as zero via SCCP

**Issue:** [https://github.com/llvm/llvm-project/issues/185352](https://github.com/llvm/llvm-project/issues/185352) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2026-03-09T06:09:30Z`

**Labels:** `mlir:linalg`, `crash`

## Description

**Description**

`linalg.pack` with a dynamic inner tile size crashes with an integer division-by-zero in `PackOp::requirePaddingValue` (LinalgOps.cpp:5501) when `--sccp` propagates a zero constant into the tile size and `--canonicalize` subsequently fires `paddingIsNotNeeded`. The zero tile size is not guarded against before the division.

**Reproducer**

```mlir
func.func @get_tile_size() -> index {
  %c0 = arith.constant 0 : index
  return %c0 : index
}

func.func private @use(%A: tensor<?x16x?x1xi32>)

func.func @pack(%A: tensor<7x16xi32>) {
  %c1 = arith.constant 1 : index
  %pad_val = arith.constant 123 : i32
  %tile_size = func.call @get_tile_size() : () -> index
  %empty = tensor.empty(%c1, %tile_size) : tensor<?x16x?x1xi32>
  %pack = linalg.pack %A
    padding_value(%pad_val : i32)
    inner_dims_pos = [0, 1]
    inner_tiles = [%tile_size, 1]
    into %empty : tensor<7x16xi32> -> tensor<?x16x?x1xi32>
  func.call @use(%pack) : (tensor<?x16x?x1xi32>) -> ()
  return
}

func.func @main() {
  %A = arith.constant dense<0> : tensor<7x16xi32>
  func.call @pack(%A) : (tensor<7x16xi32>) -> ()
  return
}
```

**Command**

```
mlir-opt --inline --sccp --canonicalize --verify-diagnostics reproduce.mlir
```

**Expected behavior**

Either a graceful error is emitted rejecting a zero tile size, or `paddingIsNotNeeded` / `requirePaddingValue` guards against division by zero before performing the computation.

**Actual behavior**

```
/workspace/llvm-project/mlir/lib/Dialect/Linalg/IR/LinalgOps.cpp:5501:32: runtime error: division by zero
    #0 0x5b6a95059b2f in mlir::linalg::PackOp::requirePaddingValue(llvm::ArrayRef<long>, llvm::ArrayRef<long>, llvm::ArrayRef<long>, llvm::ArrayRef<long>, llvm::ArrayRef<mlir::OpFoldResult>) /workspace/llvm-project/mlir/lib/Dialect/Linalg/IR/LinalgOps.cpp:5501:32
    #1 0x5b6a95017c13 in mlir::linalg::paddingIsNotNeeded(mlir::linalg::PackOp) /workspace/llvm-project/mlir/lib/Dialect/Linalg/IR/LinalgOps.cpp:5808:11
    #2 0x5b6a95017c13 in mlir::linalg::PackOp::canonicalize(mlir::linalg::PackOp, mlir::PatternRewriter&) /workspace/llvm-project/mlir/lib/Dialect/Linalg/IR/LinalgOps.cpp:5866:35
    #3 0x5b6a992fde0d in mlir::PatternApplicator::matchAndRewrite(mlir::Operation*, mlir::PatternRewriter&, llvm::function_ref<bool (mlir::Pattern const&)>, llvm::function_ref<void (mlir::Pattern const&)>, llvm::function_ref<llvm::LogicalResult (mlir::Pattern const&)>)::$_6::operator()() const /workspace/llvm-project/mlir/lib/Rewrite/PatternApplicator.cpp:223:31
    #4 0x5b6a992fde0d in void llvm::function_ref<void ()>::callback_fn<mlir::PatternApplicator::matchAndRewrite(mlir::Operation*, mlir::PatternRewriter&, llvm::function_ref<bool (mlir::Pattern const&)>, llvm::function_ref<void (mlir::Pattern const&)>, llvm::function_ref<llvm::LogicalResult (mlir::Pattern const&)>)::$_6>(long) /workspace/llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:46:12
    #5 0x5b6a992f32ed in llvm::function_ref<void ()>::operator()() const /workspace/llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:69:12
    #6 0x5b6a992f32ed in void mlir::MLIRContext::executeAction<mlir::ApplyPatternAction, mlir::Pattern const&>(llvm::function_ref<void ()>, llvm::ArrayRef<mlir::IRUnit>, mlir::Pattern const&) /workspace/llvm-project/mlir/include/mlir/IR/MLIRContext.h:290:7
    #7 0x5b6a992f32ed in mlir::PatternApplicator::matchAndRewrite(mlir::Operation*, mlir::PatternRewriter&, llvm::function_ref<bool (mlir::Pattern const&)>, llvm::function_ref<void (mlir::Pattern const&)>, llvm::function_ref<llvm::LogicalResult (mlir::Pattern const&)>) /workspace/llvm-project/mlir/lib/Rewrite/PatternApplicator.cpp:197:23
    #8 0x5b6a99288f1c in (anonymous namespace)::GreedyPatternRewriteDriver::processWorklist() /workspace/llvm-project/mlir/lib/Transforms/Utils/GreedyPatternRewriteDriver.cpp:619:17
    #9 0x5b6a99286ea6 in (anonymous namespace)::RegionPatternRewriteDriver::simplify(bool*) &&::$_14::operator()() const /workspace/llvm-project/mlir/lib/Transforms/Utils/GreedyPatternRewriteDriver.cpp:889:31
    #10 0x5b6a99286ea6 in void llvm::function_ref<void ()>::callback_fn<(anonymous namespace)::RegionPatternRewriteDriver::simplify(bool*) &&::$_14>(long) /workspace/llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:46:12
    #11 0x5b6a99281462 in llvm::function_ref<void ()>::operator()() const /workspace/llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:69:12
    #12 0x5b6a99281462 in void mlir::MLIRContext::executeAction<(anonymous namespace)::GreedyPatternRewriteIteration, long&>(llvm::function_ref<void ()>, llvm::ArrayRef<mlir::IRUnit>, long&) /workspace/llvm-project/mlir/include/mlir/IR/MLIRContext.h:290:7
    #13 0x5b6a99281462 in (anonymous namespace)::RegionPatternRewriteDriver::simplify(bool*) && /workspace/llvm-project/mlir/lib/Transforms/Utils/GreedyPatternRewriteDriver.cpp:876:10
    #14 0x5b6a99281462 in mlir::applyPatternsGreedily(mlir::Region&, mlir::FrozenRewritePatternSet const&, mlir::GreedyRewriteConfig, bool*) /workspace/llvm-project/mlir/lib/Transforms/Utils/GreedyPatternRewriteDriver.cpp:934:47
    #15 0x5b6a85633992 in mlir::applyPatternsGreedily(mlir::Operation*, mlir::FrozenRewritePatternSet const&, mlir::GreedyRewriteConfig, bool*) /workspace/llvm-project/mlir/include/mlir/Transforms/GreedyPatternRewriteDriver.h:224:15
    #16 0x5b6a9913d560 in (anonymous namespace)::Canonicalizer::runOnOperation() /workspace/llvm-project/mlir/lib/Transforms/Canonicalizer.cpp:63:9
    #17 0x5b6a9940bf43 in mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int)::$_44::operator()() const /workspace/llvm-project/mlir/lib/Pass/Pass.cpp:612:19
    #18 0x5b6a9940bf43 in void llvm::function_ref<void ()>::callback_fn<mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int)::$_44>(long) /workspace/llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:46:12
    #19 0x5b6a993f4fce in llvm::function_ref<void ()>::operator()() const /workspace/llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:69:12
    #20 0x5b6a993f4fce in void mlir::MLIRContext::executeAction<mlir::PassExecutionAction, mlir::Pass&>(llvm::function_ref<void ()>, llvm::ArrayRef<mlir::IRUnit>, mlir::Pass&) /workspace/llvm-project/mlir/include/mlir/IR/MLIRContext.h:290:7
    #21 0x5b6a993f4fce in mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int) /workspace/llvm-project/mlir/lib/Pass/Pass.cpp:606:23
    #22 0x5b6a993f719b in mlir::detail::OpToOpPassAdaptor::runPipeline(mlir::OpPassManager&, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int, mlir::PassInstrumentor*, mlir::PassInstrumentation::PipelineParentInfo const*) /workspace/llvm-project/mlir/lib/Pass/Pass.cpp:688:16
    #23 0x5b6a9940b785 in mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int)::$_43::operator()(mlir::OpPassManager&, mlir::Operation*) const /workspace/llvm-project/mlir/lib/Pass/Pass.cpp:592:12
    #24 0x5b6a9940b785 in llvm::LogicalResult llvm::function_ref<llvm::LogicalResult (mlir::OpPassManager&, mlir::Operation*)>::callback_fn<mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int)::$_43>(long, mlir::OpPassManager&, mlir::Operation*) /workspace/llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:46:12
    #25 0x5b6a9928e055 in std::function<llvm::LogicalResult (mlir::Pass&, mlir::OpPassManager&, mlir::Operation*)>::operator()(mlir::Pass&, mlir::OpPassManager&, mlir::Operation*) const /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/std_function.h:590:9
    #26 0x5b6a9928ddf1 in mlir::Inliner::Impl::optimizeCallable(mlir::CallGraphNode*, llvm::StringMap<mlir::OpPassManager, llvm::MallocAllocator>&) /workspace/llvm-project/mlir/lib/Transforms/Utils/Inliner.cpp:576:10
    #27 0x5b6a9929d376 in mlir::Inliner::Impl::optimizeSCCAsync(llvm::MutableArrayRef<mlir::CallGraphNode*>, mlir::MLIRContext*)::$_0::operator()(mlir::CallGraphNode*) const /workspace/llvm-project/mlir/lib/Transforms/Utils/Inliner.cpp:552:28
    #28 0x5b6a9928d000 in llvm::LogicalResult mlir::failableParallelForEach<mlir::CallGraphNode**, mlir::Inliner::Impl::optimizeSCCAsync(llvm::MutableArrayRef<mlir::CallGraphNode*>, mlir::MLIRContext*)::$_0>(mlir::MLIRContext*, mlir::CallGraphNode**, mlir::CallGraphNode**, mlir::Inliner::Impl::optimizeSCCAsync(llvm::MutableArrayRef<mlir::CallGraphNode*>, mlir::MLIRContext*)::$_0&&) /workspace/llvm-project/mlir/include/mlir/IR/Threading.h:46:18
    #29 0x5b6a9928d000 in llvm::LogicalResult mlir::failableParallelForEach<llvm::MutableArrayRef<mlir::CallGraphNode*>&, mlir::Inliner::Impl::optimizeSCCAsync(llvm::MutableArrayRef<mlir::CallGraphNode*>, mlir::MLIRContext*)::$_0>(mlir::MLIRContext*, llvm::MutableArrayRef<mlir::CallGraphNode*>&, mlir::Inliner::Impl::optimizeSCCAsync(llvm::MutableArrayRef<mlir::CallGraphNode*>, mlir::MLIRContext*)::$_0&&) /workspace/llvm-project/mlir/include/mlir/IR/Threading.h:92:10
    #30 0x5b6a9928d000 in mlir::Inliner::Impl::optimizeSCCAsync(llvm::MutableArrayRef<mlir::CallGraphNode*>, mlir::MLIRContext*) /workspace/llvm-project/mlir/lib/Transforms/Utils/Inliner.cpp:541:10
    #31 0x5b6a9928f668 in mlir::Inliner::Impl::optimizeSCC(mlir::CallGraph&, (anonymous namespace)::CGUseList&, (anonymous namespace)::CallGraphSCC&, mlir::MLIRContext*) /workspace/llvm-project/mlir/lib/Transforms/Utils/Inliner.cpp:509:14
    #32 0x5b6a9928f668 in mlir::Inliner::Impl::inlineSCC((anonymous namespace)::InlinerInterfaceImpl&, (anonymous namespace)::CGUseList&, (anonymous namespace)::CallGraphSCC&, mlir::MLIRContext*) /workspace/llvm-project/mlir/lib/Transforms/Utils/Inliner.cpp:475:16
    #33 0x5b6a9928f668 in mlir::Inliner::doInlining()::$_19::operator()((anonymous namespace)::CallGraphSCC&) const /workspace/llvm-project/mlir/lib/Transforms/Utils/Inliner.cpp:761:17
    #34 0x5b6a9928f668 in llvm::LogicalResult llvm::function_ref<llvm::LogicalResult ((anonymous namespace)::CallGraphSCC&)>::callback_fn<mlir::Inliner::doInlining()::$_19>(long, (anonymous namespace)::CallGraphSCC&) /workspace/llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:46:12
    #35 0x5b6a9928f668 in llvm::function_ref<llvm::LogicalResult ((anonymous namespace)::CallGraphSCC&)>::operator()((anonymous namespace)::CallGraphSCC&) const /workspace/llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:69:12
    #36 0x5b6a9928f668 in runTransformOnCGSCCs(mlir::CallGraph const&, llvm::function_ref<llvm::LogicalResult ((anonymous namespace)::CallGraphSCC&)>) /workspace/llvm-project/mlir/lib/Transforms/Utils/Inliner.cpp:294:16
    #37 0x5b6a9928f668 in mlir::Inliner::doInlining() /workspace/llvm-project/mlir/lib/Transforms/Utils/Inliner.cpp:760:26
    #38 0x5b6a991570d7 in (anonymous namespace)::InlinerPass::runOnOperation() /workspace/llvm-project/mlir/lib/Transforms/InlinerPass.cpp:151:22
    #39 0x5b6a9940bf43 in mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int)::$_44::operator()() const /workspace/llvm-project/mlir/lib/Pass/Pass.cpp:612:19
    #40 0x5b6a9940bf43 in void llvm::function_ref<void ()>::callback_fn<mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int)::$_44>(long) /workspace/llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:46:12
    #41 0x5b6a993f4fce in llvm::function_ref<void ()>::operator()() const /workspace/llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:69:12
    #42 0x5b6a993f4fce in void mlir::MLIRContext::executeAction<mlir::PassExecutionAction, mlir::Pass&>(llvm::function_ref<void ()>, llvm::ArrayRef<mlir::IRUnit>, mlir::Pass&) /workspace/llvm-project/mlir/include/mlir/IR/MLIRContext.h:290:7
    #43 0x5b6a993f4fce in mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int) /workspace/llvm-project/mlir/lib/Pass/Pass.cpp:606:23
    #44 0x5b6a993f719b in mlir::detail::OpToOpPassAdaptor::runPipeline(mlir::OpPassManager&, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int, mlir::PassInstrumentor*, mlir::PassInstrumentation::PipelineParentInfo const*) /workspace/llvm-project/mlir/lib/Pass/Pass.cpp:688:16
    #45 0x5b6a994032e7 in mlir::PassManager::runPasses(mlir::Operation*, mlir::AnalysisManager) /workspace/llvm-project/mlir/lib/Pass/Pass.cpp:1123:10
    #46 0x5b6a99401e57 in mlir::PassManager::run(mlir::Operation*) /workspace/llvm-project/mlir/lib/Pass/Pass.cpp:1097:60
    #47 0x5b6a8559164e in performActions(llvm::raw_ostream&, std::shared_ptr<llvm::SourceMgr> const&, mlir::MLIRContext*, mlir::MlirOptMainConfig const&) /workspace/llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:591:17
    #48 0x5b6a8559026f in processBuffer(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef, mlir::MlirOptMainConfig const&, mlir::DialectRegistry&, mlir::SourceMgrDiagnosticVerifierHandler*, llvm::ThreadPoolInterface*) /workspace/llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:679:9
    #49 0x5b6a8559026f in mlir::MlirOptMain(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, mlir::DialectRegistry&, mlir::MlirOptMainConfig const&)::$_3::operator()(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef, llvm::raw_ostream&) const /workspace/llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:771:12
    #50 0x5b6a8559026f in llvm::LogicalResult llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>::callback_fn<mlir::MlirOptMain(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, mlir::DialectRegistry&, mlir::MlirOptMainConfig const&)::$_3>(long, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&) /workspace/llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:46:12
    #51 0x5b6a99c74ce3 in llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>::operator()(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&) const /workspace/llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:69:12
    #52 0x5b6a99c742e7 in mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef) /workspace/llvm-project/mlir/lib/Support/ToolUtilities.cpp:30:12
    #53 0x5b6a8557371f in mlir::MlirOptMain(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, mlir::DialectRegistry&, mlir::MlirOptMainConfig const&) /workspace/llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:776:26
    #54 0x5b6a85574169 in mlir::MlirOptMain(int, char**, llvm::StringRef, llvm::StringRef, mlir::DialectRegistry&) /workspace/llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:822:14
    #55 0x5b6a85574935 in mlir::MlirOptMain(int, char**, llvm::StringRef, mlir::DialectRegistry&) /workspace/llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:838:10
    #56 0x5b6a85369101 in main /workspace/llvm-project/mlir/tools/mlir-opt/mlir-opt.cpp:347:33
    #57 0x7d15be822d8f  (/lib/x86_64-linux-gnu/libc.so.6+0x29d8f) (BuildId: 095c7ba148aeca81668091f718047078d57efddb)
    #58 0x7d15be822e3f in __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x29e3f) (BuildId: 095c7ba148aeca81668091f718047078d57efddb)
    #59 0x5b6a852a88a4 in _start (/workspace/projects/mlir/llvm-mlir-build/bin/mlir-opt+0x8a648a4) (BuildId: 3226acb7d82320a1ec39181125de89800b7b9516)

SUMMARY: UndefinedBehaviorSanitizer: undefined-behavior /workspace/llvm-project/mlir/lib/Dialect/Linalg/IR/LinalgOps.cpp:5501:32
```

**Root cause**

The call chain is:

```
PackOp::canonicalize (LinalgOps.cpp:5866)
  → paddingIsNotNeeded (LinalgOps.cpp:5808)
    → PackOp::requirePaddingValue (LinalgOps.cpp:5501)  ← division by zero
```

`--inline` inlines `@get_tile_size`, making the zero tile size visible. `--sccp` then propagates it as a constant. When `--canonicalize` triggers `PackOp::canonicalize`, `paddingIsNotNeeded` calls `requirePaddingValue` which divides the source dimension size by the (zero) tile size without checking for zero first.

**Environment**
- Tool: `mlir-opt`
- Passes: `--inline --sccp --canonicalize --verify-diagnostics`
- Sanitizer: UBSan (`UBSAN_OPTIONS=print_stacktrace=1:halt_on_error=1`)

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
