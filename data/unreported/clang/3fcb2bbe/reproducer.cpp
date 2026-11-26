
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: setType
// EXPECT-CRASH-ASSERT: isNull
// EXPECT-CRASH-ASSERT: isReferenceType
// EXPECT-CRASH-ASSERT: Expressions

template <typename T> struct S {};

template <class T> void foo() {
  S<T> bar(1, (const T &x : baz) {}
  const void *g3 = __builtin___CFStringMakeConstantString("test™");
}

template struct foo<qux>;
