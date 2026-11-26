/* A test for final value replacement.  */

/* { dg-options "-O2 -fdump-tree-optimized" } */

int foo(void);

int bla(void)
{
  int i, j = foo ();

  for (i = 0; i < 100; i++, j++)
    foo ();

  /* Should be replaced with return j0 + 100;  */
  return j;
}
/* { dg-do compile } */
/* { dg-options "-std=gnu23" } */

void f1(int n)
{
    struct foo b();
    struct foo {
        char buf[n];
    };
    goto out;		/* { dg-error "jump into scope" } */
    typeof(b) *t;
out:
}

void f2(int n)
{
    struct foo *b[1];
    struct foo {
        char buf[n];
    };
    goto out;		/* { dg-error "jump into scope" } */
    typeof(b) *t;
out:
}

void f3(int n)
{
    struct foo (*b[1])();
    struct foo {
        char buf[n];
    };
    goto out;		/* { dg-error "jump into scope" } */
    typeof(b) *t;
out:
}

/* { dg-final { scan-tree-dump-times "\\+ 100" 1 "optimized" } } */


void f4(int n)
{
    const struct foo * const * const c;
    struct foo {
        char buf[n];
    };
    goto out;		/* { dg-error "jump into scope" } */
    typeof(c) *t;
out:
}
