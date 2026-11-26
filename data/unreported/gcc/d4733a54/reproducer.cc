template <typename T, class auto, int = 0> void foo (T, auto) {}
void bar () { foo (0, 0); }
