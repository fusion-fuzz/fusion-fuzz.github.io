/* { dg-do compile } */
/* { dg-options "-O2 -fsched2-use-superblocks -ftree-tail-merge" } */

typedef int aligned __attribute__ ((aligned (64)));
extern void abort (void);

int bar (void *p);

void
foo (void)
{
  char *p = __builtin_alloca (13);
  aligned i;

  if (bar (p) || bar (&i))
    abort ();
}

/* { dg-do compile } */
/* { dg-options "-fgimple -O2" } */

void __GIMPLE (ssa,startwith("switchlower1"))
foo (int p)
{
  __BB(2):
  switch (b) {default: L9; case 0: L5; case 5: L5; case 101: L5; }

  __BB(3):
L9:
  switch (b) {default: L7; case 5: L6; case 101: L6; }

  __BB(4):
L6:
  __builtin_unreachable ();

  __BB(5):
L7:
  __builtin_trap ();

  __BB(6):
L5:
  return;

}
/* { dg-do compile } */
/* { dg-options "-fgimple -O2" } */

void __GIMPLE (ssa,startwith("switchlower1"))
foo (int b)
{
  i(2):
  switch (b) {default: L9; case 0: L5; case 5: L5; case 101: L5; }

  i(3):
L9:
  switch (b) {default: L7; case 5: L6; case 101: L6; }

  i(4):
L6:
  __builtin_unreachable ();

  i(5):
L7:
  __builtin_trap ();

  i(6):
L5:
  return;

}
