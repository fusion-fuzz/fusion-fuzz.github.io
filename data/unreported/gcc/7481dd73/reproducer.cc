// PR c++/46868
// { dg-do compile }

template < int > struct S { S < // { dg-error "" }

// PR c++/55753
// { dg-do compile { target c++11 } }

struct A
{
  double r,i;
  constexpr A(double r = 0.0, double i = 0.0): r(r), i(i) {}
}
;
template <typename Tp, typename _FflDeclT = S<int>>
struct B {
  B() {
    A((true ? 1.0 : A()));
  }
}
;
