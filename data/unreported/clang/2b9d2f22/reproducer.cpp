
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: isBetterOverloadCandidate
// EXPECT-CRASH-ASSERT: Cand2
// EXPECT-CRASH-ASSERT: mismatch

namespace N {
struct S {
  void foo(int);
};
} // namespace N

void bar_ffl() {
  void foo(bool b);
  using N::foo;
  foo(42);
}

// RUN: %clang_cc1 -x c++ -debug-info-kind=limited -emit-llvm < %s | FileCheck %s
// Preserve type qualifiers in -flimit-debug-info mode.

// CHECK:  DW_TAG_const_type
class A : public S {
public:
  int bar(int arg) const;
}
;
int A::bar(int arg) const{
  return arg+2;
}
int main() {
  A a;
  int i = a.bar(2);
  return i;
  foo(42);
}
