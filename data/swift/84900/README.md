---
render_with_liquid: false
---

# [swiftc crash with unclosed bracket](https://github.com/swiftlang/swift/issues/84900)

### Description

_No response_

### Reproduction

```swift
class B<b where B:A{public protocol F
class a { @objc ( : ( b
```


### Stack dump

```text
error: compile command failed due to signal 4 (use -v to see invocation)
min.swift:1:20: error: expected '>' to complete generic parameter list
1 | class B<b where B:A{public protocol F
  |        |           `- error: expected '>' to complete generic parameter list
  |        `- note: to match this opening '<'
2 | class a { @objc ( : ( b
3 | 

min.swift:1:11: error: 'where' clause next to generic parameters is obsolete, must be written following the declaration's type
1 | class B<b where B:A{public protocol F
  |           `- error: 'where' clause next to generic parameters is obsolete, must be written following the declaration's type
2 | class a { @objc ( : ( b
3 | 

min.swift:1:38: error: expected '{' in protocol type
1 | class B<b where B:A{public protocol F
  |                                      `- error: expected '{' in protocol type
2 | class a { @objc ( : ( b
3 | 

min.swift:2:16: warning: extraneous whitespace between attribute name and '('; this is an error in the Swift 6 language mode
1 | class B<b where B:A{public protocol F
2 | class a { @objc ( : ( b
  |                `- warning: extraneous whitespace between attribute name and '('; this is an error in the Swift 6 language mode
3 | 

min.swift:2:21: error: expected ')' after name for '@objc'
1 | class B<b where B:A{public protocol F
2 | class a { @objc ( : ( b
  |                 |   `- error: expected ')' after name for '@objc'
  |                 `- note: to match this opening '('
3 | 

min.swift:2:21: error: expected 'var' keyword in property declaration
1 | class B<b where B:A{public protocol F
2 | class a { @objc ( : ( b
  |                     `- error: expected 'var' keyword in property declaration
3 | 

min.swift:3:1: error: expected ')' at end of tuple pattern
1 | class B<b where B:A{public protocol F
2 | class a { @objc ( : ( b
  |                     `- note: to match this opening '('
3 | 
  | `- error: expected ')' at end of tuple pattern

min.swift:3:1: error: expected '}' in class
1 | class B<b where B:A{public protocol F
2 | class a { @objc ( : ( b
  |         `- note: to match this opening '{'
3 | 
  | `- error: expected '}' in class

min.swift:3:1: error: expected '}' in class
1 | class B<b where B:A{public protocol F
  |                    `- note: to match this opening '{'
2 | class a { @objc ( : ( b
3 | 
  | `- error: expected '}' in class

min.swift:1:19: error: cannot find type 'A' in scope
1 | class B<b where B:A{public protocol F
  |                   `- error: cannot find type 'A' in scope
2 | class a { @objc ( : ( b
3 | 

min.swift:1:7: error: generic class 'B' has self-referential generic requirements
1 | class B<b where B:A{public protocol F
  |       `- error: generic class 'B' has self-referential generic requirements
2 | class a { @objc ( : ( b
3 | 

min.swift:1:37: error: protocol 'F' cannot be nested in a generic context
1 | class B<b where B:A{public protocol F
  |                                     `- error: protocol 'F' cannot be nested in a generic context
2 | class a { @objc ( : ( b
3 | 

min.swift:2:23: error: type annotation missing in pattern
1 | class B<b where B:A{public protocol F
2 | class a { @objc ( : ( b
  |                       `- error: type annotation missing in pattern
3 | 

Please submit a bug report (https://swift.org/contributing/#reporting-bugs) and include the crash backtrace.
Stack dump:
0.	Program arguments: /usr/bin/swift-frontend -frontend -c -primary-file min.swift -target x86_64-unknown-linux-gnu -disable-objc-interop -color-diagnostics -Xcc -fcolor-diagnostics -empty-abi-descriptor -no-auto-bridging-header-chaining -module-name min -in-process-plugin-server-path /usr/lib/swift/host/libSwiftInProcPluginServer.so -plugin-path /usr/lib/swift/host/plugins -plugin-path /usr/local/lib/swift/host/plugins -o /tmp/TemporaryDirectory.dNUdlh/min-1.o
1.	Swift version 6.2 (swift-6.2-RELEASE)
2.	Compiling with effective version 5.10
3.	While evaluating request TypeCheckPrimaryFileRequest(source_file "min.swift")
4.	While type-checking 'B' (at min.swift:1:1)
5.	While type-checking 'a' (at min.swift:2:1)
6.	While type-checking declaration 0x57be361b5f48 (at min.swift:2:21)
 #0 0x000057bdfa1b1598 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/bin/swift-frontend+0x7316598)
 #1 0x000057bdfa1af36e llvm::sys::RunSignalHandlers() (/usr/bin/swift-frontend+0x731436e)
 #2 0x000057bdfa1b1c31 SignalHandler(int, siginfo_t*, void*) Signals.cpp:0:0
 #3 0x00007b094d93e330 (/lib/x86_64-linux-gnu/libc.so.6+0x45330)
 #4 0x000057bdf50ed56e $s11swiftASTGen19addQueuedDiagnostic20queuedDiagnosticsPtr011perFrontende5StateH04text8severity4cLoc12categoryName17documentationPath015highlightRangesH0012numHighlightT013fixItsUntypedySv_SvSo16BridgedStringRefVSo0zE8SeverityVSo0z6SourceN0VA2NSPySo0Z15CharSourceRangeVGSgSiSo0Z8ArrayRefVtF (/usr/bin/swift-frontend+0x225256e)
 #5 0x000057bdf50ecb33 swift_ASTGen_addQueuedDiagnostic (/usr/bin/swift-frontend+0x2251b33)
 #6 0x000057bdf534ad93 addQueueDiagnostic(void*, void*, swift::DiagnosticInfo const&, swift::SourceManager&) DiagnosticBridge.cpp:0:0
 #7 0x000057bdf3cf7649 swift::PrintingDiagnosticConsumer::handleDiagnostic(swift::SourceManager&, swift::DiagnosticInfo const&) (/usr/bin/swift-frontend+0xe5c649)
 #8 0x000057bdf5352511 swift::DiagnosticEngine::emitDiagnostic(swift::Diagnostic const&) (/usr/bin/swift-frontend+0x24b7511)
 #9 0x000057bdf5351f59 swift::DiagnosticEngine::handleDiagnostic(swift::Diagnostic&&) (/usr/bin/swift-frontend+0x24b6f59)
#10 0x000057bdf534f818 swift::InFlightDiagnostic::flush() (/usr/bin/swift-frontend+0x24b4818)
#11 0x000057bdf4ca63b5 swift::TypeChecker::checkDeclAttributes(swift::Decl*) (/usr/bin/swift-frontend+0x1e0b3b5)
#12 0x000057bdf4d7a416 (anonymous namespace)::DeclChecker::visitBoundVariable(swift::VarDecl*) TypeCheckDeclPrimary.cpp:0:0
#13 0x000057bdf4d79e6f void llvm::function_ref<void (swift::VarDecl*)>::callback_fn<(anonymous namespace)::DeclChecker::visitPatternBindingDecl(swift::PatternBindingDecl*)::'lambda'(swift::VarDecl*)>(long, swift::VarDecl*) TypeCheckDeclPrimary.cpp:0:0
#14 0x000057bdf4d655de (anonymous namespace)::DeclChecker::visit(swift::Decl*) TypeCheckDeclPrimary.cpp:0:0
#15 0x000057bdf4d6d04c (anonymous namespace)::DeclChecker::visitClassDecl(swift::ClassDecl*) TypeCheckDeclPrimary.cpp:0:0
#16 0x000057bdf4d65bca (anonymous namespace)::DeclChecker::visit(swift::Decl*) TypeCheckDeclPrimary.cpp:0:0
#17 0x000057bdf4d6d04c (anonymous namespace)::DeclChecker::visitClassDecl(swift::ClassDecl*) TypeCheckDeclPrimary.cpp:0:0
#18 0x000057bdf4d65bca (anonymous namespace)::DeclChecker::visit(swift::Decl*) TypeCheckDeclPrimary.cpp:0:0
#19 0x000057bdf4d652e2 swift::TypeChecker::typeCheckDecl(swift::Decl*) (/usr/bin/swift-frontend+0x1eca2e2)
#20 0x000057bdf4e419a5 swift::TypeCheckPrimaryFileRequest::evaluate(swift::Evaluator&, swift::SourceFile*) const (/usr/bin/swift-frontend+0x1fa69a5)
#21 0x000057bdf4e4352e swift::TypeCheckPrimaryFileRequest::OutputType swift::Evaluator::getResultUncached<swift::TypeCheckPrimaryFileRequest, swift::TypeCheckPrimaryFileRequest::OutputType swift::evaluateOrDefault<swift::TypeCheckPrimaryFileRequest>(swift::Evaluator&, swift::TypeCheckPrimaryFileRequest, swift::TypeCheckPrimaryFileRequest::OutputType)::'lambda'()>(swift::TypeCheckPrimaryFileRequest const&, swift::TypeCheckPrimaryFileRequest::OutputType swift::evaluateOrDefault<swift::TypeCheckPrimaryFileRequest>(swift::Evaluator&, swift::TypeCheckPrimaryFileRequest, swift::TypeCheckPrimaryFileRequest::OutputType)::'lambda'()) crtstuff.c:0:0
#22 0x000057bdf4e418e5 swift::performTypeChecking(swift::SourceFile&) (/usr/bin/swift-frontend+0x1fa68e5)
#23 0x000057bdf3cce0b9 bool llvm::function_ref<bool (swift::SourceFile&)>::callback_fn<swift::CompilerInstance::performSema()::$_8>(long, swift::SourceFile&) Frontend.cpp:0:0
#24 0x000057bdf3cc380a swift::CompilerInstance::forEachFileToTypeCheck(llvm::function_ref<bool (swift::SourceFile&)>) (/usr/bin/swift-frontend+0xe2880a)
#25 0x000057bdf3cc3797 swift::CompilerInstance::performSema() (/usr/bin/swift-frontend+0xe28797)
#26 0x000057bdf3a0953a performCompile(swift::CompilerInstance&, int&, swift::FrontendObserver*) FrontendTool.cpp:0:0
#27 0x000057bdf3a08ae4 swift::performFrontend(llvm::ArrayRef<char const*>, char const*, void*, swift::FrontendObserver*) (/usr/bin/swift-frontend+0xb6dae4)
#28 0x000057bdf37c01f9 swift::mainEntry(int, char const**) (/usr/bin/swift-frontend+0x9251f9)
#29 0x00007b094d9231ca (/lib/x86_64-linux-gnu/libc.so.6+0x2a1ca)
#30 0x00007b094d92328b __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28b)
#31 0x000057bdf37bf345 _start (/usr/bin/swift-frontend+0x924345)

*** Signal 4: Backtracing from 0x7b094d997b2c... done ***

*** Program crashed: Illegal instruction at 0x000000000035b802 ***

Platform: x86_64 Linux (Ubuntu 24.04.3 LTS)

Thread 0 "swift-frontend" crashed:

  0      0x00007b094d997b2c <unknown> in libc.so.6
  1 [ra] 0x00007b094d93e27e <unknown> in libc.so.6
...


Registers:

rax 0x0000000000000000  0
rdx 0x000000000035b802  3520514
rcx 0x00007b094d997b2c  41 89 c6 41 f7 de 3d 00 f0 ff ff b8 00 00 00 00  A·ÆA÷Þ=·ðÿÿ¸····
rbx 0x0000000000000004  4
rsi 0x000000000035b802  3520514
rdi 0x000000000035b802  3520514
rbp 0x000057be35ecfb40  60 fb ec 35 be 57 00 00 7e e2 93 4d 09 7b 00 00  `ûì5¾W··~â·M·{··
rsp 0x000057be35ecfb00  00 00 00 00 00 00 00 00 00 42 01 b1 c1 8b 30 82  ·········B·±Á·0·
 r8 0x000057be35e62010  03 00 06 00 02 00 04 00 07 00 03 00 04 00 03 00  ················
 r9 0x0000000000000007  7
r10 0x00007b094d90f750  d4 01 00 00 12 00 11 00 60 52 04 00 00 00 00 00  Ô·······`R······
r11 0x0000000000000246  582
r12 0x0000000000000004  4
r13 0x00007ffc18e9b640  10 cf 15 36 be 57 00 00 f0 14 1f 36 be 57 00 00  ·Ï·6¾W··ð··6¾W··
r14 0x0000000000000016  22
r15 0x000057be35ecfc08  ff ff ff 7f fe ff ff ff 00 00 00 00 00 00 00 00  ÿÿÿ·þÿÿÿ········
rip 0x00007b094d997b2c  41 89 c6 41 f7 de 3d 00 f0 ff ff b8 00 00 00 00  A·ÆA÷Þ=·ðÿÿ¸····

rflags 0x0000000000000246  ZF PF

cs 0x0033  fs 0x0000  gs 0x0000


Images (29 omitted):

0x00007b094d8f9000–0x00007b094daa8cf9 274eec488d230825a136fa9c4d85370fed7a0a5e libc.so.6 /usr/lib/x86_64-linux-gnu/libc.so.6

Backtrace took 0.00s
```

### Expected behavior

should not crash anyway

### Environment

docker run --rm -v "$PWD":/work -w /work swift:latest bash -lc 'swiftc -c test.swift -o /dev/null'

### Additional information

_No response_
