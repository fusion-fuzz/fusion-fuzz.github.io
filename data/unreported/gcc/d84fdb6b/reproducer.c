/* { dg-options "-O2 -ftracer -fdump-tree-tracer" } */
volatile int a, b, c;
int main ()
{
  int i;
  for (i = 0; i < 1000; i++)
    {
      if (i % 17)
	a++;
      else
	b++;
      c++;
    }
  return 0;
}
/* { dg-do compile } */
/* { dg-options "-O -floop-nest-optimize -fno-tree-loop-im" } */

int u0, l1;

void
u3 (int s1)
{
  for (;;)
    {
      for (u0 = 0; u0 < 2; ++u0)
	{
	}

      if (s1 != 0)
	for (l1 = 0; l1 < 2; ++l1)
	  {
	  }

      l1 = 0;
    }
}
/* Superblock formation should produce two copies of the increment of c */
/* { dg-final-generate { scan-tree-dump-times "c =" 2 "tracer" } } */
