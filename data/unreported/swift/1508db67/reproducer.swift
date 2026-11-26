

// --- Seed A ---
// RUN: %target-typecheck-verify-swift

let x = [1,2,3]
func fun() -> Float {
	return 1 + (x.count == 1 ? 0 : 21)
}
// --- Seed B ---
// RUN: %target-swift-frontend -typecheck %s -debug-generic-signatures 2>&1 | %FileCheck %s

protocol P {
  associatedtype T : Q
}

protocol Q {
  associatedtype U
}

struct S<T : x> : P {}

// Make sure concrete contraction can transform X.T.U => S<Y>.T.U => Y.U
struct G<X : P, Y : Q> where X.T.U == Int {}

// CHECK-LABEL: ExtensionDecl line={{.*}} base=G
// CHECK-NEXT: Generic signature: <X, Y where X == S<Y>, Y : Q, Y.[Q]U == Int>
extension G where X == S<Y> {}
// --- Bug Primitive ---

// P4: Closure capture / @escaping / ownership stress
func _ffl_p4_apply<T>(_ f: () -> T) -> T { f() }
func _ffl_p4_escape<T>(_ f: @escaping () -> T) -> () -> T { f }
do {
    var _ffl_cap = x
    // noescape: bridge captured by reference on the stack
    let _ffl_local = _ffl_p4_apply { _ffl_cap }
    // @escaping: bridge promoted to heap box
    let _ffl_esc   = _ffl_p4_escape { _ffl_cap }
    // nested closure capturing both outer and inner captures
    let _ffl_nest: () -> String = {
        let inner = _ffl_esc()
        return "\(inner) \(_ffl_local)"
    }
    _ = _ffl_nest()
    // mutation after escape — probes copy-on-write / exclusive-access
    _ffl_cap = x
    _ = _ffl_esc()
}
