


// --- Seed A ---
// RUN: %target-swift-frontend %s -module-name=test -emit-sil | %FileCheck %s
// RUN: %target-swift-frontend %s -O -module-name=test -emit-sil | %FileCheck %s --check-prefix=CHECK --check-prefix=OPT

// REQUIRES: swift_stdlib_no_asserts,optimized_stdlib

public struct GenS<T> {
  var a: T
  var b: T
  var c: T
  var d: T
  var e: T
  var f: T
  var g: T
  var h: T
}
// CHECK: enum NS1 {
// CHECK:   static var myConstexprInt: Int32
// CHECK:   static var myStaticConstexprInt: Int32
// CHECK: }

public struct MyStruct {
  // CHECK-LABEL: sil_global [let] @$s4test8MyStructV1rSnySiGvpZ : $Range<Int> = {
  // CHECK-NEXT:    %0 = integer_literal $Builtin.Int{{[0-9]+}}, 1
  // CHECK-NEXT:    %1 = struct $Int (%0)
  // CHECK-NEXT:    %2 = integer_literal $Builtin.Int{{[0-9]+}}, 3
  // CHECK-NEXT:    %3 = struct $Int (%2)
  // CHECK-NEXT:    %initval = struct $Range<Int> (%1, %3)
  // CHECK-NEXT:  }
  public static let r: Range<Int> = 1 ..< 3

  // OPT-LABEL: sil_global [let] @$s4test8MyStructV07genericC0AA4GenSVySiGvpZ : $GenS<Int> = {
  // OPT:         %initval = struct $GenS
  // OPT-NEXT:  }
  public static let genericStruct = GenS(a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7, h: 8)

  // CHECK-LABEL: sil_global [let] @$s4test8MyStructV1aypSg_AEtvpZ : $(Optional<Any>, Optional<Any>) = {
  public static let a: (Any?, Any?) = (nil, nil)

  // CHECK-LABEL: sil_global [let] @$s4test8MyStructV1bs5Error_pSg_AFtvpZ : $(Optional<any Error>, Optional<any Error>) = {
  public static let b: ((any Error)?, (any Error)?) = (nil, nil)

  // CHECK-LABEL: sil_global [let] @$s4test8MyStructV1cypSg_s8Sendable_pSgtvpZ : $(Optional<Any>, Optional<any Sendable>) = {
  public static let c: (Any?, (any Sendable)?) = (nil, nil)
}


// --- Seed B ---
// RUN: %target-swift-ide-test -print-module -module-to-print=ConstexprInNamespace -I %S/Inputs -source-filename=x -cxx-interoperability-mode=upcoming-swift | %FileCheck %s

// CHECK: enum NS1 {
// CHECK:   static var myConstexprInt: Int32
// CHECK:   static var myStaticConstexprInt: Int32
// CHECK: }
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
