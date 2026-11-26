#include <stdio.h>
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: evaluateVarDeclInit
// EXPECT-CRASH-ASSERT: isLambdaCallOperator
// EXPECT-CRASH-ASSERT: getDeclContext
// EXPECT-CRASH-ASSERT: missing

constexpr int foo() {
  switch (1) {
    if (int n) {
    case 1:
      return n;
      struct Foo5_ffl { Base_ffl base; };
      struct Bar5_ffl { Foo5_ffl base; };

      int main_ffl(void) {
      Foo1_ffl f1 = {0}; Bar1_ffl b1 = {{0}};
      Foo2_ffl f2 = {0}; Bar2_ffl b2 = {{0}};
      Base_ffl base = {0};
      Foo3_ffl f3 = {{0}}; Bar3_ffl b3 = {{{0}}};
      Foo4_ffl f4 = {0};
      Foo5_ffl f5 = {{0}}; Bar5_ffl b5 = {{{0}}};

      (void)f1; (void)b1; (void)f2; (void)b2; (void)base; (void)f3; (void)b3; (void)f4; (void)f5; (void)b5;
      return 0;
      }
    }
  }
}



typedef struct Foo1 Foo1;
typedef struct Bar1 Bar1;
typedef struct Foo2 Foo2;
typedef struct Bar2 Bar2;
typedef struct Base Base;
typedef struct Foo3 Foo3;
typedef struct Bar3 Bar3;
typedef struct Foo4 Foo4;
typedef struct Foo5 Foo5;
typedef struct Bar5 Bar5;

struct Foo1 { int dummy; };
struct Bar1 { Foo1 base; };
struct Foo2 { int dummy; };
struct Bar2 { Foo2 base; };
struct Base { int dummy; };
struct Foo3 { Base base; };
struct Bar3 { Foo3 base; };
struct Foo4 { int dummy; };
struct Foo5 { Base base; };
struct Bar5 { Foo5 base; };

int main(void) {
    Foo1 f1 = {0}; Bar1 b1 = {{0}};
    Foo2 f2 = {0}; Bar2 b2 = {{0}};
    Base base = {0};
    Foo3 f3 = {{0}}; Bar3 b3 = {{{0}}};
    Foo4 f4 = {0};
    Foo5 f5 = {{0}}; Bar5 b5 = {{{0}}};

    (void)f1; (void)b1; (void)f2; (void)b2; (void)base; (void)f3; (void)b3; (void)f4; (void)f5; (void)b5;
    return 0;
}
