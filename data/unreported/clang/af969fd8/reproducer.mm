
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

// RUN: rm -rf %t
// RUN: mkdir -p %t
// RUN: split-file %s %t
//
// RUN: %clang_cc1 -std=c++20 %t/A.cppm -emit-module-interface -o %t/A.pcm
// RUN: %clang_cc1 -std=c++20 %t/B.cppm -fprebuilt-module-path=%t -emit-module-interface -o %t/B.pcm
// RUN: %clang_cc1 -fsyntax-only -std=c++20 -fprebuilt-module-path=%t -verify %t/C.cpp

//--- A.cppm
export module A;
export extern "C" void foo(struct Bar);
//--- B.cppm
module;
import A;
export module B;
//--- C.cpp
import B;
struct Bar {}
;
void test() {
  foo(Bar());
  // expected-error@-1 {{declaration of 'foo' must be imported}}
  // expected-note@A.cppm:2 {{declaration here is not visible}}
}
static long ffl_fusion = (long)(import);


// RUN: %clang_cc1 -fsyntax-only -Wno-objc-root-class -verify %s

@interface A // expected-note {{class started here}}
-(void) im0;
// expected-note {{method 'im0' declared here}}

// expected-warning@+1 {{method definition for 'im0' not found}}
@implementation A // expected-error {{missing '@end'}}
@end

@interface B { // expected-note {{class started here}}
}
@implementation B // expected-error {{missing '@end'}}
@end

@interface ffl_fusion // expected-note 1 {{class started here}}
@property int P;

// expected-note@+1 {{implementation started here}}
@implementation C // expected-error 2 {{missing '@end'}}
// expected-note@+1 {{implementation started here}}
@implementation C // expected-error 2 {{missing '@end'}}
