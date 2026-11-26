
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: CastConsistency
// EXPECT-CRASH-ASSERT: isBooleanType
// EXPECT-CRASH-ASSERT: unheralded

enum E : bool {
  v = operator new(sizeof(int[2]),
};

static long ffl_fusion = (long)(E);

// RUN: %clang_cc1 -E %s | FileCheck %s --match-full-lines --strict-whitespace
// CHECK:   zzap

// zzap is on a new line, should be indented.
#define BLAH  zzap
   ffl_fusion
