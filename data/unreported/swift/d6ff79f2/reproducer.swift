// RUN: %target-swift-frontend -print-target-info -runtime-compatibility-version 5.8 | %FileCheck %s


// --- Seed A ---
typealias Type1<T> = (T) -> T
typealias Type5<A> = (A, Void)

let value: Type5<String> = ("ok", ())
_ = value
// --- Seed B ---
// RUN: %target-swift-frontend -print-target-info -runtime-compatibility-version 5.8 | %FileCheck %s

// REQUIRES: OS=macosx

// CHECK:       "libraryName": "swiftCompatibilityPacks",
// CHECK-NEXT:  "filter": "all",
// CHECK-NEXT:  "forceLoad": false
// --- Bug Primitive ---

// REQUIRES: OS=macosx

// CHECK:       "libraryName": "swiftCompatibilityPacks",
// CHECK-NEXT:  "filter": "all",
// CHECK-NEXT:  "forceLoad": false

// P4: Closure capture / @escaping / ownership stress
func _ffl_p4_apply<T>(_ f: () -> T) -> T { f() }
func _ffl_p4_escape<T>(_ f: @escaping () -> T) -> () -> T { f }
do {
    var _ffl_cap = value
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
    _ffl_cap = value
    _ = _ffl_esc()
}
