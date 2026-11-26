import _Differentiation

// --- Seed A ---
// REQUIRES: OS=macosx

// RUN: %empty-directory(%t)

// RUN: %target-swift-frontend -typecheck %S/Inputs/linker-directive.swift -tbd-is-installapi -emit-tbd -emit-tbd-path %t/linker_directives_installapi.tbd -previous-module-installname-map-file %S/Inputs/install-name-map-toasterkit.json -tbd-install_name toasterkit
// RUN: %llvm-nm %t/linker_directives_installapi.tbd | %FileCheck %s --check-prefixes=CHECK,CHECK-MAC --implicit-check-not "System/Previous/macCatalyst"
// RUN: %target-swift-frontend -typecheck %S/Inputs/linker-directive.swift -emit-tbd -emit-tbd-path %t/linker_directives_macos.tbd -previous-module-installname-map-file %S/Inputs/install-name-map-toasterkit.json -tbd-install_name toasterkit
// RUN: %llvm-nm %t/linker_directives_macos.tbd | %FileCheck %s --check-prefixes=CHECK,CHECK-MAC --implicit-check-not "System/Previous/macCatalyst"

// RUN: %target-swift-frontend -target-variant x86_64-apple-ios13.1-macabi -typecheck %S/Inputs/linker-directive.swift -emit-tbd -emit-tbd-path %t/linker_directives_macos_macabi.tbd -previous-module-installname-map-file %S/Inputs/install-name-map-toasterkit.json -tbd-install_name toasterkit
// RUN: %llvm-nm %t/linker_directives_macos_macabi.tbd | %FileCheck -check-prefixes=CHECK,CHECK-MAC,CHECK-MACCATALYST %s

// RUN: %target-swift-frontend -target x86_64-apple-ios13.1-macabi -typecheck %S/Inputs/linker-directive.swift -emit-tbd -emit-tbd-path %t/linker_directives_macabi.tbd -previous-module-installname-map-file %S/Inputs/install-name-map-toasterkit.json -tbd-install_name toasterkit
// R/UN: %llvm-nm %t/linker_directives_macabi.tbd | %FileCheck -check-prefixes=CHECK,CHECK-MACCATALYST %s --implicit-check-not "System/Previous/macOS"

// CHECK-MACCATALYST: D $ld$previous$/System/Previous/macCatalyst/ToasterKit.dylib$$6$1.0$13.0$_$s10ToasterKit5toastyyF$
// CHECK-MACCATALYST: D $ld$previous$/System/Previous/macCatalyst/ToasterKit.dylib$$6$1.0$13.0$_$s10ToasterKit7VehicleV4moveyyF$
// CHECK-MACCATALYST: D $ld$previous$/System/Previous/macCatalyst/ToasterKit.dylib$$6$1.0$13.0$_$s10ToasterKit7VehicleVMa$
// CHECK-MACCATALYST: D $ld$previous$/System/Previous/macCatalyst/ToasterKit.dylib$$6$1.0$13.0$_$s10ToasterKit7VehicleVMn$
// CHECK-MACCATALYST: D $ld$previous$/System/Previous/macCatalyst/ToasterKit.dylib$$6$1.0$13.0$_$s10ToasterKit7VehicleVN$
// CHECK-MACCATALYST: D $ld$previous$/System/Previous/macCatalyst/ToasterKit.dylib$$6$1.0$18.0$_$s10ToasterKit14movedPriorTo26yyF
// CHECK-MACCATALYST: D $ld$previous$/System/Previous/macCatalyst/ToasterKit.dylib$$6$1.0$26.0$_$s10ToasterKit16movedInVersion26yyF$
// CHECK-MACCATALYST: D $ld$previous$/System/Previous/macCatalyst/ToasterKit.dylib$$6$1.0$26.0$_$s10ToasterKit26movedInVersionsMappingTo26yyF$
// CHECK-MACCATALYST: D $ld$previous$/System/Previous/macCatalyst/ToasterKit.dylib$$6$1.0$27.0$_$s10ToasterKit26movedInVersionsMappingTo27yyF$

// CHECK-MAC: D $ld$previous$/System/Previous/macOS/ToasterKit.dylib$$1$1.0$10.15$_$s10ToasterKit5toastyyF$
// CHECK-MAC: D $ld$previous$/System/Previous/macOS/ToasterKit.dylib$$1$1.0$10.15$_$s10ToasterKit7VehicleV4moveyyF$
// CHECK-MAC: D $ld$previous$/System/Previous/macOS/ToasterKit.dylib$$1$1.0$10.15$_$s10ToasterKit7VehicleVMa$
// CHECK-MAC: D $ld$previous$/System/Previous/macOS/ToasterKit.dylib$$1$1.0$10.15$_$s10ToasterKit7VehicleVMn$
// CHECK-MAC: D $ld$previous$/System/Previous/macOS/ToasterKit.dylib$$1$1.0$10.15$_$s10ToasterKit7VehicleVN$
// CHECK-MAC: D $ld$previous$/System/Previous/macOS/ToasterKit.dylib$$1$1.0$15.0$_$s10ToasterKit14movedPriorTo26yyF$
// CHECK-MAC: D $ld$previous$/System/Previous/macOS/ToasterKit.dylib$$1$1.0$26.0$_$s10ToasterKit16movedInVersion26yyF$
// CHECK-MAC: D $ld$previous$/System/Previous/macOS/ToasterKit.dylib$$1$1.0$26.0$_$s10ToasterKit26movedInVersionsMappingTo26yyF$
// CHECK-MAC: D $ld$previous$/System/Previous/macOS/ToasterKit.dylib$$1$1.0$27.0$_$s10ToasterKit26movedInVersionsMappingTo27yyF$

// CHECK-NOT: $_$s10ToasterKit7VehicleV32originallyDefinedInCurrentModuleyyF
// --- Seed B ---
// RUN: %target-swift-frontend -emit-sil %s

// TF-1315: Pullback subset thunk generation crash due to unmapped parameter
// index for `inout` differentiability parameters.


func foo(_ x: Int, _ y: Float, _ z: inout Float) {}

@derivative(of: foo, wrt: (y, z))
func vjpFoo(_ x: Int, _ y: Float, _ z: inout Float) -> (
  value: Void, pullback: (inout Float) -> Float
) {
  fatalError()
}

@differentiable(reverse)
func TF_1315(_ x: Float) -> Float {
  var x = x
  // The call to `foo` below triggers pullback subset parameter thunk generation.
  // `foo` original function type: `(Int, Float, inout Float) -> ()`
  //     Actual parameter indices: 1, 2
  //    Desired parameter indices: 2
  foo(1, 2, &x)
  return x
}
var _ffl_sentinel: Int = 0
// --- Bug Primitive ---

// P6: Non-copyable (~Copyable) consume/borrow stress
struct _FflMoveOnly: ~Copyable {
    var payload: Int
    init(_ v: Int) { payload = v }
    consuming func consume() -> Int { payload }
    borrowing func inspect() -> Int { payload }
}
func _ffl_p6_transfer(_ v: consuming _FflMoveOnly) -> Int {
    v.consume()
}
do {
    var _ffl_mo = _FflMoveOnly(String(describing: _ffl_sentinel).count)
    _ = _ffl_mo.inspect()           // borrow — ownership retained
    let _ffl_result = _ffl_p6_transfer(_ffl_mo) // consume — ownership transferred
    _ = _ffl_result
    // Re-init after consume
    _ffl_mo = _FflMoveOnly(0)
    _ = _ffl_mo.inspect()
}
