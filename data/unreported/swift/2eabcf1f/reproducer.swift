// REQUIRES: swift_swift_parser, executable_test, string_processing

// RUN: %empty-directory(%t)

// Build the plugin
// RUN: %host-build-swift %S/../../Macros/Inputs/syntax_macro_definitions.swift -emit-library -o %t/%target-library-name(MacroDefinition) -module-name=MacroDefinition -swift-version 5 -g -no-toolchain-stdlib-rpath

// RUN: %target-build-swift %s -module-name Macro -emit-module -emit-module-path %t -swift-version 5 -load-plugin-library %t/%target-library-name(MacroDefinition)
// RUN: %target-swift-symbolgraph-extract -module-name Macro -I %t -pretty-print -output-dir %t
// RUN: %FileCheck %s --input-file %t/Macro.symbols.json
// RUN: %FileCheck %s --input-file %t/Macro.symbols.json --check-prefix MISSING

@freestanding(expression)
public macro customFileID() -> String = #externalMacro(module: "MacroDefinition", type: "FileIDMacro")



// --- Seed A ---

var foo: Double { 1 / 2 }
var bar: Regex<Substring> { /x/ }
var baz: Regex<Substring> { / x/ }
var qux: Regex<Substring> { / x}/ }

// Check that we are not crashing
// RUN: %sourcekitd-test \
// RUN: -req=complete -pos=2:18 %s -- -enable-bare-slash-regex %s == \
// RUN: -req=complete -pos=3:28 %s -- -enable-bare-slash-regex %s == \
// RUN: -req=complete -pos=4:28 %s -- -enable-bare-slash-regex %s == \
// RUN: -req=complete -pos=5:28 %s -- -enable-bare-slash-regex %s

// REQUIRES: swift_swift_parser
// --- Seed B ---
// REQUIRES: swift_swift_parser, executable_test, string_processing

// RUN: %empty-directory(%t)

// Build the plugin
// RUN: %host-build-swift %S/../../Macros/Inputs/syntax_macro_definitions.swift -emit-library -o %t/%target-library-name(MacroDefinition) -module-name=MacroDefinition -swift-version 5 -g -no-toolchain-stdlib-rpath

// RUN: %target-build-swift %s -module-name Macro -emit-module -emit-module-path %t -swift-version 5 -load-plugin-library %t/%target-library-name(MacroDefinition)
// RUN: %target-swift-symbolgraph-extract -module-name Macro -I %t -pretty-print -output-dir %t
// RUN: %FileCheck %s --input-file %t/Macro.symbols.json
// RUN: %FileCheck %s --input-file %t/Macro.symbols.json --check-prefix MISSING

@freestanding(expression)
public macro customFileID_d7cb162() -> String = #externalMacro(module: "MacroDefinition", type: "FileIDMacro")

@attached(peer)
public macro addCompletionHandler_d7cb162() = #externalMacro(module: "MacroDefinition", type: "AddCompletionHandler")

@freestanding(expression)
macro moduleCustomFileID_d7cb162() -> String = #externalMacro(module: "MacroDefinition", type: "FileIDMacro")

// CHECK-DAG: "precise": "s:5Macro20addCompletionHandleryycfm"
// CHECK-DAG: "precise": "s:5Macro12customFileIDSSycfm"

// MISSING-NOT: moduleCustomFileID_d7cb162
var _ffl_sentinel: Int = 0
// --- Bug Primitive ---

// P2: Existential boxing / any-Protocol metatype stress
protocol _FflShape {
@attached(peer)
public macro addCompletionHandler() = #externalMacro(module: "MacroDefinition", type: "AddCompletionHandler")

@freestanding(expression)
macro moduleCustomFileID() -> String = #externalMacro(module: "MacroDefinition", type: "FileIDMacro")

// CHECK-DAG: "precise": "s:5Macro20addCompletionHandleryycfm"
// CHECK-DAG: "precise": "s:5Macro12customFileIDSSycfm"

// MISSING-NOT: moduleCustomFileID
    func area() -> Double
    var tag: String { get }
}
struct _FflCircle: _FflShape {
    let r: Double
    func area() -> Double { .pi * r * r }
    var tag: String { "circle" }
}
struct _FflRect: _FflShape {
    let w, h: Double
    func area() -> Double { w * h }
    var tag: String { "rect" }
}
func _ffl_p2_sum(_ shapes: [any _FflShape]) -> Double {
    shapes.reduce(0.0) { $0 + $1.area() }
}
do {
    let _ffl_r = Double(String(describing: _ffl_sentinel).count)
    let _ffl_shapes: [any _FflShape] = [_FflCircle(r: _ffl_r), _FflRect(w: _ffl_r, h: 2.0)]
    _ = _ffl_p2_sum(_ffl_shapes)
    let _ffl_meta: any _FflShape.Type = _FflCircle.self
    _ = _ffl_meta.init(r: _ffl_r)
}
