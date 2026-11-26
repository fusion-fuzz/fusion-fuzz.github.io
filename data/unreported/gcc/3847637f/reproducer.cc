int ay;
unsigned hb(unsigned i) { return ~i; }
template<typename T>
void aq(int i)
{
  auto l = [ay]() { return T(2 * hb(i)); }; // { dg-bogus "in boolean context" }
}
int main()
{
  aq<bool>(0);
}
