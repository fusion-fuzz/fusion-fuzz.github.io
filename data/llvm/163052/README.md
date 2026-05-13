# [mlir] [llvm] stack overflow in llvm/include/llvm/ADT/DenseMap.h

**Issue:** [https://github.com/llvm/llvm-project/issues/163052](https://github.com/llvm/llvm-project/issues/163052) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-12T08:30:30Z`

**Labels:** `crash`, `mlir:bufferization`

## Description

test.mlir:

```mlir
func.func private @B_foo(tensor<64xf32>)
  func.func private @B_bar(%A : tensor<64xf32>) {
    call @B_foo(%A) : (tensor<64xf32>) -> ()
    return
  }
```

reproduce: `mlir-opt ./test.mlir --split-input-file '-one-shot-bufferize=bufferize-function-boundaries=1 copy-before-write=1' -drop-equivalent-buffer-results`

stderr:
```
=================================================================
==2343068==ERROR: AddressSanitizer: stack-buffer-overflow on address 0x7ffcbf29a320 at pc 0x595cbb4fa5ad bp 0x7ffcbf298960 sp 0x7ffcbf298958
READ of size 8 at 0x7ffcbf29a320 thread T0
    #0 0x595cbb4fa5ac in llvm::DenseMap<mlir::TypeID, std::unique_ptr<mlir::bufferization::OneShotAnalysisState::Extension, std::default_delete<mlir::bufferization::OneShotAnalysisState::Extension> >, llvm::DenseMapInfo<mlir::TypeID, void>, llvm::detail::DenseMapPair<mlir::TypeID, std::unique_ptr<mlir::bufferization::OneShotAnalysisState::Extension, std::default_delete<mlir::bufferization::OneShotAnalysisState::Extension> > > >::getBuckets() const llvm-project/llvm/include/llvm/ADT/DenseMap.h:829:40
    #1 0x595cbb4fa5ac in llvm::DenseMapBase<llvm::DenseMap<mlir::TypeID, std::unique_ptr<mlir::bufferization::OneShotAnalysisState::Extension, std::default_delete<mlir::bufferization::OneShotAnalysisState::Extension> >, llvm::DenseMapInfo<mlir::TypeID, void>, llvm::detail::DenseMapPair<mlir::TypeID, std::unique_ptr<mlir::bufferization::OneShotAnalysisState::Extension, std::default_delete<mlir::bufferization::OneShotAnalysisState::Extension> > > >, mlir::TypeID, std::unique_ptr<mlir::bufferization::OneShotAnalysisState::Extension, std::default_delete<mlir::bufferization::OneShotAnalysisState::Extension> >, llvm::DenseMapInfo<mlir::TypeID, void>, llvm::detail::DenseMapPair<mlir::TypeID, std::unique_ptr<mlir::bufferization::OneShotAnalysisState::Extension, std::default_delete<mlir::bufferization::OneShotAnalysisState::Extension> > > >::getBuckets() const llvm-project/llvm/include/llvm/ADT/DenseMap.h:507:56
    #2 0x595cbb4fa5ac in llvm::detail::DenseMapPair<mlir::TypeID, std::unique_ptr<mlir::bufferization::OneShotAnalysisState::Extension, std::default_delete<mlir::bufferization::OneShotAnalysisState::Extension> > > const* llvm::DenseMapBase<llvm::DenseMap<mlir::TypeID, std::unique_ptr<mlir::bufferization::OneShotAnalysisState::Extension, std::default_delete<mlir::bufferization::OneShotAnalysisState::Extension> >, llvm::DenseMapInfo<mlir::TypeID, void>, llvm::detail::DenseMapPair<mlir::TypeID, std::unique_ptr<mlir::bufferization::OneShotAnalysisState::Extension, std::default_delete<mlir::bufferization::OneShotAnalysisState::Extension> > > >, mlir::TypeID, std::unique_ptr<mlir::bufferization::OneShotAnalysisState::Extension, std::default_delete<mlir::bufferization::OneShotAnalysisState::Extension> >, llvm::DenseMapInfo<mlir::TypeID, void>, llvm::detail::DenseMapPair<mlir::TypeID, std::unique_ptr<mlir::bufferization::OneShotAnalysisState::Extension, std::default_delete<mlir::bufferization::OneShotAnalysisState::Extension> > > >::doFind<mlir::TypeID>(mlir::TypeID const&) const llvm-project/llvm/include/llvm/ADT/DenseMap.h:572:33
    #3 0x595cbb4fa3e7 in llvm::detail::DenseMapPair<mlir::TypeID, std::unique_ptr<mlir::bufferization::OneShotAnalysisState::Extension, std::default_delete<mlir::bufferization::OneShotAnalysisState::Extension> > >* llvm::DenseMapBase<llvm::DenseMap<mlir::TypeID, std::unique_ptr<mlir::bufferization::OneShotAnalysisState::Extension, std::default_delete<mlir::bufferization::OneShotAnalysisState::Extension> >, llvm::DenseMapInfo<mlir::TypeID, void>, llvm::detail::DenseMapPair<mlir::TypeID, std::unique_ptr<mlir::bufferization::OneShotAnalysisState::Extension, std::default_delete<mlir::bufferization::OneShotAnalysisState::Extension> > > >, mlir::TypeID, std::unique_ptr<mlir::bufferization::OneShotAnalysisState::Extension, std::default_delete<mlir::bufferization::OneShotAnalysisState::Extension> >, llvm::DenseMapInfo<mlir::TypeID, void>, llvm::detail::DenseMapPair<mlir::TypeID, std::unique_ptr<mlir::bufferization::OneShotAnalysisState::Extension, std::default_delete<mlir::bufferization::OneShotAnalysisState::Extension> > > >::doFind<mlir::TypeID>(mlir::TypeID const&) llvm-project/llvm/include/llvm/ADT/DenseMap.h:596:50
    #4 0x595cbb4fa3e7 in llvm::DenseMapIterator<mlir::TypeID, std::unique_ptr<mlir::bufferization::OneShotAnalysisState::Extension, std::default_delete<mlir::bufferization::OneShotAnalysisState::Extension> >, llvm::DenseMapInfo<mlir::TypeID, void>, llvm::detail::DenseMapPair<mlir::TypeID, std::unique_ptr<mlir::bufferization::OneShotAnalysisState::Extension, std::default_delete<mlir::bufferization::OneShotAnalysisState::Extension> > >, false> llvm::DenseMapBase<llvm::DenseMap<mlir::TypeID, std::unique_ptr<mlir::bufferization::OneShotAnalysisState::Extension, std::default_delete<mlir::bufferization::OneShotAnalysisState::Extension> >, llvm::DenseMapInfo<mlir::TypeID, void>, llvm::detail::DenseMapPair<mlir::TypeID, std::unique_ptr<mlir::bufferization::OneShotAnalysisState::Extension, std::default_delete<mlir::bufferization::OneShotAnalysisState::Extension> > > >, mlir::TypeID, std::unique_ptr<mlir::bufferization::OneShotAnalysisState::Extension, std::default_delete<mlir::bufferization::OneShotAnalysisState::Extension> >, llvm::DenseMapInfo<mlir::TypeID, void>, llvm::detail::DenseMapPair<mlir::TypeID, std::unique_ptr<mlir::bufferization::OneShotAnalysisState::Extension, std::default_delete<mlir::bufferization::OneShotAnalysisState::Extension> > > >::find_as<mlir::TypeID>(mlir::TypeID const&) llvm-project/llvm/include/llvm/ADT/DenseMap.h:181:27
    #5 0x595cbb4fa038 in llvm::DenseMapBase<llvm::DenseMap<mlir::TypeID, std::unique_ptr<mlir::bufferization::OneShotAnalysisState::Extension, std::default_delete<mlir::bufferization::OneShotAnalysisState::Extension> >, llvm::DenseMapInfo<mlir::TypeID, void>, llvm::detail::DenseMapPair<mlir::TypeID, std::unique_ptr<mlir::bufferization::OneShotAnalysisState::Extension, std::default_delete<mlir::bufferization::OneShotAnalysisState::Extension> > > >, mlir::TypeID, std::unique_ptr<mlir::bufferization::OneShotAnalysisState::Extension, std::default_delete<mlir::bufferization::OneShotAnalysisState::Extension> >, llvm::DenseMapInfo<mlir::TypeID, void>, llvm::detail::DenseMapPair<mlir::TypeID, std::unique_ptr<mlir::bufferization::OneShotAnalysisState::Extension, std::default_delete<mlir::bufferization::OneShotAnalysisState::Extension> > > >::find(mlir::TypeID const&) llvm-project/llvm/include/llvm/ADT/DenseMap.h:168:12
    #6 0x595cbb4fa038 in mlir::bufferization::func_ext::FuncAnalysisState* mlir::bufferization::OneShotAnalysisState::getExtension<mlir::bufferization::func_ext::FuncAnalysisState>() llvm-project/mlir/include/mlir/Dialect/Bufferization/Transforms/OneShotAnalysis.h:214:28
    #7 0x595cbb4f97ef in mlir::bufferization::func_ext::FuncAnalysisState const* mlir::bufferization::OneShotAnalysisState::getExtension<mlir::bufferization::func_ext::FuncAnalysisState>() const llvm-project/mlir/include/mlir/Dialect/Bufferization/Transforms/OneShotAnalysis.h:223:54
    #8 0x595cbb4f97ef in mlir::bufferization::func_ext::getCalledFunction(mlir::CallOpInterface, mlir::bufferization::AnalysisState const&) llvm-project/mlir/lib/Dialect/Bufferization/Transforms/FuncBufferizableOpInterfaceImpl.cpp:112:32
    #9 0x595cbb4fb5bc in mlir::bufferization::func_ext::CallOpInterface::bufferizesToMemoryWrite(mlir::Operation*, mlir::OpOperand&, mlir::bufferization::AnalysisState const&) const llvm-project/mlir/lib/Dialect/Bufferization/Transforms/FuncBufferizableOpInterfaceImpl.cpp:186:21
    #10 0x595cbb5653f8 in mlir::bufferization::AnalysisState::bufferizesToMemoryWrite(mlir::OpOperand&) const llvm-project/mlir/lib/Dialect/Bufferization/IR/BufferizableOpInterface.cpp:473:27
    #11 0x595cbb56a41b in mlir::bufferization::AnalysisState::isInPlace(mlir::OpOperand&) const llvm-project/mlir/lib/Dialect/Bufferization/IR/BufferizableOpInterface.cpp:663:11
    #12 0x595cbb5636c4 in mlir::bufferization::BufferizableOpInterface::resolveTensorOpOperandConflicts(mlir::RewriterBase&, mlir::bufferization::AnalysisState const&, mlir::bufferization::BufferizationState const&) llvm-project/mlir/lib/Dialect/Bufferization/IR/BufferizableOpInterface.cpp:242:23
    #13 0x595cbb4feb4d in mlir::bufferization::detail::BufferizableOpInterfaceInterfaceTraits::ExternalModel<mlir::bufferization::func_ext::CallOpInterface, mlir::func::CallOp>::resolveConflicts(mlir::Operation*, mlir::RewriterBase&, mlir::bufferization::AnalysisState const&, mlir::bufferization::BufferizationState const&) const llvm-mlir-build/tools/mlir/include/mlir/Dialect/Bufferization/IR/BufferizableOpInterface.h.inc:1211:33
    #14 0x595cbb55aff6 in mlir::bufferization::insertTensorCopies(mlir::Operation*, mlir::bufferization::AnalysisState const&, mlir::bufferization::BufferizationState const&)::$_1::operator()(mlir::Operation*) const llvm-project/mlir/lib/Dialect/Bufferization/Transforms/TensorCopyInsertion.cpp:72:31
    #15 0x595cbb55aff6 in mlir::WalkResult llvm::function_ref<mlir::WalkResult (mlir::Operation*)>::callback_fn<mlir::bufferization::insertTensorCopies(mlir::Operation*, mlir::bufferization::AnalysisState const&, mlir::bufferization::BufferizationState const&)::$_1>(long, mlir::Operation*) llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:46:12
    #16 0x595cac483d64 in llvm::function_ref<mlir::WalkResult (mlir::Operation*)>::operator()(mlir::Operation*) const llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:69:12
    #17 0x595cac483d64 in mlir::WalkResult mlir::detail::walk<mlir::ForwardIterator>(mlir::Operation*, llvm::function_ref<mlir::WalkResult (mlir::Operation*)>, mlir::WalkOrder) llvm-project/mlir/include/mlir/IR/Visitors.h:246:12
    #18 0x595cac483c78 in mlir::WalkResult mlir::detail::walk<mlir::ForwardIterator>(mlir::Operation*, llvm::function_ref<mlir::WalkResult (mlir::Operation*)>, mlir::WalkOrder) llvm-project/mlir/include/mlir/IR/Visitors.h:239:13
    #19 0x595cbb55ac0c in std::enable_if<llvm::is_one_of<mlir::Operation*, mlir::Operation*, mlir::Region*, mlir::Block*>::value, mlir::WalkResult>::type mlir::detail::walk<(mlir::WalkOrder)1, mlir::ForwardIterator, mlir::bufferization::insertTensorCopies(mlir::Operation*, mlir::bufferization::AnalysisState const&, mlir::bufferization::BufferizationState const&)::$_1, mlir::Operation*, mlir::WalkResult>(mlir::Operation*, mlir::bufferization::insertTensorCopies(mlir::Operation*, mlir::bufferization::AnalysisState const&, mlir::bufferization::BufferizationState const&)::$_1&&) llvm-project/mlir/include/mlir/IR/Visitors.h:278:10
    #20 0x595cbb55ac0c in std::enable_if<(llvm::function_traits<std::decay<mlir::bufferization::insertTensorCopies(mlir::Operation*, mlir::bufferization::AnalysisState const&, mlir::bufferization::BufferizationState const&)::$_1>::type>::num_args) == (1), mlir::WalkResult>::type mlir::Operation::walk<(mlir::WalkOrder)1, mlir::ForwardIterator, mlir::bufferization::insertTensorCopies(mlir::Operation*, mlir::bufferization::AnalysisState const&, mlir::bufferization::BufferizationState const&)::$_1, mlir::WalkResult>(mlir::bufferization::insertTensorCopies(mlir::Operation*, mlir::bufferization::AnalysisState const&, mlir::bufferization::BufferizationState const&)::$_1&&) llvm-project/mlir/include/mlir/IR/Operation.h:798:12
    #21 0x595cbb55ac0c in mlir::bufferization::insertTensorCopies(mlir::Operation*, mlir::bufferization::AnalysisState const&, mlir::bufferization::BufferizationState const&) llvm-project/mlir/lib/Dialect/Bufferization/Transforms/TensorCopyInsertion.cpp:59:27
    #22 0x595cbb4ac4e4 in mlir::bufferization::bufferizeOp(mlir::Operation*, mlir::bufferization::BufferizationOptions const&, mlir::bufferization::BufferizationState&, mlir::bufferization::BufferizationStatistics*) llvm-project/mlir/lib/Dialect/Bufferization/Transforms/Bufferize.cpp:283:16
    #23 0x595cbb5388e7 in mlir::bufferization::bufferizeModuleOp(mlir::Operation*, mlir::bufferization::OneShotBufferizationOptions const&, mlir::bufferization::BufferizationState&, mlir::bufferization::BufferizationStatistics*) llvm-project/mlir/lib/Dialect/Bufferization/Transforms/OneShotModuleBufferize.cpp:573:18
    #24 0x595cbb53a308 in mlir::bufferization::runOneShotModuleBufferize(mlir::Operation*, mlir::bufferization::OneShotBufferizationOptions const&, mlir::bufferization::BufferizationState&, mlir::bufferization::BufferizationStatistics*) llvm-project/mlir/lib/Dialect/Bufferization/Transforms/OneShotModuleBufferize.cpp:634:14
    #25 0x595cbb4b51a2 in (anonymous namespace)::OneShotBufferizePass::runOnOperation() llvm-project/mlir/lib/Dialect/Bufferization/Transforms/Bufferize.cpp:168:15
    #26 0x595cbebddf43 in mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int)::$_44::operator()() const llvm-project/mlir/lib/Pass/Pass.cpp:609:17
    #27 0x595cbebddf43 in void llvm::function_ref<void ()>::callback_fn<mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int)::$_44>(long) llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:46:12
    #28 0x595cbebc7119 in llvm::function_ref<void ()>::operator()() const llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:69:12
    #29 0x595cbebc7119 in void mlir::MLIRContext::executeAction<mlir::PassExecutionAction, mlir::Pass&>(llvm::function_ref<void ()>, llvm::ArrayRef<mlir::IRUnit>, mlir::Pass&) llvm-project/mlir/include/mlir/IR/MLIRContext.h:290:7
    #30 0x595cbebc7119 in mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int) llvm-project/mlir/lib/Pass/Pass.cpp:603:21
    #31 0x595cbebc90eb in mlir::detail::OpToOpPassAdaptor::runPipeline(mlir::OpPassManager&, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int, mlir::PassInstrumentor*, mlir::PassInstrumentation::PipelineParentInfo const*) llvm-project/mlir/lib/Pass/Pass.cpp:682:16
    #32 0x595cbebd5237 in mlir::PassManager::runPasses(mlir::Operation*, mlir::AnalysisManager) llvm-project/mlir/lib/Pass/Pass.cpp:1117:10
    #33 0x595cbebd3db3 in mlir::PassManager::run(mlir::Operation*) llvm-project/mlir/lib/Pass/Pass.cpp:1091:60
    #34 0x595cac42f603 in performActions(llvm::raw_ostream&, std::shared_ptr<llvm::SourceMgr> const&, mlir::MLIRContext*, mlir::MlirOptMainConfig const&) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:568:17
    #35 0x595cac42e516 in processBuffer(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef, mlir::MlirOptMainConfig const&, mlir::DialectRegistry&, mlir::SourceMgrDiagnosticVerifierHandler*, llvm::ThreadPoolInterface*) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:644:12
    #36 0x595cac42e516 in mlir::MlirOptMain(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, mlir::DialectRegistry&, mlir::MlirOptMainConfig const&)::$_3::operator()(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef, llvm::raw_ostream&) const llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:733:12
    #37 0x595cac42e516 in llvm::LogicalResult llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>::callback_fn<mlir::MlirOptMain(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, mlir::DialectRegistry&, mlir::MlirOptMainConfig const&)::$_3>(long, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&) llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:46:12
    #38 0x595cbf3f2a63 in llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>::operator()(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&) const llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:69:12
    #39 0x595cbf3f3525 in mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0::operator()(llvm::StringRef) const llvm-project/mlir/lib/Support/ToolUtilities.cpp:94:13
    #40 0x595cbf3f23b1 in void llvm::interleave<llvm::StringRef const*, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0, void llvm::interleave<llvm::SmallVector<llvm::StringRef, 8u>, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0, llvm::raw_ostream, llvm::StringRef>(llvm::SmallVector<llvm::StringRef, 8u> const&, llvm::raw_ostream&, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0, llvm::StringRef const&)::'lambda'(), void>(llvm::SmallVector<llvm::StringRef, 8u>, llvm::SmallVector<llvm::StringRef, 8u>, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0, llvm::raw_ostream) llvm-project/llvm/include/llvm/ADT/STLExtras.h:2199:3
    #41 0x595cbf3f23b1 in void llvm::interleave<llvm::SmallVector<llvm::StringRef, 8u>, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0, llvm::raw_ostream, llvm::StringRef>(llvm::SmallVector<llvm::StringRef, 8u> const&, llvm::raw_ostream&, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0, llvm::StringRef const&) llvm-project/llvm/include/llvm/ADT/STLExtras.h:2221:3
    #42 0x595cbf3f23b1 in mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef) llvm-project/mlir/lib/Support/ToolUtilities.cpp:97:3
    #43 0x595cac413431 in mlir::MlirOptMain(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, mlir::DialectRegistry&, mlir::MlirOptMainConfig const&) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:738:26
    #44 0x595cac413e6d in mlir::MlirOptMain(int, char**, llvm::StringRef, llvm::StringRef, mlir::DialectRegistry&) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:784:14
    #45 0x595cac4145c2 in mlir::MlirOptMain(int, char**, llvm::StringRef, mlir::DialectRegistry&) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:800:10
    #46 0x595cac22c3ce in main llvm-project/mlir/tools/mlir-opt/mlir-opt.cpp:343:33
    #47 0x7c1daae1bd8f in __libc_start_call_main csu/../sysdeps/nptl/libc_start_call_main.h:58:16
    #48 0x7c1daae1be3f in __libc_start_main csu/../csu/libc-start.c:392:3
    #49 0x595cac16bb64 in _start (llvm-mlir-build/bin/mlir-opt+0x8381b64) (BuildId: 8d3f598c321c686de3addc0e0905b4ae76916fb7)

Address 0x7ffcbf29a320 is located in stack of thread T0 at offset 1216 in frame
    #0 0x595cbb4ac1af in mlir::bufferization::bufferizeOp(mlir::Operation*, mlir::bufferization::BufferizationOptions const&, mlir::bufferization::BufferizationState&, mlir::bufferization::BufferizationStatistics*) llvm-project/mlir/lib/Dialect/Bufferization/Transforms/Bufferize.cpp:280

  This frame has 37 object(s):
    [32, 40) 'Val.addr.i.i752'
    [64, 72) 'wrapperFn.i.i735'
    [96, 128) 'agg.tmp.i'
    [160, 168) 'Val.addr.i.i723'
    [192, 240) 'ref.tmp.i704'
    [272, 304) 'ref.tmp.i683'
    [336, 368) 'ref.tmp.i633'
    [400, 408) 'info.i'
    [432, 464) 'ref.tmp.i'
    [496, 504) '__first.i.i.i'
    [528, 536) 'ref.tmp.i.i'
    [560, 568) 'Val.addr.i.i'
    [592, 600) 'wrapperFn.i.i'
    [624, 712) 'analysisState' (line 282)
    [752, 784) 'toBufferOps' (line 288)
    [816, 824) 'ref.tmp' (line 289)
    [848, 912) 'worklist' (line 298)
    [944, 960) 'ref.tmp29' (line 299)
    [976, 1008) 'erasedOps' (line 305)
    [1040, 1216) 'rewriter' (line 308) <== Memory access at offset 1216 overflows this variable
    [1280, 1296) 'bufferizableOp' (line 316)
    [1312, 1520) 'ref.tmp119' (line 326)
    [1584, 1624) 'ref.tmp122' (line 326)
    [1664, 1760) 'ref.tmp157' (line 332)
    [1792, 1824) 'agg.tmp158'
    [1856, 1952) 'ref.tmp235' (line 337)
    [1984, 2016) 'agg.tmp236'
    [2048, 2256) 'ref.tmp261' (line 339)
    [2320, 2360) 'ref.tmp264' (line 339)
    [2400, 2496) 'ref.tmp297' (line 341)
    [2528, 2560) 'agg.tmp298'
    [2592, 2624) '__begin1' (line 349)
    [2656, 2688) '__end1' (line 349)
    [2720, 2728) 'ref.tmp397' (line 356)
    [2752, 2832) 'ref.tmp451' (line 381)
    [2864, 3072) 'ref.tmp467' (line 386)
    [3136, 3176) 'ref.tmp470' (line 386)
HINT: this may be a false positive if your program uses some custom stack unwind mechanism, swapcontext or vfork
      (longjmp and C++ exceptions *are* supported)
SUMMARY: AddressSanitizer: stack-buffer-overflow llvm-project/llvm/include/llvm/ADT/DenseMap.h:829:40 in llvm::DenseMap<mlir::TypeID, std::unique_ptr<mlir::bufferization::OneShotAnalysisState::Extension, std::default_delete<mlir::bufferization::OneShotAnalysisState::Extension> >, llvm::DenseMapInfo<mlir::TypeID, void>, llvm::detail::DenseMapPair<mlir::TypeID, std::unique_ptr<mlir::bufferization::OneShotAnalysisState::Extension, std::default_delete<mlir::bufferization::OneShotAnalysisState::Extension> > > >::getBuckets() const
Shadow bytes around the buggy address:
  0x100017e4b410: f2 f2 f8 f2 f2 f2 f8 f2 f2 f2 00 00 00 00 00 00
  0x100017e4b420: 00 00 00 00 00 f2 f2 f2 f2 f2 f8 f8 f8 f8 f2 f2
  0x100017e4b430: f2 f2 f8 f2 f2 f2 f8 f8 f8 f8 f8 f8 f8 f8 f2 f2
  0x100017e4b440: f2 f2 f8 f8 f2 f2 f8 f8 f8 f8 f2 f2 f2 f2 f8 f8
  0x100017e4b450: f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8
=>0x100017e4b460: f8 f8 f8 f8[f2]f2 f2 f2 f2 f2 f2 f2 f8 f8 f2 f2
  0x100017e4b470: f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8
  0x100017e4b480: f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f2 f2 f2 f2 f2 f2
  0x100017e4b490: f2 f2 f8 f8 f8 f8 f8 f2 f2 f2 f2 f2 f8 f8 f8 f8
  0x100017e4b4a0: f8 f8 f8 f8 f8 f8 f8 f8 f2 f2 f2 f2 00 00 00 00
  0x100017e4b4b0: f2 f2 f2 f2 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8
Shadow byte legend (one shadow byte represents 8 application bytes):
  Addressable:           00
  Partially addressable: 01 02 03 04 05 06 07 
  Heap left redzone:       fa
  Freed heap region:       fd
  Stack left redzone:      f1
  Stack mid redzone:       f2
  Stack right redzone:     f3
  Stack after return:      f5
  Stack use after scope:   f8
  Global redzone:          f9
  Global init order:       f6
  Poisoned by user:        f7
  Container overflow:      fc
  Array cookie:            ac
  Intra object redzone:    bb
  ASan internal:           fe
  Left alloca redzone:     ca
  Right alloca redzone:    cb
==2343068==ABORTING
```

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
