

// --- Seed A ---

// RUN: %target-swift-emit-silgen -Xllvm -sil-print-types %s | %FileCheck %s

// CHECK-LABEL: sil hidden [ossa] @$s23default_arguments_local5outer1x1y1z1wySi_yXlypxtlF : $@convention(thin) <T> (Int, @guaranteed AnyObject, @in_guaranteed Any, @in_guaranteed T) -> ()
func outer<T>(x: Int, y: AnyObject, z: Any, w: T) {
  func local1(x: Int = x) {}
  func local2(y: AnyObject = y) {}
  func local3(z: Any = z) {}
  func local4(w: T = w) {}
  func local5<U>(u: U, w: T = w) {}

  // CHECK: [[FN:%.*]] = function_ref @$s23default_arguments_local5outer1x1y1z1wySi_yXlypxtlF6local1L_ACySi_tlFfA_ : $@convention(thin) (Int) -> Int
  // CHECK: [[ARG:%.*]] = apply [[FN]](%0) : $@convention(thin) (Int) -> Int
  // CHECK: [[LOCAL1:%.*]] = function_ref @$s23default_arguments_local5outer1x1y1z1wySi_yXlypxtlF6local1L_ACySi_tlF : $@convention(thin) (Int, Int) -> ()
  // CHECK: apply [[LOCAL1]]([[ARG]], %0) : $@convention(thin) (Int, Int) -> ()
  local1()

  // CHECK: [[FN:%.*]] = function_ref @$s23default_arguments_local5outer1x1y1z1wySi_yXlypxtlF6local2L_ADyyXl_tlFfA_ : $@convention(thin) (@guaranteed AnyObject) -> @owned AnyObject
  // CHECK: [[ARG:%.*]] = apply [[FN]](%1) : $@convention(thin) (@guaranteed AnyObject) -> @owned AnyObject
  // CHECK: [[LOCAL2:%.*]] = function_ref @$s23default_arguments_local5outer1x1y1z1wySi_yXlypxtlF6local2L_ADyyXl_tlF : $@convention(thin) (@guaranteed AnyObject, @guaranteed AnyObject) -> ()
  // CHECK: apply [[LOCAL2]]([[ARG]], %1) : $@convention(thin) (@guaranteed AnyObject, @guaranteed AnyObject) -> ()
  // CHECK: destroy_value [[ARG]] : $AnyObject
  local2()

  // CHECK: [[FN1:%.*]] = function_ref @$s23default_arguments_local5outer1x1y1z1wySi_yXlypxtlF6local3L_AEyyp_tlFfA_ : $@convention(thin) (@in_guaranteed Any) -> @out Any
  // CHECK: [[STACK:%.*]] = alloc_stack $Any
  // CHECK: apply [[FN1]]([[STACK]], %2) : $@convention(thin) (@in_guaranteed Any) -> @out Any
  // CHECK: [[FN2:%.*]] = function_ref @$s23default_arguments_local5outer1x1y1z1wySi_yXlypxtlF6local3L_AEyyp_tlF : $@convention(thin) (@in_guaranteed Any, @in_guaranteed Any) -> ()
  // CHECK: apply [[FN2]]([[STACK]], %2) : $@convention(thin) (@in_guaranteed Any, @in_guaranteed Any) -> ()
  // CHECK: destroy_addr [[STACK]] : $*Any
  // CHECK: dealloc_stack [[STACK]] : $*Any
  local3()

  local4()

  local5(u: "hi")
}

// CHECK-LABEL: sil private [ossa] @$s23default_arguments_local5outer1x1y1z1wySi_yXlypxtlF6local1L_ACySi_tlFfA_ : $@convention(thin) (Int) -> Int
// CHECK-LABEL: sil private [ossa] @$s23default_arguments_local5outer1x1y1z1wySi_yXlypxtlF6local1L_ACySi_tlF : $@convention(thin) (Int, Int) -> ()
// CHECK-LABEL: sil private [ossa] @$s23default_arguments_local5outer1x1y1z1wySi_yXlypxtlF6local2L_ADyyXl_tlFfA_ : $@convention(thin) (@guaranteed AnyObject) -> @owned AnyObject
// CHECK-LABEL: sil private [ossa] @$s23default_arguments_local5outer1x1y1z1wySi_yXlypxtlF6local2L_ADyyXl_tlF : $@convention(thin) (@guaranteed AnyObject, @guaranteed AnyObject) -> ()
// CHECK-LABEL: sil private [ossa] @$s23default_arguments_local5outer1x1y1z1wySi_yXlypxtlF6local3L_AEyyp_tlFfA_ : $@convention(thin) (@in_guaranteed Any) -> @out Any
// CHECK-LABEL: sil private [ossa] @$s23default_arguments_local5outer1x1y1z1wySi_yXlypxtlF6local3L_AEyyp_tlF : $@convention(thin) (@in_guaranteed Any, @in_guaranteed Any) -> ()
// CHECK-LABEL: sil private [ossa] @$s23default_arguments_local5outer1x1y1z1wySi_yXlypxtlF6local4L_AFyx_tlF : $@convention(thin) <T> (@in_guaranteed T, @in_guaranteed T) -> ()
// CHECK-LABEL: sil private [ossa] @$s23default_arguments_local5outer1x1y1z1wySi_yXlypxtlF6local5L_1uAFyqd___xtr__lFfA0_ : $@convention(thin) <T><U> (@in_guaranteed T) -> @out T

class ArtClass<T> {
  // CHECK-LABEL: sil hidden [ossa] @$s23default_arguments_local8ArtClassC10selfMethod1uyqd___tlF : $@convention(method) <T><U> (@in_guaranteed U, @guaranteed ArtClass<T>) -> ()
  func selfMethod<U>(u: U) {
    // CHECK-LABEL: sil private [ossa] @$s23default_arguments_local8ArtClassC10selfMethod1uyqd___tlF0C0L_1vAE1syqd0___qd__Sitr___lFfA1_ : $@convention(thin) <T><U><V> (@thick @dynamic_self ArtClass<T>.Type) -> Int
    // CHECK-LABEL: sil private [ossa] @$s23default_arguments_local8ArtClassC10selfMethod1uyqd___tlF0C0L_1vAE1syqd0___qd__Sitr___lF : $@convention(thin) <T><U><V> (@in_guaranteed V, @in_guaranteed U, Int, @thick @dynamic_self ArtClass<T>.Type) -> ()
    func local<V>(v: V, u: U, s: Int = Self.intMethod()) {}
  }

  static func intMethod() -> Int {
    return 0
  }
}

// Default arguments of local functions inside '@inlinable' contexts should
// be serialized.
// https://github.com/apple/swift/issues/54842

// CHECK-LABEL: sil [serialized] [ossa] @$s23default_arguments_local5outeryyF : $@convention(thin) () -> () {
@inlinable public func outer() {
  // CHECK-LABEL: sil shared [serialized] [ossa] @$s23default_arguments_local5outeryyF5innerL_1xySi_tFfA_ : $@convention(thin) () -> Int {

  // CHECK-LABEL: sil shared [serialized] [ossa] @$s23default_arguments_local5outeryyF5innerL_1xySi_tF : $@convention(thin) (Int) -> () {
  func inner(x: Int = 0) {}

  inner()
}

// CHECK-LABEL: sil hidden [ossa] @$s23default_arguments_local5outeryyxlF : $@convention(thin) <T> (@in_guaranteed T) -> ()
func outer<T>(_: T) {
  // CHECK-LABEL: sil private [ossa] @$s23default_arguments_local5outeryyxlF5innerL_yylF : $@convention(thin) <T> () -> ()
  func inner() { print(T.self) }

  // default argument 0 of hasDefault #1 <A>(x:) in outer<A>(_:)
  // CHECK-LABEL: sil private [ossa] @$s23default_arguments_local5outeryyxlF10hasDefaultL_1xySi_tlFfA_ : $@convention(thin) <T> () -> Int

  // CHECK-LABEL: sil private [ossa] @$s23default_arguments_local5outeryyxlF10hasDefaultL_1xySi_tlF : $@convention(thin) <T> (Int) -> ()
  func hasDefault(x: Int = { inner(); return 3 }()) {}
  hasDefault()
}
// --- Seed B ---
// RUN: %target-typecheck-verify-swift -enable-experimental-feature DefaultIsolationPerFile

// REQUIRES: swift_feature_DefaultIsolationPerFile

// REQUIRES: concurrency

using @MainActor
// expected-note@-1 {{default isolation was previously declared here}}

using nonisolated
// expected-error@-1 {{invalid redeclaration of file-level default actor isolation}}

using @Test // expected-error {{default isolation can only be set to '@MainActor' or 'nonisolated'}}
using test // expected-error {{default isolation can only be set to '@MainActor' or 'nonisolated'}}

do {
  using // expected-warning {{expression of type 'Int' is unused}}
  @MainActor
// expected-error@+1 {{expected declaration}}
}

do {
  using // expected-warning {{expression of type 'Int' is unused}}
  nonisolated // expected-error {{cannot find 'nonisolated' in scope}}
}

do {
  func
  using (x: Int) {}

  using(x: 42)
}

do {
  func
  using
  (x: Int) {}

  using(x: 42)
}

let
  using = 42

let (x: Int, using: String) = (x: 42, using: "")

do {
  using @MainActor // expected-error {{declaration is only valid at file scope}}
}

func test() {
  using @MainActor // expected-error {{declaration is only valid at file scope}}
}

struct S {
  var x: Int {
    using @MainActor // expected-error {{declaration is only valid at file scope}}
  }

  using @MainActor func test() {}
  // expected-error@-1 {{declaration is only valid at file scope}}
  // expected-error@-2 {{consecutive declarations on a line must be separated by ';'}}

  using nonisolated subscript(a: Int) -> Bool { false }
  // expected-error@-1 {{declaration is only valid at file scope}}
  // expected-error@-2 {{consecutive declarations on a line must be separated by ';'}}
}

do {
  @objc using @MainActor
  // expected-error@-1 {{declaration is only valid at file scope}}
}
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
func _ffl_p3_make(_ flag: Bool) -> some _FflProducer {
    if flag { return _FflIntProducer(seed: 42) as! any _FflProducer as! _FflIntProducer }
    return _FflIntProducer(seed: 0)
}
do {
    let _ffl_flag = String(describing: _ffl_sentinel).isEmpty
    let _ffl_prod = _ffl_p3_make(_ffl_flag)
    _ = _ffl_prod.produce()
}
