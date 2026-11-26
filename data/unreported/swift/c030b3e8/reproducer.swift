

// --- Seed A ---
var x = [2.0]
x[0] += 1
x[0] *= 2
x[0] = x[0] * x[0]
x[0] -= 8
x[0] = Double(Int(x[0]) / 5)
x[0] = Double(Int(x[0]) % 3)
x[0] = Double(Int(x[0]) & 2)
x[0] = Double(Int(x[0]) | 5)
x[0] = Double(Int(x[0]) ^ 1)
x[0] /= 2
// --- Seed B ---
// RUN: %target-typecheck-verify-swift  -enable-experimental-feature Reparenting

// REQUIRES: swift_feature_Reparenting


@reparentable
@available(macOS 75, *)
public protocol BorrowSeq<Element> {
  x Element
}

public protocol Seq<Element>: BorrowSeq {
  associatedtype Element
}

@available(macOS 75, *)
extension Seq: @reparented BorrowSeq {}

public protocol Coll<Element>: Seq {
  override associatedtype Element
}

public protocol LCP: Coll, Seq {}

// This unqualified reference to Element should not resolve to BorrowSeq.Element
extension LCP where Element: Sendable {}
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
