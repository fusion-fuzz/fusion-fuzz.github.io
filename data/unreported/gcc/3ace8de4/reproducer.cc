static inline __attribute__((gnu_inline)) int foo ();
int bar () { return foo (); }
int foo () { return 0; }
