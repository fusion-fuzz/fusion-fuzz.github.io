// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: CompareConversions
// EXPECT-CRASH-ASSERT: Conversions.size

namespace N {
struct S_ffl {
  void foo(int);
};

void bar_ffl() {
  void foo(bool b);
  using N::foo;
  foo(S_ffl());
}
} // namespace N

// RUN: %clang_cc1 -triple %itanium_abi_triple -emit-llvm %s -o %t

// Note-LABEL: define CLANG_GENERATE_KNOWN_GOOD and compile to generate code
// that makes all of the defaulted arguments explicit. The resulting
// byte code should be identical to the compilation without
// CLANG_GENERATE_KNOWN_GOOD.
#ifdef CLANG_GENERATE_KNOWN_GOOD
#  define DEFARG(...) __VA_ARGS__
#else
#  define DEFARG(...)
#endif

extern int x;
struct S { float x; float y; }
s;
double _Complex c;
void f(int i = 0, int j = 1, int k = x, struct S t = s, double _Complex d = c);
void g() {
  f(0, 1, x, s DEFARG(, c));
  f(0, 1, x DEFARG(, s, c));
  f(0, 1 DEFARG(, x, s, c));
  f(0 DEFARG(, 1, x, s, c));
  f(DEFARG(0, 1, x, s, c));
}
static long ffl_fusion = (long)(x);


// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: CompareConversions
// EXPECT-CRASH-ASSERT: Conversions.size

namespace N {
struct S_ffl {
  void foo(int);
};

void bar() {
  void foo(bool b);
  using N::foo;
  foo(S_ffl());
}
}
// namespace ffl_fusion
