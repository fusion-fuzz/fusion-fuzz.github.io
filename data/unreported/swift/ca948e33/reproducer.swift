import Empty
import StdlibUnittest

// --- Seed A ---
// RUN: %empty-directory(%t)
// RUN: %swift -disable-legacy-type-info -target x86_64-unknown-linux-gnu -emit-module -parse-stdlib -o %t -module-name Empty -module-link-name swiftEmpty -public-autolink-library anotherLib %S/../Inputs/empty.swift
// RUN: %swift -disable-legacy-type-info -target x86_64-unknown-linux-gnu %s -I %t -parse-stdlib -disable-objc-interop -module-name main -emit-ir -o - | %FileCheck %s

// REQUIRES: CODEGENERATOR=X86


// Check that on ELF targets autolinking information is emitted and marked
// RUN: %empty-directory(%t)
//
// RUN: %target-build-swift -swift-version 5 -g -Onone  -module-name a %s -o %t/a.swift5.Onone.out
// RUN: %target-codesign %t/a.swift5.Onone.out
// RUN: %target-run %t/a.swift5.Onone.out
//
// RUN: %target-build-swift -swift-version 6 -g -Onone  -module-name a %s -o %t/a.swift6.Onone.out
// RUN: %target-codesign %t/a.swift6.Onone.out
// RUN: %target-run %t/a.swift6.Onone.out
//
// RUN: %target-build-swift -swift-version 5 -g -O  -module-name a %s -o %t/a.swift5.O.out
// RUN: %target-codesign %t/a.swift5.O.out
// RUN: %target-run %t/a.swift5.O.out
//
// RUN: %target-build-swift -swift-version 6 -g -O  -module-name a %s -o %t/a.swift6.O.out
// RUN: %target-codesign %t/a.swift6.O.out
// RUN: %target-run %t/a.swift6.O.out
//
// REQUIRES: executable_test
// REQUIRES: concurrency
// UNSUPPORTED: use_os_stdlib
// UNSUPPORTED: back_deployment_runtime


func blackhole<T>(_ t: T) { }

private func runtimeCast<T,U>(_ from: T, to: U.Type) -> U? {
  return from as? U
}

let CastsTests = TestSuite("Casts")

protocol Box<T> {
  associatedtype T
  var t: T { get }
}

CastsTests.test("type(of:) should look through extended existentials (none)") {
  struct C<T>: Box { var t: T }
  func genericErase<T>(_ value: T) -> Any { value }
  let c: any Box<Int> = C(t: 42)
  if #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
    let x = genericErase(c)
    expectEqual("C<Int>", "\(type(of:x))")
  }
}
// as used.

// CHECK-DAG: @_swift1_autolink_entries = private constant [26 x i8] c"-lswiftEmpty\00-lanotherLib\00", section ".swift1_autolink_entries",{{.*}} align 8
// CHECK-DAG: @llvm.used = appending global [{{.*}} x ptr] [{{.*}}ptr @_swift1_autolink_entries{{.*}}], section "llvm.metadata"

protocol OBox<T> : AnyObject {
  associatedtype T
  var t: T { get }
}

CastsTests.test("type(of:) should look through extended existentials (class)") {
  class C<T>: OBox {
    var t: T
    init(t: T) { self.t = t }
  }
  func genericErase<T>(_ value: T) -> Any { value }
  let c: any OBox<Int> = C(t: 42)
  if #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
    let x = genericErase(c)
    expectEqual("C<Int>", "\(type(of:x))")
  }
}


CastsTests.test("type(of:) should look through extended existentials (metatype)") {
  struct C<T>: Box { var t: T }
  func genericErase<T>(_ value: T) -> Any { value }
  let t: any Box<Int>.Type = C<Int>.self
  if #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
    let x = genericErase(t)
    expectEqual("C<Int>.Type", "\(type(of:x))")
  }
}

runAllTests()
// --- Seed B ---
// RUN: %empty-directory(%t)
//
// RUN: %target-build-swift -swift-version 5 -g -Onone  -module-name a %s -o %t/a.swift5.Onone.out
// RUN: %target-codesign %t/a.swift5.Onone.out
// RUN: %target-run %t/a.swift5.Onone.out
//
// RUN: %target-build-swift -swift-version 6 -g -Onone  -module-name a %s -o %t/a.swift6.Onone.out
// RUN: %target-codesign %t/a.swift6.Onone.out
// RUN: %target-run %t/a.swift6.Onone.out
//
// RUN: %target-build-swift -swift-version 5 -g -O  -module-name a %s -o %t/a.swift5.O.out
// RUN: %target-codesign %t/a.swift5.O.out
// RUN: %target-run %t/a.swift5.O.out
//
// RUN: %target-build-swift -swift-version 6 -g -O  -module-name a %s -o %t/a.swift6.O.out
// RUN: %target-codesign %t/a.swift6.O.out
// RUN: %target-run %t/a.swift6.O.out
//
// REQUIRES: executable_test
// REQUIRES: concurrency
// UNSUPPORTED: use_os_stdlib
// UNSUPPORTED: back_deployment_runtime


func blackhole_bdec319<T>(_ t: T) { }

private func runtimeCast_bdec319<T,U>(_ from: T, to: U.Type) -> U? {
  return from as? U
}

let CastsTests_bdec319 = TestSuite("Casts")

protocol Box_bdec319<T> {
  associatedtype T
  var t: T { get }
}

CastsTests_bdec319.test("type(of:) should look through extended existentials (none)") {
  struct C<T>: Box_bdec319 { var t: T }
  func genericErase<T>(_ value: T) -> Any { value }
  let c: any Box_bdec319<Int> = C(t: 42)
  if #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
    let x = genericErase(c)
    expectEqual("C<Int>", "\(type(of:x))")
  }
}

protocol OBox_bdec319<T> : AnyObject {
  associatedtype T
  var t: T { get }
}

CastsTests_bdec319.test("type(of:) should look through extended existentials (class)") {
  class C<T>: OBox_bdec319 {
    var t: T
    init(t: T) { self.t = t }
  }
  func genericErase<T>(_ value: T) -> Any { value }
  let c: any OBox_bdec319<Int> = C(t: 42)
  if #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
    let x = genericErase(c)
    expectEqual("C<Int>", "\(type(of:x))")
  }
}


CastsTests_bdec319.test("type(of:) should look through extended existentials (metatype)") {
  struct C<T>: Box_bdec319 { var t: T }
  func genericErase<T>(_ value: T) -> Any { value }
  let t: any Box_bdec319<Int>.Type = CastsTests_bdec319<Int>.self
  if #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
    let x = genericErase(t)
    expectEqual("C<Int>.Type", "\(type(of:x))")
  }
}

runAllTests()
// --- Bug Primitive ---

// P1: Generic constraint solver & associated-type stress
protocol _FflEquatable {
    associatedtype Value
    func value() -> Value
}
struct _FflBox<T>: _FflEquatable {
    private let _v: T
    init(_ v: T) { self._v = v }
    func value() -> T { return _v }
}
struct _FflNested<Outer: _FflEquatable, Inner: _FflEquatable>
    where Outer.Value == Inner.Value {
    let outer: Outer
    let inner: Inner
    func merged() -> Outer.Value { outer.value() }
}
func _ffl_p1_infer<T>(_ a: T, _ b: T) -> [T] { [a, b] }
do {
    let _ffl_box1 = _FflBox(CastsTests)
    let _ffl_box2 = _FflBox(CastsTests)
    let _ffl_nest = _FflNested(outer: _ffl_box1, inner: _ffl_box2)
    let _ffl_arr  = _ffl_p1_infer(_ffl_nest.merged(), _ffl_nest.outer.value())
    _ = _ffl_arr
}
