template <int> struct T { int x; void g () { [*this] (this auto) { [&] { x; }; }; } };
template struct T<0>;
