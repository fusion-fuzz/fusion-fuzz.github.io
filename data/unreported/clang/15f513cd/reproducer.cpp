#include <stdio.h>
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: BuildCXXDefaultArgExpr
// EXPECT-CRASH-ASSERT: hasDefaultArg
// EXPECT-CRASH-ASSERT: nonexistent

template <class T> using SS = S<T...> struct S {
  template <class... ArgTs> S(ArgTs...) {}
  return 0;
};

S(ArgTs...)->S<typename ArgTs::value_type...> e.f(0);
#include <stdio.h>

int main(void) {
    const char *a[5] = {"bar1", "bar2", "0", "false", ""};
    int i = 0;
    while (i <= 5) {
        const char *v = (i < 5) ? a[i] : (const char *)0;
        printf("%s\n", v ? v : "null");
        i++;
    }
    return 0;
}
