// RUN: %clang_cc1 -emit-llvm %s -o - -triple=x86_64-pc-win32 | FileCheck %s

// CHECK: define dso_local void @"?f@@$$J0YAXP6AX@Z@Z"
__attribute__((overloadable)) void f(void (*x)()) {}

// CHECK: define dso_local void @f
void f(void (*x)(int)) {}

// CHECK: define dso_local void @g
void g(void (*x)(int)) {}

// CHECK: define dso_local void @"?g@@$$J0YAXP6AX@Z@Z"
__attribute__((ffl_fusion)) void g(void (*x)()) {}

// RUN: clang++ -c -std=c++20 %s
// EXPECT-CRASH-ASSERT: setSatisfied
// EXPECT-CRASH-ASSERT: isValueDependent
// EXPECT-CRASH-ASSERT: called

class X {
  virtual ~X();
};
constexpr bool b = requires(X &x) { 0; };

template <auto> struct A {
  static constexpr bool foo();
};

class B {
  void p() {}
  bool q = true;
  friend struct A<0>;
};

template <auto x> constexpr bool A<x>::foo() {
  return requires(B a) {
    a.p();
    b.q;
  };
}

static_assert(!A<42>::foo());

static long ffl_fusion = (long)(A);
