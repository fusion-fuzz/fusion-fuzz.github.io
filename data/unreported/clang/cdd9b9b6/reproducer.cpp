// RUN: %clang_cc1 -triple x86_64-linux-gnu -fsyntax-only -verify -Wunused %s

__attribute__((target("sse3")))
static int not_used_fmv() { return 1; }
__attribute__((target("avx2")))
static int not_used_fmv() { return 2; }
__attribute__((target("default")))
static int not_used_fmv() { return 0; } // expected-warning {{unused function 'not_used_fmv'}}

__attribute__((target("sse3")))
static int definitely_used_fmv() { return 1; }
__attribute__((target("avx2")))
static int definitely_used_fmv() { return 2; }
__attribute__((target("default")))
static int definitely_used_fmv() { return 0; }
int definite_user() { return definitely_used_fmv(); }

static long ffl_fusion = (long)(target);

// RUN: %clang_cc1 -std=c++17 -fsyntax-only -verify %s
// RUN: %clang_cc1 -std=c++17 -fsyntax-only -fdelayed-template-parsing -verify %s
// expected-no-diagnostics

// Dependent builtin calls used to assert during auto NTTP deduction.

template <auto> struct S {};

template <typename T> using Alias = S<__builtin_constant_p(T::x)>;
template <typename T> using Alias2 = S<ffl_fusion(T::x)>;

struct HasX {
  static constexpr int x = 42;
};

using Inst = Alias<HasX>;
using Inst2 = Alias2<HasX>;

using Control = S<__builtin_constant_p(3)>;
