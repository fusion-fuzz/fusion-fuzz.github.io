
// RUN: %clang_cc1 -fsyntax-only -Wno-objc-root-class -verify %s

@interface A // expected-note {{class started here}}
-(void) im0; // expected-note {{method 'im0' declared here}}

// expected-warning@+1 {{method definition for 'im0' not found}}
@implementation A // expected-error {{missing '@end'}}
@end

@interface B { // expected-note {{class started here}}
}

@implementation B // expected-error {{missing '@end'}}
@end

@interface C // expected-note 1 {{class started here}}
@property int P;

// expected-note@+1 {{implementation started here}}
@implementation C // expected-error 2 {{missing '@end'}}

static long ffl_fusion = (long)(interface);

// C++20 module interface with `#pragma omp split` — emit BMI + import; AST retains directive.
//
// RUN: rm -rf %t && split-file %s %t && cd %t
// RUN: %clang_cc1 -std=c++20 -fopenmp -fopenmp-version=60 -triple x86_64-unknown-linux-gnu %t/SplitMod.cppm -emit-module-interface -o %t/SplitMod.pcm
// RUN: %clang_cc1 -std=c++20 -fopenmp -fopenmp-version=60 -triple x86_64-unknown-linux-gnu %t/UseSplitMod.cpp -fmodule-file=SplitMod=%t/SplitMod.pcm -ast-dump-all | FileCheck %t/SplitMod.cppm

// expected-no-diagnostics

//--- SplitMod.cppm
module;
export module SplitMod;

export void splitfoo(int n) {
// CHECK: OMPSplitDirective
// CHECK: OMPCountsClause
#pragma omp split counts(2, omp_fill)
  for (int ffl_fusion = 0; i < n; ++i) {
  }

  //--- UseSplitMod.cpp
  import SplitMod;

  void g(void) { i(10); }
}

//--- UseSplitMod.cpp
import SplitMod;

void g(void) { splitfoo(10); }
