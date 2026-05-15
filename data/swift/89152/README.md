---
render_with_liquid: false
---

*Fusion-Fuzz Bug Report*

**ID:** `f56f36b2` &nbsp;·&nbsp; **Signature:** `Assertion failed: (std::find(Bindings.begin(), Bindings.end(), binding) == Bindings.end()), function addBinding at CSBindings.cpp:1681.` &nbsp;·&nbsp; **RC:** `134`

The following code:

```swift


// --- Seed A ---
// RUN: %empty-directory(%t)
// RUN: split-file %s %t

// RUN: not %target-swift-frontend-verify -typecheck %t/test.swift 2>&1 | %update-verify-tests
// RUN: %target-swift-frontend-verify -typecheck %t/test.swift
// RUN: %diff %t/test.swift %t/test.swift.expected

//--- test.swift
func foo() {

//--- test.swift.expected
// expected-note@+1{{to match this opening '{'}}
func foo() {

// expected-error@+1{{expected '}' at end of brace statement}}

// --- Seed B ---
// RUN: %empty-directory(%t)
// RUN: %target-swift-emit-module-interface(%t/OpaqueResultTypes.swiftinterface) %s -module-name OpaqueResultTypes
// RUN: %target-swift-typecheck-module-from-interface(%t/OpaqueResultTypes.swiftinterface) -module-name OpaqueResultTypes
// RUN: %FileCheck %s < %t/OpaqueResultTypes.swiftinterface
// RUN: %target-swift-frontend -I %t -typecheck -verify -verify-ignore-unrelated %S/Inputs/opaque-result-types-client.swift

public protocol Foo {}
extension Int: Foo {}

// CHECK-LABEL: public func foo(_: Swift::Int) -> some OpaqueResultTypes::Foo
@available(SwiftStdlib 5.1, *)
public func foo(_: Int) -> some Foo {
  return 1738
}

// CHECK-LABEL: @inlinable public func foo(_: Swift::String) -> some OpaqueResultTypes::Foo {
@available(SwiftStdlib 5.1, *)
@inlinable public func foo(_: String) -> some Foo {
  return 679
}

// CHECK-LABEL: public func foo<T>(_ x: T) -> some OpaqueResultTypes::Foo where T : OpaqueResultTypes::Foo
@available(SwiftStdlib 5.1, *)
public func foo<T: Foo>(_ x: T) -> some Foo {
  return x
}

// CHECK-LABEL: public var globalComputedVar: some OpaqueResultTypes::Foo {
// CHECK-NEXT:    get
// CHECK-NEXT:  }
@available(SwiftStdlib 5.1, *)
public var globalComputedVar: some Foo { 123 }

// CHECK-LABEL: public var globalVar: some OpaqueResultTypes::Foo{{$}}
@available(SwiftStdlib 5.1, *)
public var globalVar: some Foo = 123

// CHECK-LABEL: public var globalVarTuple: (some OpaqueResultTypes::Foo, some OpaqueResultTypes::Foo){{$}}
@available(SwiftStdlib 5.1, *)
public var globalVarTuple: (some Foo, some Foo) = (123, foo(123))

public protocol AssocTypeInference {
  associatedtype Assoc: Foo
  associatedtype AssocProperty: Foo
  associatedtype AssocSubscript: Foo

  func foo(_: Int) -> Assoc

  var prop: AssocProperty { get }
  subscript() -> AssocSubscript { get }
}

@available(SwiftStdlib 5.1, *)
public struct Bar<T>: AssocTypeInference {
  public init() {}

  // CHECK-LABEL: public func foo(_: Swift::Int) -> some OpaqueResultTypes::Foo
  @available(SwiftStdlib 5.1, *)
  public func foo(_: Int) -> some Foo {
    return 20721
  }

  @available(SwiftStdlib 5.1, *)
  public func foo(_: String) -> some Foo {
    return 219
  }

  // CHECK-LABEL: public func foo<U>(_ x: U) -> some OpaqueResultTypes::Foo where U : OpaqueResultTypes::Foo
  @available(SwiftStdlib 5.1, *)
  public func foo<U: Foo>(_ x: U) -> some Foo {
    return x
  }

  @available(SwiftStdlib 5.1, *)
  public struct Bas: AssocTypeInference {
    public init() {}

    // CHECK-LABEL: public func foo(_: Swift::Int) -> some OpaqueResultTypes::Foo
    @available(SwiftStdlib 5.1, *)
    public func foo(_: Int) -> some Foo {
      return 20721
    }

    @available(SwiftStdlib 5.1, *)
    public func foo(_: String) -> some Foo {
      return 219
    }

    // CHECK-LABEL: public func foo<U>(_ x: U) -> some OpaqueResultTypes::Foo where U : OpaqueResultTypes::Foo
    @available(SwiftStdlib 5.1, *)
    public func foo<U: Foo>(_ x: U) -> some Foo {
      return x
    }

    @available(SwiftStdlib 5.1, *)
    public var prop: some Foo {
      return 123
    }
    @available(SwiftStdlib 5.1, *)
    public subscript() -> some Foo {
      return 123
    }

    // CHECK-LABEL: public typealias Assoc = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<T>
    // CHECK-LABEL: public typealias AssocProperty = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<T>
    // CHECK-LABEL: public typealias AssocSubscript = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<T>
  }

  @available(SwiftStdlib 5.1, *)
  public struct Bass<U: Foo>: AssocTypeInference {
    public init() {}

    // CHECK-LABEL: public func foo(_: Swift::Int) -> some OpaqueResultTypes::Foo
    @available(SwiftStdlib 5.1, *)
    public func foo(_: Int) -> some Foo {
      return 20721
    }

    @available(SwiftStdlib 5.1, *)
    public func foo(_: String) -> some Foo {
      return 219
    }

    // CHECK-LABEL: public func foo(_ x: U) -> some OpaqueResultTypes::Foo
    @available(SwiftStdlib 5.1, *)
    public func foo(_ x: U) -> some Foo {
      return x
    }

    // CHECK-LABEL: public func foo<V>(_ x: V) -> some OpaqueResultTypes::Foo where V : OpaqueResultTypes::Foo
    @available(SwiftStdlib 5.1, *)
    public func foo<V: Foo>(_ x: V) -> some Foo {
      return x
    }
    @available(SwiftStdlib 5.1, *)
    public var prop: some Foo {
      return 123
    }
    @available(SwiftStdlib 5.1, *)
    public subscript() -> some Foo {
      return 123
    }

    // CHECK-LABEL: public typealias Assoc = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<T, U>
    // CHECK-LABEL: public typealias AssocProperty = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<T, U>
    // CHECK-LABEL: public typealias AssocSubscript = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<T, U>
  }

  @available(SwiftStdlib 5.1, *)
  public var prop: some Foo {
    return 123
  }
  @available(SwiftStdlib 5.1, *)
  public subscript() -> some Foo {
    return 123
  }

  // CHECK-LABEL: public typealias Assoc = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<T>
  // CHECK-LABEL: public typealias AssocProperty = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<T>
  // CHECK-LABEL: public typealias AssocSubscript = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<T>
}

@available(SwiftStdlib 5.1, *)
public struct Zim: AssocTypeInference {
  public init() {}

  @available(SwiftStdlib 5.1, *)
  public func foo(_: Int) -> some Foo {
    return 20721
  }

  @available(SwiftStdlib 5.1, *)
  public func foo(_: String) -> some Foo {
    return 219
  }

  // CHECK-LABEL: public func foo<U>(_ x: U) -> some OpaqueResultTypes::Foo where U : OpaqueResultTypes::Foo
  @available(SwiftStdlib 5.1, *)
  public func foo<U: Foo>(_ x: U) -> some Foo {
    return x
  }

  @available(SwiftStdlib 5.1, *)
  public struct Zang: AssocTypeInference {
    public init() {}

    @available(SwiftStdlib 5.1, *)
    public func foo(_: Int) -> some Foo {
      return 20721
    }

    @available(SwiftStdlib 5.1, *)
    public func foo(_: String) -> some Foo {
      return 219
    }

    // CHECK-LABEL: public func foo<U>(_ x: U) -> some OpaqueResultTypes::Foo where U : OpaqueResultTypes::Foo
    @available(SwiftStdlib 5.1, *)
    public func foo<U: Foo>(_ x: U) -> some Foo {
      return x
    }

    @available(SwiftStdlib 5.1, *)
    public var prop: some Foo {
      return 123
    }
    @available(SwiftStdlib 5.1, *)
    public subscript() -> some Foo {
      return 123
    }
  }

  @available(SwiftStdlib 5.1, *)
  public struct Zung<U: Foo>: AssocTypeInference {
    public init() {}

    // CHECK-LABEL: public func foo(_: Swift::Int) -> some OpaqueResultTypes::Foo
    @available(SwiftStdlib 5.1, *)
    public func foo(_: Int) -> some Foo {
      return 20721
    }

    @available(SwiftStdlib 5.1, *)
    public func foo(_: String) -> some Foo {
      return 219
    }

    @available(SwiftStdlib 5.1, *)
    public func foo(_ x: U) -> some Foo {
      return x
    }

    // CHECK-LABEL: public func foo<V>(_ x: V) -> some OpaqueResultTypes::Foo where V : OpaqueResultTypes::Foo
    @available(SwiftStdlib 5.1, *)
    public func foo<V: Foo>(_ x: V) -> some Foo {
      return x
    }

    @available(SwiftStdlib 5.1, *)
    public var prop: some Foo {
      return 123
    }
    @available(SwiftStdlib 5.1, *)
    public subscript() -> some Foo {
      return 123
    }

    // CHECK-LABEL: public typealias Assoc = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<U>
    // CHECK-LABEL: public typealias AssocProperty = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<U>
    // CHECK-LABEL: public typealias AssocSubscript = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<U>
  }

  @available(SwiftStdlib 5.1, *)
  public var prop: some Foo {
    return 123
  }
  @available(SwiftStdlib 5.1, *)
  public subscript() -> some Foo {
    return 123
  }
}
var _ffl_sentinel: Int = 0
// --- Bug Primitive ---

// P5: Dynamic casting chain stress
protocol _FflCastable: AnyObject {}
class _FflBase: _FflCastable {
    var v: Int = 0
}
class _FflDerived: _FflBase {
    var extra: String = ""
}
func _ffl_p5_cast(_ obj: AnyObject) -> String {
    if let d = obj as? _FflDerived { return "derived:\(d.extra)" }
    if let b = obj as? _FflBase    { return "base:\(b.v)" }
    if let s = obj as? CustomStringConvertible { return s.description }
    return "unknown:\(type(of: obj))"
}
do {
    let _ffl_seed = String(describing: _ffl_sentinel).count
    let _ffl_obj: AnyObject = _ffl_seed % 2 == 0
        ? _FflDerived() as AnyObject
        : _FflBase()    as AnyObject
    _ = _ffl_p5_cast(_ffl_obj)
    // Force-cast through Any — stresses value-witness metadata path
    let _ffl_any: Any = _ffl_sentinel
    _ = _ffl_any as? Int
    _ = _ffl_any as? String
    _ = _ffl_any as? Bool
    _ = type(of: _ffl_any)
}


```

Resulted in this output:

```
/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:27:1: error: attribute 'public' can only be used in a non-local scope
 25 | // RUN: %target-swift-frontend -I %t -typecheck -verify -verify-ignore-unrelated %S/Inputs/opaque-result-types-client.swift
 26 | 
 27 | public protocol Foo {}
    | `- error: attribute 'public' can only be used in a non-local scope
 28 | extension Int: Foo {}
 29 | 

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:28:1: error: declaration is only valid at file scope
 26 | 
 27 | public protocol Foo {}
 28 | extension Int: Foo {}
    | `- error: declaration is only valid at file scope
 29 | 
 30 | // CHECK-LABEL: public func foo(_: Swift::Int) -> some OpaqueResultTypes::Foo

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:32:1: error: attribute 'public' can only be used in a non-local scope
 30 | // CHECK-LABEL: public func foo(_: Swift::Int) -> some OpaqueResultTypes::Foo
 31 | @available(SwiftStdlib 5.1, *)
 32 | public func foo(_: Int) -> some Foo {
    | `- error: attribute 'public' can only be used in a non-local scope
 33 |   return 1738
 34 | }

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:38:12: error: attribute 'public' can only be used in a non-local scope
 36 | // CHECK-LABEL: @inlinable public func foo(_: Swift::String) -> some OpaqueResultTypes::Foo {
 37 | @available(SwiftStdlib 5.1, *)
 38 | @inlinable public func foo(_: String) -> some Foo {
    |            `- error: attribute 'public' can only be used in a non-local scope
 39 |   return 679
 40 | }

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:44:1: error: attribute 'public' can only be used in a non-local scope
 42 | // CHECK-LABEL: public func foo<T>(_ x: T) -> some OpaqueResultTypes::Foo where T : OpaqueResultTypes::Foo
 43 | @available(SwiftStdlib 5.1, *)
 44 | public func foo<T: Foo>(_ x: T) -> some Foo {
    | `- error: attribute 'public' can only be used in a non-local scope
 45 |   return x
 46 | }

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:52:1: error: attribute 'public' can only be used in a non-local scope
 50 | // CHECK-NEXT:  }
 51 | @available(SwiftStdlib 5.1, *)
 52 | public var globalComputedVar: some Foo { 123 }
    | `- error: attribute 'public' can only be used in a non-local scope
 53 | 
 54 | // CHECK-LABEL: public var globalVar: some OpaqueResultTypes::Foo{{$}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:56:1: error: attribute 'public' can only be used in a non-local scope
 54 | // CHECK-LABEL: public var globalVar: some OpaqueResultTypes::Foo{{$}}
 55 | @available(SwiftStdlib 5.1, *)
 56 | public var globalVar: some Foo = 123
    | `- error: attribute 'public' can only be used in a non-local scope
 57 | 
 58 | // CHECK-LABEL: public var globalVarTuple: (some OpaqueResultTypes::Foo, some OpaqueResultTypes::Foo){{$}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:60:1: error: attribute 'public' can only be used in a non-local scope
 58 | // CHECK-LABEL: public var globalVarTuple: (some OpaqueResultTypes::Foo, some OpaqueResultTypes::Foo){{$}}
 59 | @available(SwiftStdlib 5.1, *)
 60 | public var globalVarTuple: (some Foo, some Foo) = (123, foo(123))
    | `- error: attribute 'public' can only be used in a non-local scope
 61 | 
 62 | public protocol AssocTypeInference {

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:62:1: error: attribute 'public' can only be used in a non-local scope
 60 | public var globalVarTuple: (some Foo, some Foo) = (123, foo(123))
 61 | 
 62 | public protocol AssocTypeInference {
    | `- error: attribute 'public' can only be used in a non-local scope
 63 |   associatedtype Assoc: Foo
 64 |   associatedtype AssocProperty: Foo

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:74:1: error: attribute 'public' can only be used in a non-local scope
 72 | 
 73 | @available(SwiftStdlib 5.1, *)
 74 | public struct Bar<T>: AssocTypeInference {
    | `- error: attribute 'public' can only be used in a non-local scope
 75 |   public init() {}
 76 | 

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:184:1: error: attribute 'public' can only be used in a non-local scope
182 | 
183 | @available(SwiftStdlib 5.1, *)
184 | public struct Zim: AssocTypeInference {
    | `- error: attribute 'public' can only be used in a non-local scope
185 |   public init() {}
186 | 

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:313:1: error: expected '}' at end of brace statement
 14 | //--- test.swift.expected
 15 | // expected-note@+1{{to match this opening '{'}}
 16 | func foo() {
    |            `- note: to match this opening '{'
 17 | 
 18 | // expected-error@+1{{expected '}' at end of brace statement}}
    :
311 | }
312 | 
313 | 
    | `- error: expected '}' at end of brace statement

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:313:1: error: expected '}' at end of brace statement
 10 | 
 11 | //--- test.swift
 12 | func foo() {
    |            `- note: to match this opening '{'
 13 | 
 14 | //--- test.swift.expected
    :
311 | }
312 | 
313 | 
    | `- error: expected '}' at end of brace statement

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:31:12: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
 29 | 
 30 | // CHECK-LABEL: public func foo(_: Swift::Int) -> some OpaqueResultTypes::Foo
 31 | @available(SwiftStdlib 5.1, *)
    |            `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
 32 | public func foo(_: Int) -> some Foo {
 33 |   return 1738

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:37:12: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
 35 | 
 36 | // CHECK-LABEL: @inlinable public func foo(_: Swift::String) -> some OpaqueResultTypes::Foo {
 37 | @available(SwiftStdlib 5.1, *)
    |            `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
 38 | @inlinable public func foo(_: String) -> some Foo {
 39 |   return 679

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:43:12: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
 41 | 
 42 | // CHECK-LABEL: public func foo<T>(_ x: T) -> some OpaqueResultTypes::Foo where T : OpaqueResultTypes::Foo
 43 | @available(SwiftStdlib 5.1, *)
    |            `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
 44 | public func foo<T: Foo>(_ x: T) -> some Foo {
 45 |   return x

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:73:12: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
 71 | }
 72 | 
 73 | @available(SwiftStdlib 5.1, *)
    |            `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
 74 | public struct Bar<T>: AssocTypeInference {
 75 |   public init() {}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:78:14: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
 76 | 
 77 |   // CHECK-LABEL: public func foo(_: Swift::Int) -> some OpaqueResultTypes::Foo
 78 |   @available(SwiftStdlib 5.1, *)
    |              `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
 79 |   public func foo(_: Int) -> some Foo {
 80 |     return 20721

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:83:14: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
 81 |   }
 82 | 
 83 |   @available(SwiftStdlib 5.1, *)
    |              `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
 84 |   public func foo(_: String) -> some Foo {
 85 |     return 219

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:89:14: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
 87 | 
 88 |   // CHECK-LABEL: public func foo<U>(_ x: U) -> some OpaqueResultTypes::Foo where U : OpaqueResultTypes::Foo
 89 |   @available(SwiftStdlib 5.1, *)
    |              `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
 90 |   public func foo<U: Foo>(_ x: U) -> some Foo {
 91 |     return x

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:94:14: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
 92 |   }
 93 | 
 94 |   @available(SwiftStdlib 5.1, *)
    |              `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
 95 |   public struct Bas: AssocTypeInference {
 96 |     public init() {}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:99:16: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
 97 | 
 98 |     // CHECK-LABEL: public func foo(_: Swift::Int) -> some OpaqueResultTypes::Foo
 99 |     @available(SwiftStdlib 5.1, *)
    |                `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
100 |     public func foo(_: Int) -> some Foo {
101 |       return 20721

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:104:16: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
102 |     }
103 | 
104 |     @available(SwiftStdlib 5.1, *)
    |                `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
105 |     public func foo(_: String) -> some Foo {
106 |       return 219

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:110:16: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
108 | 
109 |     // CHECK-LABEL: public func foo<U>(_ x: U) -> some OpaqueResultTypes::Foo where U : OpaqueResultTypes::Foo
110 |     @available(SwiftStdlib 5.1, *)
    |                `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
111 |     public func foo<U: Foo>(_ x: U) -> some Foo {
112 |       return x

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:119:16: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
117 |       return 123
118 |     }
119 |     @available(SwiftStdlib 5.1, *)
    |                `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
120 |     public subscript() -> some Foo {
121 |       return 123

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:129:14: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
127 |   }
128 | 
129 |   @available(SwiftStdlib 5.1, *)
    |              `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
130 |   public struct Bass<U: Foo>: AssocTypeInference {
131 |     public init() {}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:134:16: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
132 | 
133 |     // CHECK-LABEL: public func foo(_: Swift::Int) -> some OpaqueResultTypes::Foo
134 |     @available(SwiftStdlib 5.1, *)
    |                `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
135 |     public func foo(_: Int) -> some Foo {
136 |       return 20721

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:139:16: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
137 |     }
138 | 
139 |     @available(SwiftStdlib 5.1, *)
    |                `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
140 |     public func foo(_: String) -> some Foo {
141 |       return 219

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:145:16: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
143 | 
144 |     // CHECK-LABEL: public func foo(_ x: U) -> some OpaqueResultTypes::Foo
145 |     @available(SwiftStdlib 5.1, *)
    |                `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
146 |     public func foo(_ x: U) -> some Foo {
147 |       return x

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:151:16: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
149 | 
150 |     // CHECK-LABEL: public func foo<V>(_ x: V) -> some OpaqueResultTypes::Foo where V : OpaqueResultTypes::Foo
151 |     @available(SwiftStdlib 5.1, *)
    |                `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
152 |     public func foo<V: Foo>(_ x: V) -> some Foo {
153 |       return x

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:159:16: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
157 |       return 123
158 |     }
159 |     @available(SwiftStdlib 5.1, *)
    |                `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
160 |     public subscript() -> some Foo {
161 |       return 123

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:173:14: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
171 |     return 123
172 |   }
173 |   @available(SwiftStdlib 5.1, *)
    |              `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
174 |   public subscript() -> some Foo {
175 |     return 123

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:183:12: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
181 | }
182 | 
183 | @available(SwiftStdlib 5.1, *)
    |            `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
184 | public struct Zim: AssocTypeInference {
185 |   public init() {}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:187:14: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
185 |   public init() {}
186 | 
187 |   @available(SwiftStdlib 5.1, *)
    |              `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
188 |   public func foo(_: Int) -> some Foo {
189 |     return 20721

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:192:14: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
190 |   }
191 | 
192 |   @available(SwiftStdlib 5.1, *)
    |              `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
193 |   public func foo(_: String) -> some Foo {
194 |     return 219

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:198:14: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
196 | 
197 |   // CHECK-LABEL: public func foo<U>(_ x: U) -> some OpaqueResultTypes::Foo where U : OpaqueResultTypes::Foo
198 |   @available(SwiftStdlib 5.1, *)
    |              `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
199 |   public func foo<U: Foo>(_ x: U) -> some Foo {
200 |     return x

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:203:14: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
201 |   }
202 | 
203 |   @available(SwiftStdlib 5.1, *)
    |              `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
204 |   public struct Zang: AssocTypeInference {
205 |     public init() {}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:207:16: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
205 |     public init() {}
206 | 
207 |     @available(SwiftStdlib 5.1, *)
    |                `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
208 |     public func foo(_: Int) -> some Foo {
209 |       return 20721

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:212:16: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
210 |     }
211 | 
212 |     @available(SwiftStdlib 5.1, *)
    |                `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
213 |     public func foo(_: String) -> some Foo {
214 |       return 219

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:218:16: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
216 | 
217 |     // CHECK-LABEL: public func foo<U>(_ x: U) -> some OpaqueResultTypes::Foo where U : OpaqueResultTypes::Foo
218 |     @available(SwiftStdlib 5.1, *)
    |                `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
219 |     public func foo<U: Foo>(_ x: U) -> some Foo {
220 |       return x

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:227:16: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
225 |       return 123
226 |     }
227 |     @available(SwiftStdlib 5.1, *)
    |                `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
228 |     public subscript() -> some Foo {
229 |       return 123

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:233:14: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
231 |   }
232 | 
233 |   @available(SwiftStdlib 5.1, *)
    |              `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
234 |   public struct Zung<U: Foo>: AssocTypeInference {
235 |     public init() {}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:238:16: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
236 | 
237 |     // CHECK-LABEL: public func foo(_: Swift::Int) -> some OpaqueResultTypes::Foo
238 |     @available(SwiftStdlib 5.1, *)
    |                `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
239 |     public func foo(_: Int) -> some Foo {
240 |       return 20721

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:243:16: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
241 |     }
242 | 
243 |     @available(SwiftStdlib 5.1, *)
    |                `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
244 |     public func foo(_: String) -> some Foo {
245 |       return 219

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:248:16: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
246 |     }
247 | 
248 |     @available(SwiftStdlib 5.1, *)
    |                `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
249 |     public func foo(_ x: U) -> some Foo {
250 |       return x

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:254:16: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
252 | 
253 |     // CHECK-LABEL: public func foo<V>(_ x: V) -> some OpaqueResultTypes::Foo where V : OpaqueResultTypes::Foo
254 |     @available(SwiftStdlib 5.1, *)
    |                `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
255 |     public func foo<V: Foo>(_ x: V) -> some Foo {
256 |       return x

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:263:16: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
261 |       return 123
262 |     }
263 |     @available(SwiftStdlib 5.1, *)
    |                `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
264 |     public subscript() -> some Foo {
265 |       return 123

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:277:14: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
275 |     return 123
276 |   }
277 |   @available(SwiftStdlib 5.1, *)
    |              `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
278 |   public subscript() -> some Foo {
279 |     return 123

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:28:16: error: cannot find type 'Foo' in scope
 26 | 
 27 | public protocol Foo {}
 28 | extension Int: Foo {}
    |                `- error: cannot find type 'Foo' in scope
 29 | 
 30 | // CHECK-LABEL: public func foo(_: Swift::Int) -> some OpaqueResultTypes::Foo

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:33:10: error: return type of local function 'foo' requires that 'Int' conform to 'Foo'
 30 | // CHECK-LABEL: public func foo(_: Swift::Int) -> some OpaqueResultTypes::Foo
 31 | @available(SwiftStdlib 5.1, *)
 32 | public func foo(_: Int) -> some Foo {
    |                            `- note: opaque return type declared here
 33 |   return 1738
    |          `- error: return type of local function 'foo' requires that 'Int' conform to 'Foo'
 34 | }
 35 | 

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:39:10: error: return type of local function 'foo' requires that 'Int' conform to 'Foo'
 36 | // CHECK-LABEL: @inlinable public func foo(_: Swift::String) -> some OpaqueResultTypes::Foo {
 37 | @available(SwiftStdlib 5.1, *)
 38 | @inlinable public func foo(_: String) -> some Foo {
    |                                          `- note: opaque return type declared here
 39 |   return 679
    |          `- error: return type of local function 'foo' requires that 'Int' conform to 'Foo'
 40 | }
 41 | 

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:51:12: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
 49 | // CHECK-NEXT:    get
 50 | // CHECK-NEXT:  }
 51 | @available(SwiftStdlib 5.1, *)
    |            `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
 52 | public var globalComputedVar: some Foo { 123 }
 53 | 

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:52:42: error: return type of var 'globalComputedVar' requires that 'Int' conform to 'Foo'
 50 | // CHECK-NEXT:  }
 51 | @available(SwiftStdlib 5.1, *)
 52 | public var globalComputedVar: some Foo { 123 }
    |                               |          `- error: return type of var 'globalComputedVar' requires that 'Int' conform to 'Foo'
    |                               `- note: opaque return type declared here
 53 | 
 54 | // CHECK-LABEL: public var globalVar: some OpaqueResultTypes::Foo{{$}}

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:55:12: warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
 53 | 
 54 | // CHECK-LABEL: public var globalVar: some OpaqueResultTypes::Foo{{$}}
 55 | @available(SwiftStdlib 5.1, *)
    |            `- warning: unrecognized platform name 'SwiftStdlib' [#AvailabilityUnrecognizedName]
 56 | public var globalVar: some Foo = 123
 57 | 

/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:56:34: error: return type of var 'globalVar' requires that 'Int' conform to 'Foo'
 54 | // CHECK-LABEL: public var globalVar: some OpaqueResultTypes::Foo{{$}}
 55 | @available(SwiftStdlib 5.1, *)
 56 | public var globalVar: some Foo = 123
    |                       |          `- error: return type of var 'globalVar' requires that 'Int' conform to 'Foo'
    |                       `- note: opaque return type declared here
 57 | 
 58 | // CHECK-LABEL: public var globalVarTuple: (some OpaqueResultTypes::Foo, some OpaqueResultTypes::Foo){{$}}

Assertion failed: (std::find(Bindings.begin(), Bindings.end(), binding) == Bindings.end()), function addBinding at CSBindings.cpp:1681.
(to display assertion configuration options: -Xllvm -assert-help)

Please submit a bug report (https://swift.org/contributing/#reporting-bugs) and include the crash backtrace.
Stack dump:
0.	Program arguments: /usr/bin/swift-frontend -emit-ir -O -sil-verify-all -enable-experimental-feature NonescapableTypes /home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift
1.	Swift version 6.5-dev (LLVM 7c86461e21cca7e, Swift 6da4da7153e8252)
2.	Compiling with effective version 5.10
3.	While evaluating request TypeCheckPrimaryFileRequest(source_file "/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift")
4.	While evaluating request TypeCheckFunctionBodyRequest(f56f36b2.(file).foo()@/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:12:6)
5.	While type-checking statement at [/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:12:12 - line:311:1] RangeText="{

//--- test.swift.expected
// expected-note@+1{{to match this opening '{'}}
func foo() {

// expected-error@+1{{expected '}' at end of brace statement}}

// --- Seed B ---
// RUN: %empty-directory(%t)
// RUN: %target-swift-emit-module-interface(%t/OpaqueResultTypes.swiftinterface) %s -module-name OpaqueResultTypes
// RUN: %target-swift-typecheck-module-from-interface(%t/OpaqueResultTypes.swiftinterface) -module-name OpaqueResultTypes
// RUN: %FileCheck %s < %t/OpaqueResultTypes.swiftinterface
// RUN: %target-swift-frontend -I %t -typecheck -verify -verify-ignore-unrelated %S/Inputs/opaque-result-types-client.swift

public protocol Foo {}
extension Int: Foo {}

// CHECK-LABEL: public func foo(_: Swift::Int) -> some OpaqueResultTypes::Foo
@available(SwiftStdlib 5.1, *)
public func foo(_: Int) -> some Foo {
  return 1738
}

// CHECK-LABEL: @inlinable public func foo(_: Swift::String) -> some OpaqueResultTypes::Foo {
@available(SwiftStdlib 5.1, *)
@inlinable public func foo(_: String) -> some Foo {
  return 679
}

// CHECK-LABEL: public func foo<T>(_ x: T) -> some OpaqueResultTypes::Foo where T : OpaqueResultTypes::Foo
@available(SwiftStdlib 5.1, *)
public func foo<T: Foo>(_ x: T) -> some Foo {
  return x
}

// CHECK-LABEL: public var globalComputedVar: some OpaqueResultTypes::Foo {
// CHECK-NEXT:    get
// CHECK-NEXT:  }
@available(SwiftStdlib 5.1, *)
public var globalComputedVar: some Foo { 123 }

// CHECK-LABEL: public var globalVar: some OpaqueResultTypes::Foo{{$}}
@available(SwiftStdlib 5.1, *)
public var globalVar: some Foo = 123

// CHECK-LABEL: public var globalVarTuple: (some OpaqueResultTypes::Foo, some OpaqueResultTypes::Foo){{$}}
@available(SwiftStdlib 5.1, *)
public var globalVarTuple: (some Foo, some Foo) = (123, foo(123))

public protocol AssocTypeInference {
  associatedtype Assoc: Foo
  associatedtype AssocProperty: Foo
  associatedtype AssocSubscript: Foo

  func foo(_: Int) -> Assoc

  var prop: AssocProperty { get }
  subscript() -> AssocSubscript { get }
}

@available(SwiftStdlib 5.1, *)
public struct Bar<T>: AssocTypeInference {
  public init() {}

  // CHECK-LABEL: public func foo(_: Swift::Int) -> some OpaqueResultTypes::Foo
  @available(SwiftStdlib 5.1, *)
  public func foo(_: Int) -> some Foo {
    return 20721
  }

  @available(SwiftStdlib 5.1, *)
  public func foo(_: String) -> some Foo {
    return 219
  }

  // CHECK-LABEL: public func foo<U>(_ x: U) -> some OpaqueResultTypes::Foo where U : OpaqueResultTypes::Foo
  @available(SwiftStdlib 5.1, *)
  public func foo<U: Foo>(_ x: U) -> some Foo {
    return x
  }

  @available(SwiftStdlib 5.1, *)
  public struct Bas: AssocTypeInference {
    public init() {}

    // CHECK-LABEL: public func foo(_: Swift::Int) -> some OpaqueResultTypes::Foo
    @available(SwiftStdlib 5.1, *)
    public func foo(_: Int) -> some Foo {
      return 20721
    }

    @available(SwiftStdlib 5.1, *)
    public func foo(_: String) -> some Foo {
      return 219
    }

    // CHECK-LABEL: public func foo<U>(_ x: U) -> some OpaqueResultTypes::Foo where U : OpaqueResultTypes::Foo
    @available(SwiftStdlib 5.1, *)
    public func foo<U: Foo>(_ x: U) -> some Foo {
      return x
    }

    @available(SwiftStdlib 5.1, *)
    public var prop: some Foo {
      return 123
    }
    @available(SwiftStdlib 5.1, *)
    public subscript() -> some Foo {
      return 123
    }

    // CHECK-LABEL: public typealias Assoc = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<T>
    // CHECK-LABEL: public typealias AssocProperty = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<T>
    // CHECK-LABEL: public typealias AssocSubscript = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<T>
  }

  @available(SwiftStdlib 5.1, *)
  public struct Bass<U: Foo>: AssocTypeInference {
    public init() {}

    // CHECK-LABEL: public func foo(_: Swift::Int) -> some OpaqueResultTypes::Foo
    @available(SwiftStdlib 5.1, *)
    public func foo(_: Int) -> some Foo {
      return 20721
    }

    @available(SwiftStdlib 5.1, *)
    public func foo(_: String) -> some Foo {
      return 219
    }

    // CHECK-LABEL: public func foo(_ x: U) -> some OpaqueResultTypes::Foo
    @available(SwiftStdlib 5.1, *)
    public func foo(_ x: U) -> some Foo {
      return x
    }

    // CHECK-LABEL: public func foo<V>(_ x: V) -> some OpaqueResultTypes::Foo where V : OpaqueResultTypes::Foo
    @available(SwiftStdlib 5.1, *)
    public func foo<V: Foo>(_ x: V) -> some Foo {
      return x
    }
    @available(SwiftStdlib 5.1, *)
    public var prop: some Foo {
      return 123
    }
    @available(SwiftStdlib 5.1, *)
    public subscript() -> some Foo {
      return 123
    }

    // CHECK-LABEL: public typealias Assoc = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<T, U>
    // CHECK-LABEL: public typealias AssocProperty = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<T, U>
    // CHECK-LABEL: public typealias AssocSubscript = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<T, U>
  }

  @available(SwiftStdlib 5.1, *)
  public var prop: some Foo {
    return 123
  }
  @available(SwiftStdlib 5.1, *)
  public subscript() -> some Foo {
    return 123
  }

  // CHECK-LABEL: public typealias Assoc = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<T>
  // CHECK-LABEL: public typealias AssocProperty = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<T>
  // CHECK-LABEL: public typealias AssocSubscript = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<T>
}

@available(SwiftStdlib 5.1, *)
public struct Zim: AssocTypeInference {
  public init() {}

  @available(SwiftStdlib 5.1, *)
  public func foo(_: Int) -> some Foo {
    return 20721
  }

  @available(SwiftStdlib 5.1, *)
  public func foo(_: String) -> some Foo {
    return 219
  }

  // CHECK-LABEL: public func foo<U>(_ x: U) -> some OpaqueResultTypes::Foo where U : OpaqueResultTypes::Foo
  @available(SwiftStdlib 5.1, *)
  public func foo<U: Foo>(_ x: U) -> some Foo {
    return x
  }

  @available(SwiftStdlib 5.1, *)
  public struct Zang: AssocTypeInference {
    public init() {}

    @available(SwiftStdlib 5.1, *)
    public func foo(_: Int) -> some Foo {
      return 20721
    }

    @available(SwiftStdlib 5.1, *)
    public func foo(_: String) -> some Foo {
      return 219
    }

    // CHECK-LABEL: public func foo<U>(_ x: U) -> some OpaqueResultTypes::Foo where U : OpaqueResultTypes::Foo
    @available(SwiftStdlib 5.1, *)
    public func foo<U: Foo>(_ x: U) -> some Foo {
      return x
    }

    @available(SwiftStdlib 5.1, *)
    public var prop: some Foo {
      return 123
    }
    @available(SwiftStdlib 5.1, *)
    public subscript() -> some Foo {
      return 123
    }
  }

  @available(SwiftStdlib 5.1, *)
  public struct Zung<U: Foo>: AssocTypeInference {
    public init() {}

    // CHECK-LABEL: public func foo(_: Swift::Int) -> some OpaqueResultTypes::Foo
    @available(SwiftStdlib 5.1, *)
    public func foo(_: Int) -> some Foo {
      return 20721
    }

    @available(SwiftStdlib 5.1, *)
    public func foo(_: String) -> some Foo {
      return 219
    }

    @available(SwiftStdlib 5.1, *)
    public func foo(_ x: U) -> some Foo {
      return x
    }

    // CHECK-LABEL: public func foo<V>(_ x: V) -> some OpaqueResultTypes::Foo where V : OpaqueResultTypes::Foo
    @available(SwiftStdlib 5.1, *)
    public func foo<V: Foo>(_ x: V) -> some Foo {
      return x
    }

    @available(SwiftStdlib 5.1, *)
    public var prop: some Foo {
      return 123
    }
    @available(SwiftStdlib 5.1, *)
    public subscript() -> some Foo {
      return 123
    }

    // CHECK-LABEL: public typealias Assoc = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<U>
    // CHECK-LABEL: public typealias AssocProperty = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<U>
    // CHECK-LABEL: public typealias AssocSubscript = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<U>
  }

  @available(SwiftStdlib 5.1, *)
  public var prop: some Foo {
    return 123
  }
  @available(SwiftStdlib 5.1, *)
  public subscript() -> some Foo {
    return 123
  }
}
var _ffl_sentinel: Int = 0
// --- Bug Primitive ---

// P5: Dynamic casting chain stress
protocol _FflCastable: AnyObject {}
class _FflBase: _FflCastable {
    var v: Int = 0
}
class _FflDerived: _FflBase {
    var extra: String = ""
}
func _ffl_p5_cast(_ obj: AnyObject) -> String {
    if let d = obj as? _FflDerived { return "derived:\(d.extra)" }
    if let b = obj as? _FflBase    { return "base:\(b.v)" }
    if let s = obj as? CustomStringConvertible { return s.description }
    return "unknown:\(type(of: obj))"
}
do {
    let _ffl_seed = String(describing: _ffl_sentinel).count
    let _ffl_obj: AnyObject = _ffl_seed % 2 == 0
        ? _FflDerived() as AnyObject
        : _FflBase()    as AnyObject
    _ = _ffl_p5_cast(_ffl_obj)
    // Force-cast through Any — stresses value-witness metadata path
    let _ffl_any: Any = _ffl_sentinel
    _ = _ffl_any as? Int
    _ = _ffl_any as? String
    _ = _ffl_any as? Bool
    _ = type(of: _ffl_any)
"
6.	While type-checking 'foo()' (at /home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:16:1)
7.	While evaluating request TypeCheckFunctionBodyRequest(f56f36b2.(file).foo().foo()@/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:16:6)
8.	While type-checking statement at [/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:16:12 - line:311:1] RangeText="{

// expected-error@+1{{expected '}' at end of brace statement}}

// --- Seed B ---
// RUN: %empty-directory(%t)
// RUN: %target-swift-emit-module-interface(%t/OpaqueResultTypes.swiftinterface) %s -module-name OpaqueResultTypes
// RUN: %target-swift-typecheck-module-from-interface(%t/OpaqueResultTypes.swiftinterface) -module-name OpaqueResultTypes
// RUN: %FileCheck %s < %t/OpaqueResultTypes.swiftinterface
// RUN: %target-swift-frontend -I %t -typecheck -verify -verify-ignore-unrelated %S/Inputs/opaque-result-types-client.swift

public protocol Foo {}
extension Int: Foo {}

// CHECK-LABEL: public func foo(_: Swift::Int) -> some OpaqueResultTypes::Foo
@available(SwiftStdlib 5.1, *)
public func foo(_: Int) -> some Foo {
  return 1738
}

// CHECK-LABEL: @inlinable public func foo(_: Swift::String) -> some OpaqueResultTypes::Foo {
@available(SwiftStdlib 5.1, *)
@inlinable public func foo(_: String) -> some Foo {
  return 679
}

// CHECK-LABEL: public func foo<T>(_ x: T) -> some OpaqueResultTypes::Foo where T : OpaqueResultTypes::Foo
@available(SwiftStdlib 5.1, *)
public func foo<T: Foo>(_ x: T) -> some Foo {
  return x
}

// CHECK-LABEL: public var globalComputedVar: some OpaqueResultTypes::Foo {
// CHECK-NEXT:    get
// CHECK-NEXT:  }
@available(SwiftStdlib 5.1, *)
public var globalComputedVar: some Foo { 123 }

// CHECK-LABEL: public var globalVar: some OpaqueResultTypes::Foo{{$}}
@available(SwiftStdlib 5.1, *)
public var globalVar: some Foo = 123

// CHECK-LABEL: public var globalVarTuple: (some OpaqueResultTypes::Foo, some OpaqueResultTypes::Foo){{$}}
@available(SwiftStdlib 5.1, *)
public var globalVarTuple: (some Foo, some Foo) = (123, foo(123))

public protocol AssocTypeInference {
  associatedtype Assoc: Foo
  associatedtype AssocProperty: Foo
  associatedtype AssocSubscript: Foo

  func foo(_: Int) -> Assoc

  var prop: AssocProperty { get }
  subscript() -> AssocSubscript { get }
}

@available(SwiftStdlib 5.1, *)
public struct Bar<T>: AssocTypeInference {
  public init() {}

  // CHECK-LABEL: public func foo(_: Swift::Int) -> some OpaqueResultTypes::Foo
  @available(SwiftStdlib 5.1, *)
  public func foo(_: Int) -> some Foo {
    return 20721
  }

  @available(SwiftStdlib 5.1, *)
  public func foo(_: String) -> some Foo {
    return 219
  }

  // CHECK-LABEL: public func foo<U>(_ x: U) -> some OpaqueResultTypes::Foo where U : OpaqueResultTypes::Foo
  @available(SwiftStdlib 5.1, *)
  public func foo<U: Foo>(_ x: U) -> some Foo {
    return x
  }

  @available(SwiftStdlib 5.1, *)
  public struct Bas: AssocTypeInference {
    public init() {}

    // CHECK-LABEL: public func foo(_: Swift::Int) -> some OpaqueResultTypes::Foo
    @available(SwiftStdlib 5.1, *)
    public func foo(_: Int) -> some Foo {
      return 20721
    }

    @available(SwiftStdlib 5.1, *)
    public func foo(_: String) -> some Foo {
      return 219
    }

    // CHECK-LABEL: public func foo<U>(_ x: U) -> some OpaqueResultTypes::Foo where U : OpaqueResultTypes::Foo
    @available(SwiftStdlib 5.1, *)
    public func foo<U: Foo>(_ x: U) -> some Foo {
      return x
    }

    @available(SwiftStdlib 5.1, *)
    public var prop: some Foo {
      return 123
    }
    @available(SwiftStdlib 5.1, *)
    public subscript() -> some Foo {
      return 123
    }

    // CHECK-LABEL: public typealias Assoc = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<T>
    // CHECK-LABEL: public typealias AssocProperty = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<T>
    // CHECK-LABEL: public typealias AssocSubscript = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<T>
  }

  @available(SwiftStdlib 5.1, *)
  public struct Bass<U: Foo>: AssocTypeInference {
    public init() {}

    // CHECK-LABEL: public func foo(_: Swift::Int) -> some OpaqueResultTypes::Foo
    @available(SwiftStdlib 5.1, *)
    public func foo(_: Int) -> some Foo {
      return 20721
    }

    @available(SwiftStdlib 5.1, *)
    public func foo(_: String) -> some Foo {
      return 219
    }

    // CHECK-LABEL: public func foo(_ x: U) -> some OpaqueResultTypes::Foo
    @available(SwiftStdlib 5.1, *)
    public func foo(_ x: U) -> some Foo {
      return x
    }

    // CHECK-LABEL: public func foo<V>(_ x: V) -> some OpaqueResultTypes::Foo where V : OpaqueResultTypes::Foo
    @available(SwiftStdlib 5.1, *)
    public func foo<V: Foo>(_ x: V) -> some Foo {
      return x
    }
    @available(SwiftStdlib 5.1, *)
    public var prop: some Foo {
      return 123
    }
    @available(SwiftStdlib 5.1, *)
    public subscript() -> some Foo {
      return 123
    }

    // CHECK-LABEL: public typealias Assoc = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<T, U>
    // CHECK-LABEL: public typealias AssocProperty = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<T, U>
    // CHECK-LABEL: public typealias AssocSubscript = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<T, U>
  }

  @available(SwiftStdlib 5.1, *)
  public var prop: some Foo {
    return 123
  }
  @available(SwiftStdlib 5.1, *)
  public subscript() -> some Foo {
    return 123
  }

  // CHECK-LABEL: public typealias Assoc = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<T>
  // CHECK-LABEL: public typealias AssocProperty = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<T>
  // CHECK-LABEL: public typealias AssocSubscript = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<T>
}

@available(SwiftStdlib 5.1, *)
public struct Zim: AssocTypeInference {
  public init() {}

  @available(SwiftStdlib 5.1, *)
  public func foo(_: Int) -> some Foo {
    return 20721
  }

  @available(SwiftStdlib 5.1, *)
  public func foo(_: String) -> some Foo {
    return 219
  }

  // CHECK-LABEL: public func foo<U>(_ x: U) -> some OpaqueResultTypes::Foo where U : OpaqueResultTypes::Foo
  @available(SwiftStdlib 5.1, *)
  public func foo<U: Foo>(_ x: U) -> some Foo {
    return x
  }

  @available(SwiftStdlib 5.1, *)
  public struct Zang: AssocTypeInference {
    public init() {}

    @available(SwiftStdlib 5.1, *)
    public func foo(_: Int) -> some Foo {
      return 20721
    }

    @available(SwiftStdlib 5.1, *)
    public func foo(_: String) -> some Foo {
      return 219
    }

    // CHECK-LABEL: public func foo<U>(_ x: U) -> some OpaqueResultTypes::Foo where U : OpaqueResultTypes::Foo
    @available(SwiftStdlib 5.1, *)
    public func foo<U: Foo>(_ x: U) -> some Foo {
      return x
    }

    @available(SwiftStdlib 5.1, *)
    public var prop: some Foo {
      return 123
    }
    @available(SwiftStdlib 5.1, *)
    public subscript() -> some Foo {
      return 123
    }
  }

  @available(SwiftStdlib 5.1, *)
  public struct Zung<U: Foo>: AssocTypeInference {
    public init() {}

    // CHECK-LABEL: public func foo(_: Swift::Int) -> some OpaqueResultTypes::Foo
    @available(SwiftStdlib 5.1, *)
    public func foo(_: Int) -> some Foo {
      return 20721
    }

    @available(SwiftStdlib 5.1, *)
    public func foo(_: String) -> some Foo {
      return 219
    }

    @available(SwiftStdlib 5.1, *)
    public func foo(_ x: U) -> some Foo {
      return x
    }

    // CHECK-LABEL: public func foo<V>(_ x: V) -> some OpaqueResultTypes::Foo where V : OpaqueResultTypes::Foo
    @available(SwiftStdlib 5.1, *)
    public func foo<V: Foo>(_ x: V) -> some Foo {
      return x
    }

    @available(SwiftStdlib 5.1, *)
    public var prop: some Foo {
      return 123
    }
    @available(SwiftStdlib 5.1, *)
    public subscript() -> some Foo {
      return 123
    }

    // CHECK-LABEL: public typealias Assoc = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<U>
    // CHECK-LABEL: public typealias AssocProperty = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<U>
    // CHECK-LABEL: public typealias AssocSubscript = @_opaqueReturnTypeOf("{{.*}}", 0) {{.*}}<U>
  }

  @available(SwiftStdlib 5.1, *)
  public var prop: some Foo {
    return 123
  }
  @available(SwiftStdlib 5.1, *)
  public subscript() -> some Foo {
    return 123
  }
}
var _ffl_sentinel: Int = 0
// --- Bug Primitive ---

// P5: Dynamic casting chain stress
protocol _FflCastable: AnyObject {}
class _FflBase: _FflCastable {
    var v: Int = 0
}
class _FflDerived: _FflBase {
    var extra: String = ""
}
func _ffl_p5_cast(_ obj: AnyObject) -> String {
    if let d = obj as? _FflDerived { return "derived:\(d.extra)" }
    if let b = obj as? _FflBase    { return "base:\(b.v)" }
    if let s = obj as? CustomStringConvertible { return s.description }
    return "unknown:\(type(of: obj))"
}
do {
    let _ffl_seed = String(describing: _ffl_sentinel).count
    let _ffl_obj: AnyObject = _ffl_seed % 2 == 0
        ? _FflDerived() as AnyObject
        : _FflBase()    as AnyObject
    _ = _ffl_p5_cast(_ffl_obj)
    // Force-cast through Any — stresses value-witness metadata path
    let _ffl_any: Any = _ffl_sentinel
    _ = _ffl_any as? Int
    _ = _ffl_any as? String
    _ = _ffl_any as? Bool
    _ = type(of: _ffl_any)
"
9.	While type-checking declaration 0x5604f6ce7ad0 (at /home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:60:8)
10.	While type-checking expression at [/home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:60:51 - line:60:65] RangeText="(123, foo(123)"
11.	While type-checking-target starting at /home/fuzz/WorkSpace/fusion-fuzz/.fused/swift/tmp97gs6ujo/f56f36b2.swift:60:51
12.	Assertion failed: (std::find(Bindings.begin(), Bindings.end(), binding) == Bindings.end()), function addBinding at CSBindings.cpp:1681.
| 	(to display assertion configuration options: -Xllvm -assert-help)
 #0 0x00005604e3af9a58 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/bin/swift-frontend+0x8bc7a58)
 #1 0x00005604e3af7275 llvm::sys::RunSignalHandlers() (/usr/bin/swift-frontend+0x8bc5275)
 #2 0x00005604e3afa811 SignalHandler(int, siginfo_t*, void*) Signals.cpp:0:0
 #3 0x00007fea92846330 (/lib/x86_64-linux-gnu/libc.so.6+0x45330)
 #4 0x00007fea9289fb2c pthread_kill (/lib/x86_64-linux-gnu/libc.so.6+0x9eb2c)
 #5 0x00007fea9284627e raise (/lib/x86_64-linux-gnu/libc.so.6+0x4527e)
 #6 0x00007fea928298ff abort (/lib/x86_64-linux-gnu/libc.so.6+0x288ff)
 #7 0x00005604ddc1be72 (/usr/bin/swift-frontend+0x2ce9e72)
 #8 0x00005604ddc1be24 (/usr/bin/swift-frontend+0x2ce9e24)
 #9 0x00005604dd2d1e66 swift::constraints::inference::BindingSet::addBinding(swift::constraints::inference::PotentialBinding) (/usr/bin/swift-frontend+0x239fe66)
#10 0x00005604dd2d131b swift::constraints::inference::BindingSet::BindingSet(swift::constraints::ConstraintSystem&, swift::TypeVariableType*, swift::constraints::inference::PotentialBindings const&) (/usr/bin/swift-frontend+0x239f31b)
#11 0x00005604dd2da926 swift::constraints::ConstraintSystem::determineBestBindings() (/usr/bin/swift-frontend+0x23a8926)
#12 0x00005604dcef566f swift::constraints::ComponentStep::take(bool) (/usr/bin/swift-frontend+0x1fc366f)
#13 0x00005604dcee259d swift::constraints::ConstraintSystem::solveImpl(llvm::SmallVectorImpl<swift::constraints::Solution>&) (/usr/bin/swift-frontend+0x1fb059d)
#14 0x00005604dcf8e229 swift::constraints::ConstraintSystem::salvage() (/usr/bin/swift-frontend+0x205c229)
#15 0x00005604dcee2c85 swift::constraints::ConstraintSystem::solve(swift::constraints::SyntacticElementTarget&, swift::FreeTypeVariableBinding) (/usr/bin/swift-frontend+0x1fb0c85)
#16 0x00005604dd0a8dc5 swift::TypeChecker::typeCheckTarget(swift::constraints::SyntacticElementTarget&, swift::optionset::OptionSet<swift::TypeCheckExprFlags, unsigned int>, swift::DiagnosticTransaction*) (/usr/bin/swift-frontend+0x2176dc5)
#17 0x00005604dd0a8c41 swift::TypeChecker::typeCheckExpression(swift::constraints::SyntacticElementTarget&, swift::optionset::OptionSet<swift::TypeCheckExprFlags, unsigned int>, swift::DiagnosticTransaction*) (/usr/bin/swift-frontend+0x2176c41)
#18 0x00005604dd0aab35 swift::TypeChecker::typeCheckBinding(swift::Pattern*&, swift::Expr*&, swift::DeclContext*, swift::Type, swift::PatternBindingDecl*, unsigned int, swift::optionset::OptionSet<swift::TypeCheckExprFlags, unsigned int>) (/usr/bin/swift-frontend+0x2178b35)
#19 0x00005604dd0aae2a swift::TypeChecker::typeCheckPatternBinding(swift::PatternBindingDecl*, unsigned int, swift::Type, swift::optionset::OptionSet<swift::TypeCheckExprFlags, unsigned int>) (/usr/bin/swift-frontend+0x2178e2a)
#20 0x00005604dd0f702f (anonymous namespace)::DeclChecker::visit(swift::Decl*) TypeCheckDeclPrimary.cpp:0:0
#21 0x00005604dd0f6b74 swift::TypeChecker::typeCheckDecl(swift::Decl*) (/usr/bin/swift-frontend+0x21c4b74)
#22 0x00005604dd1b597c swift::ASTVisitor<(anonymous namespace)::StmtChecker, void, swift::Stmt*, void, void, void, void>::visit(swift::Stmt*) TypeCheckStmt.cpp:0:0
#23 0x00005604dd1b81cc bool (anonymous namespace)::StmtChecker::typeCheckStmt<swift::BraceStmt>(swift::BraceStmt*&) TypeCheckStmt.cpp:0:0
#24 0x00005604dd1b0514 (anonymous namespace)::StmtChecker::typeCheckBody(swift::BraceStmt*&) TypeCheckStmt.cpp:0:0
#25 0x00005604dd1b0147 swift::TypeCheckFunctionBodyRequest::evaluate(swift::Evaluator&, swift::AbstractFunctionDecl*) const (/usr/bin/swift-frontend+0x227e147)
#26 0x00005604dd88bcee swift::TypeCheckFunctionBodyRequest::OutputType swift::Evaluator::getResultUncached<swift::TypeCheckFunctionBodyRequest, swift::TypeCheckFunctionBodyRequest::OutputType swift::evaluateOrDefault<swift::TypeCheckFunctionBodyRequest>(swift::Evaluator&, swift::TypeCheckFunctionBodyRequest, swift::TypeCheckFunctionBodyRequest::OutputType)::'lambda'()>(swift::TypeCheckFunctionBodyRequest const&, swift::TypeCheckFunctionBodyRequest::OutputType swift::evaluateOrDefault<swift::TypeCheckFunctionBodyRequest>(swift::Evaluator&, swift::TypeCheckFunctionBodyRequest, swift::TypeCheckFunctionBodyRequest::OutputType)::'lambda'()) crtstuff.c:0:0
#27 0x00005604dd7db3d9 swift::AbstractFunctionDecl::getTypecheckedBody() const (/usr/bin/swift-frontend+0x28a93d9)
#28 0x00005604dd0ff170 (anonymous namespace)::DeclChecker::visitFuncDecl(swift::FuncDecl*) TypeCheckDeclPrimary.cpp:0:0
#29 0x00005604dd0f6cd1 (anonymous namespace)::DeclChecker::visit(swift::Decl*) TypeCheckDeclPrimary.cpp:0:0
#30 0x00005604dd0f6b74 swift::TypeChecker::typeCheckDecl(swift::Decl*) (/usr/bin/swift-frontend+0x21c4b74)
#31 0x00005604dd1b597c swift::ASTVisitor<(anonymous namespace)::StmtChecker, void, swift::Stmt*, void, void, void, void>::visit(swift::Stmt*) TypeCheckStmt.cpp:0:0
#32 0x00005604dd1b81cc bool (anonymous namespace)::StmtChecker::typeCheckStmt<swift::BraceStmt>(swift::BraceStmt*&) TypeCheckStmt.cpp:0:0
#33 0x00005604dd1b0514 (anonymous namespace)::StmtChecker::typeCheckBody(swift::BraceStmt*&) TypeCheckStmt.cpp:0:0
#34 0x00005604dd1b0147 swift::TypeCheckFunctionBodyRequest::evaluate(swift::Evaluator&, swift::AbstractFunctionDecl*) const (/usr/bin/swift-frontend+0x227e147)
#35 0x00005604dd88bcee swift::TypeCheckFunctionBodyRequest::OutputType swift::Evaluator::getResultUncached<swift::TypeCheckFunctionBodyRequest, swift::TypeCheckFunctionBodyRequest::OutputType swift::evaluateOrDefault<swift::TypeCheckFunctionBodyRequest>(swift::Evaluator&, swift::TypeCheckFunctionBodyRequest, swift::TypeCheckFunctionBodyRequest::OutputType)::'lambda'()>(swift::TypeCheckFunctionBodyRequest const&, swift::TypeCheckFunctionBodyRequest::OutputType swift::evaluateOrDefault<swift::TypeCheckFunctionBodyRequest>(swift::Evaluator&, swift::TypeCheckFunctionBodyRequest, swift::TypeCheckFunctionBodyRequest::OutputType)::'lambda'()) crtstuff.c:0:0
#36 0x00005604dd7db3d9 swift::AbstractFunctionDecl::getTypecheckedBody() const (/usr/bin/swift-frontend+0x28a93d9)
#37 0x00005604dd970a48 swift::SourceFile::typeCheckDelayedFunctions() (/usr/bin/swift-frontend+0x2a3ea48)
#38 0x00005604dd22f58d swift::TypeCheckPrimaryFileRequest::evaluate(swift::Evaluator&, swift::SourceFile*) const (/usr/bin/swift-frontend+0x22fd58d)
#39 0x00005604dd233e6b swift::TypeCheckPrimaryFileRequest::OutputType swift::Evaluator::getResultUncached<swift::TypeCheckPrimaryFileRequest, swift::TypeCheckPrimaryFileRequest::OutputType swift::evaluateOrDefault<swift::TypeCheckPrimaryFileRequest>(swift::Evaluator&, swift::TypeCheckPrimaryFileRequest, swift::TypeCheckPrimaryFileRequest::OutputType)::'lambda'()>(swift::TypeCheckPrimaryFileRequest const&, swift::TypeCheckPrimaryFileRequest::OutputType swift::evaluateOrDefault<swift::TypeCheckPrimaryFileRequest>(swift::Evaluator&, swift::TypeCheckPrimaryFileRequest, swift::TypeCheckPrimaryFileRequest::OutputType)::'lambda'()) crtstuff.c:0:0
#40 0x00005604dd22f3d8 swift::performTypeChecking(swift::SourceFile&) (/usr/bin/swift-frontend+0x22fd3d8)
#41 0x00005604dbcfa499 bool llvm::function_ref<bool (swift::SourceFile&)>::callback_fn<swift::CompilerInstance::performSema()::$_10>(long, swift::SourceFile&) Frontend.cpp:0:0
#42 0x00005604dbcee90e swift::CompilerInstance::forEachFileToTypeCheck(llvm::function_ref<bool (swift::SourceFile&)>) (/usr/bin/swift-frontend+0xdbc90e)
#43 0x00005604dbcee68b swift::CompilerInstance::performSema() (/usr/bin/swift-frontend+0xdbc68b)
#44 0x00005604db958f32 withSemanticAnalysis(swift::CompilerInstance&, swift::FrontendObserver*, llvm::function_ref<bool (swift::CompilerInstance&)>, bool) FrontendTool.cpp:0:0
#45 0x00005604db9469a5 performCompile(swift::CompilerInstance&, int&, swift::FrontendObserver*, llvm::ArrayRef<char const*>) FrontendTool.cpp:0:0
#46 0x00005604db94362e swift::performFrontend(llvm::ArrayRef<char const*>, char const*, void*, swift::FrontendObserver*) (/usr/bin/swift-frontend+0xa1162e)
#47 0x00005604db667d21 swift::mainEntry(int, char const**) (/usr/bin/swift-frontend+0x735d21)
#48 0x00007fea9282b1ca (/lib/x86_64-linux-gnu/libc.so.6+0x2a1ca)
#49 0x00007fea9282b28b __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28b)
#50 0x00005604db666c15 _start (/usr/bin/swift-frontend+0x734c15)

*** Signal 6: Backtracing from 0x7fea9292828d... done ***

*** Program crashed: Aborted at 0x00007fea9292828d ***

Platform: x86_64 Linux (Ubuntu 24.04.4 LTS)

Thread 0 "swift-frontend" crashed:

0  0x00007fea9292828d <unknown> in libc.so.6


Registers:

rax 0x0000000000000000  0
rdx 0x0000000000000006  6
rcx 0x00007fea9292828d  48 3d 01 f0 ff ff 73 01 c3 48 8b 0d 5b bb 0d 00  H=·ðÿÿs·ÃH··[»··
rbx 0x0000000000000006  6
rsi 0x000000000013cdb5  1297845
rdi 0x000000000013cdb5  1297845
rbp 0x000000000013cdb5  1297845
rsp 0x00005604f6977328  3b a8 af e3 04 56 00 00 b0 75 97 f6 04 56 00 00  ;¨¯ã·V··°u·ö·V··
 r8 0x00005604f69775b0  06 00 00 00 00 00 00 00 fa ff ff ff 00 00 00 00  ········úÿÿÿ····
 r9 0x00005604f69775b0  06 00 00 00 00 00 00 00 fa ff ff ff 00 00 00 00  ········úÿÿÿ····
r10 0x00005604f69775b0  06 00 00 00 00 00 00 00 fa ff ff ff 00 00 00 00  ········úÿÿÿ····
r11 0x0000000000000246  582
r12 0x0000000000000006  6
r13 0x000000000000000a  10
r14 0x0000000000000000  0
r15 0x00005604f69773c8  ff ff ff 7f fe ff ff ff 00 00 00 00 00 00 00 00  ÿÿÿ·þÿÿÿ········
rip 0x00007fea9292828d  48 3d 01 f0 ff ff 73 01 c3 48 8b 0d 5b bb 0d 00  H=·ðÿÿs·ÃH··[»··

rflags 0x0000000000000246  ZF PF

cs 0x0033  fs 0x0000  gs 0x0000


Images (29 omitted):

0x00007fea92801000–0x00007fea929b0d39 8e9fd827446c24067541ac5390e6f527fb5947bb libc.so.6 /usr/lib/x86_64-linux-gnu/libc.so.6

Backtrace took 0.00s

Aborted (core dumped)
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1:detect_stack_use_after_return=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' swift -frontend -emit-ir -O -sil-verify-all -enable-experimental-feature NonescapableTypes "$SCRIPT_DIR/test.swift"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `e1ce5d51` | Project seed |
| `b` | `4754ea42` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
