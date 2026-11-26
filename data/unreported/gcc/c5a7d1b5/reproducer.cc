// PR c++/117512



// { dg-do compile { target c++11 } }

struct A
{
  A(int = 0);
}
;
// PR c++/117512

A foo (int);
void
bar ()
{
  A e = { 0 };
  A d = foo (0) = e;
}
struct B: A
{
  B();
  using A::A;
}
;
B b1(1);
B b;
// PR c++/117512
