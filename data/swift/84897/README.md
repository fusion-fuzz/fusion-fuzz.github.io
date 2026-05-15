# [swiftc crash `GenericSignatureImpl::getReducedTypeParameter`](https://github.com/swiftlang/swift/issues/84897)

### Description

_No response_

### Reproduction

```swift
protocol a {
  protocol a{associatedtype b} extension a {
    extension a {
      struct c {
        d : b


let __fusion_0 = [1,2,3]

class B {
class d<T, i where B : b> : d {
case c> : P {
init<D> s: e("
}
var b = __fusion_0
```


### Stack dump

```text
Please submit a bug report (https://swift.org/contributing/#reporting-bugs) and include the crash backtrace.
Stack dump:
0.	Program arguments: /usr/bin/swift-frontend -frontend -c -primary-file min.swift -target x86_64-unknown-linux-gnu -disable-objc-interop -color-diagnostics -Xcc -fcolor-diagnostics -empty-abi-descriptor -no-auto-bridging-header-chaining -module-name min -in-process-plugin-server-path /usr/lib/swift/host/libSwiftInProcPluginServer.so -plugin-path /usr/lib/swift/host/plugins -plugin-path /usr/local/lib/swift/host/plugins -o /tmp/TemporaryDirectory.p6hOLn/min-1.o
1.	Swift version 6.2 (swift-6.2-RELEASE)
2.	Compiling with effective version 5.10
3.	While evaluating request TypeCheckPrimaryFileRequest(source_file "min.swift")
4.	While type-checking 'a' (at min.swift:1:1)
5.	While type-checking extension of a (at min.swift:2:32)
6.	While type-checking extension of a (at min.swift:3:5)
7.	While type-checking 'c' (at min.swift:4:7)
8.	While type-checking declaration 0x5a9a41fe4138 (at min.swift:5:9)
9.	While evaluating request PatternBindingEntryRequest((unknown decl)@min.swift:5:9, 0)
10.	While evaluating request PatternTypeRequest((pattern @ 0x5a9a41fe4118))
 #0 0x00005a9a09032598 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/bin/swift-frontend+0x7316598)
 #1 0x00005a9a0903036e llvm::sys::RunSignalHandlers() (/usr/bin/swift-frontend+0x731436e)
 #2 0x00005a9a09032c31 SignalHandler(int, siginfo_t*, void*) Signals.cpp:0:0
 #3 0x000070194b309330 (/lib/x86_64-linux-gnu/libc.so.6+0x45330)
 #4 0x000070194b362b2c pthread_kill (/lib/x86_64-linux-gnu/libc.so.6+0x9eb2c)
 #5 0x000070194b30927e raise (/lib/x86_64-linux-gnu/libc.so.6+0x4527e)
 #6 0x000070194b2ec8ff abort (/lib/x86_64-linux-gnu/libc.so.6+0x288ff)
 #7 0x00005a9a042e41ca (/usr/bin/swift-frontend+0x25c81ca)
 #8 0x00005a9a0422cf17 swift::GenericSignatureImpl::getReducedTypeParameter(swift::CanType) const (/usr/bin/swift-frontend+0x2510f17)
 #9 0x00005a9a042272cb swift::GenericEnvironment::getOrCreateArchetypeFromInterfaceType(swift::Type) (/usr/bin/swift-frontend+0x250b2cb)
#10 0x00005a9a04227117 swift::GenericEnvironment::mapTypeIntoContext(swift::GenericEnvironment*, swift::Type) (/usr/bin/swift-frontend+0x250b117)
#11 0x00005a9a03ca8514 swift::TypeResolution::resolveContextualType(swift::TypeRepr*, swift::DeclContext*, swift::GenericSignature, swift::TypeResolutionOptions, llvm::function_ref<swift::Type (swift::UnboundGenericType*)>, llvm::function_ref<swift::Type (swift::ASTContext&, swift::PlaceholderTypeRepr*)>, llvm::function_ref<swift::Type (swift::Type, swift::PackElementTypeRepr*)>, swift::SILTypeResolutionContext*) (/usr/bin/swift-frontend+0x1f8c514)
#12 0x00005a9a03ca8426 swift::TypeResolution::resolveContextualType(swift::TypeRepr*, swift::DeclContext*, swift::TypeResolutionOptions, llvm::function_ref<swift::Type (swift::UnboundGenericType*)>, llvm::function_ref<swift::Type (swift::ASTContext&, swift::PlaceholderTypeRepr*)>, llvm::function_ref<swift::Type (swift::Type, swift::PackElementTypeRepr*)>, swift::SILTypeResolutionContext*) (/usr/bin/swift-frontend+0x1f8c426)
#13 0x00005a9a03c418c4 validateTypedPattern(swift::TypedPattern*, swift::DeclContext*, swift::TypeResolutionOptions, llvm::function_ref<swift::Type (swift::UnboundGenericType*)>, llvm::function_ref<swift::Type (swift::ASTContext&, swift::PlaceholderTypeRepr*)>, llvm::function_ref<swift::Type (swift::Type, swift::PackElementTypeRepr*)>) TypeCheckPattern.cpp:0:0
#14 0x00005a9a03c4166f swift::PatternTypeRequest::evaluate(swift::Evaluator&, swift::ContextualPattern) const (/usr/bin/swift-frontend+0x1f2566f)
#15 0x00005a9a03c7db08 swift::SimpleRequest<swift::PatternTypeRequest, swift::Type (swift::ContextualPattern), (swift::RequestFlags)2>::evaluateRequest(swift::PatternTypeRequest const&, swift::Evaluator&) crtstuff.c:0:0
#16 0x00005a9a03c47a76 swift::PatternTypeRequest::OutputType swift::Evaluator::getResultUncached<swift::PatternTypeRequest, swift::PatternTypeRequest::OutputType swift::evaluateOrDefault<swift::PatternTypeRequest>(swift::Evaluator&, swift::PatternTypeRequest, swift::PatternTypeRequest::OutputType)::'lambda'()>(swift::PatternTypeRequest const&, swift::PatternTypeRequest::OutputType swift::evaluateOrDefault<swift::PatternTypeRequest>(swift::Evaluator&, swift::PatternTypeRequest, swift::PatternTypeRequest::OutputType)::'lambda'()) crtstuff.c:0:0
#17 0x00005a9a03c4796e swift::PatternTypeRequest::OutputType swift::Evaluator::getResultCached<swift::PatternTypeRequest, swift::PatternTypeRequest::OutputType swift::evaluateOrDefault<swift::PatternTypeRequest>(swift::Evaluator&, swift::PatternTypeRequest, swift::PatternTypeRequest::OutputType)::'lambda'(), (void*)0>(swift::PatternTypeRequest const&, swift::PatternTypeRequest::OutputType swift::evaluateOrDefault<swift::PatternTypeRequest>(swift::Evaluator&, swift::PatternTypeRequest, swift::PatternTypeRequest::OutputType)::'lambda'()) crtstuff.c:0:0
#18 0x00005a9a03c40df0 swift::TypeChecker::typeCheckPattern(swift::ContextualPattern) (/usr/bin/swift-frontend+0x1f24df0)
#19 0x00005a9a03c8b8b7 swift::PatternBindingEntryRequest::evaluate(swift::Evaluator&, swift::PatternBindingDecl*, unsigned int) const (/usr/bin/swift-frontend+0x1f6f8b7)
#20 0x00005a9a04132a6b swift::PatternBindingEntryRequest::OutputType swift::Evaluator::getResultUncached<swift::PatternBindingEntryRequest, swift::PatternBindingEntryRequest::OutputType swift::evaluateOrDefault<swift::PatternBindingEntryRequest>(swift::Evaluator&, swift::PatternBindingEntryRequest, swift::PatternBindingEntryRequest::OutputType)::'lambda'()>(swift::PatternBindingEntryRequest const&, swift::PatternBindingEntryRequest::OutputType swift::evaluateOrDefault<swift::PatternBindingEntryRequest>(swift::Evaluator&, swift::PatternBindingEntryRequest, swift::PatternBindingEntryRequest::OutputType)::'lambda'()) crtstuff.c:0:0
#21 0x00005a9a040fee8a swift::PatternBindingDecl::getCheckedPatternBindingEntry(unsigned int) const (/usr/bin/swift-frontend+0x23e2e8a)
#22 0x00005a9a03be6547 (anonymous namespace)::DeclChecker::visit(swift::Decl*) TypeCheckDeclPrimary.cpp:0:0
#23 0x00005a9a03be6e5b (anonymous namespace)::DeclChecker::visit(swift::Decl*) TypeCheckDeclPrimary.cpp:0:0
#24 0x00005a9a03beaa0b (anonymous namespace)::DeclChecker::visit(swift::Decl*) TypeCheckDeclPrimary.cpp:0:0
#25 0x00005a9a03beaa0b (anonymous namespace)::DeclChecker::visit(swift::Decl*) TypeCheckDeclPrimary.cpp:0:0
#26 0x00005a9a03be6efb (anonymous namespace)::DeclChecker::visit(swift::Decl*) TypeCheckDeclPrimary.cpp:0:0
#27 0x00005a9a03be62e2 swift::TypeChecker::typeCheckDecl(swift::Decl*) (/usr/bin/swift-frontend+0x1eca2e2)
#28 0x00005a9a03cc29a5 swift::TypeCheckPrimaryFileRequest::evaluate(swift::Evaluator&, swift::SourceFile*) const (/usr/bin/swift-frontend+0x1fa69a5)
#29 0x00005a9a03cc452e swift::TypeCheckPrimaryFileRequest::OutputType swift::Evaluator::getResultUncached<swift::TypeCheckPrimaryFileRequest, swift::TypeCheckPrimaryFileRequest::OutputType swift::evaluateOrDefault<swift::TypeCheckPrimaryFileRequest>(swift::Evaluator&, swift::TypeCheckPrimaryFileRequest, swift::TypeCheckPrimaryFileRequest::OutputType)::'lambda'()>(swift::TypeCheckPrimaryFileRequest const&, swift::TypeCheckPrimaryFileRequest::OutputType swift::evaluateOrDefault<swift::TypeCheckPrimaryFileRequest>(swift::Evaluator&, swift::TypeCheckPrimaryFileRequest, swift::TypeCheckPrimaryFileRequest::OutputType)::'lambda'()) crtstuff.c:0:0
#30 0x00005a9a03cc28e5 swift::performTypeChecking(swift::SourceFile&) (/usr/bin/swift-frontend+0x1fa68e5)
#31 0x00005a9a02b4f0b9 bool llvm::function_ref<bool (swift::SourceFile&)>::callback_fn<swift::CompilerInstance::performSema()::$_8>(long, swift::SourceFile&) Frontend.cpp:0:0
#32 0x00005a9a02b4480a swift::CompilerInstance::forEachFileToTypeCheck(llvm::function_ref<bool (swift::SourceFile&)>) (/usr/bin/swift-frontend+0xe2880a)
#33 0x00005a9a02b44797 swift::CompilerInstance::performSema() (/usr/bin/swift-frontend+0xe28797)
#34 0x00005a9a0288a53a performCompile(swift::CompilerInstance&, int&, swift::FrontendObserver*) FrontendTool.cpp:0:0
#35 0x00005a9a02889ae4 swift::performFrontend(llvm::ArrayRef<char const*>, char const*, void*, swift::FrontendObserver*) (/usr/bin/swift-frontend+0xb6dae4)
#36 0x00005a9a026411f9 swift::mainEntry(int, char const**) (/usr/bin/swift-frontend+0x9251f9)
#37 0x000070194b2ee1ca (/lib/x86_64-linux-gnu/libc.so.6+0x2a1ca)
#38 0x000070194b2ee28b __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28b)
#39 0x00005a9a02640345 _start (/usr/bin/swift-frontend+0x924345)
```

### Expected behavior

should not crash anyway

### Environment

docker run --rm -v "$PWD":/work -w /work swift:latest bash -lc 'swiftc -c test.swift -o /dev/null'

### Additional information

_No response_
