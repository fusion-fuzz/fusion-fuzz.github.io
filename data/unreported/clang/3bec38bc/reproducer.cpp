#include <stdio.h>
#include <stdlib.h>
// RUN: clang++ -c -std=c++03 %s
// EXPECT-CRASH-NOASSERT

double foo = __builtin_structured_binding_size(double);



int main() {
    malloc(1);
    printf("<a href=\"some.php\">abc</a>\n");
    return 0;
}
