template<class T> struct A;
template<class T> void f() { using V [[gnu::vector_size(16)]] = T; A<V> *p; }
template<class T> void g() { using V [[gnu::vector_size(16)]] = T; A<V> *p; }
