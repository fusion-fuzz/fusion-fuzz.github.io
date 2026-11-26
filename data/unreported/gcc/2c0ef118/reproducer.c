void pragma (int ***x, float ***y, double **z)
{
  #pragma omp target \
      map(iterator(i=0:DIM1), from: z[i][:DIM2])
