// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: CheckTemplateArgument
// EXPECT-CRASH-ASSERT: isPointerOrReferenceType
// EXPECT-CRASH-ASSERT: isNullPtrType

struct S {};

void foo() { int res = s->i; }

static int bar = foo();
template <int N> struct SS {};
void baz(SS<bar>) {}

#include <stdio.h>
#include <stdlib.h>

typedef struct {
    void **items;
    size_t count;
    size_t cap;
} ObjStore;

int main(void) {
    ObjStore s = {NULL, 0, 0};
    if (s.count == 0) {
        printf("ObjStore(empty)\n");
    } else {
        printf("ObjStore(%zu)\n", s.count);
    }
    return 0;
}
