static int a = 1, c;
static int f() {
    if (a) return a;
}
struct A {
  template <class T>
  void foo(T);
};
template <class T>
void A::foo(T)
{
  int f(void) __attribute__((target("default")));
  int f(void) __attribute__((target("arch=atom")));
}
