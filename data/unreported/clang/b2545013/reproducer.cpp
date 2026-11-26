#include <stdio.h>
#include <stdlib.h>
#include <string.h>




int main(void) {
    char *s = malloc(2);
    if (!s) return 1;
    s[0] = '1';
    s[1] = '\0';

    size_t len = strlen(s);
    char *t = malloc(len + 4);
    if (!t) {
        free(s);
        return 1;
    }

    memcpy(t, s, len + 1);
    memcpy(t + len, "2a=1", 5);

    puts(t);

    free(t);
    free(s);
    enum __attribute((mode(SI))) foo bar;
    return 0;
}
// RUN: clang++ -c -std=c++20 %s
// EXPECT-CRASH-ASSERT: hasAcceptableDefinition
// EXPECT-CRASH-ASSERT: missing

enum __attribute_ffl((mode(SI))) foo bar;
