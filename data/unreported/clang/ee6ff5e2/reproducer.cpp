#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: ParseStatementOrDeclaration
// EXPECT-CRASH-ASSERT: empty
// EXPECT-CRASH-ASSERT: isInvalid
// EXPECT-CRASH-ASSERT: isUsable

void foo() {
#pragma clang loop interleave(enable)
#pragma pack(pop)
}
