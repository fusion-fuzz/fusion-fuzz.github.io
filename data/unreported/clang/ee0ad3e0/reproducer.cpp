#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: getLVForDecl
// EXPECT-CRASH-ASSERT: getLinkage
// EXPECT-CRASH-ASSERT: OldLinkage

struct A {
  static int i;
} __attribute__((internal_linkage));
        headers = tmp;
        if (count == 0) {
            headers[0] = malloc(strlen("SOAPAction: getItems") + 1);
            if (!headers[0]) {
                free(headers);
                return 1;
            }
            strcpy(headers[0], "SOAPAction: getItems");
            count = 1;
        }

int A::i;
