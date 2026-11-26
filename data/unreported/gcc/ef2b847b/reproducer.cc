export module M;
namespace { int x; }
template <typename T> struct vec { int f () { return x; } };
struct D : vec<int> {};
int g (D d) { return d.f (); }
