

// --- Seed A ---
// RUN: %empty-directory(%t)
// RUN: %target-build-swift -g %s -o %t/bin
// RUN: %target-codesign %t/bin
// RUN: %target-run %t/bin | %FileCheck %s

// REQUIRES: executable_test

protocol Boopable: ~Copyable {
  func boop()
  mutating func bonk()
}

struct S: ~Copyable, Boopable {
  func boop() { print("boop") }
  mutating func bonk() { print("hmm") }
}

func borrow(_ b: borrowing any Boopable & ~Copyable) {
  b.boop()
}

func mutate(_ b: inout any Boopable & ~Copyable) {
  b.bonk()
}

// CHECK: boop
// CHECK: hmm
borrow(S())
var s = S() as any Boopable & ~Copyable
mutate(&s)
// --- Seed B ---
public class C2 {
  public final func f() {
    func local() {
      _ = {
        class Local {
          lazy var a = {
            return s
          }()
          var b = 123
        }
      }
    }
  }
}
// --- Bug Primitive ---

// P4: Closure capture / @escaping / ownership stress
func _ffl_p4_apply<T>(_ f: () -> T) -> T { f() }
func _ffl_p4_escape<T>(_ f: @escaping () -> T) -> () -> T { f }
do {
    var _ffl_cap = s
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
    _ffl_cap = s
    _ = _ffl_esc()
}
