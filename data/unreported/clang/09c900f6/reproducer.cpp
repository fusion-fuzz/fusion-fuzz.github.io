// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: ActOnPopScope
// EXPECT-CRASH-ASSERT: getFlags
// EXPECT-CRASH-ASSERT: TemplateParamScope
// EXPECT-CRASH-ASSERT: shouldn't

struct {
  void foo() noexcept(&&bar);
}

#include <stdio.h>

int main() {
    char *var1 = "nonexistentfile";
    long var2 = 2200000000L;
    (void)fopen(var1, "rb");
    int x = (int)var2;
    (void)x;
    var2 = 1;
    return 0;
}
