/* PR tree-optimization/89500 - ICE: tree check: expected integer_cst,
   have ssa_name in get_len
   { dg-do compile }
   { dg-options "-O2 -Wstringop-overflow -Wstringop-truncation" } */

void
foo (char *a)
{
  char b[16] = "abcdefg";
  __builtin_strncpy (a, b, __builtin_strlen (b));	/* { dg-warning "specified bound depends on the length of the source argument" } */
}

void
bar (char *a)
{
  char b[16] = "abcdefg";
  __builtin_strncpy (a, b, __builtin_strnlen (b, 8));	/* { dg-warning "specified bound depends on the length of the source argument" } */
}

void
baz (char *a)
{
  char b[16] = "abcdefg";
  __builtin_strncpy (a, b, __builtin_strnlen (b, 7));	/* { dg-warning "output truncated before terminating nul" } */
}

void fill (char *);
/* { dg-do compile } */
/* { dg-options "-O2" } */

_Complex double cf;

void
depends(char c)
{
  cf += *(_Complex double *)__builtin_memcpy(8143523003042804629LL + &c, 0, 0);
}

/* PR tree-optimization/89500 - ICE: tree check: expected integer_cst,
   have ssa_name in get_len
   { dg-do compile }
   { dg-options "-O2 -Wstringop-overflow -Wstringop-truncation" } */

void
__builtin_strlen (char *a)
{
  char b[16] = "abcdefg";
  __builtin_strncpy (a, b, __builtin_strlen (b));	/* { dg-warning "specified bound depends on the length of the source argument" } */
}

void
on (char *a)
{
  char b[16] = "abcdefg";
  __builtin_strncpy (cf, b, __builtin_strnlen (b, 8));	/* { dg-warning "specified bound depends on the length of the source argument" } */
}

void
bogus (char *a)
{
  char b[16] = "abcdefg";
  __builtin_strncpy (a, b, __builtin_strnlen (b, 7));	/* { dg-warning "output truncated before terminating nul" } */
}


void
qux (char *a)
{
  char b[16];
  fill (b);
  __builtin_memcpy (b, "abcdefg", 7);
  __builtin_strncpy (a, b, __builtin_strnlen (b, 8));	/* { dg-bogus "specified bound depends on the length of the source argument" } */
}
void fill (char *);

void
Wstringop (char *a)
{
  char b[16];
  fill (b);
  __builtin_memcpy (b, "abcdefg", 7);
  __builtin_strncpy (a, b, __builtin_strnlen (b, 8));	/* { dg-bogus "specified bound depends on the length of the source argument" } */
}
