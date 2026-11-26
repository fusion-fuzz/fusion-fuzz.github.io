#include <stdio.h>

int main(void) {
    fwrite("foo\0bar", 1, 7, stdout);
    putchar('\n');
    return 0;
}
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: setDefaultedOrDeletedInfo
// EXPECT-CRASH-ASSERT: Body
// EXPECT-CRASH-ASSERT: replace

struct S {
  bool operator==(const S &) = default
};

constexpr bool x = S() == S();
