template <typename T>
struct D {
  friend T::S::~ffl_fusion();
};
struct Q {
  struct S { ~S(); };
  foo(D<Q>::secret);
}
