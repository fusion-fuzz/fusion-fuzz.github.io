class A {
  virtual int foo ();
};
class B : A {
  template <typename> void foo ();
  class foo {};
};
