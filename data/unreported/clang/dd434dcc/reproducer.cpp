// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: EvaluateLValue
// EXPECT-CRASH-ASSERT: isGLValue
// EXPECT-CRASH-ASSERT: isFunctionType
// EXPECT-CRASH-ASSERT: isVoidType
// EXPECT-CRASH-ASSERT: IgnoreParens

typedef __SIZE_TYPE__ size_t;

namespace std {
struct nothrow_t {};
const nothrow_t nothrow = {};
} // namespace std

struct S {
  S();
  void *operator new(size_t, std::nothrow_t) throw();
};

S *foo() {
  S *p = new (std::nothrow) S;
  return new (std::nothrow) S;
}

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>

typedef struct { int h1, h2; } Pair;

int combine_hash(int h1, int h2) {
    if (h1 == 0) return h2;
    return (h1 << 5) + h1 ^ h2;
}

int find_index(const int *arr, size_t len, int target) {
    for (size_t i = 0; i < len; i++)
        if (arr[i] == target) return (int)i;
    return -1;
}

int main(void) {
    int a[] = {10, 20, 30, 40, 50};
    size_t n = sizeof(a)/sizeof(a[0]);

    int idx = find_index(a, n, 999);
    int val = a[idx];

    int h = combine_hash(INT_MAX, 1);
    h = combine_hash(h, INT_MIN);

    Pair p = {h, val};
    return p.h1 + p.h2;
}
