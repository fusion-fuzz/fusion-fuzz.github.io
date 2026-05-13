# [mlir] memory leak at mlir/include/mlir/IR/Region.h (ModuleOp::build)

**Issue:** [https://github.com/llvm/llvm-project/issues/163673](https://github.com/llvm/llvm-project/issues/163673) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-16T01:07:26Z`

**Labels:** `duplicate`, `code-quality`, `mlir`

## Description

```
module {
  spirv.module Logical GLSL450 requires #spirv.vce<v1.0, [Shader], []> {
  }
  spirv.module Logical GLSL450 requires #spirv.vce<v1.0, [Shader], []> {
    spirv.SpecConstant @sc2 = 3 : i8
    spirv.GlobalVariable @var1 {
      linkage_attributes=#spirv.linkage_attributes<
        linkage_name="outSideGlobalVar1", 
        linkage_type=<Import>
      >
    } : !spirv.ptr<f32, Private>
  }
  func.func @fusion_bridge_521672475() -> i32 {
    %c = arith.constant 0 : i32
    return %c : i32
  }
}
```

repro: `mlir-opt -convert-spirv-to-llvm=client-api=Vulkan -verify-diagnostics ./test.mlir`

stderr:
```
=================================================================
==3331763==ERROR: LeakSanitizer: detected memory leaks

Direct leak of 144 byte(s) in 2 object(s) allocated from:
    #0 0x5961ff36577d in operator new(unsigned long) (llvm-mlir-build/bin/mlir-opt+0x843f77d) (BuildId: 8d3f598c321c686de3addc0e0905b4ae76916fb7)
    #1 0x5961ff902152 in mlir::Region::emplaceBlock() llvm-project/mlir/include/mlir/IR/Region.h:47:15
    #2 0x59621231598c in mlir::ModuleOp::build(mlir::OpBuilder&, mlir::OperationState&, std::optional<llvm::StringRef>) llvm-project/mlir/lib/IR/BuiltinDialect.cpp:125:22
    #3 0x596212315eb7 in mlir::ModuleOp::create(mlir::OpBuilder&, mlir::Location, std::optional<llvm::StringRef>) llvm-mlir-build/tools/mlir/include/mlir/IR/BuiltinOps.cpp.inc:251:3
    #4 0x596207e65870 in (anonymous namespace)::ModuleConversionPattern::matchAndRewrite(mlir::spirv::ModuleOp, mlir::spirv::ModuleOpAdaptor, mlir::ConversionPatternRewriter&) const llvm-project/mlir/lib/Conversion/SPIRVToLLVM/SPIRVToLLVM.cpp:1713:9
    #5 0x596207e65faa in llvm::LogicalResult mlir::ConversionPattern::dispatchTo1To1<mlir::OpConversionPattern<mlir::spirv::ModuleOp>, mlir::spirv::ModuleOp>(mlir::OpConversionPattern<mlir::spirv::ModuleOp> const&, mlir::spirv::ModuleOp, mlir::spirv::ModuleOp::GenericAdaptor<llvm::ArrayRef<mlir::ValueRange> >, mlir::ConversionPatternRewriter&) llvm-project/mlir/include/mlir/Transforms/DialectConversion.h:1025:15
    #6 0x596207e65ba4 in mlir::OpConversionPattern<mlir::spirv::ModuleOp>::matchAndRewrite(mlir::spirv::ModuleOp, mlir::spirv::ModuleOpGenericAdaptor<llvm::ArrayRef<mlir::ValueRange> >, mlir::ConversionPatternRewriter&) const llvm-project/mlir/include/mlir/Transforms/DialectConversion.h:727:12
    #7 0x596207e655a7 in mlir::OpConversionPattern<mlir::spirv::ModuleOp>::matchAndRewrite(mlir::Operation*, llvm::ArrayRef<mlir::ValueRange>, mlir::ConversionPatternRewriter&) const llvm-project/mlir/include/mlir/Transforms/DialectConversion.h:713:12
    #8 0x596211b39925 in mlir::ConversionPattern::matchAndRewrite(mlir::Operation*, mlir::PatternRewriter&) const llvm-project/mlir/lib/Transforms/Utils/DialectConversion.cpp:2359:10
    #9 0x596211c11a9d in mlir::PatternApplicator::matchAndRewrite(mlir::Operation*, mlir::PatternRewriter&, llvm::function_ref<bool (mlir::Pattern const&)>, llvm::function_ref<void (mlir::Pattern const&)>, llvm::function_ref<llvm::LogicalResult (mlir::Pattern const&)>)::$_6::operator()() const llvm-project/mlir/lib/Rewrite/PatternApplicator.cpp:223:31
    #10 0x596211c11a9d in void llvm::function_ref<void ()>::callback_fn<mlir::PatternApplicator::matchAndRewrite(mlir::Operation*, mlir::PatternRewriter&, llvm::function_ref<bool (mlir::Pattern const&)>, llvm::function_ref<void (mlir::Pattern const&)>, llvm::function_ref<llvm::LogicalResult (mlir::Pattern const&)>)::$_6>(long) llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:46:12
    #11 0x596211c0707d in llvm::function_ref<void ()>::operator()() const llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:69:12
    #12 0x596211c0707d in void mlir::MLIRContext::executeAction<mlir::ApplyPatternAction, mlir::Pattern const&>(llvm::function_ref<void ()>, llvm::ArrayRef<mlir::IRUnit>, mlir::Pattern const&) llvm-project/mlir/include/mlir/IR/MLIRContext.h:290:7
    #13 0x596211c0707d in mlir::PatternApplicator::matchAndRewrite(mlir::Operation*, mlir::PatternRewriter&, llvm::function_ref<bool (mlir::Pattern const&)>, llvm::function_ref<void (mlir::Pattern const&)>, llvm::function_ref<llvm::LogicalResult (mlir::Pattern const&)>) llvm-project/mlir/lib/Rewrite/PatternApplicator.cpp:197:23
    #14 0x596211b3d9a9 in (anonymous namespace)::OperationLegalizer::legalizeWithPattern(mlir::Operation*) llvm-project/mlir/lib/Transforms/Utils/DialectConversion.cpp:2797:21
    #15 0x596211b3d9a9 in (anonymous namespace)::OperationLegalizer::legalize(mlir::Operation*) llvm-project/mlir/lib/Transforms/Utils/DialectConversion.cpp:2563:17
    #16 0x596211b3c06f in mlir::OperationConverter::convert(mlir::Operation*) llvm-project/mlir/lib/Transforms/Utils/DialectConversion.cpp:3318:26
    #17 0x596211b3e86c in mlir::OperationConverter::convertOperations(llvm::ArrayRef<mlir::Operation*>) llvm-project/mlir/lib/Transforms/Utils/DialectConversion.cpp:3415:16
    #18 0x596211b67ebc in applyConversion(llvm::ArrayRef<mlir::Operation*>, mlir::ConversionTarget const&, mlir::FrozenRewritePatternSet const&, mlir::ConversionConfig, (anonymous namespace)::OpConversionMode)::$_43::operator()() const llvm-project/mlir/lib/Transforms/Utils/DialectConversion.cpp:4137:30
    #19 0x596211b67ebc in void llvm::function_ref<void ()>::callback_fn<applyConversion(llvm::ArrayRef<mlir::Operation*>, mlir::ConversionTarget const&, mlir::FrozenRewritePatternSet const&, mlir::ConversionConfig, (anonymous namespace)::OpConversionMode)::$_43>(long) llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:46:12
    #20 0x596211b4cb00 in llvm::function_ref<void ()>::operator()() const llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:69:12
    #21 0x596211b4cb00 in void mlir::MLIRContext::executeAction<ApplyConversionAction>(llvm::function_ref<void ()>, llvm::ArrayRef<mlir::IRUnit>) llvm-project/mlir/include/mlir/IR/MLIRContext.h:290:7
    #22 0x596211b4cb00 in applyConversion(llvm::ArrayRef<mlir::Operation*>, mlir::ConversionTarget const&, mlir::FrozenRewritePatternSet const&, mlir::ConversionConfig, (anonymous namespace)::OpConversionMode) llvm-project/mlir/lib/Transforms/Utils/DialectConversion.cpp:4133:8
    #23 0x596211b4ce39 in mlir::applyPartialConversion(llvm::ArrayRef<mlir::Operation*>, mlir::ConversionTarget const&, mlir::FrozenRewritePatternSet const&, mlir::ConversionConfig) llvm-project/mlir/lib/Transforms/Utils/DialectConversion.cpp:4150:10
    #24 0x596211b4ce39 in mlir::applyPartialConversion(mlir::Operation*, mlir::ConversionTarget const&, mlir::FrozenRewritePatternSet const&, mlir::ConversionConfig) llvm-project/mlir/lib/Transforms/Utils/DialectConversion.cpp:4157:10
    #25 0x596207e69466 in (anonymous namespace)::ConvertSPIRVToLLVMPass::runOnOperation() llvm-project/mlir/lib/Conversion/SPIRVToLLVM/SPIRVToLLVMPass.cpp:71:14
    #26 0x596211d19f43 in mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int)::$_44::operator()() const llvm-project/mlir/lib/Pass/Pass.cpp:609:17
    #27 0x596211d19f43 in void llvm::function_ref<void ()>::callback_fn<mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int)::$_44>(long) llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:46:12
    #28 0x596211d03119 in llvm::function_ref<void ()>::operator()() const llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:69:12
    #29 0x596211d03119 in void mlir::MLIRContext::executeAction<mlir::PassExecutionAction, mlir::Pass&>(llvm::function_ref<void ()>, llvm::ArrayRef<mlir::IRUnit>, mlir::Pass&) llvm-project/mlir/include/mlir/IR/MLIRContext.h:290:7
    #30 0x596211d03119 in mlir::detail::OpToOpPassAdaptor::run(mlir::Pass*, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int) llvm-project/mlir/lib/Pass/Pass.cpp:603:21
    #31 0x596211d050eb in mlir::detail::OpToOpPassAdaptor::runPipeline(mlir::OpPassManager&, mlir::Operation*, mlir::AnalysisManager, bool, unsigned int, mlir::PassInstrumentor*, mlir::PassInstrumentation::PipelineParentInfo const*) llvm-project/mlir/lib/Pass/Pass.cpp:682:16
    #32 0x596211d11237 in mlir::PassManager::runPasses(mlir::Operation*, mlir::AnalysisManager) llvm-project/mlir/lib/Pass/Pass.cpp:1117:10
    #33 0x596211d0fdb3 in mlir::PassManager::run(mlir::Operation*) llvm-project/mlir/lib/Pass/Pass.cpp:1091:60
    #34 0x5961ff56b603 in performActions(llvm::raw_ostream&, std::shared_ptr<llvm::SourceMgr> const&, mlir::MLIRContext*, mlir::MlirOptMainConfig const&) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:568:17
    #35 0x5961ff56a32f in processBuffer(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef, mlir::MlirOptMainConfig const&, mlir::DialectRegistry&, mlir::SourceMgrDiagnosticVerifierHandler*, llvm::ThreadPoolInterface*) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:650:9
    #36 0x5961ff56a32f in mlir::MlirOptMain(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, mlir::DialectRegistry&, mlir::MlirOptMainConfig const&)::$_3::operator()(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef, llvm::raw_ostream&) const llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:733:12
    #37 0x5961ff56a32f in llvm::LogicalResult llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>::callback_fn<mlir::MlirOptMain(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, mlir::DialectRegistry&, mlir::MlirOptMainConfig const&)::$_3>(long, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&) llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:46:12
    #38 0x59621252ea63 in llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>::operator()(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&) const llvm-project/llvm/include/llvm/ADT/STLFunctionalExtras.h:69:12
    #39 0x59621252e0a6 in mlir::splitAndProcessBuffer(std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::function_ref<llvm::LogicalResult (std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, llvm::MemoryBufferRef const&, llvm::raw_ostream&)>, llvm::raw_ostream&, llvm::StringRef, llvm::StringRef) llvm-project/mlir/lib/Support/ToolUtilities.cpp:30:12
    #40 0x5961ff54f431 in mlir::MlirOptMain(llvm::raw_ostream&, std::unique_ptr<llvm::MemoryBuffer, std::default_delete<llvm::MemoryBuffer> >, mlir::DialectRegistry&, mlir::MlirOptMainConfig const&) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:738:26
    #41 0x5961ff54fe6d in mlir::MlirOptMain(int, char**, llvm::StringRef, llvm::StringRef, mlir::DialectRegistry&) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:784:14
    #42 0x5961ff5505c2 in mlir::MlirOptMain(int, char**, llvm::StringRef, mlir::DialectRegistry&) llvm-project/mlir/lib/Tools/mlir-opt/MlirOptMain.cpp:800:10

SUMMARY: AddressSanitizer: 144 byte(s) leaked in 2 allocation(s).
```

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
