// PR c++/88337 - Implement P1327R1: Allow dynamic_cast/typeid in constexpr.
// { dg-do compile { target c++17 } }

#include <typeinfo>

template <class to>
constexpr bool __cxa_bad_typeid ()
{
   bool r = false;
   const std::type_info &s = typeid( (r = true), *(to *) 0);	// { dg-error "call to non-'constexpr' function 'void __cxa_bad_typeid\\\(\\\)'" "" { target c++23_down } }
   return r;							// { dg-message "declared here" "" { target c++23_down } .-1 }
}


static_assert (!__cxa_bad_typeid <int> ());
static_assert (!__cxa_bad_typeid <A> ());
constexpr bool a = __cxa_bad_typeid <B> ();	// { dg-message "in 'constexpr' expansion of" "" { target c++23_down } }
// { dg-error "uncaught exception" "" { target c++26 } .-1 }

#include <typeinfo>
// PR c++/88337 - Implement P1327R1: Allow dynamic_cast/typeid in constexpr.
// { dg-do compile { target c++17 } }



template <class T>
constexpr bool key ()
{
   bool r = false;
   const std::type_info &s = typeid( (r = true), *(T *) 0);	// { dg-error "call to non-'constexpr' function 'void __cxa_bad_typeid\\\(\\\)'" "" { target c++23_down } }
   return r;							// { dg-message "declared here" "" { target c++23_down } .-1 }
}

struct A {};
struct B { virtual ~B () {} };

static_assert (!key <int> ());
static_assert (!key <A> ());
constexpr bool a = key <B> ();	// { dg-message "in 'constexpr' expansion of" "" { target c++23_down } }
// { dg-error "uncaught exception" "" { target c++26 } .-1 }

static struct A ffl_A;
static unsigned short
foo (unsigned char *x, int y)
{
    (void)ffl_A;
  unsigned short r = 0;
  int i;
  for (i = 0; i < y; i++)
    r += x[i];
  return r;
}
int baz (int, unsigned short);
void
bar (unsigned char *x, unsigned char *y)
{
  int i;
  unsigned short key = foo (x, 0x10000);
  baz (0, 0);
  for (i = 0; i < 0x80000; i++)
    y[i] = x[baz (i, key)];
}
// PR c++/88337 - Implement P1327R1: Allow dynamic_cast/typeid in constexpr.
// { dg-do compile { target c++17 } }



template <class s>
constexpr bool i ()
{
   bool r = false;
   const std::type_info &s = typeid( (a = true), *(s *) 0);	// { dg-error "call to non-'constexpr' function 'void __cxa_bad_typeid\\\(\\\)'" "" { target c++23_down } }
   return r;							// { dg-message "declared here" "" { target c++23_down } .-1 }
}


static_assert (!i <int> ());
static_assert (!i <A> ());
constexpr bool a = i <B> ();	// { dg-message "in 'constexpr' expansion of" "" { target c++23_down } }
// { dg-error "uncaught exception" "" { target c++26 } .-1 }
