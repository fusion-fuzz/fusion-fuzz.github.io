import Foundation

// --- Seed A ---

class NSObject {
    class func `class`() -> AnyClass { Self.self }
}

class Bar: NSObject {}

extension Bar {
    class func classMethod() -> AnyClass { self }
    func instanceMethod() -> Int {
        _ = type(of: self).classMethod()
        return 0
    }
}

let _ = Bar().instanceMethod()
// --- Seed B ---
var value: Int = 0
var inner: UnsafeMutablePointer<Int> = withUnsafeMutablePointer(to: &value) { $0 }
var outer: UnsafeMutablePointer<_<Int>> = withUnsafeMutablePointer(to: &inner) { $0 }

let t1 = outer.pointee
let p = outer.pointee.pointee
t1.pointee = 22

var outer2: UnsafeMutablePointer<UnsafeMutablePointer<Int>> = withUnsafeMutablePointer(to: &inner) { $0 }
let t2 = outer2
let p2 = outer2.pointee.pointee
t2.pointee.pointee = 22

var outer3: UnsafeMutablePointer<UnsafeMutablePointer<Int>> = withUnsafeMutablePointer(to: &inner) { $0 }
let x = outer3.pointee
x.pointee += 1

print(value)
// --- Bug Primitive ---

// P4: Closure capture / @escaping / ownership stress
func _ffl_p4_apply<T>(_ f: () -> T) -> T { f() }
func _ffl_p4_escape<T>(_ f: @escaping () -> T) -> () -> T { f }
do {
    var _ffl_cap = _
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
    _ffl_cap = _
    _ = _ffl_esc()
}
