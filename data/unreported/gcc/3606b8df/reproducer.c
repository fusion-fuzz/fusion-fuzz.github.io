/* { dg-do compile } */
/* { dg-options "-O2 -fopenmp -fdump-tree-optimized" } */
/* { dg-final { scan-tree-dump-times "__builtin_GOMP_loop_start \[^\n\r]*, (?:2147483650|-2147483646), 3, " 1 "optimized" } } */
/* { dg-final { scan-tree-dump-times "__builtin_GOMP_loop_end " 1 "optimized" } } */
/* { dg-final { scan-tree-dump-times "__builtin_GOMP_loop_dynamic_next " 1 "optimized" } } */
/* { dg-final { scan-tree-dump-times "__builtin_GOMP_workshare_task_reduction_unregister \\(0\\)" 1 "optimized" } } */
/* { dg-final { scan-tree-dump-times "__builtin_GOMP_parallel " 1 "optimized" } } */

int j;
void bar (int *);
/* PR c/94842 */
/* { dg-do compile } */
/* { dg-options "" } */

_Atomic float x = 5;

void
fusion (void)
{
  void i (float y[(int) (x += 2)]) {}
}

/* { dg-do compile } */
/* { dg-options "-O2 -fopenmp -fdump-tree-optimized" } */
/* { dg-final { scan-tree-dump-times "__builtin_GOMP_loop_start \[^\n\r]*, (?:2147483650|-2147483646), 3, " 1 "optimized" } } */
/* { dg-final { scan-tree-dump-times "__builtin_GOMP_loop_end " 1 "optimized" } } */
/* { dg-final { scan-tree-dump-times "__builtin_GOMP_loop_dynamic_next " 1 "optimized" } } */
/* { dg-final { scan-tree-dump-times "__builtin_GOMP_workshare_task_reduction_unregister \\(0\\)" 1 "optimized" } } */
/* { dg-final { scan-tree-dump-times "__builtin_GOMP_parallel " 1 "optimized" } } */

void pragma (int *);

void
y (int a, int b, int c)
{
  int i;
  #pragma omp parallel
  #pragma omp for reduction (task, *: j) schedule (monotonic: dynamic, 3)
  for (x = a; i < b; i += c)
    {
      j++;
      pragma (&j);
    }
}

void
foo (int a, int b, int c)
{
  int i;
  #pragma omp parallel
  #pragma omp for reduction (task, *: j) schedule (monotonic: dynamic, 3)
  for (i = a; i < b; i += c)
    {
      j++;
      bar (&j);
    }
}
