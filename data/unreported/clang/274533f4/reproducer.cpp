#include <stdint.h>
#include <inttypes.h>
#include <stddef.h>
#include <stdio.h>

typedef int64_t off_t;

void bug79532(off_t *array, size_t elems) {
    int32_t *p = (int32_t *)array;
    for (size_t i = 0; i < elems; ++i) {
        p[i] = (int32_t)(i * 100);
    }
}

int main() {
    off_t array[3] = {0, 0, 0};
    bug79532(array, 3);
    for (int i = 0; i < 3; ++i) {
        printf("%" PRId64 "\n", array[i]);
    }
    return 0;
}
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: PerformImplicitConversion
// EXPECT-CRASH-ASSERT: Context.hasSameType
// EXPECT-CRASH-ASSERT: ToAtomicType
// EXPECT-CRASH-ASSERT: getType

const int foo(bool b) { return 42; }

_Atomic int bar() { return foo(); }
