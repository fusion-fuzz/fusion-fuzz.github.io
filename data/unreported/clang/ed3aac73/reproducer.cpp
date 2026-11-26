#include <stdio.h>

typedef int (*maker_t)(void);
static int global_key = 0;
static int build(int key) { return key; }
#define DECLARE_CACHE(name) \
static int name##_thunk = 0; \
static int name##_get(void) { \
    if (name##_thunk) return name##_thunk; \
    name##_thunk = build(global_key); \
    return name##_thunk; \
}
DECLARE_CACHE(foo)
DECLARE_CACHE(bar)
int main(void) {
    int a = foo_get();
    int b = bar_get();
    printf("%d %d\n", a, b);
    return 0;
}
void bar(baz a) _diagnose_if(a == 1, "warning", "error");

void foo(void) { bar(1); }
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: EvaluateAsBooleanCondition
// EXPECT-CRASH-ASSERT: isValueDependent
// EXPECT-CRASH-ASSERT: evaluator

#define _diagnose_if(...) __attribute__((diagnose_if(__VA_ARGS__)))

void bar(baz a) _diagnose_if(a == 1, "warning", "error");

void foo_ffl(void) { bar(1); }
