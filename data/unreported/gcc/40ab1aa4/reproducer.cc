struct A {
  int operator* () const;
  bool operator!= (A) const;
  A &operator++ ();
  ~A ();
};
struct C {};
A begin (C);
A end (C);
void f () {
  template for (constexpr int m : C ()) ;
}
