void f (void)
{
  float _Complex z = 0;
  long double v;
  asm volatile ("" : "=t" (v) : "0" (z));
}
