*Fusion-Fuzz Bug Report*

**ID:** `eaaf8edc` &nbsp;·&nbsp; **Signature:** `Assertion failed: ((numMissing + numExtra + numWrong > 0) && "Should not call this function with nothing to diagnose"), function diagnoseArgumentLabelError at MiscDiagnostics.cpp:2973.` &nbsp;·&nbsp; **RC:** `134`

The following code:

```swift


// --- Seed A ---
// RUN: %empty-directory(%t)
// RUN: split-file %s %t
// RUN: %sourcekitd-test -req=find-rename-ranges -rename-spec %t/spec.json %t/main.swift | %FileCheck %s

// REQUIRES: swift_swift_parser

//--- main.swift
func foo() {}

// Make sure we don't crash on the unrelated comment refs:
// foo()
// foo(0)
// foo(a: 0)
// foo {}
// foo {} a: {}

// Nor when written in code:
foo()
foo(0)
foo(a: 0)
foo {}
foo {} a: {}

// CHECK:      source.edit.kind.active:
// CHECK-NEXT:   1:6-1:9 source.refactoring.range.kind.basename
// CHECK-NEXT: source.edit.kind.comment:
// CHECK-NEXT:   4:4-4:7 source.refactoring.range.kind.basename
// CHECK-NEXT: source.edit.kind.unknown:
// CHECK-NEXT:   5:4-5:7 source.refactoring.range.kind.basename
// CHECK-NEXT: source.edit.kind.unknown:
// CHECK-NEXT:   6:4-6:7 source.refactoring.range.kind.basename
// CHECK-NEXT: source.edit.kind.unknown:
// CHECK-NEXT:   7:4-7:7 source.refactoring.range.kind.basename
// CHECK-NEXT: source.edit.kind.unknown:
// CHECK-NEXT:   8:4-8:7 source.refactoring.range.kind.basename
// CHECK-NEXT: source.edit.kind.active:
// CHECK-NEXT:   11:1-11:4 source.refactoring.range.kind.basename
// CHECK-NEXT: source.edit.kind.mismatch:
// CHECK-NEXT: source.edit.kind.mismatch:
// CHECK-NEXT: source.edit.kind.mismatch:
// CHECK-NEXT: source.edit.kind.mismatch:

//--- spec.json
[
  {
    "key.name": "foo()",
    "key.locations": [
      {
        "key.line": 1,
        "key.column": 6,
        "key.nametype": source.syntacticrename.definition
      },
      {
        "key.line": 4,
        "key.column": 4,
        "key.nametype": source.syntacticrename.unknown
      },
      {
        "key.line": 5,
        "key.column": 4,
        "key.nametype": source.syntacticrename.unknown
      },
      {
        "key.line": 6,
        "key.column": 4,
        "key.nametype": source.syntacticrename.unknown
      },
      {
        "key.line": 7,
        "key.column": 4,
        "key.nametype": source.syntacticrename.unknown
      },
      {
        "key.line": 8,
        "key.column": 4,
        "key.nametype": source.syntacticrename.unknown
      },
      {
        "key.line": 11,
        "key.column": 1,
        "key.nametype": source.syntacticrename.call
      },
      {
        "key.line": 12,
        "key.column": 1,
        "key.nametype": source.syntacticrename.call
      },
      {
        "key.line": 13,
        "key.column": 1,
        "key.nametype": source.syntacticrename.call
      },
      {
        "key.line": 14,
        "key.column": 1,
        "key.nametype": source.syntacticrename.call
      },
      {
        "key.line": 15,
        "key.column": 1,
        "key.nametype": source.syntacticrename.call
      },
    ]
  }
]

// --- Seed B ---
// RUN: %target-swift-frontend -emit-sil -verify %s | %FileCheck %s

func foo(a: Int) {}
func foo(q: String = "", a: Int) {}

// CHECK: function_ref @$s12rdar362268743foo1aySi_tF : $@convention(thin) (Int) -> ()
foo(a: 42)

func bar(a: Int, c: Int) {}
func bar(a: Int, b: Int = 0, c: Int) {}

// CHECK: function_ref @$s12rdar362268743bar1a1cySi_SitF : $@convention(thin) (Int, Int) -> ()
bar(a: 0, c: 42)
var _ffl_sentinel: Int = 0
// --- Bug Primitive ---

// P9: @resultBuilder control-flow desugaring stress
@resultBuilder
struct _FflHTML {
    static func buildBlock(_ parts: String...) -> String { parts.joined() }
    static func buildOptional(_ part: String?) -> String { part ?? "" }
    static func buildEither(first:  String) -> String { "<first>\(first)</first>" }
    static func buildEither(second: String) -> String { "<second>\(second)</second>" }
    static func buildArray(_ parts: [String]) -> String { parts.joined(separator: "\n") }
}
func _ffl_p9_render(_ flag: Bool, items: [String]) -> String {
    @_FflHTML var body: String {
        "<root>"
        if flag {
            "<active/>"
        } else {
            "<inactive/>"
        }
        for item in items {
            "<item>\(item)</item>"
        }
        if items.isEmpty {
            "<empty/>"
        }
        "</root>"
    }
    return body
}
do {
    let _ffl_desc  = String(describing: _ffl_sentinel)
    let _ffl_items = _ffl_desc.split(separator: " ").map(String.init)
    _ = _ffl_p9_render(_ffl_items.isEmpty, items: _ffl_items)
}


```

Resulted in this output:

```
/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpr_80ts7d/eaaf8edc.swift:49:15: error: consecutive statements on a line must be separated by ';'
 47 | [
 48 |   {
 49 |     "key.name": "foo()",
    |               `- error: consecutive statements on a line must be separated by ';'
 50 |     "key.locations": [
 51 |       {

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpr_80ts7d/eaaf8edc.swift:49:15: error: expected expression
 47 | [
 48 |   {
 49 |     "key.name": "foo()",
    |               `- error: expected expression
 50 |     "key.locations": [
 51 |       {

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpr_80ts7d/eaaf8edc.swift:22:5: error: missing argument label 'a:' in call
 20 | // Nor when written in code:
 21 | foo()
 22 | foo(0)
    |     `- error: missing argument label 'a:' in call
 23 | foo(a: 0)
 24 | foo {}

Assertion failed: ((numMissing + numExtra + numWrong > 0) && "Should not call this function with nothing to diagnose"), function diagnoseArgumentLabelError at MiscDiagnostics.cpp:2973.
(to display assertion configuration options: -Xllvm -assert-help)

Please submit a bug report (https://swift.org/contributing/#reporting-bugs) and include the crash backtrace.
Stack dump:
0.	Program arguments: /usr/bin/swift-frontend -typecheck -wmo -sil-verify-all -enable-experimental-feature VariadicGenerics /home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpr_80ts7d/eaaf8edc.swift
1.	Swift version 6.5-dev (LLVM 7c86461e21cca7e, Swift 6da4da7153e8252)
2.	Compiling with effective version 5.10
3.	While evaluating request TypeCheckPrimaryFileRequest(source_file "/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpr_80ts7d/eaaf8edc.swift")
4.	While type-checking statement at [/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpr_80ts7d/eaaf8edc.swift:25:1 - line:25:12] RangeText="foo {} a: {"
5.	While type-checking expression at [/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpr_80ts7d/eaaf8edc.swift:25:1 - line:25:12] RangeText="foo {} a: {"
6.	While type-checking-target starting at /home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpr_80ts7d/eaaf8edc.swift:25:1
7.	Assertion failed: ((numMissing + numExtra + numWrong > 0) && "Should not call this function with nothing to diagnose"), function diagnoseArgumentLabelError at MiscDiagnostics.cpp:2973.
| 	(to display assertion configuration options: -Xllvm -assert-help)
 #0 0x0000559e35cf1a58 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/bin/swift-frontend+0x8bc7a58)
 #1 0x0000559e35cef275 llvm::sys::RunSignalHandlers() (/usr/bin/swift-frontend+0x8bc5275)
 #2 0x0000559e35cf2811 SignalHandler(int, siginfo_t*, void*) Signals.cpp:0:0
 #3 0x00007f0b27adf330 (/lib/x86_64-linux-gnu/libc.so.6+0x45330)
 #4 0x00007f0b27b38b2c pthread_kill (/lib/x86_64-linux-gnu/libc.so.6+0x9eb2c)
 #5 0x00007f0b27adf27e raise (/lib/x86_64-linux-gnu/libc.so.6+0x4527e)
 #6 0x00007f0b27ac28ff abort (/lib/x86_64-linux-gnu/libc.so.6+0x288ff)
 #7 0x0000559e2fe13e72 (/usr/bin/swift-frontend+0x2ce9e72)
 #8 0x0000559e2fe13e24 (/usr/bin/swift-frontend+0x2ce9e24)
 #9 0x0000559e2f1b6144 swift::diagnoseArgumentLabelError(swift::ASTContext&, swift::ArgumentList const*, llvm::ArrayRef<swift::Identifier>, swift::ParameterContext, swift::InFlightDiagnostic*) (/usr/bin/swift-frontend+0x208c144)
#10 0x0000559e2f1059cc swift::constraints::RelabelArguments::diagnose(swift::constraints::Solution const&, bool) const (/usr/bin/swift-frontend+0x1fdb9cc)
#11 0x0000559e2f495b4f swift::constraints::ConstraintSystem::applySolutionFixes(swift::constraints::Solution const&) (/usr/bin/swift-frontend+0x236bb4f)
#12 0x0000559e2f4965a2 swift::constraints::ConstraintSystem::applySolution(swift::constraints::Solution&, swift::constraints::SyntacticElementTarget) (/usr/bin/swift-frontend+0x236c5a2)
#13 0x0000559e2f2a0e23 swift::TypeChecker::typeCheckTarget(swift::constraints::SyntacticElementTarget&, swift::optionset::OptionSet<swift::TypeCheckExprFlags, unsigned int>, swift::DiagnosticTransaction*) (/usr/bin/swift-frontend+0x2176e23)
#14 0x0000559e2f2a0c41 swift::TypeChecker::typeCheckExpression(swift::constraints::SyntacticElementTarget&, swift::optionset::OptionSet<swift::TypeCheckExprFlags, unsigned int>, swift::DiagnosticTransaction*) (/usr/bin/swift-frontend+0x2176c41)
#15 0x0000559e2f2a0b16 swift::TypeChecker::typeCheckExpression(swift::Expr*&, swift::DeclContext*, swift::constraints::ContextualTypeInfo, swift::optionset::OptionSet<swift::TypeCheckExprFlags, unsigned int>) (/usr/bin/swift-frontend+0x2176b16)
#16 0x0000559e2f3a6d3b (anonymous namespace)::StmtChecker::typeCheckASTNode(swift::ASTNode&) TypeCheckStmt.cpp:0:0
#17 0x0000559e2f3ad97c swift::ASTVisitor<(anonymous namespace)::StmtChecker, void, swift::Stmt*, void, void, void, void>::visit(swift::Stmt*) TypeCheckStmt.cpp:0:0
#18 0x0000559e2f3b01cc bool (anonymous namespace)::StmtChecker::typeCheckStmt<swift::BraceStmt>(swift::BraceStmt*&) TypeCheckStmt.cpp:0:0
#19 0x0000559e2f3a8b46 swift::TypeChecker::typeCheckTopLevelCodeDecl(swift::TopLevelCodeDecl*) (/usr/bin/swift-frontend+0x227eb46)
#20 0x0000559e2f4274ca swift::TypeCheckPrimaryFileRequest::evaluate(swift::Evaluator&, swift::SourceFile*) const (/usr/bin/swift-frontend+0x22fd4ca)
#21 0x0000559e2f42be6b swift::TypeCheckPrimaryFileRequest::OutputType swift::Evaluator::getResultUncached<swift::TypeCheckPrimaryFileRequest, swift::TypeCheckPrimaryFileRequest::OutputType swift::evaluateOrDefault<swift::TypeCheckPrimaryFileRequest>(swift::Evaluator&, swift::TypeCheckPrimaryFileRequest, swift::TypeCheckPrimaryFileRequest::OutputType)::'lambda'()>(swift::TypeCheckPrimaryFileRequest const&, swift::TypeCheckPrimaryFileRequest::OutputType swift::evaluateOrDefault<swift::TypeCheckPrimaryFileRequest>(swift::Evaluator&, swift::TypeCheckPrimaryFileRequest, swift::TypeCheckPrimaryFileRequest::OutputType)::'lambda'()) crtstuff.c:0:0
#22 0x0000559e2f4273d8 swift::performTypeChecking(swift::SourceFile&) (/usr/bin/swift-frontend+0x22fd3d8)
#23 0x0000559e2def2499 bool llvm::function_ref<bool (swift::SourceFile&)>::callback_fn<swift::CompilerInstance::performSema()::$_10>(long, swift::SourceFile&) Frontend.cpp:0:0
#24 0x0000559e2dee690e swift::CompilerInstance::forEachFileToTypeCheck(llvm::function_ref<bool (swift::SourceFile&)>) (/usr/bin/swift-frontend+0xdbc90e)
#25 0x0000559e2dee668b swift::CompilerInstance::performSema() (/usr/bin/swift-frontend+0xdbc68b)
#26 0x0000559e2db50f32 withSemanticAnalysis(swift::CompilerInstance&, swift::FrontendObserver*, llvm::function_ref<bool (swift::CompilerInstance&)>, bool) FrontendTool.cpp:0:0
#27 0x0000559e2db3e9a5 performCompile(swift::CompilerInstance&, int&, swift::FrontendObserver*, llvm::ArrayRef<char const*>) FrontendTool.cpp:0:0
#28 0x0000559e2db3b62e swift::performFrontend(llvm::ArrayRef<char const*>, char const*, void*, swift::FrontendObserver*) (/usr/bin/swift-frontend+0xa1162e)
#29 0x0000559e2d85fd21 swift::mainEntry(int, char const**) (/usr/bin/swift-frontend+0x735d21)
#30 0x00007f0b27ac41ca (/lib/x86_64-linux-gnu/libc.so.6+0x2a1ca)
#31 0x00007f0b27ac428b __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28b)
#32 0x0000559e2d85ec15 _start (/usr/bin/swift-frontend+0x734c15)

*** Signal 6: Backtracing from 0x7f0b27bc128d... done ***

*** Program crashed: Aborted at 0x00007f0b27bc128d ***

Platform: x86_64 Linux (Ubuntu 24.04.4 LTS)

Thread 0 "swift-frontend" crashed:

0  0x00007f0b27bc128d <unknown> in libc.so.6


Registers:

rax 0x0000000000000000  0
rdx 0x0000000000000006  6
rcx 0x00007f0b27bc128d  48 3d 01 f0 ff ff 73 01 c3 48 8b 0d 5b bb 0d 00  H=·ðÿÿs·ÃH··[»··
rbx 0x0000000000000006  6
rsi 0x000000000017fad3  1571539
rdi 0x000000000017fad3  1571539
rbp 0x000000000017fad3  1571539
rsp 0x0000559e790c8328  3b 28 cf 35 9e 55 00 00 b0 85 0c 79 9e 55 00 00  ;(Ï5·U··°··y·U··
 r8 0x0000559e790c85b0  06 00 00 00 00 00 00 00 fa ff ff ff 00 00 00 00  ········úÿÿÿ····
 r9 0x0000559e790c85b0  06 00 00 00 00 00 00 00 fa ff ff ff 00 00 00 00  ········úÿÿÿ····
r10 0x0000559e790c85b0  06 00 00 00 00 00 00 00 fa ff ff ff 00 00 00 00  ········úÿÿÿ····
r11 0x0000000000000246  582
r12 0x0000000000000006  6
r13 0x000000000000001a  26
r14 0x0000000000000000  0
r15 0x0000559e790c83c8  ff ff ff 7f fe ff ff ff 00 00 00 00 00 00 00 00  ÿÿÿ·þÿÿÿ········
rip 0x00007f0b27bc128d  48 3d 01 f0 ff ff 73 01 c3 48 8b 0d 5b bb 0d 00  H=·ðÿÿs·ÃH··[»··

rflags 0x0000000000000246  ZF PF

cs 0x0033  fs 0x0000  gs 0x0000


Images (29 omitted):

0x00007f0b27a9a000–0x00007f0b27c49d39 8e9fd827446c24067541ac5390e6f527fb5947bb libc.so.6 /usr/lib/x86_64-linux-gnu/libc.so.6

Backtrace took 0.00s

Aborted (core dumped)
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1:detect_stack_use_after_return=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' swift -frontend -typecheck -wmo -sil-verify-all -enable-experimental-feature VariadicGenerics "$SCRIPT_DIR/test.swift"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `07ed0046` | Project seed |
| `b` | `d835dd43` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
