struct A { void f (int = 0); };
typedef void (A::*PF) (int) __attribute__ ((ms_abi));
void g () { PF pf = &A::f; }
