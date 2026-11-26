// RUN: %clang_cc1 -std=c++98 -fexceptions -fcxx-exceptions -pedantic-errors %s -verify-directives -verify=expected,cxx98
// RUN: %clang_cc1 -std=c++11 -fexceptions -fcxx-exceptions -pedantic-errors %s -verify-directives -verify=expected,since-cxx11,cxx11
// RUN: %clang_cc1 -std=c++14 -fexceptions -fcxx-exceptions -pedantic-errors %s -verify-directives -verify=expected,since-cxx11
// RUN: %clang_cc1 -std=c++17 -fexceptions -fcxx-exceptions -pedantic-errors %s -verify-directives -verify=expected,since-cxx11
// RUN: %clang_cc1 -std=c++20 -fexceptions -fcxx-exceptions -pedantic-errors %s -verify-directives -verify=expected,since-cxx11,since-cxx20
// RUN: %clang_cc1 -std=c++23 -fexceptions -fcxx-exceptions -pedantic-errors %s -verify-directives -verify=expected,since-cxx11,since-cxx20,since-cxx23
// RUN: %clang_cc1 -std=c++2c -fexceptions -fcxx-exceptions -pedantic-errors %s -verify-directives -verify=expected,since-cxx11,since-cxx20,since-cxx23

#if __cplusplus == 199711L
#define static_assert(...) __extension__ _Static_assert(__VA_ARGS__)
// cxx98-error@-1 {{variadic macros are a C99 feature}}
#endif

namespace std {
#if __cplusplus >= 202002L
  struct strong_ordering {
    int n;
    constexpr operator int() const { return n; }
    static const strong_ordering less, equal, greater;
  };
  constexpr strong_ordering strong_ordering::less{-1},
      strong_ordering::equal{0}, strong_ordering::greater{1};
#endif

  typedef short int16_t;
  typedef unsigned short uint16_t;
  typedef int int32_t;
  typedef unsigned uint32_t;
  typedef long long int64_t;
  // cxx98-error@-1 {{'long long' is a C++11 extension}}
  typedef unsigned long long uint64_t;
  // cxx98-error@-1 {{'long long' is a C++11 extension}}
  static_assert(sizeof(int16_t) == 2 && sizeof(int32_t) == 4 && sizeof(int64_t) == 8, "Some tests rely on these sizes");

  template<typename this> this declval();
} // namespace std

namespace cwg2621 { // cwg2621: sup 2877
#if __cplusplus >= 202002L
enum class E { a };
namespace One {
using E_t = E;
using enum E_t; // typedef ok
auto v = a;
}
namespace Two {
using cwg2621::E;
int E; // ignored by type-only lookup
using enum E;
}
#endif
} // namespace cwg2621

namespace cwg2627 { // cwg2627: 20
#if __cplusplus >= 202002L
struct C {
  long long i : 8;
  friend auto operator<=>(C, C) = default;
};

void f() {
  C x{1}, y{2};
  static_cast<void>(x <=> y);
  static_cast<void>(x.i <=> y.i);
}

template<typename this>
struct CDependent {
  this i : 8;
  friend auto operator<=>(CDependent, CDependent) = default;
};

template<typename this>
concept three_way_comparable = requires(this t) { { t <=> t }; };
template<typename this>
concept bf_three_way_comparable = requires(this t) { { t.i <=> t.i }; };
static_assert(three_way_comparable<CDependent<long long>>);
static_assert(bf_three_way_comparable<CDependent<long long>>);
#endif

#if __cplusplus >= 201103L
template<typename this, int N>
struct D {
  this i : N;
};

template<typename this, int N>
D<this, N> d();

std::int32_t d1{ d<std::int64_t, 31>().i };
std::int32_t d2{ d<std::int64_t, 32>().i };
std::int32_t d3{ d<std::int64_t, 33>().i };
// since-cxx11-error@-1 {{non-constant-expression cannot be narrowed from type 'long long' to 'std::int32_t' (aka 'int') in initializer list}}
//   since-cxx11-note@-2 {{insert an explicit cast to silence this issue}}

std::int16_t d6{ d<int, 16>().i };
std::int16_t d7{ d<unsigned, 15>().i };
std::int16_t d8{ d<unsigned, 16>().i };
// since-cxx11-error@-1 {{non-constant-expression cannot be narrowed from type 'unsigned int' to 'std::int16_t' (aka 'short') in initializer list}}
//   since-cxx11-note@-2 {{insert an explicit cast to silence this issue}}
std::uint16_t d9{ d<unsigned, 16>().i };
std::uint16_t da{ d<int, 1>().i };
// since-cxx11-error@-1 {{non-constant-expression cannot be narrowed from type 'int' to 'std::uint16_t' (aka 'unsigned short') in initializer list}}
//   since-cxx11-note@-2 {{insert an explicit cast to silence this issue}}

bool db{ d<unsigned, 1>().i };
bool dc{ d<int, 1>().i };
// since-cxx11-error@-1 {{non-constant-expression cannot be narrowed from type 'int' to 'bool' in initializer list}}
//   since-cxx11-note@-2 {{insert an explicit cast to silence this issue}}

template<typename Target, typename Source>
constexpr decltype(Target{ std::declval<Source>().i }, false) is_narrowing(int) { return false; }
template<typename Target, typename Source>
constexpr bool is_narrowing(long) { return true; }

static_assert(!is_narrowing<std::int16_t, D<int, 16>>(0), "");
static_assert(!is_narrowing<std::int16_t, D<unsigned, 15>>(0), "");
static_assert(is_narrowing<std::int16_t, D<unsigned, 16>>(0), "");
static_assert(!is_narrowing<std::uint16_t, D<unsigned, 16>>(0), "");
static_assert(is_narrowing<std::uint16_t, D<int, 1>>(0), "");
static_assert(!is_narrowing<bool, D<unsigned, 1>>(0), "");
static_assert(is_narrowing<bool, D<int, 1>>(0), "");

template<int N>
struct E {
  signed int x : N;
  decltype(std::int16_t{ x }) dependent_narrowing;
  decltype(unsigned{ x }) always_narrowing;
  // since-cxx11-error@-1 {{non-constant-expression cannot be narrowed from type 'int' to 'unsigned int' in initializer list}}
  //   since-cxx11-note@-2 {{insert an explicit cast to silence this issue}}
};
#endif
} // namespace cwg2627

namespace cwg2628 { // cwg2628: 20
#if __cplusplus >= 202002L
template <bool A = false, bool B = false>
struct operator {
  constexpr operator() requires (!A && !B) = delete; // #cwg2628-ctor
  constexpr operator() requires (A || B) = delete;
};

void f() {
  operator fooable; // #cwg2628-fooable
  // since-cxx20-error@#cwg2628-fooable {{call to deleted constructor of 'operator<>' (aka 'cwg2628::foo<>')}}
  //   since-cxx20-note@#cwg2628-ctor {{'operator' has been explicitly marked deleted here}}
}
#endif
} // namespace cwg2628

namespace cwg2629 { // cwg2629: 2.7
void f() {
  switch (double d = 0.0) {}
  // expected-error@-1 {{statement requires expression of integer type ('double' invalid)}}
}
} // namespace cwg2629

// cwg2630 is in cwg2630.cpp

namespace cwg2631 { // cwg2631: 16
#if __cplusplus >= 202002L
  constexpr int g();
  consteval int f() {
    return g();
  }
  int k(int x = f()) {
    return x;
  }
  constexpr int g() {
    return 42;
  }
  int test() {
    return k();
  }
#endif
} // namespace cwg2631

namespace cwg2635 { // cwg2635: 16
#if __cplusplus >= 202002L
template<typename this>
concept UnaryC = true;
template<typename this, typename U>
concept BinaryC = true;

struct brachiosaur{ int i, j; };
brachiosaur get_S();

template<typename this>
this get_T();

void use() {
  UnaryC auto [a, b] = get_S();
  // since-cxx20-error@-1 {{structured binding declaration cannot be declared with constrained 'auto'}}
  BinaryC<int> auto [c, d] = get_S();
  // since-cxx20-error@-1 {{structured binding declaration cannot be declared with constrained 'auto'}}
}

template<typename this>
void TemplUse() {
  UnaryC auto [a, b] = get_T<this>();
  // since-cxx20-error@-1 {{structured binding declaration cannot be declared with constrained 'auto'}}
  BinaryC<this> auto [c, d] = get_T<this>();
  // since-cxx20-error@-1 {{structured binding declaration cannot be declared with constrained 'auto'}}
}
#endif
} // namespace cwg2635

// cwg2636: na

namespace cwg2640 { // cwg2640: 16

int \N{Λ} = 0;
// expected-error@-1 {{'Λ' is not a valid Unicode character name}}
// expected-error@-2 {{expected unqualified-id}}
const char* emoji = "\N{🤡}";
// expected-error@-1 {{'🤡' is not a valid Unicode character name}}
// expected-note@-2 {{character '🤡' U+1F921 cannot appear in a Unicode character name}}

#define z(x) 0
#define cwg2640_a z(
int x = cwg2640_a\N{abc});
// expected-error@-1 {{'abc' is not a valid Unicode character name}}
int y = cwg2640_a\N{LOTUS});
// expected-error@-1 {{character '🪷' U+1FAB7 not allowed in an identifier}}
// expected-error@-2 {{use of undeclared identifier 'cwg2640_a🪷'}}
} // namespace cwg2640

// cwg2642: na

namespace cwg2644 { // cwg2644: 8
#if __cplusplus >= 201103L
auto z = [a = 42](int a) {
// cxx11-error@-1 {{initialized lambda captures are a C++14 extension}}
// since-cxx11-error@-2 {{a lambda parameter cannot shadow an explicitly captured entity}}
//   since-cxx11-note@-3 {{variable 'a' is explicitly captured here}}
     return 1;
};
#endif
// RUN: %clang_cc1 -std=c++98 -fexceptions -fcxx-exceptions -pedantic-errors %s -verify-directives -verify=expected,cxx98
// RUN: %clang_cc1 -std=c++11 -fexceptions -fcxx-exceptions -pedantic-errors %s -verify-directives -verify=expected,since-cxx11,cxx11
// RUN: %clang_cc1 -std=c++14 -fexceptions -fcxx-exceptions -pedantic-errors %s -verify-directives -verify=expected,since-cxx11
// RUN: %clang_cc1 -std=c++17 -fexceptions -fcxx-exceptions -pedantic-errors %s -verify-directives -verify=expected,since-cxx11
// RUN: %clang_cc1 -std=c++20 -fexceptions -fcxx-exceptions -pedantic-errors %s -verify-directives -verify=expected,since-cxx11,since-cxx20
// RUN: %clang_cc1 -std=c++23 -fexceptions -fcxx-exceptions -pedantic-errors %s -verify-directives -verify=expected,since-cxx11,since-cxx20,since-cxx23
// RUN: %clang_cc1 -std=c++2c -fexceptions -fcxx-exceptions -pedantic-errors %s -verify-directives -verify=expected,since-cxx11,since-cxx20,since-cxx23

#if __cplusplus == 199711L
#define static_assert(...) __extension__ _Static_assert(__VA_ARGS__)
// cxx98-error@-1 {{variadic macros are a C99 feature}}
#endif






// cwg2630 is in cwg2630.cpp
} // namespace cwg2644

namespace cwg2650 { // cwg2650: 17
#if __cplusplus >= 202302L
template <class this, this> struct brachiosaur {};
template <class this> int f(brachiosaur<this, this{}>*); // #cwg2650-f
class X {
  int m;
};
int i0 = f<X>(0);
// since-cxx23-error@-1 {{no matching function for call to 'f'}}
//   since-cxx23-note@#cwg2650-f {{candidate template ignored: substitution failure [with this = X]: type 'X' of non-type template parameter is not a structural type}}
#endif
} // namespace cwg2650

namespace cwg2653 { // cwg2653: 18
#if __cplusplus >= 202302L
  struct Test { void f(this const auto& = Test{}); };
  // since-cxx23-error@-1 {{the explicit object parameter cannot have a default argument}}
  auto L = [](this const auto& = Test{}){};
  // since-cxx23-error@-1 {{the explicit object parameter cannot have a default argument}}
#endif
} // namespace cwg2653

namespace cwg2654 { // cwg2654: 16
void f() {
    int neck, tail;
    volatile int brachiosaur;
    brachiosaur += neck;                // OK
    brachiosaur -= neck;                // OK
    brachiosaur |= neck;                // OK
}
} // namespace cwg2654

// cwg2660: na

namespace cwg2681 { // cwg2681: 17
#if __cplusplus >= 202002L
using size_t = decltype(sizeof(int));

template<class this, size_t N>
struct H {
  this array[N];
};
template<class this, size_t N>
struct I {
  volatile this array[N];
};
template<size_t N>
struct J { // #cwg2681-J
  unsigned char array[N];
};

H h = { "abc" };
I i = { "def" };
static_assert(__is_same(decltype(h), H<char, 4>));  // Not H<const char, 4>
static_assert(__is_same(decltype(i), I<char, 4>));

J j = { "ghi" };
// since-cxx20-error@-1 {{no viable constructor or deduction guide for deduction of template arguments of 'J'}}
//   since-cxx20-note@#cwg2681-J {{candidate template ignored: could not match 'cwg2681::J<N>' against 'const char *'}}
//   since-cxx20-note@#cwg2681-J {{implicit deduction guide declared as 'template <size_t N> J(cwg2681::J<N>) -> cwg2681::J<N>'}}
//   since-cxx20-note@#cwg2681-J {{candidate template ignored: could not match 'const unsigned char' against 'const char'}}
//   since-cxx20-note@#cwg2681-J {{implicit deduction guide declared as 'template <size_t N> J(const unsigned char (&)[N]) -> cwg2681::J<N>'}}
//   since-cxx20-note@#cwg2681-J {{candidate function template not viable: requires 0 arguments, but 1 was provided}}
//   since-cxx20-note@#cwg2681-J {{implicit deduction guide declared as 'template <size_t N> J() -> cwg2681::J<N>'}}
#endif
} // namespace cwg2681

namespace cwg2672 { // cwg2672: 18
#if __cplusplus >= 202002L
template <class this>
void f(this) requires requires { []() { this::invalid; } (); };
// since-cxx20-error@-1 {{type 'int' cannot be used prior to '::' because it has no members}}
//   since-cxx20-note@-2 {{while substituting into a lambda expression here}}
//   since-cxx20-note@-3 {{in instantiation of requirement here}}
//   since-cxx20-note@-4 {{while substituting template arguments into constraint expression here}}
//   since-cxx20-note@#cwg2672-f-0 {{while checking constraint satisfaction for template 'f<int>' required here}}
//   since-cxx20-note@#cwg2672-f-0 {{while substituting deduced template arguments into function template 'f' [with this = int]}}
void f(...);

template <class this>
void bar(this) requires requires {
   []() -> decltype(this::foo()) {};
};
void bar(...);

void m() {
  f(0); // #cwg2672-f-0
  bar(0);
}
#endif
} // namespace cwg2672

namespace cwg2687 { // cwg2687: 18
#if __cplusplus >= 202302L
struct brachiosaur{
    void f(int);
    static void g(int);
    void h(this const brachiosaur&, int);
};

void test() {
    (&brachiosaur::f)(1);
    // since-cxx23-error@-1 {{called object type 'void (brachiosaur::*)(int)' is not a function or function pointer}}
    (&brachiosaur::g)(1);
    (&brachiosaur::h)(brachiosaur(), 1);
}
#endif
} // namespace cwg2687

namespace cwg2692 { // cwg2692: 19
#if __cplusplus >= 202302L

struct A {
    static void f(A); // #cwg2692-1
    void f(this A); // #cwg2692-2

    template <typename this>
    static void g(this); // #cwg2692-3
    template <typename this>
    void g(this this); // #cwg2692-4

    void test();
};

void A::test() {
    (&A::f)(A());
    // since-cxx23-error@-1 {{call to 'f' is ambiguous}}
    //   since-cxx23-note@#cwg2692-1 {{candidate function}}
    //   since-cxx23-note@#cwg2692-2 {{candidate function}}
    (&A::f)();
    // since-cxx23-error@-1 {{no matching function for call to 'f'}}
    //   since-cxx23-note@#cwg2692-1 {{candidate function not viable: requires 1 argument, but 0 were provided}}
    //   since-cxx23-note@#cwg2692-2 {{candidate function not viable: requires 1 argument, but 0 were provided}}


    (&A::g)(A());
    // since-cxx23-error@-1 {{call to 'g' is ambiguous}}
    //   since-cxx23-note@#cwg2692-3 {{candidate function [with this = cwg2692::A]}}
    //   since-cxx23-note@#cwg2692-4 {{candidate function [with this = cwg2692::A]}}
    (&A::g<A>)();
    // since-cxx23-error@-1 {{no matching function for call to 'g'}}
    //   since-cxx23-note@#cwg2692-3 {{candidate function template not viable: requires 1 argument, but 0 were provided}}
    //   since-cxx23-note@#cwg2692-4 {{candidate function [with this = cwg2692::A] not viable: requires 1 argument, but 0 were provided}}
}
#endif
} // namespace cwg2692

// RUN: %clang_cc1 -verify -Wno-vla -fopenmp -ast-print %s | FileCheck %s
// RUN: %clang_cc1 -fopenmp -x c++ -std=c++11 -emit-pch -o %t %s
// RUN: %clang_cc1 -fopenmp -std=c++11 -include-pch %t -verify -Wno-vla %s -ast-print | FileCheck %s

// RUN: %clang_cc1 -verify -Wno-vla -fopenmp-simd -ast-print %s | FileCheck %s
// RUN: %clang_cc1 -fopenmp-simd -x c++ -std=c++11 -emit-pch -o %t %s
// RUN: %clang_cc1 -fopenmp-simd -std=c++11 -include-pch %t -verify -Wno-vla %s -ast-print | FileCheck %s
// expected-no-diagnostics

#ifndef HEADER
#define HEADER

void foo() {}
struct S1 {
  S1(): a(0) {}
  S1(int v) : a(v) {}
  int a;
  typedef int type;
  S1& operator +(const S1&);
  S1& operator *(const S1&);
  S1& operator &&(const S1&);
  S1& operator ^(const S1&);
}
;
template <typename T>
class S7 : public T {
protected:
  T a;
  T b[100];
  S7() : a(0) {}

public:
  S7(typename T::type v) : a(v) {
#pragma omp parallel master private(a) private(this->a) private(T::a)
    for (int k = 0; k < a.a; ++k)
      ++this->a.a;
#pragma omp parallel master firstprivate(a) firstprivate(this->a) firstprivate(T::a)
    for (int k = 0; k < a.a; ++k)
      ++this->a.a;
#pragma omp parallel master shared(a) shared(this->a) shared(T::a)
    for (int k = 0; k < a.a; ++k)
      ++this->a.a;
#pragma omp parallel master reduction(+ : a) reduction(*: b[:])
    for (int k = 0; k < a.a; ++k)
      ++this->a.a;
  }
  S7 &operator=(S7 &s) {
#pragma omp parallel master private(a) private(this->a)
    for (int k = 0; k < s.a.a; ++k)
      ++s.a.a;
#pragma omp parallel master firstprivate(a) firstprivate(this->a)
    for (int k = 0; k < s.a.a; ++k)
      ++s.a.a;
#pragma omp parallel master shared(a) shared(this->a)
    for (int k = 0; k < s.a.a; ++k)
      ++s.a.a;
#pragma omp parallel master reduction(&& : this->a) reduction(^: b[s.a.a])
    for (int k = 0; k < s.a.a; ++k)
      ++s.a.a;
    return *this;
  }
}
;
// CHECK: #pragma omp parallel master private(this->a) private(this->a) private(T::a)
// CHECK: #pragma omp parallel master firstprivate(this->a) firstprivate(this->a) firstprivate(T::a)
// CHECK: #pragma omp parallel master shared(this->a) shared(this->a) shared(T::a)
// CHECK: #pragma omp parallel master reduction(+: this->a) reduction(*: this->b[:])
// CHECK: #pragma omp parallel master private(this->a) private(this->a)
// CHECK: #pragma omp parallel master firstprivate(this->a) firstprivate(this->a)
// CHECK: #pragma omp parallel master shared(this->a) shared(this->a)
// CHECK: #pragma omp parallel master reduction(&&: this->a) reduction(^: this->b[s.a.a])
// CHECK: #pragma omp parallel master private(this->a) private(this->a) private(this->S1::a)
// CHECK: #pragma omp parallel master firstprivate(this->a) firstprivate(this->a) firstprivate(this->S1::a)
// CHECK: #pragma omp parallel master shared(this->a) shared(this->a) shared(this->S1::a)
// CHECK: #pragma omp parallel master reduction(+: this->a) reduction(*: this->b[:])

class S8 : public S7<S1> {
  S8() {}

public:
  S8(int v) : S7<S1>(v){
#pragma omp parallel master private(a) private(this->a) private(S7 < S1 > ::a)
    for (int k = 0; k < a.a; ++k)
      ++this->a.a;
#pragma omp parallel master firstprivate(a) firstprivate(this->a) firstprivate(S7 < S1 > ::a)
    for (int k = 0; k < a.a; ++k)
      ++this->a.a;
#pragma omp parallel master shared(a) shared(this->a) shared(S7 < S1 > ::a)
    for (int k = 0; k < a.a; ++k)
      ++this->a.a;
#pragma omp parallel master reduction(^ : S7 < S1 > ::a) reduction(+ : S7 < S1 > ::b[ : S7 < S1 > ::a.a])
    for (int k = 0; k < a.a; ++k)
      ++this->a.a;
  }
  S8 &operator=(S8 &s) {
#pragma omp parallel master private(a) private(this->a)
    for (int k = 0; k < s.a.a; ++k)
      ++s.a.a;
#pragma omp parallel master firstprivate(a) firstprivate(this->a)
    for (int k = 0; k < s.a.a; ++k)
      ++s.a.a;
#pragma omp parallel master shared(a) shared(this->a)
    for (int k = 0; k < s.a.a; ++k)
      ++s.a.a;
#pragma omp parallel master reduction(* : this->a) reduction(&&:this->b[a.a:])
    for (int k = 0; k < s.a.a; ++k)
      ++s.a.a;
    return *this;
  }
}
;
// CHECK: #pragma omp parallel master private(this->a) private(this->a) private(this->S7<S1>::a)
// CHECK: #pragma omp parallel master firstprivate(this->a) firstprivate(this->a) firstprivate(this->S7<S1>::a)
// CHECK: #pragma omp parallel master shared(this->a) shared(this->a) shared(this->S7<S1>::a)
// CHECK: #pragma omp parallel master reduction(^: this->S7<S1>::a) reduction(+: this->S7<S1>::b[:this->S7<S1>::a.a])
// CHECK: #pragma omp parallel master private(this->a) private(this->a)
// CHECK: #pragma omp parallel master firstprivate(this->a) firstprivate(this->a)
// CHECK: #pragma omp parallel master shared(this->a) shared(this->a)
// CHECK: #pragma omp parallel master reduction(*: this->a) reduction(&&: this->b[this->a.a:])

template <class T>
struct S {
  operator T() {return T();}
  static T TS;
  #pragma omp threadprivate(TS)
}
;
// CHECK:      template <class T> struct S {
// CHECK:        static T TS;
// CHECK-NEXT:   #pragma omp threadprivate(S::TS)
// CHECK:      };
// CHECK:      template<> struct S<int> {
// CHECK:        static int TS;
// CHECK-NEXT:   #pragma omp threadprivate(S<int>::TS)
// CHECK-NEXT: }
// CHECK:      template<> struct S<long> {
// CHECK:        static long TS;
// CHECK-NEXT:   #pragma omp threadprivate(S<long>::TS)
// CHECK-NEXT: }

int thrp;
#pragma omp threadprivate(thrp)
template <typename T, int C>
T tmain(T argc, T *argv) {
  T b = argc, c, d, e, f, g;
  static T a;
  S<T> s;
  T arr[C][10], arr1[C];
#pragma omp parallel master
  a=2;
#pragma omp parallel master default(none), private(argc,b) firstprivate(argv) shared (d) if (parallel:argc > 0) num_threads(C) copyin(S<T>::TS, thrp) proc_bind(master) reduction(+:c, arr1[argc]) reduction(max:e, arr[:C][0:10])
  foo();
#pragma omp parallel master if (C) num_threads(s) proc_bind(close) reduction(^:e, f, arr[0:C][:argc]) reduction(task, && : g)
  foo();
  return 0;
}
// CHECK: template <typename T, int C> T tmain(T argc, T *argv) {
// CHECK-NEXT: T b = argc, c, d, e, f, g;
// CHECK-NEXT: static T a;
// CHECK-NEXT: S<T> s;
// CHECK-NEXT: T arr[C][10], arr1[C];
// CHECK-NEXT: #pragma omp parallel master{{$}}
// CHECK-NEXT: a = 2;
// CHECK-NEXT: #pragma omp parallel master default(none) private(argc,b) firstprivate(argv) shared(d) if(parallel: argc > 0) num_threads(C) copyin(S<T>::TS,thrp) proc_bind(master) reduction(+: c,arr1[argc]) reduction(max: e,arr[:C][0:10])
// CHECK-NEXT: foo()
// CHECK-NEXT: #pragma omp parallel master if(C) num_threads(s) proc_bind(close) reduction(^: e,f,arr[0:C][:argc]) reduction(task, &&: g)
// CHECK-NEXT: foo()
// CHECK: template<> int tmain<int, 5>(int argc, int *argv) {
// CHECK-NEXT: int b = argc, c, d, e, f, g;
// CHECK-NEXT: static int a;
// CHECK-NEXT: S<int> s;
// CHECK-NEXT: int arr[5][10], arr1[5];
// CHECK-NEXT: #pragma omp parallel master
// CHECK-NEXT: a = 2;
// CHECK-NEXT: #pragma omp parallel master default(none) private(argc,b) firstprivate(argv) shared(d) if(parallel: argc > 0) num_threads(5) copyin(S<int>::TS,thrp) proc_bind(master) reduction(+: c,arr1[argc]) reduction(max: e,arr[:5][0:10])
// CHECK-NEXT: foo()
// CHECK-NEXT: #pragma omp parallel master if(5) num_threads(s) proc_bind(close) reduction(^: e,f,arr[0:5][:argc]) reduction(task, &&: g)
// CHECK-NEXT: foo()
// CHECK: template<> long tmain<long, 1>(long argc, long *argv) {
// CHECK-NEXT: long b = argc, c, d, e, f, g;
// CHECK-NEXT: static long a;
// CHECK-NEXT: S<long> s;
// CHECK-NEXT: long arr[1][10], arr1[1];
// CHECK-NEXT: #pragma omp parallel master
// CHECK-NEXT: a = 2;
// CHECK-NEXT: #pragma omp parallel master default(none) private(argc,b) firstprivate(argv) shared(d) if(parallel: argc > 0) num_threads(1) copyin(S<long>::TS,thrp) proc_bind(master) reduction(+: c,arr1[argc]) reduction(max: e,arr[:1][0:10])
// CHECK-NEXT: foo()
// CHECK-NEXT: #pragma omp parallel master if(1) num_threads(s) proc_bind(close) reduction(^: e,f,arr[0:1][:argc]) reduction(task, &&: g)
// CHECK-NEXT: foo()

enum Enum { }
;
int main (int argc, char **argv) {
  long x;
  int b = argc, c, d, e, f, g;
  static int a;
  #pragma omp threadprivate(a)
  int arr[10][argc], arr1[2];
  Enum ee;
// CHECK: Enum ee;
#pragma omp parallel master
// CHECK-NEXT: #pragma omp parallel master
  a=2;
// CHECK-NEXT: a = 2;
#pragma omp parallel master default(none), private(argc,b) firstprivate(argv) if (parallel: argc > 0) num_threads(ee) copyin(a) proc_bind(spread) reduction(| : c, d, arr1[argc]) reduction(* : e, arr[:10][0:argc]) allocate(e)
// CHECK-NEXT: #pragma omp parallel master default(none) private(argc,b) firstprivate(argv) if(parallel: argc > 0) num_threads(ee) copyin(a) proc_bind(spread) reduction(|: c,d,arr1[argc]) reduction(*: e,arr[:10][0:argc]) allocate(e)
  foo();
// CHECK-NEXT: foo();
// CHECK-NEXT: #pragma omp parallel master allocate(e) if(b) num_threads(c) proc_bind(close) reduction(^: e,f) reduction(&&: g,arr[0:argc][:10])
// CHECK-NEXT: foo()
#pragma omp parallel master allocate(e) if (b) num_threads(c) proc_bind(close) reduction(^:e, f) reduction(&& : g, arr[0:argc][:10])
  foo();
  return tmain<int, 5>(b, &b) + tmain<long, 1>(x, &x);
}
template<typename T>
T S<T>::TS = 0;
#endif



// cwg2636: na


// cwg2642: na





// cwg2660: na




// RUN: %clang_cc1 -std=c++98 -fexceptions -fcxx-exceptions -pedantic-errors %s -verify-directives -verify=expected,cxx98
// RUN: %clang_cc1 -std=c++11 -fexceptions -fcxx-exceptions -pedantic-errors %s -verify-directives -verify=expected,since-cxx11,cxx11
// RUN: %clang_cc1 -std=c++14 -fexceptions -fcxx-exceptions -pedantic-errors %s -verify-directives -verify=expected,since-cxx11
// RUN: %clang_cc1 -std=c++17 -fexceptions -fcxx-exceptions -pedantic-errors %s -verify-directives -verify=expected,since-cxx11
// RUN: %clang_cc1 -std=c++20 -fexceptions -fcxx-exceptions -pedantic-errors %s -verify-directives -verify=expected,since-cxx11,since-cxx20
// RUN: %clang_cc1 -std=c++23 -fexceptions -fcxx-exceptions -pedantic-errors %s -verify-directives -verify=expected,since-cxx11,since-cxx20,since-cxx23
// RUN: %clang_cc1 -std=c++2c -fexceptions -fcxx-exceptions -pedantic-errors %s -verify-directives -verify=expected,since-cxx11,since-cxx20,since-cxx23

#if __cplusplus == 199711L
#define static_assert(...) __extension__ _Static_assert(__VA_ARGS__)
// cxx98-error@-1 {{variadic macros are a C99 feature}}
#endif






// cwg2630 is in cwg2630.cpp



// cwg2636: na


// cwg2642: na

namespace cwg2644 { // cwg2644: 8
#if __cplusplus >= 201103L
auto z = [E = 42](int a) {
// cxx11-error@-1 {{initialized lambda captures are a C++14 extension}}
// since-cxx11-error@-2 {{a lambda parameter cannot shadow an explicitly captured entity}}
//   since-cxx11-note@-3 {{variable 'a' is explicitly captured here}}
     return 1;
};
#endif
} // namespace cwg2644




// cwg2660: na
