// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: VisitTypeOfExprTypeLoc
// EXPECT-CRASH-ASSERT: getTypeSpecType
// EXPECT-CRASH-ASSERT: TST_typeofExpr
// EXPECT-CRASH-ASSERT: TST_typeof_unqualExpr

const typedef typeof(nullptr) nullptr_t;

_Atomic nullptr_t a = 0;

#include <stdio.h>
#include <string.h>

static unsigned int md5_like(const char *s) {
    unsigned int h = 2166136261u;
    while (*s) {
        h ^= (unsigned char)*s++;
        h *= 16777619u;
    }
    return h;
}

int main(void) {
    const char *x = "foo";
    volatile unsigned int sink = 0;

    puts("explicit conversion");
    for (int i = 0; i < 100000; i++) {
        char buf[16];
        snprintf(buf, sizeof(buf), "%s", x);
        sink ^= md5_like(buf);
    }

    puts("no conversion");
    for (int i = 0; i < 100000; i++) {
        sink ^= md5_like(x);
    }

    return (int)sink;
}
