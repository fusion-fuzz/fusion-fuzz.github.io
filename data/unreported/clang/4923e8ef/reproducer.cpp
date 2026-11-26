// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: setQualifierLoc
// EXPECT-CRASH-ASSERT: getNestedNameSpecifier
// EXPECT-CRASH-ASSERT: nested-name-specifier

template <typename C1, typename C2>
operator int C1::*C2::*__attribute__((__vector_size__(16))) {
  return 0;
}

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct { const char* name; } Bucket;

Bucket* open_bucket(const char* name, const char* pass) {
    if (strcmp(pass, "secret") == 0) {
        return malloc(sizeof(Bucket));
    }
    return NULL;
}

void close_bucket(Bucket* b) {
    if (b) free(b);
}

int main(void) {
    Bucket* b = open_bucket("authenticated", "secret");
    close_bucket(b);
    close_bucket(b);
    b = open_bucket("authenticated", "secretw");
    close_bucket(b);
    return 0;
}
