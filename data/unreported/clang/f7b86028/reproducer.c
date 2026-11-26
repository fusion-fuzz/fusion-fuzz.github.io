#include <stdio.h>
#include <stdlib.h>

typedef struct {
    int key;
    const char *value;
} Pair;

typedef struct {
    Pair *data;
    size_t len;
} Array;

int main(void) {
    Array b;
    b.len = 2;
    b.data = malloc(b.len * sizeof(*b.data));
    if (!b.data) return 1;

    b.data[0].key = 1;
    b.data[0].value = "one";
    b.data[1].key = 2;
    b.data[1].value = "two";

    Array *a = &b;
    size_t i = 0;
    if (i < a->len) {
        printf("%s\n", a->data[i].value);
        i++;
    }
    if (i < a->len) {
        i++;
    }
    if (i < a->len) {
        printf("%s\n", a->data[i].value);
    }

    free(b.data);
    return 0;
}
// RUN: %clang_cc1 -S -Wno-int-conversions %s -o -

typedef int Int;

int f0(int *a, Int *b) { return a - b; }

int f1(const char *a, char *b) { return b - a; }

// GNU extensions
typedef void (*FP)(void);
void *f2(void *a, int b) { return a + b; }
void *f2_0(void *a, int b) { return &a[b]; }
void *f2_1(void *a, int b) { return (a += b); }
void *f3(int a, void *b) { return a + b; }
void *f3_1(int a, void *b) { return (a += b); }
void *f4(void *a, int b) { return a - b; }
void *f4_1(void *a, int b) { return (a -= b); }
FP f5(FP a, int b) { return a + b; }
FP f5_1(FP a, int b) { return (a += b); }
FP f6(int a, FP b) { return a + b; }
FP f6_1(int a, FP b) { return (a += b); }
FP f7(FP a, int b) { return a - b; }
FP f7_1(FP a, int b) { return (a -= b); }
void f8(void *a, int b) { return *(a + b); }
void f8_1(void *a, int b) { return a[b]; }
