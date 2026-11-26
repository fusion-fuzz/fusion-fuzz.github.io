// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: ParseParenExpression
// EXPECT-CRASH-ASSERT: CodeDC
// EXPECT-CRASH-ASSERT: isFileContext
// EXPECT-CRASH-ASSERT: statement

struct S {};

int foo = [] { void ffl_fusion::bar(__attribute__((assume(({}))))) };

// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: EvaluateAsInt
// EXPECT-CRASH-ASSERT: isValueDependent
// EXPECT-CRASH-ASSERT: evaluator

void foo() { char16_t(__format__(__printf__, 2, 4)) < char32_t(0x80); }

static long ffl_fusion = (long)(__format__);
