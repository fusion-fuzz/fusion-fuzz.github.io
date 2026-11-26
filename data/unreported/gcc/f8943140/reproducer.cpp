typedef float v2sf __attribute__ ((vector_size (8)));
struct D { ~D (); };
float foo (v2sf a) { D d; return a[0] + a[1]; }
