
struct IncompleteType;

void foo() {
  IncompleteType *f;
  f->x;
}
// RUN: not %clang_cc1 -fsyntax-only -code-completion-at=%s:%(line-2):6 %s -o - | FileCheck %s -allow-empty
// CHECK-NOT: COMPLETION:
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: BuildMemberReferenceExpr
// EXPECT-CRASH-ASSERT: isDependentType
// EXPECT-CRASH-ASSERT: isDependentScopeSpecifier
// EXPECT-CRASH-ASSERT: instantiation

template <typename T>
auto f = [](auto... args) {
  union {
    char c;
  };
  c = 'a';
};

void g() { f<void>(); }
