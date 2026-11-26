// PR c++/45236
// { dg-do compile { target c++11 } }

template <class T, class S> class foo;

template<template<int...> class C, int... II, class S>
struct foo<C<II...>,S>
// { dg-do compile { target c++11 } }
// { dg-require-effective-target lto }
// { dg-additional-options "-flto" }

// PR 79296 ICE mangling local class of localized instantiation

struct X {
  template <typename T> X (T const *) {
    struct Z {};
  }
};
{
    template <class U>
    struct bar { typedef int type; };
};

template <int... I>
struct A {};

foo<A<3>, float>::bar<int> x;

void Baz ()
{
  struct Y { } y;

  0, X (&y);
}
