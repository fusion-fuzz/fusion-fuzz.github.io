// RUN: %clang_cc1 -std=c++11 %s -verify

using size_t = decltype(sizeof(int));
// expected-error {{template}}
template<typename T> T operator ""_b(const char *);
template<typename T> struct U {
  friend int operator ""_a(const char *, size_t);
  // FIXME: It's not entirely clear whether this is intended to be legal.
  friend U operator ""_a(const T *, size_t); // expected-error {{parameter}}
}
template<char...> struct V {
  friend void operator ""_b(); // expected-error {{parameters}}
}
template<char...> struct S {}
// expected-error {{template}}
template<typename T> int operator ""_b(const T *, size_t);
// expected-error {{template}}
// expected-error {{template}}
template<char, char...> void operator ""_b();
template<char...> void operator ""_a();
template<char... C> S<C...> operator ""_a();
;
;
;
;
;
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: getTypeInfoImpl
// EXPECT-CRASH-ASSERT: EltInfo.Width
// EXPECT-CRASH-ASSERT: Overflow

template <unsigned Size> struct S_ffl {
  double A[Size];
}
template <unsigned Size> struct SS {
  S_ffl<Size> A[Size];
}
void T() { SS<-123> ss; }
template<char... C, int N = 0> void operator ""_b();
// expected-error {{template}}
template<char... C> void operator ""_b(int N = 0);