struct S { constexpr operator int () const { return 1; } };
constexpr S s;
template <int> struct A { enum E { e = s }; };
A<0> a;
