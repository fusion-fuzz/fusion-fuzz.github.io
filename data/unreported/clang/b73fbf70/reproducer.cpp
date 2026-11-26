template <class T> int f() { return test<T>(); }
void test();
template <class T> int test();
int x = f<int>();
