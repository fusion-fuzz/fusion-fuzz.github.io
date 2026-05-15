---
render_with_liquid: false
---

# [swiftc crash when ArgumentMismatchFailure](https://github.com/swiftlang/swift/issues/84850)

### Description

_No response_

### Reproduction

```swift
func test_assert(x: Int, y: Int) -> Int {
  assert(x >= y , "x smaller than y")
  return x + y
}

func test_fatal(x: Int, y: Int) -> Int {
  if x > y {
    return x + y
  }
  preconditionFailure("Human nature ...")
}

func testprecondition_check(x: Int, y: Int) -> Int {
  precondition(x > y, "Test precondition check")
  return x + y
}

func test_partial_safety_check(x: Int, y: Int) -> Int {
  assert(x > y, "Test partial safety check")
  return x + y
}

let __fusion_0 = x + y

func a<each b>(repeat each b, repeat each b)
a(repeat (
```

cmd: `docker run --rm -v "$PWD":/work -w /work swift:latest bash -lc 'swiftc -c test.swift -o /dev/null'`


### Stack dump

```text
Please submit a bug report (https://swift.org/contributing/#reporting-bugs) and include the crash backtrace.
Stack dump:
0.	Program arguments: /usr/bin/swift-frontend -frontend -c -primary-file min.swift -target x86_64-unknown-linux-gnu -disable-objc-interop -color-diagnostics -Xcc -fcolor-diagnostics -empty-abi-descriptor -no-auto-bridging-header-chaining -module-name min -in-process-plugin-server-path /usr/lib/swift/host/libSwiftInProcPluginServer.so -plugin-path /usr/lib/swift/host/plugins -plugin-path /usr/local/lib/swift/host/plugins -o /tmp/TemporaryDirectory.sepieT/min-1.o
1.	Swift version 6.2 (swift-6.2-RELEASE)
2.	Compiling with effective version 5.10
3.	While evaluating request TypeCheckPrimaryFileRequest(source_file "min.swift")
4.	While type-checking statement at [min.swift:26:1 - line:26:10] RangeText="a(repeat "
5.	While type-checking expression at [min.swift:26:1 - line:26:10] RangeText="a(repeat "
6.	While type-checking-target starting at min.swift:26:1
 #0 0x0000645dbf264598 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/bin/swift-frontend+0x7316598)
 #1 0x0000645dbf26236e llvm::sys::RunSignalHandlers() (/usr/bin/swift-frontend+0x731436e)
 #2 0x0000645dbf264c31 SignalHandler(int, siginfo_t*, void*) Signals.cpp:0:0
 #3 0x00007ec28721b330 (/lib/x86_64-linux-gnu/libc.so.6+0x45330)
 #4 0x0000645db9cbf6a5 swift::constraints::ArgumentMismatchFailure::diagnoseAttemptedRegexBuilder() const (/usr/bin/swift-frontend+0x1d716a5)
 #5 0x0000645db9ca9aa8 swift::constraints::ArgumentMismatchFailure::diagnoseAsError() (/usr/bin/swift-frontend+0x1d5baa8)
 #6 0x0000645db9c8dc78 swift::constraints::AllowArgumentMismatch::diagnose(swift::constraints::Solution const&, bool) const (/usr/bin/swift-frontend+0x1d3fc78)
 #7 0x0000645db9f2439e swift::constraints::ConstraintSystem::applySolutionFixes(swift::constraints::Solution const&) (/usr/bin/swift-frontend+0x1fd639e)
 #8 0x0000645db9f24a32 swift::constraints::ConstraintSystem::applySolution(swift::constraints::Solution&, swift::constraints::SyntacticElementTarget) (/usr/bin/swift-frontend+0x1fd6a32)
 #9 0x0000645db9dd3f0c swift::TypeChecker::typeCheckTarget(swift::constraints::SyntacticElementTarget&, swift::optionset::OptionSet<swift::TypeCheckExprFlags, unsigned int>, swift::DiagnosticTransaction*) (/usr/bin/swift-frontend+0x1e85f0c)
#10 0x0000645db9dd3d1d swift::TypeChecker::typeCheckExpression(swift::constraints::SyntacticElementTarget&, swift::optionset::OptionSet<swift::TypeCheckExprFlags, unsigned int>, swift::DiagnosticTransaction*) (/usr/bin/swift-frontend+0x1e85d1d)
#11 0x0000645db9dd3c06 swift::TypeChecker::typeCheckExpression(swift::Expr*&, swift::DeclContext*, swift::constraints::ContextualTypeInfo, swift::optionset::OptionSet<swift::TypeCheckExprFlags, unsigned int>) (/usr/bin/swift-frontend+0x1e85c06)
#12 0x0000645db9eb30c0 (anonymous namespace)::StmtChecker::typeCheckASTNode(swift::ASTNode&) TypeCheckStmt.cpp:0:0
#13 0x0000645db9eb621d swift::ASTVisitor<(anonymous namespace)::StmtChecker, void, swift::Stmt*, void, void, void, void>::visit(swift::Stmt*) TypeCheckStmt.cpp:0:0
#14 0x0000645db9eb47ac bool (anonymous namespace)::StmtChecker::typeCheckStmt<swift::BraceStmt>(swift::BraceStmt*&) TypeCheckStmt.cpp:0:0
#15 0x0000645db9eb4823 swift::TypeChecker::typeCheckTopLevelCodeDecl(swift::TopLevelCodeDecl*) (/usr/bin/swift-frontend+0x1f66823)
#16 0x0000645db9ef49c1 swift::TypeCheckPrimaryFileRequest::evaluate(swift::Evaluator&, swift::SourceFile*) const (/usr/bin/swift-frontend+0x1fa69c1)
#17 0x0000645db9ef652e swift::TypeCheckPrimaryFileRequest::OutputType swift::Evaluator::getResultUncached<swift::TypeCheckPrimaryFileRequest, swift::TypeCheckPrimaryFileRequest::OutputType swift::evaluateOrDefault<swift::TypeCheckPrimaryFileRequest>(swift::Evaluator&, swift::TypeCheckPrimaryFileRequest, swift::TypeCheckPrimaryFileRequest::OutputType)::'lambda'()>(swift::TypeCheckPrimaryFileRequest const&, swift::TypeCheckPrimaryFileRequest::OutputType swift::evaluateOrDefault<swift::TypeCheckPrimaryFileRequest>(swift::Evaluator&, swift::TypeCheckPrimaryFileRequest, swift::TypeCheckPrimaryFileRequest::OutputType)::'lambda'()) crtstuff.c:0:0
#18 0x0000645db9ef48e5 swift::performTypeChecking(swift::SourceFile&) (/usr/bin/swift-frontend+0x1fa68e5)
#19 0x0000645db8d810b9 bool llvm::function_ref<bool (swift::SourceFile&)>::callback_fn<swift::CompilerInstance::performSema()::$_8>(long, swift::SourceFile&) Frontend.cpp:0:0
#20 0x0000645db8d7680a swift::CompilerInstance::forEachFileToTypeCheck(llvm::function_ref<bool (swift::SourceFile&)>) (/usr/bin/swift-frontend+0xe2880a)
#21 0x0000645db8d76797 swift::CompilerInstance::performSema() (/usr/bin/swift-frontend+0xe28797)
#22 0x0000645db8abc53a performCompile(swift::CompilerInstance&, int&, swift::FrontendObserver*) FrontendTool.cpp:0:0
#23 0x0000645db8abbae4 swift::performFrontend(llvm::ArrayRef<char const*>, char const*, void*, swift::FrontendObserver*) (/usr/bin/swift-frontend+0xb6dae4)
#24 0x0000645db88731f9 swift::mainEntry(int, char const**) (/usr/bin/swift-frontend+0x9251f9)
#25 0x00007ec2872001ca (/lib/x86_64-linux-gnu/libc.so.6+0x2a1ca)
#26 0x00007ec28720028b __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28b)
#27 0x0000645db8872345 _start (/usr/bin/swift-frontend+0x924345)

*** Signal 11: Backtracing from 0x7ec287274b2c... done ***

*** Program crashed: Bad pointer dereference at 0x0000000000083db8 ***

Platform: x86_64 Linux (Ubuntu 24.04.3 LTS)

Thread 0 "swift-frontend" crashed:

  0      0x00007ec287274b2c <unknown> in libc.so.6
  1 [ra] 0x00007ec28721b27e <unknown> in libc.so.6
...


Registers:

rax 0x0000000000000000  0
rdx 0x0000000000083db8  540088
rcx 0x00007ec287274b2c  41 89 c6 41 f7 de 3d 00 f0 ff ff b8 00 00 00 00  A·ÆA÷Þ=·ðÿÿ¸····
rbx 0x000000000000000b  11
rsi 0x0000000000083db8  540088
rdi 0x0000000000083db8  540088
rbp 0x0000645dcbd3bb40  60 bb d3 cb 5d 64 00 00 7e b2 21 87 c2 7e 00 00  `»ÓË]d··~²!·Â~··
rsp 0x0000645dcbd3bb00  00 00 00 00 00 00 00 00 00 21 3a c6 e7 e2 9c 67  ·········!:Æçâ·g
 r8 0x0000645dcbcce010  03 00 06 00 01 00 02 00 07 00 04 00 04 00 02 00  ················
 r9 0x0000000000000007  7
r10 0x00007ec2871ec750  d4 01 00 00 12 00 11 00 60 52 04 00 00 00 00 00  Ô·······`R······
r11 0x0000000000000246  582
r12 0x000000000000000b  11
r13 0x00007ffde747b490  2e 00 00 00 00 00 00 00 a8 b4 47 e7 fd 7f 00 00  .·······¨´Gçý···
r14 0x0000000000000016  22
r15 0x0000645dcbd3bc08  ff ff ff 7f fe ff ff ff 00 00 00 00 00 00 00 00  ÿÿÿ·þÿÿÿ········
rip 0x00007ec287274b2c  41 89 c6 41 f7 de 3d 00 f0 ff ff b8 00 00 00 00  A·ÆA÷Þ=·ðÿÿ¸····

rflags 0x0000000000000246  ZF PF

cs 0x0033  fs 0x0000  gs 0x0000


Images (29 omitted):

0x00007ec2871d6000–0x00007ec287385cf9 274eec488d230825a136fa9c4d85370fed7a0a5e libc.so.6 /usr/lib/x86_64-linux-gnu/libc.so.6

Backtrace took 0.00s
```

### Expected behavior

should not crash anyway

### Environment

nightly

### Additional information

_No response_
