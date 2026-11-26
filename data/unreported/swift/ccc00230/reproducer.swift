import B
// Test that after compiling a module to a path containing a symlink we still
// get the same scanner output.

// REQUIRES: OS=macosx

// RUN: %empty-directory(%t)
// RUN: split-file %s %t
// RUN: %target-swift-emit-silgen -Xllvm -sil-print-types %s | %FileCheck %s

struct S {
  func callAsFunction(_ x: Int) -> Int! { nil }
}

protocol P1 {
  func callAsFunction()
}

protocol P2 {
  func callAsFunction() -> Self
}

class C {
  func callAsFunction(_ x: String) -> Self { return self }
}

// CHECK-LABEL: sil hidden [ossa] @$s16call_as_function05test_a1_b1_C0yyAA1SV_AA2P1_pAA2P2_pxtAA1CCRbzlF : $@convention(thin) <T where T : C> (S, @in_guaranteed any P1, @in_guaranteed any P2, @guaranteed T) -> ()
func test_call_as_function<T : C>(_ s: S, _ p1: P1, _ p2: P2, _ t: T) {
  // CHECK: function_ref @$s16call_as_function1SV0A10AsFunctionySiSgSiF : $@convention(method) (Int, S) -> Optional<Int>
  // CHECK: switch_enum %{{.+}} : $Optional<Int>
  let _: Int = s(0)

  // https://github.com/apple/swift/issues/55035
  // SILGen crash on existential callAsFunction.
  //
  // CHECK: witness_method $@opened({{.+}}, any P1) Self, #P1.callAsFunction : <Self where Self : P1> (Self) -> () -> ()
  p1()

  // CHECK: witness_method $@opened({{.+}}, any P2) Self, #P2.callAsFunction : <Self where Self : P2> (Self) -> () -> Self
  _ = p2()

  // CHECK: class_method %{{.+}} : $C, #C.callAsFunction : (C) -> (String) -> @dynamic_self C, $@convention(method) (@guaranteed String, @guaranteed C) -> @owned C
  // CHECK: unchecked_ref_cast %{{.+}} : $C to $T
  _ = t("")
}
// RUN: mkdir %t/module-outputs
// RUN: ln -s module-outputs %t/symlink

// RUN: %target-swift-frontend -scan-dependencies %t/a.swift -o %t/deps.json -module-name A -emit-dependencies -emit-dependencies-path %t/deps.d -disable-implicit-concurrency-module-import -disable-implicit-string-processing-module-import -I %t -module-cache-path %t/symlink -verify -cache-compile-job -cas-path %t/cas
// Check the contents of the JSON output
// RUN: %validate-json %t/deps.json | %FileCheck %s

// CHECK:      "-fmodule-file=C=[[PCM_PATH:C-.*.pcm]]"
// CHECK:      "-fmodule-file-cache-key"
// CHECK-NEXT: "-Xcc"
// CHECK-NEXT: "[[PCM_PATH]]"
// CHECK-NEXT: "-Xcc"
// CHECK-NEXT: "llvmcas://

// Emit one of the modules, which will be in the symlinked path.
// RUN: %{python} %S/../CAS/Inputs/BuildCommandExtractor.py %t/deps.json clang:C > %t/C.cmd
// RUN: %swift_frontend_plain @%t/C.cmd

// RUN: %target-swift-frontend -scan-dependencies %t/a.swift -o %t/deps2.json -module-name A -emit-dependencies -emit-dependencies-path %t/deps.d -disable-implicit-concurrency-module-import -disable-implicit-string-processing-module-import -I %t -module-cache-path %t/symlink -verify -cache-compile-job -cas-path %t/cas
// RUN: diff -u %t/deps.json %t/deps2.json

//--- module.modulemap
module B { header "B.h" }
module C { header "C.h" }

//--- B.h
#include "C.h"

//--- C.h

//--- a.swift
