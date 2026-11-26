struct E;
struct A { E e; };

template <typename... T>
void foo (T...);

void f ()
{
  template for (auto [...e] : A ())
    foo (e...);
}
