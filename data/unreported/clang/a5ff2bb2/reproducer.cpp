#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// RUN: clang++ -c -fblocks %s
// EXPECT-CRASH-ASSERT: ActOnBlockStmtExpr
// EXPECT-CRASH-ASSERT: exprNeedsCleanups
// EXPECT-CRASH-ASSERT: correctly

struct S {
  ~S();
};


int main(void) {
    x o;
    o.zzz = 3;

    int *z = malloc(sizeof(int));
    if (!z) return 1;
    *z = 1000;

    printf("%p\n", (void *)z);
    printf("%d\n", 0);
    printf("%d\n", 1);
    printf("%d\n", 0);
    printf("%s\n", "z");
    printf("%s\n", "public");
    printf("%d\n", *z);

    printf("---------------------------\n");

    printf("%s\n", "property not found");

    printf("%p\n", (void *)&o.zzz);

    bar b;
    b.a = 200;
    b.foobar = 2;
    printf("%d %d %d\n", b.foobar, 0, 1);

    free(z);
    return 0;
}
void foo(T);

void bar() {
  ^{
    return foo(S());
  };
}
