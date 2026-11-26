#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: ActOnIdExpression
// EXPECT-CRASH-ASSERT: getAsSingle
// EXPECT-CRASH-ASSERT: declaration

template<class > foo ; foo(foo<>
        free(res.message);
        return 1;
