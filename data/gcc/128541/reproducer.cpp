template <class T> struct S { template <class U> __attribute__((target("avx"))) void f (); };
template <class T> template <class U> __attribute__((target("avx512f"))) void S<T>::f () {}
