# [mlir] UBSan alert mlir/lib/IR/AsmPrinter.cpp

**Issue:** [https://github.com/llvm/llvm-project/issues/162774](https://github.com/llvm/llvm-project/issues/162774) &nbsp;·&nbsp; **State:** `open` &nbsp;·&nbsp; **Created:** `2025-10-10T04:40:18Z`

**Labels:** `mlir`, `crash`

## Description

PoC:
```
#map = affine_map<(d0)[s0, s1] -> (s1, -d0 + s0)>
#map1 = affine_map<(d0, d1, d2) -> (d0, d1, d2)>
#map2 = affine_map<(d0, d1, d2) -> (d0, d1)>
#map3 = affine_map<(d0, d1) -> (d0, d1)>
#map4 = affine_map<(d0, d1) -> (d0)>
module {
  func.func @B_multi_slice_fusion_with_broadcast(%arg0: tensor<?x?x?xf32>, %arg1: tensor<?x?xf32>, %arg2: tensor<?xf32>, %arg3: index, %arg4: index) -> tensor<?x?xf32> {
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c2 = arith.constant 2 : index
    %dim = tensor.dim %arg0, %c0 : tensor<?x?x?xf32>
    %dim_0 = tensor.dim %arg0, %c1 : tensor<?x?x?xf32>
    %dim_1 = tensor.dim %arg0, %c2 : tensor<?x?x?xf32>
    %0:2 = scf.forall (%arg5, %arg6) = (%c0, %c0) to (%dim, %dim_0) step (%arg3, %arg4) shared_outs(%arg7 = %arg1, %arg8 = %arg2) -> (tensor<?x?xf32>, tensor<?xf32>) {
      %3 = affine.min #map(%arg5)[%dim, %arg3]
      %4 = affine.min #map(%arg6)[%dim_0, %arg4]
      %extracted_slice = tensor.extract_slice %arg0[%arg5, %arg6, 0] [%3, %4, %dim_1] [1, 1, 1] : tensor<?x?x?xf32> to tensor<?x?x?xf32>
      %extracted_slice_2 = tensor.extract_slice %arg7[%arg5, %arg6] [%3, %4] [1, 1] : tensor<?x?xf32> to tensor<?x?xf32>
      %5 = linalg.generic {indexing_maps = [#map1, #map2], iterator_types = ["parallel", "parallel", "reduction"]} ins(%extracted_slice : tensor<?x?x?xf32>) outs(%extracted_slice_2 : tensor<?x?xf32>) {
      ^bb0(%in: f32, %out: f32):
        %7 = arith.mulf %in, %out : f32
        linalg.yield %7 : f32
      } -> tensor<?x?xf32>
      %extracted_slice_3 = tensor.extract_slice %arg8[%arg5] [%3] [1] : tensor<?xf32> to tensor<?xf32>
      %6 = linalg.generic {indexing_maps = [#map3, #map4], iterator_types = ["parallel", "reduction"]} ins(%5 : tensor<?x?xf32>) outs(%extracted_slice_3 : tensor<?xf32>) {
      ^bb0(%in: f32, %out: f32):
        %7 = arith.addf %in, %out : f32
        linalg.yield %7 : f32
      } -> tensor<?xf32>
      scf.forall.in_parallel {
        tensor.parallel_insert_slice %6 into %arg8[%arg5] [%3] [1] : tensor<?xf32> into tensor<?xf32>
      }
    }
    %1 = tensor.empty(%dim, %dim_0) : tensor<?x?xf32>
    %2 = linalg.generic {indexing_maps = [#map3, #map4, #map3], iterator_types = ["parallel", "parallel"]} ins(%0#0, %0#1 : tensor<?x?xf32>, tensor<?xf32>) outs(%1 : tensor<?x?xf32>) {
    ^bb0(%in: f32, %in_2: f32, %out: f32):
      %3 = arith.addf %in, %in_2 : f32
      linalg.yield %3 : f32
    } -> tensor<?x?xf32>
    return %2 : tensor<?x?xf32>
  }
}
```

reproduce: `mlir-opt ./test.mlir -test-linalg-data-layout-propagation`

stderr:
```
SUMMARY: UndefinedBehaviorSanitizer: undefined-behavior llvm-project/mlir/lib/IR/AsmPrinter.cpp:3157:22 in 
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and instructions to reproduce the bug.
Stack dump:
0.	Program arguments: llvm-mlir-build/bin/mlir-opt test.mlir -test-linalg-data-layout-propagation -split-input-file
 #0 0x00005e610077069b backtrace (llvm-mlir-build/bin/mlir-opt+0x83bd69b)
 #1 0x00005e610083dad7 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) llvm-project/llvm/lib/Support/Unix/Signals.inc:838:8
 #2 0x00005e6100837dbf llvm::sys::RunSignalHandlers() llvm-project/llvm/lib/Support/Signals.cpp:105:18
 #3 0x00005e6100840e16 SignalHandler(int, siginfo_t*, void*) llvm-project/llvm/lib/Support/Unix/Signals.inc:426:38
 #4 0x00007ae4c52a5520 (/lib/x86_64-linux-gnu/libc.so.6+0x42520)
 #5 0x00007ae4c52f99fc __pthread_kill_implementation ./nptl/pthread_kill.c:44:76
 #6 0x00007ae4c52f99fc __pthread_kill_internal ./nptl/pthread_kill.c:78:10
 #7 0x00007ae4c52f99fc pthread_kill ./nptl/pthread_kill.c:89:10
 #8 0x00007ae4c52a5476 gsignal ./signal/../sysdeps/posix/raise.c:27:6
 #9 0x00007ae4c528b7f3 abort ./stdlib/abort.c:81:7
#10 0x00005e61007dbd07 (llvm-mlir-build/bin/mlir-opt+0x8428d07)
#11 0x00005e61007d9ba1 (llvm-mlir-build/bin/mlir-opt+0x8426ba1)
#12 0x00005e61007ed8ec __ubsan::ScopedReport::~ScopedReport() (llvm-mlir-build/bin/mlir-opt+0x843a8ec)
#13 0x00005e61007ef12b handleNegateOverflowImpl(__ubsan::OverflowData*, unsigned long, __ubsan::ReportOptions) ubsan_handlers.cpp.o:0:0
#14 0x00005e61007ef16e __ubsan_handle_negate_overflow_abort (llvm-mlir-build/bin/mlir-opt+0x843c16e)
#15 0x00005e611366ba08 mlir::AsmPrinter::Impl::printAffineExprInternal(mlir::AffineExpr, mlir::AsmPrinter::Impl::BindingStrength, llvm::function_ref<void (unsigned int, bool)>) llvm-project/mlir/lib/IR/AsmPrinter.cpp:3094:10
#16 0x00005e611366c0d0 void llvm::interleave<mlir::AffineExpr const*, mlir::AsmPrinter::Impl::printAffineMap(mlir::AffineMap)::$_56, void llvm::interleave<llvm::ArrayRef<mlir::AffineExpr>, mlir::AsmPrinter::Impl::printAffineMap(mlir::AffineMap)::$_56, llvm::raw_ostream, mlir::AffineExpr const>(llvm::ArrayRef<mlir::AffineExpr> const&, llvm::raw_ostream&, mlir::AsmPrinter::Impl::printAffineMap(mlir::AffineMap)::$_56, llvm::StringRef const&)::'lambda'(), void>(llvm::ArrayRef<mlir::AffineExpr>, llvm::ArrayRef<mlir::AffineExpr>, mlir::AsmPrinter::Impl::printAffineMap(mlir::AffineMap)::$_56, llvm::raw_ostream) llvm-project/llvm/include/llvm/ADT/STLExtras.h:2200:3
#17 0x00005e611366c0d0 void llvm::interleave<llvm::ArrayRef<mlir::AffineExpr>, mlir::AsmPrinter::Impl::printAffineMap(mlir::AffineMap)::$_56, llvm::raw_ostream, mlir::AffineExpr const>(llvm::ArrayRef<mlir::AffineExpr> const&, llvm::raw_ostream&, mlir::AsmPrinter::Impl::printAffineMap(mlir::AffineMap)::$_56, llvm::StringRef const&) llvm-project/llvm/include/llvm/ADT/STLExtras.h:2221:3
#18 0x00005e611366c0d0 void llvm::interleaveComma<llvm::ArrayRef<mlir::AffineExpr>, mlir::AsmPrinter::Impl::printAffineMap(mlir::AffineMap)::$_56, llvm::raw_ostream, mlir::AffineExpr const>(llvm::ArrayRef<mlir::AffineExpr> const&, llvm::raw_ostream&, mlir::AsmPrinter::Impl::printAffineMap(mlir::AffineMap)::$_56) llvm-project/llvm/include/llvm/ADT/STLExtras.h:2235:3
#19 0x00005e611366c0d0 void mlir::AsmPrinter::Impl::interleaveComma<llvm::ArrayRef<mlir::AffineExpr>, mlir::AsmPrinter::Impl::printAffineMap(mlir::AffineMap)::$_56>(llvm::ArrayRef<mlir::AffineExpr> const&, mlir::AsmPrinter::Impl::printAffineMap(mlir::AffineMap)::$_56) const llvm-project/mlir/lib/IR/AsmPrinter.cpp:423:5
#20 0x00005e611366c0d0 mlir::AsmPrinter::Impl::printAffineMap(mlir::AffineMap) llvm-project/mlir/lib/IR/AsmPrinter.cpp:3199:3
#21 0x00005e61136626a5 mlir::AffineMap::print(llvm::raw_ostream&) const llvm-project/mlir/lib/IR/AsmPrinter.cpp:0:41
#22 0x00005e611365fdad mlir::AsmPrinter::Impl::printAttributeImpl(mlir::Attribute, mlir::AsmPrinter::Impl::AttrTypeElision) llvm-project/mlir/lib/IR/AsmPrinter.cpp:0:30
#23 0x00005e611368fdc6 (anonymous namespace)::AliasState::printAliases(mlir::AsmPrinter::Impl&, (anonymous namespace)::NewLineCounter&, bool) llvm-project/mlir/lib/IR/AsmPrinter.cpp:0:11
#24 0x00005e611366e6cb (anonymous namespace)::OperationPrinter::printTopLevelOperation(mlir::Operation*) llvm-project/mlir/lib/IR/AsmPrinter.cpp:3444:3
#25 0x00005e611366e6cb mlir::Operation::print(llvm::raw_ostream&, mlir::AsmState&) llvm-project/mlir/lib/IR/AsmPrinter.cpp:4128:13
#26 0x00005e61009f9fd1 mlir::operator<<(llvm::raw_ostream&, mlir::OpWithState const&) llvm-project/mlir/include/mlir/IR/Operation.h:1147:3
#27 0x00005e61009f8b6f performActions(llvm::raw_ostream&, std::shared_ptr<llvm::SourceMgr> const&, mlir::MLIRContext*, mlir::MlirOptMainConfig const&) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:595:41
#28 0x00005e61009f7517 processBuffer(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef, mlir::MlirOptMainConfig const&, mlir::DialectRegistry&, mlir::SourceMgrDiagnosticVerifierHandler*, llvm::ThreadPoolInterface*) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:644:12
#29 0x00005e61009f7517 mlir::MlirOptMain(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, mlir::DialectRegistry&, mlir::MlirOptMainConfig const&)::$_3::operator()(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef, llvm::raw_ostream&) const llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:733:12
#30 0x00005e61009f7517 llvm::LogicalResult llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>::callback_fn<mlir::MlirOptMain(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, mlir::DialectRegistry&, mlir::MlirOptMainConfig const&)::$_3>(long, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&) llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:46:12
#31 0x00005e61139bba64 std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>::~unique_ptr() /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/unique_ptr.h:360:6
#32 0x00005e61139bba64 llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>::operator()(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&) const llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:69:5
#33 0x00005e61139bc526 mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0::operator()(llvm::StringRef) const llvm-project/mlir/lib/Support/ToolUtilities.cpp:94:13
#34 0x00005e61139bb447 void llvm::interleave<llvm::StringRef const*, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0, void llvm::interleave<llvm::SmallVector<llvm::StringRef, 8u>, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0, llvm::raw_ostream, llvm::StringRef>(llvm::SmallVector<llvm::StringRef, 8u> const&, llvm::raw_ostream&, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0, llvm::StringRef const&)::'lambda'(), void>(llvm::SmallVector<llvm::StringRef, 8u>, llvm::SmallVector<llvm::StringRef, 8u>, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0, llvm::raw_ostream) llvm-project/llvm/include/llvm/ADT/STLExtras.h:2201:24
#35 0x00005e61139bb447 void llvm::interleave<llvm::SmallVector<llvm::StringRef, 8u>, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0, llvm::raw_ostream, llvm::StringRef>(llvm::SmallVector<llvm::StringRef, 8u> const&, llvm::raw_ostream&, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::$_0, llvm::StringRef const&) llvm-project/llvm/include/llvm/ADT/STLExtras.h:2221:3
#36 0x00005e61139bb447 mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef) llvm-project/mlir/lib/Support/ToolUtilities.cpp:97:3
#37 0x00005e61009dc432 mlir::MlirOptMain(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, mlir::DialectRegistry&, mlir::MlirOptMainConfig const&) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:0:26
#38 0x00005e61009dce6e llvm::LogicalResult::failed() const llvm-project/llvm/include/llvm/Support/LogicalResult.h:43:43
#39 0x00005e61009dce6e llvm::failed(llvm::LogicalResult) llvm-project/llvm/include/llvm/Support/LogicalResult.h:71:58
#40 0x00005e61009dce6e mlir::MlirOptMain(int, char**, llvm::StringRef, llvm::StringRef, mlir::DialectRegistry&) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:784:7
#41 0x00005e61009dd5c3 mlir::MlirOptMain(int, char**, llvm::StringRef, mlir::DialectRegistry&) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:800:10
#42 0x00005e61007f53cf llvm::LogicalResult::succeeded() const llvm-project/llvm/include/llvm/Support/LogicalResult.h:40:45
#43 0x00005e61007f53cf mlir::asMainReturnCode(llvm::LogicalResult) llvm-project/mlir/include/mlir/Tools/mlir-opt/MlirOptMain.h:399:12
#44 0x00005e61007f53cf main llvm-project/mlir/tools/mlir-opt/mlir-opt.cpp:343:10
#45 0x00007ae4c528cd90 __libc_start_call_main ./csu/../sysdeps/nptl/libc_start_call_main.h:58:16
#46 0x00007ae4c528ce40 call_init ./csu/../csu/libc-start.c:128:20
#47 0x00007ae4c528ce40 __libc_start_main ./csu/../csu/libc-start.c:379:5
#48 0x00005e6100734b65 _start (llvm-mlir-build/bin/mlir-opt+0x8381b65)
```

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
