// PR c++/51227
// { dg-do compile { target c++11 } }

template<int> int foo()
{
  [] (void i) { return 0; } (0); // { dg-error "incomplete|invalid|no match" }
  return 0;
}
/* { dg-do compile { target { ! int128 } } } */
/* { dg-options "-fpermissive" } */
/* { dg-final { scan-assembler "__builtin_" } } */

int i (int x)
{
  return __builtin_bswap128 (x); /* { dg-warning "implicit declaration" } */
}

void bar()
{
  foo<0>();
}
