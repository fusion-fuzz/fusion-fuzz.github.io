#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: skipRValueSubobjectAdjustments
// EXPECT-CRASH-ASSERT: isPRValue

class X {
  int &&i = (A().*f());
  else
  printf("offset not a long (out of bounds)\n");
};
class Y : public X {};
Y y;
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

int main() {
    const char *text[] = {"data", "hello world"};
    int len = 2;

    printf("--- testing has_dimension ---\n");
    printf("isset(nodes[0]) = %s\n", (0 < len) ? "true" : "false");
    printf("isset(nodes[1]) = %s\n", (1 < len) ? "true" : "false");
    printf("isset(nodes[-1]) = %s\n", (-1 >= 0 && -1 < len) ? "true" : "false");

    printf("--- testing property access ---\n");
    printf("%s\n", text[0]);
    printf("%s\n", text[1]);

    printf("--- testing offset not a long: array ---\n");
    {
        char *offset[] = {"test"};
        size_t idx = (size_t)(intptr_t)offset;
        printf("offset=%p\n", (void*)offset);
        if (idx < len)
            printf("%s\n", text[idx]);
        else
            printf("offset not a long (out of bounds)\n");
    }

    printf("--- testing offset not a long: Reference to string ---\n");
    {
        char *something = "href";
        char **offset = &something;
        size_t idx = (size_t)(intptr_t)offset;
        printf("offset=%p\n", (void*)offset);
        if (idx < len)
            printf("%s\n", text[idx]);
        else
            printf("offset not a long (out of bounds)\n");
    }

    printf("--- testing offset not a long: string ---\n");
    {
        char *offset = "test";
        size_t idx = (size_t)(intptr_t)offset;
        printf("offset=%p\n", (void*)offset);
        if (idx < len)
            printf("%s\n", text[idx]);
        else
            printf("offset not a long (out of bounds)\n");
    }

    printf("--- testing read_dimension with null offset ---\n");
    {
        size_t idx = (size_t)(intptr_t)NULL;
        if (idx >= len)
            printf("Cannot access a null offset (out of bounds)\n");
        else
            printf("unexpected access: %s\n", text[idx]);
    }

    printf("==DONE==\n");
    return 0;
}
