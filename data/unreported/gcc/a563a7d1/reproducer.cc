/* PR tree-optimization/107967 */
/* { dg-do compile { target float64 } } */
/* { dg-options "-O2 -fno-rounding-math -fno-trapping-math -fdump-tree-optimized" } */
/* { dg-add-options float64 } */
/* { dg-final { scan-tree-dump-times "return\[ \t]\*-?Inf;" 3 "optimized" } } */

_Float64
foo (_Float64 x)
{
  if (x >= 1.0e+300f64)
    ;
  else
    __builtin_unreachable ();
  return x * x;
}

_Float64
bar (_Float64 x)
{
  if (x >= 1.0e+300f64)
    ;
  else
    __builtin_unreachable ();
  return x * -x;
}

_Float64
baz (_Float64 a, _Float64 b)
{
  if (a >= 0x1.fffffffffffffp+1023f64)
    ;
  else
    __builtin_unreachable ();
  if (b >= 0x1.p+972f64)
    ;
  else
    __builtin_unreachable ();
  return a + b;
}

_Float64
qux (_Float64 a, _Float64 b)
{
  if (a >= 0x1.fffffffffffffp+1023f64)
    ;
  else
    __builtin_unreachable ();
  if (b >= 0x1.fffffffffffffp+969f64)
    ;
  else
    __builtin_unreachable ();
  return a + b;
}

// CWG3119 - for-range-declaration of an expansion-statement as a templated
// entity.
// { dg-do run { target c++26 } }

namespace std {
  using size_t = decltype (sizeof 0);
  template<typename T> struct tuple_size;
  template<size_t, typename> struct tuple_element;
}
struct B { int a; long b; };
struct C { char a; short b; int c; long d; long long e; float f; };
struct E { char a; template <int I> char &get () { return a; } };

template <> struct std::tuple_size <E> { static const int value = 7; };
template <std::size_t I> struct std::tuple_element <I, E> { using type = char; };

struct A
{
  B b;
  C c;
  int d[3];
  E e;
};

template <typename ...T>
int
__builtin_abort (T... x)
{
  return sizeof... (x);
}

int
main ()
{
  int ret = 0;
  template for (auto [...e] : A ())
    ret += __builtin_abort (e...);
  if (ret != 18)
    __builtin_abort ();
}
