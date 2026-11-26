template<typename>
struct test {
  friend int foo(bool = true) { return 1; }
  friend int foo(bool);
};
template struct test<bool>;
template struct test<int>;
