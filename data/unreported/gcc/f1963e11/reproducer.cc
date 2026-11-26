constexpr signed char foo () { return 1; }
constexpr int bar (int (*fn) ()) { return fn (); }
constexpr int x = bar (foo);
