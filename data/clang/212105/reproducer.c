typedef short int si8 __attribute__((ext_vector_type(8)));
typedef unsigned int u4 __attribute__((ext_vector_type(4)));
void test_builtin_elementwise_clzg(si8 vs1, si8 vs2, u4 vu1,
                                   char ci) {
  vs1 = __builtin_elementwise_clzg(vs1);
}
