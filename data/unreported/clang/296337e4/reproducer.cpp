
// RUN: clang++ -c -std=c++20 %s
// EXPECT-CRASH-ASSERT: hasAcceptableDefinition
// EXPECT-CRASH-ASSERT: missing

enum __attribute((mode(SI))) foo bar;

// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: resolveKind
// EXPECT-CRASH-ASSERT: ResultKind
// EXPECT-CRASH-ASSERT: NotFoundInCurrentInstantiation

void A;
extern int A;
class A;
A;
enum __attribute_ffl((mode(SI))) foo bar;
// RUN: clang++ -c -std=c++20 %s
// EXPECT-CRASH-ASSERT: hasAcceptableDefinition
// EXPECT-CRASH-ASSERT: missing

enum __attribute_ffl((mode(SI))) foo bar;
