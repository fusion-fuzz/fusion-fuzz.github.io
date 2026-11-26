struct S {
  int a;
  S() : a(0) {}
  struct { int a; int b[]; };
};
