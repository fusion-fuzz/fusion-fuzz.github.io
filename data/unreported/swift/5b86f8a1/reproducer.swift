import SubscriptOverloads

// --- Seed A ---
// RUN: %target-typecheck-verify-swift -suppress-notes -I %S/Inputs -cxx-interoperability-mode=default
// RUN: %target-typecheck-verify-swift -suppress-notes -I %S/Inputs -cxx-interoperability-mode=default -Xcc -std=c++23 -D CXX23 -verify-additional-prefix CXX23-


let u = Overloaded()
var v = Overloaded()

let val = Num(123)

let signed: CInt = 0
let unsigned: CUnsignedInt = 0
let num = Num(0)
let float: Float = 4.2
let unit = Overloaded.Unit()

let _: Num = v[signed]
v[signed] = val // expected-error {{no exact matches in call to subscript}}

let _: Num = u[signed]
u[signed] = val // expected-error {{subscript is get-only}}

let _: Num = v[unsigned]
v[unsigned] = val

let _: Num = u[unsigned]
u[unsigned] = val // expected-error {{'u' is a 'let' constant}}

let _: Num = v[num]
v[num] = val

let _: Num = u[num] // expected-error {{cannot use mutating getter on immutable value}}
u[num] = val // expected-error {{cannot convert value of type 'Num' to expected argument type}}
             // FIXME: ^this should complain about 'u' being a 'let' constant


let _: Float = v[float]
// RUN: %target-typecheck-verify-swift -enable-experimental-feature Reparenting
// RUN: %target-swift-frontend %s -emit-irgen -DFIXED -enable-experimental-feature Reparenting > /dev/null

// REQUIRES: swift_feature_Reparenting

// This test exercises the extra witness checking needed for reparented conformances.
// We need to ensure that an abstract witness for an associatedtype requirement from the new parent protocol
// doesn't refer to itself, e.g.,
// "CheckReparentingWitnesses found illegal witness Self.Element of BorrowingSeq that is not within expected protocol context Seq"

public protocol Seq: BorrowingSeq {

// Seq should've declared an Element to witness BorrowingSeq's Element
#if FIXED
  associatedtype Element
#endif

  associatedtype Iterator: Iterable
  func makeIterator() -> Iterator

  associatedtype BorrowingSeqIter: BorrowingIter<Element> = Adapter<Iterator>
}

@reparentable
public protocol BorrowingSeq<Element> {
  associatedtype Element  // expected-note {{protocol requires nested type 'Element'}}
  associatedtype BorrowingSeqIter: BorrowingIter<Element> // expected-note {{protocol requires nested type 'BorrowingSeqIter'}}

  func makeBorrowingSeqIter() -> BorrowingSeqIter
}

extension Seq : @reparented BorrowingSeq // expected-error {{type 'Self' does not conform to protocol 'BorrowingSeq'}} // expected-note {{add stubs for conformance}}
    where BorrowingSeqIter == Adapter<Iterator> {
  public func makeBorrowingSeqIter() -> BorrowingSeqIter {
    return Adapter(makeIterator())
  }
}
v[float] = val // expected-error {{no exact matches in call to subscript}}
               // FIXME: ^this should complain about 'u' being a 'let' constant

let _: Float = u[float]
u[float] = val // expected-error {{no exact matches in call to subscript}}
               // FIXME: ^this should complain about 'u' being a 'let' constant

let _: Overloaded.Unit = v[unit]
v[unit] = val // expected-error {{cannot assign value of type 'Num' to subscript of type 'Overloaded.Unit'}}

v[unit] = unit

let _: Overloaded.Unit = u[unit] // expected-error {{cannot use mutating getter on immutable value: 'u' is a 'let' constant}}
u[unit] = val // expected-error {{cannot convert value of type 'Overloaded.Unit' to expected argument type}}

u[unit] = unit // expected-error {{failed to produce diagnostic}}
               // FIXME: ^this should complain about 'u' being a 'let' constant

let _: Bool = v[Overloaded.Bogus()]
v[Overloaded.Bogus()] = false // expected-error {{subscript is get-only}}
let _: Bool = u[Overloaded.Bogus()]
u[Overloaded.Bogus()] = false // expected-error {{subscript is get-only}}

var CharPtr = v[Overloaded.GetCharPtr()]
var ConstCharPtr = v[Overloaded.GetConstCharPtr()]

CharPtr = v[CharPtr]
CharPtr = u[CharPtr] // expected-error {{cannot use mutating getter on immutable value}}
                     // FIXME: ^ this should be allowed
ConstCharPtr = v[ConstCharPtr]
ConstCharPtr = u[ConstCharPtr]

#if CXX23
let _: Bool = v[]
v[] = true // expected-CXX23-error {{subscript is get-only}}
let _: Bool = u[]
u[] = true // expected-CXX23-error {{subscript is get-only}}

let _: Num = v[1.0, 2.0]
v[1.0, 2.0] = val // expected-CXX23-error {{subscript is get-only}}
let _: Num = u[1.0, 2.0]
u[1.0, 2.0] = val // expected-CXX23-error {{subscript is get-only}}

let _: CInt = v[1, 2]
v[1, 2] = 12 // expected-CXX23-error {{subscript is get-only}}
let _: CInt = u[1, 2]
u[1, 2] = 12 // expected-CXX23-error {{subscript is get-only}}
#endif


let getPtr = Overloaded.GetPtr(index: 0)
let getRef = Overloaded.GetRef(index: 0)
let getPtrRef = Overloaded.GetPtrRef(index: 0)
let getRefVal = Overloaded.GetRefVal(index: 0)
let getValPtr = Overloaded.GetValPtr(index: 0)

let vGetPtr: CUnsignedInt = v[getPtr]
v[getPtr] = vGetPtr
let uGetPtr: CUnsignedInt = u[getPtr] // expected-error {{cannot use mutating getter on immutable value: 'u' is a 'let' constant}}
u[getPtr] = uGetPtr // expected-error {{no exact matches in call to subscript}}
                    // FIXME: ^this should complain about 'u' being a 'let' constant

let vGetRef: UnsafeMutablePointer<UInt32>? = v[getRef]
// FIXME: ^why is this returning a mutable pointer?
v[getRef] = vGetRef
let uGetRef: UnsafeMutablePointer<UInt32>? = u[getRef] // expected-error {{cannot use mutating getter on immutable value: 'u' is a 'let' constant}}
                                                       // FIXME: ^this should complain about 'u' being a 'let' constant
u[getRef] = uGetRef // expected-error {{failed to produce diagnostic for expression}}
                    // FIXME: ^this should complain about 'u' being a 'let' constant

let vGetPtrRef: CUnsignedInt = v[getPtrRef]
v[getPtrRef] = vGetPtrRef
let uGetPtrRef: CUnsignedInt = u[getPtrRef]
u[getPtrRef] = uGetPtrRef // expected-error {{'u' is a 'let' constant}}

let vGetRefVal: CUnsignedInt = v[getRefVal]
v[getRefVal] = vGetRefVal
let uGetRefVal: CUnsignedInt = u[getRefVal]
u[getRefVal] = uGetRefVal // expected-error {{'u' is a 'let' constant}}

let vGetValPtr: UnsafePointer<UInt32>? = v[getValPtr]
v[getValPtr] = vGetValPtr // expected-error {{subscript is get-only}}
let uGetValPtr: UnsafePointer<UInt32>? = u[getValPtr]
u[getValPtr] = uGetValPtr // expected-error {{subscript is get-only}}

let deprecatedIdx = Overloaded.DeprecatedIndex(index: 0)
let _: CUnsignedInt = v[deprecatedIdx] // expected-warning {{deprecated: use GetVal instead}}

public struct Adapter<Iterator: Iterable>: BorrowingIter {
  public typealias Element = Iterator.Element
  var iterator: Iterator
  public init(_ iterator: Iterator) { self.iterator = iterator }

  public mutating func nextThing() -> Element? {
    print("Adapter invoking iterator.next()")
    return iterator.next()!
  }
}

public protocol BorrowingIter<Element> {
  associatedtype Element
  mutating func nextThing() -> Element?
}

public protocol Iterable {
  associatedtype Element
  mutating func next() -> Element?
}
// --- Seed B ---
// RUN: %target-typecheck-verify-swift -enable-experimental-feature Reparenting
// RUN: %target-swift-frontend %s -emit-irgen -DFIXED -enable-experimental-feature Reparenting > /dev/null

// REQUIRES: swift_feature_Reparenting

// This test exercises the extra witness checking needed for reparented conformances.
// We need to ensure that an abstract witness for an associatedtype requirement from the new parent protocol
// doesn't refer to itself, e.g.,
// "CheckReparentingWitnesses found illegal witness Self.Element of BorrowingSeq_b272f35 that is not within expected protocol context Seq_b272f35"

public protocol Seq_b272f35: _ {

// Seq_b272f35 should've declared an Element to witness BorrowingSeq_b272f35's Element
#if FIXED
  associatedtype Element
#endif

  associatedtype Iterator: Iterable_b272f35
  func makeIterator() -> Iterator

  associatedtype BorrowingSeqIter: BorrowingIter_b272f35<Element> = Adapter_b272f35<Iterator>
}

@reparentable
public protocol BorrowingSeq_b272f35<Element> {
  associatedtype Element  // expected-note {{protocol requires nested type 'Element'}}
  associatedtype BorrowingSeqIter: BorrowingIter_b272f35<Element> // expected-note {{protocol requires nested type 'BorrowingSeqIter'}}

  func makeBorrowingSeqIter() -> BorrowingSeqIter
}

extension Seq_b272f35 : @reparented BorrowingSeq_b272f35 // expected-error {{type 'Self' does not conform to protocol 'BorrowingSeq_b272f35'}} // expected-note {{add stubs for conformance}}
    where BorrowingSeqIter == Adapter_b272f35<Iterator> {
  public func makeBorrowingSeqIter() -> BorrowingSeqIter {
    return Adapter_b272f35(makeIterator())
  }
}

public struct Adapter_b272f35<Iterator: Iterable_b272f35>: BorrowingIter_b272f35 {
  public typealias Element = Iterator.Element
  var iterator: Iterator
  public init(_ iterator: Iterator) { self.iterator = iterator }

  public mutating func nextThing() -> Element? {
    print("Adapter_b272f35 invoking iterator.next()")
    return iterator.next()!
  }
}

public protocol BorrowingIter_b272f35<Element> {
  associatedtype Element
  mutating func nextThing() -> Element?
}

public protocol Iterable_b272f35 {
  associatedtype Element
  mutating func next() -> Element?
}
// --- Bug Primitive ---

// P6: Non-copyable (~Copyable) consume/borrow stress
struct _FflMoveOnly: ~Copyable {
    var payload: Int
    init(_ v: Int) { payload = v }
    consuming func consume() -> Int { payload }
    borrowing func inspect() -> Int { payload }
}
func _ffl_p6_transfer(_ v: consuming _FflMoveOnly) -> Int {
    v.consume()
}
do {
    var _ffl_mo = _FflMoveOnly(String(describing: _).count)
    _ = _ffl_mo.inspect()           // borrow — ownership retained
    let _ffl_result = _ffl_p6_transfer(_ffl_mo) // consume — ownership transferred
    _ = _ffl_result
    // Re-init after consume
    _ffl_mo = _FflMoveOnly(0)
    _ = _ffl_mo.inspect()
}
