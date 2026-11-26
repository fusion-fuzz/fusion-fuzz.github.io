using FourLongLong = long long __attribute__((ext_vector_type(4)));
int *f(FourLongLong v) { return v.operator int*(); }
