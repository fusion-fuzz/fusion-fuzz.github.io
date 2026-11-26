struct A { ~A (); };
struct C { C (A); };
struct S { A x; C y; };
int t;

S *f ()
{
  return new S {A (), t};
}
