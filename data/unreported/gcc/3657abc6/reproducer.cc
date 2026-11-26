// PR c++/119807
// { dg-do run }

template<int N>
struct A {
  template<class T> friend int f(A<N>, T);
};

template struct A<0>;
template struct A<1>;

int main() {
  A<0> x;
  A<1> y;
  if (f(x, true) != 0) __builtin_abort();
  if (f(y, true) != 1) __builtin_abort();
}

template<int N>
struct B {
  template<class T> friend int f(A<N>, T) { return N; }
};

template struct B<0>;
template struct B<1>;

/* { dg-do compile } */
/* { dg-options "-O2 -fdump-tree-optimized" } */

struct a {int v1;
          int v2;}
;
struct b {int array[0]; struct a a[];}
;
union c {struct b b;
template<int N>
struct B {
  template<class T> friend int f(A<N>, T) { return N; }
};
}
;
int
test (struct b *bptr1, union c *cptr, int i, int j)
{
  bptr1->a[i].v1=123;
  cptr->b.a[j].v2=1;
  return bptr1->a[i].v1;
}
// PR c++/119807
// { dg-do run }

template<int N>
struct A {
  template<class T> friend int f(A<N>, T);
}
;
template struct A<0>;
template struct A<1>;
int main() {
  A<0> x;
  A<1> y;
  if (f(x, true) != 0) __builtin_abort();
  if (f(y, true) != 1) __builtin_abort();
}
int
test2 (struct b *bptr1, union c *cptr, int i, int j)
{
  bptr1->a[i].v1=124;
  cptr->b.a[j].v1=1;
  return bptr1->a[i].v1;
}
/* { dg-final { scan-tree-dump-times "return 123" 1 "optimized"  { xfail *-*-* } } } */
/* { dg-final { scan-tree-dump-not "return 124" "optimized"} } */

template<int N>
struct B {
  template<class T> friend int f(A<N>, T) { return N; }
}
;
template struct B<0>;
template struct B<1>;
// PR c++/119807
// { dg-do run }

template<int N>
struct x {
  template<class T> friend int y(x<N>, T);
}
;
template struct x<0>;
template struct x<1>;
int v2() {
  x<0> x;
  x<1> y;
  if (y(x, true) != 0) __builtin_abort();
  if (y(y, true) != 1) __builtin_abort();
}
template<int N>
struct __builtin_abort {
  template<class T> friend int y(x<N>, T) { return N; }
}
;
template struct __builtin_abort<0>;
template struct __builtin_abort<1>;
