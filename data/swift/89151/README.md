*Fusion-Fuzz Bug Report*

**ID:** `d52f65f9` &nbsp;·&nbsp; **Signature:** `Assertion failed: (isConcrete()), function getConcrete at ProtocolConformanceRef.h:127.` &nbsp;·&nbsp; **RC:** `134`

The following code:

```swift


// --- Seed A ---
// REQUIRES: swift_swift_parser

// RUN: %empty-directory(%t)
// RUN: %host-build-swift -swift-version 5 -emit-library -o %t/%target-library-name(MacroDefinition) -module-name=MacroDefinition %S/Inputs/syntax_macro_definitions.swift -g -no-toolchain-stdlib-rpath

// RUN: %target-typecheck-verify-swift -swift-version 5 -load-plugin-library %t/%target-library-name(MacroDefinition) -module-name MacroUser -DTEST_DIAGNOSTICS -swift-version 5 -I %t
protocol DefaultInit {
  init()
}

@attached(extension, conformances: DefaultInit)
@attached(member, conformances: DefaultInit, names: named(init()), named(f()))
macro DefaultInit() = #externalMacro(module: "MacroDefinition", type: "RequiredDefaultInitMacro")

@DefaultInit
class C { }

@DefaultInit
class D: C { }

@DefaultInit
struct E { }

// --- Seed B ---
// RUN: %target-typecheck-verify-swift -swift-version 4

func bet() where A : B {} // expected-error {{'where' clause cannot be applied to a non-generic top-level declaration}}

typealias gimel = Int where A : B // expected-error {{'where' clause cannot be applied to a non-generic top-level declaration}}

class dalet where A : B {} // expected-error {{'where' clause cannot be applied to a non-generic top-level declaration}}

struct Where {
  func bet() where A == B {}  // expected-error {{'where' clause on non-generic member declaration requires a generic context}}
  typealias gimel = Int where A : B  // expected-error {{'where' clause on non-generic member declaration requires a generic context}}
  class dalet where A : B {}  // expected-error {{'where' clause on non-generic member declaration requires a generic context}}
}

// Make sure Self: ... is correctly diagnosed in classes

class SelfInGenericClass<T> {
  // expected-error@+1 {{type 'Self' in conformance requirement does not refer to a generic parameter or associated type}}
  func foo() where Self: Equatable { }
  // expected-error@+1 {{generic signature requires types 'Self' and 'Bool' to be the same}}
  func bar() where Self == Bool { }
}

protocol Whereable {
  associatedtype Assoc
  associatedtype Bssoc

  // expected-error@+1 {{instance method requirement 'requirement1()' cannot add constraint 'Self.Assoc: Sequence' on 'Self'}}
  func requirement1() where Assoc: Sequence
  // expected-error@+1 {{instance method requirement 'requirement2()' cannot add constraint 'Self.Bssoc == Never' on 'Self'}}
  func requirement2() where Bssoc == Never
}

extension Whereable {
  // expected-note@+1 {{where 'Self' = 'T1'}}
  static func staticExtensionFunc(arg: Self.Element) -> Self.Element
    where Self: Sequence {
      return arg
  }

  // expected-note@+1 {{where 'Self.Assoc' = 'T1.Assoc', 'Self.Bssoc' = 'T1.Bssoc'}}
  func extensionFunc() where Assoc == Bssoc { }


  // expected-note@+1 {{where 'Self.Assoc' = 'T1.Assoc'}}
  subscript() -> Assoc where Assoc: Whereable {
    fatalError()
  }
}

func testProtocolExtensions<T1, T2, T3, T4>(t1: T1, t2: T2, t3: T3, t4: T4)
  where T1: Whereable,
        T2: Whereable & Sequence,
        T3: Whereable, T3.Assoc == T3.Bssoc,
        T4: Whereable, T4.Assoc: Whereable {
  _ = T1.staticExtensionFunc // expected-error {{static method 'staticExtensionFunc(arg:)' requires that 'T1' conform to 'Sequence'}}
  _ = T2.staticExtensionFunc

  t1.extensionFunc() // expected-error {{instance method 'extensionFunc()' requires the types 'T1.Assoc' and 'T1.Bssoc' be equivalent}}
  t3.extensionFunc()

  _ = t1[] // expected-error {{subscript 'subscript()' requires that 'T1.Assoc' conform to 'Whereable'}}
  _ = t4[]
}

class Class<T> {
  // expected-note@+1 {{where 'T' = 'T}} // expected-note@+1 {{where 'T.Assoc' = 'T.Assoc'}}
  static func staticFunc() where T: Whereable, T.Assoc == Int { }

  // expected-note@+1 {{candidate requires that the types 'T' and 'Bool' be equivalent}}
  func func1() where T == Bool { }
  // FIXME: The rhs type at the end of the error message is not persistent across compilations.
  // expected-note@+1 {{candidate requires that the types 'T' and 'Int' be equivalent (requirement specified as 'T' == }}
  func func1() where T == Int { }

  func func2() where T == Int { } // expected-note {{where 'T' = 'T'}}

  subscript() -> T.Element where T: Sequence { // expected-note {{where 'T' = 'T'}}
    fatalError()
  }
}

extension Class {
  static func staticExtensionFunc() where T: Class<Int> { } // expected-note {{where 'T' = 'T'}}

  subscript(arg: T.Element) -> T.Element where T == Array<Int> {
    fatalError()
  }
}

extension Class where T: Equatable {
  func extensionFunc() where T: Comparable { } // expected-note {{where 'T' = 'T'}}

  // expected-error@+1 {{no type for 'T' can satisfy both 'T == Class<Int>' and 'T : Equatable'}}
  func badRequirement1() where T == Class<Int> { }
}

extension Class where T == Bool {
  // expected-error@+1 {{no type for 'T' can satisfy both 'T == Int' and 'T == Bool'}}
  func badRequirement2() where T == Int { }
}

func testMemberDeclarations<T, U: Comparable>(arg1: Class<T>, arg2: Class<U>) {
  // expected-error@+2 {{static method 'staticFunc()' requires the types 'T.Assoc' and 'Int' be equivalent}}
  // expected-error@+1 {{static method 'staticFunc()' requires that 'T' conform to 'Whereable'}}
  Class<T>.staticFunc()
  Class<T>.staticExtensionFunc() // expected-error {{static method 'staticExtensionFunc()' requires that 'T' inherit from 'Class<Int>'}}
  Class<Class<Int>>.staticExtensionFunc()

  arg1.func1() // expected-error {{no exact matches in call to instance method 'func1'}}
  arg1.func2() // expected-error {{instance method 'func2()' requires the types 'T' and 'Int' be equivalent}}
  arg1.extensionFunc() // expected-error {{instance method 'extensionFunc()' requires that 'T' conform to 'Comparable'}}
  arg2.extensionFunc()
  Class<Int>().func1()
  Class<Int>().func2()

  arg1[] // expected-error {{subscript 'subscript()' requires that 'T' conform to 'Sequence'}}
  _ = Class<Array<Int>>()[Int.zero]
}

// Test nested types and requirements.

struct Container<T> {
  typealias NestedAlias = Bool where T == Int
  // expected-note@-1 {{'NestedAlias' previously declared here}}
  typealias NestedAlias = Bool where T == Bool
  // expected-error@-1 {{invalid redeclaration of 'NestedAlias}}
  typealias NestedAlias2 = T.Magnitude where T: FixedWidthInteger

  typealias NestedAlias3 = T.Element where T: Sequence

  class NestedClass where T: Equatable {}
}

extension Container where T: Sequence {
  struct NestedStruct {}

  struct NestedStruct2 where T.Element: Comparable {
    enum NestedEnum where T.Element == Double {} // expected-note {{requirement specified as 'T.Element' == 'Double' [with T = String]}}
  }

  struct NestedStruct3<U: Whereable> {}
}

extension Container.NestedStruct3 {
  func foo(arg: U) where U.Assoc == T {}
}

_ = Container<String>.NestedAlias2.self // expected-error {{type 'String' does not conform to protocol 'FixedWidthInteger'}}
_ = Container<Container<Bool>>.NestedClass.self // expected-error {{type 'Container<Bool>' does not conform to protocol 'Equatable'}}
_ = Container<Void>.NestedStruct.self // expected-error {{type 'Void' does not conform to protocol 'Sequence'}}
_ = Container<Array<Void>>.NestedStruct2.self // expected-error {{type 'Void' does not conform to protocol 'Comparable'}}
_ = Container<String>.NestedStruct2.NestedEnum.self // expected-error {{'Container<T>.NestedStruct2.NestedEnum' requires the types 'String.Element' (aka 'Character') and 'Double' be equivalent}}
_ = Container<Int>.NestedAlias2.self
_ = Container<Bool>.NestedClass.self
_ = Container<String>.NestedStruct.self
_ = Container<Array<UInt8>>.NestedStruct2.self
_ = Container<Array<Double>>.NestedStruct2.NestedEnum.self

// Make sure the substitution here actually succeeds instead of producing an ErrorType
func sameType<T>(_: T.Type, _: T.Type) {}
sameType(Container<Array<Int>>.NestedAlias3.self, Int.self)
sameType(Container<Array<Bool>>.NestedAlias3.self, Int.self)
// expected-error@-1 {{cannot convert value of type 'Int.Type' to expected argument type 'Container<Array<Bool>>.NestedAlias3.Type' (aka 'Bool.Type')}}

sameType(Container<Array<Int>>.NestedAlias3.self, Bool.self)
// expected-error@-1 {{cannot convert value of type 'Bool.Type' to expected argument type 'Container<Array<Int>>.NestedAlias3.Type' (aka 'Int.Type')}}
var _ffl_sentinel: Int = 0
// --- Bug Primitive ---

// P3: Opaque result type (some) reverse-inference stress
protocol _FflProducer {
    associatedtype Output
    func produce() -> Output
}
struct _FflIntProducer: _FflProducer {
    let seed: Int
    func produce() -> Int { seed &* 6364136223846793005 &+ 1442695040888963407 }
}
struct _FflStrProducer: _FflProducer {
    let seed: String
    func produce() -> String { seed + seed }
}
@inlinable
func _ffl_p3_make(_ flag: Bool) -> some _FflProducer {
    if flag { return _FflIntProducer(seed: 42) as! any _FflProducer as! _FflIntProducer }
    return _FflIntProducer(seed: 0)
}
do {
    let _ffl_flag = String(describing: _ffl_sentinel).isEmpty
    let _ffl_prod = _ffl_p3_make(_ffl_flag)
    _ = _ffl_prod.produce()
}


```

Resulted in this output:

```
/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp624fpi98/d52f65f9.swift:16:7: warning: external macro implementation type 'MacroDefinition.RequiredDefaultInitMacro' could not be found for macro 'DefaultInit()'; plugin for module 'MacroDefinition' not found
 14 | @attached(extension, conformances: DefaultInit)
 15 | @attached(member, conformances: DefaultInit, names: named(init()), named(f()))
 16 | macro DefaultInit() = #externalMacro(module: "MacroDefinition", type: "RequiredDefaultInitMacro")
    |       `- warning: external macro implementation type 'MacroDefinition.RequiredDefaultInitMacro' could not be found for macro 'DefaultInit()'; plugin for module 'MacroDefinition' not found
 17 | 
 18 | @DefaultInit

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp624fpi98/d52f65f9.swift:19:7: error: external macro implementation type 'MacroDefinition.RequiredDefaultInitMacro' could not be found for macro 'DefaultInit()'; plugin for module 'MacroDefinition' not found
 14 | @attached(extension, conformances: DefaultInit)
 15 | @attached(member, conformances: DefaultInit, names: named(init()), named(f()))
 16 | macro DefaultInit() = #externalMacro(module: "MacroDefinition", type: "RequiredDefaultInitMacro")
    |       `- note: 'DefaultInit()' declared here
 17 | 
 18 | @DefaultInit
 19 | class C { }
    |       `- error: external macro implementation type 'MacroDefinition.RequiredDefaultInitMacro' could not be found for macro 'DefaultInit()'; plugin for module 'MacroDefinition' not found
 20 | 
 21 | @DefaultInit

Assertion failed: (isConcrete()), function getConcrete at ProtocolConformanceRef.h:127.
(to display assertion configuration options: -Xllvm -assert-help)

Please submit a bug report (https://swift.org/contributing/#reporting-bugs) and include the crash backtrace.
Stack dump:
0.	Program arguments: /usr/bin/swift-frontend -emit-ir -O -sil-verify-all -enable-experimental-feature NonescapableTypes -strict-concurrency=complete /home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp624fpi98/d52f65f9.swift
1.	Swift version 6.5-dev (LLVM 7c86461e21cca7e, Swift 6da4da7153e8252)
2.	Compiling with effective version 5.10
3.	While evaluating request TypeCheckPrimaryFileRequest(source_file "/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp624fpi98/d52f65f9.swift")
4.	While type-checking 'D' (at /home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp624fpi98/d52f65f9.swift:22:1)
5.	While evaluating request StoredPropertiesRequest(d52f65f9.(file).D@/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp624fpi98/d52f65f9.swift:22:7)
6.	While evaluating request ExpandSynthesizedMemberMacroRequest(d52f65f9.(file).D@/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp624fpi98/d52f65f9.swift:22:7)
7.	Assertion failed: (isConcrete()), function getConcrete at ProtocolConformanceRef.h:127.
| 	(to display assertion configuration options: -Xllvm -assert-help)
 #0 0x0000597934172a58 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/bin/swift-frontend+0x8bc7a58)
 #1 0x0000597934170275 llvm::sys::RunSignalHandlers() (/usr/bin/swift-frontend+0x8bc5275)
 #2 0x0000597934173811 SignalHandler(int, siginfo_t*, void*) Signals.cpp:0:0
 #3 0x0000785c8d00b330 (/lib/x86_64-linux-gnu/libc.so.6+0x45330)
 #4 0x0000785c8d064b2c pthread_kill (/lib/x86_64-linux-gnu/libc.so.6+0x9eb2c)
 #5 0x0000785c8d00b27e raise (/lib/x86_64-linux-gnu/libc.so.6+0x4527e)
 #6 0x0000785c8cfee8ff abort (/lib/x86_64-linux-gnu/libc.so.6+0x288ff)
 #7 0x000059792e294e72 (/usr/bin/swift-frontend+0x2ce9e72)
 #8 0x000059792e294e24 (/usr/bin/swift-frontend+0x2ce9e24)
 #9 0x000059792e1a99ae swift::ConformanceLookupTable::getConformance(swift::NominalTypeDecl*, swift::ConformanceLookupTable::ConformanceEntry*) (/usr/bin/swift-frontend+0x2bfe9ae)
#10 0x000059792e1a9e7e swift::ConformanceLookupTable::lookupConformance(swift::NominalTypeDecl*, swift::ProtocolDecl*, llvm::SmallVectorImpl<swift::ProtocolConformance*>&) (/usr/bin/swift-frontend+0x2bfee7e)
#11 0x000059792d7c1838 getIntroducedConformances(swift::NominalTypeDecl*, swift::MacroRole, swift::MacroDecl*, llvm::SmallVectorImpl<swift::ProtocolDecl*>*) TypeCheckMacros.cpp:0:0
#12 0x000059792d7c15ac swift::expandMembers(swift::CustomAttr*, swift::MacroDecl*, swift::Decl*) (/usr/bin/swift-frontend+0x22165ac)
#13 0x000059792d7d088b void llvm::function_ref<void (swift::CustomAttr*, swift::MacroDecl*)>::callback_fn<swift::ExpandSynthesizedMemberMacroRequest::evaluate(swift::Evaluator&, swift::Decl*) const::$_17>(long, swift::CustomAttr*, swift::MacroDecl*) TypeCheckMacros.cpp:0:0
#14 0x000059792de2c319 swift::Decl::forEachAttachedMacro(swift::MacroRole, llvm::function_ref<void (swift::CustomAttr*, swift::MacroDecl*)>) const (/usr/bin/swift-frontend+0x2881319)
#15 0x000059792d7be0a6 swift::ExpandSynthesizedMemberMacroRequest::evaluate(swift::Evaluator&, swift::Decl*) const (/usr/bin/swift-frontend+0x22130a6)
#16 0x000059792d73f92a swift::ExpandSynthesizedMemberMacroRequest::OutputType swift::Evaluator::getResultUncached<swift::ExpandSynthesizedMemberMacroRequest, swift::ExpandSynthesizedMemberMacroRequest::OutputType swift::evaluateOrDefault<swift::ExpandSynthesizedMemberMacroRequest>(swift::Evaluator&, swift::ExpandSynthesizedMemberMacroRequest, swift::ExpandSynthesizedMemberMacroRequest::OutputType)::'lambda'()>(swift::ExpandSynthesizedMemberMacroRequest const&, swift::ExpandSynthesizedMemberMacroRequest::OutputType swift::evaluateOrDefault<swift::ExpandSynthesizedMemberMacroRequest>(swift::Evaluator&, swift::ExpandSynthesizedMemberMacroRequest, swift::ExpandSynthesizedMemberMacroRequest::OutputType)::'lambda'()) crtstuff.c:0:0
#17 0x000059792d73f6f8 swift::ExpandSynthesizedMemberMacroRequest::OutputType swift::Evaluator::getResultCached<swift::ExpandSynthesizedMemberMacroRequest, swift::ExpandSynthesizedMemberMacroRequest::OutputType swift::evaluateOrDefault<swift::ExpandSynthesizedMemberMacroRequest>(swift::Evaluator&, swift::ExpandSynthesizedMemberMacroRequest, swift::ExpandSynthesizedMemberMacroRequest::OutputType)::'lambda'(), (void*)0>(swift::ExpandSynthesizedMemberMacroRequest const&, swift::ExpandSynthesizedMemberMacroRequest::OutputType swift::evaluateOrDefault<swift::ExpandSynthesizedMemberMacroRequest>(swift::Evaluator&, swift::ExpandSynthesizedMemberMacroRequest, swift::ExpandSynthesizedMemberMacroRequest::OutputType)::'lambda'()) crtstuff.c:0:0
#18 0x000059792d838463 computeLoweredProperties(swift::NominalTypeDecl*, swift::IterableDeclContext*, (anonymous namespace)::LoweredPropertiesReason) TypeCheckStorage.cpp:0:0
#19 0x000059792d837862 swift::StoredPropertiesRequest::evaluate(swift::Evaluator&, swift::NominalTypeDecl*) const (/usr/bin/swift-frontend+0x228c862)
#20 0x000059792de94f2e swift::StoredPropertiesRequest::OutputType swift::Evaluator::getResultUncached<swift::StoredPropertiesRequest, swift::StoredPropertiesRequest::OutputType swift::evaluateOrDefault<swift::StoredPropertiesRequest>(swift::Evaluator&, swift::StoredPropertiesRequest, swift::StoredPropertiesRequest::OutputType)::'lambda'()>(swift::StoredPropertiesRequest const&, swift::StoredPropertiesRequest::OutputType swift::evaluateOrDefault<swift::StoredPropertiesRequest>(swift::Evaluator&, swift::StoredPropertiesRequest, swift::StoredPropertiesRequest::OutputType)::'lambda'()) crtstuff.c:0:0
#21 0x000059792de94cf8 swift::StoredPropertiesRequest::OutputType swift::Evaluator::getResultCached<swift::StoredPropertiesRequest, swift::StoredPropertiesRequest::OutputType swift::evaluateOrDefault<swift::StoredPropertiesRequest>(swift::Evaluator&, swift::StoredPropertiesRequest, swift::StoredPropertiesRequest::OutputType)::'lambda'(), (void*)0>(swift::StoredPropertiesRequest const&, swift::StoredPropertiesRequest::OutputType swift::evaluateOrDefault<swift::StoredPropertiesRequest>(swift::Evaluator&, swift::StoredPropertiesRequest, swift::StoredPropertiesRequest::OutputType)::'lambda'()) crtstuff.c:0:0
#22 0x000059792de4191f swift::NominalTypeDecl::getStoredProperties() const (/usr/bin/swift-frontend+0x289691f)
#23 0x000059792d7757ec (anonymous namespace)::DeclChecker::visitClassDecl(swift::ClassDecl*) TypeCheckDeclPrimary.cpp:0:0
#24 0x000059792d76fce2 (anonymous namespace)::DeclChecker::visit(swift::Decl*) TypeCheckDeclPrimary.cpp:0:0
#25 0x000059792d76fb74 swift::TypeChecker::typeCheckDecl(swift::Decl*) (/usr/bin/swift-frontend+0x21c4b74)
#26 0x000059792d8a84a5 swift::TypeCheckPrimaryFileRequest::evaluate(swift::Evaluator&, swift::SourceFile*) const (/usr/bin/swift-frontend+0x22fd4a5)
#27 0x000059792d8ace6b swift::TypeCheckPrimaryFileRequest::OutputType swift::Evaluator::getResultUncached<swift::TypeCheckPrimaryFileRequest, swift::TypeCheckPrimaryFileRequest::OutputType swift::evaluateOrDefault<swift::TypeCheckPrimaryFileRequest>(swift::Evaluator&, swift::TypeCheckPrimaryFileRequest, swift::TypeCheckPrimaryFileRequest::OutputType)::'lambda'()>(swift::TypeCheckPrimaryFileRequest const&, swift::TypeCheckPrimaryFileRequest::OutputType swift::evaluateOrDefault<swift::TypeCheckPrimaryFileRequest>(swift::Evaluator&, swift::TypeCheckPrimaryFileRequest, swift::TypeCheckPrimaryFileRequest::OutputType)::'lambda'()) crtstuff.c:0:0
#28 0x000059792d8a83d8 swift::performTypeChecking(swift::SourceFile&) (/usr/bin/swift-frontend+0x22fd3d8)
#29 0x000059792c373499 bool llvm::function_ref<bool (swift::SourceFile&)>::callback_fn<swift::CompilerInstance::performSema()::$_10>(long, swift::SourceFile&) Frontend.cpp:0:0
#30 0x000059792c36790e swift::CompilerInstance::forEachFileToTypeCheck(llvm::function_ref<bool (swift::SourceFile&)>) (/usr/bin/swift-frontend+0xdbc90e)
#31 0x000059792c36768b swift::CompilerInstance::performSema() (/usr/bin/swift-frontend+0xdbc68b)
#32 0x000059792bfd1f32 withSemanticAnalysis(swift::CompilerInstance&, swift::FrontendObserver*, llvm::function_ref<bool (swift::CompilerInstance&)>, bool) FrontendTool.cpp:0:0
#33 0x000059792bfbf9a5 performCompile(swift::CompilerInstance&, int&, swift::FrontendObserver*, llvm::ArrayRef<char const*>) FrontendTool.cpp:0:0
#34 0x000059792bfbc62e swift::performFrontend(llvm::ArrayRef<char const*>, char const*, void*, swift::FrontendObserver*) (/usr/bin/swift-frontend+0xa1162e)
#35 0x000059792bce0d21 swift::mainEntry(int, char const**) (/usr/bin/swift-frontend+0x735d21)
#36 0x0000785c8cff01ca (/lib/x86_64-linux-gnu/libc.so.6+0x2a1ca)
#37 0x0000785c8cff028b __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28b)
#38 0x000059792bcdfc15 _start (/usr/bin/swift-frontend+0x734c15)

*** Signal 6: Backtracing from 0x785c8d0ed28d... done ***

*** Program crashed: Aborted at 0x0000785c8d0ed28d ***

Platform: x86_64 Linux (Ubuntu 24.04.4 LTS)

Thread 0 "swift-frontend" crashed:

0  0x0000785c8d0ed28d <unknown> in libc.so.6


Registers:

rax 0x0000000000000000  0
rdx 0x0000000000000006  6
rcx 0x0000785c8d0ed28d  48 3d 01 f0 ff ff 73 01 c3 48 8b 0d 5b bb 0d 00  H=·ðÿÿs·ÃH··[»··
rbx 0x0000000000000006  6
rsi 0x0000000000145eff  1335039
rdi 0x0000000000145eff  1335039
rbp 0x0000000000145eff  1335039
rsp 0x00005979779831a8  3b 38 17 34 79 59 00 00 30 34 98 77 79 59 00 00  ;8·4yY··04·wyY··
 r8 0x0000597977983430  06 00 00 00 00 00 00 00 fa ff ff ff 00 00 00 00  ········úÿÿÿ····
 r9 0x0000597977983430  06 00 00 00 00 00 00 00 fa ff ff ff 00 00 00 00  ········úÿÿÿ····
r10 0x0000597977983430  06 00 00 00 00 00 00 00 fa ff ff ff 00 00 00 00  ········úÿÿÿ····
r11 0x0000000000000246  582
r12 0x0000000000000006  6
r13 0x000000000000000b  11
r14 0x0000000000000000  0
r15 0x0000597977983248  ff ff ff 7f fe ff ff ff 00 00 00 00 00 00 00 00  ÿÿÿ·þÿÿÿ········
rip 0x0000785c8d0ed28d  48 3d 01 f0 ff ff 73 01 c3 48 8b 0d 5b bb 0d 00  H=·ðÿÿs·ÃH··[»··

rflags 0x0000000000000246  ZF PF

cs 0x0033  fs 0x0000  gs 0x0000


Images (29 omitted):

0x0000785c8cfc6000–0x0000785c8d175d39 8e9fd827446c24067541ac5390e6f527fb5947bb libc.so.6 /usr/lib/x86_64-linux-gnu/libc.so.6

Backtrace took 0.00s

Aborted (core dumped)
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1:detect_stack_use_after_return=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' swift -frontend -emit-ir -O -sil-verify-all -enable-experimental-feature NonescapableTypes -strict-concurrency=complete "$SCRIPT_DIR/test.swift"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `129ecfa4` | Project seed |
| `b` | `dc95916e` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
