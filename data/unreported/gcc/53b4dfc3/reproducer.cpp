struct S { __attribute__((aligned (1 << 28))) double a; };
void f (int, int, int, int, int, int, int, struct S);
void g (struct S *p) { f (0, 1, 2, 3, 4, 5, 6, *p); }
