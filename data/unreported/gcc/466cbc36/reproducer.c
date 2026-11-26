void abort (void);
void exit (int);

long double
ll_to_ld (long long n)
{
  return n;
}

long long
ld_to_ll (long double n)
{
  return n;
}

int
main (void)
{
  long long n;

  if (ll_to_ld (10LL) != 10.0)
    abort ();

  if (ld_to_ll (10.0) != 10)
    abort ();

  exit (0);
}
/* { dg-do compile { target { ! ia32 } } } */
/* { dg-options "-O2 -ffixed-rax -ffixed-rbx -ffixed-rcx -ffixed-rdx -ffixed-rdi -ffixed-rsi -mindirect-branch-cs-prefix -mindirect-branch=thunk-extern" } */
/* { dg-additional-options "-fno-pic" { target { ! *-*-darwin* } } } */

extern void (*fptr) (void);

void
foo (void)
{
  fptr ();
}

/* { dg-final { scan-assembler-times "jmp\[ \t\]+_?__x86_indirect_thunk_r\[0-9\]+" 1 } } */
/* { dg-final { scan-assembler-times "\tcs" 1 } } */
