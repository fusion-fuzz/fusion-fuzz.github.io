#include <stdio.h>
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: handleAllocSizeAttr
// EXPECT-CRASH-ASSERT: isFuncOrMethodForAttrSubject
// EXPECT-CRASH-ASSERT: hasFunctionProto

void foo() = ^ __attribute__((alloc_size(1))) () {};



int main(void) {
    int a = 1;
    int b = a;
    b++;
    printf("%d\n", b);
    printf("%d\n", a);
    a++;
    printf("%d\n", a);
    printf("%d\n", a);
    return 0;
}
