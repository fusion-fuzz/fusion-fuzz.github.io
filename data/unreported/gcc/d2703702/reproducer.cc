/* PR91038 */
/* { dg-do run } */
/* { dg-options "-O2 -Wunused-variable" } */



void foo(void)
{
	if (2 * sizeof(int) != sizeof((*({ int N = 2; int (*x)[9][N] = 0; x; })[1])))
		__builtin_abort();
}
// { dg-do compile }

void bar(void)
{
	if (2 * sizeof(int) != sizeof((*({ int N = 2; int (*x)[9][N] = 0; x; })[0])))
		__builtin_abort();
}

void bar0(void)
{
	if (2 * 9 *  sizeof(int) != sizeof((*({ int N = 2; int (*x)[9][N] = 0; x; }))))
		__builtin_abort();
}

void bar11(void)
{
	sizeof(*((*({ int N = 2; int (*x)[9][N] = 0; x; }) + 0)));
}

void bar12(void)
{
	if (2 * sizeof(int) != sizeof(*((*({ int N = 2; int (*x)[9][N] = 0; x; })    ))))
		__builtin_abort();
}

void bar1(void)
{
	if (2 * sizeof(int) != sizeof(*((*({ int N = 2; int (*x)[9][N] = 0; x; }) + 0))))
		__builtin_abort();
}




int main()
{
	foo();
	bar0();
	bar12();
	bar1();
	bar();
}


// Copyright (C) 2003 Free Software Foundation, Inc.
// Contributed by Nathan Sidwell 5 Sep 2003 <nathan@codesourcery.com>
// Origin:Wolfgang Bangerth bangerth@dealii.org

// PR c++/12167 - infinite recursion

typedef int int32_t __attribute__((mode (__SI__)));
typedef unsigned uint32_t __attribute__((mode (__SI__)));

class A {   
  void report(int32_t d
	      // the default arg is what NAN etc can expand to, but
	      // with the floatiness removed.
	      = (__extension__ ((union { uint32_t l; int32_t d; })
				{ l: 0x7fc00000U }).d));
};
