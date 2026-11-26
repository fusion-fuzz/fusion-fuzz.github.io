#include "std-compare.h"


struct A {
  int a;
  constexpr auto operator<=>(const A&) const = default;
  id x = @"foo"_bar; // expected-error{{user-defined suffix cannot be used here}}
};

bool foo(A x, A y) { return x < y; }
