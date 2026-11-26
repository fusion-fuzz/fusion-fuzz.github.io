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
