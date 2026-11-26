int j;

void f (void)
{
  #pragma omp target has_device_addr(j[:2])
  ;
}
