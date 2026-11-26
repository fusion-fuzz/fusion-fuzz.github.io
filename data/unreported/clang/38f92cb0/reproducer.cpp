
// RUN: %clang_cc1 -triple x86_64-windows-msvc -fsyntax-only -fms-extensions -verify -std=c++20 %s
// RUN: %clang_cc1 -triple x86_64-windows-msvc -fsyntax-only -fms-extensions -verify -std=c++20 -fno-dllexport-inlines %s
// RUN: %clang_cc1 -triple x86_64-windows-gnu  -fsyntax-only -fms-extensions -verify -std=c++20 %s

// expected-no-diagnostics

// Regression test for https://github.com/llvm/llvm-project/issues/185924
// dllexport should not attempt to instantiate inherited constructors whose
// requires clause is not satisfied.
//
// This exercises two paths in checkClassLevelDLLAttribute:
//   1) findInheritingConstructor must skip constrained-out base ctors
//   2) dllexport propagated to the base template specialization must not
//      export members whose requires clause is not satisfied
//
// The constructor/method bodies are intentionally ill-formed when the
// constraint is not satisfied, so that forced instantiation via dllexport
// would produce an error without the correct fix.

template <bool B>
struct ConstrainedBase {
  struct Enabler {};
  ConstrainedBase(Enabler) requires(B) {}
  ConstrainedBase() requires(B) : ConstrainedBase(Enabler{}) {}
  ConstrainedBase(int);
};

struct __declspec(dllexport) ConstrainedChild : ConstrainedBase<false> {
  using ConstrainedBase::ConstrainedBase;
};

// Non-constructor constrained method on a base template specialization.
// When dllexport propagates to the base, methods whose requires clause
// is not satisfied must be skipped.
template <typename T>
struct BaseWithConstrainedMethod {
  void foo() requires(sizeof(T) > 100) { T::nonexistent(); }
  void bar() {}
};

struct __declspec(dllexport) MethodChild : BaseWithConstrainedMethod<int> {};
// RUN: %clang_cc1 -pedantic-errors -std=c++11 -emit-pch %s -o %t
// RUN: %clang_cc1 -pedantic-errors -std=c++11 -include-pch %t -verify %s

// RUN: %clang_cc1 -pedantic-errors -std=c++11 -emit-pch -fpch-instantiate-templates %s -o %t
// RUN: %clang_cc1 -pedantic-errors -std=c++11 -include-pch %t -verify %s

#ifndef HEADER_INCLUDED

#define HEADER_INCLUDED

struct B {
  B();
  constexpr B(char) {}
}
;
struct C {
  B b;
  double d = 0.0;
}
;
struct D : B {
  constexpr D(int n) : B('x'), k(2*n+1) {}
  int k;
}
;
constexpr int value = 7;
template<typename T>
constexpr T plus_seven(T other) {
  return value + other;

struct __declspec(dllexport) ConstrainedChild : ConstrainedBase<false> {
  using ConstrainedBase::ConstrainedBase;
};
}
#else
static_assert(D(4).k == 9, "");
constexpr int f(C c) { return 0; }
// expected-error {{not a literal type}}
// expected-note@16 {{not an aggregate and has no constexpr constructors}}
constexpr B b;
// expected-error {{constant expression}} expected-note {{non-constexpr}}
               // expected-note@12 {{here}}

static_assert(plus_seven(3) == 10, "");
#endif
