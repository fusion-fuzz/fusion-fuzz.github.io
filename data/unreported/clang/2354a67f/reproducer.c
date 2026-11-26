int __builtin_abs(int m) __attribute__((overloadable, enable_if(m, "")));
int (*p)(int) = &__builtin_abs;
