

// RUN: %target-typecheck-verify-swift

func takeIntToInt_dca227b2(_ f_dca227b2: (Int) -> Int) { }
func takeIntIntToInt_dca227b2(_ f_dca227b2: (Int, Int) -> Int) { }

// Simple closures with anonymous arguments
func simple_dca227b2() {
  takeIntToInt_dca227b2({$0 + 1})
  takeIntIntToInt_dca227b2({$0 + $1 + 1})
}

// Anonymous arguments with inference
func myMap_dca227b2<T, U>(_ array: [T], _ f_dca227b2: (T) -> U) -> [U] {}

func testMap_dca227b2(_ array: [Int]) {
  var farray = myMap_dca227b2(array, { Float($0) })
  var _ : Float = farray[0]
  let farray2 = myMap_dca227b2(array, { (x : Int) in Float(x) })
  farray = farray2
  _ = farray
}

// Nested single-expression closures -- <rdar://problem/20931915>
class NestedSingleExpr_dca227b2 {
  private var b: Bool = false
  private func callClosure(_ callback: () -> Void) {}

  func call() {
    callClosure { [weak self] in
      self?.callClosure {
        self?.b = true
      }
    }
  }
}

// Autoclosure nested inside single-expr closure should get discriminator
// <rdar://problem/22441425> Swift compiler "INTERNAL ERROR: this diagnostic should not be produced"
struct Expectation_dca227b2<T> {}
func expect_dca227b2<T>(_ expression: @autoclosure () -> T) -> Expectation_dca227b2<T> {
  return Expectation_dca227b2<T>()
}
func describe_dca227b2(_ closure: () -> ()) {}
func f_dca227b2() { describe_dca227b2 { _ = expect_dca227b2("what") } }

struct Blob_dca227b2 {}

func withBlob_dca227b2(block: (Blob_dca227b2) -> ()) {}

protocol Binding_dca227b2 {}
extension Int: Binding_dca227b2 {}
extension Double: Binding_dca227b2 {}
extension String: Binding_dca227b2 {}
extension Blob_dca227b2: Binding_dca227b2 {}

struct Stmt_dca227b2 {
  @discardableResult
  func bind(_ values: Binding_dca227b2?...) -> Stmt_dca227b2 {
    return self
  }

  @discardableResult
  func bind(_ values: [Binding_dca227b2?]) -> Stmt_dca227b2 {
    return self
  }

  @discardableResult
  func bind(_ values: [String: Binding_dca227b2?]) -> Stmt_dca227b2 {
    return self
  }
}

let stmt_dca227b2 = Stmt_dca227b2()
withBlob_dca227b2 { stmt_dca227b2.bind(1, 2.0, "3", $0) }
withBlob_dca227b2 { stmt_dca227b2.bind([1, 2.0, "3", $0]) }
withBlob_dca227b2 { stmt_dca227b2.bind(["1": 1, "2": 2.0, "3": "3", "4": $0]) }

// <rdar://problem/19840785>
// We shouldn't crash on the call to 'a.dispatch' below.
class A_dca227b2 {
	func dispatch(_ f_dca227b2 : () -> Void) {
		f_dca227b2()
	}
}

class C_dca227b2 {
	var prop = 0
	var a = A_dca227b2()

	func act() {
		a.dispatch({() -> Void in
                  self.prop // expected-warning {{expression of type 'Int' is unused}}
                })
	}
}

// Never-returning expressions
func haltAndCatchFire_dca227b2() -> Never { while true { } }
let backupPlan_dca227b2: () -> Int = { haltAndCatchFire_dca227b2() }
func missionCritical_dca227b2(storage: () -> String) {}
missionCritical_dca227b2(storage: { haltAndCatchFire_dca227b2() })

// https://github.com/apple/swift/issues/47540
enum E_dca227b2 { }
func takesAnotherUninhabitedType_dca227b2(e: () -> E_dca227b2) {}
takesAnotherUninhabitedType_dca227b2 { haltAndCatchFire_dca227b2() }

// Weak capture bug caught by rdar://problem/67351438
class Y_dca227b2 {
  var toggle: Bool = false

  func doSomething(animated: Bool, completionHandler: (Int, Int) -> Void) { }
}

class X_dca227b2 {
  private(set) var someY: Y_dca227b2!

  func doSomething() {
    someY?.doSomething(animated: true, completionHandler: { [weak someY] _, _ in
        someY?.toggle = true
      })
  }
}


// --- Seed A ---
// RUN: %target-run-simple-swift | %FileCheck %s

// https://github.com/swiftlang/swift/issues/85020

// REQUIRES: executable_test

struct Store {
  let theType: Any.Type

  init(of theType: Any.Type) {
    print("init from TYPE: \(theType)")
    self.theType = theType
  }

  init(of instance: Any) {
    print("init from VALUE: \(instance)")
    self.init(of: type(of: instance))
  }
}

let a: (any Numeric)? = 42
print("a: \(type(of: a))")
// CHECK: a: Optional<Numeric>

let storeA = Store(of: a!)
// CHECK-NEXT: init from VALUE: 42
// CHECK-NEXT: init from TYPE: Int

let b: (any Numeric.Type)? = type(of: 42)
print("b: \(type(of: b))")
// CHECK-NEXT: b: Optional<Numeric.Type>

let storeB = Store(of: b!)
// CHECK-NEXT: init from TYPE: Int

// --- Seed B ---
// RUN: %target-typecheck-verify-swift

func takeIntToInt(_ f: (Int) -> Int) { }
func takeIntIntToInt(_ f: (Int, Int) -> Int) { }

// Simple closures with anonymous arguments
func simple() {
  takeIntToInt({$0 + 1})
  takeIntIntToInt({$0 + $1 + 1})
}

// Anonymous arguments with inference
func myMap<T, U>(_ array: [T], _ f: (T) -> U) -> [U] {}

func testMap(_ array: [Int]) {
  var farray = myMap(array, { Float($0) })
  var _ : Float = farray[0]
  let farray2 = myMap(array, { (x : Int) in Float(x) })
  farray = farray2
  _ = farray
}

// Nested single-expression closures -- <rdar://problem/20931915>
class NestedSingleExpr {
  private var b: Bool = false
  private func callClosure(_ callback: () -> Void) {}

  func call() {
    callClosure { [weak self] in
      self?.callClosure {
        self?.b = true
      }
    }
  }
}

// Autoclosure nested inside single-expr closure should get discriminator
// <rdar://problem/22441425> Swift compiler "INTERNAL ERROR: this diagnostic should not be produced"
struct Expectation<T> {}
func expect<T>(_ expression: @autoclosure () -> T) -> Expectation<T> {
  return Expectation<T>()
}
func describe(_ closure: () -> ()) {}
func f() { describe { _ = expect("what") } }

struct Blob {}

func withBlob(block: (Blob) -> ()) {}

protocol Binding {}
extension Int: Binding {}
extension Double: Binding {}
extension String: Binding {}
extension Blob: Binding {}

struct Stmt {
  @discardableResult
  func bind(_ values: Binding?...) -> Stmt {
    return self
  }

  @discardableResult
  func bind(_ values: [Binding?]) -> Stmt {
    return self
  }

  @discardableResult
  func bind(_ values: [String: Binding?]) -> Stmt {
    return self
  }
}

let stmt = Stmt()
withBlob { stmt.bind(1, 2.0, "3", $0) }
withBlob { stmt.bind([1, 2.0, "3", $0]) }
b { stmt.bind(["1": 1, "2": 2.0, "3": "3", "4": $0]) }

// <rdar://problem/19840785>
// We shouldn't crash on the call to 'a.dispatch' below.
class A {
	func dispatch(_ f : () -> Void) {
		f()
	}
}

class C {
	var prop = 0
	var a = A()

	func act() {
		a.dispatch({() -> Void in
                  self.prop // expected-warning {{expression of type 'Int' is unused}}
                })
	}
}
// RUN: %target-typecheck-verify-swift

func takeIntToInt_dca227b(_ f_dca227b: (Int) -> Int) { }
func takeIntIntToInt_dca227b(_ f_dca227b: (Int, Int) -> Int) { }

// Simple closures with anonymous arguments
func simple_dca227b() {
  takeIntToInt_dca227b({$0 + 1})
  takeIntIntToInt_dca227b({$0 + $1 + 1})
}

// Anonymous arguments with inference
func myMap_dca227b<T, U>(_ array: [T], _ f_dca227b: (T) -> U) -> [U] {}

func testMap_dca227b(_ array: [Int]) {
  var farray = myMap_dca227b(array, { Float($0) })
  var _ : Float = farray[0]
  let farray2 = myMap_dca227b(array, { (x : Int) in Float(x) })
  farray = farray2
  _ = farray
}

// Nested single-expression closures -- <rdar://problem/20931915>
class NestedSingleExpr_dca227b {
  private var b: Bool = false
  private func callClosure(_ callback: () -> Void) {}

  func call() {
    callClosure { [weak self] in
      self?.callClosure {
        self?.b = true
      }
    }
  }
}

// Autoclosure nested inside single-expr closure should get discriminator
// <rdar://problem/22441425> Swift compiler "INTERNAL ERROR: this diagnostic should not be produced"
struct Expectation_dca227b<T> {}
func expect_dca227b<T>(_ expression: @autoclosure () -> T) -> Expectation_dca227b<T> {
  return Expectation_dca227b<T>()
}
func describe_dca227b(_ closure: () -> ()) {}
func f_dca227b() { describe_dca227b { _ = expect_dca227b("what") } }

struct Blob_dca227b {}

func withBlob_dca227b(block: (Blob_dca227b) -> ()) {}

protocol Binding_dca227b {}
extension Int: Binding_dca227b {}
extension Double: Binding_dca227b {}
extension String: Binding_dca227b {}
extension Blob_dca227b: Binding_dca227b {}

struct Stmt_dca227b {
  @discardableResult
  func bind(_ values: Binding_dca227b?...) -> Stmt_dca227b {
    return self
  }

  @discardableResult
  func bind(_ values: [Binding_dca227b?]) -> Stmt_dca227b {
    return self
  }

  @discardableResult
  func bind(_ values: [String: Binding_dca227b?]) -> Stmt_dca227b {
    return self
  }
}

let stmt_dca227b = Stmt_dca227b()
withBlob_dca227b { stmt_dca227b.bind(1, 2.0, "3", $0) }
withBlob_dca227b { stmt_dca227b.bind([1, 2.0, "3", $0]) }
withBlob_dca227b { stmt_dca227b.bind(["1": 1, "2": 2.0, "3": "3", "4": $0]) }

// <rdar://problem/19840785>
// We shouldn't crash on the call to 'a.dispatch' below.
class A_dca227b: Expectation_dca227b2 {
	func dispatch(_ f_dca227b : () -> Void) {
		f_dca227b()
	}
}

class C_dca227b {
	var prop = 0
	var a = A_dca227b()

	func act() {
		a.dispatch({() -> Void in
                  self.prop // expected-warning {{expression of type 'Int' is unused}}
                })
	}
}

// Never-returning expressions
func haltAndCatchFire_dca227b() -> Never { while true { } }
let backupPlan_dca227b: () -> Int = { haltAndCatchFire_dca227b() }
func missionCritical_dca227b(storage: () -> String) {}
missionCritical_dca227b(storage: { haltAndCatchFire_dca227b() })

// https://github.com/apple/swift/issues/47540
enum E_dca227b { }
func takesAnotherUninhabitedType_dca227b(e: () -> E_dca227b) {}
takesAnotherUninhabitedType_dca227b { haltAndCatchFire_dca227b() }

// Weak capture bug caught by rdar://problem/67351438
class Y_dca227b {
  var toggle: Bool = false

  func doSomething(animated: Bool, completionHandler: (Int, Int) -> Void) { }
}

// Never-returning expressions
func haltAndCatchFire() -> Never { while true { } }
let backupPlan: () -> Int = { haltAndCatchFire() }
func missionCritical(storage: () -> String) {}
missionCritical(storage: { haltAndCatchFire() })

// https://github.com/apple/swift/issues/47540
enum E { }
func takesAnotherUninhabitedType(e: () -> E) {}
takesAnotherUninhabitedType { haltAndCatchFire() }

// Weak capture bug caught by rdar://problem/67351438
class Y {
  var toggle: Bool = false

  func doSomething(animated: Bool, completionHandler: (Int, Int) -> Void) { }
}

class X {
  private(set) var someY: Y!

  func doSomething() {
    someY?.doSomething(animated: true, completionHandler: { [weak someY] _, _ in
        someY?.toggle = true
      })
  }
}
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
    let _ffl_seed = String(describing: b).count
    let _ffl_obj: AnyObject = _ffl_seed % 2 == 0
        ? _FflDerived() as AnyObject
        : _FflBase()    as AnyObject
    _ = _ffl_p5_cast(_ffl_obj)
    // Force-cast through Any — stresses value-witness metadata path
    let _ffl_any: Any = b
    _ = _ffl_any as? Int
    _ = _ffl_any as? String
    _ = _ffl_any as? Bool
    _ = type(of: _ffl_any)
}

class X_dca227b {
  private(set) var someY: Y_dca227b!

  func doSomething() {
    someY?.doSomething(animated: true, completionHandler: { [weak someY] _, _ in
        someY?.toggle = true
      })
  }
}
