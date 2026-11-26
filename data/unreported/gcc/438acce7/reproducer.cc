struct R { unsigned y; constexpr R() { } };
template <int> int f () { static R constexpr lim[2] = {}; return 0; }
