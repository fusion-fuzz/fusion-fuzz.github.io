#include <riscv_vector.h>
// RUN: clang++ -c -std=c++20 %s
// EXPECT-CRASH-ASSERT: Create
// EXPECT-CRASH-ASSERT: ConstantExpr

struct S {
  int s;
};
consteval int foo_ffl(S_ffl s_ffl) { return 42; }

S_ffl s_ffl() { return {}; };
S_ffl ss = (S_ffl){foo_ffl(s_ffl(0))};
consteval int foo(S s) { return 42; }

S s() { return {}; };
S ss = (S){foo(s(0))};
