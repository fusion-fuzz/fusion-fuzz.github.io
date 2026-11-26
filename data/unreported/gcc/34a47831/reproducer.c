[[omp::directive (begin declare variant match (d={target}))]];
#pragma omp end declare variant  /* { dg-error "'begin declare variant' in attribute syntax terminated with 'end declare variant' in pragma syntax" } */
