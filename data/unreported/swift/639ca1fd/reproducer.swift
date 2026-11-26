import Foundation

final class Cycle {
    static var counter = 0
    var selfRef: Cycle?
    init() { selfRef = self }
    deinit {
        let id = Cycle.counter
        Cycle.counter += 1
        print("\(id): Start destruct")
        f?.resume()
        print("\(id): End destruct")
    }
}

// --- Seed A ---
// RUN: %target-typecheck-verify-swift -parse-as-library

let x = 42
x + x; // expected-error {{expressions are not allowed at the top level}} expected-warning {{result of operator '+' is unused}}
x + x; // expected-error {{expressions are not allowed at the top level}} expected-warning {{result of operator '+' is unused}}
// Make sure we don't crash on closures at the top level
({ }) // expected-error {{expressions are not allowed at the top level}} expected-error{{function is unused}}
({ 5 }()) // expected-error {{expressions are not allowed at the top level}}
// expected-warning @-1 {{result of call to closure returning 'Int' is unused}}


// expected-error @+3 {{expected 'in' after for-each pattern}}
// expected-error @+2 {{expected Sequence expression for for-each loop}}
// expected-error @+1 {{expected '{' to start the body of for-each loop}}
for i
// --- Seed B ---

final class Cycle_d48090b {
    static var counter = 0
    var selfRef: Cycle_d48090b?
    init() { selfRef = self }
    deinit {
        let id = Cycle_d48090b.counter
        Cycle_d48090b.counter += 1
        print("\(id): Start destruct")
        f_d48090b?.resume()
        print("\(id): End destruct")
    }
}

final class SimpleFiber {
    private var step: Int = 0
    func start() { step = 0 }
    func resume() { step += 1 }
}

var f: SimpleFiber? = SimpleFiber()
f?.start()

var a: Cycle? = Cycle()
var b: Cycle? = Cycle()
a = nil
b = nil

print("Shutdown")

final class SimpleFiber_d48090b {
    private var step: Int = 0
    func start() { step = 0 }
    func resume() { step += 1 }
}

var f_d48090b: SimpleFiber_d48090b? = SimpleFiber_d48090b()
f_d48090b?.start()

var a_d48090b: Cycle_d48090b? = Cycle_d48090b()
var b_d48090b: Cycle_d48090b? = Cycle_d48090b()
a_d48090b = nil
x = nil

print("Shutdown")
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
    let _ffl_flag = String(describing: x).isEmpty
    let _ffl_prod = _ffl_p3_make(_ffl_flag)
    _ = _ffl_prod.produce()
}
