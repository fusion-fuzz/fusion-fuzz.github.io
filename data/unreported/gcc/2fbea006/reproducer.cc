void fn (int);
template <class F>
auto f (F fn)
{
  return [fn{fn}] (auto a) requires requires { fn (a); } { return 0; };
}
int x = f ([] (int) { }) (1);
