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

long foo(long data, long v)
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
/* PR rtl-optimization/69891 */
/* { dg-do run } */
/* { dg-options "-O -fno-tree-fre -mstringop-strategy=libcall -Wno-psabi" } */
/* { dg-additional-options "-mno-sse" { target ia32 } } */

typedef unsigned short A;
typedef unsigned short B __attribute__ ((vector_size (32)));
typedef unsigned int C;
typedef unsigned int D __attribute__ ((vector_size (32)));
typedef unsigned long long E;
typedef unsigned long long F __attribute__ ((vector_size (32)));

__attribute__((noinline, noclone)) unsigned
copy(D a, B b, D c, F d)
{
  b /= (B) {1, -c[0]} | 1;
  c[0] |= 7;
  a %= c | 1;
  c ^= c;
  return a[0] + b[15] + c[0] + d[3];
}

/* We should not eliminate global register variable when it is the RHS of
   a single assignment.  So the number of loads from data_0 has to match
   that of the number of adds (we hoist data_0 + data_3 above the
   if (data) and eliminate the useless copy).  */

/* { dg-final { scan-tree-dump-times "= data_0;" 1 "optimized" { target { arm*-*-* i?86-*-* mips*-*-* x86_64-*-* } } } } */
/* { dg-final { scan-tree-dump-times " \\+ " 1 "optimized" { target { ! { arm*-*-* i?86-*-* mips*-*-* x86_64-*-* } } } } } */

int
main ()
{
  unsigned x = copy ((D) {}, (B) {}, (D) {}, (F) {});
  if (x != 0)
    __builtin_abort ();
  return 0;
}
