
// RUN: %clang_cc1 -fsyntax-only  %s
struct foo {
  virtual void bar() ;
};
template<typename T>
class zed : public foo {
};
template<typename T>
class bah : public zed<T> {
  void f() {
     const_cast<foo *>(this->g())->bar();
  }
};
// RUN: clang++ -c -std=c++20 %s
// EXPECT-CRASH-ASSERT: isReferenceToNonConstCapture
// EXPECT-CRASH-ASSERT: Binding

void foo_ffl() {
  return ^{
    int arr[] = {1, 2};
    auto [e1, e2] = arr;
    auto lambda = [e1] { e1 = 42; };
  };
}
