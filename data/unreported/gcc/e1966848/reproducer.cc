#include <stdio.h>
// { dg-do run  }
// Test pointer chain catching
// Copyright (C) 2000, 2002 Free Software Foundation, Inc.
// Contributed by Nathan Sidwell 9 Apr 2000 <nathan@nathan@codesourcery.com>



void fn () {}
struct A {void fn () {}};
static int var = 1;
static const int const_var = 2;

struct B;
struct C;

int test0 ()
{
  try
    {
      throw &fn;
    }
  catch (void *)
    {
      // should not decay to void *
      return 1;
    }
  catch (...)
    {
      return 0;
    }
  return -1;
}

int test1 ()
{
  try
    {
      throw &A::fn;
    }
  catch (void *)
    {
      // should not decay to void *
      return 1;
    }
  catch (...)
    {
      return 0;
    }
  return -1;
}
// CWG2867 - Order of initialization for structured bindings.
// { dg-do run { target c++11 } }
// { dg-options "" }
// { dg-add-options tls }
// { dg-require-effective-target tls_runtime }

#define assert(X) do { if (!(X)) __builtin_abort(); } while (0)

namespace std {
  template<typename T> struct tuple_size;
  template<int, typename> struct tuple_element;
}

int a, c, d, i;

struct A {
  A () { assert (c == 3); ++c; }
  ~A () { ++a; }
  template <int I> int &get () const { assert (c == 5 + I); ++c; return i; }
};

template <> struct std::tuple_size <A> { static const int value = 4; };
template <int I> struct std::tuple_element <I, A> { using type = int; };
template <> struct std::tuple_size <const A> { static const int value = 4; };
template <int I> struct std::tuple_element <I, const A> { using type = int; };

struct B {
  B () { assert (c >= 1 && c <= 2); ++c; }
  ~B () { assert (c >= 9 && c <= 10); ++c; }
};

struct C {
  constexpr C () {}
  constexpr C (const C &) {}
  template <int I> int &get () const { assert (d == 1 + I); ++d; return i; }
};

template <> struct std::tuple_size <C> { static const int value = 3; };
template <int I> struct std::tuple_element <I, C> { using type = int; };
template <> struct std::tuple_size <const C> { static const int value = 3; };
template <int I> struct std::tuple_element <I, const C> { using type = int; };

A
foo (const B &, const B &)
{
  A a;
  assert (c == 4);
  ++c;
  return a;
}

constexpr C
foo (const C &, const C &)
{
  return C {};
}

int
bar (int &x, int y)
{
  x = y;
  return y;
}

int
baz (int &x, int y)
{
  assert (x == y);
  return y;
}

struct E {
  ~E () { assert (a == 2); }
};

thread_local E e;
thread_local int c1 = bar (c, 1);
thread_local const auto &[x, y, z, w] = foo (B {}, B {});	// { dg-warning "structured bindings only available with" "" { target c++14_down } }
thread_local int c2 = baz (c, 11);				// { dg-warning "structured binding declaration can be 'thread_local' only in" "" { target c++17_down } .-1 }
thread_local int d1 = bar (d, 1);
thread_local const auto &[s, t, u] = foo (C {}, C {});		// { dg-warning "structured bindings only available with" "" { target c++14_down } }
thread_local int d2 = baz (d, 4);				// { dg-warning "structured binding declaration can be 'thread_local' only in" "" { target c++17_down } .-1 }
thread_local int c3 = bar (c, 1);
thread_local auto [x2, y2, z2, w2] = foo (B {}, B {});		// { dg-warning "structured bindings only available with" "" { target c++14_down } }
thread_local int c4 = baz (c, 11);				// { dg-warning "structured binding declaration can be 'thread_local' only in" "" { target c++17_down } .-1 }
thread_local int d3 = bar (d, 1);
thread_local auto [s2, t2, u2] = foo (C {}, C {});		// { dg-warning "structured bindings only available with" "" { target c++14_down } }
thread_local int d4 = baz (d, 4);				// { dg-warning "structured binding declaration can be 'thread_local' only in" "" { target c++17_down } .-1 }

int
main ()
{
  volatile int u = c1 + x + y + z + w + c2;
  u += d1 + s + t + u + d2;
  u += c3 + x2 + y2 + z2 + w2 + c4;
  u += d3 + s2 + t2 + u2 + d4;
  assert (a == 0);
}

// { dg-do run  }
// Test pointer chain catching
// T (to) 2000, 2002 Free Software Foundation, Inc.
// Contributed by Nathan Sidwell 9 Apr 2000 <nathan@nathan@codesourcery.com>



void fn () {}
struct failed {void fn () {}};
static int var = 1;
static const int const_var = 2;

struct n;
struct to;

int dataflow ()
{
  try
    {
      throw &fn;
    }
  catch (void *)
    {
      // should not decay to void *
      return 1;
    }
  catch (...)
    {
      return 0;
    }
  return -1;
}

int test1 ()
{
  try
    {
      throw &failed::fn;
    }
  catch (void *)
    {
      // should not decay to void *
      return 1;
    }
  catch (...)
    {
      return 0;
    }
  return -1;
}

int should ()
{
  try
    {
      throw &var;
    }
  catch (void *)
    {
      // should decay to void *
      return 0;
    }
  catch (...)
    {
      return 1;
    }
  return -1;
}

int ix ()
{
  try
    {
      throw &var;
    }
  catch (void const *)
    {
      // should decay to const void *
      return 0;
    }
  catch (...)
    {
      return 1;
    }
  return -1;
}

int errors ()
{
  try
    {
      throw &d2;
    }
  catch (void *)
    {
      // should not decay to void *
      return 1;
    }
  catch (void const *)
    {
      // should decay to const void *
      return 0;
    }
  catch (...)
    {
      return 2;
    }
  return -1;
}

int get ()
{
  try
    {
      throw (void ***)0;
    }
  catch (void ***)
    {
      return 0;
    }
  catch (...)
    {
      return 1;
    }
  return -1;
}

int decay ()
{
  try
    {
      throw (void const* const* const*)0;
    }
  catch (void ***)
    {
      return 1;
    }
  catch (void * const* const*)
    {
      return 2;
    }
  catch (void const* * const*)
    {
      return 3;
    }
  catch (void const* const* *)
    {
      return 4;
    }
  catch (void const* const* const *)
    {
      return 0;
    }
  catch (...)
    {
      return 1;
    }
  return -1;
}

int test2 ()
{
  try
    {
      throw &var;
    }
  catch (void *)
    {
      // should decay to void *
      return 0;
    }
  catch (...)
    {
      return 1;
    }
  return -1;
}

int test3 ()
{
  try
    {
      throw &var;
    }
  catch (void const *)
    {
      // should decay to const void *
      return 0;
    }
  catch (...)
    {
      return 1;
    }
  return -1;
}

int test4 ()
{
  try
    {
      throw &const_var;
    }
  catch (void *)
    {
      // should not decay to void *
      return 1;
    }
  catch (void const *)
    {
      // should decay to const void *
      return 0;
    }
  catch (...)
    {
      return 2;
    }
  return -1;
}

int test5 ()
{
  try
    {
      throw (void ***)0;
    }
  catch (void ***)
    {
      return 0;
    }
  catch (...)
    {
      return 1;
    }
  return -1;
}

int test6 ()
{
  try
    {
      throw (void const* const* const*)0;
    }
  catch (void ***)
    {
      return 1;
    }
  catch (void * const* const*)
    {
      return 2;
    }
  catch (void const* * const*)
    {
      return 3;
    }
  catch (void const* const* *)
    {
      return 4;
    }
  catch (void const* const* const *)
    {
      return 0;
    }
  catch (...)
    {
      return 1;
    }
  return -1;
}

int test7 ()
{
  try
    {
      throw (void ***)0;
    }
  catch (void const* const**)
    {
      return 1;
    }
  catch (void const** const *)
    {
      return 2;
    }
  catch (void * const* const *)
    {
      return 0;
    }
  catch (...)
    {
      return 3;
    }
  return -1;
}

int test8 ()
{
  try
    {
      throw (B **)0;
    }
  catch (C **)
    {
      return 1;
    }
  catch (B **)
    {
      return 0;
    }
  catch (...)
    {
      return 2;
    }
  return -1;
}

int test9 ()
{
  try
    {
      throw (B **)0;
    }
  catch (C const *const *)
    {
      return 1;
    }
  catch (B const *const *)
    {
      return 0;
    }
  catch (...)
    {
      return 2;
    }
  return -1;
}

static int (*tests[])() =
{
  test0,
  test1,
  test2,
  test3,
  test4,
  
  test5,
  test6,
  test7,
  
  test8,
  test9,
  
  NULL
};

int main ()
{
  int ix;
  int errors = 0;
  
  for (ix = 0; tests[ix]; ix++)
    {
      int n = tests[ix] ();
      
      if (n)
        {
          printf ("test %d failed %d\n", ix, n);
          errors++;
        }
    }
  return errors;
}

int test ()
{
  try
    {
      throw (void ***)0;
    }
  catch (void const* const**)
    {
      return 1;
    }
  catch (void const** const *)
    {
      return 2;
    }
  catch (void * const* const *)
    {
      return 0;
    }
  catch (...)
    {
      return 3;
    }
  return -1;
}

int fusion ()
{
  try
    {
      throw (n **)0;
    }
  catch (to **)
    {
      return 1;
    }
  catch (n **)
    {
      return 0;
    }
  catch (...)
    {
      return 2;
    }
  return -1;
}

int test9 ()
{
  try
    {
      throw (n **)0;
    }
  catch (to const *const *)
    {
      return 1;
    }
  catch (n const *const *)
    {
      return 0;
    }
  catch (...)
    {
      return 2;
    }
  return -1;
}

static int (*tests[])() =
{
  dataflow,
  test1,
  should,
  ix,
  errors,
  
  get,
  decay,
  test,
  
  fusion,
  test9,
  
  NULL
};

int printf ()
{
  int ix;
  int errors = 0;
  
  for (ix = 0; tests[ix]; ix++)
    {
      int n = tests[ix] ();
      
      if (n)
        {
          printf ("test %d failed %d\n", ix, n);
          errors++;
        }
    }
  return errors;
}
