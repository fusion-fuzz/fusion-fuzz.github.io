// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend  -target %target-swift-5.1-abi-triple -emit-module-path %t/a.swiftmodule -module-name a %s
// RUN: %llvm-bcanalyzer -dump %t/a.swiftmodule | %FileCheck --check-prefix BC-CHECK --implicit-check-not UnknownCode %s
// RUN: %target-swift-frontend -Xllvm -type-lowering-disable-verification -emit-ir -primary-file %s %S/Inputs/opaque_result_type_linkage_2.swift -module-name lib | %FileCheck %s
// RUN: %target-swift-frontend -Xllvm -type-lowering-disable-verification -emit-ir %s -primary-file %S/Inputs/opaque_result_type_linkage_2.swift -module-name lib | %FileCheck %s --check-prefix=OTHER
// RUN: %target-swift-ide-test -print-module -module-to-print a -source-filename x -I %t | %FileCheck --check-prefix MODULE-CHECK %s

// REQUIRES: concurrency

///////////
// This test checks for correct serialization & deserialization of
// nonisolated

// look for correct annotation after first deserialization's module print:

// MODULE-CHECK:      actor UnsafeCounter {
// MODULE-CHECK-NEXT:   var storage: Int
// MODULE-CHECK-NEXT:   nonisolated var count: Int
// MODULE-CHECK-NEXT:   deinit
// MODULE-CHECK-NEXT:   init()
// MODULE-CHECK-NEXT: }

// and look for nonisolated

// BC-CHECK: <Nonisolated_DECL_ATTR abbrevid={{[0-9]+}} op0=0 op1=0/>


actor UnsafeCounter {

  private var storage : Int = 0

  nonisolated
  var count : Int {
    get { 0 }
    set {  }
  }
}

protocol P {
  associatedtype A
  var a: A { get }
}

struct G<T>: P {
  lazy var lazyVar: A = a

  var a: some Any {
    b()
  }

  consuming func b() -> some Any {
    "hello"
  }
}

// We lower the two outlined destroy functions differently depending on the type
// expansion context (there is an opaque result type).
// We therefore must not use hidden linkonce_odr linkage.

// CHECK: define{{.*}} private ptr @"$s3lib1GVyxGlWOh"(ptr %0)
// OTHER: define{{.*}} private ptr @"$s3lib1GVyxGlWOh"(ptr %0, ptr %"some Any", ptr %"Optional<some Any>", ptr %"G<T>")
