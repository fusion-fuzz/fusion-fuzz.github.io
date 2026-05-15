# [swiftc crash `swift::ast_scope::NodeAdder::visitBraceStmt`](https://github.com/swiftlang/swift/issues/84901)

### Description

_No response_

### Reproduction

```swift
protocol a : b where c == d<e> protocol f : g protocol g {
  associatedtype 2 : a
}
struct d < e extension d
    : f protocol h{associatedtype e associatedtype c : g} protocol b : h

let __fusion_0 = 2

@a({ struct b }
                        var c
```


### Stack dump

```text
Please submit a bug report (https://swift.org/contributing/#reporting-bugs) and include the crash backtrace.
Stack dump:
0.	Program arguments: /usr/bin/swift-frontend -frontend -c -primary-file min.swift -target x86_64-unknown-linux-gnu -disable-objc-interop -color-diagnostics -Xcc -fcolor-diagnostics -empty-abi-descriptor -no-auto-bridging-header-chaining -module-name min -in-process-plugin-server-path /usr/lib/swift/host/libSwiftInProcPluginServer.so -plugin-path /usr/lib/swift/host/plugins -plugin-path /usr/local/lib/swift/host/plugins -o /tmp/TemporaryDirectory.Z3CtwV/min-1.o
1.	Swift version 6.2 (swift-6.2-RELEASE)
2.	Compiling with effective version 5.10
3.	While evaluating request ExtendedNominalRequest(extension of d@min.swift:4:14, 1)
 #0 0x00005cd39d49d598 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/bin/swift-frontend+0x7316598)
 #1 0x00005cd39d49b36e llvm::sys::RunSignalHandlers() (/usr/bin/swift-frontend+0x731436e)
 #2 0x00005cd39d49dc31 SignalHandler(int, siginfo_t*, void*) Signals.cpp:0:0
 #3 0x000070e784c51330 (/lib/x86_64-linux-gnu/libc.so.6+0x45330)
 #4 0x00005cd39862a717 swift::DeclContext::getASTContext() const (/usr/bin/swift-frontend+0x24a3717)
 #5 0x00005cd3985702e9 swift::abi_role_detail::computeStorage(swift::Decl*) (/usr/bin/swift-frontend+0x23e92e9)
 #6 0x00005cd3984de162 swift::ast_scope::NodeAdder::visitBraceStmt(swift::BraceStmt*, swift::ast_scope::ASTScopeImpl*, swift::ast_scope::ScopeCreator&) crtstuff.c:0:0
 #7 0x00005cd3984db578 swift::ast_scope::ClosureParametersScope::expandSpecifically(swift::ast_scope::ScopeCreator&) (/usr/bin/swift-frontend+0x2354578)
 #8 0x00005cd3984dd569 swift::ast_scope::ScopeCreator::addExprToScopeTree(swift::Expr*, swift::ast_scope::ASTScopeImpl*)::NestedExprScopeFinder::walkToExprPre(swift::Expr*) crtstuff.c:0:0
 #9 0x00005cd3984f763a swift::Expr::walk(swift::ASTWalker&) (/usr/bin/swift-frontend+0x237063a)
#10 0x00005cd3984d97e2 swift::ASTVisitor<swift::ast_scope::NodeAdder, swift::ast_scope::ASTScopeImpl*, swift::ast_scope::ASTScopeImpl*, swift::ast_scope::ASTScopeImpl*, void, void, void, swift::ast_scope::ASTScopeImpl*, swift::ast_scope::ScopeCreator&>::visit(swift::Expr*, swift::ast_scope::ASTScopeImpl*, swift::ast_scope::ScopeCreator&) crtstuff.c:0:0
#11 0x00005cd3984dad86 swift::ast_scope::CustomAttributeScope::expandSpecifically(swift::ast_scope::ScopeCreator&) (/usr/bin/swift-frontend+0x2353d86)
#12 0x00005cd3984d9f7d swift::ast_scope::ScopeCreator::addChildrenForKnownAttributes(swift::Decl*, swift::ast_scope::ASTScopeImpl*) (/usr/bin/swift-frontend+0x2352f7d)
#13 0x00005cd3984da1db swift::ast_scope::ScopeCreator::addPatternBindingToScopeTree(swift::PatternBindingDecl*, swift::ast_scope::ASTScopeImpl*, std::optional<swift::SourceLoc>) (/usr/bin/swift-frontend+0x23531db)
#14 0x00005cd3984da891 swift::ast_scope::BraceStmtScope::expandAScopeThatCreatesANewInsertionPoint(swift::ast_scope::ScopeCreator&) (/usr/bin/swift-frontend+0x2353891)
#15 0x00005cd3984de4d5 swift::ast_scope::NodeAdder::visitBraceStmt(swift::BraceStmt*, swift::ast_scope::ASTScopeImpl*, swift::ast_scope::ScopeCreator&) crtstuff.c:0:0
#16 0x00005cd3984da907 swift::ast_scope::TopLevelCodeScope::expandSpecifically(swift::ast_scope::ScopeCreator&) (/usr/bin/swift-frontend+0x2353907)
#17 0x00005cd3984da4dd swift::ast_scope::ASTSourceFileScope::expandAScopeThatCreatesANewInsertionPoint(swift::ast_scope::ScopeCreator&) (/usr/bin/swift-frontend+0x23534dd)
#18 0x00005cd3984dfbcb swift::ast_scope::ASTScopeImpl::lookupEnclosingMacroScope(swift::SourceFile*, swift::SourceLoc, llvm::function_ref<bool (llvm::PointerUnion<swift::FreestandingMacroExpansion*, swift::CustomAttr*>)>) (/usr/bin/swift-frontend+0x2358bcb)
#19 0x00005cd3987089ad directReferencesForUnqualifiedTypeLookup(swift::DeclNameRef, swift::SourceLoc, swift::DeclContext*, (anonymous namespace)::LookupOuterResults, swift::optionset::OptionSet<DirectlyReferencedTypeLookupFlags, unsigned int>) NameLookup.cpp:0:0
#20 0x00005cd3986fe554 directReferencesForTypeRepr(swift::Evaluator&, swift::ASTContext&, swift::TypeRepr*, swift::DeclContext*, swift::optionset::OptionSet<DirectlyReferencedTypeLookupFlags, unsigned int>) NameLookup.cpp:0:0
#21 0x00005cd398707482 swift::ExtendedNominalRequest::evaluate(swift::Evaluator&, swift::ExtensionDecl*, bool) const (/usr/bin/swift-frontend+0x2580482)
#22 0x00005cd398596c7b swift::ExtendedNominalRequest::OutputType swift::Evaluator::getResultUncached<swift::ExtendedNominalRequest, swift::ExtendedNominalRequest::OutputType swift::evaluateOrDefault<swift::ExtendedNominalRequest>(swift::Evaluator&, swift::ExtendedNominalRequest, swift::ExtendedNominalRequest::OutputType)::'lambda'()>(swift::ExtendedNominalRequest const&, swift::ExtendedNominalRequest::OutputType swift::evaluateOrDefault<swift::ExtendedNominalRequest>(swift::Evaluator&, swift::ExtendedNominalRequest, swift::ExtendedNominalRequest::OutputType)::'lambda'()) crtstuff.c:0:0
#23 0x00005cd398596b86 swift::ExtendedNominalRequest::OutputType swift::Evaluator::getResultCached<swift::ExtendedNominalRequest, swift::ExtendedNominalRequest::OutputType swift::evaluateOrDefault<swift::ExtendedNominalRequest>(swift::Evaluator&, swift::ExtendedNominalRequest, swift::ExtendedNominalRequest::OutputType)::'lambda'(), (void*)0>(swift::ExtendedNominalRequest const&, swift::ExtendedNominalRequest::OutputType swift::evaluateOrDefault<swift::ExtendedNominalRequest>(swift::Evaluator&, swift::ExtendedNominalRequest, swift::ExtendedNominalRequest::OutputType)::'lambda'()) crtstuff.c:0:0
#24 0x00005cd398567fbe swift::ExtensionDecl::computeExtendedNominal(bool) const (/usr/bin/swift-frontend+0x23e0fbe)
#25 0x00005cd39812d508 swift::bindExtensions(swift::ModuleDecl&) (/usr/bin/swift-frontend+0x1fa6508)
#26 0x00005cd396faf6ee swift::CompilerInstance::performParseAndResolveImportsOnly() (/usr/bin/swift-frontend+0xe286ee)
#27 0x00005cd396faf75f swift::CompilerInstance::performSema() (/usr/bin/swift-frontend+0xe2875f)
#28 0x00005cd396cf553a performCompile(swift::CompilerInstance&, int&, swift::FrontendObserver*) FrontendTool.cpp:0:0
#29 0x00005cd396cf4ae4 swift::performFrontend(llvm::ArrayRef<char const*>, char const*, void*, swift::FrontendObserver*) (/usr/bin/swift-frontend+0xb6dae4)
#30 0x00005cd396aac1f9 swift::mainEntry(int, char const**) (/usr/bin/swift-frontend+0x9251f9)
#31 0x000070e784c361ca (/lib/x86_64-linux-gnu/libc.so.6+0x2a1ca)
#32 0x000070e784c3628b __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28b)
#33 0x00005cd396aab345 _start (/usr/bin/swift-frontend+0x924345)

*** Signal 11: Backtracing from 0x70e784caab2c... done ***

*** Program crashed: Bad pointer dereference at 0x000000000036b33f ***

Platform: x86_64 Linux (Ubuntu 24.04.3 LTS)

Thread 0 "swift-frontend" crashed:

  0      0x000070e784caab2c <unknown> in libc.so.6
  1 [ra] 0x000070e784c5127e <unknown> in libc.so.6
...


Registers:

rax 0x0000000000000000  0
rdx 0x000000000036b33f  3584831
rcx 0x000070e784caab2c  41 89 c6 41 f7 de 3d 00 f0 ff ff b8 00 00 00 00  A·ÆA÷Þ=·ðÿÿ¸····
rbx 0x000000000000000b  11
rsi 0x000000000036b33f  3584831
rdi 0x000000000036b33f  3584831
rbp 0x00005cd3b37c0b40  60 0b 7c b3 d3 5c 00 00 7e 12 c5 84 e7 70 00 00  `·|³Ó\··~·Å·çp··
rsp 0x00005cd3b37c0b00  00 00 00 00 00 00 00 00 00 61 b1 ee ca b1 9f 70  ·········a±îÊ±·p
 r8 0x00005cd3b3753010  03 00 06 00 04 00 03 00 05 00 04 00 04 00 05 00  ················
 r9 0x0000000000000007  7
r10 0x000070e784c22750  d4 01 00 00 12 00 11 00 60 52 04 00 00 00 00 00  Ô·······`R······
r11 0x0000000000000246  582
r12 0x000000000000000b  11
r13 0x0000000000000000  0
r14 0x0000000000000016  22
r15 0x00005cd3b37c0c08  ff ff ff 7f fe ff ff ff 00 00 00 00 00 00 00 00  ÿÿÿ·þÿÿÿ········
rip 0x000070e784caab2c  41 89 c6 41 f7 de 3d 00 f0 ff ff b8 00 00 00 00  A·ÆA÷Þ=·ðÿÿ¸····

rflags 0x0000000000000246  ZF PF

cs 0x0033  fs 0x0000  gs 0x0000
```

### Expected behavior

should not crash anyway

### Environment

docker run --rm -v "$PWD":/work -w /work swift:latest bash -lc 'swiftc -c test.swift -o /dev/null'

### Additional information

_No response_
