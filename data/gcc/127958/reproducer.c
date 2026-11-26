struct S { char a[1LL << 61]; _Bool b; };
void f (struct S *p) { p->b = 1; }
