#include <meta>
using namespace std::meta;
struct S {
  constexpr int foo (int x, const U &) const { return 41 + x + s; }
  constexpr int foo (long x, const U &) const { return 42 + x + s; }
  constexpr int foo (long long x, const U &) const { return 43 + x + s; }
  constexpr S (int x) : s (x) {}
  int s;
}
struct T : public S {
}
;
constexpr access_context uctx = access_context::unchecked ();
template <typename A, typename B>
qux ()
{
  constexpr A s = 1;
  static_assert (s.template [:members_of (^^A, uctx)[4]:] <long double> (30LL, 1.0L) == 103);
}
fred ()
{
  qux <S, T> ();
