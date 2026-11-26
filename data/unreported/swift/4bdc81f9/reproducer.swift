import CxxModule

// --- Seed A ---
// RUN: %empty-directory(%t)
// RUN: split-file %s %t

// RUN: %target-swift-emit-ir %t/test.swift -I %t/Inputs -enable-experimental-cxx-interop -Xcc -fignore-exceptions | %FileCheck %s
// RUN: %target-swift-emit-ir %t/test.swift -I %t/Inputs -enable-experimental-cxx-interop -Xcc -fno-exceptions -Xcc -fno-objc-exceptions  -Xcc -DNOEXCEPTION | %FileCheck %s

//--- Inputs/module.modulemap
module CxxModule {
    header "cxxHeader.h"
    requires cplusplus
}

//--- Inputs/cxxHeader.h

inline int freeFunctionThrows(int x) {
#ifndef NOEXCEPTION
  if (x > 0)
    throw 2;
#endif
  return -x;
}

inline int freeFunctionNoThrow(int x) noexcept {
  return -x;
}

class ClassWithThrowingCopyConstructor {
public:
  int m = 0;
  inline ClassWithThrowingCopyConstructor() noexcept {}
  inline ClassWithThrowingCopyConstructor(const ClassWithThrowingCopyConstructor &) { (void)freeFunctionThrows(0); }
};

class ClassWithThrowingConstructor {
public:
  int m = 0;
  inline ClassWithThrowingConstructor() { }
};

//--- test.swift


func makeCInt() -> CInt {
  return 42
}

func testFreeFunctionNoThrowOnly() -> CInt {
  return freeFunctionNoThrow(makeCInt())
}

func testFreeFunctionCalls() -> CInt {
  let p = freeFunctionThrows(0)
  freeFunctionNoThrow(1)
  freeFunctionThrows(makeCInt())
  return p
}

func testClassWithThrowingCopyConstructor() -> CInt {
  let p1 = ClassWithThrowingCopyConstructor()
  let p2 = p1
  return p2.m
}

func testClassWithThrowingConstructor() -> CInt {
  let obj = ClassWithThrowingConstructor()
  return obj.m
}

let _ = testFreeFunctionNoThrowOnly()
let _ = testFreeFunctionCalls()
let _ = testClassWithThrowingCopyConstructor()
let _ = testClassWithThrowingConstructor()

// CHECK: define {{.*}} @"$s4test0A23FreeFunctionNoThrowOnlys5Int32VyF"() #[[#SWIFTMETA:]] {
// CHECK-NEXT: :
// CHECK-NEXT:  call swiftcc i32 @"$s4test8makeCInts5Int32VyF"()
// CHECK-NEXT:  call i32 @{{_Z19freeFunctionNoThrowi|"\?freeFunctionNoThrow@@YAHH@Z"}}(i32 {{.*}})
// CHECK-NEXT:  ret i32
// CHECK-NEXT: }

// CHECK: define {{.*}} @"$s4test0A17FreeFunctionCallss5Int32VyF"() #[[#SWIFTMETA]] {
// CHECK: call i32 @{{_Z18freeFunctionThrowsi|"\?freeFunctionThrows@@YAHH@Z"}}(i32 0)
// CHECK: call i32 @{{_Z19freeFunctionNoThrowi|"\?freeFunctionNoThrow@@YAHH@Z"}}(i32 1)
// CHECK: call swiftcc i32 @"$s4test8makeCInts5Int32VyF"()
// CHECK: call i32 @{{_Z18freeFunctionThrowsi|"\?freeFunctionThrows@@YAHH@Z"}}(i32
// CHECK: ret i32
// CHECK-NEXT: }

// CHECK: define {{.*}} @"$s4test0A32ClassWithThrowingCopyConstructors5Int32VyF"() #[[#SWIFTMETA]] {
// CHECK-NOT: invoke
// CHECK: }

// RUN: %empty-directory(%t)
// RUN: split-file %s %t
// RUN: %target-swift-frontend -emit-ir -primary-file %t/valid.swift %t/definitions.swift > /dev/null
// RUN: %target-swift-frontend -typecheck -verify -verify-additional-prefix main- -primary-file %t/main.swift %t/definitions.swift
// RUN: %target-swift-frontend -typecheck -verify -verify-additional-prefix other- -parse-as-library -primary-file %t/other.swift %t/definitions.swift

//--- definitions.swift
@attached(peer)
macro SomeAttr() = #externalMacro(module: "", type: "") // expected-note {{declared here}}
// expected-main-note@-1 2{{declared here}}

@propertyWrapper
struct SomeAttr<T> {
  var wrappedValue: T
  init(wrappedValue: T) { self.wrappedValue = wrappedValue }
  init(projectedValue: Self) { self = projectedValue}
  var projectedValue: Self { self }
}

struct Err: Error {}

//--- valid.swift
func foo() throws {
  // Make sure we prefer the property wrapper over the macro here.
  @SomeAttr var x = 0
  let _: Int = x
  let _: SomeAttr<Int> = _x
  let _: SomeAttr<Int> = $x

  _ = {
    @SomeAttr var y = 0
    let _: Int = y
    let _: SomeAttr<Int> = _y
    let _: SomeAttr<Int> = $y
  }

  func bar(@SomeAttr x: Int) {
    let _: Int = x
    let _: SomeAttr<Int> = _x
    let _: SomeAttr<Int> = $x
  }

  bar($x: SomeAttr(wrappedValue: 0))

  func baz(_ fn: (SomeAttr<Int>) -> Void) {}
  baz { x in }
  baz { $x in }

  _ = if .random() {
    @SomeAttr var z = 0
    let _: SomeAttr<Int> = _z
    let _: SomeAttr<Int> = $z
    throw Err()
  } else {
    0
  }
}
// CHECK: define {{.*}} @"$s4test0A28ClassWithThrowingConstructors5Int32VyF"() #[[#SWIFTMETA]] {
// CHECK-NOT: invoke
// CHECK: }

//--- main.swift
struct S1 {
  var x = if .random() {
    @SomeAttr var y = 0
    let _: SomeAttr<Int> = _y
    let _: SomeAttr<Int> = $y
    throw Err() // expected-error {{errors cannot be thrown out of a property initializer}}
  } else {
    0
  }
}

// Here we prefer the macro.
struct S2 {
  @SomeAttr var x = 0 // expected-error {{could not be found for macro}}
}

func bar() {
  @SomeAttr func baz() {} // expected-error {{could not be found for macro}}
}

@SomeAttr var x = 0 // expected-error {{could not be found for macro}}

_ = { @SomeAttr<Int> in }
// expected-error@-1 {{attribute @SomeAttr<Int> is not supported on a closure}}
// expected-warning@-2 {{cannot specialize a non-generic external macro 'SomeAttr()'}}

//--- other.swift

// Also check for a library file
@SomeAttr var x = 0 // expected-error {{could not be found for macro}}
// --- Seed B ---
// RUN: %empty-directory(%t)
// RUN: split-file %s %t
// RUN: %target-swift-frontend -emit-ir -primary-file %t/valid.swift %t/definitions.swift > /dev/null
// RUN: %target-swift-frontend -typecheck -verify -verify-additional-prefix main- -primary-file %t/main.swift %t/definitions.swift
// RUN: %target-swift-frontend -typecheck -verify -verify-additional-prefix other- -parse-as-library -primary-file %t/other.swift %t/definitions.swift

//--- definitions.swift
@attached(peer)
macro SomeAttr_b0de6ac() = #externalMacro(module: "", type: "") // expected-note {{declared here}}
// expected-main-note@-1 2{{declared here}}

@propertyWrapper
struct SomeAttr_b0de6ac<T> {
  var wrappedValue: T
  init(wrappedValue: T) { self.wrappedValue = wrappedValue }
  init(projectedValue: obj) { self = projectedValue}
  var projectedValue: Self { self }
}

struct Err_b0de6ac: Error {}

//--- valid.swift
func foo_b0de6ac() throws {
  // Make sure we prefer the property wrapper over the macro here.
  @SomeAttr_b0de6ac var x_b0de6ac = 0
  let _: Int = x_b0de6ac
  let _: SomeAttr_b0de6ac<Int> = _x
  let _: SomeAttr_b0de6ac<Int> = $x_b0de6ac

  _ = {
    @SomeAttr_b0de6ac var y = 0
    let _: Int = y
    let _: SomeAttr_b0de6ac<Int> = _y
    let _: SomeAttr_b0de6ac<Int> = $y
  }

  func bar_b0de6ac(@SomeAttr_b0de6ac x_b0de6ac: Int) {
    let _: Int = x_b0de6ac
    let _: SomeAttr_b0de6ac<Int> = _x
    let _: SomeAttr_b0de6ac<Int> = $x_b0de6ac
  }

  bar_b0de6ac($x_b0de6ac: SomeAttr_b0de6ac(wrappedValue: 0))

  func baz(_ fn: (SomeAttr_b0de6ac<Int>) -> Void) {}
  baz { x_b0de6ac in }
  baz { $x_b0de6ac in }

  _ = if .random() {
    @SomeAttr_b0de6ac var z = 0
    let _: SomeAttr_b0de6ac<Int> = _z
    let _: SomeAttr_b0de6ac<Int> = $z
    throw Err_b0de6ac()
  } else {
    0
  }
}

//--- main.swift
struct S1_b0de6ac {
  var x_b0de6ac = if .random() {
    @SomeAttr_b0de6ac var y = 0
    let _: SomeAttr_b0de6ac<Int> = _y
    let _: SomeAttr_b0de6ac<Int> = $y
    throw Err_b0de6ac() // expected-error {{errors cannot be thrown out of a property initializer}}
  } else {
    0
  }
}

// Here we prefer the macro.
struct S2_b0de6ac {
  @SomeAttr_b0de6ac var x_b0de6ac = 0 // expected-error {{could not be found for macro}}
}

func bar_b0de6ac() {
  @SomeAttr_b0de6ac func baz() {} // expected-error {{could not be found for macro}}
}

@SomeAttr_b0de6ac var x_b0de6ac = 0 // expected-error {{could not be found for macro}}

_ = { @SomeAttr_b0de6ac<Int> in }
// expected-error@-1 {{attribute @SomeAttr_b0de6ac<Int> is not supported on a closure}}
// expected-warning@-2 {{cannot specialize a non-generic external macro 'SomeAttr_b0de6ac()'}}

//--- other.swift

// Also check for a library file
@SomeAttr_b0de6ac var x_b0de6ac = 0 // expected-error {{could not be found for macro}}
// --- Bug Primitive ---

// P4: Closure capture / @escaping / ownership stress
func _ffl_p4_apply<T>(_ f: () -> T) -> T { f() }
func _ffl_p4_escape<T>(_ f: @escaping () -> T) -> () -> T { f }
do {
    var _ffl_cap = obj
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
    _ffl_cap = obj
    _ = _ffl_esc()
}
