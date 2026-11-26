#include <stdio.h>
#include <string.h>
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: AnnotatePreviousCachedTokens
// EXPECT-CRASH-ASSERT: getAnnotationEndLoc

int bar;

namespace A {
template <typename T> class X {
  friend foo(::bar::baz());
};
} // namespace A




int main(void) {
    const char *fnw = "š.txt";
    FILE *f = fopen(fnw, "w");
    if (f) {
        fputs("writing to an mb filename", f);
        fclose(f);
    }
    f = fopen(fnw, "r");
    if (f) {
        char buf[256];
        size_t n = fread(buf, 1, sizeof(buf) - 1, f);
        buf[n] = '\0';
        fclose(f);
        buf[n] = '\0';
        fclose(f);
    }
    remove(fnw);
    return 0;
}
