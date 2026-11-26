
// RUN: %clang_cc1 -emit-llvm %s -o - -triple=x86_64-linux-gnu -std=c++2a | FileCheck %s

namespace spaceship {
  struct X {};
  struct Y {};
  int operator<=>(X, Y);
  template<typename Outer> template<typename Inner> int z<Outer>::y<Outer>; // expected-error {{cannot be deduced}} expected-note {{'Inner'}}
  template<typename Outer> template<typename Inner> int z<Outer>::y<Inner>; // expected-error {{does not specialize}}
  template<> template<typename Inner> int z<int>::y<Inner>; // expected-error {{does not specialize}} expected-note {{instantiation of}}

  z<int> xi;
  z<int*> xf; // expected-note {{instantiation of}}

  // CHECK-LABEL: define {{.*}} @_ZN9spaceship1fIiEEvDTcmltcvNS_1YE_EcvNS_1XE_EcvT__EE
  template<typename T> void f(decltype(Y() < X(), T()) x) {}
  template void f<int>(int);
}
// RUN: %clang_cc1 -std=c++1y -fsyntax-only -verify %s

// -- The argument list of the specialization shall not be identical
//    to the implicit argument list of the primary template.

template<typename T, int N, template<typename> class z> int v1;
template<typename T, int N, template<typename> class z> int v1<T, N, z>;
// expected-error@-1{{variable template partial specialization does not specialize any template argument; to define the primary template, remove the template argument list}}

template<typename...T> int v2;
template<typename...T> int v2<T...>;
// expected-error@-1{{variable template partial specialization does not specialize any template argument; to define the primary template, remove the template argument list}}

template<int...N> int v3;
template<int...N> int v3<N...>;
// expected-error@-1{{variable template partial specialization does not specialize any template argument; to define the primary template, remove the template argument list}}

template<template<typename> class...X> int v4;
template<template<typename> class...X> int v4<z...>;
// expected-error@-1{{variable template partial specialization does not specialize any template argument; to define the primary template, remove the template argument list}}

template<typename Outer> struct z {
  template<typename Inner> static int y;
  // FIXME: It would be preferable to only diagnose this once.
  template<typename Inner> static int y<Outer>; // expected-error 3{{cannot be deduced}} expected-note 3{{'Inner'}}
  template<typename Inner> static int y<Inner>; // expected-error {{does not specialize}}

  template<typename, int> static int z;
  template<Outer N> static int z<int, N>; // expected-error {{not implicitly convertible}}
};
template<typename Outer> template<typename Inner> int z<Outer>::y<Outer>; // expected-error {{cannot be deduced}} expected-note {{'Inner'}}
template<typename Outer> template<typename Inner> int z<Outer>::y<Inner>; // expected-error {{does not specialize}}
template<> template<typename Inner> int z<int>::y<Inner>; // expected-error {{does not specialize}} expected-note {{instantiation of}}

z<int> xi;
z<int*> xf; // expected-note {{instantiation of}}
