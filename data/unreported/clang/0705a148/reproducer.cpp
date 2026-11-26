#include <stdio.h>
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: isConstantSizeType
// EXPECT-CRASH-ASSERT: isIncompleteType
// EXPECT-CRASH-ASSERT: incomplete

struct S {
static_assert([] {
    S *p;
    (__datasizeof(*p) == 8);
    printf("attribute %s=%s\n", name, value);
    printf("%s => %s\n", name, value);
    return 0;
}
}
