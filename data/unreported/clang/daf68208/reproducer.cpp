
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: TransformInitializer
// EXPECT-CRASH-ASSERT: empty
// EXPECT-CRASH-ASSERT: parens

struct S {
  S(int i) : {}
  void x();
};

template <bool T> S foo() {
  S obj(1;
  return obj;
}

void bar() { foo<false>(); }
// RUN: c-index-test -code-completion-at=%s:7:1 -load %llvmshlibdir/PrintFunctionNames%pluginext -add-plugin print-fns %s | FileCheck %s
// REQUIRES: plugins, examples
// CHECK: macro definition:{{.*}}
// CHECK-NOT: top-level-decl: "x"

void x();
