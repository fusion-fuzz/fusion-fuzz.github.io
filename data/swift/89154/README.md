---
render_with_liquid: false
---

*Fusion-Fuzz Bug Report*

**ID:** `d0a70f40` &nbsp;·&nbsp; **Signature:** `Assertion failed: (std::find(conformsTo.begin(), conformsTo.end(), symbol.getProtocol()) != conformsTo.end()), function getTypeForSymbolRange at InterfaceType.cpp:365.` &nbsp;·&nbsp; **RC:** `139`

The following code:

```swift


// --- Seed A ---
// RUN: %target-typecheck-verify-swift
// RUN: %target-swift-ide-test -print-ast-typechecked -source-filename=%s -disable-objc-attr-requires-foundation-module -define-availability 'SwiftStdlib 5.1:macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0' | %FileCheck %s

struct S<T> {}

public protocol P {
}
extension Int: P {
}

public protocol ProtocolWithDep {
  associatedtype Element
  func getElement() -> Element
}

public class C1 {
}

class Base {}
class Sub : Base {}
class NonSub {}

// Specialize freestanding functions with the correct number of concrete types.
// ----------------------------------------------------------------------------

// CHECK: @_specialize(exported: false, kind: full, where T == Int)
@_specialize(where T == Int)
// CHECK: @_specialize(exported: false, kind: full, where T == S<Int>)
@_specialize(where T == S<Int>)
@_specialize(where T == Int, U == Int) // expected-error{{cannot find type 'U' in scope}},
@_specialize(where T == T1) // expected-error{{cannot find type 'T1' in scope}}
@specialized(where T == T1) // expected-error{{cannot find type 'T1' in scope}}
public func oneGenericParam<T>(_ t: T) -> T {
  return t
}

// CHECK: @_specialize(exported: false, kind: full, where T == Int, U == Int)
@_specialize(where T == Int, U == Int)
@_specialize(where T == Int) // expected-error{{too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)}} expected-note{{missing constraint for 'U' in '_specialize' attribute}}
public func twoGenericParams<T, U>(_ t: T, u: U) -> (T, U) {
  return (t, u)
}

@_specialize(where T == Int) // expected-error{{trailing 'where' clause in '_specialize' attribute of non-generic function 'nonGenericParam(x:)'}}
func nonGenericParam(x: Int) {}

// Specialize contextual types.
// ----------------------------

class G<T> {
  // CHECK: @_specialize(exported: false, kind: full, where T == Int)
  @_specialize(where T == Int)
  @_specialize(where T == T) // expected-error{{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}}
  // expected-note@-1 {{missing constraint for 'T' in '_specialize' attribute}}
  @_specialize(where T == S<T>)
  // expected-error@-1 {{cannot build rewrite system for generic signature; concrete type nesting limit exceeded}}
  // expected-note@-2 {{failed rewrite rule is τ_0_0.[concrete: S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<τ_0_0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>] => τ_0_0}}
  @_specialize(where T == Int, U == Int) // expected-error{{cannot find type 'U' in scope}}

  func noGenericParams() {}

  @specialized(where T == Int)
  @specialized(where T == T) // expected-error{{too few generic parameters are specified in 'specialized' attribute (got 0, but expected 1)}}
  // expected-note@-1 {{missing constraint for 'T' in 'specialized' attribute}}
  func noGenericParamsPublic() {}

  // CHECK: @_specialize(exported: false, kind: full, where T == Int, U == Float)
  @_specialize(where T == Int, U == Float)
  // CHECK: @_specialize(exported: false, kind: full, where T == Int, U == S<Int>)
  @_specialize(where T == Int, U == S<Int>)
  @_specialize(where T == Int) // expected-error{{too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)}} expected-note {{missing constraint for 'U' in '_specialize' attribute}}
  func oneGenericParam<U>(_ t: T, u: U) -> (U, T) {
    return (u, t)
  }
  @specialized(where T == Int) // expected-error{{too few generic parameters are specified in 'specialized' attribute (got 1, but expected 2)}} expected-note {{missing constraint for 'U' in 'specialized' attribute}}
  func oneGenericParamPublic<U>(_ t: T, u: U) -> (U, T) {
    return (u, t)
  }}

// Specialize with requirements.
// -----------------------------

protocol Thing {}

struct AThing : Thing {}

// CHECK: @_specialize(exported: false, kind: full, where T == AThing)
@_specialize(where T == AThing)
@_specialize(where T == Int) // expected-error{{no type for 'T' can satisfy both 'T == Int' and 'T : Thing'}}

func oneRequirement<T : Thing>(_ t: T) {}

protocol HasElt {
  associatedtype Element
}
struct IntElement : HasElt {
  typealias Element = Int
}
struct FloatElement : HasElt {
  typealias Element = Float
}
@_specialize(where T == FloatElement)
@_specialize(where T == IntElement) // expected-error{{generic signature requires types 'IntElement.Element' (aka 'Int') and 'Float' to be the same}}
func sameTypeRequirement<T : HasElt>(_ t: T) where T.Element == Float {}

@specialized(where T == FloatElement)
@specialized(where T == IntElement) // expected-error{{generic signature requires types 'IntElement.Element' (aka 'Int') and 'Float' to be the same}}
func sameTypeRequirementPublic<T : HasElt>(_ t: T) where T.Element == Float {}

@_specialize(where T == Sub)
@_specialize(where T == NonSub) // expected-error{{no type for 'T' can satisfy both 'T : NonSub' and 'T : Base'}}
@specialized(where T == Sub)
@specialized(where T == NonSub) // expected-error{{no type for 'T' can satisfy both 'T : NonSub' and 'T : Base'}}
func superTypeRequirement<T : Base>(_ t: T) {}

@_specialize(where X:_Trivial(8), Y == Int) // expected-error{{trailing 'where' clause in '_specialize' attribute of non-generic function 'requirementOnNonGenericFunction(x:y:)'}}
public func requirementOnNonGenericFunction(x: Int, y: Int) {
}

@_specialize(where Y == Int) // expected-error{{too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)}} expected-note{{missing constraint for 'X' in '_specialize' attribute}}
@specialized(where Y == Int) // expected-error{{too few generic parameters are specified in 'specialized' attribute (got 1, but expected 2)}} expected-note{{missing constraint for 'X' in 'specialized' attribute}}
public func missingRequirement<X:P, Y>(x: X, y: Y) {
}

@_specialize(where) // expected-error{{expected type}}
@_specialize() // expected-error{{expected a parameter label or a where clause in '_specialize' attribute}} expected-error{{expected declaration}}
@specialized() // expected-error{{expected a where clause in 'specialized' attribute}} expected-error{{expected declaration}}
public func funcWithEmptySpecializeAttr<X: P, Y>(x: X, y: Y) {
}


@_specialize(where X:_Trivial(8), Y:_Trivial(32), Z == Int) // expected-error{{cannot find type 'Z' in scope}}
@_specialize(where X:_Trivial(8), Y:_Trivial(32, 4))
@_specialize(where X == Int) // expected-error{{too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)}} expected-note{{missing constraint for 'Y' in '_specialize' attribute}}
@_specialize(where Y:_Trivial(32)) // expected-error {{too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)}} expected-note{{missing constraint for 'X' in '_specialize' attribute}}
@_specialize(where Y: P) // expected-error{{only same-type and layout requirements are supported by '_specialize' attribute}}
@_specialize(where Y: MyClass) // expected-error{{cannot find type 'MyClass' in scope}} expected-error{{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 2)}} expected-note{{missing constraint for 'X' in '_specialize' attribute}} expected-note{{missing constraint for 'Y' in '_specialize' attribute}}
@_specialize(where X:_Trivial(8), Y == Int)
@_specialize(where X == Int, Y == Int)
@_specialize(where X == Int, X == Int) // expected-error{{too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)}} expected-note{{missing constraint for 'Y' in '_specialize' attribute}}
@_specialize(where Y:_Trivial(32), X == Float)
@_specialize(where X1 == Int, Y1 == Int) // expected-error{{cannot find type 'X1' in scope}} expected-error{{cannot find type 'Y1' in scope}} expected-error{{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 2)}} expected-note{{missing constraint for 'X' in '_specialize' attribute}} expected-note{{missing constraint for 'Y' in '_specialize' attribute}}
public func funcWithTwoGenericParameters<X, Y>(x: X, y: Y) {
}

@_specialize(where X == Int, Y == Int)
@_specialize(exported: true, where X == Int, Y == Int)
@_specialize(exported: false, where X == Int, Y == Int)
@_specialize(exported: false where X == Int, Y == Int) // expected-error{{missing ',' in '_specialize' attribute}}
@_specialize(exported: yes, where X == Int, Y == Int) // expected-error{{expected a boolean true or false value in '_specialize' attribute}}
@_specialize(exported: , where X == Int, Y == Int) // expected-error{{expected a boolean true or false value in '_specialize' attribute}}

@_specialize(kind: partial, where X == Int, Y == Int)
@_specialize(kind: partial, where X == Int)
@_specialize(kind: full, where X == Int, Y == Int)
@_specialize(kind: any, where X == Int, Y == Int) // expected-error{{expected 'partial' or 'full' as values of the 'kind' parameter in '_specialize' attribute}}
@_specialize(kind: false, where X == Int, Y == Int) // expected-error{{expected 'partial' or 'full' as values of the 'kind' parameter in '_specialize' attribute}}
@_specialize(kind: partial where X == Int, Y == Int) // expected-error{{missing ',' in '_specialize' attribute}}
@_specialize(kind: partial, where X == Int, Y == Int)
@_specialize(kind: , where X == Int, Y == Int)

@_specialize(exported: true, kind: partial, where X == Int, Y == Int)
@_specialize(exported: true, exported: true, where X == Int, Y == Int) // expected-error{{parameter 'exported' was already defined in '_specialize' attribute}}
@_specialize(kind: partial, exported: true, where X == Int, Y == Int)
@_specialize(kind: partial, kind: partial, where X == Int, Y == Int) // expected-error{{parameter 'kind' was already defined in '_specialize' attribute}}

@_specialize(where X == Int, Y == Int, exported: true, kind: partial) // expected-error{{expected type}} expected-error{{cannot find type 'exported' in scope}} expected-error{{cannot find type 'kind' in scope}} expected-error{{cannot find type 'partial' in scope}}
public func anotherFuncWithTwoGenericParameters<X: P, Y>(x: X, y: Y) {
}

@_specialize(where T: P) // expected-error{{only same-type and layout requirements are supported by '_specialize' attribute}}
@specialized(where T: P) // expected-error{{only same-type are supported by 'specialized' attribute}}
@_specialize(where T: Int) // expected-error{{type 'T' constrained to non-protocol, non-class type 'Int'}} expected-note {{use 'T == Int' to require 'T' to be 'Int'}}
// expected-error@-1 {{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}}
// expected-note@-2 {{missing constraint for 'T' in '_specialize' attribute}}

@_specialize(where T: S1) // expected-error{{type 'T' constrained to non-protocol, non-class type 'S1'}} expected-note {{use 'T == S1' to require 'T' to be 'S1'}}
// expected-error@-1 {{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}}
// expected-note@-2 {{missing constraint for 'T' in '_specialize' attribute}}
@_specialize(where T: C1) // expected-error{{only same-type and layout requirements are supported by '_specialize' attribute}}
@_specialize(where Int: P) // expected-error{{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}} expected-note{{missing constraint for 'T' in '_specialize' attribute}}
@specialized(where T: Int) // expected-error{{type 'T' constrained to non-protocol, non-class type 'Int'}} expected-note {{use 'T == Int' to require 'T' to be 'Int'}}
// expected-error@-1 {{too few generic parameters are specified in 'specialized' attribute (got 0, but expected 1)}}
// expected-note@-2 {{missing constraint for 'T' in 'specialized' attribute}}
func funcWithForbiddenSpecializeRequirement<T>(_ t: T) {
}

@_specialize(where T: _Trivial(32), T: _Trivial(64), T: _Trivial, T: _RefCountedObject)
// expected-error@-1{{no type for 'T' can satisfy both 'T : _RefCountedObject' and 'T : _Trivial(64)'}}
// expected-error@-2{{no type for 'T' can satisfy both 'T : _Trivial(64)' and 'T : _Trivial(32)'}}
@_specialize(where T: _Trivial, T: _Trivial(64))
@_specialize(where T: _RefCountedObject, T: _NativeRefCountedObject)
@_specialize(where Array<T> == Int) // expected-error{{generic signature requires types 'Array<T>' and 'Int' to be the same}}
// expected-error@-1 {{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}}
// expected-note@-2 {{missing constraint for 'T' in '_specialize' attribute}}
@_specialize(where T.Element == Int) // expected-error{{only requirements on generic parameters are supported by '_specialize' attribute}}
public func funcWithComplexSpecializeRequirements<T: ProtocolWithDep>(t: T) -> Int {
  return 55555
}

public protocol Proto: class {
}

@_specialize(where T: _RefCountedObject)
// expected-error@-1 {{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}}
// expected-note@-2 {{missing constraint for 'T' in '_specialize' attribute}}
@_specialize(where T: _Trivial)
// expected-error@-1{{no type for 'T' can satisfy both 'T : _NativeClass' and 'T : _Trivial'}}
// expected-error@-2 {{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}}
// expected-note@-3 {{missing constraint for 'T' in '_specialize' attribute}}
@_specialize(where T: _Trivial(64))
// expected-error@-1{{no type for 'T' can satisfy both 'T : _NativeClass' and 'T : _Trivial(64)'}}
// expected-error@-2 {{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}}
// expected-note@-3 {{missing constraint for 'T' in '_specialize' attribute}}
public func funcWithABaseClassRequirement<T>(t: T) -> Int where T: C1 {
  return 44444
}

public struct S1 {
}

@_specialize(exported: false, where T == Int64)
public func simpleGeneric<T>(t: T) -> T {
  return t
}


@_specialize(exported: true, where S: _Trivial(64))
// Check that any bitsize size is OK, not only powers of 8.
@_specialize(where S: _Trivial(60))
@_specialize(exported: true, where S: _RefCountedObject)
@inline(never)
public func copyValue<S>(_ t: S, s: inout S) -> Int64 where S: P{
  return 1
}

@_specialize(exported: true, where S: _Trivial)
@_specialize(exported: true, where S: _Trivial(64))
@_specialize(exported: true, where S: _Trivial(32))
@_specialize(exported: true, where S: _RefCountedObject)
@_specialize(exported: true, where S: _NativeRefCountedObject)
@_specialize(exported: true, where S: _Class)
@_specialize(exported: true, where S: _NativeClass)
@inline(never)
public func copyValueAndReturn<S>(_ t: S, s: inout S) -> S where S: P{
  return s
}

struct OuterStruct<S> {
  struct MyStruct<T> {
    @_specialize(where T == Int, U == Float) // expected-error{{too few generic parameters are specified in '_specialize' attribute (got 2, but expected 3)}} expected-note{{missing constraint for 'S' in '_specialize' attribute}}
    @specialized(where T == Int, U == Float) // expected-error{{too few generic parameters are specified in 'specialized' attribute (got 2, but expected 3)}} expected-note{{missing constraint for 'S' in 'specialized' attribute}}
    public func foo<U>(u : U) {
    }

    @_specialize(where T == Int, U == Float, S == Int)
    @specialized(where T == Int, U == Float, S == Int)
    public func bar<U>(u : U) {
    }
  }
}

// Check _TrivialAtMostN constraints.
@_specialize(exported: true, where S: _TrivialAtMost(64))
@inline(never)
public func copy2<S>(_ t: S, s: inout S) -> S where S: P{
  return s
}

// Check missing alignment.
@_specialize(where S: _Trivial(64, )) // expected-error{{expected non-negative alignment to be specified in layout constraint}}
// Check non-numeric size.
@_specialize(where S: _Trivial(Int)) // expected-error{{expected non-negative size to be specified in layout constraint}}
// Check non-numeric alignment.
@_specialize(where S: _Trivial(64, X)) // expected-error{{expected non-negative alignment to be specified in layout constraint}}
@inline(never)
public func copy3<S>(_ s: S) -> S {
  return s
}

public func funcWithWhereClause<T>(t: T) where T:P, T: _Trivial(64) { // expected-error{{layout constraints are only allowed inside '_specialize' attributes}}
}

// rdar://problem/29333056
public protocol P1 {
  associatedtype DP1
  associatedtype DP11
}

public protocol P2 {
  associatedtype DP2 : P1
}

public struct H<T> {
}

public struct MyStruct3 : P1 {
  public typealias DP1 = Int
  public typealias DP11 = H<Int>
}

public struct MyStruct4 : P2 {
  public typealias DP2 = MyStruct3
}

@_specialize(where T==MyStruct4)
public func foo<T: P2>(_ t: T) where T.DP2.DP11 == H<T.DP2.DP1> {
}

public func targetFun<T>(_ t: T) {}

@_specialize(exported: true, target: targetFun(_:), where T == Int)
public func specifyTargetFunc<T>(_ t: T) {
}

public struct Container {
  public func targetFun<T>(_ t: T) {}
}

extension Container {
  @_specialize(exported: true, target: targetFun(_:), where T == Int)
  public func specifyTargetFunc<T>(_ t: T) { }

  @_specialize(exported: true, target: targetFun2(_:), where T == Int) // expected-error{{target function 'targetFun2' could not be found}}
  public func specifyTargetFunc2<T>(_ t: T) { }
}

// Make sure we don't complain that 'E' is not explicitly specialized here.
// E becomes concrete via the combination of 'S == Set<String>' and
// 'E == S.Element'.
@_specialize(where S == Set<String>)
@specialized(where S == Set<String>)
public func takesSequenceAndElement<S, E>(_: S, _: E)
  where S : Sequence, E == S.Element {}

// CHECK: @_specialize(exported: true, kind: full, availability: macOS 11, iOS 13, *; where T == Int)
// CHECK: public func testAvailability<T>(_ t: T)
@_specialize(exported: true, availability: macOS 11, iOS 13, *; where T == Int)
public func testAvailability<T>(_ t: T) {}

// CHECK: @_specialize(exported: true, kind: full, availability: macOS, introduced: 11; where T == Int)
// CHECK: public func testAvailability2<T>(_ t: T)
@_specialize(exported: true, availability: macOS 11, *; where T == Int)
public func testAvailability2<T>(_ t: T) {}

// CHECK: @_specialize(exported: true, kind: full, availability: macOS, introduced: 11; where T == Int)
// CHECK: public func testAvailability3<T>(_ t: T)
@_specialize(exported: true, availability: macOS, introduced: 11; where T == Int)
public func testAvailability3<T>(_ t: T) {}

// CHECK: @_specialize(exported: true, kind: full, availability: macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *; where T == Int)
// CHECK: public func testAvailability4<T>(_ t: T)
@_specialize(exported: true, availability: SwiftStdlib 5.1, *; where T == Int)
public func testAvailability4<T>(_ t: T) {}

public struct ExpectedElement {
  @inline(never)
  public func hello() {}
}

public struct ConformerElement {}

public struct Conformer : ProtocolWithDep {
  public typealias Element = ConformerElement
  public func getElement() -> ConformerElement { return ConformerElement() }
}

@inline(never)
@_specialize(where T == Conformer) // expected-error{{generic signature requires types 'Conformer.Element' (aka 'ConformerElement') and 'ExpectedElement' to be the same}}
public func foo<T : ProtocolWithDep>(_ t: T) where T.Element == ExpectedElement {
  t.getElement().hello()
}

@_specialize(where T == Conformer) // expected-error{{generic signature requires types 'Conformer.Element' (aka 'ConformerElement') and 'ExpectedElement' to be the same}}
@specialized(where T == Conformer) // expected-error{{generic signature requires types 'Conformer.Element' (aka 'ConformerElement') and 'ExpectedElement' to be the same}}
public func bar<T : ProtocolWithDep>(_ t: T) where T.Element == ExpectedElement {
  foo(t)
}

// CHECK: @specialized(where T == Int)
@specialized(where T == Int)
// CHECK: @specialized(where T == S<Int>)
@specialized(where T == S<Int>)
public func oneGenericParam2Good<T>(_ t: T) -> T {
    return t
}

@specialized(where T == Int, U == Int) // expected-error{{cannot find type 'U' in scope}},
@specialized(where T == T1) // expected-error{{cannot find type 'T1' in scope}},
@specialized(where T : _Trivial) // expected-error{{layout constraints are only allowed inside '_specialize' attributes}} expected-error{{empty 'where' clause in 'specialized' attribute}}
public func oneGenericParam2<T>(_ t: T) -> T {
  return t
}

// CHECK: @specialized(where T == Int, U == Int)
@specialized(where T == Int, U == Int)
@specialized(where T == Int) // expected-error{{too few generic parameters are specified in 'specialized' attribute (got 1, but expected 2)}} expected-note{{missing constraint for 'U' in 'specialized' attribute}}
public func twoGenericParams2<T, U>(_ t: T, u: U) -> (T, U) {
  return (t, u)
}

@specialized(where T == Int) // expected-error{{trailing 'where' clause in 'specialized' attribute of non-generic function 'nonGenericParam2(x:)'}}
func nonGenericParam2(x: Int) {}

@_specialize(where T == Int)
@_specialize(where T == Int)
func genericParamDuplicate<T>(t: T) {}

struct GG<T: P> {}

// expected-error@+1 {{type 'String' does not conform to protocol 'P'}}
@_specialize(where T == GG<String>)
func genericArgInvalidSpecialize<T>(t: T) {}

// --- Seed B ---
// REQUIRES: swift_swift_parser

// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend %s -swift-version 5 -module-name main -disable-availability-checking -typecheck -plugin-path %swift-plugin-dir -dump-macro-expansions > %t/expansions-dump.txt 2>&1
// RUN: %FileCheck %s < %t/expansions-dump.txt

@DebugDescription
struct MyStruct1: CustomStringConvertible {
  var description: String { "thirty" }
}
// CHECK: static let _lldb_summary: (
// CHECK:   {{UInt8(, UInt8)*}}
// CHECK: ) =
// CHECK: (
// CHECK:     /* version */ 1,
// CHECK:     /* record size */ 24,
// CHECK:     /* "main.MyStruct1" */ 15, 109, 97, 105, 110, 46, 77, 121, 83, 116, 114, 117, 99, 116, 49, 0,
// CHECK:     /* "thirty" */ 7, 116, 104, 105, 114, 116, 121, 0
// CHECK: )

@DebugDescription
struct MyStruct2: CustomDebugStringConvertible {
  var description: String { "thirty" }
  var debugDescription: String { "eleven" }
}
// CHECK: static let _lldb_summary: (
// CHECK:   {{UInt8(, UInt8)*}}
// CHECK: ) =
// CHECK: (
// CHECK:     /* version */ 1,
// CHECK:     /* record size */ 24,
// CHECK:     /* "main.MyStruct2" */ 15, 109, 97, 105, 110, 46, 77, 121, 83, 116, 114, 117, 99, 116, 50, 0,
// CHECK:     /* "eleven" */ 7, 101, 108, 101, 118, 101, 110, 0
// CHECK: )

@DebugDescription
struct MyStruct3: CustomDebugStringConvertible {
  var description: String { "thirty" }
  var debugDescription: String { "eleven" }
  var lldbDescription: String { "two" }
}
// CHECK: static let _lldb_summary: (
// CHECK:   {{UInt8(, UInt8)*}}
// CHECK: ) =
// CHECK: (
// CHECK:     /* version */ 1,
// CHECK:     /* record size */ 21,
// CHECK:     /* "main.MyStruct3" */ 15, 109, 97, 105, 110, 46, 77, 121, 83, 116, 114, 117, 99, 116, 51, 0,
// CHECK:     /* "two" */ 4, 116, 119, 111, 0
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
/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:128:19: error: expected type
126 | }
127 | 
128 | @_specialize(where) // expected-error{{expected type}}
    |                   `- error: expected type
129 | @_specialize() // expected-error{{expected a parameter label or a where clause in '_specialize' attribute}} expected-error{{expected declaration}}
130 | @specialized() // expected-error{{expected a where clause in 'specialized' attribute}} expected-error{{expected declaration}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:129:14: error: expected a parameter label or a where clause in '_specialize' attribute
127 | 
128 | @_specialize(where) // expected-error{{expected type}}
129 | @_specialize() // expected-error{{expected a parameter label or a where clause in '_specialize' attribute}} expected-error{{expected declaration}}
    |              `- error: expected a parameter label or a where clause in '_specialize' attribute
130 | @specialized() // expected-error{{expected a where clause in 'specialized' attribute}} expected-error{{expected declaration}}
131 | public func funcWithEmptySpecializeAttr<X: P, Y>(x: X, y: Y) {

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:129:14: error: expected declaration
127 | 
128 | @_specialize(where) // expected-error{{expected type}}
129 | @_specialize() // expected-error{{expected a parameter label or a where clause in '_specialize' attribute}} expected-error{{expected declaration}}
    |              `- error: expected declaration
130 | @specialized() // expected-error{{expected a where clause in 'specialized' attribute}} expected-error{{expected declaration}}
131 | public func funcWithEmptySpecializeAttr<X: P, Y>(x: X, y: Y) {

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:130:14: error: expected a where clause in 'specialized' attribute
128 | @_specialize(where) // expected-error{{expected type}}
129 | @_specialize() // expected-error{{expected a parameter label or a where clause in '_specialize' attribute}} expected-error{{expected declaration}}
130 | @specialized() // expected-error{{expected a where clause in 'specialized' attribute}} expected-error{{expected declaration}}
    |              `- error: expected a where clause in 'specialized' attribute
131 | public func funcWithEmptySpecializeAttr<X: P, Y>(x: X, y: Y) {
132 | }

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:130:14: error: expected declaration
128 | @_specialize(where) // expected-error{{expected type}}
129 | @_specialize() // expected-error{{expected a parameter label or a where clause in '_specialize' attribute}} expected-error{{expected declaration}}
130 | @specialized() // expected-error{{expected a where clause in 'specialized' attribute}} expected-error{{expected declaration}}
    |              `- error: expected declaration
131 | public func funcWithEmptySpecializeAttr<X: P, Y>(x: X, y: Y) {
132 | }

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:152:30: error: missing ',' in '_specialize' attribute
150 | @_specialize(exported: true, where X == Int, Y == Int)
151 | @_specialize(exported: false, where X == Int, Y == Int)
152 | @_specialize(exported: false where X == Int, Y == Int) // expected-error{{missing ',' in '_specialize' attribute}}
    |                              `- error: missing ',' in '_specialize' attribute
153 | @_specialize(exported: yes, where X == Int, Y == Int) // expected-error{{expected a boolean true or false value in '_specialize' attribute}}
154 | @_specialize(exported: , where X == Int, Y == Int) // expected-error{{expected a boolean true or false value in '_specialize' attribute}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:153:24: error: expected a boolean true or false value in '_specialize' attribute
151 | @_specialize(exported: false, where X == Int, Y == Int)
152 | @_specialize(exported: false where X == Int, Y == Int) // expected-error{{missing ',' in '_specialize' attribute}}
153 | @_specialize(exported: yes, where X == Int, Y == Int) // expected-error{{expected a boolean true or false value in '_specialize' attribute}}
    |                        `- error: expected a boolean true or false value in '_specialize' attribute
154 | @_specialize(exported: , where X == Int, Y == Int) // expected-error{{expected a boolean true or false value in '_specialize' attribute}}
155 | 

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:154:24: error: expected a boolean true or false value in '_specialize' attribute
152 | @_specialize(exported: false where X == Int, Y == Int) // expected-error{{missing ',' in '_specialize' attribute}}
153 | @_specialize(exported: yes, where X == Int, Y == Int) // expected-error{{expected a boolean true or false value in '_specialize' attribute}}
154 | @_specialize(exported: , where X == Int, Y == Int) // expected-error{{expected a boolean true or false value in '_specialize' attribute}}
    |                        `- error: expected a boolean true or false value in '_specialize' attribute
155 | 
156 | @_specialize(kind: partial, where X == Int, Y == Int)

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:159:20: error: expected 'partial' or 'full' as values of the 'kind' parameter in '_specialize' attribute
157 | @_specialize(kind: partial, where X == Int)
158 | @_specialize(kind: full, where X == Int, Y == Int)
159 | @_specialize(kind: any, where X == Int, Y == Int) // expected-error{{expected 'partial' or 'full' as values of the 'kind' parameter in '_specialize' attribute}}
    |                    `- error: expected 'partial' or 'full' as values of the 'kind' parameter in '_specialize' attribute
160 | @_specialize(kind: false, where X == Int, Y == Int) // expected-error{{expected 'partial' or 'full' as values of the 'kind' parameter in '_specialize' attribute}}
161 | @_specialize(kind: partial where X == Int, Y == Int) // expected-error{{missing ',' in '_specialize' attribute}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:160:20: error: expected 'partial' or 'full' as values of the 'kind' parameter in '_specialize' attribute
158 | @_specialize(kind: full, where X == Int, Y == Int)
159 | @_specialize(kind: any, where X == Int, Y == Int) // expected-error{{expected 'partial' or 'full' as values of the 'kind' parameter in '_specialize' attribute}}
160 | @_specialize(kind: false, where X == Int, Y == Int) // expected-error{{expected 'partial' or 'full' as values of the 'kind' parameter in '_specialize' attribute}}
    |                    `- error: expected 'partial' or 'full' as values of the 'kind' parameter in '_specialize' attribute
161 | @_specialize(kind: partial where X == Int, Y == Int) // expected-error{{missing ',' in '_specialize' attribute}}
162 | @_specialize(kind: partial, where X == Int, Y == Int)

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:161:28: error: missing ',' in '_specialize' attribute
159 | @_specialize(kind: any, where X == Int, Y == Int) // expected-error{{expected 'partial' or 'full' as values of the 'kind' parameter in '_specialize' attribute}}
160 | @_specialize(kind: false, where X == Int, Y == Int) // expected-error{{expected 'partial' or 'full' as values of the 'kind' parameter in '_specialize' attribute}}
161 | @_specialize(kind: partial where X == Int, Y == Int) // expected-error{{missing ',' in '_specialize' attribute}}
    |                            `- error: missing ',' in '_specialize' attribute
162 | @_specialize(kind: partial, where X == Int, Y == Int)
163 | @_specialize(kind: , where X == Int, Y == Int)

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:166:40: error: parameter 'exported' was already defined in '_specialize' attribute
164 | 
165 | @_specialize(exported: true, kind: partial, where X == Int, Y == Int)
166 | @_specialize(exported: true, exported: true, where X == Int, Y == Int) // expected-error{{parameter 'exported' was already defined in '_specialize' attribute}}
    |                                        `- error: parameter 'exported' was already defined in '_specialize' attribute
167 | @_specialize(kind: partial, exported: true, where X == Int, Y == Int)
168 | @_specialize(kind: partial, kind: partial, where X == Int, Y == Int) // expected-error{{parameter 'kind' was already defined in '_specialize' attribute}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:168:35: error: parameter 'kind' was already defined in '_specialize' attribute
166 | @_specialize(exported: true, exported: true, where X == Int, Y == Int) // expected-error{{parameter 'exported' was already defined in '_specialize' attribute}}
167 | @_specialize(kind: partial, exported: true, where X == Int, Y == Int)
168 | @_specialize(kind: partial, kind: partial, where X == Int, Y == Int) // expected-error{{parameter 'kind' was already defined in '_specialize' attribute}}
    |                                   `- error: parameter 'kind' was already defined in '_specialize' attribute
169 | 
170 | @_specialize(where X == Int, Y == Int, exported: true, kind: partial) // expected-error{{expected type}} expected-error{{cannot find type 'exported' in scope}} expected-error{{cannot find type 'kind' in scope}} expected-error{{cannot find type 'partial' in scope}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:170:50: error: expected type
168 | @_specialize(kind: partial, kind: partial, where X == Int, Y == Int) // expected-error{{parameter 'kind' was already defined in '_specialize' attribute}}
169 | 
170 | @_specialize(where X == Int, Y == Int, exported: true, kind: partial) // expected-error{{expected type}} expected-error{{cannot find type 'exported' in scope}} expected-error{{cannot find type 'kind' in scope}} expected-error{{cannot find type 'partial' in scope}}
    |                                                  `- error: expected type
171 | public func anotherFuncWithTwoGenericParameters<X: P, Y>(x: X, y: Y) {
172 | }

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:274:36: error: expected non-negative alignment to be specified in layout constraint
272 | 
273 | // Check missing alignment.
274 | @_specialize(where S: _Trivial(64, )) // expected-error{{expected non-negative alignment to be specified in layout constraint}}
    |                                    `- error: expected non-negative alignment to be specified in layout constraint
275 | // Check non-numeric size.
276 | @_specialize(where S: _Trivial(Int)) // expected-error{{expected non-negative size to be specified in layout constraint}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:276:32: error: expected non-negative size to be specified in layout constraint
274 | @_specialize(where S: _Trivial(64, )) // expected-error{{expected non-negative alignment to be specified in layout constraint}}
275 | // Check non-numeric size.
276 | @_specialize(where S: _Trivial(Int)) // expected-error{{expected non-negative size to be specified in layout constraint}}
    |                                `- error: expected non-negative size to be specified in layout constraint
277 | // Check non-numeric alignment.
278 | @_specialize(where S: _Trivial(64, X)) // expected-error{{expected non-negative alignment to be specified in layout constraint}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:278:36: error: expected non-negative alignment to be specified in layout constraint
276 | @_specialize(where S: _Trivial(Int)) // expected-error{{expected non-negative size to be specified in layout constraint}}
277 | // Check non-numeric alignment.
278 | @_specialize(where S: _Trivial(64, X)) // expected-error{{expected non-negative alignment to be specified in layout constraint}}
    |                                    `- error: expected non-negative alignment to be specified in layout constraint
279 | @inline(never)
280 | public func copy3<S>(_ s: S) -> S {

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:284:56: error: layout constraints are only allowed inside '_specialize' attributes
282 | }
283 | 
284 | public func funcWithWhereClause<T>(t: T) where T:P, T: _Trivial(64) { // expected-error{{layout constraints are only allowed inside '_specialize' attributes}}
    |                                                        `- error: layout constraints are only allowed inside '_specialize' attributes
285 | }
286 | 

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:393:24: error: layout constraints are only allowed inside '_specialize' attributes
391 | @specialized(where T == Int, U == Int) // expected-error{{cannot find type 'U' in scope}},
392 | @specialized(where T == T1) // expected-error{{cannot find type 'T1' in scope}},
393 | @specialized(where T : _Trivial) // expected-error{{layout constraints are only allowed inside '_specialize' attributes}} expected-error{{empty 'where' clause in 'specialized' attribute}}
    |                        `- error: layout constraints are only allowed inside '_specialize' attributes
394 | public func oneGenericParam2<T>(_ t: T) -> T {
395 |   return t

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:35:25: error: cannot find type 'T1' in scope
 33 | @_specialize(where T == Int, U == Int) // expected-error{{cannot find type 'U' in scope}},
 34 | @_specialize(where T == T1) // expected-error{{cannot find type 'T1' in scope}}
 35 | @specialized(where T == T1) // expected-error{{cannot find type 'T1' in scope}}
    |                         `- error: cannot find type 'T1' in scope
 36 | public func oneGenericParam<T>(_ t: T) -> T {
 37 |   return t

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:34:25: error: cannot find type 'T1' in scope
 32 | @_specialize(where T == S<Int>)
 33 | @_specialize(where T == Int, U == Int) // expected-error{{cannot find type 'U' in scope}},
 34 | @_specialize(where T == T1) // expected-error{{cannot find type 'T1' in scope}}
    |                         `- error: cannot find type 'T1' in scope
 35 | @specialized(where T == T1) // expected-error{{cannot find type 'T1' in scope}}
 36 | public func oneGenericParam<T>(_ t: T) -> T {

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:33:30: error: cannot find type 'U' in scope
 31 | // CHECK: @_specialize(exported: false, kind: full, where T == S<Int>)
 32 | @_specialize(where T == S<Int>)
 33 | @_specialize(where T == Int, U == Int) // expected-error{{cannot find type 'U' in scope}},
    |                              `- error: cannot find type 'U' in scope
 34 | @_specialize(where T == T1) // expected-error{{cannot find type 'T1' in scope}}
 35 | @specialized(where T == T1) // expected-error{{cannot find type 'T1' in scope}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:42:2: error: too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)
 40 | // CHECK: @_specialize(exported: false, kind: full, where T == Int, U == Int)
 41 | @_specialize(where T == Int, U == Int)
 42 | @_specialize(where T == Int) // expected-error{{too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)}} expected-note{{missing constraint for 'U' in '_specialize' attribute}}
    |  |- error: too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)
    |  `- note: missing constraint for 'U' in '_specialize' attribute
 43 | public func twoGenericParams<T, U>(_ t: T, u: U) -> (T, U) {
 44 |   return (t, u)

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:47:2: error: trailing 'where' clause in '_specialize' attribute of non-generic function 'nonGenericParam(x:)'
 45 | }
 46 | 
 47 | @_specialize(where T == Int) // expected-error{{trailing 'where' clause in '_specialize' attribute of non-generic function 'nonGenericParam(x:)'}}
    |  `- error: trailing 'where' clause in '_specialize' attribute of non-generic function 'nonGenericParam(x:)'
 48 | func nonGenericParam(x: Int) {}
 49 | 

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:61:32: error: cannot find type 'U' in scope
 59 |   // expected-error@-1 {{cannot build rewrite system for generic signature; concrete type nesting limit exceeded}}
 60 |   // expected-note@-2 {{failed rewrite rule is τ_0_0.[concrete: S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<τ_0_0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>] => τ_0_0}}
 61 |   @_specialize(where T == Int, U == Int) // expected-error{{cannot find type 'U' in scope}}
    |                                `- error: cannot find type 'U' in scope
 62 | 
 63 |   func noGenericParams() {}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:58:4: error: cannot build rewrite system for generic signature; concrete type nesting limit exceeded
 56 |   @_specialize(where T == T) // expected-error{{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}}
 57 |   // expected-note@-1 {{missing constraint for 'T' in '_specialize' attribute}}
 58 |   @_specialize(where T == S<T>)
    |    |- error: cannot build rewrite system for generic signature; concrete type nesting limit exceeded
    |    `- note: failed rewrite rule is τ_0_0.[concrete: S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<τ_0_0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>] => τ_0_0
 59 |   // expected-error@-1 {{cannot build rewrite system for generic signature; concrete type nesting limit exceeded}}
 60 |   // expected-note@-2 {{failed rewrite rule is τ_0_0.[concrete: S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<S<τ_0_0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>] => τ_0_0}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:56:4: error: too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)
 54 |   // CHECK: @_specialize(exported: false, kind: full, where T == Int)
 55 |   @_specialize(where T == Int)
 56 |   @_specialize(where T == T) // expected-error{{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}}
    |    |- error: too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)
    |    `- note: missing constraint for 'T' in '_specialize' attribute
 57 |   // expected-note@-1 {{missing constraint for 'T' in '_specialize' attribute}}
 58 |   @_specialize(where T == S<T>)

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:66:4: error: too few generic parameters are specified in 'specialized' attribute (got 0, but expected 1)
 64 | 
 65 |   @specialized(where T == Int)
 66 |   @specialized(where T == T) // expected-error{{too few generic parameters are specified in 'specialized' attribute (got 0, but expected 1)}}
    |    |- error: too few generic parameters are specified in 'specialized' attribute (got 0, but expected 1)
    |    `- note: missing constraint for 'T' in 'specialized' attribute
 67 |   // expected-note@-1 {{missing constraint for 'T' in 'specialized' attribute}}
 68 |   func noGenericParamsPublic() {}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:74:4: error: too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)
 72 |   // CHECK: @_specialize(exported: false, kind: full, where T == Int, U == S<Int>)
 73 |   @_specialize(where T == Int, U == S<Int>)
 74 |   @_specialize(where T == Int) // expected-error{{too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)}} expected-note {{missing constraint for 'U' in '_specialize' attribute}}
    |    |- error: too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)
    |    `- note: missing constraint for 'U' in '_specialize' attribute
 75 |   func oneGenericParam<U>(_ t: T, u: U) -> (U, T) {
 76 |     return (u, t)

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:78:4: error: too few generic parameters are specified in 'specialized' attribute (got 1, but expected 2)
 76 |     return (u, t)
 77 |   }
 78 |   @specialized(where T == Int) // expected-error{{too few generic parameters are specified in 'specialized' attribute (got 1, but expected 2)}} expected-note {{missing constraint for 'U' in 'specialized' attribute}}
    |    |- error: too few generic parameters are specified in 'specialized' attribute (got 1, but expected 2)
    |    `- note: missing constraint for 'U' in 'specialized' attribute
 79 |   func oneGenericParamPublic<U>(_ t: T, u: U) -> (U, T) {
 80 |     return (u, t)

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:92:2: error: no type for 'T' can satisfy both 'T == Int' and 'T : Thing'
 90 | // CHECK: @_specialize(exported: false, kind: full, where T == AThing)
 91 | @_specialize(where T == AThing)
 92 | @_specialize(where T == Int) // expected-error{{no type for 'T' can satisfy both 'T == Int' and 'T : Thing'}}
    |  `- error: no type for 'T' can satisfy both 'T == Int' and 'T : Thing'
 93 | 
 94 | func oneRequirement<T : Thing>(_ t: T) {}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:106:2: error: generic signature requires types 'IntElement.Element' (aka 'Int') and 'Float' to be the same
104 | }
105 | @_specialize(where T == FloatElement)
106 | @_specialize(where T == IntElement) // expected-error{{generic signature requires types 'IntElement.Element' (aka 'Int') and 'Float' to be the same}}
    |  `- error: generic signature requires types 'IntElement.Element' (aka 'Int') and 'Float' to be the same
107 | func sameTypeRequirement<T : HasElt>(_ t: T) where T.Element == Float {}
108 | 

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:110:2: error: generic signature requires types 'IntElement.Element' (aka 'Int') and 'Float' to be the same
108 | 
109 | @specialized(where T == FloatElement)
110 | @specialized(where T == IntElement) // expected-error{{generic signature requires types 'IntElement.Element' (aka 'Int') and 'Float' to be the same}}
    |  `- error: generic signature requires types 'IntElement.Element' (aka 'Int') and 'Float' to be the same
111 | func sameTypeRequirementPublic<T : HasElt>(_ t: T) where T.Element == Float {}
112 | 

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:116:2: error: no type for 'T' can satisfy both 'T : NonSub' and 'T : Base'
114 | @_specialize(where T == NonSub) // expected-error{{no type for 'T' can satisfy both 'T : NonSub' and 'T : Base'}}
115 | @specialized(where T == Sub)
116 | @specialized(where T == NonSub) // expected-error{{no type for 'T' can satisfy both 'T : NonSub' and 'T : Base'}}
    |  `- error: no type for 'T' can satisfy both 'T : NonSub' and 'T : Base'
117 | func superTypeRequirement<T : Base>(_ t: T) {}
118 | 

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:114:2: error: no type for 'T' can satisfy both 'T : NonSub' and 'T : Base'
112 | 
113 | @_specialize(where T == Sub)
114 | @_specialize(where T == NonSub) // expected-error{{no type for 'T' can satisfy both 'T : NonSub' and 'T : Base'}}
    |  `- error: no type for 'T' can satisfy both 'T : NonSub' and 'T : Base'
115 | @specialized(where T == Sub)
116 | @specialized(where T == NonSub) // expected-error{{no type for 'T' can satisfy both 'T : NonSub' and 'T : Base'}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:119:2: error: trailing 'where' clause in '_specialize' attribute of non-generic function 'requirementOnNonGenericFunction(x:y:)'
117 | func superTypeRequirement<T : Base>(_ t: T) {}
118 | 
119 | @_specialize(where X:_Trivial(8), Y == Int) // expected-error{{trailing 'where' clause in '_specialize' attribute of non-generic function 'requirementOnNonGenericFunction(x:y:)'}}
    |  `- error: trailing 'where' clause in '_specialize' attribute of non-generic function 'requirementOnNonGenericFunction(x:y:)'
120 | public func requirementOnNonGenericFunction(x: Int, y: Int) {
121 | }

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:124:2: error: too few generic parameters are specified in 'specialized' attribute (got 1, but expected 2)
122 | 
123 | @_specialize(where Y == Int) // expected-error{{too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)}} expected-note{{missing constraint for 'X' in '_specialize' attribute}}
124 | @specialized(where Y == Int) // expected-error{{too few generic parameters are specified in 'specialized' attribute (got 1, but expected 2)}} expected-note{{missing constraint for 'X' in 'specialized' attribute}}
    |  |- error: too few generic parameters are specified in 'specialized' attribute (got 1, but expected 2)
    |  `- note: missing constraint for 'X' in 'specialized' attribute
125 | public func missingRequirement<X:P, Y>(x: X, y: Y) {
126 | }

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:123:2: error: too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)
121 | }
122 | 
123 | @_specialize(where Y == Int) // expected-error{{too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)}} expected-note{{missing constraint for 'X' in '_specialize' attribute}}
    |  |- error: too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)
    |  `- note: missing constraint for 'X' in '_specialize' attribute
124 | @specialized(where Y == Int) // expected-error{{too few generic parameters are specified in 'specialized' attribute (got 1, but expected 2)}} expected-note{{missing constraint for 'X' in 'specialized' attribute}}
125 | public func missingRequirement<X:P, Y>(x: X, y: Y) {

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:145:20: error: cannot find type 'X1' in scope
143 | @_specialize(where X == Int, X == Int) // expected-error{{too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)}} expected-note{{missing constraint for 'Y' in '_specialize' attribute}}
144 | @_specialize(where Y:_Trivial(32), X == Float)
145 | @_specialize(where X1 == Int, Y1 == Int) // expected-error{{cannot find type 'X1' in scope}} expected-error{{cannot find type 'Y1' in scope}} expected-error{{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 2)}} expected-note{{missing constraint for 'X' in '_specialize' attribute}} expected-note{{missing constraint for 'Y' in '_specialize' attribute}}
    |                    `- error: cannot find type 'X1' in scope
146 | public func funcWithTwoGenericParameters<X, Y>(x: X, y: Y) {
147 | }

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:145:31: error: cannot find type 'Y1' in scope
143 | @_specialize(where X == Int, X == Int) // expected-error{{too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)}} expected-note{{missing constraint for 'Y' in '_specialize' attribute}}
144 | @_specialize(where Y:_Trivial(32), X == Float)
145 | @_specialize(where X1 == Int, Y1 == Int) // expected-error{{cannot find type 'X1' in scope}} expected-error{{cannot find type 'Y1' in scope}} expected-error{{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 2)}} expected-note{{missing constraint for 'X' in '_specialize' attribute}} expected-note{{missing constraint for 'Y' in '_specialize' attribute}}
    |                               `- error: cannot find type 'Y1' in scope
146 | public func funcWithTwoGenericParameters<X, Y>(x: X, y: Y) {
147 | }

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:145:2: error: too few generic parameters are specified in '_specialize' attribute (got 0, but expected 2)
143 | @_specialize(where X == Int, X == Int) // expected-error{{too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)}} expected-note{{missing constraint for 'Y' in '_specialize' attribute}}
144 | @_specialize(where Y:_Trivial(32), X == Float)
145 | @_specialize(where X1 == Int, Y1 == Int) // expected-error{{cannot find type 'X1' in scope}} expected-error{{cannot find type 'Y1' in scope}} expected-error{{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 2)}} expected-note{{missing constraint for 'X' in '_specialize' attribute}} expected-note{{missing constraint for 'Y' in '_specialize' attribute}}
    |  |- error: too few generic parameters are specified in '_specialize' attribute (got 0, but expected 2)
    |  |- note: missing constraint for 'X' in '_specialize' attribute
    |  `- note: missing constraint for 'Y' in '_specialize' attribute
146 | public func funcWithTwoGenericParameters<X, Y>(x: X, y: Y) {
147 | }

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:143:2: error: too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)
141 | @_specialize(where X:_Trivial(8), Y == Int)
142 | @_specialize(where X == Int, Y == Int)
143 | @_specialize(where X == Int, X == Int) // expected-error{{too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)}} expected-note{{missing constraint for 'Y' in '_specialize' attribute}}
    |  |- error: too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)
    |  `- note: missing constraint for 'Y' in '_specialize' attribute
144 | @_specialize(where Y:_Trivial(32), X == Float)
145 | @_specialize(where X1 == Int, Y1 == Int) // expected-error{{cannot find type 'X1' in scope}} expected-error{{cannot find type 'Y1' in scope}} expected-error{{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 2)}} expected-note{{missing constraint for 'X' in '_specialize' attribute}} expected-note{{missing constraint for 'Y' in '_specialize' attribute}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:140:23: error: cannot find type 'MyClass' in scope
138 | @_specialize(where Y:_Trivial(32)) // expected-error {{too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)}} expected-note{{missing constraint for 'X' in '_specialize' attribute}}
139 | @_specialize(where Y: P) // expected-error{{only same-type and layout requirements are supported by '_specialize' attribute}}
140 | @_specialize(where Y: MyClass) // expected-error{{cannot find type 'MyClass' in scope}} expected-error{{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 2)}} expected-note{{missing constraint for 'X' in '_specialize' attribute}} expected-note{{missing constraint for 'Y' in '_specialize' attribute}}
    |                       `- error: cannot find type 'MyClass' in scope
141 | @_specialize(where X:_Trivial(8), Y == Int)
142 | @_specialize(where X == Int, Y == Int)

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:140:2: error: too few generic parameters are specified in '_specialize' attribute (got 0, but expected 2)
138 | @_specialize(where Y:_Trivial(32)) // expected-error {{too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)}} expected-note{{missing constraint for 'X' in '_specialize' attribute}}
139 | @_specialize(where Y: P) // expected-error{{only same-type and layout requirements are supported by '_specialize' attribute}}
140 | @_specialize(where Y: MyClass) // expected-error{{cannot find type 'MyClass' in scope}} expected-error{{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 2)}} expected-note{{missing constraint for 'X' in '_specialize' attribute}} expected-note{{missing constraint for 'Y' in '_specialize' attribute}}
    |  |- error: too few generic parameters are specified in '_specialize' attribute (got 0, but expected 2)
    |  |- note: missing constraint for 'X' in '_specialize' attribute
    |  `- note: missing constraint for 'Y' in '_specialize' attribute
141 | @_specialize(where X:_Trivial(8), Y == Int)
142 | @_specialize(where X == Int, Y == Int)

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:139:2: error: only same-type and layout requirements are supported by '_specialize' attribute
137 | @_specialize(where X == Int) // expected-error{{too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)}} expected-note{{missing constraint for 'Y' in '_specialize' attribute}}
138 | @_specialize(where Y:_Trivial(32)) // expected-error {{too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)}} expected-note{{missing constraint for 'X' in '_specialize' attribute}}
139 | @_specialize(where Y: P) // expected-error{{only same-type and layout requirements are supported by '_specialize' attribute}}
    |  `- error: only same-type and layout requirements are supported by '_specialize' attribute
140 | @_specialize(where Y: MyClass) // expected-error{{cannot find type 'MyClass' in scope}} expected-error{{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 2)}} expected-note{{missing constraint for 'X' in '_specialize' attribute}} expected-note{{missing constraint for 'Y' in '_specialize' attribute}}
141 | @_specialize(where X:_Trivial(8), Y == Int)

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:138:2: error: too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)
136 | @_specialize(where X:_Trivial(8), Y:_Trivial(32, 4))
137 | @_specialize(where X == Int) // expected-error{{too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)}} expected-note{{missing constraint for 'Y' in '_specialize' attribute}}
138 | @_specialize(where Y:_Trivial(32)) // expected-error {{too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)}} expected-note{{missing constraint for 'X' in '_specialize' attribute}}
    |  |- error: too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)
    |  `- note: missing constraint for 'X' in '_specialize' attribute
139 | @_specialize(where Y: P) // expected-error{{only same-type and layout requirements are supported by '_specialize' attribute}}
140 | @_specialize(where Y: MyClass) // expected-error{{cannot find type 'MyClass' in scope}} expected-error{{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 2)}} expected-note{{missing constraint for 'X' in '_specialize' attribute}} expected-note{{missing constraint for 'Y' in '_specialize' attribute}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:137:2: error: too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)
135 | @_specialize(where X:_Trivial(8), Y:_Trivial(32), Z == Int) // expected-error{{cannot find type 'Z' in scope}}
136 | @_specialize(where X:_Trivial(8), Y:_Trivial(32, 4))
137 | @_specialize(where X == Int) // expected-error{{too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)}} expected-note{{missing constraint for 'Y' in '_specialize' attribute}}
    |  |- error: too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)
    |  `- note: missing constraint for 'Y' in '_specialize' attribute
138 | @_specialize(where Y:_Trivial(32)) // expected-error {{too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)}} expected-note{{missing constraint for 'X' in '_specialize' attribute}}
139 | @_specialize(where Y: P) // expected-error{{only same-type and layout requirements are supported by '_specialize' attribute}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:135:51: error: cannot find type 'Z' in scope
133 | 
134 | 
135 | @_specialize(where X:_Trivial(8), Y:_Trivial(32), Z == Int) // expected-error{{cannot find type 'Z' in scope}}
    |                                                   `- error: cannot find type 'Z' in scope
136 | @_specialize(where X:_Trivial(8), Y:_Trivial(32, 4))
137 | @_specialize(where X == Int) // expected-error{{too few generic parameters are specified in '_specialize' attribute (got 1, but expected 2)}} expected-note{{missing constraint for 'Y' in '_specialize' attribute}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:170:40: error: cannot find type 'exported' in scope
168 | @_specialize(kind: partial, kind: partial, where X == Int, Y == Int) // expected-error{{parameter 'kind' was already defined in '_specialize' attribute}}
169 | 
170 | @_specialize(where X == Int, Y == Int, exported: true, kind: partial) // expected-error{{expected type}} expected-error{{cannot find type 'exported' in scope}} expected-error{{cannot find type 'kind' in scope}} expected-error{{cannot find type 'partial' in scope}}
    |                                        `- error: cannot find type 'exported' in scope
171 | public func anotherFuncWithTwoGenericParameters<X: P, Y>(x: X, y: Y) {
172 | }

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:170:56: error: cannot find type 'kind' in scope
168 | @_specialize(kind: partial, kind: partial, where X == Int, Y == Int) // expected-error{{parameter 'kind' was already defined in '_specialize' attribute}}
169 | 
170 | @_specialize(where X == Int, Y == Int, exported: true, kind: partial) // expected-error{{expected type}} expected-error{{cannot find type 'exported' in scope}} expected-error{{cannot find type 'kind' in scope}} expected-error{{cannot find type 'partial' in scope}}
    |                                                        `- error: cannot find type 'kind' in scope
171 | public func anotherFuncWithTwoGenericParameters<X: P, Y>(x: X, y: Y) {
172 | }

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:170:62: error: cannot find type 'partial' in scope
168 | @_specialize(kind: partial, kind: partial, where X == Int, Y == Int) // expected-error{{parameter 'kind' was already defined in '_specialize' attribute}}
169 | 
170 | @_specialize(where X == Int, Y == Int, exported: true, kind: partial) // expected-error{{expected type}} expected-error{{cannot find type 'exported' in scope}} expected-error{{cannot find type 'kind' in scope}} expected-error{{cannot find type 'partial' in scope}}
    |                                                              `- error: cannot find type 'partial' in scope
171 | public func anotherFuncWithTwoGenericParameters<X: P, Y>(x: X, y: Y) {
172 | }

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:185:21: error: type 'T' constrained to non-protocol, non-class type 'Int'
183 | @_specialize(where T: C1) // expected-error{{only same-type and layout requirements are supported by '_specialize' attribute}}
184 | @_specialize(where Int: P) // expected-error{{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}} expected-note{{missing constraint for 'T' in '_specialize' attribute}}
185 | @specialized(where T: Int) // expected-error{{type 'T' constrained to non-protocol, non-class type 'Int'}} expected-note {{use 'T == Int' to require 'T' to be 'Int'}}
    |                     |- error: type 'T' constrained to non-protocol, non-class type 'Int'
    |                     `- note: use 'T == Int' to require 'T' to be 'Int'
186 | // expected-error@-1 {{too few generic parameters are specified in 'specialized' attribute (got 0, but expected 1)}}
187 | // expected-note@-2 {{missing constraint for 'T' in 'specialized' attribute}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:185:2: error: too few generic parameters are specified in 'specialized' attribute (got 0, but expected 1)
183 | @_specialize(where T: C1) // expected-error{{only same-type and layout requirements are supported by '_specialize' attribute}}
184 | @_specialize(where Int: P) // expected-error{{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}} expected-note{{missing constraint for 'T' in '_specialize' attribute}}
185 | @specialized(where T: Int) // expected-error{{type 'T' constrained to non-protocol, non-class type 'Int'}} expected-note {{use 'T == Int' to require 'T' to be 'Int'}}
    |  |- error: too few generic parameters are specified in 'specialized' attribute (got 0, but expected 1)
    |  `- note: missing constraint for 'T' in 'specialized' attribute
186 | // expected-error@-1 {{too few generic parameters are specified in 'specialized' attribute (got 0, but expected 1)}}
187 | // expected-note@-2 {{missing constraint for 'T' in 'specialized' attribute}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:184:2: error: too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)
182 | // expected-note@-2 {{missing constraint for 'T' in '_specialize' attribute}}
183 | @_specialize(where T: C1) // expected-error{{only same-type and layout requirements are supported by '_specialize' attribute}}
184 | @_specialize(where Int: P) // expected-error{{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}} expected-note{{missing constraint for 'T' in '_specialize' attribute}}
    |  |- error: too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)
    |  `- note: missing constraint for 'T' in '_specialize' attribute
185 | @specialized(where T: Int) // expected-error{{type 'T' constrained to non-protocol, non-class type 'Int'}} expected-note {{use 'T == Int' to require 'T' to be 'Int'}}
186 | // expected-error@-1 {{too few generic parameters are specified in 'specialized' attribute (got 0, but expected 1)}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:183:2: error: only same-type and layout requirements are supported by '_specialize' attribute
181 | // expected-error@-1 {{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}}
182 | // expected-note@-2 {{missing constraint for 'T' in '_specialize' attribute}}
183 | @_specialize(where T: C1) // expected-error{{only same-type and layout requirements are supported by '_specialize' attribute}}
    |  `- error: only same-type and layout requirements are supported by '_specialize' attribute
184 | @_specialize(where Int: P) // expected-error{{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}} expected-note{{missing constraint for 'T' in '_specialize' attribute}}
185 | @specialized(where T: Int) // expected-error{{type 'T' constrained to non-protocol, non-class type 'Int'}} expected-note {{use 'T == Int' to require 'T' to be 'Int'}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:180:21: error: type 'T' constrained to non-protocol, non-class type 'S1'
178 | // expected-note@-2 {{missing constraint for 'T' in '_specialize' attribute}}
179 | 
180 | @_specialize(where T: S1) // expected-error{{type 'T' constrained to non-protocol, non-class type 'S1'}} expected-note {{use 'T == S1' to require 'T' to be 'S1'}}
    |                     |- error: type 'T' constrained to non-protocol, non-class type 'S1'
    |                     `- note: use 'T == S1' to require 'T' to be 'S1'
181 | // expected-error@-1 {{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}}
182 | // expected-note@-2 {{missing constraint for 'T' in '_specialize' attribute}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:180:2: error: too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)
178 | // expected-note@-2 {{missing constraint for 'T' in '_specialize' attribute}}
179 | 
180 | @_specialize(where T: S1) // expected-error{{type 'T' constrained to non-protocol, non-class type 'S1'}} expected-note {{use 'T == S1' to require 'T' to be 'S1'}}
    |  |- error: too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)
    |  `- note: missing constraint for 'T' in '_specialize' attribute
181 | // expected-error@-1 {{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}}
182 | // expected-note@-2 {{missing constraint for 'T' in '_specialize' attribute}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:176:21: error: type 'T' constrained to non-protocol, non-class type 'Int'
174 | @_specialize(where T: P) // expected-error{{only same-type and layout requirements are supported by '_specialize' attribute}}
175 | @specialized(where T: P) // expected-error{{only same-type are supported by 'specialized' attribute}}
176 | @_specialize(where T: Int) // expected-error{{type 'T' constrained to non-protocol, non-class type 'Int'}} expected-note {{use 'T == Int' to require 'T' to be 'Int'}}
    |                     |- error: type 'T' constrained to non-protocol, non-class type 'Int'
    |                     `- note: use 'T == Int' to require 'T' to be 'Int'
177 | // expected-error@-1 {{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}}
178 | // expected-note@-2 {{missing constraint for 'T' in '_specialize' attribute}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:176:2: error: too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)
174 | @_specialize(where T: P) // expected-error{{only same-type and layout requirements are supported by '_specialize' attribute}}
175 | @specialized(where T: P) // expected-error{{only same-type are supported by 'specialized' attribute}}
176 | @_specialize(where T: Int) // expected-error{{type 'T' constrained to non-protocol, non-class type 'Int'}} expected-note {{use 'T == Int' to require 'T' to be 'Int'}}
    |  |- error: too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)
    |  `- note: missing constraint for 'T' in '_specialize' attribute
177 | // expected-error@-1 {{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}}
178 | // expected-note@-2 {{missing constraint for 'T' in '_specialize' attribute}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:175:2: error: only same-type are supported by 'specialized' attribute
173 | 
174 | @_specialize(where T: P) // expected-error{{only same-type and layout requirements are supported by '_specialize' attribute}}
175 | @specialized(where T: P) // expected-error{{only same-type are supported by 'specialized' attribute}}
    |  `- error: only same-type are supported by 'specialized' attribute
176 | @_specialize(where T: Int) // expected-error{{type 'T' constrained to non-protocol, non-class type 'Int'}} expected-note {{use 'T == Int' to require 'T' to be 'Int'}}
177 | // expected-error@-1 {{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:174:2: error: only same-type and layout requirements are supported by '_specialize' attribute
172 | }
173 | 
174 | @_specialize(where T: P) // expected-error{{only same-type and layout requirements are supported by '_specialize' attribute}}
    |  `- error: only same-type and layout requirements are supported by '_specialize' attribute
175 | @specialized(where T: P) // expected-error{{only same-type are supported by 'specialized' attribute}}
176 | @_specialize(where T: Int) // expected-error{{type 'T' constrained to non-protocol, non-class type 'Int'}} expected-note {{use 'T == Int' to require 'T' to be 'Int'}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:199:2: error: only requirements on generic parameters are supported by '_specialize' attribute
197 | // expected-error@-1 {{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}}
198 | // expected-note@-2 {{missing constraint for 'T' in '_specialize' attribute}}
199 | @_specialize(where T.Element == Int) // expected-error{{only requirements on generic parameters are supported by '_specialize' attribute}}
    |  `- error: only requirements on generic parameters are supported by '_specialize' attribute
200 | public func funcWithComplexSpecializeRequirements<T: ProtocolWithDep>(t: T) -> Int {
201 |   return 55555

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:196:29: error: generic signature requires types 'Array<T>' and 'Int' to be the same
194 | @_specialize(where T: _Trivial, T: _Trivial(64))
195 | @_specialize(where T: _RefCountedObject, T: _NativeRefCountedObject)
196 | @_specialize(where Array<T> == Int) // expected-error{{generic signature requires types 'Array<T>' and 'Int' to be the same}}
    |                             `- error: generic signature requires types 'Array<T>' and 'Int' to be the same
197 | // expected-error@-1 {{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}}
198 | // expected-note@-2 {{missing constraint for 'T' in '_specialize' attribute}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:196:2: error: too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)
194 | @_specialize(where T: _Trivial, T: _Trivial(64))
195 | @_specialize(where T: _RefCountedObject, T: _NativeRefCountedObject)
196 | @_specialize(where Array<T> == Int) // expected-error{{generic signature requires types 'Array<T>' and 'Int' to be the same}}
    |  |- error: too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)
    |  `- note: missing constraint for 'T' in '_specialize' attribute
197 | // expected-error@-1 {{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}}
198 | // expected-note@-2 {{missing constraint for 'T' in '_specialize' attribute}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:191:2: error: no type for 'T' can satisfy both 'T : _Trivial(64)' and 'T : _Trivial(32)'
189 | }
190 | 
191 | @_specialize(where T: _Trivial(32), T: _Trivial(64), T: _Trivial, T: _RefCountedObject)
    |  `- error: no type for 'T' can satisfy both 'T : _Trivial(64)' and 'T : _Trivial(32)'
192 | // expected-error@-1{{no type for 'T' can satisfy both 'T : _RefCountedObject' and 'T : _Trivial(64)'}}
193 | // expected-error@-2{{no type for 'T' can satisfy both 'T : _Trivial(64)' and 'T : _Trivial(32)'}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:191:2: error: no type for 'T' can satisfy both 'T : _RefCountedObject' and 'T : _Trivial(64)'
189 | }
190 | 
191 | @_specialize(where T: _Trivial(32), T: _Trivial(64), T: _Trivial, T: _RefCountedObject)
    |  `- error: no type for 'T' can satisfy both 'T : _RefCountedObject' and 'T : _Trivial(64)'
192 | // expected-error@-1{{no type for 'T' can satisfy both 'T : _RefCountedObject' and 'T : _Trivial(64)'}}
193 | // expected-error@-2{{no type for 'T' can satisfy both 'T : _Trivial(64)' and 'T : _Trivial(32)'}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:204:24: warning: using 'class' keyword to define a class-constrained protocol is deprecated; use 'AnyObject' instead [#deprecation]
202 | }
203 | 
204 | public protocol Proto: class {
    |                        `- warning: using 'class' keyword to define a class-constrained protocol is deprecated; use 'AnyObject' instead [#deprecation]
205 | }
206 | 

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:214:2: error: no type for 'T' can satisfy both 'T : _NativeClass' and 'T : _Trivial(64)'
212 | // expected-error@-2 {{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}}
213 | // expected-note@-3 {{missing constraint for 'T' in '_specialize' attribute}}
214 | @_specialize(where T: _Trivial(64))
    |  `- error: no type for 'T' can satisfy both 'T : _NativeClass' and 'T : _Trivial(64)'
215 | // expected-error@-1{{no type for 'T' can satisfy both 'T : _NativeClass' and 'T : _Trivial(64)'}}
216 | // expected-error@-2 {{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:214:2: error: too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)
212 | // expected-error@-2 {{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}}
213 | // expected-note@-3 {{missing constraint for 'T' in '_specialize' attribute}}
214 | @_specialize(where T: _Trivial(64))
    |  |- error: too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)
    |  `- note: missing constraint for 'T' in '_specialize' attribute
215 | // expected-error@-1{{no type for 'T' can satisfy both 'T : _NativeClass' and 'T : _Trivial(64)'}}
216 | // expected-error@-2 {{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:210:2: error: no type for 'T' can satisfy both 'T : _NativeClass' and 'T : _Trivial'
208 | // expected-error@-1 {{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}}
209 | // expected-note@-2 {{missing constraint for 'T' in '_specialize' attribute}}
210 | @_specialize(where T: _Trivial)
    |  `- error: no type for 'T' can satisfy both 'T : _NativeClass' and 'T : _Trivial'
211 | // expected-error@-1{{no type for 'T' can satisfy both 'T : _NativeClass' and 'T : _Trivial'}}
212 | // expected-error@-2 {{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:210:2: error: too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)
208 | // expected-error@-1 {{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}}
209 | // expected-note@-2 {{missing constraint for 'T' in '_specialize' attribute}}
210 | @_specialize(where T: _Trivial)
    |  |- error: too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)
    |  `- note: missing constraint for 'T' in '_specialize' attribute
211 | // expected-error@-1{{no type for 'T' can satisfy both 'T : _NativeClass' and 'T : _Trivial'}}
212 | // expected-error@-2 {{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:207:2: error: too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)
205 | }
206 | 
207 | @_specialize(where T: _RefCountedObject)
    |  |- error: too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)
    |  `- note: missing constraint for 'T' in '_specialize' attribute
208 | // expected-error@-1 {{too few generic parameters are specified in '_specialize' attribute (got 0, but expected 1)}}
209 | // expected-note@-2 {{missing constraint for 'T' in '_specialize' attribute}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:255:6: error: too few generic parameters are specified in 'specialized' attribute (got 2, but expected 3)
253 |   struct MyStruct<T> {
254 |     @_specialize(where T == Int, U == Float) // expected-error{{too few generic parameters are specified in '_specialize' attribute (got 2, but expected 3)}} expected-note{{missing constraint for 'S' in '_specialize' attribute}}
255 |     @specialized(where T == Int, U == Float) // expected-error{{too few generic parameters are specified in 'specialized' attribute (got 2, but expected 3)}} expected-note{{missing constraint for 'S' in 'specialized' attribute}}
    |      |- error: too few generic parameters are specified in 'specialized' attribute (got 2, but expected 3)
    |      `- note: missing constraint for 'S' in 'specialized' attribute
256 |     public func foo<U>(u : U) {
257 |     }

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:254:6: error: too few generic parameters are specified in '_specialize' attribute (got 2, but expected 3)
252 | struct OuterStruct<S> {
253 |   struct MyStruct<T> {
254 |     @_specialize(where T == Int, U == Float) // expected-error{{too few generic parameters are specified in '_specialize' attribute (got 2, but expected 3)}} expected-note{{missing constraint for 'S' in '_specialize' attribute}}
    |      |- error: too few generic parameters are specified in '_specialize' attribute (got 2, but expected 3)
    |      `- note: missing constraint for 'S' in '_specialize' attribute
255 |     @specialized(where T == Int, U == Float) // expected-error{{too few generic parameters are specified in 'specialized' attribute (got 2, but expected 3)}} expected-note{{missing constraint for 'S' in 'specialized' attribute}}
256 |     public func foo<U>(u : U) {

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:306:26: error: 'MyStruct3' is ambiguous for type lookup in this context
298 | }
299 | 
300 | public struct MyStruct3 : P1 {
    |               `- note: found this candidate
301 |   public typealias DP1 = Int
302 |   public typealias DP11 = H<Int>
    :
304 | 
305 | public struct MyStruct4 : P2 {
306 |   public typealias DP2 = MyStruct3
    |                          `- error: 'MyStruct3' is ambiguous for type lookup in this context
307 | }
308 | 
    :
453 | 
454 | @DebugDescription
455 | struct MyStruct3: CustomDebugStringConvertible {
    |        `- note: found this candidate
456 |   var description: String { "thirty" }
457 |   var debugDescription: String { "eleven" }

Assertion failed: (std::find(conformsTo.begin(), conformsTo.end(), symbol.getProtocol()) != conformsTo.end()), function getTypeForSymbolRange at InterfaceType.cpp:365.
(to display assertion configuration options: -Xllvm -assert-help)

Please submit a bug report (https://swift.org/contributing/#reporting-bugs) and include the crash backtrace.
Stack dump:
0.	Program arguments: /usr/bin/swift-frontend -typecheck -Onone -sil-verify-all /home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift
1.	Swift version 6.5-dev (LLVM 7c86461e21cca7e, Swift 6da4da7153e8252)
2.	Compiling with effective version 5.10
3.	While evaluating request TypeCheckPrimaryFileRequest(source_file "/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift")
4.	While type-checking 'foo(_:)' (at /home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:310:8)
5.	While evaluating request SerializeAttrGenericSignatureRequest(d0a70f40.(file).foo@/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmpnczhb7nf/d0a70f40.swift:310:13, @_specialize(exported: false, kind: full, 
*** Signal 11: Backtracing from 0x55f5f30554df... done ***

*** Program crashed: Bad pointer dereference at 0x0000000000000048 ***

Platform: x86_64 Linux (Ubuntu 24.04.4 LTS)

Thread 0 "swift-frontend" crashed:

0  0x000055f5f30554df swift::AbstractSpecializeAttr::getSpecializedSignature(swift::AbstractFunctionDecl const*) const + 15 in swift-frontend


Registers:

rax 0x0000000400000000  17179869184
rdx 0x000055f624131ea0  01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ················
rcx 0x0000000800000000  34359738368
rbx 0x0000000000000000  0
rsi 0x000055f62415b1a8  18 71 7a e4 c7 7f 00 00 19 71 7a e4 c7 7f 00 00  ·qzäÇ····qzäÇ···
rdi 0x0000000000000000  0
rbp 0x000055f624132060  68 68 58 fa f5 55 00 00 00 00 00 00 00 00 00 00  hhXúõU··········
rsp 0x000055f624131e50  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ················
 r8 0x000055f5fc4561bc  66 e5 bf f6 72 e5 bf f6 60 e7 bf f6 16 e0 bf f6  få¿örå¿ö`ç¿ö·à¿ö
 r9 0x0000000000000000  0
r10 0x0000000000000031  49
r11 0x0000000000000202  514
r12 0x0000000000000000  0
r13 0x000055f5fa88d8dc  66 61 6c 73 65 00 6f 66 66 00 72 65 71 75 65 73  false·off·reques
r14 0x0000000000000000  0
r15 0x000055f62415b1a8  18 71 7a e4 c7 7f 00 00 19 71 7a e4 c7 7f 00 00  ·qzäÇ····qzäÇ···
rip 0x000055f5f30554df  48 8b 46 48 48 89 c3 48 83 e3 fc 31 ff a8 02 48  H·FHH·ÃH·ãü1ÿ¨·H

rflags 0x0000000000010206  PF

cs 0x0033  fs 0x0000  gs 0x0000


Images (29 omitted):

0x000055f5f0843000–0x000055f5fa525408 7962bc5b87f37dc987a2f3d77afdf00ca4b96717 swift-frontend /usr/bin/swift-frontend

Backtrace took 0.45s

Segmentation fault (core dumped)
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1:detect_stack_use_after_return=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' swift -frontend -typecheck -Onone -sil-verify-all "$SCRIPT_DIR/test.swift"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `0b0568b4` | Project seed |
| `b` | `4e1886bd` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
