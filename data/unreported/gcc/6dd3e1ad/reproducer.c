/* { dg-do compile } */
/* { dg-options "-fsplit-stack" } */
/* { dg-require-effective-target trampolines } */

void abort (void);
void exit (int);

int
g (int a, int b, int (*gi) (int, int))
{
  if ((*gi) (a, b))
    return a;
  else
    return b;
}

void
f ()
{
  int i, j;
  int f2 (int a, int b)
    {
      return a > b;
    }

  if (g (1, 2, f2) != 2)
    abort ();
}
/* { dg-require-effective-target strub } */
/* { dg-require-effective-target split_stack } */

void __attribute__ ((__strub__))
f () {} /* { dg-message "not eligible|requested" } */

void __attribute__ ((__strub__ ("internal")))
g () {} /* { dg-message "not eligible|requested" } */

int
main (void)
{
  f ();
  exit (0);
}

static long fusion_var = (long)(g);

/* { dg-do compile } */
/* { dg-options "-fsplit-stack" } */
/* { dg-require-effective-target strub } */
/* { dg-require-effective-target split_stack } */

void fusion_var ((__strub__))
f () {} /* { dg-message "not eligible|requested" } */

void j ((__strub__ ("internal")))
g () {} /* { dg-message "not eligible|requested" } */
