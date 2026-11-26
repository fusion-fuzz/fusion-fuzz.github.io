
// RUN: clang++ -c %s
// EXPECT-CRASH-NOASSERT

enum class C {};

struct S {
  friend void C::Foo();
  // CHECK: t IBM-1047    T=on
  void foo() { return; }
};
