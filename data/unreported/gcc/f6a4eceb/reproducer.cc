struct Foo { virtual ~Foo () = default; };

template <int>
void f ()
{
  constexpr Foo foo{};
}

template void f<0> ();
