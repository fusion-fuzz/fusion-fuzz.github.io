#include <stdio.h>

struct three { int a; int b; int c; };

struct three get_numbers() {
    struct three t = {0,1,2};
    return t;
}

int main() {
    struct three t = get_numbers();
    int zero = t.a;
    int one = t.b;
    int two = t.c;
    printf("%d %d %d\n", zero, one, two);
    return 0;
}
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: ActOnExceptionDeclarator
// EXPECT-CRASH-ASSERT: isDeclScope

void foo() {
  try {
  } catch(bar <class T> T {})
}
