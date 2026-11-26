struct S {
  ~S() {}
  int x = 0;
};
void f(S s) pre(s.x == 1) {}
int main()
{
  S s;
  f(s);
}
