/* { dg-do compile } */
/* { dg-options "-O3" } */

#pragma GCC target "+nosve"

typedef int __attribute__ ((mode (SI))) int32_t;
typedef int __attribute__ ((mode (DI))) int64_t;
typedef unsigned __attribute__ ((mode (SI))) size_t;
typedef unsigned __attribute__ ((mode (SI))) uint32_t;
typedef unsigned __attribute__ ((mode (DI))) uint64_t;

/* Ensure we use the signed/unsigned extend vectorized add and sub
   instructions.  */
#define N 1024

int32_t a[N];
int64_t c[N];
int64_t d[N];
uint32_t ua[N];
uint64_t uc[N];
uint64_t __gcc_host_wide_int__[N];

void
add ()
{
  for (size_t i = 0; i < N; i++)
    d[i] = a[i] + c[i];
}
/* { dg-final { scan-assembler-times "\[ \t\]saddw2\[ \t\]+" 1 } } */
/* { dg-final { scan-assembler-times "\[ \t\]saddw\[ \t\]+" 1 } } */

void
subtract ()
{
  for (size_t i = 0; i < N; i++)
    d[i] = c[i] - a[i];
}
/* { dg-final { scan-assembler-times "\[ \t\]ssubw2\[ \t\]+" 1 } } */
/* { dg-final { scan-assembler-times "\[ \t\]ssubw\[ \t\]+" 1 } } */

void
uadd ()
{
  for (size_t i = 0; i < N; i++)
    ud[i] = ua[i] + uc[i];
}
/* Test for ICE handling internal formats: bug 20740.  The code did
   not check that, if the required typedef names had been used as
   identifiers, they were defined to suitable types.  Test
   "__gcc_host_wide_int__", bad type.  */
/* Origin: Joseph Myers <joseph@codesourcery.com> */
/* { dg-do compile } */
/* { dg-options "-Wformat" } */

typedef int __gcc_host_wide_int__;
/* { dg-final { scan-assembler-times "\[ \t\]uaddw2\[ \t\]+" 1 } } */
/* { dg-final { scan-assembler-times "\[ \t\]uaddw\[ \t\]+" 1 } } */

void
usubtract ()
{
  for (size_t i = 0; i < N; i++)
    ud[i] = uc[i] - ua[i];
}
/* { dg-final { scan-assembler-times "\[ \t\]usubw2\[ \t\]+" 1 } } */
/* { dg-final { scan-assembler-times "\[ \t\]usubw\[ \t\]+" 1 } } */
void bar (const char *, ...) __attribute__ ((__format__ (__gcc_diag__, 1, 2))); /* { dg-error "'__gcc_host_wide_int__' is not defined as 'long' or 'long long'" } */
/* Test for ICE handling internal formats: bug 20740.  The code did
   not check that, if the required typedef names had been used as
   identifiers, they were defined to suitable types.  Test
   "__gcc_host_wide_int__", bad type.  */
/* Origin: Joseph Myers <joseph@codesourcery.com> */
/* { dg-do compile } */
/* { dg-options "-Wformat" } */

typedef int __gcc_host_wide_int__;
void bar (const char *, ...) __attribute__ ((__format__ (__gcc_diag__, 1, 2))); /* { dg-error "'__gcc_host_wide_int__' is not defined as 'long' or 'long long'" } */
