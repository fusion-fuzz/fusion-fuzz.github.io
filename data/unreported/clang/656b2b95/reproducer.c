typedef int v8i32 __attribute__((ext_vector_type(8)));

void f(v8i32 v) { asm("" : : "y"(v)); }
