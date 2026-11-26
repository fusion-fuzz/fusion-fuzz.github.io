/* { dg-lto-do run } */
/* { dg-skip-if "x86 only" { ! { x86_64-*-* i?86-*-* } } } */
/* { dg-skip-if "no .type" { *-*-darwin* } } */
/* { dg-skip-if "no @function" { *-*-mingw* *-*-cygwin* } } */

/* Doesn't work without this dummy function with -fwhopr.  */
int foo(void) { }

asm(".text\n"
    ".globl main\n"
    "\t.type main,@function\n"
    "main:\n"
    "\txorl %eax, %eax\n"
    "\tret\n");
/* PR tree-optimization/109583 */
/* { dg-do compile } */
/* { dg-options "-O1 -Wno-psabi" } */
/* { dg-additional-options "-mno-avx" { target i?86-*-* x86_64-*-* } } */

typedef float v8sf __attribute__((vector_size (8 * sizeof (float))));
typedef int v8si __attribute__((vector_size (8 * sizeof (int))));

#if __SIZEOF_INT__ == __SIZEOF_FLOAT__
v8sf
main (v8sf x, v8sf y)
{
  v8sf a = x - y;
  v8sf b = x + y;
  return __builtin_shuffle (a, b, (v8si) { 0, 9, 2, 11, 4, 13, 6, 15 });
}

v8sf
bar (v8sf x, v8sf y)
{
  v8sf a = x + y;
  v8sf b = x - y;
  return __builtin_shuffle (a, b, (v8si) { 0, 9, 2, 11, 4, 13, 6, 15 });
}
#endif
