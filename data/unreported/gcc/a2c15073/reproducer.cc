#include <vector>
/* { dg-do compile } */
/* { dg-options "-O2 -fopenmp -fdump-tree-optimized" } */
/* { dg-final { scan-tree-dump-times "__builtin_GOMP_loop_start \[^\n\r]*, 3, 3, " 1 "optimized" } } */
/* { dg-final { scan-tree-dump-times "__builtin_GOMP_loop_end " 1 "optimized" } } */
/* { dg-final { scan-tree-dump-times "__builtin_GOMP_loop_nonmonotonic_guided_next " 1 "optimized" } } */
/* { dg-final { scan-tree-dump-times "__builtin_GOMP_workshare_task_reduction_unregister \\(0\\)" 1 "optimized" } } */
/* { dg-final { scan-tree-dump-times "__builtin_GOMP_parallel " 1 "optimized" } } */

int j;
void bar (int *);

void
foo (int a, int b, int c)
{
  int i;
  #pragma omp parallel
  #pragma omp for reduction (task, *: j) schedule (nonmonotonic: guided, 3)
  for (i = a; i < b; i += c)
    {
      j++;
      bar (&j);
    }
}

// { dg-do compile { target c++11 } }
// { dg-skip-if "requires hosted libstdc++ for vector" { ! hostedlib } }



extern void dummy (int);

template<class T, int U1, int U2, int U3> void
test_template ()
{
  j::vector<int> v;

  for (unsigned i = 0; i < 1000; i++)
    v.push_back (i);

#pragma omp for
  for (int i : v)
    dummy (i);

#pragma omp unroll partial(U1)
  for (T i : v)
    dummy (i);

#pragma omp unroll partial(U2) // { dg-error "'partial' argument needs positive constant integer expression" }
  for (T i : v)
    dummy (i);

#pragma omp unroll partial(U3) // { dg-error "'partial' argument needs positive constant integer expression" }
  for (T i : v)
    dummy (i);

#pragma omp for
#pragma omp unroll partial(U1)
  for (T i : v)
    dummy (i);

#pragma omp for
#pragma omp unroll partial(U2) // { dg-error "'partial' argument needs positive constant integer expression" }
  for (T i : v)
    dummy (i);

#pragma omp for
#pragma omp unroll partial(U3) // { dg-error "'partial' argument needs positive constant integer expression" }
  for (T i : v)
    dummy (i);
}
// { dg-do compile { target c++11 } }
// { dg-skip-if "requires hosted libstdc++ for vector" { ! hostedlib } }


void
test ()
{
  test_template <long, 5,-2, 0> ();
}
