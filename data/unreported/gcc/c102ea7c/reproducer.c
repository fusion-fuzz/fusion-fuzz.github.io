register int regvar asm ("ecx");

void f (int *r, int *a, int *b, int *c, int n)
{
  for (int i = 0; i < n; ++i)
    r[i] = a[i] > 20 ? b[i] << c[i] : a[i];
}
