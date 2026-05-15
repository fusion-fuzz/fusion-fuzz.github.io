---
render_with_liquid: false
---

**Date:** `2026-01-12`
# [Assertion failed in `SILBuilder::insertImpl` via `emitMarkFunctionEscape` when defining struct after top-level terminator](https://github.com/swiftlang/swift/issues/86489)

### Description

_No response_

### Reproduction

```swift
var x = 0
throw E()

struct E: Error {
    init() {
        _ = x
    }
}
```


### Stack dump

```text
Assertion failed: (hasValidInsertionPoint()), function insertImpl at SILBuilder.h:3191.
(to display assertion configuration options: -Xllvm -assert-help)
Stack dump:
0.	Program arguments: /usr/bin/swift-frontend -frontend -interpret min.swift -disable-objc-interop -color-diagnostics -Xcc -fcolor-diagnostics -empty-abi-descriptor -no-auto-bridging-header-chaining -module-name min -in-process-plugin-server-path /usr/lib/swift/host/libSwiftInProcPluginServer.so -plugin-path /usr/lib/swift/host/plugins -plugin-path /usr/local/lib/swift/host/plugins
1.	Swift version 6.2.3 (swift-6.2.3-RELEASE)
2.	Compiling with effective version 5.10
3.	While evaluating request ASTLoweringRequest(Lowering AST to SIL for module min)
 #0 0x000063f2b2d0cc58 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/bin/swift-frontend+0x731ec58)
 #1 0x000063f2b2d0aa2e llvm::sys::RunSignalHandlers() (/usr/bin/swift-frontend+0x731ca2e)
 #2 0x000063f2b2d0d2f1 SignalHandler(int, siginfo_t*, void*) Signals.cpp:0:0
 #3 0x00007a2b23a7f330 (/lib/x86_64-linux-gnu/libc.so.6+0x45330)
 #4 0x00007a2b23ad8b2c pthread_kill (/lib/x86_64-linux-gnu/libc.so.6+0x9eb2c)
 #5 0x00007a2b23a7f27e raise (/lib/x86_64-linux-gnu/libc.so.6+0x4527e)
 #6 0x00007a2b23a628ff abort (/lib/x86_64-linux-gnu/libc.so.6+0x288ff)
 #7 0x000063f2ae117b2b (/usr/bin/swift-frontend+0x2729b2b)
 #8 0x000063f2ac333dc9 swift::SILBuilder::insertImpl(swift::SILInstruction*) crtstuff.c:0:0
 #9 0x000063f2acd48dcd swift::Lowering::SILGenFunction::emitMarkFunctionEscapeForTopLevelCodeGlobals(swift::SILLocation, swift::CaptureInfo) crtstuff.c:0:0
#10 0x000063f2acd49396 emitMarkFunctionEscape(swift::Lowering::SILGenFunction&, swift::AbstractFunctionDecl*) SILGenTopLevel.cpp:0:0
#11 0x000063f2acd48f70 swift::ASTVisitor<swift::Lowering::SILGenTopLevel, void, void, void, void, void, void>::visit(swift::Decl*) crtstuff.c:0:0
#12 0x000063f2acd4765b swift::Lowering::SILGenTopLevel::visitSourceFile(swift::SourceFile*) (/usr/bin/swift-frontend+0x135965b)
#13 0x000063f2acd46b36 swift::Lowering::SILGenModule::emitEntryPoint(swift::SourceFile*, swift::SILFunction*) crtstuff.c:0:0
#14 0x000063f2acd48bf6 swift::Lowering::SILGenModule::emitEntryPoint(swift::SourceFile*) crtstuff.c:0:0
#15 0x000063f2acc5a431 swift::Lowering::SILGenModule::emitSourceFile(swift::SourceFile*) crtstuff.c:0:0
#16 0x000063f2acc5abe0 swift::ASTLoweringRequest::evaluate(swift::Evaluator&, swift::ASTLoweringDescriptor) const (/usr/bin/swift-frontend+0x126cbe0)
#17 0x000063f2acd38684 std::unique_ptr<swift::SILModule, std::default_delete<swift::SILModule>> swift::SimpleRequest<swift::ASTLoweringRequest, std::unique_ptr<swift::SILModule, std::default_delete<swift::SILModule>> (swift::ASTLoweringDescriptor), (swift::RequestFlags)17>::callDerived<0ul>(swift::Evaluator&, std::integer_sequence<unsigned long, 0ul>) const crtstuff.c:0:0
#18 0x000063f2acd385a9 swift::SimpleRequest<swift::ASTLoweringRequest, std::unique_ptr<swift::SILModule, std::default_delete<swift::SILModule>> (swift::ASTLoweringDescriptor), (swift::RequestFlags)17>::evaluateRequest(swift::ASTLoweringRequest const&, swift::Evaluator&) crtstuff.c:0:0
#19 0x000063f2acc5edd7 swift::ASTLoweringRequest::OutputType swift::Evaluator::getResultUncached<swift::ASTLoweringRequest, swift::ASTLoweringRequest::OutputType swift::evaluateOrFatal<swift::ASTLoweringRequest>(swift::Evaluator&, swift::ASTLoweringRequest)::'lambda'()>(swift::ASTLoweringRequest const&, swift::ASTLoweringRequest::OutputType swift::evaluateOrFatal<swift::ASTLoweringRequest>(swift::Evaluator&, swift::ASTLoweringRequest)::'lambda'()) crtstuff.c:0:0
#20 0x000063f2acc5b04f swift::performASTLowering(swift::ModuleDecl*, swift::Lowering::TypeConverter&, swift::SILOptions const&, swift::IRGenOptions const*) (/usr/bin/swift-frontend+0x126d04f)
#21 0x000063f2ac560b11 swift::performCompileStepsPostSema(swift::CompilerInstance&, int&, swift::FrontendObserver*) (/usr/bin/swift-frontend+0xb72b11)
#22 0x000063f2ac56f2cb withSemanticAnalysis(swift::CompilerInstance&, swift::FrontendObserver*, llvm::function_ref<bool (swift::CompilerInstance&)>, bool) FrontendTool.cpp:0:0
#23 0x000063f2ac563fe2 performCompile(swift::CompilerInstance&, int&, swift::FrontendObserver*) FrontendTool.cpp:0:0
#24 0x000063f2ac562744 swift::performFrontend(llvm::ArrayRef<char const*>, char const*, void*, swift::FrontendObserver*) (/usr/bin/swift-frontend+0xb74744)
#25 0x000063f2ac314029 swift::mainEntry(int, char const**) (/usr/bin/swift-frontend+0x926029)
#26 0x00007a2b23a641ca (/lib/x86_64-linux-gnu/libc.so.6+0x2a1ca)
#27 0x00007a2b23a6428b __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28b)
#28 0x000063f2ac313175 _start (/usr/bin/swift-frontend+0x925175)
Aborted (core dumped)
```

### Expected behavior

should not crash

### Environment

Swift version 6.2.3 (swift-6.2.3-RELEASE)

### Additional information

_No response_
