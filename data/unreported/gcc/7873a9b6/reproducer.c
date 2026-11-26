/* PR target/106550 */
/* { dg-require-effective-target power10_ok } */
/* { dg-require-effective-target has_arch_ppc64 } */
/* { dg-options "-O2 -mdejagnu-cpu=power10 -fdisable-rtl-split1" } */
/* force the constant splitter run after RA: -fdisable-rtl-split1.  */


/* { dg-final { scan-assembler-times {\mpli\M} 3 } } */
/* { dg-final { scan-assembler-times {\msldi\M} 3 } } */
/* { dg-final { scan-assembler-times {\moris\M} 2 } } */
/* { dg-final { scan-assembler-times {\mori\M} 2 } } */

/* PR tree-optimization/106433 */
/* { dg-require-effective-target avx512f { target x86 } } */

int m, *p;

/* PR target/106550 */
/* { dg-require-effective-target power10_ok } */
/* { dg-require-effective-target has_arch_ppc64 } */
/* { dg-options "-O2 -mdejagnu-cpu=power10 -fdisable-rtl-split1" } */
/* force the constant splitter run after RA: -fdisable-rtl-split1.  */


__attribute__ ((simd,noipa)) int
bar (int x)
{
  if (x)
    {
      if (m < 1)
        for (m = 0; m < 1; ++m)
          ++x;
      p = &x;
      for (;;)
        ++m;
    }
  return 0;
}

__attribute__ ((simd)) int
foo (int x)
{
  return bar (x);
}
/* { dg-final { scan-assembler-times {\mpli\M} 3 } } */
/* { dg-final { scan-assembler-times {\msldi\M} 3 } } */
/* { dg-final { scan-assembler-times {\moris\M} 2 } } */
/* { dg-final { scan-assembler-times {\mori\M} 2 } } */
