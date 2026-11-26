  template <typename T> struct A {
    struct B {
      template <typename U> struct X {};
    };
    struct C {
      typedef B::X<typename B::arg> x; // precxx17-warning{{missing 'typename' prior to dependent type name 'B::X' is a C++20 extension}}
    };
  };
  template <> struct A<int>::B {
  };
  A<int>::C::x a;
