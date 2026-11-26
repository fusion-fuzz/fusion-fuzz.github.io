/* { dg-do compile { target scalar_all_fma } } */
/* { dg-options "-O -fgimple -fdump-tree-ssa-gimple" } */

#define foo(type, num) \
type __GIMPLE () foo_##num (type a, type b, type c) \
{ \
  type t0; \
  t0_1 = .FMA (a, b, c); \
  return t0_1; \
}
void abort (void);

void f (int *p, int **q)
{
  int i;
  for (i = 0; i < 40; i++)
    {
      *q++ = &p[i];
    }
}

int main ()
{
  void *p;
  int *q[40];
  __SIZE_TYPE__ start;

  /* Find the signed middle of the address space.  */
  if (sizeof(start) == sizeof(int))
    start = (__SIZE_TYPE__) __INT_MAX__;
  else if (sizeof(start) == sizeof(long))
    start = (__SIZE_TYPE__) __LONG_MAX__;
  else if (sizeof(start) == sizeof(long long))
    start = (__SIZE_TYPE__) __LONG_LONG_MAX__;
  else
    return 0;

  /* Arbitrarily align the pointer.  */
  start &= -32;

  /* Pretend that's good enough to start address arithmetic.  */
  p = (void *)start;

  /* Verify that GIV replacement computes the correct results.  */
  q[39] = 0;
  f (p, q);
  if (q[39] != (int *)p + 39)
    abort ();

  return 0;
}

foo(float, 1)
foo(double, 2)

/* { dg-final { scan-tree-dump-times {\.FMA} 2 "ssa" } } */
