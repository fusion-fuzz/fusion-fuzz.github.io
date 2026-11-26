#include <meta>
// { dg-do compile { target c++26 } }
// { dg-additional-options "-freflection" }
// Test std::meta::constant_of, CWG 3111.


using namespace std::meta;

// { dg-do compile { target c++26 } }
// { dg-additional-options "-freflection" }
// Test std::meta::constant_of, CWG 3111.




// LWG4483 Multidimensional arrays
// constexpr info mr = reflect_constant_array (mis);
// static_assert (constant_of (^^mis) == mr);

constexpr int is[] = {1, 2, 3};
constexpr info r = reflect_constant_array (is);
static_assert (constant_of (^^is) == r);

constexpr int mis[2][2] = {{1, 2}, {3, 4}};
// LWG4483 Multidimensional arrays
// constexpr info mr = reflect_constant_array (mis);
// static_assert (constant_of (^^mis) == mr);


/* { dg-do compile { target *-*-linux* } } */
/* { dg-options "-O2 -fno-pic -fno-plt" } */

extern void bar (void);

void *
foo (void)
{
  return &r+1;
}

/* { dg-final { scan-assembler "mov\(l|q\)\[ \t\]*bar@GOTPCREL" { target { ! ia32 } } } } */
/* { dg-final { scan-assembler-not "\(mov|lea\)\(l|q\)\[ \t\]*\(\\\$|\)bar," { target { ! ia32 } } } } */
