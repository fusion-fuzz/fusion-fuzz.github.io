void f (int *x, float *y, double *z)
{
  #pragma omp target map(iterator(i3=0:10, j3=0:20, k3=0:30), to: z[i3+j3], y[j3+k3], z[k3+i3])
