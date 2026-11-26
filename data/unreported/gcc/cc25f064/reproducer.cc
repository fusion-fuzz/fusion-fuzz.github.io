// PR c++/123080
// { dg-do compile { target c++20 } }
// { dg-do compile }

// Copyright (C) 2001 Free Software Foundation, Inc.
// Contributed by Nathan Sidwell 28 Dec 2001 <nathan@codesourcery.com>

// PR 775 friend classes with qualified names inside template classes.

struct A
{
  struct B {
    B () { }
  };
};

template <class T>
auto f = [](auto x) requires requires { // { dg-error "expected | invalid member template | constraints" }
struct C: A {
  friend A::B::B (); // 2.95.2 ICE
  friend struct A;
  friend struct A::B; // 2.97 error
};

template class C<char>;

template <typename T> class TPL
{
  class nested;
};

template <typename T> class TPL<T>::nested 
{
};

// PR c++/123080
// { dg-do compile { target c++20 } }
auto f = [](auto x) requires requires { // { dg-error "expected | invalid member template | constraints" }
