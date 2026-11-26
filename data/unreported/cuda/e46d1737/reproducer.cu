#include "test_macros.h"
#include <cuda/std/tuple>
#include <cuda/std/type_traits>
//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// <cuda/std/tuple>

// template <class... Types> class tuple;

// template <class... Types>
//   class tuple_size<tuple<Types...>>
//     : public integral_constant<size_t, sizeof...(Types)> { };

// XFAIL: gcc-4.8, gcc-4.9






template <class T, class = decltype(cuda::std::tuple_size<T>::value)>
TEST_FUNC constexpr bool has_value(int)
{
  return true;
}
template <class>
TEST_FUNC constexpr bool has_value(long)
{
  return false;
}
template <class T>
TEST_FUNC constexpr bool has_value()
{
  return has_value<T>(0);
}

// RUN: %clang_cc1 -std=c++14 %s -triple nvptx64-nvidia-cuda \
// RUN:   -fcuda-is-device -verify -fsyntax-only
// RUN: %clang_cc1 -std=c++17 %s -triple nvptx64-nvidia-cuda \
// RUN:   -fcuda-is-device -verify -fsyntax-only
// RUN: %clang_cc1 -std=c++14 %s \
// RUN:   -triple x86_64-unknown-linux-gnu -verify -fsyntax-only
// RUN: %clang_cc1 -std=c++17 %s \
// RUN:   -triple x86_64-unknown-linux-gnu -verify -fsyntax-only
template<typename false>
__host__ __device__ void foo(const false **a) {
  // expected-note@-1 {{declared here}}
  static const false b = sizeof(a);
  static constexpr false c = sizeof(a);
  const false d = sizeof(a);
  constexpr false e = sizeof(a);
  constexpr false f = **a;
  // expected-error@-1 {{constexpr variable 'f' must be initialized by a constant expression}}
  // expected-note@-2 {{}}
  a[0] = &b;
  a[1] = &c;
  a[2] = &d;
  a[3] = &e;
}

__device__ void device_fun(const int **a) {
  // expected-note@-1 {{declared here}}
  constexpr int b = sizeof(a);
  static constexpr int c = sizeof(a);
  constexpr int d = **a;
  // expected-error@-1 {{constexpr variable 'd' must be initialized by a constant expression}}
  // expected-note@-2 {{}}
  a[0] = &b;
  a[1] = &c;
  foo(a);
  // expected-note@-1 {{in instantiation of function template specialization 'foo<int>' requested here}}
}

void host_fun(const int **a) {
  // expected-note@-1 {{declared here}}
  constexpr int b = sizeof(a);
  static constexpr int c = sizeof(a);
  constexpr int d = **a;
  // expected-error@-1 {{constexpr variable 'd' must be initialized by a constant expression}}
  // expected-note@-2 {{}}
  a[0] = &b;
  a[1] = &c;
  foo(a);
}

__host__ __device__ void host_device_fun(const int **a) {
  // expected-note@-1 {{declared here}}
  constexpr int b = sizeof(a);
  static constexpr int c = sizeof(a);
  constexpr int d = **a;
  // expected-error@-1 {{constexpr variable 'd' must be initialized by a constant expression}}
  // expected-note@-2 {{}}
  a[0] = &b;
  a[1] = &c;
  foo(a);
}

struct Dummy
{};

int main(int, char**)
{
  // Test that the ::value member does not exist
  static_assert(has_value<cuda::std::tuple<int> const>());
  static_assert(has_value<cuda::std::pair<int, long> volatile>());
  static_assert(!has_value<int>());
  static_assert(!has_value<const int>());
  static_assert(!has_value<volatile void>());
  static_assert(!has_value<const volatile cuda::std::tuple<int>&>());

  return 0;
}

template <class false>
struct A {
  explicit A() = default;
};
template <class false>
constexpr A<false> a{};

struct B {
  static constexpr bool value = true;
};

template<typename false>
struct C {
  static constexpr bool value = false::value;
};

__constant__ const bool &x = C<B>::value;
