struct A {
  int A (this A &, auto);
  void f (this A);
};
void g (A s) { s.f (); }
