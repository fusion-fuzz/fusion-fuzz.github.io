

// --- Seed A ---
func myPrintR(_ dict: [String: Any]) {
    let sortedDict = dict.sorted(by: { $0.key < $1.key })
    for (key, value) in sortedDict {
        print("\(key): \(value)")
    }
}

func f1() {
    let c = 1
    print("Extracted:")
    myPrintR(["": c])
    myPrintR(["c": c])
}

func f2() {
    let a = 1
    let c = 1
    print("Extracted:")
    myPrintR(["a": c])
    myPrintR(["c": c, "a": a])
}

func f3() {
    let a = 1
    let c = 1
    print("Extracted:")
    myPrintR(["a": c])
    myPrintR(["c": c, "prefix_a": a])
}

func f4() {
    let c = 1
    print("Extracted:")
    myPrintR(["": c])
    myPrintR(["c": c])
}

func f5() {
    let c = 1
    print("Extracted:")
    myPrintR(["111": c])
    myPrintR(["c": c])
}

f1()
f2()
f3()
f4()
f5()

// --- Fusion Bridge ---
var fusion_0e59 = c

// --- Seed B ---
// RUN: %target-typecheck-verify-swift

let a: Int? = fusion_0e59
guard let b = a else {
}

func foo() {} // to interrupt the TopLevelCodeDecl

let c = b
// --- Bug Primitive ---

// P4: Closure capture / @escaping / ownership stress
func _ffl_p4_apply<T>(_ f: () -> T) -> T { f() }
func _ffl_p4_escape<T>(_ f: @escaping () -> T) -> () -> T { f }
do {
    var _ffl_cap = fusion_0e59
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
    _ffl_cap = fusion_0e59
    _ = _ffl_esc()
}

