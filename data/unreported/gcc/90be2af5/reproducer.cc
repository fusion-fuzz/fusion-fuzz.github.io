#include <stdarg.h>
template <int N>
struct A { };

template <int Q>
/* { dg-do compile } */



void foo(int, ...)
{
    va_list va;
    int i;
    i = va_arg(va, int&); /* { dg-error "cannot receive" } */
}
void g()
{
    const int M ( Q );

    A<M> a;
}

void h()
{
    g<3>();
}

/* { dg-do compile } */

#include <stdarg.h>

void i(int, ...)
{
    va_list va;
    int i;
    i = va_arg(va, int&); /* { dg-error "cannot receive" } */
}
