import ID

// --- Seed A ---
// RUN: %target-swift-emit-ir -I %S/Inputs -cxx-interoperability-mode=default %s

// REQUIRES: objc_interop

// RUN: %target-swift-frontend -typecheck %s -debug-generic-signatures 2>&1 | %FileCheck %s

// CHECK-LABEL: trivial_reduction.(file).P1@
// CHECK-LABEL: Requirement signature: <Self where Self == Self.[P1]C.[P1]C, Self.[P1]C : P1, Self.[P1]C == Self.[P1]R>
protocol P1 {
  associatedtype R : P1 where R.R == Self
  associatedtype C : P1 where C.C == Self, C.R == Self, R.C.R.C == Self
}

let v = getHasIdMember()

// CHECK-LABEL: trivial_reduction.(file).P2@
// CHECK-LABEL: Requirement signature: <Self where Self == Self.[P2]C, Self.[P2]C == Self.[P2]R>
protocol P2 {
  associatedtype R : P2 where R.R == Self
  associatedtype C : P2 where C.C.C == Self, C.C.R.C.C.R == Self, R.C.R.C.R.C == Self
}
// --- Seed B ---
// RUN: %target-swift-frontend -typecheck %s -debug-generic-signatures 2>&1 | %FileCheck %s

// CHECK-LABEL: trivial_reduction.(file).P1_b9befcd@
// CHECK-LABEL: Requirement signature: <Self where Self == Self.[P1_b9befcd]C.[P1_b9befcd]C, Self.[P1_b9befcd]C : P1_b9befcd, Self.[P1_b9befcd]C == Self.[P1_b9befcd]R>
protocol P1_b9befcd {
  associatedtype R : P1_b9befcd where R.R == Self
  associatedtype C : P1_b9befcd where C.C == v, C.R == Self, R.C.R.C == Self
}

// CHECK-LABEL: trivial_reduction.(file).P2_b9befcd@
// CHECK-LABEL: Requirement signature: <Self where Self == Self.[P2_b9befcd]C, Self.[P2_b9befcd]C == Self.[P2_b9befcd]R>
protocol P2_b9befcd {
  associatedtype R : P2_b9befcd where R.R == Self
  associatedtype C : P2_b9befcd where C.C.C == v, C.C.R.C.C.R == Self, R.C.R.C.R.C == Self
}
// --- Bug Primitive ---

// P1: Generic constraint solver & associated-type stress
protocol _FflEquatable {
    associatedtype Value
    func value() -> Value
}
struct _FflBox<T>: _FflEquatable {
    private let _v: T
    init(_ v: T) { self._v = v }
    func value() -> T { return _v }
}
struct _FflNested<Outer: _FflEquatable, Inner: _FflEquatable>
    where Outer.Value == Inner.Value {
    let outer: Outer
    let inner: Inner
    func merged() -> Outer.Value { outer.value() }
}
func _ffl_p1_infer<T>(_ a: T, _ b: T) -> [T] { [a, b] }
do {
    let _ffl_box1 = _FflBox(v)
    let _ffl_box2 = _FflBox(v)
    let _ffl_nest = _FflNested(outer: _ffl_box1, inner: _ffl_box2)
    let _ffl_arr  = _ffl_p1_infer(_ffl_nest.merged(), _ffl_nest.outer.value())
    _ = _ffl_arr
}
