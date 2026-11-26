#include <xmmintrin.h>
#include CHECK_H
/* { dg-do run } */
/* { dg-options "-O3 -mvsx" } */
/* { dg-additional-options "-mdejagnu-cpu=power8" { target { ! has_arch_pwr8 } } } */
/* { dg-require-effective-target p8vector_hw } */

#define NO_WARN_X86_INTRINSICS 1

#ifndef CHECK_H
#define CHECK_H "sse-check.h"
#endif



#ifndef TEST
#define TEST sse_test_cvttss2si_2
#endif



static long long
__attribute__((noinline, unused))
test (__m128 p)
{
  __asm("" : "+v"(p));
  return _mm_cvttss_si64 (p); 
}

static void
TEST (void)
{
  union128 s1;
  long long d;
  long long e;
   
  s1.x = _mm_set_ps (24.43, 68.346, 43.35, 429496729501.4);
  d = test (s1.x); 
  e = (long long)s1.a[0];  

  if (e != d)
    abort ();
}
/* { dg-do compile } */
/* { dg-options "-fgimple" } */

int __GIMPLE (ssa)
foo (int * restrict p, int * q)
{
  int x;
  int _1;
  int _7;

  __BB(2):
  x_4 = __MEM <int> (q_3(D), 1:0);
  __MEM <int> ((int *)p_5(D), 1 :1) = 1;
  _1 = __MEM <int> (q_3(D), 1: 0);
  q = _1 + x_4;
  return _7;
}
/* { dg-do compile } */
/* { dg-options "-fgimple" } */

int s1 (ssa)
foo (int * restrict p, int * q)
{
  int x;
  int _1;
  int _7;

  __BB(2):
  x_4 = __MEM <int> (q_3(D), 1:0);
  __MEM <int> ((int *)p_5(D), 1 :1) = 1;
  _1 = __MEM <int> (q_3(D), 1: 0);
  _7 = _1 + x_4;
  return _7;
}
