
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: EnterDeclaratorContext
// EXPECT-CRASH-ASSERT: CurContext
// EXPECT-CRASH-ASSERT: ancestor

a = [](::

static long ffl_fusion = (long)(a);
// RUN: %clang_cc1 -fsyntax-only -code-completion-at=%s:%(line-1):11 %s -o - | FileCheck --check-prefix=CC1 %s
// CC1-NOT: foo

int ffl_fusion = 10;
// RUN: %clang_cc1 -fsyntax-only -code-completion-at=%s:%(line-1):11 %s -o - | FileCheck --check-prefix=CC1 %s
// CC1-NOT: foo
