---
render_with_liquid: false
---

# [Crash: swift-frontend crash in ConstraintSystem::getConstraintLocator (via FoldingSetBase::FindNodeOrInsertPos) when type-checking OptionalTryExpr](https://github.com/swiftlang/swift/issues/86438)

### Description

The Swift compiler crashes with a bad pointer dereference (SIGSEGV) in llvm::FoldingSetBase::FindNodeOrInsertPos. The crash occurs during the constraint generation phase, specifically within ConstraintSystem::addUnresolvedValueMemberConstraint and ConstraintSystem::simplifyMemberConstraint, while the type checker is processing an OptionalTryExpr (try?) inside a top-level guard statement. The minimized reproduction involves circular variable dependencies and potential undefined types (XPath) in top-level code.

### Reproduction

```swift
var test = result
let htmlContent = "<a href=\"https://PHP.net\">hello</a>"
guard let doc = try? HTMLDocument(string: htmlContent) else { fatalError("Failed to create document") }
let xpath = XPath(doc)
var result = xpath.query("//a[foo:strtolower(string(@href)) = 'https://php.net']")
class HTMLDocument {
    init(string: String) {}
}
```


### Stack dump

```text
Please submit a bug report (https://swift.org/contributing/#reporting-bugs) and include the crash backtrace.
Stack dump:
0.	Program arguments: /usr/bin/swift-frontend -frontend -emit-silgen -primary-file minimized.swift -target x86_64-unknown-linux-gnu -disable-objc-interop -color-diagnostics -Xcc -fcolor-diagnostics -Osize -strict-concurrency=complete -empty-abi-descriptor -no-auto-bridging-header-chaining -module-name minimized -sil-verify-all -in-process-plugin-server-path /usr/lib/swift/host/libSwiftInProcPluginServer.so -plugin-path /usr/lib/swift/host/plugins -plugin-path /usr/local/lib/swift/host/plugins -enable-default-cmo -o -
1.	Swift version 6.2.3 (swift-6.2.3-RELEASE)
2.	Compiling with effective version 5.10
3.	While evaluating request TypeCheckPrimaryFileRequest(source_file "minimized.swift")
4.	While type-checking statement at [minimized.swift:3:1 - line:3:103] RangeText="guard let doc = try? HTMLDocument(string: htmlContent) else { fatalError("Failed to create document") "
5.	While type-checking statement at [minimized.swift:3:1 - line:3:103] RangeText="guard let doc = try? HTMLDocument(string: htmlContent) else { fatalError("Failed to create document") "
6.	While type-checking expression at [minimized.swift:3:17 - line:3:54] RangeText="try? HTMLDocument(string: htmlContent"
7.	While type-checking-target starting at minimized.swift:3:22
 #0 0x00005d8380a8ec58 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/bin/swift-frontend+0x731ec58)
 #1 0x00005d8380a8ca2e llvm::sys::RunSignalHandlers() (/usr/bin/swift-frontend+0x731ca2e)
 #2 0x00005d8380a8f2f1 SignalHandler(int, siginfo_t*, void*) Signals.cpp:0:0
 #3 0x000070c48a7d4330 (/lib/x86_64-linux-gnu/libc.so.6+0x45330)
 #4 0x00005d83809f0043 llvm::FoldingSetBase::FindNodeOrInsertPos(llvm::FoldingSetNodeID const&, void*&, llvm::FoldingSetBase::FoldingSetInfo const&) (/usr/bin/swift-frontend+0x7280043)
 #5 0x00005d837b510d81 swift::constraints::ConstraintSystem::getConstraintLocator(swift::ASTNode, llvm::ArrayRef<swift::constraints::ConstraintLocator::PathElement>, unsigned int) (/usr/bin/swift-frontend+0x1da0d81)
 #6 0x00005d837b51070f swift::constraints::ConstraintSystem::getConstraintLocator(swift::constraints::ConstraintLocatorBuilder const&) (/usr/bin/swift-frontend+0x1da070f)
 #7 0x00005d837b45ce36 swift::constraints::ConstraintSystem::simplifyMemberConstraint(swift::constraints::ConstraintKind, swift::Type, swift::DeclNameRef, swift::Type, swift::DeclContext*, swift::FunctionRefInfo, llvm::ArrayRef<swift::constraints::OverloadChoice>, swift::optionset::OptionSet<swift::constraints::ConstraintSystem::TypeMatchFlags, unsigned int>, swift::constraints::ConstraintLocatorBuilder) (/usr/bin/swift-frontend+0x1cece36)
 #8 0x00005d837b4355d9 swift::constraints::ConstraintSystem::addUnresolvedValueMemberConstraint(swift::Type, swift::DeclNameRef, swift::Type, swift::DeclContext*, swift::FunctionRefInfo, swift::constraints::ConstraintLocatorBuilder) crtstuff.c:0:0
 #9 0x00005d837b423ec2 (anonymous namespace)::ConstraintWalker::walkToExprPost(swift::Expr*) CSGen.cpp:0:0
#10 0x00005d837bae8626 (anonymous namespace)::Traversal::visitOptionalTryExpr(swift::OptionalTryExpr*) ASTWalker.cpp:0:0
#11 0x00005d837bae75d0 (anonymous namespace)::Traversal::visit(swift::Expr*) ASTWalker.cpp:0:0
#12 0x00005d837bae6bb0 swift::Expr::walk(swift::ASTWalker&) (/usr/bin/swift-frontend+0x2376bb0)
#13 0x00005d837b41f09d swift::constraints::ConstraintSystem::generateConstraints(swift::Expr*, swift::DeclContext*) (/usr/bin/swift-frontend+0x1caf09d)
#14 0x00005d837b41d042 swift::constraints::ConstraintSystem::generateConstraints(swift::constraints::SyntacticElementTarget&, swift::FreeTypeVariableBinding) (/usr/bin/swift-frontend+0x1cad042)
#15 0x00005d837b487574 swift::constraints::ConstraintSystem::solveImpl(swift::constraints::SyntacticElementTarget&, swift::FreeTypeVariableBinding) (/usr/bin/swift-frontend+0x1d17574)
#16 0x00005d837b48702c swift::constraints::ConstraintSystem::solve(swift::constraints::SyntacticElementTarget&, swift::FreeTypeVariableBinding) (/usr/bin/swift-frontend+0x1d1702c)
#17 0x00005d837b5f99f9 swift::TypeChecker::typeCheckTarget(swift::constraints::SyntacticElementTarget&, swift::optionset::OptionSet<swift::TypeCheckExprFlags, unsigned int>, swift::DiagnosticTransaction*) (/usr/bin/swift-frontend+0x1e899f9)
#18 0x00005d837b5f985d swift::TypeChecker::typeCheckExpression(swift::constraints::SyntacticElementTarget&, swift::optionset::OptionSet<swift::TypeCheckExprFlags, unsigned int>, swift::DiagnosticTransaction*) (/usr/bin/swift-frontend+0x1e8985d)
#19 0x00005d837b5fab16 swift::TypeChecker::typeCheckBinding(swift::Pattern*&, swift::Expr*&, swift::DeclContext*, swift::Type, swift::PatternBindingDecl*, unsigned int, swift::optionset::OptionSet<swift::TypeCheckExprFlags, unsigned int>) (/usr/bin/swift-frontend+0x1e8ab16)
#20 0x00005d837b6d7aba swift::TypeChecker::typeCheckStmtConditionElement(swift::StmtConditionElement&, bool&, swift::DeclContext*) (/usr/bin/swift-frontend+0x1f67aba)
#21 0x00005d837b6dd39e typeCheckConditionForStatement(swift::LabeledConditionalStmt*, swift::DeclContext*) TypeCheckStmt.cpp:0:0
#22 0x00005d837b6dc08c swift::ASTVisitor<(anonymous namespace)::StmtChecker, void, swift::Stmt*, void, void, void, void>::visit(swift::Stmt*) TypeCheckStmt.cpp:0:0
#23 0x00005d837b6dbcdc bool (anonymous namespace)::StmtChecker::typeCheckStmt<swift::Stmt>(swift::Stmt*&) TypeCheckStmt.cpp:0:0
#24 0x00005d837b6d8c4f (anonymous namespace)::StmtChecker::typeCheckASTNode(swift::ASTNode&) TypeCheckStmt.cpp:0:0
#25 0x00005d837b6dbe0d swift::ASTVisitor<(anonymous namespace)::StmtChecker, void, swift::Stmt*, void, void, void, void>::visit(swift::Stmt*) TypeCheckStmt.cpp:0:0
#26 0x00005d837b6da39c bool (anonymous namespace)::StmtChecker::typeCheckStmt<swift::BraceStmt>(swift::BraceStmt*&) TypeCheckStmt.cpp:0:0
#27 0x00005d837b6da413 swift::TypeChecker::typeCheckTopLevelCodeDecl(swift::TopLevelCodeDecl*) (/usr/bin/swift-frontend+0x1f6a413)
#28 0x00005d837b71a661 swift::TypeCheckPrimaryFileRequest::evaluate(swift::Evaluator&, swift::SourceFile*) const (/usr/bin/swift-frontend+0x1faa661)
#29 0x00005d837b71c1ce swift::TypeCheckPrimaryFileRequest::OutputType swift::Evaluator::getResultUncached<swift::TypeCheckPrimaryFileRequest, swift::TypeCheckPrimaryFileRequest::OutputType swift::evaluateOrDefault<swift::TypeCheckPrimaryFileRequest>(swift::Evaluator&, swift::TypeCheckPrimaryFileRequest, swift::TypeCheckPrimaryFileRequest::OutputType)::'lambda'()>(swift::TypeCheckPrimaryFileRequest const&, swift::TypeCheckPrimaryFileRequest::OutputType swift::evaluateOrDefault<swift::TypeCheckPrimaryFileRequest>(swift::Evaluator&, swift::TypeCheckPrimaryFileRequest, swift::TypeCheckPrimaryFileRequest::OutputType)::'lambda'()) crtstuff.c:0:0
#30 0x00005d837b71a585 swift::performTypeChecking(swift::SourceFile&) (/usr/bin/swift-frontend+0x1faa585)
#31 0x00005d837a5aa819 bool llvm::function_ref<bool (swift::SourceFile&)>::callback_fn<swift::CompilerInstance::performSema()::$_8>(long, swift::SourceFile&) Frontend.cpp:0:0
#32 0x00005d837a59fd7a swift::CompilerInstance::forEachFileToTypeCheck(llvm::function_ref<bool (swift::SourceFile&)>) (/usr/bin/swift-frontend+0xe2fd7a)
#33 0x00005d837a59fd07 swift::CompilerInstance::performSema() (/usr/bin/swift-frontend+0xe2fd07)
#34 0x00005d837a2e519a performCompile(swift::CompilerInstance&, int&, swift::FrontendObserver*) FrontendTool.cpp:0:0
#35 0x00005d837a2e4744 swift::performFrontend(llvm::ArrayRef<char const*>, char const*, void*, swift::FrontendObserver*) (/usr/bin/swift-frontend+0xb74744)
#36 0x00005d837a096029 swift::mainEntry(int, char const**) (/usr/bin/swift-frontend+0x926029)
#37 0x000070c48a7b91ca (/lib/x86_64-linux-gnu/libc.so.6+0x2a1ca)
#38 0x000070c48a7b928b __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28b)
#39 0x00005d837a095175 _start (/usr/bin/swift-frontend+0x925175)

💣 Program crashed: Bad pointer dereference at 0x0000000000091330

Platform: x86_64 Linux (Ubuntu 24.04.3 LTS)

Thread 0 "swift-frontend" crashed:

  0 0x000070c48a82db2c <unknown> in libc.so.6
  1 0x000070c48a7d427e <unknown> in libc.so.6
... 

Backtrace took 0.00s
```

### Expected behavior

should not crash

### Environment

Swift version 6.2.3 (swift-6.2.3-RELEASE)

### Additional information

_No response_
