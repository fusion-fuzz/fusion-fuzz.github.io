#pragma omp declare simd linear (val (x) : step (1))	/* { dg-error "is neither constant nor a parameter" } */
int bar (int x, int y, int z);
