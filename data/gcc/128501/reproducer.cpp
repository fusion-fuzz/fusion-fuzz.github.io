export module foo;
namespace ns { typedef int T; }
constexpr int f () { using ns::T; return 0; }
