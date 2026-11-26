struct A
{
  int& x;
template <int>
foo (int j)
{
  auto [j] = A{j};	// { dg-error "shadows a parameter" }
}
bar ()
{
  foo<0> (0);
