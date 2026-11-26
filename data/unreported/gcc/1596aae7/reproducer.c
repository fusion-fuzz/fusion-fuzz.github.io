/* PR c++/57945 */
/* { dg-do compile } */
/* { dg-options "-O3 -mavx512fp16 -mavx512vl -mprefer-vector-width=128" } */

/* Check that we vectorize to a full 128-bit vector for _Float16 types.  */

void
foo (_Float16 *__restrict__ a, _Float16 *__restrict__ b,
     _Float16 *__restrict__ c)
{
  for (int i = 0; i < 128; i++)
    a[i] = b[i] - c[i];
}

/* { dg-final { scan-assembler-times "vsubph" 16 } } */

/* PR c++/57945 */
/* { dg-do compile } */

extern int j;
static int i __attribute__((weakref("i")));
/* { dg-error "PTX does not support weak declarations" "" { target nvptx-*-* } .-1 } */

/* { dg-do compile } */

extern int j;
static int i __attribute__((weakref("j")));
/* { dg-error "PTX does not support weak declarations" "" { target nvptx-*-* } .-1 } */

int
foo (void)
{
  return &i ? i : 0;
}
int
foo (void)
{
  return &i ? i : 0;
}
