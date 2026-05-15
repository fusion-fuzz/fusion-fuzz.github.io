---
render_with_liquid: false
---

# [swiftc crash `evaluateFreestandingMacro`](https://github.com/swiftlang/swift/issues/84898)

### Description

_No response_

### Reproduction

```swift
import freestanding_macro_library

#if IMPORT_MACRO_LIBRARY

#else
@freestanding(declaration, names: named(StructWithUnqualifiedLookup))
macro structWithUnqualifiedLookup() = #externalMacro(module: "MacroDefinition", type: "DefineStructWithUnqualifiedLookupMacro")
@freestanding(declaration)
macro anonymousTypes(public: Bool = false, causeErrors: Bool = false, _: () -> String) = #externalMacro(module: "MacroDefinition", type: "DefineAnonymousTypesMacro")
@freestanding(declaration)
macro introduceTypeCheckingErrors() = #externalMacro(module: "MacroDefinition", type: "IntroduceTypeCheckingErrorsMacro")
@freestanding(declaration)
macro freestandingWithClosure<T>(_ value: T, body: (T) -> T) = #externalMacro(module: "MacroDefinition", type: "EmptyDeclarationMacro")
@freestanding(declaration, names: arbitrary) macro bitwidthNumberedStructs(_ baseName: String) = #externalMacro(module: "MacroDefinition", type: "DefineBitwidthNumberedStructsMacro")
@freestanding(expression) macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "MacroDefinition", type: "StringifyMacro")
@freestanding(declaration, names: named(value)) macro varValue() = #externalMacro(module: "MacroDefinition", type: "VarValueMacro")

@freestanding(expression) macro checkGeneric_root<A>() = #externalMacro(module: "MacroDefinition", type: "GenericToVoidMacro")
@freestanding(expression) macro checkGeneric<A>() = #checkGeneric_root<A>()

@freestanding(expression) macro checkGeneric2_root<A, B>() = #externalMacro(module: "MacroDefinition", type: "GenericToVoidMacro")
@freestanding(expression) macro checkGeneric2<A, B>() = #checkGeneric2_root<A, B>()

@freestanding(expression) macro checkGenericHashableCodable_root<A: Hashable, B: Codable>() = #externalMacro(module: "MacroDefinition", type: "GenericToVoidMacro")
@freestanding(expression) macro checkGenericHashableCodable<A: Hashable, B: Codable>() = #checkGenericHashableCodable_root<A, B>()

#endif

// Test unqualified lookup from within a macro expansion

let world = 3 // to be used by the macro expansion below

#structWithUnqualifiedLookup

func lookupGlobalFreestandingExpansion() {
  // CHECK: 4
  print(StructWithUnqualifiedLookup().foo())
}

#anonymousTypes(public: true) { "hello" }

// CHECK-SIL: sil @$s9MacroUser03$s9A115User0033top_level_freestandingswift_DbGHjfMX56_0_33_082AE7CFEFA6960C804A9FE7366EB5A0Ll14anonymousTypesfMf_4namefMu_C5helloSSyF

@main
struct Main {
  static func main() {
    lookupGlobalFreestandingExpansion()
  }
}

// Unqualified lookup for names defined within macro arguments.
#freestandingWithClosure(0) { x in x }

#freestandingWithClosure(1) {
  let x = $0
  return x
}

struct HasInnerClosure {
  #freestandingWithClosure(0) { x in x }
  #freestandingWithClosure(1) { x in x }
}

#if TEST_DIAGNOSTICS
// Arbitrary names at global scope

#bitwidthNumberedStructs("MyIntGlobal")
// expected-error@-1 {{'declaration' macros are not allowed to introduce arbitrary names at global scope}}

func testArbitraryAtGlobal() {
  _ = MyIntGlobal16()
  // expected-error@-1 {{cannot find 'MyIntGlobal16' in scope}}
}
#endif


#varValue

func testGlobalVariable() {
  _ = value
}

#if TEST_DIAGNOSTICS

// expected-note @+1 6 {{in expansion of macro 'anonymousTypes' here}}
#anonymousTypes(causeErrors: true) { "foo" }
// expected-note @+1 2 {{in expansion of macro 'anonymousTypes' here}}
#anonymousTypes { () -> String in
  // expected-warning @+1 {{use of protocol 'Equatable' as a type must be written 'any Equatable'}}
  _ = 0 as Equatable
  return "foo"
}

#endif


@freestanding(declaration)
macro Empty<T>(_ closure: () -> T) = #externalMacro(module: "MacroDefinition", type: "EmptyDeclarationMacro")

#Empty {
  S(a: 10, b: 10)
}

@attached(extension, conformances: Initializable, names: named(init))
macro Initializable() = #externalMacro(module: "MacroDefinition", type: "InitializableMacro")

protocol Initializable {
  init(value: Int)
}

@Initializable
struct S {
  init(a: Int, b: Int) {}
}

#checkGeneric<String>()
#checkGeneric2<String, Int>()
#checkGenericHashableCodable<String, Int>()

@freestanding(expression) macro functionCallWithInoutParam(_ v: inout Int)
  = #externalMacro(module: "MacroDefinition", type: "VoidExpressionMacro")

@freestanding(expression) macro functionCallWithTwoInoutParams(_ u: inout Int, _ v: inout Int)
  = #externalMacro(module: "MacroDefinition", type: "VoidExpressionMacro")

@freestanding(expression) macro functionCallWithInoutParamPlusOthers(
  string: String, double: Double, _ v: inout Int)
  = #externalMacro(module: "MacroDefinition", type: "VoidExpressionMacro")

func testFunctionCallWithInoutParam() {
  var a = 0
  var b = 0
  #functionCallWithInoutParam(&a)
  #functionCallWithTwoInoutParams(&a, &b)
  #functionCallWithInoutParamPlusOthers(string: "", double: 1.0, &a)
}


let __fusion_0 = }

class A{var f=b
func b{class B{
class A{class A{
class A<f:f.c
```


### Stack dump

```text
Please submit a bug report (https://swift.org/contributing/#reporting-bugs) and include the crash backtrace.
Stack dump:
0.	Program arguments: /usr/bin/swift-frontend -frontend -c -primary-file minn.swift -target x86_64-unknown-linux-gnu -disable-objc-interop -color-diagnostics -Xcc -fcolor-diagnostics -empty-abi-descriptor -no-auto-bridging-header-chaining -module-name minn -in-process-plugin-server-path /usr/lib/swift/host/libSwiftInProcPluginServer.so -plugin-path /usr/lib/swift/host/plugins -plugin-path /usr/local/lib/swift/host/plugins -o /tmp/TemporaryDirectory.VjjFSi/minn-1.o
1.	Swift version 6.2 (swift-6.2-RELEASE)
2.	Compiling with effective version 5.10
3.	While evaluating request TypeCheckPrimaryFileRequest(source_file "minn.swift")
4.	While type-checking statement at [minn.swift:117:1 - line:117:29] RangeText="#checkGeneric2<String, Int>("
5.	While type-checking expression at [minn.swift:117:1 - line:117:29] RangeText="#checkGeneric2<String, Int>("
6.	While type-checking-target starting at minn.swift:117:1
7.	While evaluating request ExpandMacroExpansionExprRequest(expression)
 #0 0x000055b9837e1598 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/bin/swift-frontend+0x7316598)
 #1 0x000055b9837df36e llvm::sys::RunSignalHandlers() (/usr/bin/swift-frontend+0x731436e)
 #2 0x000055b9837e1c31 SignalHandler(int, siginfo_t*, void*) Signals.cpp:0:0
 #3 0x000073ba9ba16330 (/lib/x86_64-linux-gnu/libc.so.6+0x45330)
 #4 0x000073ba9ba6fb2c pthread_kill (/lib/x86_64-linux-gnu/libc.so.6+0x9eb2c)
 #5 0x000073ba9ba1627e raise (/lib/x86_64-linux-gnu/libc.so.6+0x4527e)
 #6 0x000073ba9b9f98ff abort (/lib/x86_64-linux-gnu/libc.so.6+0x288ff)
 #7 0x000073ba9bcb6ff5 (/lib/x86_64-linux-gnu/libstdc++.so.6+0xa5ff5)
 #8 0x000073ba9bccc0da (/lib/x86_64-linux-gnu/libstdc++.so.6+0xbb0da)
 #9 0x000073ba9bcb6a55 std::unexpected() (/lib/x86_64-linux-gnu/libstdc++.so.6+0xa5a55)
#10 0x000073ba9bccc391 (/lib/x86_64-linux-gnu/libstdc++.so.6+0xbb391)
#11 0x000073ba9bcba2d2 std::__throw_length_error(char const*) (/lib/x86_64-linux-gnu/libstdc++.so.6+0xa92d2)
#12 0x000073ba9bd7a866 (/lib/x86_64-linux-gnu/libstdc++.so.6+0x169866)
#13 0x000055b97e3db392 expandMacroDefinition[abi:cxx11](swift::ExpandedMacroDefinition, swift::MacroDecl*, swift::SubstitutionMap, swift::ArgumentList*) TypeCheckMacros.cpp:0:0
#14 0x000055b97e3d703c evaluateFreestandingMacro(swift::FreestandingMacroExpansion*, llvm::StringRef) TypeCheckMacros.cpp:0:0
#15 0x000055b97e3d64bf swift::expandMacroExpr(swift::MacroExpansionExpr*) (/usr/bin/swift-frontend+0x1f0b4bf)
#16 0x000055b97e3d641a swift::ExpandMacroExpansionExprRequest::evaluate(swift::Evaluator&, swift::MacroExpansionExpr*) const (/usr/bin/swift-frontend+0x1f0b41a)
#17 0x000055b97e4b4ba1 swift::ExpandMacroExpansionExprRequest::OutputType swift::Evaluator::getResultUncached<swift::ExpandMacroExpansionExprRequest, swift::ExpandMacroExpansionExprRequest::OutputType swift::evaluateOrDefault<swift::ExpandMacroExpansionExprRequest>(swift::Evaluator&, swift::ExpandMacroExpansionExprRequest, swift::ExpandMacroExpansionExprRequest::OutputType)::'lambda'()>(swift::ExpandMacroExpansionExprRequest const&, swift::ExpandMacroExpansionExprRequest::OutputType swift::evaluateOrDefault<swift::ExpandMacroExpansionExprRequest>(swift::Evaluator&, swift::ExpandMacroExpansionExprRequest, swift::ExpandMacroExpansionExprRequest::OutputType)::'lambda'()) crtstuff.c:0:0
#18 0x000055b97e4b4a1b swift::ExpandMacroExpansionExprRequest::OutputType swift::Evaluator::getResultCached<swift::ExpandMacroExpansionExprRequest, swift::ExpandMacroExpansionExprRequest::OutputType swift::evaluateOrDefault<swift::ExpandMacroExpansionExprRequest>(swift::Evaluator&, swift::ExpandMacroExpansionExprRequest, swift::ExpandMacroExpansionExprRequest::OutputType)::'lambda'(), (void*)0>(swift::ExpandMacroExpansionExprRequest const&, swift::ExpandMacroExpansionExprRequest::OutputType swift::evaluateOrDefault<swift::ExpandMacroExpansionExprRequest>(swift::Evaluator&, swift::ExpandMacroExpansionExprRequest, swift::ExpandMacroExpansionExprRequest::OutputType)::'lambda'()) crtstuff.c:0:0
#19 0x000055b97e4a3686 (anonymous namespace)::ExprRewriter::finalize() CSApply.cpp:0:0
#20 0x000055b97e4a1cd1 swift::constraints::ConstraintSystem::applySolution(swift::constraints::Solution&, swift::constraints::SyntacticElementTarget) (/usr/bin/swift-frontend+0x1fd6cd1)
#21 0x000055b97e350f0c swift::TypeChecker::typeCheckTarget(swift::constraints::SyntacticElementTarget&, swift::optionset::OptionSet<swift::TypeCheckExprFlags, unsigned int>, swift::DiagnosticTransaction*) (/usr/bin/swift-frontend+0x1e85f0c)
#22 0x000055b97e350d1d swift::TypeChecker::typeCheckExpression(swift::constraints::SyntacticElementTarget&, swift::optionset::OptionSet<swift::TypeCheckExprFlags, unsigned int>, swift::DiagnosticTransaction*) (/usr/bin/swift-frontend+0x1e85d1d)
#23 0x000055b97e350c06 swift::TypeChecker::typeCheckExpression(swift::Expr*&, swift::DeclContext*, swift::constraints::ContextualTypeInfo, swift::optionset::OptionSet<swift::TypeCheckExprFlags, unsigned int>) (/usr/bin/swift-frontend+0x1e85c06)
#24 0x000055b97e4300c0 (anonymous namespace)::StmtChecker::typeCheckASTNode(swift::ASTNode&) TypeCheckStmt.cpp:0:0
#25 0x000055b97e43321d swift::ASTVisitor<(anonymous namespace)::StmtChecker, void, swift::Stmt*, void, void, void, void>::visit(swift::Stmt*) TypeCheckStmt.cpp:0:0
#26 0x000055b97e4317ac bool (anonymous namespace)::StmtChecker::typeCheckStmt<swift::BraceStmt>(swift::BraceStmt*&) TypeCheckStmt.cpp:0:0
#27 0x000055b97e431823 swift::TypeChecker::typeCheckTopLevelCodeDecl(swift::TopLevelCodeDecl*) (/usr/bin/swift-frontend+0x1f66823)
#28 0x000055b97e4719c1 swift::TypeCheckPrimaryFileRequest::evaluate(swift::Evaluator&, swift::SourceFile*) const (/usr/bin/swift-frontend+0x1fa69c1)
#29 0x000055b97e47352e swift::TypeCheckPrimaryFileRequest::OutputType swift::Evaluator::getResultUncached<swift::TypeCheckPrimaryFileRequest, swift::TypeCheckPrimaryFileRequest::OutputType swift::evaluateOrDefault<swift::TypeCheckPrimaryFileRequest>(swift::Evaluator&, swift::TypeCheckPrimaryFileRequest, swift::TypeCheckPrimaryFileRequest::OutputType)::'lambda'()>(swift::TypeCheckPrimaryFileRequest const&, swift::TypeCheckPrimaryFileRequest::OutputType swift::evaluateOrDefault<swift::TypeCheckPrimaryFileRequest>(swift::Evaluator&, swift::TypeCheckPrimaryFileRequest, swift::TypeCheckPrimaryFileRequest::OutputType)::'lambda'()) crtstuff.c:0:0
#30 0x000055b97e4718e5 swift::performTypeChecking(swift::SourceFile&) (/usr/bin/swift-frontend+0x1fa68e5)
#31 0x000055b97d2fe0b9 bool llvm::function_ref<bool (swift::SourceFile&)>::callback_fn<swift::CompilerInstance::performSema()::$_8>(long, swift::SourceFile&) Frontend.cpp:0:0
#32 0x000055b97d2f380a swift::CompilerInstance::forEachFileToTypeCheck(llvm::function_ref<bool (swift::SourceFile&)>) (/usr/bin/swift-frontend+0xe2880a)
#33 0x000055b97d2f3797 swift::CompilerInstance::performSema() (/usr/bin/swift-frontend+0xe28797)
#34 0x000055b97d03953a performCompile(swift::CompilerInstance&, int&, swift::FrontendObserver*) FrontendTool.cpp:0:0
#35 0x000055b97d038ae4 swift::performFrontend(llvm::ArrayRef<char const*>, char const*, void*, swift::FrontendObserver*) (/usr/bin/swift-frontend+0xb6dae4)
#36 0x000055b97cdf01f9 swift::mainEntry(int, char const**) (/usr/bin/swift-frontend+0x9251f9)
#37 0x000073ba9b9fb1ca (/lib/x86_64-linux-gnu/libc.so.6+0x2a1ca)
#38 0x000073ba9b9fb28b __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28b)
#39 0x000055b97cdef345 _start (/usr/bin/swift-frontend+0x924345)
```

### Expected behavior

should not crash anyway. should be syntax error?

### Environment

docker run --rm -v "$PWD":/work -w /work swift:latest bash -lc 'swiftc -c test.swift -o /dev/null'

### Additional information

_No response_
