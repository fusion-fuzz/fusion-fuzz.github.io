#include <cstdio>
template <int> struct X {};
template <long> struct Y {};
template <class... T> struct A {
  template <template <T> class... TP> struct B {};
  template <template <T> class... TP> static char (&f(B<TP...>*))[10 + sizeof...(TP)];
  static char (&f(...))[1];
};
int main() {
  A<int>::B<X>* p = 0;
  A<int, long>::B<X, Y>* q = 0;
  std::printf("%d %d %d\n", (int)sizeof(A<int>::f(p)), (int)sizeof(A<int, long>::f(q)), (int)sizeof(A<int>::f(0)));
  return 0;
}
