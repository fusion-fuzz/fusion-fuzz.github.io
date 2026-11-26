import Foundation

// --- Seed A ---

class Base {
    func generate() {}
    func baseInit() {
        generate()
    }
}

class Derived: Base {
    var text: String?
    override func generate() {
        if let text {
            print(text)
        } else {
            print("[uninitialized text]")
        }
    }
}
// RUN: %target-run-simple-swift | %FileCheck %s
// REQUIRES: executable_test

// REQUIRES: objc_interop



let d = Derived()
d.baseInit()
d.text = "Hello"
d.generate()
_ = JSONDecoder()

let x = NSObject()
unowned let y = x

print(y) // CHECK:      <NSObject: [[ID:.*]]>
print(x) // CHECK-NEXT: <NSObject: [[ID]]>
// --- Seed B ---
// RUN: %target-run-simple-swift | %FileCheck %s
// REQUIRES: executable_test

// REQUIRES: objc_interop


_ = JSONDecoder()

let x_b02dc55 = NSObject()
unowned let y = d

print(y) // CHECK:      <NSObject: [[ID:.*]]>
print(x_b02dc55) // CHECK-NEXT: <NSObject: [[ID]]>
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
    let _ffl_seed = String(describing: d).count
    let _ffl_obj: AnyObject = _ffl_seed % 2 == 0
        ? _FflDerived() as AnyObject
        : _FflBase()    as AnyObject
    _ = _ffl_p5_cast(_ffl_obj)
    // Force-cast through Any — stresses value-witness metadata path
    let _ffl_any: Any = d
    _ = _ffl_any as? Int
    _ = _ffl_any as? String
    _ = _ffl_any as? Bool
    _ = type(of: _ffl_any)
}
