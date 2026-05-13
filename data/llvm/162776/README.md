# [mlir] integer overflow in BufferizableOpInterfaceImpl.cpp

**Issue:** [https://github.com/llvm/llvm-project/issues/162776](https://github.com/llvm/llvm-project/issues/162776) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-10T04:43:42Z`

**Labels:** `mlir:tensor`, `crash`

## Description

PoC:
```
func.func @B_concat(%arg0: tensor<4x7x3xf32>, %arg1 : tensor<4x4x3xf32>, %arg2: tensor<?x?x?xf32>) {
    %3 = tensor.concat dim(1) %arg2, %arg2 : (tensor<?x?x?xf32>, tensor<?x?x?xf32>) -> tensor<?x10x?xf32>
    return
  }
```

reproduce: `-allow-unregistered-dialect -one-shot-bufferize=allow-unknown-ops -split-input-file`

stderr:
```
SUMMARY: UndefinedBehaviorSanitizer: undefined-behavior llvm-project/mlir/lib/Dialect/Tensor/Transforms/BufferizableOpInterfaceImpl.cpp:1202:25 in 
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and instructions to reproduce the bug.
Stack dump:
0.	Program arguments: llvm-mlir-build/bin/mlir-opt /tmp/mlirfuzz_run_sh1skl6n/fused.mlir -allow-unregistered-dialect -one-shot-bufferize=allow-unknown-ops -split-input-file
 #0 0x00006544676a969b backtrace (llvm-mlir-build/bin/mlir-opt+0x83bd69b)
 #1 0x0000654467776ad7 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) llvm-project/llvm/lib/Support/Unix/Signals.inc:838:8
 #2 0x0000654467770dbf llvm::sys::RunSignalHandlers() llvm-project/llvm/lib/Support/Signals.cpp:105:18
 #3 0x0000654467779e16 SignalHandler(int, siginfo_t*, void*) llvm-project/llvm/lib/Support/Unix/Signals.inc:426:38
 #4 0x00007c5784c81520 (/lib/x86_64-linux-gnu/libc.so.6+0x42520)
 #5 0x00007c5784cd59fc __pthread_kill_implementation ./nptl/pthread_kill.c:44:76
 #6 0x00007c5784cd59fc __pthread_kill_internal ./nptl/pthread_kill.c:78:10
 #7 0x00007c5784cd59fc pthread_kill ./nptl/pthread_kill.c:89:10
 #8 0x00007c5784c81476 gsignal ./signal/../sysdeps/posix/raise.c:27:6
 #9 0x00007c5784c677f3 abort ./stdlib/abort.c:81:7
#10 0x0000654467714d07 (llvm-mlir-build/bin/mlir-opt+0x8428d07)
#11 0x0000654467712ba1 (llvm-mlir-build/bin/mlir-opt+0x8426ba1)
#12 0x00006544677268ec __ubsan::ScopedReport::~ScopedReport() (llvm-mlir-build/bin/mlir-opt+0x843a8ec)
#13 0x0000654467727cae void handleIntegerOverflowImpl<__ubsan::Value>(__ubsan::OverflowData*, unsigned long, char const*, __ubsan::Value, __ubsan::ReportOptions) ubsan_handlers.cpp.o:0:0
#14 0x0000654467727d7c __ubsan_handle_add_overflow_abort (llvm-mlir-build/bin/mlir-opt+0x843bd7c)
#15 0x00006544759f5ec4 mlir::tensor::(anonymous namespace)::ConcatOpInterface::bufferize(mlir::Operation*, mlir::RewriterBase&, mlir::bufferization::BufferizationOptions const&, mlir::bufferization::BufferizationState&) const llvm-project/mlir/lib/Dialect/Tensor/Transforms/BufferizableOpInterfaceImpl.cpp:0:0
#16 0x00006544759f5ec4 mlir::bufferization::detail::BufferizableOpInterfaceInterfaceTraits::FallbackModel<mlir::tensor::(anonymous namespace)::ConcatOpInterface>::bufferize(mlir::bufferization::detail::BufferizableOpInterfaceInterfaceTraits::Concept const*, mlir::Operation*, mlir::RewriterBase&, mlir::bufferization::BufferizationOptions const&, mlir::bufferization::BufferizationState&) llvm-mlir-build/tools/mlir/include/mlir/Dialect/Bufferization/IR/BufferizableOpInterface.h.inc:1127:49
#17 0x00006544769aef82 llvm::LogicalResult::failed() const llvm-project/llvm/include/llvm/Support/LogicalResult.h:43:43
#18 0x00006544769aef82 llvm::failed(llvm::LogicalResult) llvm-project/llvm/include/llvm/Support/LogicalResult.h:71:58
#19 0x00006544769aef82 mlir::bufferization::bufferizeOp(mlir::Operation*, mlir::bufferization::BufferizationOptions const&, mlir::bufferization::BufferizationState&, mlir::bufferization::BufferizationStatistics*) llvm-project/mlir/lib/Dialect/Bufferization/Transforms/Bufferize.cpp:335:9
#20 0x00006544769b82b4 llvm::LogicalResult::failed() const llvm-project/llvm/include/llvm/Support/LogicalResult.h:43:43
#21 0x00006544769b82b4 llvm::failed(llvm::LogicalResult) llvm-project/llvm/include/llvm/Support/LogicalResult.h:71:58
#22 0x00006544769b82b4 (anonymous namespace)::OneShotBufferizePass::runOnOperation() llvm-project/mlir/lib/Dialect/Bufferization/Transforms/Bufferize.cpp:179:11
#23 0x000065447a0dff44 mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int)::$_44::operator()() const llvm-project/mlir/lib/Pass/Pass.cpp:610:22
#24 0x000065447a0dff44 void llvm::function_ref<void ()>::callback_fn<mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int)::$_44>(long) llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:46:12
#25 0x000065447a0c911a mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int) llvm-project/mlir/lib/Pass/Pass.cpp:603:3
#26 0x000065447a0cb0ec llvm::LogicalResult::failed() const llvm-project/llvm/include/llvm/Support/LogicalResult.h:43:43
#27 0x000065447a0cb0ec llvm::failed(llvm::LogicalResult) llvm-project/llvm/include/llvm/Support/LogicalResult.h:71:58
#28 0x000065447a0cb0ec mlir::detail::OpToOpPassAdaptor::runPipeline(mlir::OpPassManager&, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int, mlir::PassInstrumentor*, mlir::PassInstrumentation::PipelineParentInfo const*) llvm-project/mlir/lib/Pass/Pass.cpp:682:9
#29 0x000065447a0d7238 mlir::PassManager::runPasses(mlir::Operation*, mlir::AnalysisManager) llvm-project/mlir/lib/Pass/Pass.cpp:1117:10
#30 0x000065447a0d5db4 mlir::PassManager::run(mlir::Operation*) llvm-project/mlir/lib/Pass/Pass.cpp:0:60
#31 0x0000654467931604 llvm::LogicalResult::failed() const llvm-project/llvm/include/llvm/Support/LogicalResult.h:43:43
#32 0x0000654467931604 llvm::failed(llvm::LogicalResult) llvm-project/llvm/include/llvm/Support/LogicalResult.h:71:58
#33 0x0000654467931604 performActions(llvm::raw_ostream&, std::shared_ptr<llvm::SourceMgr> const&, mlir::MLIRContext*, mlir::MlirOptMainConfig const&) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:568:7
#34 0x0000654467930517 processBuffer(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef, mlir::MlirOptMainConfig const&, mlir::DialectRegistry&, mlir::SourceMgrDiagnosticVerifierHandler*, llvm::ThreadPoolInterface*) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:644:12
#35 0x0000654467930517 mlir::MlirOptMain(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, mlir::DialectRegistry&, mlir::MlirOptMainConfig const&)::$_3::operator()(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef, llvm::raw_ostream&) const llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:733:12
#36 0x0000654467930517 llvm::LogicalResult llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>::callback_fn<mlir::MlirOptMain(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, mlir::DialectRegistry&, mlir::MlirOptMainConfig const&)::$_3>(long, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&) llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:46:12
#37 0x000065447a8f4a64 std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>::~unique_ptr() /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/unique_ptr.h:360:6
#38 0x000065447a8f4a64 llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>::operator()(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&) const llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:69:5
#39 0x000065447a8f5526 mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0::operator()(llvm::StringRef) const llvm-project/mlir/lib/Support/ToolUtilities.cpp:94:13
#40 0x000065447a8f4447 void llvm::interleave<llvm::StringRef const*, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0, void llvm::interleave<llvm::SmallVector<llvm::StringRef, 8u>, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0, llvm::raw_ostream, llvm::StringRef>(llvm::SmallVector<llvm::StringRef, 8u> const&, llvm::raw_ostream&, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0, llvm::StringRef const&)::'lambda'(), void>(llvm::SmallVector<llvm::StringRef, 8u>, llvm::SmallVector<llvm::StringRef, 8u>, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0, llvm::raw_ostream) llvm-project/llvm/include/llvm/ADT/STLExtras.h:2201:24
#41 0x000065447a8f4447 void llvm::interleave<llvm::SmallVector<llvm::StringRef, 8u>, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0, llvm::raw_ostream, llvm::StringRef>(llvm::SmallVector<llvm::StringRef, 8u> const&, llvm::raw_ostream&, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0, llvm::StringRef const&) llvm-project/llvm/include/llvm/ADT/STLExtras.h:2221:3
#42 0x000065447a8f4447 mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef) llvm-project/mlir/lib/Support/ToolUtilities.cpp:97:3
#43 0x0000654467915432 mlir::MlirOptMain(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, mlir::DialectRegistry&, mlir::MlirOptMainConfig const&) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:0:26
#44 0x0000654467915e6e llvm::LogicalResult::failed() const llvm-project/llvm/include/llvm/Support/LogicalResult.h:43:43
#45 0x0000654467915e6e llvm::failed(llvm::LogicalResult) llvm-project/llvm/include/llvm/Support/LogicalResult.h:71:58
#46 0x0000654467915e6e mlir::MlirOptMain(int, char**, llvm::StringRef, llvm::StringRef, mlir::DialectRegistry&) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:784:7
#47 0x00006544679165c3 mlir::MlirOptMain(int, char**, llvm::StringRef, mlir::DialectRegistry&) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:800:10
#48 0x000065446772e3cf llvm::LogicalResult::succeeded() const llvm-project/llvm/include/llvm/Support/LogicalResult.h:40:45
#49 0x000065446772e3cf mlir::asMainReturnCode(llvm::LogicalResult) llvm-project/mlir/include/mlir/Tools/mlir-opt/MlirOptMain.h:399:12
#50 0x000065446772e3cf main llvm-project/mlir/tools/mlir-opt/mlir-opt.cpp:343:10
#51 0x00007c5784c68d90 __libc_start_call_main ./csu/../sysdeps/nptl/libc_start_call_main.h:58:16
#52 0x00007c5784c68e40 call_init ./csu/../csu/libc-start.c:128:20
#53 0x00007c5784c68e40 __libc_start_main ./csu/../csu/libc-start.c:379:5
#54 0x000065446766db65 _start (llvm-mlir-build/bin/mlir-opt+0x8381b65)
```

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
