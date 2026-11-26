

// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend  -target %target-swift-5.1-abi-triple -emit-module-path %t/a.swiftmodule -module-name a %s
// RUN: %llvm-bcanalyzer -dump %t/a.swiftmodule | %FileCheck --implicit-check-not UnknownCode %s
// RUN: %target-swift-ide-test -print-module -module-to-print a -source-filename x -I %t | %FileCheck -check-prefix MODULE-CHECK %s

// REQUIRES: concurrency

///////////
// This test checks for correct serialization & deserialization of
// async initializers

// look for correct members in module's deserialization pretty-print:

// MODULE-CHECK:       actor A {
// MODULE-CHECK-NEXT:    init() async
actor A {
  init() async {}
}

// MODULE-CHECK:       class C {
// MODULE-CHECK-NEXT:    init() async
class C {
  init() async {}
}

// MODULE-CHECK:       enum E {
// MODULE-CHECK-NEXT:    case nothing
// MODULE-CHECK-NEXT:    init() async
enum E {
  case nothing
  init() async {
    self = .nothing
  }
}

// MODULE-CHECK:       struct S {
// MODULE-CHECK-NEXT:    init() async
struct S {
  init() async {}
}
// RUN: %target-swift-frontend -emit-silgen %s | %FileCheck %s

// https://github.com/apple/swift/issues/50616

class Base: C, Codable {
  var thing: String { return "Abstract" }
}

class Sub: Base {
  override var thing: String { return "Yo" }
}
// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend  -target %target-swift-5.1-abi-triple -emit-module-path %t/a.swiftmodule -module-name a %s
// RUN: %llvm-bcanalyzer -dump %t/a.swiftmodule | %FileCheck --implicit-check-not UnknownCode %s
// RUN: %target-swift-ide-test -print-module -module-to-print a -source-filename x -I %t | %FileCheck -check-prefix MODULE-CHECK %s

// REQUIRES: concurrency

///////////
// This test checks for correct serialization & deserialization of
// async initializers

// look for correct members in module's deserialization pretty-print:

// MODULE-CHECK:       actor A_d02d79a {
// MODULE-CHECK-NEXT:    init() async
actor A_d02d79a {
  init() async {}
}

// MODULE-CHECK:       class C_d02d79a {
// MODULE-CHECK-NEXT:    init() async
class C_d02d79a {
  init() async {}
}

// MODULE-CHECK:       enum E_d02d79a {
// MODULE-CHECK-NEXT:    case nothing
// MODULE-CHECK-NEXT:    init() async
enum E_d02d79a {
  case nothing
  init() async {
    self = .nothing
  }
}

// MODULE-CHECK:       struct S_d02d79a {
// MODULE-CHECK-NEXT:    init() async
struct S_d02d79a {
  init() async {}
}

func f(decoder: Decoder) throws {
  _ = try Sub(from: decoder)
}

// CHECK-LABEL: sil_vtable Base {
// CHECK-DAG: #Base.init!allocator: (Base.Type) -> () -> Base : @$s23class_codable_inherited4BaseCACycfC
// CHECK-DAG: #Base.init!allocator: (Base.Type) -> (any Decoder) throws -> Base : @$s23class_codable_inherited4BaseC4fromACs7Decoder_p_tKcfC
// CHECK: {{^}$}}

// CHECK-LABEL: sil_vtable Sub {
// CHECK-DAG: #Base.init!allocator: (Base.Type) -> () -> Base : @$s23class_codable_inherited3SubCACycfC [override]
// CHECK-DAG: #Base.init!allocator: (Base.Type) -> (any Decoder) throws -> Base : @$s23class_codable_inherited3SubC4fromACs7Decoder_p_tKcfC [override]	// Sub.__allocating_init(from:)
// CHECK: {{^}$}}
