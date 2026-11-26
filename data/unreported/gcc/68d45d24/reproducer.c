/* { dg-do compile } */
/* { dg-options "-mror -O2" } */

unsigned int rotate (unsigned int a, int b) {
  return ( a >> b ) | ( a << ( 32 - b ) );
}

/* { dg-final { scan-assembler "l.ror" } } */

/* PR rtl-optimization/127809 */
/* { dg-do compile } */
/* { dg-require-effective-target label_values } */
/* { dg-options "-Os -fno-var-tracking -fcompare-debug" } */

/* PR rtl-optimization/127809 */
/* { dg-do compile } */
/* { dg-require-effective-target label_values } */
/* { dg-options "-Os -fno-var-tracking -fcompare-debug" } */

/* When reorg deletes a label that follows a BARRIER and a block holding
   only debug insns, the code after the label is unreachable and must be
   deleted with -g as well as with -g0.  */

int h;

void
foo (int b, int c)
{
  int i = b * 3;
  void *x = &&lab;
l1:
  if (b)
    {
    lab:
      __builtin_unreachable ();
    }
  b = i;
  if (c)
    x = &&l1;
  goto *x;
}

/* When reorg deletes a label that follows a BARRIER and a block holding
   only debug insns, the code after the label is unreachable and must be
   deleted with -g as well as with -g0.  */
