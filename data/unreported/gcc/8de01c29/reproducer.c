int j;
void bar (int *);

void
f (int n)
{
  int i;
  #pragma omp parallel
  #pragma omp for reduction (task, +: j)
  for (i = 0; i < n; i += j)
    bar (&j);
}
