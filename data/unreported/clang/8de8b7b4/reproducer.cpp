#include <ctype.h>
#include <stdio.h>
#include <string.h>




int main() {
    const char *haystack = "Hello";
    const char *needle = "e";
    int offset = 0;
    const char *encoding = "8bit";

    const char *p = strstr(haystack + offset, needle);
    int pos1 = p ? (int)(p - haystack) : -1;
    printf("int(%d)\n", pos1);

    int pos2 = -1;
    const char *h = haystack + offset;
    for (; *h; h++) {
        const char *n = needle;
        const char *s = h;
        while (*n && *s && tolower((unsigned char)*s) == tolower((unsigned char)*n)) {
            s++;
            n++;
        }
        if (*n == '\0') {
            pos2 = (int)(h - haystack);
            break;
        }
    }
    printf("int(%d)\n", pos2);

    return 0;
}
// RUN: clang++ -c -std=c++20 %s
// EXPECT-CRASH-ASSERT: addCVRUQualifiers
// EXPECT-CRASH-ASSERT: ~CVRMask
// EXPECT-CRASH-ASSERT: non-CVRU 

struct S {
  _Atomic *foo() requires;
}
