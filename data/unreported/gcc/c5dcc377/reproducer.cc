struct NonTrivial {
  NonTrivial () {}
}
struct Elem {
  NonTrivial n;
}
struct Bug {
  bool flag{true};
  Elem arr[2]{};
}
res (Bug *p)
{
  *p = {};
  *p = {};
