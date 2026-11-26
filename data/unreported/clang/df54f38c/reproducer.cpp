// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: setLazyInClassInitializer
// EXPECT-CRASH-ASSERT: hasInClassInitializer
// EXPECT-CRASH-ASSERT: getInClassInitializer

template <class T> void foo() {
  struct S1 {
    struct S2 {
      int i = 0;
    };
    enum { E = S2() };
  };
};

void bar() { foo<int>(); }

#include <stdio.h>
#include <string.h>

int main(void) {
    const char *inputs[] = {"&amp;lt;", "&amp;#38;", "&amp;#38;lt;"};
    for (int i = 0; i < 3; i++) {
        const char *s = inputs[i];
        char out[64];
        size_t j = 0;
        for (size_t k = 0; s[k] && j + 1 < sizeof(out); ) {
            if (!strncmp(&s[k], "&amp;", 5)) {
                out[j++] = '&';
                k += 5;
            } else if (!strncmp(&s[k], "&lt;", 4)) {
                out[j++] = '<';
                k += 4;
            } else if (!strncmp(&s[k], "&gt;", 4)) {
                out[j++] = '>';
                k += 4;
            } else if (!strncmp(&s[k], "&quot;", 6)) {
                out[j++] = '"';
                k += 6;
            } else if (!strncmp(&s[k], "&#38;", 5)) {
                out[j++] = '&';
                k += 5;
            } else {
                out[j++] = s[k++];
            }
        }
        out[j] = '\0';
        puts(out);
    }
    return 0;
}
