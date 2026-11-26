struct b {};
struct S3 {
  template<class> struct B : b { B() noexcept(b); };
  struct A : B<int> { A() : B() {} };
};
