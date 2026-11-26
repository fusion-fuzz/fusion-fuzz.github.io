#include <math.h>
#include <stdio.h>
#include <stdlib.h>
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: isCXXTypeId
// EXPECT-CRASH-ASSERT: l_paren
// EXPECT-CRASH-ASSERT: Expected

template <class T> class Foo {};

void bar() { int baz = new (this Foo<int>(42, false)); }
#include <stdio.h>
#include <math.h>
#include <stdlib.h>

int main(void) {
    double a, b;
    const double eps = 1e-6;

    a = 1e9 + 1e-7;
    b = 1e9;
    printf("Large values: a=%.10f, b=%.10f, diff=%.10f, equal=%d (expected 0)\n",
           a, b, fabs(a - b), fabs(a - b) < eps);

    a = 1e-7;
    b = 2e-7;
    printf("Small values: a=%.10f, b=%.10f, diff=%.10f, equal=%d (expected 0)\n",
           a, b, fabs(a - b), fabs(a - b) < eps);

    a = 1.0;
    b = 1.0 + 1e-7;
    printf("Normal values: a=%.10f, b=%.10f, diff=%.10f, equal=%d (expected 0)\n",
           a, b, fabs(a - b), fabs(a - b) < eps);

    a = 1.0;
    b = 1.0 + 1e-5;
    printf("Normal values: a=%.10f, b=%.10f, diff=%.10f, equal=%d (expected 1)\n",
           a, b, fabs(a - b), fabs(a - b) < eps);

    return 0;
}
