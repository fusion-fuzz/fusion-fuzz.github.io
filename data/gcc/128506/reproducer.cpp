int S, s;
template<auto ns>
void h ()
{
  namespace A = [:ns:];
  S < A::template X > s;
}
