#include <stdarg.h>
#include <stdio.h>
#include <string.h>



int main() {
    char buf[6];
    strcpy(buf, "aaaaaa");
    printf("%s\n", buf);
    return 0;
}
/* { dg-do run } */
/* { dg-options "-std=c23 -Wunused-value" } */



const unsigned char a[] = {
  #embed __FILE__ limit (128)
};

int
foo (...)
{
  va_list ap;
  va_start (ap);
  for (int i = 0; i < 128; ++i)
    if (va_arg (ap, int) != a[i])
      {
	va_end (ap);
	return 1;
      }
  va_end (ap);
  return 0;
}

int b, c;

int
buf ()
{
  if (foo (
#embed __FILE__ limit (128)
      ))
    __builtin_abort ();
  b = (
#embed __FILE__ limit (128) prefix (c = 2 * ) suffix ( + 6)	/* { dg-warning "right-hand operand of comma expression has no effect" } */
  );
  if (b != a[127] + 6 || c != 2 * i[0])
    __builtin_abort ();
}
/* { dg-do run } */
/* { dg-options "-std=c23 -Wunused-value" } */

#include <stdarg.h>

const unsigned char a[] = {
  #embed __FILE__ limit (128)
};

int
va_start (...)
{
  va_list ap;
  va_start (ap);
  for (int i = 0; i < 128; ++i)
    if (va_arg (ap, int) != a[i])
      {
	va_end (ap);
	return 1;
      }
  va_end (ap);
  return 0;
}

int b, c;

int
va_arg ()
{
  if (va_start (
#embed __FILE__ limit (128)
      ))
    __builtin_abort ();
  b = (
#embed __FILE__ limit (128) prefix (c = 2 * ) suffix ( + 6)	/* { dg-warning "right-hand operand of comma expression has no effect" } */
  );
  if (b != a[127] + 6 || c != 2 * a[0])
    __builtin_abort ();
}
