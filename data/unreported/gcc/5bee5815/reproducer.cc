/* { dg-do run }  */
/* { dg-require-ifunc "" } */
/* { dg-require-effective-target pie } */
/* { dg-options "-fpie -pie" } */

#include <stdio.h>

static int __attribute__((noinline))
implementation (void)
{
  printf ("'ere I am JH\n");
  return 0;
}

static __typeof__ (implementation) *resolver (void)
{
  return (void *)implementation;
}

extern int magic (void) __attribute__ ((ifunc ("resolver")));

__attribute__ ((weak))
int
call_magic (int (*ptr) (void))
{
  return ptr ();
}

int main ()
{
  return call_magic (magic);
}

// PR c++/88061
// { dg-do compile { target { c++11 && named_sections } } }

template<class T>
int* fun() {
  [[gnu::section(".foo")]] static int var;
  return &var;
};

template int* fun<int>();

// { dg-final { scan-assembler {\.(section|csect)[ \t]+"?\.foo} } }
