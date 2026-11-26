/* { dg-do compile } */
/* { dg-options "-O2" } */

int
foo (int x)
{
  asm goto ("" : : "r" (x), "r" (x + 1), "r" (x + 2), "r" (x + 3), /* { dg-error "operand has impossible constraints" } */
	    "r" (x + 4), "r" (x + 5), "r" (x + 6), "r" (x + 7),
	    "r" (x + 8), "r" (x + 9), "r" (x + 10), "r" (x + 11),
	    "r" (x + 12), "r" (x + 13), "r" (x + 14), "r" (x + 15) : : lab);
 lab:
  return 0;
}
/* { dg-do compile } */
/* { dg-options "-O2 -fdump-tree-optimized" } */

#define REGISTER register

#if defined __arm__
# define REG1 asm("r4")
#elif defined __i386__
# define REG1 asm("ebx")
#elif defined __mips__
# define REG1 asm("s0")
#elif defined __x86_64__
# define REG1 asm("rbp")
#else
# undef REGISTER
# define REGISTER
# define REG1
#endif

REGISTER long data_0 REG1;
long data_3; 

long number(long data, long v)
{
	long i;
	long t, u;

	if (data)
		i = data_0 + data_3;
	else {
		v = 2;
		i = 5;
	}
	t = data_0 + data_3;
	u = i;
	return v * t * u;
}

/* We should not eliminate global register variable when it is the RHS of
   a single assignment.  So the number of loads from data_0 has to match
   that of the number of adds (we hoist data_0 + data_3 above the
   if (data) and eliminate the useless copy).  */

/* { dg-final { scan-tree-dump-times "= data_0;" 1 "optimized" { target { arm*-*-* i?86-*-* mips*-*-* x86_64-*-* } } } } */
/* { dg-final { scan-tree-dump-times " \\+ " 1 "optimized" { target { ! { arm*-*-* i?86-*-* mips*-*-* x86_64-*-* } } } } } */
