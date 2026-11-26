#include <stdio.h>
#include <stdlib.h>

int main() {
    char *browser = getenv("HTTP_USER_AGENT");
    printf("%s\n", browser);
    return 0;
}
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: VisitParenTypeLoc
// EXPECT-CRASH-ASSERT: DeclaratorChunk

template <class T> T(Foo)() __attribute__((ext_vector_type(2)));
