#include <stdio.h>
#include <string.h>
#include <ctype.h>

int main(void) {
    const char *in = "IT \xE4\xBA\x92";
    unsigned char out[256];
    size_t j = 0;

    for (size_t i = 0; in[i] && j + 1 < sizeof(out); i++) {
        unsigned char c = (unsigned char)in[i];
        if (c == ' ' || isalnum(c))
            out[j++] = c;
        else if (c >= 0x80 && j + 1 < sizeof(out)) {
            out[j++] = '?';
        } else {
            out[j++] = c;
        }
    }
    out[j] = '\0';

    printf("A: %s\n", in);
    printf("B: ", in);
    for (size_t i = 0; in[i]; i++) printf("%02x%s", (unsigned char)in[i], in[i + 1] ? " " : "");
    printf("\nC: %s\n", out);
    printf("D: ");
    for (size_t i = 0; out[i]; i++) printf("%02x%s", (unsigned char)out[i], out[i + 1] ? " " : "");
    printf("\n");
    return 0;
}
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: ActOnGCCAsmStmtString
// EXPECT-CRASH-ASSERT: isOrdinary

void foo() {
  asm("" ::: (u8""}));
}
