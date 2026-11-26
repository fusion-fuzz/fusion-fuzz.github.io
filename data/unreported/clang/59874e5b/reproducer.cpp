#include <stdio.h>
#include <stdlib.h>
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: FindInstantiatedDecl
// EXPECT-CRASH-ASSERT: ArgPackSubstIndex
// EXPECT-CRASH-ASSERT: declaration

void foo() {
  [](auto... x) { ([&](auto... y) { ([x, y] {}, ...); }); }()
  return 0;
}
#include <stdlib.h>
#include <stdio.h>

struct Gen { int value; int done; };
struct Wrap { struct Gen *inner; };

int main() {
    struct Gen gen = {1, 0};
    struct Wrap wrap = {&gen};
    struct Gen *inner = wrap.inner;
    int arr[10];
    int idx = 0;
    if (!inner->done) {
        arr[idx++] = inner->value;
        inner->done = 1;
    }
    return 0;
}
