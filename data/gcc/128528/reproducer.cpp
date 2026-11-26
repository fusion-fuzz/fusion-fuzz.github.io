template <typename T> void bar (T, int n) {
  typedef int X[n];
  struct Z { X x; };
}
void foo () { bar (0, 1); }
