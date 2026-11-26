#include <stdlib.h>
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: BuildUsingDeclaration
// EXPECT-CRASH-ASSERT: isInvalid
// EXPECT-CRASH-ASSERT: CXXScopeSpec

class C1;
class C2 {
int main() {
    qsort(NULL, 0, sizeof(Triple), cmp);
    return 0;
}
  using C1::operator()<>();
};
