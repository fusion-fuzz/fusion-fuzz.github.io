// RUN: %target-typecheck-verify-swift

@available(*, deprecated)
func dep() -> Bool { return false }

@available(*, deprecated)
class depClass {}

// Function
@diagnose(DeprecatedDeclaration, as: error)
func foo() {
    let _: Bool = dep() // expected-error {{'dep()' is deprecated}}
    @diagnose(DeprecatedDeclaration, as: warning)
    func bar() {
        let _: Bool = dep() // expected-warning {{'dep()' is deprecated}}
        @diagnose(DeprecatedDeclaration, as: ignored)
        @diagnose(PerformanceHints, as: error)
        func baz() {
            let _: Bool = dep()
        }
        @diagnose(DeprecatedDeclaration, as: error)
        func qux() {
            let _: Bool = dep() // expected-error {{'dep()' is deprecated}}
            @diagnose(DeprecatedDeclaration, as: warning)
            func corge() {
                let _: Bool = dep() // expected-warning {{'dep()' is deprecated}}
            }
        }
    }
}

// Nominal types
@diagnose(DeprecatedDeclaration, as: error)
class Foo {
    let x = dep() // expected-error {{'dep()' is deprecated}}
}
@diagnose(DeprecatedDeclaration, as: ignored)
struct Bar {
    let x = dep()
}
@diagnose(DeprecatedDeclaration, as: warning)
enum Baz {
    var x: Bool { dep() } // expected-warning {{'dep()' is deprecated}}
}
@diagnose(DeprecatedDeclaration, as: error)      
actor Qux {
    let x = dep() // expected-error {{'dep()' is deprecated}}
    @diagnose(DeprecatedDeclaration, as: ignored)
    struct Quux {
        let x = dep()
    }
}
@diagnose(DeprecatedDeclaration, as: error)
protocol Proto {
    var x: depClass { get } // expected-error {{'depClass' is deprecated}}
}

// Initializer
@diagnose(DeprecatedDeclaration, as: error)
struct Corge : ~Copyable {
    let x = dep() // expected-error {{'dep()' is deprecated}}
    @diagnose(DeprecatedDeclaration, as: ignored)
    init() {
        let _ = dep() 
    }
    @diagnose(DeprecatedDeclaration, as: warning) 
    deinit {
        let _ = dep() // expected-warning {{'dep()' is deprecated}}
    }
}

// Extension
@diagnose(DeprecatedDeclaration, as: error)
extension Foo {
    var y: Bool { dep() } // expected-error {{'dep()' is deprecated}}
}

// Import
@diagnose(PreconcurrencyImport, as: error)
@preconcurrency import Swift // expected-error {{'@preconcurrency' on module 'Swift' has no effect}}
@diagnose(PreconcurrencyImport, as: ignored)
@preconcurrency import Swift

// Subscript
struct Hmm {
    @diagnose(DeprecatedDeclaration, as: error)
    subscript(index: Int) -> Bool {
        return dep() // expected-error {{'dep()' is deprecated}}
    }
} 

// Computed property
@diagnose(DeprecatedDeclaration, as: ignored)
extension Foo {
    @diagnose(DeprecatedDeclaration, as: error)
    var property: Bool {
        return dep() // expected-error {{'dep()' is deprecated}}
    }
}
// RUN: %target-typecheck-verify-swift -enable-bare-slash-regex -disable-availability-checking -experimental-skip-all-function-bodies
// RUN: %target-typecheck-verify-swift -enable-bare-slash-regex -disable-availability-checking -experimental-skip-non-inlinable-function-bodies-without-types
// RUN: %target-typecheck-verify-swift -enable-bare-slash-regex -disable-availability-checking -experimental-skip-non-inlinable-function-bodies

// REQUIRES: swift_swift_parser

// We don't consider this a regex literal when skipping as it has an initial
// space.
func a() { _ = / x*/ } // expected-error {{unexpected end of block comment}}

// Same because of unbalanced ')'
func b() { _ = /x)*/ } // expected-error {{unexpected end of block comment}}

// These also fail the heuristic, but have unbalanced `{` `}`, so we don't skip.
func c() { _ = / x}*/ } // expected-error {{regex literal may not start with space; add backslash to escape}}
func d() { _ = / x{*/ } // expected-error {{regex literal may not start with space; add backslash to escape}}

// Unterminated, and unbalanced `{}`.
func e() {
  _ = /         }
  // expected-error@-1 {{unterminated regex literal}}
  // expected-error@-2 {{regex literal may not start with space; add backslash to escape}}
}
func f() {
  _ = /         {
  // expected-error@-1 {{unterminated regex literal}}
  // expected-error@-2 {{regex literal may not start with space; add backslash to escape}}
}
func g() {
  _ = /x         }
} // expected-error {{extraneous '}' at top level}}
func h() {
  _ = /x         {
  } // The above cannot a regex literal so we skip; this `}` is to balance things out.
}
func i() {
  _ = /x "[abc]     {
  // expected-error@-1 {{unterminated string literal}}
}
func j() {
  _ = /^ [abc]     {
  // expected-error@-1 {{unterminated regex literal}}
}
func k() {
  _ = /^ "[abc]     {
  // expected-error@-1 {{unterminated string literal}}
}
func l() {
  _ = /^    } abc     {
  // expected-error@-1 {{unterminated regex literal}}
}
func m() {
  _ = / "
  // expected-error@-1 {{unterminated string literal}}
  }
} // expected-error {{extraneous '}' at top level}}

// Unbalanced `}`, make sure we don't consider the string literal `{`.
func n() { / "{"}/ } // expected-error {{regex literal may not start with space; add backslash to escape}}

func o() {
  _ = {
    0
    /x}}} /
    2
  } // expected-error {{extraneous '}' at top level}}
  // expected-error@-3 {{extraneous '}' at top level}}
  // expected-error@-4 {{consecutive statements on a line must be separated by ';'}}
  // expected-error@-5 {{unterminated regex literal}}
  // expected-warning@-6 {{regular expression literal is unused}}
  // expected-warning@-6 {{integer literal is unused}}
} // expected-error {{extraneous '}' at top level}}

func p() {
  _ = 2
  /x} /
    .bitWidth
  // expected-error@-2 {{consecutive statements on a line must be separated by ';'}}
  // expected-error@-3 {{unterminated regex literal}}
  // expected-error@-3 {{value of type 'Regex<Substring>' has no member 'bitWidth'}}
} // expected-error {{extraneous '}' at top level}}

func err1() { _ = / 0xG}/ }
// expected-error@-1 {{regex literal may not start with space; add backslash to escape}}
func err2() { _ = / 0oG}/ }
// expected-error@-1 {{regex literal may not start with space; add backslash to escape}}
func err3() { _ = / {"/ }

// Accessors
@diagnose(DeprecatedDeclaration, as: ignored)
extension Foo {
    var b: Bool { dep() }
    var computed_property: Bool {
        @diagnose(DeprecatedDeclaration, as: error)
        get {
            return dep() // expected-error {{'dep()' is deprecated}}
        }
        @diagnose(DeprecatedDeclaration, as: warning)
        set {
            let _ = dep() // expected-warning {{'dep()' is deprecated}}
        }
    }
}

// Observers
@diagnose(DeprecatedDeclaration, as: ignored)
struct Foox {
    var observed_property: Bool {
        @diagnose(DeprecatedDeclaration, as: error)
        willSet {
            let _ = dep() // expected-error {{'dep()' is deprecated}}
        }
        @diagnose(DeprecatedDeclaration, as: warning)
        didSet {
            let _ = dep() // expected-warning {{'dep()' is deprecated}}
        }
    }
}

// Enum case
enum UnEnum {
  @diagnose(DeprecatedDeclaration, as: error)
  case foo(depClass) // expected-error {{'depClass' is deprecated}}
}

// Enum raw value case
enum RawEnum: Int32 {
  @diagnose(DeprecatedDeclaration, as: error)
  case foo = 32
}

// Typealias
@diagnose(DeprecatedDeclaration, as: error)
typealias Sneaky = depClass // expected-error {{'depClass' is deprecated}}

// Associated type
protocol P {
  @diagnose(DeprecatedDeclaration, as: error)
  associatedtype AT: depClass // expected-error {{'depClass' is deprecated}}
}

// Macro declaration
@diagnose(DeprecatedDeclaration, as: error)
@freestanding(declaration, names: named(FooMacro))
macro FooMacro(_ s: depClass) = #externalMacro(module: "Foo", type: "Bar") // expected-error {{'depClass' is deprecated}}
// expected-warning@-1 {{external macro implementation type 'Foo.Bar' could not be found for macro 'FooMacro'; plugin for module 'Foo' not found}}

// With property wrapper
@propertyWrapper
@available(*, deprecated)
struct depIntClamped {
    private var value: Int
    var wrappedValue: Int {
        get { value }
        set { value = min(max(newValue, 0), 42) }
    }
    init(wrappedValue: Int) {
        self.value = min(max(wrappedValue, 0), 42)
    }
}

func baz() {
  @depIntClamped // expected-error {{'depIntClamped' is deprecated}}
  @diagnose(DeprecatedDeclaration, as: error)
  var score1: Int = 5

  @diagnose(DeprecatedDeclaration, as: error)
  @depIntClamped // expected-error {{'depIntClamped' is deprecated}}
  var score2: Int = 5

  @diagnose(DeprecatedDeclaration, as: error)
  @depIntClamped // nothing
  @diagnose(DeprecatedDeclaration, as: ignored)
  var score3: Int = 5
}
// expected-error@-1 {{regex literal may not start with space; add backslash to escape}}
func err4() { _ = / {'/ }
// expected-error@-1 {{regex literal may not start with space; add backslash to escape}}
func err5() { _ = / {<#placeholder#>/ }
// expected-error@-1 {{regex literal may not start with space; add backslash to escape}}
