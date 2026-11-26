

// --- Seed A ---
// REQUIRES: swift_swift_parser, executable_test

// RUN: %empty-directory(%t)
// RUN: %host-build-swift -swift-version 5 -emit-library -o %t/%target-library-name(MacroDefinition) -module-name=MacroDefinition %S/Inputs/syntax_macro_definitions.swift

// RUN: %target-swift-frontend -typecheck -swift-version 5 -load-plugin-library %t/%target-library-name(MacroDefinition) -module-name MacroUser -parse-as-library -emit-reference-dependencies-path %t/MacroUser.swiftdeps -primary-file %s

// Note: this test ensures that we don't crash when trying to mangle a symbol
// within a closure passed to a macro.

@freestanding(declaration)
macro Empty<T>(_ x: T) = #externalMacro(module: "MacroDefinition", type: "EmptyDeclarationMacro")

#Empty {
    struct S {
        static var foo: Int { 0 }
    }
    _ = S.foo
}

// --- Seed B ---
// Ensure that an incomplete output-file-map path does not crash the driver,
// but instead outputs a nice diagnostic.
//
// RUN: %empty-directory(%t)
// RUN: split-file %s %t
// RUN: not %swiftc_driver -c %S/../Inputs/empty.swift -output-file-map %t/malformed-output-file-map.json 2>&1 | %FileCheck %s
//
// CHECK: error: Expected quote at end of scalar
// CHECK-NOT: Assertion failed

//--- malformed-output-file-map.json
{
  "/path/to/some/file.swift": {
    "dependencies": "
var _ffl_sentinel: Int = 0
// --- Bug Primitive ---

// P4: Closure capture / @escaping / ownership stress
func _ffl_p4_apply<T>(_ f: () -> T) -> T { f() }
func _ffl_p4_escape<T>(_ f: @escaping () -> T) -> () -> T { f }
do {
    var _ffl_cap = _ffl_sentinel
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
    _ffl_cap = _ffl_sentinel
    _ = _ffl_esc()
}
