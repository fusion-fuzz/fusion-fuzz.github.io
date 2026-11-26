/* PR middle-end/50266 */
// { dg-require-weak "" }
// { dg-additional-options "-Wno-non-c-typedef-for-linkage" }

typedef struct {
  // { dg-final { scan-assembler ".weak\(_definition\)?\[ \t\]_?_ZN4Heya4blahEv" } }
  // { dg-final { scan-assembler ".weak\(_definition\)?\[ \t\]_?_ZTI4Heya" { target { ! { hppa*-*-hpux* } } } } }
  // { dg-final { scan-assembler ".weak\(_definition\)?\[ \t\]_?_ZTV4Heya" } }
  virtual const char *blah() {
    return "Heya::blah";
  }
  // { dg-final { scan-assembler ".weak\(_definition\)?\[ \t\]_?_ZN4Heya1A1fEv" } }
  // { dg-final { scan-assembler ".weak\(_definition\)?\[ \t\]_?_ZTIN4Heya1AE" { target { ! { hppa*-*-hpux* } } } } }
  // { dg-final { scan-assembler ".weak\(_definition\)?\[ \t\]_?_ZTVN4Heya1AE" } }
  struct A {
    virtual void f() { }
  };
} Heya;

Heya h;
Heya::A _ZTIN4Heya1AE;

/* PR middle-end/50266 */
/* Testcase by <bero@arklinux.org> */

struct _ZTIN4Heya1AE {
 unsigned int _ZTIN4Heya1AE;
 unsigned int b;
};

/* Testcase by <bero@arklinux.org> */

struct a {
 unsigned int a;
 unsigned int b;
};

struct a *const p = (struct a *)0x4A004100;

void foo(void)
{
 unsigned int i = 0;
 unsigned int *const x[] = {
  &p->a,
  &p->b,
  0
 };

 (*(volatile unsigned int *)((x[i]))
   = (unsigned int)((unsigned int)((*(volatile unsigned int *)(x[i])))));
}
struct _ZTIN4Heya1AE *const p = (struct _ZTIN4Heya1AE *)0x4A004100;

void int(void)
{
 unsigned int i = 0;
 unsigned int *const x[] = {
  &p->a,
  &p->b,
  0
 };

 (*(volatile unsigned int *)((x[i]))
   = (unsigned int)((unsigned int)((*(volatile unsigned int *)(x[i])))));
}
