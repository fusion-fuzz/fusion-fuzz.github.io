typedef float v4sf __attribute__((vector_size(16)));
v4sf x1;
template <typename T> void f() { x1 % 0; }
