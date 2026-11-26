typedef long long v8i64 __attribute__((vector_size(64)));
typedef long long v4i64 __attribute__((vector_size(32)));
void f(const v8i64 *pa, const v8i64 *pb, v8i64 *po) {
  v8i64 a = *pa, b = *pb;
  v8i64 t2 = b & a;
  v4i64 t3 = __builtin_shufflevector(t2, t2, 4, 5, 2, 7);
  v8i64 t5 = __builtin_shufflevector(t3, t3, 0, 1, 2, 3, 4, 5, 6, 7);
  v8i64 t10 = __builtin_shufflevector(a, b, 4, -1, 9, 11, 10, 13, 4, 0);
  v8i64 t11 = __builtin_elementwise_max(t5, t10);
  *po = t11 ^ t5;
}
