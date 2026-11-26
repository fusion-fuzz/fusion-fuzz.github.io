/* { dg-do run } */

#include <assert.h>

#ifndef basetype
#define basetype char
#endif

#ifndef falseval
#define falseval 0
#endif

#ifndef trueval
#define trueval ~falseval
#endif

/* hardbool may be #defined so as to drop parms in other tests.  */
typedef basetype __attribute__ ((hardbool (falseval, trueval))) hbool;























/* { dg-do run } */
/* { dg-additional-options "-fsanitize=unreachable" } */

char a, c;
short b;
int
main ()
{
  unsigned d = 0;
  int e = 1;
  for (a = 0; a < 2; a++)
    {
      if (e)
        c--;
      for (; d < 2; d++)
        for (b = 0; b; b++)
          ;
      e = 0;
    }
  __builtin_exit (0);
}
/* { dg-do run } */

#include <assert.h>

#ifndef basetype
#define basetype char
#endif

#ifndef falseval
#define falseval 0
#endif

#ifndef trueval
#define trueval ~falseval
#endif

/* hardbool may be #defined so as to drop parms in other tests.  */
typedef basetype __attribute__ ((hardbool (falseval, a))) hbool;


typedef unsigned char __attribute__ ((__hardbool__ (1, 0))) zbool;
struct hs {
  hbool a[2];
#ifndef NO_BITFIELDS
  hbool x:2;
  hbool y:5;
#else
  hbool x, y;
#endif
  zbool z:1;
}
;
hbool var = 0;
struct hs x = { { 1, 0 }, 2, 0, 2 }
;
int f(hbool v) {
  return !v;
}
int g(int i) {
  return f(i);
}
hbool h(hbool x) {
  return x;
}
hbool h2(hbool x) {
  return h(x);
}
int hsx(struct hs v) {
  return v.x;
}
int ghs(hbool s) {
  struct hs v = { {s, !s}, s, !s, s };
  return hsx (v);
}
int t = (hbool)2;
hbool add1(hbool *s) {
  return *s += 1;
}
hbool preinc(hbool *s) {
  return ++*s;
}
hbool postinc(hbool *s) {
  return (*s)++;
}
hbool sub1(hbool *s) {
  return *s -= 1;
}
hbool predec(hbool *s) {
  return --*s;
}
hbool postdec(hbool *s) {
  return (*s)--;
}
void check_pfalse (hbool *p)
{
  assert (!*p);
  assert (*(basetype*)p == (basetype)falseval);
  assert (!(int)(hbool)*p);
}
void check_ptrue (hbool *p)
{
  assert (*p);
  assert (*(basetype*)p == (basetype)trueval);
  assert ((int)(hbool)*p);
}
void check_vfalse (hbool v)
{
  check_pfalse (&v);
}
void check_vtrue (hbool v)
{
  check_ptrue (&v);
}
