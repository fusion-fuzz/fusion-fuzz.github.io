struct A { bool foo (); };
template <typename T>
struct S : A {
  static bool foo (decltype (T::x));
  static constexpr bool s = foo (0);
};
bool b = S<int>::s;
