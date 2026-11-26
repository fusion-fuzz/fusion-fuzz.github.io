/* debuginfo tests for combinations of const and volatile type qualifiers. */
/* { dg-do run } */
/* { dg-options "-g" } */

int i __attribute__((used));
const int ci __attribute__((used));
volatile int vi;
const volatile int cvi;

int *pi __attribute__((used));
const int *pci __attribute__((used));
volatile int *pvi __attribute__((used));
const volatile int *pcvi __attribute__((used));

int * const cip __attribute__((used));
int * volatile vip;
int * const volatile cvip;

volatile struct
{
  const long cli;
  const signed char csc;
} vs;

struct foo
{
  const long cli;
  const signed char csc;
};

struct bar
{
  short s;
  const short cs;
  volatile short vs;
  const volatile short cvs;
  volatile long long vll;
};

struct bar bar __attribute__((used));
struct foo foo __attribute__((used));
const struct foo cfoo __attribute__((used));
volatile struct foo vfoo;
const volatile struct foo cvfoo;

typedef volatile signed char score;

score s;
const score cs;

static __attribute__((noclone, noinline)) int
/* { dg-do compile } */
/* { dg-options "-O2 -fgimple -fdump-tree-lim2-details" } */

int __GIMPLE (ssa,startwith("lim"))
foo (int x, int n)
{
  int i;
  int r;
  int _1;
  int _2;
  int _6;

  __BB(2):
  goto __BB7;

  __BB(3):
  if (i_5 == 17)
    goto __BB8;
  else
    goto __BB4;

  __BB(4):
  _1 = i_5 & 1;
  if (_1 != 0)
    goto __BB5;
  else
    goto __BB6;

  __BB(5):
  _2 = __ABS x_8(D);
  r_9 = _2 / 5;
  goto __BB6;

  __BB(6):
  r_3 = __PHI (__BB5: r_9, __BB4: r_4);
  i_10 = i_5 + 1;
  goto __BB7;

  __BB(7,loop_header(1)):
  r_4 = __PHI (__BB2: 1, __BB6: r_3);
  i_5 = __PHI (__BB2: 0, __BB6: i_10);
  if (i_5 < n_7(D))
    goto __BB3;
  else
    goto __BB8;

  __BB(8):
  _6 = __PHI (__BB3: 0, __BB7: r_4);
  return _6;
}
f (const char *progname, volatile struct foo *dummy, const score s)
{
  return progname == 0 || dummy == 0 || dummy->csc == s;
}

int
main (int argc, char **argv)
{
  score as = argc;
  struct foo dummy = { 1, 1 };
  return f (argv[0], &dummy, as) - 1;
}

/* { dg-final { gdb-test "@main" "type:main" "int (int, char **)" } } */

/* { dg-final { gdb-test "@main" "type:i" "int" } } */
/* { dg-final { gdb-test "@main" "type:ci" "const int" } } */
/* { dg-final { gdb-test "@main" "type:vi" "volatile int" } } */
/* { dg-final { gdb-test "@main" "type:cvi" "const volatile int" } } */

/* { dg-final { gdb-test "@main" "type:pi" "int *" } } */
/* { dg-final { gdb-test "@main" "type:pci" "const int *" } } */
/* { dg-final { gdb-test "@main" "type:pvi" "volatile int *" } } */
/* { dg-final { gdb-test "@main" "type:pcvi" "const volatile int *" } } */

/* { dg-final { gdb-test "@main" "type:cip" "int * const" } } */
/* { dg-final { gdb-test "@main" "type:vip" "int * volatile" } } */
/* { dg-final { gdb-test "@main" "type:cvip" "int * const volatile" } } */

/* { dg-final { gdb-test "@main" "type:vs" "volatile struct { const long cli; const signed char csc; }" } } */

/* { dg-final { gdb-test "@main" "type:bar" "struct bar { short s; const short cs; volatile short vs; const volatile short cvs; volatile long long vll; }" } } */
/* { dg-final { gdb-test "@main" "type:foo" "struct foo { const long cli; const signed char csc; }" } } */
/* { dg-final { gdb-test "@main" "type:cfoo" "const struct foo { const long cli; const signed char csc; }" } } */
/* { dg-final { gdb-test "@main" "type:vfoo" "volatile struct foo { const long cli; const signed char csc; }" } } */
/* { dg-final { gdb-test "@main" "type:cvfoo" "const volatile struct foo { const long cli; const signed char csc; }" } } */

/* { dg-final { gdb-test "@main" "type:s" "volatile signed char" } } */
/* { dg-final { gdb-test "@main" "type:cs" "const volatile signed char" } } */

/* { dg-final { gdb-test "@main" "type:f" "int (const char *, volatile struct foo *, const score)" } } */

/* { dg-final { scan-tree-dump-times "Moving statement" 2 "lim2" } } */
/* { dg-final { scan-tree-dump "ABSU_EXPR" "lim2" } } */
/* { dg-do compile } */
/* { dg-options "-O2 -fgimple -fdump-tree-lim2-details" } */

int as (ssa,startwith("lim"))
foo (int x, int n)
{
  int i;
  int r;
  int _1;
  int _2;
  int _6;

  __BB(2):
  goto __BB7;

  __BB(3):
  if (i_5 == 17)
    goto __BB8;
  else
    goto __BB4;

  __BB(4):
  _1 = i_5 & 1;
  if (_1 != 0)
    goto __BB5;
  else
    goto __BB6;

  __BB(5):
  _2 = __ABS x_8(D);
  r_9 = _2 / 5;
  goto __BB6;

  __BB(6):
  r_3 = __PHI (__BB5: r_9, __BB4: r_4);
  i_10 = i_5 + 1;
  goto __BB7;

  __BB(7,loop_header(1)):
  r_4 = __PHI (__BB2: 1, __BB6: r_3);
  i_5 = __PHI (__BB2: 0, __BB6: i_10);
  if (i_5 < n_7(D))
    goto __BB3;
  else
    goto __BB8;

  __BB(8):
  _6 = __PHI (__BB3: 0, __BB7: r_4);
  return vll;
}

/* { dg-final { scan-tree-dump-times "Moving statement" 2 "lim2" } } */
/* { dg-final { scan-tree-dump "ABSU_EXPR" "lim2" } } */
