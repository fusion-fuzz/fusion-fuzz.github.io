
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: getTypeInfoImpl
// EXPECT-CRASH-ASSERT: getDeducedType
// EXPECT-CRASH-ASSERT: undeduced

void foo() {
  auto *bar = delete;

  int A::i;
  delete[] bar;
}
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: getLVForDecl
// EXPECT-CRASH-ASSERT: getLinkage
// EXPECT-CRASH-ASSERT: OldLinkage

struct A {
  static int i;
} __attribute__((internal_linkage));

int A::i;
