# [mlir] UAF in mlir/include/mlir/IR/Block.h

**Issue:** [https://github.com/llvm/llvm-project/issues/163051](https://github.com/llvm/llvm-project/issues/163051) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-12T08:24:26Z`

**Labels:** `code-quality`, `mlir`

## Description

```
llvm.func @repeated_successor(%arg0: i64, %arg1: i64, %arg2: i64, %arg3: i1) {
    omp.wsloop {
      omp.loop_nest (%arg4) : i64 = (%arg0) to (%arg1) step (%arg2)  {
        llvm.cond_br %arg3, ^bb1(%arg0 : i64), ^bb1(%arg1 : i64)
      ^bb1(%0: i64):  // 2 preds: ^bb0, ^bb0
        omp.yield
      }
    }
    llvm.return
  }
```

repro: `mlir-opt ./test.mlir -remove-dead-values -split-input-file -verify-diagnostics`

stderr:
```
=================================================================
==2252528==ERROR: AddressSanitizer: heap-use-after-free on address 0x60200000b170 at pc 0x5ff94c553f04 bp 0x7ffe0ef2a8f0 sp 0x7ffe0ef2a8e8
READ of size 8 at 0x60200000b170 thread T0
    #0 0x5ff94c553f03 in mlir::Block::getArgument(unsigned int) llvm-project/mlir/include/mlir/IR/Block.h:129:50
    #1 0x5ff94c553f03 in (anonymous namespace)::cleanUpDeadVals((anonymous namespace)::RDVFinalCleanupList&) llvm-project/mlir/lib/Transforms/RemoveDeadValues.cpp:836:12
    #2 0x5ff94c54cf3b in (anonymous namespace)::RemoveDeadValues::runOnOperation() llvm-project/mlir/lib/Transforms/RemoveDeadValues.cpp:902:3
    #3 0x5ff94c7bbf43 in mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int)::$_44::operator()() const llvm-project/mlir/lib/Pass/Pass.cpp:609:17
    #4 0x5ff94c7bbf43 in void llvm::function_ref<void ()>::callback_fn<mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int)::$_44>(long) llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:46:12
    #5 0x5ff94c7a5119 in llvm::function_ref<void ()>::operator()() const llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:69:12
    #6 0x5ff94c7a5119 in void mlir::MLIRContext::executeAction<mlir::PassExecutionAction, mlir::Pass&>(llvm::function_ref<void ()>, llvm::ArrayRef<mlir::IRUnit>, mlir::Pass&) llvm-project/mlir/include/mlir/IR/MLIRContext.h:290:7
    #7 0x5ff94c7a5119 in mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int) llvm-project/mlir/lib/Pass/Pass.cpp:603:21
    #8 0x5ff94c7a70eb in mlir::detail::OpToOpPassAdaptor::runPipeline(mlir::OpPassManager&, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int, mlir::PassInstrumentor*, mlir::PassInstrumentation::PipelineParentInfo const*) llvm-project/mlir/lib/Pass/Pass.cpp:682:16
    #9 0x5ff94c7b3237 in mlir::PassManager::runPasses(mlir::Operation*, mlir::AnalysisManager) llvm-project/mlir/lib/Pass/Pass.cpp:1117:10
    #10 0x5ff94c7b1db3 in mlir::PassManager::run(mlir::Operation*) llvm-project/mlir/lib/Pass/Pass.cpp:1091:60
    #11 0x5ff93a00d603 in performActions(llvm::raw_ostream&, std::shared_ptr<llvm::SourceMgr> const&, mlir::MLIRContext*, mlir::MlirOptMainConfig const&) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:568:17
    #12 0x5ff93a00c32f in processBuffer(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef, mlir::MlirOptMainConfig const&, mlir::DialectRegistry&, mlir::SourceMgrDiagnosticVerifierHandler*, llvm::ThreadPoolInterface*) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:650:9
    #13 0x5ff93a00c32f in mlir::MlirOptMain(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, mlir::DialectRegistry&, mlir::MlirOptMainConfig const&)::$_3::operator()(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef, llvm::raw_ostream&) const llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:733:12
    #14 0x5ff93a00c32f in llvm::LogicalResult llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>::callback_fn<mlir::MlirOptMain(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, mlir::DialectRegistry&, mlir::MlirOptMainConfig const&)::$_3>(long, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&) llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:46:12
    #15 0x5ff94cfd0a63 in llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>::operator()(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&) const llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:69:12
    #16 0x5ff94cfd1525 in mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0::operator()(llvm::StringRef) const llvm-project/mlir/lib/Support/ToolUtilities.cpp:94:13
    #17 0x5ff94cfd03b1 in void llvm::interleave<llvm::StringRef const*, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0, void llvm::interleave<llvm::SmallVector<llvm::StringRef, 8u>, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0, llvm::raw_ostream, llvm::StringRef>(llvm::SmallVector<llvm::StringRef, 8u> const&, llvm::raw_ostream&, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0, llvm::StringRef const&)::'lambda'(), void>(llvm::SmallVector<llvm::StringRef, 8u>, llvm::SmallVector<llvm::StringRef, 8u>, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0, llvm::raw_ostream) llvm-project/llvm/include/llvm/ADT/STLExtras.h:2199:3
    #18 0x5ff94cfd03b1 in void llvm::interleave<llvm::SmallVector<llvm::StringRef, 8u>, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0, llvm::raw_ostream, llvm::StringRef>(llvm::SmallVector<llvm::StringRef, 8u> const&, llvm::raw_ostream&, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0, llvm::StringRef const&) llvm-project/llvm/include/llvm/ADT/STLExtras.h:2221:3
    #19 0x5ff94cfd03b1 in mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef) llvm-project/mlir/lib/Support/ToolUtilities.cpp:97:3
    #20 0x5ff939ff1431 in mlir::MlirOptMain(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, mlir::DialectRegistry&, mlir::MlirOptMainConfig const&) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:738:26
    #21 0x5ff939ff1e6d in mlir::MlirOptMain(int, char**, llvm::StringRef, llvm::StringRef, mlir::DialectRegistry&) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:784:14
    #22 0x5ff939ff25c2 in mlir::MlirOptMain(int, char**, llvm::StringRef, mlir::DialectRegistry&) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:800:10
    #23 0x5ff939e0a3ce in main llvm-project/mlir/tools/mlir-opt/mlir-opt.cpp:343:33
    #24 0x7f128dcf9d8f in __libc_start_call_main csu/../sysdeps/nptl/libc_start_call_main.h:58:16
    #25 0x7f128dcf9e3f in __libc_start_main csu/../csu/libc-start.c:392:3
    #26 0x5ff939d49b64 in _start (llvm-mlir-build/bin/mlir-opt+0x8381b64) (BuildId: 8d3f598c321c686de3addc0e0905b4ae76916fb7)

0x60200000b170 is located 0 bytes inside of 8-byte region [0x60200000b170,0x60200000b178)
freed by thread T0 here:
    #0 0x5ff939e07fdd in operator delete(void*) (llvm-mlir-build/bin/mlir-opt+0x843ffdd) (BuildId: 8d3f598c321c686de3addc0e0905b4ae76916fb7)
    #1 0x5ff94cce0e32 in std::_Vector_base<mlir::BlockArgument, std::allocator<mlir::BlockArgument> >::_M_deallocate(mlir::BlockArgument*, unsigned long) /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/stl_vector.h:354:4
    #2 0x5ff94cce0e32 in std::_Vector_base<mlir::BlockArgument, std::allocator<mlir::BlockArgument> >::~_Vector_base() /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/stl_vector.h:335:2
    #3 0x5ff94cce0e32 in std::vector<mlir::BlockArgument, std::allocator<mlir::BlockArgument> >::~vector() /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/stl_vector.h:683:7
    #4 0x5ff94cce07e7 in mlir::Block::~Block() llvm-project/mlir/lib/IR/Block.cpp:25:1
    #5 0x5ff93b1df33b in llvm::ilist_alloc_traits<mlir::Block>::deleteNode(mlir::Block*) llvm-project/llvm/include/llvm/ADT/ilist.h:42:39
    #6 0x5ff93b1df33b in llvm::iplist_impl<llvm::simple_ilist<mlir::Block>, llvm::ilist_traits<mlir::Block> >::erase(llvm::ilist_iterator<llvm::ilist_detail::node_options<mlir::Block, true, false, void, false, void>, false, false>) llvm-project/llvm/include/llvm/ADT/ilist.h:205:5
    #7 0x5ff93b1df33b in llvm::iplist_impl<llvm::simple_ilist<mlir::Block>, llvm::ilist_traits<mlir::Block> >::erase(llvm::ilist_iterator<llvm::ilist_detail::node_options<mlir::Block, true, false, void, false, void>, false, false>, llvm::ilist_iterator<llvm::ilist_detail::node_options<mlir::Block, true, false, void, false, void>, false, false>) llvm-project/llvm/include/llvm/ADT/ilist.h:242:15
    #8 0x5ff94cf5cfce in llvm::iplist_impl<llvm::simple_ilist<mlir::Block>, llvm::ilist_traits<mlir::Block> >::clear() llvm-project/llvm/include/llvm/ADT/ilist.h:246:18
    #9 0x5ff94cf5cfce in llvm::iplist_impl<llvm::simple_ilist<mlir::Block>, llvm::ilist_traits<mlir::Block> >::~iplist_impl() llvm-project/llvm/include/llvm/ADT/ilist.h:147:20
    #10 0x5ff94cf5cfce in mlir::Region::~Region() llvm-project/mlir/lib/IR/Region.cpp:20:1
    #11 0x5ff94cf211da in mlir::Operation::~Operation() llvm-project/mlir/lib/IR/Operation.cpp:201:12
    #12 0x5ff94cf21d5d in mlir::Operation::destroy() llvm-project/mlir/lib/IR/Operation.cpp:212:9
    #13 0x5ff94cf24d2f in llvm::ilist_traits<mlir::Operation>::deleteNode(mlir::Operation*) llvm-project/mlir/lib/IR/Operation.cpp:491:7
    #14 0x5ff94cf24d2f in llvm::iplist_impl<llvm::simple_ilist<mlir::Operation>, llvm::ilist_traits<mlir::Operation> >::erase(llvm::ilist_iterator<llvm::ilist_detail::node_options<mlir::Operation, true, false, void, false, void>, false, false>) llvm-project/llvm/include/llvm/ADT/ilist.h:205:5
    #15 0x5ff94cf24d2f in llvm::iplist_impl<llvm::simple_ilist<mlir::Operation>, llvm::ilist_traits<mlir::Operation> >::erase(mlir::Operation*) llvm-project/llvm/include/llvm/ADT/ilist.h:209:39
    #16 0x5ff94c54e3f5 in (anonymous namespace)::cleanUpDeadVals((anonymous namespace)::RDVFinalCleanupList&) llvm-project/mlir/lib/Transforms/RemoveDeadValues.cpp:740:9
    #17 0x5ff94c54cf3b in (anonymous namespace)::RemoveDeadValues::runOnOperation() llvm-project/mlir/lib/Transforms/RemoveDeadValues.cpp:902:3
    #18 0x5ff94c7bbf43 in mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int)::$_44::operator()() const llvm-project/mlir/lib/Pass/Pass.cpp:609:17
    #19 0x5ff94c7bbf43 in void llvm::function_ref<void ()>::callback_fn<mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int)::$_44>(long) llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:46:12
    #20 0x5ff94c7a5119 in llvm::function_ref<void ()>::operator()() const llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:69:12
    #21 0x5ff94c7a5119 in void mlir::MLIRContext::executeAction<mlir::PassExecutionAction, mlir::Pass&>(llvm::function_ref<void ()>, llvm::ArrayRef<mlir::IRUnit>, mlir::Pass&) llvm-project/mlir/include/mlir/IR/MLIRContext.h:290:7
    #22 0x5ff94c7a5119 in mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int) llvm-project/mlir/lib/Pass/Pass.cpp:603:21
    #23 0x5ff94c7a70eb in mlir::detail::OpToOpPassAdaptor::runPipeline(mlir::OpPassManager&, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int, mlir::PassInstrumentor*, mlir::PassInstrumentation::PipelineParentInfo const*) llvm-project/mlir/lib/Pass/Pass.cpp:682:16
    #24 0x5ff94c7b3237 in mlir::PassManager::runPasses(mlir::Operation*, mlir::AnalysisManager) llvm-project/mlir/lib/Pass/Pass.cpp:1117:10
    #25 0x5ff94c7b1db3 in mlir::PassManager::run(mlir::Operation*) llvm-project/mlir/lib/Pass/Pass.cpp:1091:60
    #26 0x5ff93a00d603 in performActions(llvm::raw_ostream&, std::shared_ptr<llvm::SourceMgr> const&, mlir::MLIRContext*, mlir::MlirOptMainConfig const&) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:568:17
    #27 0x5ff93a00c32f in processBuffer(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef, mlir::MlirOptMainConfig const&, mlir::DialectRegistry&, mlir::SourceMgrDiagnosticVerifierHandler*, llvm::ThreadPoolInterface*) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:650:9
    #28 0x5ff93a00c32f in mlir::MlirOptMain(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, mlir::DialectRegistry&, mlir::MlirOptMainConfig const&)::$_3::operator()(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef, llvm::raw_ostream&) const llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:733:12
    #29 0x5ff93a00c32f in llvm::LogicalResult llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>::callback_fn<mlir::MlirOptMain(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, mlir::DialectRegistry&, mlir::MlirOptMainConfig const&)::$_3>(long, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&) llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:46:12
    #30 0x5ff94cfd0a63 in llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>::operator()(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&) const llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:69:12
    #31 0x5ff94cfd1525 in mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0::operator()(llvm::StringRef) const llvm-project/mlir/lib/Support/ToolUtilities.cpp:94:13
    #32 0x5ff94cfd03b1 in void llvm::interleave<llvm::StringRef const*, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0, void llvm::interleave<llvm::SmallVector<llvm::StringRef, 8u>, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0, llvm::raw_ostream, llvm::StringRef>(llvm::SmallVector<llvm::StringRef, 8u> const&, llvm::raw_ostream&, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0, llvm::StringRef const&)::'lambda'(), void>(llvm::SmallVector<llvm::StringRef, 8u>, llvm::SmallVector<llvm::StringRef, 8u>, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0, llvm::raw_ostream) llvm-project/llvm/include/llvm/ADT/STLExtras.h:2199:3
    #33 0x5ff94cfd03b1 in void llvm::interleave<llvm::SmallVector<llvm::StringRef, 8u>, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0, llvm::raw_ostream, llvm::StringRef>(llvm::SmallVector<llvm::StringRef, 8u> const&, llvm::raw_ostream&, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0, llvm::StringRef const&) llvm-project/llvm/include/llvm/ADT/STLExtras.h:2221:3
    #34 0x5ff94cfd03b1 in mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef) llvm-project/mlir/lib/Support/ToolUtilities.cpp:97:3
    #35 0x5ff939ff1431 in mlir::MlirOptMain(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, mlir::DialectRegistry&, mlir::MlirOptMainConfig const&) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:738:26
    #36 0x5ff939ff1e6d in mlir::MlirOptMain(int, char**, llvm::StringRef, llvm::StringRef, mlir::DialectRegistry&) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:784:14
    #37 0x5ff939ff25c2 in mlir::MlirOptMain(int, char**, llvm::StringRef, mlir::DialectRegistry&) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:800:10
    #38 0x5ff939e0a3ce in main llvm-project/mlir/tools/mlir-opt/mlir-opt.cpp:343:33
    #39 0x7f128dcf9d8f in __libc_start_call_main csu/../sysdeps/nptl/libc_start_call_main.h:58:16

previously allocated by thread T0 here:
    #0 0x5ff939e0777d in operator new(unsigned long) (llvm-mlir-build/bin/mlir-opt+0x843f77d) (BuildId: 8d3f598c321c686de3addc0e0905b4ae76916fb7)
    #1 0x5ff94cce69f1 in void std::vector<mlir::BlockArgument, std::allocator<mlir::BlockArgument> >::_M_realloc_insert<mlir::BlockArgument const&>(__gnu_cxx::__normal_iterator<mlir::BlockArgument*, std::vector<mlir::BlockArgument, std::allocator<mlir::BlockArgument> > >, mlir::BlockArgument const&) /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/vector.tcc:440:33
    #2 0x5ff94cce21f5 in mlir::Block::addArgument(mlir::Type, mlir::Location) llvm-project/mlir/lib/IR/Block.cpp:155:13
    #3 0x5ff948daceac in (anonymous namespace)::OperationParser::parseOptionalBlockArgList(mlir::Block*)::$_13::operator()() const::'lambda'(mlir::OpAsmParser::UnresolvedOperand, mlir::Type)::operator()(mlir::OpAsmParser::UnresolvedOperand, mlir::Type) const llvm-project/mlir/lib/AsmParser/Parser.cpp:2496:26
    #4 0x5ff948daceac in llvm::ParseResult llvm::function_ref<llvm::ParseResult (mlir::OpAsmParser::UnresolvedOperand, mlir::Type)>::callback_fn<(anonymous namespace)::OperationParser::parseOptionalBlockArgList(mlir::Block*)::$_13::operator()() const::'lambda'(mlir::OpAsmParser::UnresolvedOperand, mlir::Type)>(long, mlir::OpAsmParser::UnresolvedOperand, mlir::Type) llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:46:12
    #5 0x5ff948daceac in llvm::function_ref<llvm::ParseResult (mlir::OpAsmParser::UnresolvedOperand, mlir::Type)>::operator()(mlir::OpAsmParser::UnresolvedOperand, mlir::Type) const llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:69:12
    #6 0x5ff948daceac in (anonymous namespace)::OperationParser::parseSSADefOrUseAndType(llvm::function_ref<llvm::ParseResult (mlir::OpAsmParser::UnresolvedOperand, mlir::Type)>) llvm-project/mlir/lib/AsmParser/Parser.cpp:1140:10
    #7 0x5ff948daceac in (anonymous namespace)::OperationParser::parseOptionalBlockArgList(mlir::Block*)::$_13::operator()() const llvm-project/mlir/lib/AsmParser/Parser.cpp:2479:12
    #8 0x5ff948daceac in llvm::ParseResult llvm::function_ref<llvm::ParseResult ()>::callback_fn<(anonymous namespace)::OperationParser::parseOptionalBlockArgList(mlir::Block*)::$_13>(long) llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:46:12
    #9 0x5ff948d7e85c in llvm::function_ref<llvm::ParseResult ()>::operator()() const llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:69:12
    #10 0x5ff948d7e85c in mlir::detail::Parser::parseCommaSeparatedList(mlir::AsmParser::Delimiter, llvm::function_ref<llvm::ParseResult ()>, llvm::StringRef) llvm-project/mlir/lib/AsmParser/Parser.cpp:138:7
    #11 0x5ff948daae46 in (anonymous namespace)::OperationParser::parseOptionalBlockArgList(mlir::Block*) llvm-project/mlir/lib/AsmParser/Parser.cpp:2478:10
    #12 0x5ff948daae46 in (anonymous namespace)::OperationParser::parseBlock(mlir::Block*&) llvm-project/mlir/lib/AsmParser/Parser.cpp:2419:9
    #13 0x5ff948da41aa in (anonymous namespace)::OperationParser::parseRegionBody(mlir::Region&, llvm::SMLoc, llvm::ArrayRef<mlir::OpAsmParser::Argument>, bool) llvm-project/mlir/lib/AsmParser/Parser.cpp:2341:9
    #14 0x5ff948da41aa in (anonymous namespace)::OperationParser::parseRegion(mlir::Region&, llvm::ArrayRef<mlir::OpAsmParser::Argument>, bool) llvm-project/mlir/lib/AsmParser/Parser.cpp:2257:7
    #15 0x5ff948d9ec5e in (anonymous namespace)::CustomOpAsmParser::parseRegion(mlir::Region&, llvm::ArrayRef<mlir::OpAsmParser::Argument>, bool) llvm-project/mlir/lib/AsmParser/Parser.cpp:1879:16
    #16 0x5ff9421f07cb in mlir::omp::LoopNestOp::parse(mlir::OpAsmParser&, mlir::OperationState&) llvm-project/mlir/lib/Dialect/OpenMP/IR/OpenMPDialect.cpp:3264:14
    #17 0x5ff948d87de8 in llvm::ParseResult llvm::function_ref<llvm::ParseResult (mlir::OpAsmParser&, mlir::OperationState&)>::callback_fn<llvm::unique_function<llvm::ParseResult (mlir::OpAsmParser&, mlir::OperationState&)> >(long, mlir::OpAsmParser&, mlir::OperationState&) llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:46:12
    #18 0x5ff948d87de8 in llvm::function_ref<llvm::ParseResult (mlir::OpAsmParser&, mlir::OperationState&)>::operator()(mlir::OpAsmParser&, mlir::OperationState&) const llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:69:12
    #19 0x5ff948d87de8 in (anonymous namespace)::CustomOpAsmParser::parseOperation(mlir::OperationState&) llvm-project/mlir/lib/AsmParser/Parser.cpp:1615:9
    #20 0x5ff948d87de8 in (anonymous namespace)::OperationParser::parseCustomOperation(llvm::ArrayRef<std::tuple<llvm::StringRef, unsigned int, llvm::SMLoc> >) llvm-project/mlir/lib/AsmParser/Parser.cpp:2154:19
    #21 0x5ff948d87de8 in (anonymous namespace)::OperationParser::parseOperation() llvm-project/mlir/lib/AsmParser/Parser.cpp:1268:10
    #22 0x5ff948dac5fa in (anonymous namespace)::OperationParser::parseBlockBody(mlir::Block*) llvm-project/mlir/lib/AsmParser/Parser.cpp:2440:9
    #23 0x5ff948daaa26 in (anonymous namespace)::OperationParser::parseBlock(mlir::Block*&) llvm-project/mlir/lib/AsmParser/Parser.cpp:2370:12
    #24 0x5ff948da3edc in (anonymous namespace)::OperationParser::parseRegionBody(mlir::Region&, llvm::SMLoc, llvm::ArrayRef<mlir::OpAsmParser::Argument>, bool) llvm-project/mlir/lib/AsmParser/Parser.cpp:2328:7
    #25 0x5ff948da3edc in (anonymous namespace)::OperationParser::parseRegion(mlir::Region&, llvm::ArrayRef<mlir::OpAsmParser::Argument>, bool) llvm-project/mlir/lib/AsmParser/Parser.cpp:2257:7
    #26 0x5ff948d9ec5e in (anonymous namespace)::CustomOpAsmParser::parseRegion(mlir::Region&, llvm::ArrayRef<mlir::OpAsmParser::Argument>, bool) llvm-project/mlir/lib/AsmParser/Parser.cpp:1879:16
    #27 0x5ff9424525b4 in parseBlockArgRegion(mlir::OpAsmParser&, mlir::Region&, (anonymous namespace)::AllRegionParseArgs) llvm-project/mlir/lib/Dialect/OpenMP/IR/OpenMPDialect.cpp:1057:17
    #28 0x5ff9422b7920 in parsePrivateReductionRegion(mlir::OpAsmParser&, mlir::Region&, llvm::SmallVectorImpl<mlir::OpAsmParser::UnresolvedOperand>&, llvm::SmallVectorImpl<mlir::Type>&, mlir::ArrayAttr&, mlir::UnitAttr&, mlir::omp::ReductionModifierAttr&, llvm::SmallVectorImpl<mlir::OpAsmParser::UnresolvedOperand>&, llvm::SmallVectorImpl<mlir::Type>&, mlir::detail::DenseArrayAttrImpl<bool>&, mlir::ArrayAttr&) llvm-project/mlir/lib/Dialect/OpenMP/IR/OpenMPDialect.cpp:1148:10
    #29 0x5ff942437e18 in mlir::omp::WsloopOp::parse(mlir::OpAsmParser&, mlir::OperationState&) llvm-mlir-build/tools/mlir/include/mlir/Dialect/OpenMP/OpenMPOps.cpp.inc:32491:22
    #30 0x5ff948d87de8 in llvm::ParseResult llvm::function_ref<llvm::ParseResult (mlir::OpAsmParser&, mlir::OperationState&)>::callback_fn<llvm::unique_function<llvm::ParseResult (mlir::OpAsmParser&, mlir::OperationState&)> >(long, mlir::OpAsmParser&, mlir::OperationState&) llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:46:12
    #31 0x5ff948d87de8 in llvm::function_ref<llvm::ParseResult (mlir::OpAsmParser&, mlir::OperationState&)>::operator()(mlir::OpAsmParser&, mlir::OperationState&) const llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:69:12
    #32 0x5ff948d87de8 in (anonymous namespace)::CustomOpAsmParser::parseOperation(mlir::OperationState&) llvm-project/mlir/lib/AsmParser/Parser.cpp:1615:9
    #33 0x5ff948d87de8 in (anonymous namespace)::OperationParser::parseCustomOperation(llvm::ArrayRef<std::tuple<llvm::StringRef, unsigned int, llvm::SMLoc> >) llvm-project/mlir/lib/AsmParser/Parser.cpp:2154:19
    #34 0x5ff948d87de8 in (anonymous namespace)::OperationParser::parseOperation() llvm-project/mlir/lib/AsmParser/Parser.cpp:1268:10
    #35 0x5ff948dac5fa in (anonymous namespace)::OperationParser::parseBlockBody(mlir::Block*) llvm-project/mlir/lib/AsmParser/Parser.cpp:2440:9
    #36 0x5ff948daaa26 in (anonymous namespace)::OperationParser::parseBlock(mlir::Block*&) llvm-project/mlir/lib/AsmParser/Parser.cpp:2370:12
    #37 0x5ff948da3edc in (anonymous namespace)::OperationParser::parseRegionBody(mlir::Region&, llvm::SMLoc, llvm::ArrayRef<mlir::OpAsmParser::Argument>, bool) llvm-project/mlir/lib/AsmParser/Parser.cpp:2328:7
    #38 0x5ff948da3edc in (anonymous namespace)::OperationParser::parseRegion(mlir::Region&, llvm::ArrayRef<mlir::OpAsmParser::Argument>, bool) llvm-project/mlir/lib/AsmParser/Parser.cpp:2257:7
    #39 0x5ff948d9ec5e in (anonymous namespace)::CustomOpAsmParser::parseRegion(mlir::Region&, llvm::ArrayRef<mlir::OpAsmParser::Argument>, bool) llvm-project/mlir/lib/AsmParser/Parser.cpp:1879:16
    #40 0x5ff948d9ed99 in (anonymous namespace)::CustomOpAsmParser::parseOptionalRegion(mlir::Region&, llvm::ArrayRef<mlir::OpAsmParser::Argument>, bool) llvm-project/mlir/lib/AsmParser/Parser.cpp:1890:12
    #41 0x5ff94a880475 in mlir::LLVM::LLVMFuncOp::parse(mlir::OpAsmParser&, mlir::OperationState&) llvm-project/mlir/lib/Dialect/LLVMIR/IR/LLVMDialect.cpp:3004:14
    #42 0x5ff948d87de8 in llvm::ParseResult llvm::function_ref<llvm::ParseResult (mlir::OpAsmParser&, mlir::OperationState&)>::callback_fn<llvm::unique_function<llvm::ParseResult (mlir::OpAsmParser&, mlir::OperationState&)> >(long, mlir::OpAsmParser&, mlir::OperationState&) llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:46:12
    #43 0x5ff948d87de8 in llvm::function_ref<llvm::ParseResult (mlir::OpAsmParser&, mlir::OperationState&)>::operator()(mlir::OpAsmParser&, mlir::OperationState&) const llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:69:12
    #44 0x5ff948d87de8 in (anonymous namespace)::CustomOpAsmParser::parseOperation(mlir::OperationState&) llvm-project/mlir/lib/AsmParser/Parser.cpp:1615:9
    #45 0x5ff948d87de8 in (anonymous namespace)::OperationParser::parseCustomOperation(llvm::ArrayRef<std::tuple<llvm::StringRef, unsigned int, llvm::SMLoc> >) llvm-project/mlir/lib/AsmParser/Parser.cpp:2154:19
    #46 0x5ff948d87de8 in (anonymous namespace)::OperationParser::parseOperation() llvm-project/mlir/lib/AsmParser/Parser.cpp:1268:10
    #47 0x5ff948d8496b in (anonymous namespace)::TopLevelOperationParser::parse(mlir::Block*, mlir::Location) llvm-project/mlir/lib/AsmParser/Parser.cpp:2870:20
    #48 0x5ff948d8496b in mlir::parseAsmSourceFile(llvm::SourceMgr const&, mlir::Block*, mlir::ParserConfig const&, mlir::AsmParserState*, mlir::AsmParserCodeCompleteContext*) llvm-project/mlir/lib/AsmParser/Parser.cpp:2930:41
    #49 0x5ff948d34ce3 in mlir::parseSourceFile(std::shared_ptr<llvm::SourceMgr> const&, mlir::Block*, mlir::ParserConfig const&, mlir::LocationAttr*) llvm-project/mlir/lib/Parser/Parser.cpp:64:10
    #50 0x5ff93a00f454 in mlir::OwningOpRef<mlir::ModuleOp> mlir::detail::parseSourceFile<mlir::ModuleOp, std::shared_ptr<llvm::SourceMgr> const&>(mlir::ParserConfig const&, std::shared_ptr<llvm::SourceMgr> const&) llvm-project/mlir/include/mlir/Parser/Parser.h:158:14
    #51 0x5ff93a00ec07 in mlir::OwningOpRef<mlir::ModuleOp> mlir::parseSourceFile<mlir::ModuleOp>(std::shared_ptr<llvm::SourceMgr> const&, mlir::ParserConfig const&) llvm-project/mlir/include/mlir/Parser/Parser.h:188:10
    #52 0x5ff93a00ec07 in mlir::parseSourceFileForTool(std::shared_ptr<llvm::SourceMgr> const&, mlir::ParserConfig const&, bool) llvm-project/mlir/include/mlir/Tools/ParseUtilities.h:31:12
    #53 0x5ff93a00cd5f in performActions(llvm::raw_ostream&, std::shared_ptr<llvm::SourceMgr> const&, mlir::MLIRContext*, mlir::MlirOptMainConfig const&) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:508:33

SUMMARY: AddressSanitizer: heap-use-after-free llvm-project/mlir/include/mlir/IR/Block.h:129:50 in mlir::Block::getArgument(unsigned int)
Shadow bytes around the buggy address:
  0x0c047fff95d0: fa fa 00 fa fa fa 00 00 fa fa 00 00 fa fa 00 00
  0x0c047fff95e0: fa fa 00 00 fa fa 00 00 fa fa 00 00 fa fa 00 fa
  0x0c047fff95f0: fa fa 00 fa fa fa 00 fa fa fa 00 00 fa fa 00 00
  0x0c047fff9600: fa fa 00 00 fa fa 00 00 fa fa 00 00 fa fa 00 00
  0x0c047fff9610: fa fa 00 fa fa fa 00 fa fa fa 00 00 fa fa 00 fa
=>0x0c047fff9620: fa fa 00 fa fa fa fd fa fa fa fd fd fa fa[fd]fa
  0x0c047fff9630: fa fa fd fd fa fa 00 fa fa fa 00 fa fa fa 00 fa
  0x0c047fff9640: fa fa fd fd fa fa 00 00 fa fa 00 00 fa fa 00 00
  0x0c047fff9650: fa fa 00 00 fa fa fa fa fa fa fa fa fa fa fa fa
  0x0c047fff9660: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x0c047fff9670: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
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
==2252528==ABORTING
```

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
