union Union {
  class A {
  virtual void foo();
  };
  class B : public A {
  };
  void B::foo() {}
void uni(void (*fn)(union Union), union Union arg1) {
    fn(arg1);
}
}
