template <class T> struct Foo {
};
template <class T> struct Bar : public Foo<T>, Baz {
  using Foo<T>::k;
  using Baz::k;
  int foo() {
    return k (1.0f);
  }
};
