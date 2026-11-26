template <int N>
int fn (char (&)[N], const char *, ...) __attribute__ ((format (1, 2, 3)));
template <int N>
int fn (char (&)[N], const char *, ...) __attribute__ ((format (printf, 2, 3)));
