typedef int V __attribute__ ((vector_size (16)));
V v;
int *f (void)
{
  return &v[1];
}
