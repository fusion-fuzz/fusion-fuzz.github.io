template<typename T> typename T::X v1;
struct A { constexpr A(int) { } };
template<A> struct B { };
B<v1> *p;
