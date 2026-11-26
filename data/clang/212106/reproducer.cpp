struct RR { int r; };
struct Z { int x; const RR* y; int z; };
inline int f() { return 0; }
Z z2 = { 10, (const RR[1]){__builtin_constant_p(z2.x)}, z2.y->r+f() };
