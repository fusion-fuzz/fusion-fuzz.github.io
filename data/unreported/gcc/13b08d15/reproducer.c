typedef int v4si __attribute__ ((vector_size (16)));
v4si x;
void f (int i)
{
  register v4si c asm ("foo");
  c[i] = 1;
  x = c;
}
