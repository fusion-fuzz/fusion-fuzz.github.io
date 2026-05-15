*Fusion-Fuzz Bug Report*

**ID:** `e62d92b2` &nbsp;·&nbsp; **Signature:** `Assertion:symbolUses && "expected uses to be valid"` &nbsp;·&nbsp; **RC:** `134`

The following code:

```mlir
// FUSED MLIR (FFL)  A: aa1bdd52  B: 9a707715

// ===== Section A =====
module {
  // (seed A not plausible MLIR — omitted)
}

// -----

// ===== Section B =====
module {
  // Note: Listener notifications appear after the pattern application because
  // the conversion driver sends all notifications at the end of the conversion
  // in bulk.
  func.func @B_9a707715_verifyDirectPattern() -> i32 {
    %result = "test.illegal_op_a"() : () -> (i32)
    return %result : i32
  }


  // Note: func.return is modified a second time when running in no-rollback
  //       mode.

  func.func @B_9a707715_verifyLargerBenefit() -> i32 {
    %result = "test.illegal_op_c"() : () -> (i32)
    return %result : i32
  }


  // Note: No block insertion because this function is external and no block
  // signature conversion is performed.

  func.func private @remap_input_1_to_0(i16)


  func.func @B_9a707715_remap_input_1_to_1(%arg0: i64) {
    "test.invalid"(%arg0) : (i64) -> ()
  }

  func.func @B_9a707715_remap_call_1_to_1(%arg0: i64) {
    call @B_9a707715_remap_input_1_to_1(%arg0) : (i64) -> ()
    return
  }


  // Block signature conversion: new block is inserted.

  // Contents of the old block are moved to the new block.

  // The old block is erased.

  // The function op gets a new type attribute.

  // "test.return" is replaced.

  func.func @B_9a707715_remap_input_1_to_N(%arg0: f32) -> f32 {
    "test.return"(%arg0) : (f32) -> ()
  }


  func.func @B_9a707715_remap_input_1_to_N_remaining_use(%arg0: f32) {
    "work"(%arg0) : (f32) -> ()
  }

  func.func @B_9a707715_remap_materialize_1_to_1(%arg0: i42) {
    "work"(%arg0) : (i42) -> ()
    "test.return"() : () -> ()
  }


  func.func @B_9a707715_remap_input_to_self(%arg0: index) {
    "work"(%arg0) : (index) -> ()
  }

  func.func @B_9a707715_remap_multi(%arg0: i64, %unused: i16, %arg1: i64) -> (i64, i64) {
   "test.invalid"(%arg0, %arg1) : (i64, i64) -> ()
  }


  func.func @B_9a707715_no_remap_nested() {
    "foo.region"() ({
      ^bb0(%i0: f64, %unused: i16, %i1: f64):
        "test.invalid"(%i0, %i1) : (f64, f64) -> ()
    }) : () -> ()
    return
  }


  func.func @B_9a707715_remap_drop_region() {
    "test.drop_region_op"() ({
      ^bb1(%i0: i64, %unused: i16, %i1: i64, %2: f32):
        "test.invalid"(%i0, %i1, %2) : (i64, i64, f32) -> ()
    }) : () -> ()
    return
  }


  func.func @B_9a707715_dropped_input_in_use(%arg: i16, %arg2: i64) {
    "work"(%arg) : (i16) -> ()
  }


  func.func @B_9a707715_up_to_date_replacement(%arg: i8) -> i8 {
    %repl_1 = "test.rewrite"(%arg) : (i8) -> i8
    %repl_2 = "test.rewrite"(%repl_1) : (i8) -> i8
    return %repl_2 : i8
  }


  func.func @B_9a707715_remove_foldable_op(%arg0 : i32) -> (i32) {
    %0 = "test.op_with_region_fold"(%arg0) ({
      "foo.op_with_region_terminator"() : () -> ()
    }) : (i32) -> (i32)
    return %0 : i32
  }


  func.func @B_9a707715_create_block() {
    // Check that we created a block with arguments.
    "test.create_block"() : () -> ()

    return
  }



  func.func @B_9a707715_bounded_recursion() {
    test.recursive_rewrite 3
    return
  }


  builtin.module {

    func.func @B_9a707715_fail_to_convert_illegal_op() -> i32 {
      %result = "test.illegal_op_f"() : () -> (i32)
      return %result : i32
    }

  }


  func.func @B_9a707715_replace_block_arg_1_to_n() {
    "test.legal_op"() ({
    ^bb0(%arg0: i32, %arg1: i16):
      "test.value_replace"(%arg0, %arg1) : (i32, i16) -> ()
      "test.return"(%arg0) : (i32) -> ()
    }) : () -> ()
    "test.return"() : () -> ()
  }


  func.func @B_9a707715_replace_op_result_1_to_n() -> i32 {
    %0 = "test.legal_op"() : () -> i32
    %1 = "test.legal_op"() : () -> i16

    "test.value_replace"(%0, %1) : (i32, i16) -> ()
    "test.return"(%0) : (i32) -> ()
  }


  // Check that a conversion pattern on `test.blackhole` can mark the producer
  // for deletion.
  func.func @B_9a707715_blackhole() {
    %input = "test.blackhole_producer"() : () -> (i32)
    "test.blackhole"(%input) : (i32) -> ()
    return
  }


  module {
  func.func private @callee() -> (f32, i24)

  func.func @B_9a707715_caller() {
    // f32 is converted to (f16, f16).
    // i24 is converted to ().
    %0:2 = func.call @callee() : () -> (f32, i24)

    "test.some_user"(%0#0, %0#1) : (f32, i24) -> ()
    "test.return"() : () -> ()
  }
  }


  func.func @B_9a707715_use_of_replaced_bbarg(%arg0: i64) {
    %0 = "test.op_with_region_fold"(%arg0) ({
      "foo.op_with_region_terminator"() : () -> ()
    }) : (i64) -> (i64)
    "test.invalid"(%0) : (i64) -> ()
  }


  func.func @B_9a707715_fold_legalization() -> i32 {
    %1 = "test.op_in_place_self_fold"() : () -> (i32)
    "test.return"(%1) : (i32) -> ()
  }


  func.func @B_9a707715_convert_detached_signature() {
    "test.detached_signature_conversion"() ({
    ^bb0(%arg0: i64):
      "test.return"() : () -> ()
    }) : () -> ()
    "test.return"() : () -> ()
  }



  func.func @B_9a707715_circular_mapping() {
    // Regression test that used to crash due to circular
    // unrealized_conversion_cast ops. 
    %0 = "test.erase_op"() ({
      "test.dummy_op_lvl_1"() ({
        "test.dummy_op_lvl_2"() : () -> ()
      }) : () -> ()
    }): () -> (i64)
    "test.drop_operands_and_replace_with_valid"(%0) : (i64) -> ()
  }


  func.func @B_9a707715_test_duplicate_block_arg() {
    test.convert_block_args duplicate {
    ^bb0(%arg0: i64):
      "test.repetitive_1_to_n_consumer"(%arg0) : (i64) -> ()
    } : () -> ()
    "test.return"() : () -> ()
  }


  func.func @B_9a707715_test_remap_block_arg() {
    %0 = "test.legal_op"() : () -> (i32)
    test.convert_block_args %0 replace_with_operand {
    ^bb0(%arg0: i32):
      "test.repetitive_1_to_n_consumer"(%arg0) : (i32) -> ()
    } : (i32) -> ()
    "test.return"() : () -> ()
  }



  // Note: There is a bug in the rollback-based conversion driver: it emits a
  // "test.cast" : (f16, f16, f16, f16) -> f16, when it should be emitting
  // three consecutive casts of (f16, f16) -> f16.
  func.func @B_9a707715_test_multiple_1_to_n_replacement() {
    %0 = "test.multiple_1_to_n_replacement"() : () -> (f16)
    "test.invalid"(%0) : (f16) -> ()
  }


  func.func @B_9a707715_test_lookup_without_converter() {
    %0 = "test.replace_with_valid_producer"() {type = i16} : () -> (i64)
    "test.replace_with_valid_consumer"(%0) {with_converter} : (i64) -> ()
    // Make sure that the second "replace_with_valid_consumer" lowering does not
    // lookup the materialization that was created for the above op.
    "test.replace_with_valid_consumer"(%0) : (i64) -> ()
    return
  }


  func.func @B_9a707715_test_skip_1to1_pattern(%arg0: f32) {
    "test.type_consumer"(%arg0) : (f32) -> ()
    return
  }


  // Demonstrate that the pattern generally works, but only for 1:1 type
  // conversions.

  func.func @B_9a707715_test_working_1to1_pattern(%arg0: f16) {
    "test.type_consumer"(%arg0) : (f16) -> ()
    "test.return"() : () -> ()
  }


  // The region of "test.post_order_legalization" is converted before the op.


  // Note: The survival of a not-explicitly-invalid operation does *not* cause
  // a conversion failure in when applying a partial conversion.
  func.func @B_9a707715_test_preorder_legalization() {
    "test.post_order_legalization"() ({
    ^bb0(%arg0: i64):
      "test.remaining_consumer"(%arg0) : (i64) -> ()
      "test.legal_op"() ({
        "test.invalid"(%arg0) : (i64) -> ()
      }) : () -> ()
      "test.invalid"(%arg0) : (i64) -> ()
    }) : () -> ()
    return
  }
}

// -----

// ===== FFL Bridge + Bug Primitives =====
module {

  // P9: Multi-result function & call — multi-value SSA lowering
  func.func @_ffl_p9_divmod(%a : i32, %b : i32) -> (i32, i32) {
    %q = arith.divsi %a, %b : i32
    %r = arith.remsi %a, %b : i32
    return %q, %r : i32, i32
  }

  func.func @_ffl_p9_call() -> i32 {
    %num = arith.constant 1000000007 : i32
    %den = arith.constant 998244353 : i32
    %q, %r = func.call @_ffl_p9_divmod(%num, %den) : (i32, i32) -> (i32, i32)
    %res = arith.addi %q, %r : i32
    return %res : i32
  }
}

```

Resulted in this output:

```
mlir-opt: /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/mlir/lib/Transforms/Utils/Inliner.cpp:42: void walkReferencedSymbolNodes(mlir::Operation*, mlir::CallGraph&, mlir::SymbolTableCollection&, mlir::DenseMap<mlir::Attribute, mlir::CallGraphNode*>&, mlir::function_ref<void(mlir::CallGraphNode*, mlir::Operation*)>): Assertion `symbolUses && "expected uses to be valid"' failed.
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and instructions to reproduce the bug.
Stack dump:
0.	Program arguments: /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-mlir-install/bin/mlir-opt --split-input-file --allow-unregistered-dialect --inline --loop-invariant-code-motion --cse --canonicalize --symbol-dce --sccp --verify-each /home/fuzz/WorkSpace/fusion-fuzz/.fused/mlir/tmpgqobe1w3/e62d92b2.mlir
 #0 0x00006092e3549f42 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/llvm/lib/Support/Unix/Signals.inc:884:3
 #1 0x00006092e35468bc llvm::sys::RunSignalHandlers() /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/llvm/lib/Support/Signals.cpp:108:20
 #2 0x00006092e3546f81 SignalHandler(int, siginfo_t*, void*) /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/llvm/lib/Support/Unix/Signals.inc:448:14
 #3 0x000078b2603e2520 (/lib/x86_64-linux-gnu/libc.so.6+0x42520)
 #4 0x000078b2604369fc pthread_kill (/lib/x86_64-linux-gnu/libc.so.6+0x969fc)
 #5 0x000078b2603e2476 gsignal (/lib/x86_64-linux-gnu/libc.so.6+0x42476)
 #6 0x000078b2603c87f3 abort (/lib/x86_64-linux-gnu/libc.so.6+0x287f3)
 #7 0x000078b2603c871b (/lib/x86_64-linux-gnu/libc.so.6+0x2871b)
 #8 0x000078b2603d9e96 (/lib/x86_64-linux-gnu/libc.so.6+0x39e96)
 #9 0x00006092eac3da98 walkReferencedSymbolNodes(mlir::Operation*, mlir::CallGraph&, mlir::SymbolTableCollection&, llvm::DenseMap<mlir::Attribute, mlir::CallGraphNode*, llvm::DenseMapInfo<mlir::Attribute, void>, llvm::detail::DenseMapPair<mlir::Attribute, mlir::CallGraphNode*>>&, llvm::function_ref<void (mlir::CallGraphNode*, mlir::Operation*)>) /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/mlir/lib/Transforms/Utils/Inliner.cpp:62:1
#10 0x00006092eac3e1cd llvm::DenseMap<mlir::Attribute, mlir::CallGraphNode*, llvm::DenseMapInfo<mlir::Attribute, void>, llvm::detail::DenseMapPair<mlir::Attribute, mlir::CallGraphNode*>>::deallocateBuckets() /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/llvm/include/llvm/ADT/DenseMap.h:822:50
#11 0x00006092eac3e1cd llvm::DenseMap<mlir::Attribute, mlir::CallGraphNode*, llvm::DenseMapInfo<mlir::Attribute, void>, llvm::detail::DenseMapPair<mlir::Attribute, mlir::CallGraphNode*>>::~DenseMap() /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/llvm/include/llvm/ADT/DenseMap.h:784:22
#12 0x00006092eac3e1cd (anonymous namespace)::CGUseList::recomputeUses(mlir::CallGraphNode*, mlir::CallGraph&) /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/mlir/lib/Transforms/Utils/Inliner.cpp:233:1
#13 0x00006092eac41f84 CGUseList /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/mlir/lib/Transforms/Utils/Inliner.cpp:159:30
#14 0x00006092eac41f84 mlir::Inliner::doInlining() /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/mlir/lib/Transforms/Utils/Inliner.cpp:759:40
#15 0x00006092eaba95db (anonymous namespace)::InlinerPass::runOnOperation() /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/mlir/lib/Transforms/InlinerPass.cpp:152:3
#16 0x00006092eaccc7a6 operator() /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/mlir/lib/Pass/Pass.cpp:612:33
#17 0x00006092eaccc7a6 callback_fn<mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int)::<lambda()> > /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:46:52
#18 0x00006092eaccc7a6 llvm::function_ref<void ()>::operator()() const /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:69:12
#19 0x00006092eaccc7a6 void mlir::MLIRContext::executeAction<mlir::PassExecutionAction, mlir::Pass&>(llvm::function_ref<void ()>, llvm::ArrayRef<mlir::IRUnit>, mlir::Pass&) /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/mlir/include/mlir/IR/MLIRContext.h:294:15
#20 0x00006092eaccc7a6 mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int) /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/mlir/lib/Pass/Pass.cpp:606:57
#21 0x00006092eaccca74 mlir::detail::OpToOpPassAdaptor::runPipeline(mlir::OpPassManager&, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int, mlir::PassInstrumentor*, mlir::PassInstrumentation::PipelineParentInfo const*) /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/mlir/lib/Pass/Pass.cpp:688:5
#22 0x00006092eaccea13 mlir::PassManager::runPasses(mlir::Operation*, mlir::AnalysisManager) /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/mlir/lib/Pass/Pass.cpp:1129:71
#23 0x00006092eaccffcb mlir::PassManager::run(mlir::Operation*) /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/mlir/lib/Pass/Pass.cpp:1102:69
#24 0x00006092e35f790d performActions(llvm::raw_ostream&, std::shared_ptr<llvm::SourceMgr> const&, mlir::MLIRContext*, mlir::MlirOptMainConfig const&) /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:596:3
#25 0x00006092e35f813c ~DiagnosticFilter /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:310:7
#26 0x00006092e35f813c processBuffer(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef, mlir::MlirOptMainConfig const&, mlir::DialectRegistry&, mlir::SourceMgrDiagnosticVerifierHandler*, llvm::ThreadPoolInterface*) /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:687:3
#27 0x00006092e35f8351 std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>::~unique_ptr() /usr/include/c++/11/bits/unique_ptr.h:360:12
#28 0x00006092e35f8351 operator() /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:784:25
#29 0x00006092e35f8351 llvm::LogicalResult llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>::callback_fn<mlir::MlirOptMain(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, mlir::DialectRegistry&, mlir::MlirOptMainConfig const&)::'lambda'(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef, llvm::raw_ostream&)>(long, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&) /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:46:52
#30 0x00006092eb02e45a std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>::~unique_ptr() /usr/include/c++/11/bits/unique_ptr.h:360:12
#31 0x00006092eb02e45a llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>::operator()(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&) const /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:69:12
#32 0x00006092eb02e45a mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::'lambda'(llvm::StringRef)::operator()(llvm::StringRef) const /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/mlir/lib/Support/ToolUtilities.cpp:93:15
#33 0x00006092eb02ea3d interleave<const llvm::StringRef*, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer>, mlir::ChunkBufferHandler, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::<lambda(llvm::StringRef)>, llvm::interleave<llvm::SmallVector<llvm::StringRef, 8>, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer>, mlir::ChunkBufferHandler, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::<lambda(llvm::StringRef)>, llvm::raw_ostream>(const llvm::SmallVector<llvm::StringRef, 8>&, llvm::raw_ostream&, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer>, mlir::ChunkBufferHandler, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::<lambda(llvm::StringRef)>, const llvm::StringRef&)::<lambda()> > /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/llvm/include/llvm/ADT/STLExtras.h:2280:16
#34 0x00006092eb02ea3d interleave<llvm::SmallVector<llvm::StringRef, 8>, mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer>, mlir::ChunkBufferHandler, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef)::<lambda(llvm::StringRef)>, llvm::raw_ostream> /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/llvm/include/llvm/ADT/STLExtras.h:2300:13
#35 0x00006092eb02ea3d mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef) /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/mlir/lib/Support/ToolUtilities.cpp:97:19
#36 0x00006092e35ef763 std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>::~unique_ptr() /usr/include/c++/11/bits/unique_ptr.h:360:12
#37 0x00006092e35ef763 mlir::MlirOptMain(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, mlir::DialectRegistry&, mlir::MlirOptMainConfig const&) (.part.0) /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:790:39
#38 0x00006092e35f88e8 mlir::MlirOptMain(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer>>, mlir::DialectRegistry&, mlir::MlirOptMainConfig const&) /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/llvm/include/llvm/Support/LogicalResult.h:62:42
#39 0x00006092e35f88e8 mlir::MlirOptMain(int, char**, llvm::StringRef, llvm::StringRef, mlir::DialectRegistry&) /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:835:13
#40 0x00006092e35f8b22 std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char>>::_M_data() const /usr/include/c++/11/bits/basic_string.h:195:28
#41 0x00006092e35f8b22 std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char>>::_M_is_local() const /usr/include/c++/11/bits/basic_string.h:230:23
#42 0x00006092e35f8b22 std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char>>::_M_dispose() /usr/include/c++/11/bits/basic_string.h:239:18
#43 0x00006092e35f8b22 std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char>>::~basic_string() /usr/include/c++/11/bits/basic_string.h:672:19
#44 0x00006092e35f8b22 mlir::MlirOptMain(int, char**, llvm::StringRef, mlir::DialectRegistry&) /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:852:1
#45 0x00006092e3455627 main /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-project/mlir/tools/mlir-opt/mlir-opt.cpp:347:1
#46 0x000078b2603c9d90 (/lib/x86_64-linux-gnu/libc.so.6+0x29d90)
#47 0x000078b2603c9e40 __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x29e40)
#48 0x00006092e352db65 _start (/home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-mlir-install/bin/mlir-opt+0x293cb65)
Aborted (core dumped)
module {
}

// -----
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-mlir-install/bin/mlir-opt --split-input-file --allow-unregistered-dialect --inline --loop-invariant-code-motion --cse --canonicalize --symbol-dce --sccp --verify-each "$SCRIPT_DIR/test.mlir"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `aa1bdd52` | Bug corpus (project: `php`, name: `gh11289.phpt`) |
| `b` | `9a707715` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
