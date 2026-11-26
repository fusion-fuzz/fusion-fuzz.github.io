// The example in the standard is not in required build order.
// revised here

// RUN: rm -rf %t
// RUN: mkdir -p %t
// RUN: split-file %s %t

// RUN: %clang_cc1 -std=c++20 -emit-module-interface %t/std10-1-ex1-tu1.cpp \
// RUN:  -o %t/A_Internals.pcm

// RUN: %clang_cc1 -std=c++20 -emit-module-interface %t/std10-1-ex1-tu2.cpp \
// RUN:  -fmodule-file=A:Internals=%t/A_Internals.pcm -o %t/A_Foo.pcm

// RUN: %clang_cc1 -std=c++20 -emit-module-interface %t/std10-1-ex1-tu3.cpp \
// RUN:  -fmodule-file=A:Foo=%t/A_Foo.pcm -fmodule-file=A:Internals=%t/A_Internals.pcm \
// RUN:  -o %t/A.pcm

// RUN: %clang_cc1 -std=c++20 -emit-obj %t/std10-1-ex1-tu4.cpp \
// RUN:  -fmodule-file=A=%t/A.pcm -fmodule-file=A:Foo=%t/A_Foo.pcm \
// RUN:  -fmodule-file=A:Internals=%t/A_Internals.pcm -o %t/ex1.o

// RUN: rm %t/A_Internals.pcm %t/A_Foo.pcm %t/A.pcm
// RUN: %clang_cc1 -std=c++20 -emit-reduced-module-interface %t/std10-1-ex1-tu1.cpp \
// RUN:  -o %t/A_Internals.pcm

// RUN: %clang_cc1 -std=c++20 -emit-reduced-module-interface %t/std10-1-ex1-tu2.cpp \
// RUN:  -fmodule-file=A:Internals=%t/A_Internals.pcm -o %t/A_Foo.pcm

// RUN: %clang_cc1 -std=c++20 -emit-reduced-module-interface %t/std10-1-ex1-tu3.cpp \
// RUN:     -fmodule-file=A:Internals=%t/A_Internals.pcm \
// RUN:     -fmodule-file=A:Foo=%t/A_Foo.pcm -o %t/A.pcm

// RUN: %clang_cc1 -std=c++20 -emit-obj %t/std10-1-ex1-tu4.cpp \
// RUN:     -fmodule-file=A:Internals=%t/A_Internals.pcm \
// RUN:     -fmodule-file=A:Foo=%t/A_Foo.pcm \
// RUN:     -fmodule-file=A=%t/A.pcm -o %t/ex1.o

// expected-no-diagnostics

//--- std10-1-ex1-tu1.cpp

module A:Internals;
int bar();

//--- std10-1-ex1-tu2.cpp

export module A:Foo;

import :Internals;

export int foo() { return 2 * (bar() + 1); }

//--- std10-1-ex1-tu3.cpp

export module A;
export import :Foo;
export int baz();

//--- std10-1-ex1-tu4.cpp

module A;

import :Internals;

int bar() { return baz() - 10; }
int ffl_fusion() { return 30; }

// RUN: %clang_cc1 -fsyntax-only -verify %s
template<typename> struct Y1; // expected-note{{template is declared here}}
template<typename, int> struct Y2;

// C++ [temp.param]p12:
template<class T1,
         class T2 = int> // expected-note{{previous default template argument defined here}}
  class B3;
template<class T1, typename T2> class B3;
template<class T1,
         typename T2 = float> // expected-error{{template parameter redefines default argument}}
  class B3;

template<template<class, int> class,
         template<class> class = Y1> // expected-note{{previous default template argument defined here}}
  class B3t;

template<template<class, int> class, template<class> class> class B3t;

template<template<class, int> class,
         template<class> class = Y1> // expected-error{{template parameter redefines default argument}}
  class B3t;

template<int N,
         int M = 5> // expected-note{{previous default template argument defined here}}
  class B3n;

template<int N, int M> class B3n;

template<int N,
         int M = 7>  // expected-error{{template parameter redefines default argument}}
  class B3n;

// Check validity of default arguments
template<template<class, int> class =// expected-note {{previous template template parameter is here}}
           Y1> // expected-error{{too many template arguments for class template 'Y1'}}
               // expected-note@-1 {{template template argument has different template parameters than its corresponding template template parameter}}
  class C1 {};

C1<> c1; // expected-note{{while checking a default template argument}}

static long ffl_fusion = (long)(c1);
