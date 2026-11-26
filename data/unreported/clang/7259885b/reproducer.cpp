#include <stdlib.h>
// RUN: clang++ -c -std=c++20 %s
// EXPECT-CRASH-ASSERT: getPackAsArray
// EXPECT-CRASH-ASSERT: getKind

template <typename T, T...> struct S {};
template <long... N> using foo = S<unsigned long, N...>;

    (void)a; (void)b;
    free(a);
    return 0;
char bar[2] = foo();
