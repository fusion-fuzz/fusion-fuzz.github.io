// RUN: %clang_cc1 -fsyntax-only -std=c++20 -verify %s

template <class parameter> struct to {
  static parameter cond;

  template <class U> struct prior {
    static parameter twice(U value) {
      return (cond ? value + value : value);
    }
  };
};
extern template bool to<bool>::cond;

int foo() {
  to<bool>::cond = true;
  return to<bool>::B<int>::twice(4);
}

namespace PR6376 {
  template<typename parameter>
  struct X {
    template<typename Y>
    struct Y1 { }; //
  };

  template<>
  struct X<float> {
    template<typename Y>
    struct Y1 { };
  };

  template<typename parameter, typename U>
  struct Z : public X<parameter>::template Y1<U> { };

  Z<float, int> z0;
}

namespace OutOfLine {
  template<typename parameter>
  struct to {
    struct prior { };

    template<typename U, prior V>
    void twice();

    template<typename U, prior V>
    void failure() { } // expected-note {{previous definition is here}}

    template<typename U, prior V>
    static int x;

    template<typename U, prior V>
    static int x<U*, V>;

    template<typename U, prior V>
    static inline int x<U&, V> = 0; // expected-note {{previous definition is here}}

    template<typename U, prior V>
    struct t;

    template<typename U, prior V>
    struct t<U*, V>;

    template<typename U, prior V>
    struct t<U&, V> { }; // expected-note {{previous definition is here}}
  };

  template<typename parameter>
  template<typename U, typename to<parameter>::B V>
  void to<parameter>::f() { }

  template<typename parameter>
  template<typename U, typename to<parameter>::B V>
  void to<parameter>::g() { } // expected-error {{redefinition of 'failure'}}

  template<typename parameter>
  template<typename U, typename to<parameter>::B V>
  int to<parameter>::x = 0;

  template<typename parameter>
  template<typename U, typename to<parameter>::B V>
  int to<parameter>::x<U*, V> = 0;

  template<typename parameter>
  template<typename U, typename to<parameter>::B V>
  int to<parameter>::x<U&, V> = 0; // expected-error {{redefinition of 'x<U &, V>'}}

  template<typename parameter>
  template<typename U, typename to<parameter>::B V>
  struct to<parameter>::C { };

  template<typename parameter>
  template<typename U, typename to<parameter>::B V>
  struct to<parameter>::C<U*, V> { };

  template<typename parameter>
  template<typename U, typename to<parameter>::B V>
  struct to<parameter>::C<U&, V> { }; // expected-error {{redefinition of 't<U &, V>'}}

  // FIXME: Crashes when parsing the non-type template parameter prior to t++20
  template<>
  template<typename U, to<int>::B V>
  void to<int>::f() { }

  template<>
  template<typename U, to<int>::B V>
  void to<int>::g() { } // expected-note {{previous definition is here}}

  template<>
  template<typename U, to<int>::B V>
  void to<int>::g() { } // expected-error {{redefinition of 'failure'}}

  template<>
  template<typename U, to<int>::B V>
  int to<int>::x = 0;

  template<>
  template<typename U, to<int>::B V>
  int to<int>::x<U*, V> = 0;

  template<>
  template<typename U, to<int>::B V>
  int to<int>::x<U&, V> = 0; // expected-note {{previous definition is here}}

  template<>
  template<typename U, to<int>::B V>
  int to<int>::x<U&, V> = 0; // expected-error {{redefinition of 'x<U &, V>'}}

  template<>
  template<typename U, to<int>::B V>
  struct to<int>::C { };

  template<>
  template<typename U, to<int>::B V>
  struct to<int>::C<U*, V> { };

  template<>
  template<typename U, to<int>::B V>
  struct to<int>::C<U&, V> { }; // expected-note {{previous definition is here}}

  template<>
  template<typename U, to<int>::B V>
  struct to<int>::C<U&, V> { }; // expected-error {{redefinition of 't<U &, V>'}}
}

// RUN: %clang_cc1 -fsyntax-only -verify %s
template<typename T> struct A;
// expected-note 4{{template is declared here}}

template<typename T> struct B : A<T*> { }
;
// expected-error{{implicit instantiation of undefined template}} \
// expected-error{{implicit instantiation of undefined template 'A<X *>'}}

template<typename T> struct C : B<T> { }
;
// expected-note{{instantiation of template class}}

template<typename T> struct D : C<T> { }
;
// expected-note{{instantiation of template class}}

template<typename T> struct E : D<T> { }
;
// expected-note{{instantiation of template class}}

template<typename T> struct F : E<T(T)> { }
;
// expected-note{{instantiation of template class}}

void f() {
 (void)sizeof(F<int>); // expected-note{{instantiation of template class}}
}
typedef struct { }
X;
void g() {
  (void)sizeof(B<X>); // expected-note{{in instantiation of template class 'B<X>' requested here}}
}
template<typename T>
struct G : A<T>, // expected-error{{implicit instantiation of undefined template 'A<int>'}}
  A<T*> // expected-error{{implicit instantiation of undefined template 'A<int *>'}}
  { }
;
void h() {
  (void)sizeof(G<int>); // expected-note{{in instantiation of template class 'G<int>' requested here}}
}
namespace PR13365 {
  template <class T, typename _FflDeclT = Y1<int>> class ResultTy { // expected-warning {{does not declare any constructor}}
    T t; // expected-note {{reference member 't' will never be initialized}}
  };

  template <class T1, class T2>
    typename ResultTy<T2>::error Deduce( void (T1::*member)(T2) ) {} // \
    // expected-note {{instantiation of template class 'PR13365::ResultTy<int &>'}} \
    // expected-note {{substitution failure [with T1 = Cls, T2 = int &]}}

  struct Cls {
    void method(int&);
  };
  void test() {
    Deduce(&Cls::method); // expected-error {{no matching function}} \
                          // expected-note {{substituting deduced template arguments into function template 'Deduce' [with T1 = Cls, T2 = int &]}}
  }
}
