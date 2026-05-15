---
render_with_liquid: false
---

*Fusion-Fuzz Bug Report*

**ID:** `f1b72f43` &nbsp;·&nbsp; **Signature:** `Assertion failed: (Context.SourceMgr.hasIDEInspectionTargetBuffer() || Context.LangOpts.IsForSourceKit || Context.TypeCheckerOpts.EnableLazyTypecheck || inSecondaryScriptFile() && "Querying VarDecl's type before type-checking parent stmt"), function evaluate at TypeCheckDecl.cpp:2766.` &nbsp;·&nbsp; **RC:** `134`

The following code:

```swift


// --- Seed A ---
func myPrintR(_ dict: [String: Any]) {
    let sortedDict = dict.sorted(by: { $0.key < $1.key })
    for (key, value) in sortedDict {
        print("\(key): \(value)")
    }
}

func f1() {
    let c = 1
    print("Extracted:")
    myPrintR(["": c])
    myPrintR(["c": c])
}

func f2() {
    let a = 1
    let c = 1
    print("Extracted:")
    myPrintR(["a": c])
    myPrintR(["c": c, "a": a])
}

func f3() {
    let a = 1
    let c = 1
    print("Extracted:")
    myPrintR(["a": c])
    myPrintR(["c": c, "prefix_a": a])
}

func f4() {
    let c = 1
    print("Extracted:")
    myPrintR(["": c])
    myPrintR(["c": c])
}

func f5() {
    let c = 1
    print("Extracted:")
    myPrintR(["111": c])
    myPrintR(["c": c])
}

f1()
f2()
f3()
f4()
f5()

// --- Fusion Bridge ---
var fusion_0e59 = c

// --- Seed B ---
// RUN: %target-typecheck-verify-swift

let a: Int? = fusion_0e59
guard let b = a else {
}

func foo() {} // to interrupt the TopLevelCodeDecl

let c = b
// --- Bug Primitive ---

// P4: Closure capture / @escaping / ownership stress
func _ffl_p4_apply<T>(_ f: () -> T) -> T { f() }
func _ffl_p4_escape<T>(_ f: @escaping () -> T) -> () -> T { f }
do {
    var _ffl_cap = fusion_0e59
    // noescape: bridge captured by reference on the stack
    let _ffl_local = _ffl_p4_apply { _ffl_cap }
    // @escaping: bridge promoted to heap box
    let _ffl_esc   = _ffl_p4_escape { _ffl_cap }
    // nested closure capturing both outer and inner captures
    let _ffl_nest: () -> String = {
        let inner = _ffl_esc()
        return "\(inner) \(_ffl_local)"
    }
    _ = _ffl_nest()
    // mutation after escape — probes copy-on-write / exclusive-access
    _ffl_cap = fusion_0e59
    _ = _ffl_esc()
}


```

Resulted in this output:

```
Assertion failed: (Context.SourceMgr.hasIDEInspectionTargetBuffer() || Context.LangOpts.IsForSourceKit || Context.TypeCheckerOpts.EnableLazyTypecheck || inSecondaryScriptFile() && "Querying VarDecl's type before type-checking parent stmt"), function evaluate at TypeCheckDecl.cpp:2766.
(to display assertion configuration options: -Xllvm -assert-help)

Please submit a bug report (https://swift.org/contributing/#reporting-bugs) and include the crash backtrace.
Stack dump:
0.	Program arguments: /usr/bin/swift-frontend -emit-sil -wmo -sil-verify-all /home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpk5la4wyv/f1b72f43.swift
1.	Swift version 6.4-dev (LLVM d2079213f1d4451, Swift 82b7720768ba875)
2.	Compiling with effective version 5.10
3.	While evaluating request TypeCheckPrimaryFileRequest(source_file "/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpk5la4wyv/f1b72f43.swift")
4.	While type-checking statement at [/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpk5la4wyv/f1b72f43.swift:55:1 - line:55:19] RangeText="var fusion_0e59 = "
5.	While type-checking declaration 0x56f908c08b60 (at /home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpk5la4wyv/f1b72f43.swift:55:1)
6.	While evaluating request PatternBindingEntryRequest((unknown decl)@/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpk5la4wyv/f1b72f43.swift:55:1, 0)
7.	While type-checking expression at [/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpk5la4wyv/f1b72f43.swift:55:19 - line:55:19] RangeText=""
8.	While type-checking-target starting at /home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpk5la4wyv/f1b72f43.swift:55:19
9.	While evaluating request InterfaceTypeRequest(f1b72f43.(file).c@/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpk5la4wyv/f1b72f43.swift:66:5)
10.	While evaluating request NamingPatternRequest(f1b72f43.(file).c@/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpk5la4wyv/f1b72f43.swift:66:5)
11.	While evaluating request PatternBindingEntryRequest((unknown decl)@/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpk5la4wyv/f1b72f43.swift:66:1, 0)
12.	While type-checking expression at [/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpk5la4wyv/f1b72f43.swift:66:9 - line:66:9] RangeText=""
13.	While type-checking-target starting at /home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpk5la4wyv/f1b72f43.swift:66:9
14.	While evaluating request InterfaceTypeRequest(f1b72f43.(file).top-level code.b@/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpk5la4wyv/f1b72f43.swift:61:11)
15.	While evaluating request NamingPatternRequest(f1b72f43.(file).top-level code.b@/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpk5la4wyv/f1b72f43.swift:61:11)
16.	Assertion failed: (Context.SourceMgr.hasIDEInspectionTargetBuffer() || Context.LangOpts.IsForSourceKit || Context.TypeCheckerOpts.EnableLazyTypecheck || inSecondaryScriptFile() && "Querying VarDecl's type before type-checking parent stmt"), function evaluate at TypeCheckDecl.cpp:2766.
| 	(to display assertion configuration options: -Xllvm -assert-help)
 #0 0x000056f901797c98 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/bin/swift-frontend+0x8bb8c98)
 #1 0x000056f9017954b5 llvm::sys::RunSignalHandlers() (/usr/bin/swift-frontend+0x8bb64b5)
 #2 0x000056f901798a51 SignalHandler(int, siginfo_t*, void*) Signals.cpp:0:0
 #3 0x00007192c7a05330 (/lib/x86_64-linux-gnu/libc.so.6+0x45330)
 #4 0x00007192c7a5eb2c pthread_kill (/lib/x86_64-linux-gnu/libc.so.6+0x9eb2c)
 #5 0x00007192c7a0527e raise (/lib/x86_64-linux-gnu/libc.so.6+0x4527e)
 #6 0x00007192c79e88ff abort (/lib/x86_64-linux-gnu/libc.so.6+0x288ff)
 #7 0x000056f8fb8ba392 (/usr/bin/swift-frontend+0x2cdb392)
 #8 0x000056f8fb8ba344 (/usr/bin/swift-frontend+0x2cdb344)
 #9 0x000056f8fad6110f swift::NamingPatternRequest::evaluate(swift::Evaluator&, swift::VarDecl*) const (/usr/bin/swift-frontend+0x218210f)
#10 0x000056f8fb50d13f swift::NamingPatternRequest::OutputType swift::Evaluator::getResultUncached<swift::NamingPatternRequest, swift::NamingPatternRequest::OutputType swift::evaluateOrDefault<swift::NamingPatternRequest>(swift::Evaluator&, swift::NamingPatternRequest, swift::NamingPatternRequest::OutputType)::'lambda'()>(swift::NamingPatternRequest const&, swift::NamingPatternRequest::OutputType swift::evaluateOrDefault<swift::NamingPatternRequest>(swift::Evaluator&, swift::NamingPatternRequest, swift::NamingPatternRequest::OutputType)::'lambda'()) crtstuff.c:0:0
#11 0x000056f8fb473009 swift::VarDecl::getNamingPattern() const (/usr/bin/swift-frontend+0x2894009)
#12 0x000056f8fad5f4ef swift::InterfaceTypeRequest::evaluate(swift::Evaluator&, swift::ValueDecl*) const (/usr/bin/swift-frontend+0x21804ef)
#13 0x000056f8fb453c05 swift::ValueDecl::getInterfaceType() const (/usr/bin/swift-frontend+0x2874c05)
#14 0x000056f8fb472931 swift::VarDecl::getTypeInContext() const (/usr/bin/swift-frontend+0x2893931)
#15 0x000056f8fab233c2 (anonymous namespace)::ConstraintWalker::walkToExprPost(swift::Expr*) CSGen.cpp:0:0
#16 0x000056f8fb3c88a6 (anonymous namespace)::Traversal::doIt(swift::Expr*) ASTWalker.cpp:0:0
#17 0x000056f8fb3c87b3 swift::Expr::walk(swift::ASTWalker&) (/usr/bin/swift-frontend+0x27e97b3)
#18 0x000056f8fab1755e swift::constraints::ConstraintSystem::generateConstraints(swift::Expr*, swift::DeclContext*) (/usr/bin/swift-frontend+0x1f3855e)
#19 0x000056f8fab1602b swift::constraints::ConstraintSystem::generateConstraints(swift::constraints::SyntacticElementTarget&, swift::FreeTypeVariableBinding) (/usr/bin/swift-frontend+0x1f3702b)
#20 0x000056f8fab8a980 swift::constraints::ConstraintSystem::solveImpl(swift::constraints::SyntacticElementTarget&, swift::FreeTypeVariableBinding) (/usr/bin/swift-frontend+0x1fab980)
#21 0x000056f8fab8a296 swift::constraints::ConstraintSystem::solve(swift::constraints::SyntacticElementTarget&, swift::FreeTypeVariableBinding) (/usr/bin/swift-frontend+0x1fab296)
#22 0x000056f8fad4ad65 swift::TypeChecker::typeCheckTarget(swift::constraints::SyntacticElementTarget&, swift::optionset::OptionSet<swift::TypeCheckExprFlags, unsigned int>, swift::DiagnosticTransaction*) (/usr/bin/swift-frontend+0x216bd65)
#23 0x000056f8fad4abe1 swift::TypeChecker::typeCheckExpression(swift::constraints::SyntacticElementTarget&, swift::optionset::OptionSet<swift::TypeCheckExprFlags, unsigned int>, swift::DiagnosticTransaction*) (/usr/bin/swift-frontend+0x216bbe1)
#24 0x000056f8fad4cad5 swift::TypeChecker::typeCheckBinding(swift::Pattern*&, swift::Expr*&, swift::DeclContext*, swift::Type, swift::PatternBindingDecl*, unsigned int, swift::optionset::OptionSet<swift::TypeCheckExprFlags, unsigned int>) (/usr/bin/swift-frontend+0x216dad5)
#25 0x000056f8fad4cdca swift::TypeChecker::typeCheckPatternBinding(swift::PatternBindingDecl*, unsigned int, swift::Type, swift::optionset::OptionSet<swift::TypeCheckExprFlags, unsigned int>) (/usr/bin/swift-frontend+0x216ddca)
#26 0x000056f8fae629d2 swift::PatternBindingEntryRequest::evaluate(swift::Evaluator&, swift::PatternBindingDecl*, unsigned int) const (/usr/bin/swift-frontend+0x22839d2)
#27 0x000056f8fb49f020 swift::PatternBindingEntryRequest::OutputType swift::Evaluator::getResultUncached<swift::PatternBindingEntryRequest, swift::PatternBindingEntryRequest::OutputType swift::evaluateOrDefault<swift::PatternBindingEntryRequest>(swift::Evaluator&, swift::PatternBindingEntryRequest, swift::PatternBindingEntryRequest::OutputType)::'lambda'()>(swift::PatternBindingEntryRequest const&, swift::PatternBindingEntryRequest::OutputType swift::evaluateOrDefault<swift::PatternBindingEntryRequest>(swift::Evaluator&, swift::PatternBindingEntryRequest, swift::PatternBindingEntryRequest::OutputType)::'lambda'()) crtstuff.c:0:0
#28 0x000056f8fb45c4c0 swift::PatternBindingDecl::getCheckedPatternBindingEntry(unsigned int) const (/usr/bin/swift-frontend+0x287d4c0)
#29 0x000056f8fad60dea swift::NamingPatternRequest::evaluate(swift::Evaluator&, swift::VarDecl*) const (/usr/bin/swift-frontend+0x2181dea)
#30 0x000056f8fb50d13f swift::NamingPatternRequest::OutputType swift::Evaluator::getResultUncached<swift::NamingPatternRequest, swift::NamingPatternRequest::OutputType swift::evaluateOrDefault<swift::NamingPatternRequest>(swift::Evaluator&, swift::NamingPatternRequest, swift::NamingPatternRequest::OutputType)::'lambda'()>(swift::NamingPatternRequest const&, swift::NamingPatternRequest::OutputType swift::evaluateOrDefault<swift::NamingPatternRequest>(swift::Evaluator&, swift::NamingPatternRequest, swift::NamingPatternRequest::OutputType)::'lambda'()) crtstuff.c:0:0
#31 0x000056f8fb473009 swift::VarDecl::getNamingPattern() const (/usr/bin/swift-frontend+0x2894009)
#32 0x000056f8fad5f4ef swift::InterfaceTypeRequest::evaluate(swift::Evaluator&, swift::ValueDecl*) const (/usr/bin/swift-frontend+0x21804ef)
#33 0x000056f8fb453c05 swift::ValueDecl::getInterfaceType() const (/usr/bin/swift-frontend+0x2874c05)
#34 0x000056f8fb472931 swift::VarDecl::getTypeInContext() const (/usr/bin/swift-frontend+0x2893931)
#35 0x000056f8fab233c2 (anonymous namespace)::ConstraintWalker::walkToExprPost(swift::Expr*) CSGen.cpp:0:0
#36 0x000056f8fb3c88a6 (anonymous namespace)::Traversal::doIt(swift::Expr*) ASTWalker.cpp:0:0
#37 0x000056f8fb3c87b3 swift::Expr::walk(swift::ASTWalker&) (/usr/bin/swift-frontend+0x27e97b3)
#38 0x000056f8fab1755e swift::constraints::ConstraintSystem::generateConstraints(swift::Expr*, swift::DeclContext*) (/usr/bin/swift-frontend+0x1f3855e)
#39 0x000056f8fab1602b swift::constraints::ConstraintSystem::generateConstraints(swift::constraints::SyntacticElementTarget&, swift::FreeTypeVariableBinding) (/usr/bin/swift-frontend+0x1f3702b)
#40 0x000056f8fab8a980 swift::constraints::ConstraintSystem::solveImpl(swift::constraints::SyntacticElementTarget&, swift::FreeTypeVariableBinding) (/usr/bin/swift-frontend+0x1fab980)
#41 0x000056f8fab8a296 swift::constraints::ConstraintSystem::solve(swift::constraints::SyntacticElementTarget&, swift::FreeTypeVariableBinding) (/usr/bin/swift-frontend+0x1fab296)
#42 0x000056f8fad4ad65 swift::TypeChecker::typeCheckTarget(swift::constraints::SyntacticElementTarget&, swift::optionset::OptionSet<swift::TypeCheckExprFlags, unsigned int>, swift::DiagnosticTransaction*) (/usr/bin/swift-frontend+0x216bd65)
#43 0x000056f8fad4abe1 swift::TypeChecker::typeCheckExpression(swift::constraints::SyntacticElementTarget&, swift::optionset::OptionSet<swift::TypeCheckExprFlags, unsigned int>, swift::DiagnosticTransaction*) (/usr/bin/swift-frontend+0x216bbe1)
#44 0x000056f8fad4cad5 swift::TypeChecker::typeCheckBinding(swift::Pattern*&, swift::Expr*&, swift::DeclContext*, swift::Type, swift::PatternBindingDecl*, unsigned int, swift::optionset::OptionSet<swift::TypeCheckExprFlags, unsigned int>) (/usr/bin/swift-frontend+0x216dad5)
#45 0x000056f8fad4cdca swift::TypeChecker::typeCheckPatternBinding(swift::PatternBindingDecl*, unsigned int, swift::Type, swift::optionset::OptionSet<swift::TypeCheckExprFlags, unsigned int>) (/usr/bin/swift-frontend+0x216ddca)
#46 0x000056f8fae629d2 swift::PatternBindingEntryRequest::evaluate(swift::Evaluator&, swift::PatternBindingDecl*, unsigned int) const (/usr/bin/swift-frontend+0x22839d2)
#47 0x000056f8fb49f020 swift::PatternBindingEntryRequest::OutputType swift::Evaluator::getResultUncached<swift::PatternBindingEntryRequest, swift::PatternBindingEntryRequest::OutputType swift::evaluateOrDefault<swift::PatternBindingEntryRequest>(swift::Evaluator&, swift::PatternBindingEntryRequest, swift::PatternBindingEntryRequest::OutputType)::'lambda'()>(swift::PatternBindingEntryRequest const&, swift::PatternBindingEntryRequest::OutputType swift::evaluateOrDefault<swift::PatternBindingEntryRequest>(swift::Evaluator&, swift::PatternBindingEntryRequest, swift::PatternBindingEntryRequest::OutputType)::'lambda'()) crtstuff.c:0:0
#48 0x000056f8fb45c4c0 swift::PatternBindingDecl::getCheckedPatternBindingEntry(unsigned int) const (/usr/bin/swift-frontend+0x287d4c0)
#49 0x000056f8fad97fd7 (anonymous namespace)::DeclChecker::visit(swift::Decl*) TypeCheckDeclPrimary.cpp:0:0
#50 0x000056f8fad97cc4 swift::TypeChecker::typeCheckDecl(swift::Decl*) (/usr/bin/swift-frontend+0x21b8cc4)
#51 0x000056f8fae56a6c swift::ASTVisitor<(anonymous namespace)::StmtChecker, void, swift::Stmt*, void, void, void, void>::visit(swift::Stmt*) TypeCheckStmt.cpp:0:0
#52 0x000056f8fae592bc bool (anonymous namespace)::StmtChecker::typeCheckStmt<swift::BraceStmt>(swift::BraceStmt*&) TypeCheckStmt.cpp:0:0
#53 0x000056f8fae51c36 swift::TypeChecker::typeCheckTopLevelCodeDecl(swift::TopLevelCodeDecl*) (/usr/bin/swift-frontend+0x2272c36)
#54 0x000056f8faed05ba swift::TypeCheckPrimaryFileRequest::evaluate(swift::Evaluator&, swift::SourceFile*) const (/usr/bin/swift-frontend+0x22f15ba)
#55 0x000056f8faed4f5b swift::TypeCheckPrimaryFileRequest::OutputType swift::Evaluator::getResultUncached<swift::TypeCheckPrimaryFileRequest, swift::TypeCheckPrimaryFileRequest::OutputType swift::evaluateOrDefault<swift::TypeCheckPrimaryFileRequest>(swift::Evaluator&, swift::TypeCheckPrimaryFileRequest, swift::TypeCheckPrimaryFileRequest::OutputType)::'lambda'()>(swift::TypeCheckPrimaryFileRequest const&, swift::TypeCheckPrimaryFileRequest::OutputType swift::evaluateOrDefault<swift::TypeCheckPrimaryFileRequest>(swift::Evaluator&, swift::TypeCheckPrimaryFileRequest, swift::TypeCheckPrimaryFileRequest::OutputType)::'lambda'()) crtstuff.c:0:0
#56 0x000056f8faed04c8 swift::performTypeChecking(swift::SourceFile&) (/usr/bin/swift-frontend+0x22f14c8)
#57 0x000056f8f99a4c39 bool llvm::function_ref<bool (swift::SourceFile&)>::callback_fn<swift::CompilerInstance::performSema()::$_10>(long, swift::SourceFile&) Frontend.cpp:0:0
#58 0x000056f8f999a96e swift::CompilerInstance::forEachFileToTypeCheck(llvm::function_ref<bool (swift::SourceFile&)>) (/usr/bin/swift-frontend+0xdbb96e)
#59 0x000056f8f999a6eb swift::CompilerInstance::performSema() (/usr/bin/swift-frontend+0xdbb6eb)
#60 0x000056f8f96050e2 withSemanticAnalysis(swift::CompilerInstance&, swift::FrontendObserver*, llvm::function_ref<bool (swift::CompilerInstance&)>, bool) FrontendTool.cpp:0:0
#61 0x000056f8f95f2b95 performCompile(swift::CompilerInstance&, int&, swift::FrontendObserver*, llvm::ArrayRef<char const*>) FrontendTool.cpp:0:0
#62 0x000056f8f95ef81e swift::performFrontend(llvm::ArrayRef<char const*>, char const*, void*, swift::FrontendObserver*) (/usr/bin/swift-frontend+0xa1081e)
#63 0x000056f8f9314681 swift::mainEntry(int, char const**) (/usr/bin/swift-frontend+0x735681)
#64 0x00007192c79ea1ca (/lib/x86_64-linux-gnu/libc.so.6+0x2a1ca)
#65 0x00007192c79ea28b __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28b)
#66 0x000056f8f9313575 _start (/usr/bin/swift-frontend+0x734575)

*** Signal 6: Backtracing from 0x7192c7ae728d... done ***

*** Program crashed: Aborted at 0x00007192c7ae728d ***

Platform: x86_64 Linux (Ubuntu 24.04.4 LTS)

Thread 0 "swift-frontend" crashed:

0  0x00007192c7ae728d <unknown> in libc.so.6


Registers:

rax 0x0000000000000000  0
rdx 0x0000000000000006  6
rcx 0x00007192c7ae728d  48 3d 01 f0 ff ff 73 01 c3 48 8b 0d 5b bb 0d 00  H=·ðÿÿs·ÃH··[»··
rbx 0x0000000000000006  6
rsi 0x000000000017499e  1526174
rdi 0x000000000017499e  1526174
rbp 0x000000000017499e  1526174
rsp 0x000056f9088af328  7b 8a 79 01 f9 56 00 00 b0 f5 8a 08 f9 56 00 00  {·y·ùV··°õ··ùV··
 r8 0x000056f9088af5b0  06 00 00 00 00 00 00 00 fa ff ff ff 00 00 00 00  ········úÿÿÿ····
 r9 0x000056f9088af5b0  06 00 00 00 00 00 00 00 fa ff ff ff 00 00 00 00  ········úÿÿÿ····
r10 0x000056f9088af5b0  06 00 00 00 00 00 00 00 fa ff ff ff 00 00 00 00  ········úÿÿÿ····
r11 0x0000000000000246  582
r12 0x0000000000000006  6
r13 0x0000000000000008  8
r14 0x0000000000000000  0
r15 0x000056f9088af3c8  ff ff ff 7f fe ff ff ff 00 00 00 00 00 00 00 00  ÿÿÿ·þÿÿÿ········
rip 0x00007192c7ae728d  48 3d 01 f0 ff ff 73 01 c3 48 8b 0d 5b bb 0d 00  H=·ðÿÿs·ÃH··[»··

rflags 0x0000000000000246  ZF PF

cs 0x0033  fs 0x0000  gs 0x0000


Images (29 omitted):

0x00007192c79c0000–0x00007192c7b6fd39 8e9fd827446c24067541ac5390e6f527fb5947bb libc.so.6 /usr/lib/x86_64-linux-gnu/libc.so.6

Backtrace took 0.00s

Aborted (core dumped)
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1:detect_stack_use_after_return=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' swift -frontend -emit-sil -wmo -sil-verify-all "$SCRIPT_DIR/test.swift"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `a0af5a02` | Bug corpus (project: `php`, name: `bug29038.phpt`) |
| `b` | `5665bab7` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
