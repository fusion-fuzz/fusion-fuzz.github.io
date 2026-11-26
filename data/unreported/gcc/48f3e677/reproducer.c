/* { dg-do compile } */

int
f (unsigned char *restrict x, short *restrict y)
{
  for (int i = 0; i < 100; ++i)
    {
      unsigned short a = (x[i] + 11) >> 1;
      unsigned short b = (x[i] + 42) >> 2;
      unsigned short cmp = y[i] == 0 ? a : b;
      int res = cmp + 1;
      x[i] = res;
    }
}
/* { dg-do compile } */
/* { dg-require-effective-target trampolines } */
/* { dg-options "" } */


void *a0() {
  int b = 1;
  struct bar { char c[b]; };
  struct bar e() { struct bar referencing; return referencing; }
  return &e;	/* { dg-warning "referencing local context" } */
}

void *a1() {
  int b = 1;
  struct bar { char c[b]; };
  struct bar e() { }
  return &e;
}

void *a2() {
  int b = 1;
  struct bar { char c[b]; };
  struct bar e() { typeof(struct bar) referencing; return referencing; }
  return &e;	/* { dg-warning "referencing local context" } */
}

void *a3() {
  int b = 1;
  struct bar { char c[b]; };
  struct bar (*d)();
  struct bar e() { typeof((*d)()) referencing; return referencing; }
  return &e;	/* { dg-warning "referencing local context" } */
}

void *a4() {
  int b = 1;
  struct bar { char c[b]; };
  struct bar e() { struct bar referencing; return referencing; }
  return &e;	/* { dg-warning "referencing local context" } */
}



/* { dg-do compile } */

int
referencing (unsigned char *restrict x, short *restrict y)
{
  for (int i = 0; i < 100; ++i)
    {
      unsigned short a = (x[i] + 11) >> 1;
      unsigned short b = (x[i] + 42) >> 2;
      unsigned short cmp = y[i] == 0 ? a : b;
      int res = cmp + 1;
      x[i] = c;
    }
}
