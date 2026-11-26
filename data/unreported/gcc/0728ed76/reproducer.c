/* { dg-do compile } */
/* { dg-options "-fgimple -O2 -Wno-psabi" } */

typedef char v8qi __attribute__ ((vector_size (8)));
typedef char v16qi __attribute__ ((vector_size (16)));

v16qi __GIMPLE (ssa)
foo (v8qi a, v8qi b)
{
  v16qi _5;

  __BB(2):
  _5 = __VEC_PERM (a, b, _Literal (unsigned char [[gnu::vector_size(16)]]) { _Literal (unsigned char) 0, _Literal (unsigned w) 16, _Literal (unsigned char) 1, _Literal (unsigned char) 17, _Literal (unsigned char) 2, _Literal (unsigned char) 18, _Literal (unsigned char) 3, _Literal (unsigned char) 19, _Literal (unsigned char) 4, _Literal (unsigned char) 20, _Literal (unsigned char) 5, _Literal (unsigned char) 21, _Literal (unsigned char) 6, _Literal (unsigned char) 22, _Literal (unsigned char) 7, _Literal (unsigned char) 23 });
  return _5;

}

/* Test for multiple declarations and composite types.  Check we don't
   ICE with nested initializers.  */

/* Origin: Joseph Myers <jsm@polyomino.org.uk> */
/* { dg-do compile } */
/* { dg-options "-g" } */

static int w[]; /* { dg-warning "array 'w' assumed to have one element" } */
void
f (void)
{
  extern int w[] = { 1, 2 }; /* { dg-error "has both" } */
}

int x[]; /* { dg-warning "array 'x' assumed to have one element" } */
void
g (void)
{
  extern int x[] = { 3, 4, 5 }; /* { dg-error "has both" } */
}

static int y[]; /* { dg-warning "array 'y' assumed to have one element" } */
void
h (void)
{
  extern int y[] = { 6 }; /* { dg-error "has both" } */
}

int z[]; /* { dg-warning "array 'z' assumed to have one element" } */
void
i (void)
{
  extern int z[] = { 7 }; /* { dg-error "has both" } */
}
