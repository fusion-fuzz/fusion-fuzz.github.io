/* PR tree-optimization/60823 */
/* { dg-do compile } */
/* { dg-options "-O2 -fopenmp-simd -fno-strict-aliasing" } */

void bar (char *, double *);

#if __SIZEOF_DOUBLE__ >= 4

void baz (struct S, struct S);
#ifdef __aarch64__
#pragma omp declare simd simdlen(2) notinbranch
#else
#pragma omp declare simd simdlen(4) notinbranch
#endif

#endif

// PR c++/115012
// { dg-do compile { target { c++11 } } }
// { dg-final { scan-assembler "_Z3fooIJidEEvDpFT_iE" } }
// { dg-final { scan-assembler "_Z3barIiEvPFT_iE" } }
// { dg-final { scan-assembler "_Z3bazIJidEEvDpFT_iE" } }

template <typename ...T>
void
foo (T... x (int))
{
}
template <typename T>
void
bar (T (int))
{
}
template <typename ...T>
void
baz (T... (int))
{
}
int
f1 (int)
{
  return 0;
}
/* PR tree-optimization/60823 */
/* { dg-do compile } */
/* { dg-options "-O2 -fopenmp-simd -fno-strict-aliasing" } */

void a (char *, double *);
#if __SIZEOF_DOUBLE__ >= 4
struct S { char c[sizeof (double)]; }
;
void b (struct S, struct S);
union U { struct S s; double d; }
;
#ifdef __aarch64__
#pragma omp declare simd simdlen(2) notinbranch
#else
#pragma omp declare simd simdlen(4) notinbranch
#endif
__attribute__((noinline)) int
foo (double c1, double c2)
{
  double *a = &c1;
  char *b = (char *) &c1 + 2;

  b[-2]++;
  b[1]--;
  *a++;
  c2++;
  a ((char *) &c2 + 1, &c2);
  c2 *= 3.0;
  a (b, a);
  b (((union U) { .d = c1 }).s, ((union U) { .d = c2 }).s);
  b (*(struct S *)&c1, *(struct S *)&c2);
  return c1 + c2 + ((struct S *)&c1)->c[1];
}
double
f2 (int)
{
  return 0;
}
void
corge ()
{
  foo <int, double> (f1, f2);
  bar <int> (f1);
  baz <int, double> (f1, f2);
}
#endif
