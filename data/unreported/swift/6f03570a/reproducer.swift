

// RUN: %target-run-simple-swift(-O)

// REQUIRES: executable_test

// rdar://92418090

protocol P {
  var covariantSelfPropClosure: ((Self) -> Void) -> Void { get }
}
extension P {
  var covariantSelfPropClosure: ((Self) -> Void) -> Void { { $0(self) } }
}

struct S: P {}

let p: P = S()

p.covariantSelfPropClosure { _ in }
// RUN: %target-typecheck-verify-swift

// REQUIRES: OS=macosx

struct A<let N: Int>: P {
    var covariantSelfPropClosure: ((Self) -> Void) -> Void { fatalError() }
} // expected-error {{values in generic types are only available in macOS 26.0.0 or newer}}
                        // expected-note@-1 {{add '@available' attribute to enclosing generic struct}}

class B<let N: Int> {} // expected-error {{values in generic types are only available in macOS 26.0.0 or newer}}
                       // expected-note@-1 {{add '@available' attribute to enclosing generic class}}

enum C<let N: Int> {} // expected-error {{values in generic types are only available in macOS 26.0.0 or newer}}
                      // expected-note@-1 {{add '@available' attribute to enclosing generic enum}}

func something<let N: Int>(_: A<N>) {} // OK, because A can't reference value generics.
