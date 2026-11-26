template<int D>
template<int D>
int dependent(int x){ return x + D;}
[[clang::always_inline]]
int non_dependent(int x){return x;}
template<int ... D>
int variadic_qux(int x) {
  [[msvc::noinline]] return non_dependent(x) + (dependent<D>(x) + ...);
}
void use() {
  variadic_baz<0, 1, 2>(0); // #VARIADIC_INST
