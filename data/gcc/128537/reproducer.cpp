typedef int vec __attribute__ ((vector_size (8)));
constexpr vec v = { 1, 2 };
bool f (int a, int *res)
{
  return __builtin_sub_overflow (a, v, res);
}
