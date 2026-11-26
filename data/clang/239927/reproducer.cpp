int f();
namespace { template <int = 0> thread_local int n = f(); }
int g() { return n<>; }
