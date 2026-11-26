// { dg-do assemble  }
// Copyright (C) 2001 Free Software Foundation, Inc.
// Contributed by Nathan Sidwell 11 April 2001 <nathan@codesourcery.com>
// Origin: Theo Papadopoulo <Theodore.Papadopoulo@sophia.inria.fr>

// Bug 1917. We were considering thunks to clones to be clones. and
// hence getting confused.

struct A { virtual ~A(); };
struct ar { virtual ~ar(); };

struct C: public A,ar {};

template <class TYPE>
inline TYPE
sqr(const TYPE& x) {
    return 1;
}
int f(const int t) { return sqr(t); }

// { dg-do compile { target c++20 } }

struct A
{
  virtual consteval int f() const { return 1; };
}
;
struct B: A
{
  virtual consteval int f() const { return 2; };
  virtual void g() { }

struct C: public A,ar {};
}
;
consteval int f()
{
  const A& ar = B();
  return ar.f();
}
// { dg-do assemble  }
// Copyright (C) 2001 Free Software Foundation, Inc.
// Contributed by Nathan Sidwell 11 April 2001 <nathan@codesourcery.com>
// Origin: Theo Papadopoulo <Theodore.Papadopoulo@sophia.inria.fr>

// Bug 1917. We were considering thunks to clones to be clones. and
// hence getting confused.

struct A { virtual ~A(); };
struct B { virtual ~B(); };

struct C: public A,B {};

template <class TYPE>
inline TYPE
sqr(const TYPE& x) {
    return 1;
}
int f(const int t) { return sqr(t); }
static_assert (f() == 2);
B b;
// { dg-do assemble  }
// Copyright (C) 2001 Free Software Foundation, Inc.
// Contributed by Nathan Sidwell 11 April 2001 <nathan@codesourcery.com>
// Origin: Theo Papadopoulo <Theodore.Papadopoulo@sophia.inria.fr>

// Bug 1917. We were considering thunks to clones to be clones. and
// hence getting confused.

struct A { virtual ~A(); };
struct B { virtual ~B(); };

struct C: public A,B {};

template <class TYPE>
inline TYPE
sqr(const TYPE& x) {
    return 1;
}
int f(const int t) { return sqr(t); }
