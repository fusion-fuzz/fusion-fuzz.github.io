// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: AccessDeclContextCheck
// EXPECT-CRASH-ASSERT: AS_none

struct S {};

struct T {
  void operator delete(void *p){} : S

  {
    (enum e{a});

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(void) {
    const char *paths[] = {"temp.log", "memory.log", "temp2.log", "memory2.log"};
    FILE *o;
    int i;

    for (i = 0; i < 4; i++) {
        o = fopen(paths[i], "w+");
        if (!o) return 1;
        fprintf(o, "verbose: failed to open source\n");
        fflush(o);
        printf(i == 0 ? "temp stream (close after):\n" :
               i == 1 ? "\nmemory stream (close after):\n" :
               i == 2 ? "\ntemp stream (leak):\n" :
                         "\nmemory stream (leak):\n");
        rewind(o);
        while (fgetc(o) != EOF) {}
        if (i < 2) fclose(o);
    }

    printf("\nDone.\n");
    return 0;
}
