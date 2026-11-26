#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: EmitScalarExpr
// EXPECT-CRASH-ASSERT: hasScalarEvaluationKind
// EXPECT-CRASH-ASSERT: Invalid

const void *foo() { return __builtin_preserve_access_index(""); }





int main(void) {
    unsigned char in1[] = {0x80};
    unsigned char out1[8];
    unsigned char in2[] = {0x20, 0xAC};
    unsigned char out2[8];

    size_t n1 = 0, n2 = 0;

    if (in1[0] == 0x80) {
        out1[n1++] = 0x00;
        out1[n1++] = 0x80;
    }

    if (in2[0] == 0x20 && in2[1] == 0xAC) {
        out2[n2++] = 0x80;
    }

    for (size_t i = 0; i < n1; i++) printf("%02x", out1[i]);
    printf("\n");
    for (size_t i = 0; i < n2; i++) printf("%02x", out2[i]);
    printf("\n");

    return 0;
}
