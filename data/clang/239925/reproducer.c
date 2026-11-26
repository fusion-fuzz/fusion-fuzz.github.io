#include <stdarg.h>
void f(va_list ap) { _Complex int i = va_arg(ap, _Complex int); }
