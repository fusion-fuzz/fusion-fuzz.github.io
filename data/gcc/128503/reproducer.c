struct D { struct b; };
struct E { struct D; };
void f6 (struct b *p);
void f7 (struct E *p) { f6 (p); }
