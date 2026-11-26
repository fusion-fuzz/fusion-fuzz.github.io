// RUN: %empty-directory(%t)
// RUN: %target-build-swift -swift-version 5 %s -o %t/a.out
// RUN: %target-codesign %t/a.out
// RUN: %target-run %t/a.out | %FileCheck %s

// REQUIRES: executable_test

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
protocol P {
  associatedtype AT
  func foo() -> AT
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
struct Adapter<T: P>: P {
  var inner: T

  @available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
  func foo() -> some P {
    return inner
  }
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension P {
  @available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
  func foo() -> some P {
    return Adapter(inner: self)
  }
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
func getPAT<T: P>(_: T.Type) -> Any.Type {
  return T.AT.self
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension Int: P { }

// CHECK: {{Adapter<Int>|too old}}
if #available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *) {
  print(getPAT(Int.self))
} else {
  print("i'm getting too old for this sh")
}

// rdar://problem/54084733

protocol Q {
  associatedtype A
  func f() -> A
}
struct X: Q {
  typealias A = Array<Int>
  func f() -> A {
    return [1, 2, 3]
  }
}
@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
dynamic func g() -> some Q {
  return X()
}

func h<T: Q>(x: T) -> (T.A?, T.A?) {
  return (.some(x.f()), .some(x.f()))
}

if #available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *) {
  let x = g()
  // CHECK: {{X()|no really}}
  print(x)
  // CHECK: {{[1, 2, 3]|too old}}
  let y = x.f()
  print(y)
  // CHECK: {{[1, 2, 3]|too old}}
  let z = h(x: x)
  print(z)
} else {
  print("no really")
  print("i'm getting way too old for this sh")
  print("way too old")
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
dynamic func opaqueAssocTypeUnderlyingType() -> some Any {
  return g().f()
}

extension Optional: Q where Wrapped: Q {
  func f() -> Wrapped.A? {
    return map { $0.f() }
  }
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
dynamic func structuralOpaqueAssocTypeUnderlyingType() -> some Any {
  return Optional(g()).f()
}

// RUN: %target-typecheck-verify-swift -strict-memory-safety

// The feature flag should be enabled.
#if !hasFeature(StrictMemorySafety)
#error("Strict memory safety is not enabled!")
#endif


@unsafe
func unsafeFunction() { }

@unsafe
struct UnsafeType { }

func f() {
  unsafe unsafeFunction()
}

func g_d9d4fd4() {
  unsafe unsafeFunction()
}

func h_d9d4fd4(_: UnsafeType) {
// expected-warning@+1{{expression uses unsafe constructs but is not marked with 'unsafe'}}
  unsafeFunction() // expected-note{{reference to unsafe global function 'unsafeFunction()'}}

  // okay
  unsafe unsafeFunction()

  // expected-warning@+1{{no unsafe operations occur within 'unsafe' expression}}
  unsafe g_d9d4fd4()
}

func rethrowing(body: (UnsafeType) throws -> Void) rethrows { }

class HasStatics {
  static internal func f(_: UnsafeType) { }

  
}

@unsafe
func unsafeInt() -> Int { 5 }

struct HasProperties {
  var computed: Int {
    unsafe unsafeInt()
  }

  @unsafe var computedUnsafe: Int {
    unsafe unsafeInt()
  }

  static var blah: Int = {
    unsafe unsafeInt()
  }()

  @unsafe static var blahUnsafe: Int = {
    unsafe unsafeInt()
  }()
}

protocol P_d9d4fd4 { }

extension Int: @unsafe P_d9d4fd4 { }

func acceptP(_: some P_d9d4fd4) { }

func testConformance(i: Int) {
  // expected-warning@+1{{expression uses unsafe constructs but is not marked with 'unsafe'}}
  acceptP(i) // expected-note{{'@unsafe' conformance of 'Int' to protocol 'P_d9d4fd4' involves unsafe code}}
}

func returnsOpaqueP() -> some P_d9d4fd4 {
  5 // expected-warning{{expression uses unsafe constructs but is not marked with 'unsafe'}}
  // expected-note@-1{{'@unsafe' conformance of 'Int' to protocol 'P_d9d4fd4' involves unsafe code}}
}

func returnsExistentialP() -> any P_d9d4fd4 {
  5 // expected-warning{{expression uses unsafe constructs but is not marked with 'unsafe'}}
  // expected-note@-1{{'@unsafe' conformance of 'Int' to protocol 'P_d9d4fd4' involves unsafe code}}
}

// FIXME: Should work even if the IteratorProtocol conformance is safe
struct UnsafeAsSequence: @unsafe Sequence, @unsafe IteratorProtocol {
  @unsafe mutating func next() -> Int? { nil }
}

func testUnsafeAsSequenceForEach() {
  let uas = UnsafeAsSequence()

  // expected-note@+1{{reference to unsafe instance method 'next()'}}
  for _ in uas { } // expected-note{{conformance}}
  // expected-warning@-1{{for-in loop uses unsafe constructs but is not marked with 'unsafe'}}{{documentation-file=strict-memory-safety}}{{7-7=unsafe }}

  // expected-note@+1{{reference to unsafe instance method 'next()'}}
  for _ in unsafe uas { } // expected-warning{{for-in loop uses unsafe constructs but is not marked with 'unsafe'}}{{documentation-file=strict-memory-safety}}{{7-7=unsafe }} expected-note{{conformance}}
  // expected-warning@-1 {{no unsafe operations occur within 'unsafe' expression}}

  for unsafe _ in unsafe uas { } // expected-warning{{no unsafe operations occur within 'unsafe' expression}}

  for unsafe _ in [1, 2, 3] { } // expected-warning{{no unsafe operations occur within 'unsafe' for-in loop}}
}

func testForInUnsafeAmbiguity(_ integers: [Int]) {
  for unsafe in integers {
    _ = unsafe
  }
  for unsafe: Int in integers {
    _ = unsafe
  }
}

struct UnsafeIterator: @unsafe IteratorProtocol {
  @unsafe mutating func next() -> Int? { nil }
}

struct SequenceWithUnsafeIterator: Sequence {
  func makeIterator() -> UnsafeIterator { UnsafeIterator() }
}
if #available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *) {
  // CHECK: {{[\1, 2, 3\]|too old}}
  let x = opaqueAssocTypeUnderlyingType()
  print(x)
  // CHECK: {{Optional\(\[1, 2, 3\]\)|too damn old}}
  let y = structuralOpaqueAssocTypeUnderlyingType()
  print(y)
} else {
  print("nope, still too old")
  print("too damn old")
}

func testUnsafeIteratorForEach() {
  let swui = SequenceWithUnsafeIterator()

  // expected-note@+1{{reference to unsafe instance method 'next()'}}
  for _ in swui { } // expected-warning{{for-in loop uses unsafe constructs but is not marked with 'unsafe'}}{{7-7=unsafe }}
  for unsafe _ in swui { } // okay, it's only the iterator that's unsafe
}

class MyRange {
  @unsafe init(unchecked bounds: Range<Int>) { }

  convenience init(_ bounds: Range<Int>) {
    // bounds check
    self.init(unchecked: bounds) // expected-warning{{expression uses unsafe constructs but is not marked with 'unsafe'}}
    // expected-note@-1{{reference to unsafe initializer 'init(unchecked:)'}}
  }
}

func casting(value: Any, i: Int) {
  // expected-warning@+1{{expression uses unsafe constructs but is not marked with 'unsafe'}}
  _ = value as? UnsafeType // expected-note{{reference to unsafe type 'UnsafeType'}}
  // expected-warning@+1{{expression uses unsafe constructs but is not marked with 'unsafe'}}
  _ = value as! UnsafeType // expected-note{{reference to unsafe type 'UnsafeType'}}

  _ = unsafe value as? UnsafeType
  _ = unsafe value as! UnsafeType

  // expected-warning@+1{{expression uses unsafe constructs but is not marked with 'unsafe'}}
  _ = i as any P_d9d4fd4 // expected-note{{'@unsafe' conformance of 'Int' to protocol 'P_d9d4fd4' involves unsafe code}}
}

func metatypes() {
  // expected-warning@+1{{expression uses unsafe constructs but is not marked with 'unsafe'}}
  let _: Any.Type = UnsafeType.self // expected-note{{reference to unsafe type 'UnsafeType'}}

  let _: Any.Type = unsafe UnsafeType.self
}

func testKeyPath() {
  // expected-warning@+1{{expression uses unsafe constructs but is not marked with 'unsafe'}}
  _ = \HasProperties.computedUnsafe // expected-note{{reference to unsafe property 'computedUnsafe'}}

  _ = unsafe \HasProperties.computedUnsafe
}

func takesAutoclosure<T>(_ body: @autoclosure () -> T) { }

func testAutoclosure() {
  // expected-warning@+1{{expression uses unsafe constructs but is not marked with 'unsafe'}}{{3-3=unsafe }}
  takesAutoclosure(unsafeFunction()) // expected-note{{reference to unsafe global function 'unsafeFunction()'}}

  unsafe takesAutoclosure(unsafeFunction())

  takesAutoclosure(unsafe unsafeFunction())
}

// Parsing of `unsafe` expressions.
func testUnsafePositionError() -> Int {
  return 3 + unsafe unsafeInt() // expected-error{{'unsafe' cannot appear to the right of a non-assignment operator}}
}

enum Color {
case red
}

func acceptBools(_: Bool, _: Bool) { }

func acceptBoolsUnsafeLabel(unsafe _: Bool, _: Bool) { }

func unsafe(_: Int) { }

func unsafeFun() {
  var unsafe = true
  unsafe = false
  unsafe.toggle()
  _ = [unsafe]
  _ = { unsafe }
  acceptBools(unsafe, unsafe)
  acceptBoolsUnsafeLabel(unsafe: unsafe, unsafe)

  let color: Color
  // expected-warning@+1{{no unsafe operations occur within 'unsafe' expression}}{{11-18=}}
  color = unsafe .red
  _ = color

  if unsafe { }

  _ = unsafe ? 1 : 0
}

func moreUnsafeFunc(unsafe: [Int]) {
  let _: [Int] = unsafe []
  // expected-warning@-1{{no unsafe operations occur within 'unsafe' expression}}

  _ = unsafe[1]

  _ = "\(unsafe)"
}

func yetMoreUnsafeFunc(unsafe: () -> Void) {
  unsafe()

  _ = unsafe ()
  // expected-warning@-1{{no unsafe operations occur within 'unsafe' expression}}
}

func yetMoreMoreUnsafeFunc(unsafe: Int?) {
  _ = unsafe!
  if let unsafe {
    _ = unsafe + 1
  }
}

// @safe suppresses unsafe-type-related diagnostics on an entity
struct MyArray<Element> {
  @safe func withUnsafeBufferPointer<R, E>(
    _ body: (UnsafeBufferPointer<Element>) throws(E) -> R
  ) throws(E) -> R {
    return unsafe try body(.init(start: nil, count: 0))
  }
}

extension UnsafeBufferPointer {
  @unsafe var unsafeCount: Int { 17 }
  @safe var safeCount: Int { unsafe unsafeCount }
}

func testMyArray(ints: MyArray<Int>) {
  ints.withUnsafeBufferPointer { buffer in
    let bufferCopy = unsafe buffer
    _ = unsafe bufferCopy

    print(buffer.safeCount)
    unsafe print(buffer.unsafeCount)
  }
}

func testUnsafeLHS() {
  @unsafe var value: Int = 0
  unsafe value = switch unsafe value {
  case 0: 1
  default: 0
  }
}

@safe
struct UnsafeWrapTest {
  var pointer: UnsafeMutablePointer<Int>?

  func test() {
    if let pointer { // expected-warning{{expression uses unsafe constructs but is not marked with 'unsafe'}}{{19-19= = unsafe pointer}}
      // expected-note@-1{{reference to property 'pointer' involves unsafe type 'UnsafeMutablePointer<Int>'}}
      _ = unsafe pointer
    }
  }

  func otherTest(pointer: UnsafeMutablePointer<Int>?) {
    if let pointer { // expected-warning{{expression uses unsafe constructs but is not marked with 'unsafe'}}{{19-19= = unsafe pointer}}
      // expected-note@-1{{reference to parameter 'pointer' involves unsafe type 'UnsafeMutablePointer<Int>}}
      _ = unsafe pointer
    }
  }
}

@safe @unsafe
struct ConfusedStruct { } // expected-error{{struct 'ConfusedStruct' cannot be both '@safe' and '@unsafe'}}

@unsafe
struct UnsafeContainingUnspecified {
  typealias A = Int

  func getA() -> A { 0 }

  @safe
  struct Y {
    var value: Int
  }

  func f() {
    _ = Y(value: 5)
  }
}


@unsafe func f(x: UnsafeContainingUnspecified) {
  let a = unsafe x.getA()
  _ = a
}

extension Slice {
  // Make sure we aren't diagnosing the 'defer' as unsafe.
  public func withContiguousMutableStorageIfAvailable<R, Element>(
    _ body: (_ buffer: inout UnsafeMutableBufferPointer<Element>) throws -> R
  ) rethrows -> R? where Base == UnsafeMutableBufferPointer<Element> {
    try unsafe base.withContiguousStorageIfAvailable { buffer in
      let start = unsafe base.baseAddress?.advanced(by: startIndex)
      var slice = unsafe UnsafeMutableBufferPointer(start: start, count: count)
      defer {
      }
      return try unsafe body(&slice)
    }
  }
}

@unsafe enum SomeEnum {
  case first
  case second
}

@unsafe var someEnumValue: SomeEnum = unsafe .first

func testSwitch(se: SomeEnum) {
  switch unsafe se {
  case unsafe someEnumValue: break
  default: break
  }

  switch unsafe se {
  case someEnumValue: break
    // expected-warning@-1{{expression uses unsafe constructs but is not marked with 'unsafe'}}{{8-8=unsafe }}
    // expected-note@-2{{argument #0 in call to operator function '~=' has unsafe type 'SomeEnum'}}
    // expected-note@-3{{argument #1 in call to operator function '~=' has unsafe type 'SomeEnum'}}
    // expected-note@-4{{reference to unsafe type 'SomeEnum'}}
    // expected-note@-5{{reference to unsafe var 'someEnumValue'}}
    // expected-note@-6{{reference to let '$match' involves unsafe type 'SomeEnum'}}
  default: break
  }

  // expected-note@+2{{reference to parameter 'se' involves unsafe type 'SomeEnum'}}
  // expected-warning@+1{{expression uses unsafe constructs but is not marked with 'unsafe'}}{{10-10=unsafe }}
  switch se {
  case unsafe someEnumValue: break
  default: break
  }

  if case someEnumValue = unsafe se { }
    // expected-warning@-1{{expression uses unsafe constructs but is not marked with 'unsafe'}}{{11-11=unsafe }}
    // expected-note@-2{{argument #0 in call to operator function '~=' has unsafe type 'SomeEnum'}}
    // expected-note@-3{{argument #1 in call to operator function '~=' has unsafe type 'SomeEnum'}}
    // expected-note@-4{{reference to unsafe type 'SomeEnum'}}
    // expected-note@-5{{reference to unsafe var 'someEnumValue'}}
    // expected-note@-6{{reference to let '$match' involves unsafe type 'SomeEnum'}}

  if case unsafe someEnumValue = unsafe se { }
}

@unsafe class SomeClass {}
@unsafe class SomeClassWrapper { }

protocol Associated {
    associatedtype Associated
}

protocol CustomAssociated: Associated { }

// expected-warning@+1{{conformance of 'SomeClass' to protocol 'Associated' involves unsafe code}}{{22-22=@unsafe }}
extension SomeClass: CustomAssociated {
  typealias Associated = SomeClassWrapper // expected-note{{unsafe type 'SomeClass.Associated' (aka 'SomeClassWrapper') cannot satisfy safe associated type 'Associated'}}
}

func testInterpolation(ptr: UnsafePointer<Int>) {
  _ = "Hello \(unsafe ptr)" // expected-warning{{expression uses unsafe constructs but is not marked with 'unsafe'}}{{7-7=unsafe }}
  // expected-note@-1{{reference to unsafe type 'UnsafePointer<Int>'}}
  // expected-note@-2{{argument #0 in call to instance method 'appendInterpolation' has unsafe type 'UnsafePointer<Int>'}}
  // expected-note@-3{{reference to instance method 'appendInterpolation' involves unsafe type 'UnsafePointer<Int>'}}
}

func superDuperUnsafe(_ bytes: UnsafeRawBufferPointer) {
  // expected-warning@+1{{no unsafe operations occur within 'unsafe' expression}}
  let byte = unsafe unsafe bytes.first ?? 0
  _ = byte
  _ = unsafe bytes.first ?? 0
}
