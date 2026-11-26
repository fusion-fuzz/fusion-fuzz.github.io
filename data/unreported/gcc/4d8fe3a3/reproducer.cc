struct B { void foo (); };

template <typename T>
struct S : B {
  static bool foo (decltype (bar (T {})));
  static constexpr bool s = foo (0);
};

void baz () { S<int>::s; }
