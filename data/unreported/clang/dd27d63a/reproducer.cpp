// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: CheckJump
// EXPECT-CRASH-ASSERT: Permissive
// EXPECT-CRASH-ASSERT: LabelAndGotoScopes

template <class T> void foo() { goto *&&bar; };

void baz() { foo<int>(); }

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct { const char *key; int v; } Item;

static int cmp_gt(const void *pa, const void *pb) {
    const Item *a = (const Item *)pa, *b = (const Item *)pb;
    if (a->v == b->v) return 0;
    return a->v > b->v ? 1 : -1;
}

static int cmp_lt_print(const void *pa, const void *pb) {
    const Item *a = (const Item *)pa, *b = (const Item *)pb;
    putchar('.');
    if (a->v == b->v) return 0;
    return a->v < b->v ? 1 : -1;
}

int main(void) {
    Item a[] = {{"0.1", 9}, {"0.5", 12}, {"0", 23}, {"1", 4}, {"2", -15}};
    Item b[] = {{"0.2", 9}, {"0.5", 22}, {"0", 3}, {"1", 4}, {"2", -15}};
    size_t na = sizeof(a) / sizeof(a[0]), nb = sizeof(b) / sizeof(b[0]);

    for (size_t i = 0; i < na; i++) {
        int found = 0;
        for (size_t j = 0; j < nb; j++) {
            if (strcmp(a[i].key, b[j].key) == 0) {
                found = 1;
                if (cmp_gt(&a[i], &b[j]) != 0) printf("%d\n", a[i].v);
                break;
            }
        }
        if (!found) printf("%d\n", a[i].v);
    }

    for (size_t i = 0; i < na; i++) {
        int found = 0;
        for (size_t j = 0; j < nb; j++) {
            if (strcmp(a[i].key, b[j].key) == 0) {
                found = 1;
                if (cmp_lt_print(&a[i], &b[j]) != 0) printf("%d\n", a[i].v);
                break;
            }
        }
        if (!found) printf("%d\n", a[i].v);
    }

    return 0;
}
