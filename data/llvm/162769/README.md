# mlir heap-use-after-free

**Issue:** [https://github.com/llvm/llvm-project/issues/162769](https://github.com/llvm/llvm-project/issues/162769) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-10T04:06:15Z`

**Labels:** `question`, `mlir`

## Description

Seems to be a TOCTOU problem then cause UAF?

reproduce: 
```
mlir-opt ./min.mlir '-pass-pipeline=builtin.module(func.func(test-memref-stride-calculation))'
Segmentation fault (core dumped)
```

PoC:
```
module {
  module {
      // CHECK: func.func @A_test(%[[test_arg:[^ ]*]]: i1) {
      // CHECK: %[[v0:[^ ]*]] = "test_irdl_to_cpp.bar"() : () -> i32
      // CHECK: %[[v1:[^ ]*]] = "test_irdl_to_cpp.bar"() : () -> i32
      // CHECK: %[[v2:[^ ]*]] = "test_irdl_to_cpp.hash"(%[[v0]], %[[v0]]) : (i32, i32) -> i32
      // CHECK: scf.if %[[test_arg]]
      // CHECK: return
      // CHECK: }
      func.func @A_test(%test_arg: i1) {
          %0 = "test_irdl_to_cpp.bar"() : () -> i32
          %1 = "test_irdl_to_cpp.beef"(%0, %0) : (i32, i32) -> i32
          "test_irdl_to_cpp.conditional"(%test_arg) ({
          ^cond(%test: i1):
            %3 = "test_irdl_to_cpp.bar"() : () -> i32
            "test.terminator"() : ()->()
          }, {
          ^then(%what: i1, %ever: i32):
            %4 = "test_irdl_to_cpp.bar"() : () -> i32
            "test.terminator"() : ()->()
          }, {
          ^else():
            %5 = "test_irdl_to_cpp.bar"() : () -> i32
            "test.terminator"() : ()->()
          }) : (i1) -> ()
          return
      }
  
  // CHECK: }
  }

  func.func @fusion_bridge_151568007() -> i32 {
    %c = arith.constant 0 : i32
    return %c : i32
  }

  %fusion_tmp = func.call @fusion_bridge_151568007() : () -> i32
  
  func.func @B_f(%0: index) {
  // CHECK-LABEL: Testing: f
    %1 = memref.alloc() : memref<3x4x5xf32>
  // CHECK: MemRefType offset: 0 strides: 20, 5, 1
    %2 = memref.alloc(%0) : memref<3x4x?xf32>
  // CHECK: MemRefType offset: 0 strides: ?, ?, 1
    %3 = memref.alloc(%0) : memref<3x?x5xf32>
  // CHECK: MemRefType offset: 0 strides: ?, 5, 1
    %4 = memref.alloc(%0) : memref<?x4x5xf32>
  // CHECK: MemRefType offset: 0 strides: 20, 5, 1
    %5 = memref.alloc(%0, %0) : memref<?x4x?xf32>
  // CHECK: MemRefType offset: 0 strides: ?, ?, 1
    %6 = memref.alloc(%0, %0, %0) : memref<?x?x?xf32>
  // CHECK: MemRefType offset: 0 strides: ?, ?, 1
  
    %11 = memref.alloc() : memref<3x4x5xf32, affine_map<(i, j, k)->(i, j, k)>>
  // CHECK: MemRefType offset: 0 strides: 20, 5, 1
    %b11 = memref.alloc() : memref<3x4x5xf32, strided<[20, 5, 1], offset: 0>>
  // CHECK: MemRefType offset: 0 strides: 20, 5, 1
    %12 = memref.alloc(%0) : memref<3x4x?xf32, affine_map<(i, j, k)->(i, j, k)>>
  // CHECK: MemRefType offset: 0 strides: ?, ?, 1
    %13 = memref.alloc(%0) : memref<3x?x5xf32, affine_map<(i, j, k)->(i, j, k)>>
  // CHECK: MemRefType offset: 0 strides: ?, 5, 1
    %14 = memref.alloc(%0) : memref<?x4x5xf32, affine_map<(i, j, k)->(i, j, k)>>
  // CHECK: MemRefType offset: 0 strides: 20, 5, 1
    %15 = memref.alloc(%0, %0) : memref<?x4x?xf32, affine_map<(i, j, k)->(i, j, k)>>
  // CHECK: MemRefType offset: 0 strides: ?, ?, 1
    %16 = memref.alloc(%0, %0, %0) : memref<?x?x?xf32, affine_map<(i, j, k)->(i, j, k)>>
  // CHECK: MemRefType offset: 0 strides: ?, ?, 1
  
    %21 = memref.alloc()[%0] : memref<3x4x5xf32, affine_map<(i, j, k)[M]->(32 * i + 16 * j + M * k + 1)>>
  // CHECK: MemRefType offset: 1 strides: 32, 16, ?
    %22 = memref.alloc()[%0] : memref<3x4x5xf32, affine_map<(i, j, k)[M]->(32 * i + M * j + 16 * k + 3)>>
  // CHECK: MemRefType offset: 3 strides: 32, ?, 16
    %b22 = memref.alloc(%0)[%0, %0] : memref<3x4x?xf32, strided<[?, ?, 1], offset: 0>>
  // CHECK: MemRefType offset: 0 strides: ?, ?, 1
    %23 = memref.alloc(%0)[%0] : memref<3x?x5xf32, affine_map<(i, j, k)[M]->(M * i + 32 * j + 16 * k + 7)>>
  // CHECK: MemRefType offset: 7 strides: ?, 32, 16
    %b23 = memref.alloc(%0)[%0] : memref<3x?x5xf32, strided<[?, 5, 1], offset: 0>>
  // CHECK: MemRefType offset: 0 strides: ?, 5, 1
    %24 = memref.alloc(%0)[%0] : memref<3x?x5xf32, affine_map<(i, j, k)[M]->(M * i + 32 * j + 16 * k + M)>>
  // CHECK: MemRefType offset: ? strides: ?, 32, 16
    %b24 = memref.alloc(%0)[%0, %0] : memref<3x?x5xf32, strided<[?, 32, 16], offset: ?>>
  // CHECK: MemRefType offset: ? strides: ?, 32, 16
    %25 = memref.alloc(%0, %0)[%0, %0] : memref<?x?x16xf32, affine_map<(i, j, k)[M, N]->(M * i + N * j + k + 1)>>
  // CHECK: MemRefType offset: 1 strides: ?, ?, 1
    %b25 = memref.alloc(%0, %0)[%0, %0] : memref<?x?x16xf32, strided<[?, ?, 1], offset: 1>>
  // CHECK: MemRefType offset: 1 strides: ?, ?, 1
    %26 = memref.alloc(%0)[] : memref<?xf32, affine_map<(i)[M]->(i)>>
  // CHECK: MemRefType offset: 0 strides: 1
    %27 = memref.alloc()[%0] : memref<5xf32, affine_map<(i)[M]->(M)>>
  // CHECK: MemRefType offset: ? strides: 0
    %28 = memref.alloc()[%0] : memref<5xf32, affine_map<(i)[M]->(123)>>
  // CHECK: MemRefType offset: 123 strides: 0
    %29 = memref.alloc()[%0] : memref<f32, affine_map<()[M]->(M)>>
  // CHECK: MemRefType offset: ? strides:
    %30 = memref.alloc()[%0] : memref<f32, affine_map<()[M]->(123)>>
  // CHECK: MemRefType offset: 123 strides:
  
    %101 = memref.alloc() : memref<3x4x5xf32, affine_map<(i, j, k)->(i floordiv 4 + j + k)>>
  // CHECK: MemRefType memref<3x4x5xf32, affine_map<(d0, d1, d2) -> (d0 floordiv 4 + d1 + d2)>> cannot be converted to strided form
    %102 = memref.alloc() : memref<3x4x5xf32, affine_map<(i, j, k)->(i ceildiv 4 + j + k)>>
  // CHECK: MemRefType memref<3x4x5xf32, affine_map<(d0, d1, d2) -> (d0 ceildiv 4 + d1 + d2)>> cannot be converted to strided form
    %103 = memref.alloc() : memref<3x4x5xf32, affine_map<(i, j, k)->(i mod 4 + j + k)>>
  // CHECK: MemRefType memref<3x4x5xf32, affine_map<(d0, d1, d2) -> (d0 mod 4 + d1 + d2)>> cannot be converted to strided form
  
    %200 = memref.alloc()[%0, %0, %0] : memref<3x4x5xf32, affine_map<(i, j, k)[M, N, K]->(M * i + N * i + N * j + K * k - (M + N - 20)* i)>>
    // CHECK: MemRefType offset: 0 strides: 20, ?, ?
    %201 = memref.alloc()[%0, %0, %0] : memref<3x4x5xf32, affine_map<(i, j, k)[M, N, K]->(M * i + N * i + N * K * j + K * K * k - (M + N - 20) * (i + 1))>>
    // CHECK: MemRefType offset: ? strides: 20, ?, ?
    %202 = memref.alloc()[%0, %0, %0] : memref<3x4x5xf32, affine_map<(i, j, k)[M, N, K]->(M * (i + 1) + j + k - M)>>
    // CHECK: MemRefType offset: 0 strides: ?, 1, 1
    %203 = memref.alloc()[%0, %0, %0] : memref<3x4x5xf32, affine_map<(i, j, k)[M, N, K]->(M + M * (i + N * (j + K * k)))>>
    // CHECK: MemRefType offset: ? strides: ?, ?, ?
  
    return
  }
}
```

As I cannot stably reproduce this, I can hardly minimize this :(

Error:
```
=================================================================
==153850==ERROR: AddressSanitizer: heap-use-after-free on address 0x62100003fd00 at pc 0x58d0bb5c5c98 bp 0x7c808f1fcb50 sp 0x7c808f1fc328
READ of size 33 at 0x62100003fd00 thread T1
    #0 0x58d0bb5c5c97 in write (llvm-mlir-build/bin/mlir-opt+0x839dc97) (BuildId: 8d3f598c321c686de3addc0e0905b4ae76916fb7)
    #1 0x58d0bb672f12 in llvm::raw_fd_ostream::write_impl(char const*, unsigned long) llvm-project/llvm/lib/Support/raw_ostream.cpp:763:19
    #2 0x58d0bb9b96cd in llvm::raw_ostream::flush() llvm-project/llvm/include/llvm/Support/raw_ostream.h:201:7
    #3 0x58d0bb9b96cd in (anonymous namespace)::TestMemRefStrideCalculation::runOnOperation() llvm-project/mlir/test/lib/Analysis/TestMemRefStrideCalculation.cpp:57:16
    #4 0x58d0ce01bf43 in mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int)::$_44::operator()() const llvm-project/mlir/lib/Pass/Pass.cpp:609:17
    #5 0x58d0ce01bf43 in void llvm::function_ref<void ()>::callback_fn<mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int)::$_44>(long) llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:46:12
    #6 0x58d0ce005119 in llvm::function_ref<void ()>::operator()() const llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:69:12
    #7 0x58d0ce005119 in void mlir::MLIRContext::executeAction<mlir::PassExecutionAction, mlir::Pass&>(llvm::function_ref<void ()>, llvm::ArrayRef<mlir::IRUnit>, mlir::Pass&) llvm-project/mlir/include/mlir/IR/MLIRContext.h:290:7
    #8 0x58d0ce005119 in mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int) llvm-project/mlir/lib/Pass/Pass.cpp:603:21
    #9 0x58d0ce0070eb in mlir::detail::OpToOpPassAdaptor::runPipeline(mlir::OpPassManager&, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int, mlir::PassInstrumentor*, mlir::PassInstrumentation::PipelineParentInfo const*) llvm-project/mlir/lib/Pass/Pass.cpp:682:16
    #10 0x58d0ce021bbb in mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102::operator()(mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo&) const llvm-project/mlir/lib/Pass/Pass.cpp:995:36
    #11 0x58d0ce021bbb in auto void mlir::parallelForEach<__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102>(mlir::MLIRContext*, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102&&)::'lambda'(__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >&&)::operator()<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo&>(__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >&&) const llvm-project/mlir/include/mlir/IR/Threading.h:120:12
    #12 0x58d0ce0223a3 in llvm::LogicalResult mlir::failableParallelForEach<__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, void mlir::parallelForEach<__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102>(mlir::MLIRContext*, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102&&)::'lambda'(__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >&&)>(mlir::MLIRContext*, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102&&)::'lambda'()::operator()() const llvm-project/mlir/include/mlir/IR/Threading.h:62:18
    #13 0x58d0ce0223a3 in __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > > std::__invoke_impl<void, llvm::LogicalResult mlir::failableParallelForEach<__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, void mlir::parallelForEach<__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102>(mlir::MLIRContext*, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102&&)::'lambda'(__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >&&)>(mlir::MLIRContext*, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102&&)::'lambda'()&>(std::__invoke_other, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102&&) /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/invoke.h:61:14
    #14 0x58d0ce0223a3 in std::enable_if<is_invocable_r_v<__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102>, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > > >::type std::__invoke_r<void, llvm::LogicalResult mlir::failableParallelForEach<__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, void mlir::parallelForEach<__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102>(mlir::MLIRContext*, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102&&)::'lambda'(__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >&&)>(mlir::MLIRContext*, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102&&)::'lambda'()&>(mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102&&) /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/invoke.h:111:2
    #15 0x58d0ce0223a3 in std::_Function_handler<void (), llvm::LogicalResult mlir::failableParallelForEach<__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, void mlir::parallelForEach<__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102>(mlir::MLIRContext*, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102&&)::'lambda'(__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >&&)>(mlir::MLIRContext*, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102&&)::'lambda'()>::_M_invoke(std::_Any_data const&) /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/std_function.h:290:9
    #16 0x58d0cdeb8e8a in void std::__invoke_impl<void, std::function<void ()> >(std::__invoke_other, std::function<void ()>&&) /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/invoke.h:61:14
    #17 0x58d0cdeb8e8a in std::__invoke_result<std::function<void ()> >::type std::__invoke<std::function<void ()> >(std::function<void ()>&&) /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/invoke.h:96:14
    #18 0x58d0cdeb8e8a in void std::thread::_Invoker<std::tuple<std::function<void ()> > >::_M_invoke<0ul>(std::_Index_tuple<0ul>) /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/std_thread.h:259:13
    #19 0x58d0cdeb8e8a in std::thread::_Invoker<std::tuple<std::function<void ()> > >::operator()() /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/std_thread.h:266:11
    #20 0x58d0cdeb8e8a in std::__future_base::_Task_setter<std::unique_ptr<std::__future_base::_Result<void>, std::__future_base::_Result_base::_Deleter>, std::thread::_Invoker<std::tuple<std::function<void ()> > >, void>::operator()() const /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/future:1409:6
    #21 0x58d0cdeb8d02 in std::unique_ptr<std::__future_base::_Result<void>, std::__future_base::_Result_base::_Deleter> std::__invoke_impl<std::unique_ptr<std::__future_base::_Result<void>, std::__future_base::_Result_base::_Deleter>, std::__future_base::_Task_setter<std::unique_ptr<std::__future_base::_Result<void>, std::__future_base::_Result_base::_Deleter>, std::thread::_Invoker<std::tuple<std::function<void ()> > >, void>&>(std::__invoke_other, std::__future_base::_Task_setter<std::unique_ptr<std::__future_base::_Result<void>, std::__future_base::_Result_base::_Deleter>, std::thread::_Invoker<std::tuple<std::function<void ()> > >, void>&) /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/invoke.h:61:14
    #22 0x58d0cdeb8d02 in std::enable_if<is_invocable_r_v<std::unique_ptr<std::__future_base::_Result_base, std::__future_base::_Result_base::_Deleter>, std::__future_base::_Task_setter<std::unique_ptr<std::__future_base::_Result<void>, std::__future_base::_Result_base::_Deleter>, std::thread::_Invoker<std::tuple<std::function<void ()> > >, void>&>, std::unique_ptr<std::__future_base::_Result_base, std::__future_base::_Result_base::_Deleter> >::type std::__invoke_r<std::unique_ptr<std::__future_base::_Result_base, std::__future_base::_Result_base::_Deleter>, std::__future_base::_Task_setter<std::unique_ptr<std::__future_base::_Result<void>, std::__future_base::_Result_base::_Deleter>, std::thread::_Invoker<std::tuple<std::function<void ()> > >, void>&>(std::__future_base::_Task_setter<std::unique_ptr<std::__future_base::_Result<void>, std::__future_base::_Result_base::_Deleter>, std::thread::_Invoker<std::tuple<std::function<void ()> > >, void>&) /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/invoke.h:114:9
    #23 0x58d0cdeb8d02 in std::_Function_handler<std::unique_ptr<std::__future_base::_Result_base, std::__future_base::_Result_base::_Deleter> (), std::__future_base::_Task_setter<std::unique_ptr<std::__future_base::_Result<void>, std::__future_base::_Result_base::_Deleter>, std::thread::_Invoker<std::tuple<std::function<void ()> > >, void> >::_M_invoke(std::_Any_data const&) /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/std_function.h:290:9
    #24 0x58d0cdeb8c2c in std::function<std::unique_ptr<std::__future_base::_Result_base, std::__future_base::_Result_base::_Deleter> ()>::operator()() const /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/std_function.h:590:9
    #25 0x58d0cdeb884c in std::__future_base::_State_baseV2::_M_do_set(std::function<std::unique_ptr<std::__future_base::_Result_base, std::__future_base::_Result_base::_Deleter> ()>*, bool*) /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/future:571:27
    #26 0x7c8091a8cee7 in __pthread_once_slow nptl/./nptl/pthread_once.c:116:7
    #27 0x58d0cdeb8617 in __gthread_once(int*, void (*)()) /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/x86_64-linux-gnu/c++/11/bits/gthr-default.h:700:12
    #28 0x58d0cdeb8617 in void std::call_once<void (std::__future_base::_State_baseV2::*)(std::function<std::unique_ptr<std::__future_base::_Result_base, std::__future_base::_Result_base::_Deleter> ()>*, bool*), std::__future_base::_State_baseV2*, std::function<std::unique_ptr<std::__future_base::_Result_base, std::__future_base::_Result_base::_Deleter> ()>*, bool*>(std::once_flag&, void (std::__future_base::_State_baseV2::*&&)(std::function<std::unique_ptr<std::__future_base::_Result_base, std::__future_base::_Result_base::_Deleter> ()>*, bool*), std::__future_base::_State_baseV2*&&, std::function<std::unique_ptr<std::__future_base::_Result_base, std::__future_base::_Result_base::_Deleter> ()>*&&, bool*&&) /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/mutex:783:21
    #29 0x58d0cdeb8262 in std::__future_base::_State_baseV2::_M_set_result(std::function<std::unique_ptr<std::__future_base::_Result_base, std::__future_base::_Result_base::_Deleter> ()>, bool) /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/future:411:2
    #30 0x58d0cdeb9f88 in std::__future_base::_Deferred_state<std::thread::_Invoker<std::tuple<std::function<void ()> > >, void>::_M_complete_async() /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/future:1679:9
    #31 0x58d0cdeba3a0 in std::__future_base::_State_baseV2::wait() /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/future:333:2
    #32 0x58d0ce8fb87e in llvm::StdThreadPool::processTasks(llvm::ThreadPoolTaskGroup*) llvm-project/llvm/lib/Support/ThreadPool.cpp:114:5
    #33 0x58d0ce902956 in llvm::StdThreadPool::grow(int)::$_0::operator()() const llvm-project/llvm/lib/Support/ThreadPool.cpp:62:9
    #34 0x58d0ce902956 in auto void llvm::thread::GenericThreadProxy<std::tuple<llvm::StdThreadPool::grow(int)::$_0> >(void*)::'lambda'(auto&&, auto&&...)::operator()<llvm::StdThreadPool::grow(int)::$_0&>(auto&&, auto&&...) const llvm-project/llvm/include/llvm/Support/thread.h:46:11
    #35 0x58d0ce902956 in auto std::__invoke_impl<void, void llvm::thread::GenericThreadProxy<std::tuple<llvm::StdThreadPool::grow(int)::$_0> >(void*)::'lambda'(auto&&, auto&&...), llvm::StdThreadPool::grow(int)::$_0&>(std::__invoke_other, void llvm::thread::GenericThreadProxy<std::tuple<llvm::StdThreadPool::grow(int)::$_0> >(void*)::'lambda'(auto&&, auto&&...)&&, llvm::StdThreadPool::grow(int)::$_0&) /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/invoke.h:61:14
    #36 0x58d0ce902956 in std::__invoke_result<auto, auto...>::type std::__invoke<void llvm::thread::GenericThreadProxy<std::tuple<llvm::StdThreadPool::grow(int)::$_0> >(void*)::'lambda'(auto&&, auto&&...), llvm::StdThreadPool::grow(int)::$_0&>(auto&&, auto&&...) /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/invoke.h:96:14
    #37 0x58d0ce902956 in decltype(auto) std::__apply_impl<void llvm::thread::GenericThreadProxy<std::tuple<llvm::StdThreadPool::grow(int)::$_0> >(void*)::'lambda'(auto&&, auto&&...), std::tuple<llvm::StdThreadPool::grow(int)::$_0>&, 0ul>(auto&&, std::tuple<llvm::StdThreadPool::grow(int)::$_0>&, std::integer_sequence<unsigned long, 0ul>) /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/tuple:1854:14
    #38 0x58d0ce902956 in decltype(auto) std::apply<void llvm::thread::GenericThreadProxy<std::tuple<llvm::StdThreadPool::grow(int)::$_0> >(void*)::'lambda'(auto&&, auto&&...), std::tuple<llvm::StdThreadPool::grow(int)::$_0>&>(auto&&, std::tuple<llvm::StdThreadPool::grow(int)::$_0>&) /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/tuple:1865:14
    #39 0x58d0ce902956 in void llvm::thread::GenericThreadProxy<std::tuple<llvm::StdThreadPool::grow(int)::$_0> >(void*) llvm-project/llvm/include/llvm/Support/thread.h:44:5
    #40 0x58d0ce902956 in void* llvm::thread::ThreadProxy<std::tuple<llvm::StdThreadPool::grow(int)::$_0> >(void*) llvm-project/llvm/include/llvm/Support/thread.h:58:5
    #41 0x7c8091a87ac2 in start_thread nptl/./nptl/pthread_create.c:442:8
    #42 0x7c8091b18a03 in __clone misc/../sysdeps/unix/sysv/linux/x86_64/clone.S:100

0x62100003fd00 is located 0 bytes inside of 4096-byte region [0x62100003fd00,0x621000040d00)
freed by thread T2 here:
    #0 0x58d0bb6680dd in operator delete[](void*) (llvm-mlir-build/bin/mlir-opt+0x84400dd) (BuildId: 8d3f598c321c686de3addc0e0905b4ae76916fb7)
    #1 0x58d0bb66e969 in llvm::raw_ostream::SetBufferAndMode(char*, unsigned long, llvm::raw_ostream::BufferKind) llvm-project/llvm/lib/Support/raw_ostream.cpp:116:5
    #2 0x58d0bb66fae9 in llvm::raw_ostream::write(char const*, unsigned long) llvm-project/llvm/lib/Support/raw_ostream.cpp:254:7
    #3 0x58d0bb9b9563 in llvm::raw_ostream::operator<<(char const*) llvm-project/llvm/include/llvm/Support/raw_ostream.h:258:18
    #4 0x58d0bb9b9563 in (anonymous namespace)::TestMemRefStrideCalculation::runOnOperation() llvm-project/mlir/test/lib/Analysis/TestMemRefStrideCalculation.cpp:33:16
    #5 0x58d0ce01bf43 in mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int)::$_44::operator()() const llvm-project/mlir/lib/Pass/Pass.cpp:609:17
    #6 0x58d0ce01bf43 in void llvm::function_ref<void ()>::callback_fn<mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int)::$_44>(long) llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:46:12
    #7 0x58d0ce005119 in llvm::function_ref<void ()>::operator()() const llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:69:12
    #8 0x58d0ce005119 in void mlir::MLIRContext::executeAction<mlir::PassExecutionAction, mlir::Pass&>(llvm::function_ref<void ()>, llvm::ArrayRef<mlir::IRUnit>, mlir::Pass&) llvm-project/mlir/include/mlir/IR/MLIRContext.h:290:7
    #9 0x58d0ce005119 in mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int) llvm-project/mlir/lib/Pass/Pass.cpp:603:21
    #10 0x58d0ce0070eb in mlir::detail::OpToOpPassAdaptor::runPipeline(mlir::OpPassManager&, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int, mlir::PassInstrumentor*, mlir::PassInstrumentation::PipelineParentInfo const*) llvm-project/mlir/lib/Pass/Pass.cpp:682:16
    #11 0x58d0ce021bbb in mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102::operator()(mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo&) const llvm-project/mlir/lib/Pass/Pass.cpp:995:36
    #12 0x58d0ce021bbb in auto void mlir::parallelForEach<__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102>(mlir::MLIRContext*, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102&&)::'lambda'(__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >&&)::operator()<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo&>(__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >&&) const llvm-project/mlir/include/mlir/IR/Threading.h:120:12
    #13 0x58d0ce0223a3 in llvm::LogicalResult mlir::failableParallelForEach<__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, void mlir::parallelForEach<__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102>(mlir::MLIRContext*, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102&&)::'lambda'(__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >&&)>(mlir::MLIRContext*, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102&&)::'lambda'()::operator()() const llvm-project/mlir/include/mlir/IR/Threading.h:62:18
    #14 0x58d0ce0223a3 in __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > > std::__invoke_impl<void, llvm::LogicalResult mlir::failableParallelForEach<__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, void mlir::parallelForEach<__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102>(mlir::MLIRContext*, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102&&)::'lambda'(__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >&&)>(mlir::MLIRContext*, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102&&)::'lambda'()&>(std::__invoke_other, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102&&) /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/invoke.h:61:14
    #15 0x58d0ce0223a3 in std::enable_if<is_invocable_r_v<__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102>, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > > >::type std::__invoke_r<void, llvm::LogicalResult mlir::failableParallelForEach<__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, void mlir::parallelForEach<__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102>(mlir::MLIRContext*, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102&&)::'lambda'(__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >&&)>(mlir::MLIRContext*, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102&&)::'lambda'()&>(mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102&&) /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/invoke.h:111:2
    #16 0x58d0ce0223a3 in std::_Function_handler<void (), llvm::LogicalResult mlir::failableParallelForEach<__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, void mlir::parallelForEach<__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102>(mlir::MLIRContext*, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102&&)::'lambda'(__gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >&&)>(mlir::MLIRContext*, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, __gnu_cxx::__normal_iterator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo*, std::vector<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo, std::allocator<mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::OpPMInfo> > >, mlir::detail::OpToOpPassAdaptor::runOnOperationAsyncImpl(bool)::$_102&&)::'lambda'()>::_M_invoke(std::_Any_data const&) /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/std_function.h:290:9
    #17 0x58d0cdeb8e8a in void std::__invoke_impl<void, std::function<void ()> >(std::__invoke_other, std::function<void ()>&&) /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/invoke.h:61:14
    #18 0x58d0cdeb8e8a in std::__invoke_result<std::function<void ()> >::type std::__invoke<std::function<void ()> >(std::function<void ()>&&) /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/invoke.h:96:14
    #19 0x58d0cdeb8e8a in void std::thread::_Invoker<std::tuple<std::function<void ()> > >::_M_invoke<0ul>(std::_Index_tuple<0ul>) /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/std_thread.h:259:13
    #20 0x58d0cdeb8e8a in std::thread::_Invoker<std::tuple<std::function<void ()> > >::operator()() /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/std_thread.h:266:11
    #21 0x58d0cdeb8e8a in std::__future_base::_Task_setter<std::unique_ptr<std::__future_base::_Result<void>, std::__future_base::_Result_base::_Deleter>, std::thread::_Invoker<std::tuple<std::function<void ()> > >, void>::operator()() const /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/future:1409:6
    #22 0x58d0cdeb8d02 in std::unique_ptr<std::__future_base::_Result<void>, std::__future_base::_Result_base::_Deleter> std::__invoke_impl<std::unique_ptr<std::__future_base::_Result<void>, std::__future_base::_Result_base::_Deleter>, std::__future_base::_Task_setter<std::unique_ptr<std::__future_base::_Result<void>, std::__future_base::_Result_base::_Deleter>, std::thread::_Invoker<std::tuple<std::function<void ()> > >, void>&>(std::__invoke_other, std::__future_base::_Task_setter<std::unique_ptr<std::__future_base::_Result<void>, std::__future_base::_Result_base::_Deleter>, std::thread::_Invoker<std::tuple<std::function<void ()> > >, void>&) /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/invoke.h:61:14
    #23 0x58d0cdeb8d02 in std::enable_if<is_invocable_r_v<std::unique_ptr<std::__future_base::_Result_base, std::__future_base::_Result_base::_Deleter>, std::__future_base::_Task_setter<std::unique_ptr<std::__future_base::_Result<void>, std::__future_base::_Result_base::_Deleter>, std::thread::_Invoker<std::tuple<std::function<void ()> > >, void>&>, std::unique_ptr<std::__future_base::_Result_base, std::__future_base::_Result_base::_Deleter> >::type std::__invoke_r<std::unique_ptr<std::__future_base::_Result_base, std::__future_base::_Result_base::_Deleter>, std::__future_base::_Task_setter<std::unique_ptr<std::__future_base::_Result<void>, std::__future_base::_Result_base::_Deleter>, std::thread::_Invoker<std::tuple<std::function<void ()> > >, void>&>(std::__future_base::_Task_setter<std::unique_ptr<std::__future_base::_Result<void>, std::__future_base::_Result_base::_Deleter>, std::thread::_Invoker<std::tuple<std::function<void ()> > >, void>&) /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/invoke.h:114:9
    #24 0x58d0cdeb8d02 in std::_Function_handler<std::unique_ptr<std::__future_base::_Result_base, std::__future_base::_Result_base::_Deleter> (), std::__future_base::_Task_setter<std::unique_ptr<std::__future_base::_Result<void>, std::__future_base::_Result_base::_Deleter>, std::thread::_Invoker<std::tuple<std::function<void ()> > >, void> >::_M_invoke(std::_Any_data const&) /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/std_function.h:290:9
    #25 0x58d0cdeb8c2c in std::function<std::unique_ptr<std::__future_base::_Result_base, std::__future_base::_Result_base::_Deleter> ()>::operator()() const /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/bits/std_function.h:590:9
    #26 0x58d0cdeb884c in std::__future_base::_State_baseV2::_M_do_set(std::function<std::unique_ptr<std::__future_base::_Result_base, std::__future_base::_Result_base::_Deleter> ()>*, bool*) /usr/bin/../lib/gcc/x86_64-linux-gnu/11/../../../../include/c++/11/future:571:27
    #27 0x7c8091a8cee7 in __pthread_once_slow nptl/./nptl/pthread_once.c:116:7

...

SUMMARY: AddressSanitizer: heap-use-after-free (llvm-mlir-build/bin/mlir-opt+0x839dc97) (BuildId: 8d3f598c321c686de3addc0e0905b4ae76916fb7) in write
Shadow bytes around the buggy address:
  0x0c427fffff50: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x0c427fffff60: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x0c427fffff70: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x0c427fffff80: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x0c427fffff90: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
=>0x0c427fffffa0:[fd]fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd
  0x0c427fffffb0: fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd
  0x0c427fffffc0: fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd
  0x0c427fffffd0: fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd
  0x0c427fffffe0: fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd
  0x0c427ffffff0: fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd
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
==153850==ABORTING
```

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
