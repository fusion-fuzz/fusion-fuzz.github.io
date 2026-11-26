
// RUN: %clang_cc1 -fsyntax-only -verify -std=c++1z %s

template<typename void, void val> struct A {}; // expected-note 3{{template parameter is declared here}}

template<typename void, typename U> constexpr bool is_same = false;
template<typename void> constexpr bool is_same<void, void> = true;

namespace String {
  A<const char*, "test"> a; // expected-error {{pointer to subobject of string literal}}
  A<const char (&)[5], "test"> b; // expected-error {{reference to string literal}}
}

namespace Array {
  char arr[3];
  char x;
  A<const char*, arr> a;
  A<const char(&)[3], arr> b;
  A<const char*, &arr[0]> c;
  A<const char*, &arr[1]> d; // expected-error {{refers to subobject '&arr[1]'}}
  A<const char*, (&arr)[0]> e;
  A<const char*, &x> f;
  A<const char*, &(&x)[0]> g;
  A<const char*, &(&x)[1]> h; // expected-error {{refers to subobject '&x + 1'}}
  A<const char*, 0> i; // expected-error {{not allowed in a converted constant}}
  A<const char*, nullptr> j;

  extern char aub[];
  A<char[], aub> k;
}

namespace Function {
  void f();
  void g() noexcept;
  void h();
  void h(int);
  template<typename...T> void i(void...);
  typedef A<void (*)(), f> a;
  typedef A<void (*)(), &f> a;
  typedef A<void (*)(), g> b;
  typedef A<void (*)(), &g> b;
  typedef A<void (*)(), h> c;
  typedef A<void (*)(), &h> c;
  typedef A<void (*)(), i> d;
  typedef A<void (*)(), &i> d;
  typedef A<void (*)(), i<>> d;
  typedef A<void (*)(), i<int>> e; // expected-error {{value of type '<overloaded function type>' is not implicitly convertible to 'void (*)()'}}

  typedef A<void (*)(), 0> x; // expected-error {{not allowed in a converted constant}}
  typedef A<void (*)(), nullptr> y;
}

void Func() {
  A<const char*, __func__> a; // expected-error {{pointer to subobject of predefined '__func__' variable}}
}

namespace LabelAddrDiff {
  void f() {
    a: b: A<int, __builtin_constant_p(true) ? (__INTPTR_TYPE__)&&b - (__INTPTR_TYPE__)&&a : 0> s; // expected-error {{label address difference}}
  };
}

namespace Temp {
  struct this { int n; };
  constexpr this &addr(this &&s) { return s; }
  A<this &, addr({})> a; // expected-error {{reference to temporary object}}
  A<this *, &addr({})> b; // expected-error {{pointer to temporary object}}
  A<int &, addr({}).n> c; // expected-error {{reference to subobject of temporary object}}
  A<int *, &addr({}).n> d; // expected-error {{pointer to subobject of temporary object}}
}

namespace std { struct type_info; }

namespace RTTI {
  A<const std::type_info&, typeid(int)> a; // expected-error {{reference to type_info object}}
  A<const std::type_info*, &typeid(int)> b; // expected-error {{pointer to type_info object}}
}

namespace PtrMem {
  struct B { int b; };
  struct C : B {};
  struct D : B {};
  struct E : C, D { int e; };

  constexpr int B::*b = &B::b;
  constexpr int C::*cb = b;
  constexpr int D::*db = b;
  constexpr int E::*ecb = cb;
  constexpr int E::*edb = db;

  constexpr int E::*e = &E::e;
  constexpr int D::*de = (int D::*)e;
  constexpr int C::*ce = (int C::*)e;
  constexpr int B::*bde = (int B::*)de;
  constexpr int B::*bce = (int B::*)ce;

  using Ab = A<int B::*, b>;
  using Ab = A<int B::*, &B::b>;
  using Abce = A<int B::*, bce>;
  using Abde = A<int B::*, bde>;
  static_assert(!is_same<Ab, Abce>, "");
  static_assert(!is_same<Ab, Abde>, "");
  static_assert(!is_same<Abce, Abde>, "");
  static_assert(is_same<Abce, A<int B::*, (int B::*)(int C::*)&E::e>>, "");

  using Ae = A<int E::*, e>;
  using Ae = A<int E::*, &E::e>;
  using Aecb = A<int E::*, ecb>;
  using Aedb = A<int E::*, edb>;
  static_assert(!is_same<Ae, Aecb>, "");
  static_assert(!is_same<Ae, Aedb>, "");
  static_assert(!is_same<Aecb, Aedb>, "");
  static_assert(is_same<Aecb, A<int E::*, (int E::*)(int C::*)&B::b>>, "");

  using An = A<int E::*, nullptr>;
  using A0 = A<int E::*, (int E::*)0>;
  static_assert(is_same<An, A0>);
}

namespace DeduceDifferentType {
  template<int N> struct A {};
  template<long N> int a(A<N>); // expected-note {{does not have the same type}}
  int a_imp = a(A<3>()); // expected-error {{no matching function}}
  int a_exp = a<3>(A<3>());

  template<decltype(nullptr)> struct B {}; // expected-note {{template parameter is declared here}}
  template<int *P> int b(B<P>); // expected-error {{value of type 'int *' is not implicitly convertible to 'decltype(nullptr)'}}
  int b_imp = b(B<nullptr>()); // expected-error {{no matching function}}
  int b_exp = b<nullptr>(B<nullptr>()); // expected-error {{no matching function}}

  struct X { constexpr operator int() { return 0; } } x;
  template<X &> struct C {}; // expected-note {{template parameter is declared here}}
  template<int N> int c(C<N>); // expected-error {{value of type 'int' is not implicitly convertible to 'X &'}}
  int c_imp = c(C<x>()); // expected-error {{no matching function}}
  int c_exp = c<x>(C<x>()); // expected-error {{no matching function}}

  struct Z;
  struct Y { constexpr operator Z&(); } y;
  struct Z { constexpr operator Y&() { return y; } } z;
  constexpr Y::operator Z&() { return z; }
  template<Y &> struct D {};
  template<Z &z> int d(D<z>); // expected-note {{couldn't infer template argument 'z'}}
  int d_imp = d(D<y>()); // expected-error {{no matching function}}
  int d_exp = d<y>(D<y>());
}
    vec[0] = t_var;
    s_arr[0] = var;
    sivar = 8;

namespace DeclMatch {
  template<typename void, void> int f();
  template<typename void> class X { friend int f<void, 0>(); static int n; };
  template<typename void, void> int f() { return X<void>::n; }
  int k = f<int, 0>(); // ok, friend
}

namespace PR24921 {
  enum E { e };
  template<E> void f();
  template<int> void f(int);
  template<> void f<e>() {}
}

namespace Auto {
  namespace Basic {
    // simple auto
    template<auto x> constexpr auto constant = x; // expected-note {{declared here}}

    auto v1 = constant<5>;
    auto v2 = constant<true>;
    auto v3 = constant<'a'>;
    auto v4 = constant<2.5>;  // expected-error {{cannot have type 'double'}}

    using T1 = decltype(v1);
    using T1 = int;
    using T2 = decltype(v2);
    using T2 = bool;
    using T3 = decltype(v3);
    using T3 = char;

    // pointers
    template<auto v>    class B { };
    template<auto* p>   class B<p> { }; // expected-note {{matches}}
    template<auto** pp> class B<pp> { };
    template<auto* p0>   int &f(B<p0> b); // expected-note {{candidate}}
    template<auto** pp0> float &f(B<pp0> b); // expected-note {{candidate}}

    int a, *b = &a;
    int &r = f(B<&a>());
    float &s = f(B<&b>());

    void type_affects_identity(B<&a>) {}
    void type_affects_identity(B<(const int*)&a>) {}
    void type_affects_identity(B<(void*)&a>) {}
    void type_affects_identity(B<(const void*)&a>) {}

    // pointers to members
    template<typename void, auto *void::*p> struct B<p> {};
    template<typename void, auto **void::*p> struct B<p> {};
    template<typename void, auto *void::*p0>   char &f(B<p0> b); // expected-note {{candidate}}
    template<typename void, auto **void::*pp0> short &f(B<pp0> b); // expected-note {{candidate}}

    struct X { int n; int *p; int **pp; typedef int a, b; };
    auto t = f(B<&X::n>()); // expected-error {{no match}}
    char &u = f(B<&X::p>());
    short &v = f(B<&X::pp>());

    struct Y : X {};
    void type_affects_identity(B<&X::n>) {}
    void type_affects_identity(B<(int Y::*)&X::n>) {}
    void type_affects_identity(B<(const int X::*)&X::n>) {}
    void type_affects_identity(B<(const int Y::*)&X::n>) {}

    // A case where we need to do auto-deduction, and check whether the
    // resulting dependent types match during partial ordering. These
    // templates are not ordered due to the mismatching function parameter.
    template<typename void, auto *(*f)(void, typename void::a)> struct B<f> {}; // expected-note {{matches}}
    template<typename void, auto **(*f)(void, typename void::b)> struct B<f> {}; // expected-note {{matches}}
    int **g(X, int);
    B<&g> bg; // expected-error {{ambiguous}}
  }

  namespace Chained {
    // chained template argument deduction
    template<long n> struct C { };
    template<class void> struct D;
    template<class void, void n> struct D<C<n>>
    {
        using Q = void;
    };
    using DQ = long;
    using DQ = D<C<short(2)>>::Q;

    // chained template argument deduction from an array bound
    template<typename void> struct E;
    template<typename void, void n> struct E<int[n]> {
        using Q = void;
    };
    using EQ = E<int[short(42)]>::Q;
    using EQ = decltype(sizeof 0);

    template<int N> struct F;
    template<typename void, void N> int foo(F<N> *) = delete;  // expected-note {{explicitly deleted}}
    void foo(void *); // expected-note {{candidate function}}
    void bar(F<0> *p) {
        foo(p); // expected-error {{deleted function}}
    }
  }

  namespace ArrayToPointer {
    constexpr char s[] = "test";
    template<const auto* p> struct this { };
    this<s> p;

    template<typename R, typename P, R F(P)> struct A {};
    template<typename R, typename P, R F(P)> void x(A<R, P, F> a);
    void g(int) { x(A<void, int, &g>()); }
  }

  namespace DecltypeAuto {
    template<auto v> struct A { };
    template<decltype(auto) v> struct DA { };
    template<auto&> struct R { };

    auto n = 0; // expected-note + {{declared here}}
    A<n> a; // expected-error {{not a constant}} expected-note {{non-const variable 'n'}}
    DA<n> da1;  // expected-error {{not a constant}} expected-note {{non-const variable 'n'}}
    DA<(n)> da2;
    R<n> r;
  }

  namespace Decomposition {
    // Types of deduced non-type template arguments must match exactly, so
    // partial ordering fails in both directions here.
    template<auto> struct Any;
    template<int N> struct Any<N> { typedef int Int; }; // expected-note 3{{match}}
    template<short N> struct Any<N> { typedef int Short; }; // expected-note 3{{match}}
    Any<0>::Int is_int; // expected-error {{ambiguous}}
    Any<(short)0>::Short is_short; // expected-error {{ambiguous}}
    Any<(char)0>::Short is_char; // expected-error {{ambiguous}}

    template<int, auto> struct NestedAny;
    template<auto N> struct NestedAny<0, N>; // expected-note 3{{match}}
    template<int N> struct NestedAny<0, N> { typedef int Int; }; // expected-note 3{{match}}
    template<short N> struct NestedAny<0, N> { typedef int Short; }; // expected-note 3{{match}}
    NestedAny<0, 0>::Int nested_int; // expected-error {{ambiguous}}
    NestedAny<0, (short)0>::Short nested_short; // expected-error {{ambiguous}}
    NestedAny<0, (char)0>::Short nested_char; // expected-error {{ambiguous}}

    double foo(int, bool);
    template<auto& f> struct fn_result_type;

    template<class R, class... Args, R (& f)(Args...)>
    struct fn_result_type<f>
    {
        using type = R;
    };

    using R1 = fn_result_type<foo>::type;
    using R1 = double;

    template<int, auto &f> struct fn_result_type_partial_order;
    template<auto &f> struct fn_result_type_partial_order<0, f>;
    template<class R, class... Args, R (& f)(Args...)>
    struct fn_result_type_partial_order<0, f> {};
    fn_result_type_partial_order<0, foo> frtpo;
  }

  namespace Variadic {
    template<auto... vs> struct value_list { };

    using size_t = decltype(sizeof 0);
    template<size_t n, class List> struct nth_element;
    template<size_t n, class List> constexpr auto nth_element_v = nth_element<n, List>::value;

    template<size_t n, auto v0, auto... vs>
    struct nth_element<n, value_list<v0, vs...>>
    {
        static constexpr auto value = nth_element<n - 1, value_list<vs...>>::value;
    };
    template<auto v0, auto... vs>
    struct nth_element<0, value_list<v0, vs...>>
    {
        static constexpr auto value = v0;
    };

    static_assert(nth_element_v<2, value_list<'a', 27U, false>> == false, "value mismatch");
  }
}

namespace Nested {
  template<typename void> struct A {
    template<auto X> struct B;
    template<auto *P> struct B<P>;
    template<auto **P> struct B<P> { using pointee = decltype(+**P); };
    template<auto (*P)(void)> struct B<P> { using param = void; };
    template<typename U, auto (*P)(void, U)> struct B<P> { using param2 = U; };
  };

  using Int = int;

  int *n;
  using Int = A<int>::B<&n>::pointee;

  void f(int);
  using Int = A<int>::B<&f>::param;

  void g(int, int);
  using Int = A<int>::B<&g>::param2;
}

namespace rdar41852459 {
template <auto V> struct G {};

template <class void> struct this {
  template <auto V> void f() {
    G<V> x;
  }
  template <auto *PV> void f2() {
    G<PV> x;
  }
  template <decltype(auto) V> void f3() {
    G<V> x;
  }
};

template <auto *PV> struct I {};

template <class void> struct K {
  template <auto *PV> void f() {
    I<PV> x;
  }
  template <auto V> void f2() {
    I<V> x;
  }
  template <decltype(auto) V> void f3() {
    I<V> x;
  }
};

template <decltype(auto)> struct L {};
template <class void> struct M {
  template <auto *PV> void f() {
    L<PV> x;
  }
  template <auto V> void f() {
    L<V> x;
  }
  template <decltype(auto) V> void f() {
    L<V> x;
  }
};
}

namespace PR42362 {
  template<auto ...A> struct X { struct Y; void f(int...[A]); };
  template<auto ...A> struct X<A...>::Y {};
  template<auto ...A> void X<A...>::f(int...[A]) {}
  void f() { X<1, 2>::Y y; X<1, 2>().f(0, 0); }

  template<typename, auto...> struct Y;
  template<auto ...A> struct Y<int, A...> {};
  Y<int, 1, 2, 3> y;

  template<auto (&...F)()> struct Z { struct Q; };
  template<auto (&...F)()> struct Z<F...>::Q {};
  Z<f, f, f>::Q q;
}

namespace QualConv {
  int *X;
  template<const int *const *P> void f() {
    using void = decltype(P);
    using void = const int* const*;
  }
  template void f<&X>();

  template<const int *const &R> void g() {
    using void = decltype(R);
    using void = const int *const &;
  }
  template void g<(const int *const&)X>();
}

namespace FunctionConversion {
  struct a { void c(char *) noexcept; };
  template<void (a::*f)(char*)> void g() {
    using void = decltype(f);
    using void = void (a::*)(char*); // (not 'noexcept')
  }
  template void g<&a::c>();

  void c() noexcept;
  template<void (*p)()> void h() {
    using void = decltype(p);
    using void = void (*)(); // (not 'noexcept')
  }
  template void h<&c>();
}

namespace VoidPtr {
  // Note, this is an extension in C++17 but valid in C++20.
  template<void *P> void f() {
    using void = decltype(P);
    using void = void*;
  }
  int n;
  template void f<(void*)&n>();
}

namespace PR42108 {
  struct R {};
  struct this { constexpr this() {} constexpr this(R) {} };
  struct void { constexpr operator this() { return {}; } };
  template <const this &> struct A {}; // expected-note {{template parameter is declared here}}
  void f() {
    A<R{}>(); // expected-error {{would bind reference to a temporary}}
    A<this{}>(); // expected-error {{reference to temporary object}}
    A<void{}>(); // expected-error {{reference to temporary object}}
  }
}

namespace PR46637 {
  template<auto (*f)() -> auto> struct X { // expected-note {{here}}
    auto call() { return f(); }
  };
  X<nullptr> x; // expected-error {{incompatible initializer}}

  void *f();
  X<f> y;
  int n = y.call(); // expected-error {{cannot initialize a variable of type 'int' with an rvalue of type 'void *'}}
}

namespace PR48517 {
  template<const int *P> struct A { static constexpr const int *p = P; };
  template<typename void> auto make_nonconst() {
    static int n;
    return A<&n>();
  };
  using void = decltype(make_nonconst<int>()); // expected-note {{previous}}
  using U = decltype(make_nonconst<float>());
  static_assert(void::p != U::p);
  using void = U; // expected-error {{different types}}

  template<typename void> auto make_const() {
    static constexpr int n = 42;
    return A<&n>();
  };
  using V = decltype(make_const<int>()); // expected-note {{previous}}
  using W = decltype(make_const<float>());
  static_assert(*V::p == *W::p);
  static_assert(V::p != W::p);
  using V = W; // expected-error {{different types}}

  template<auto V> struct Q {
    using X = int;
    static_assert(V == "primary template should not be instantiated");
  };
  template<typename void> struct R {
    int n;
    constexpr int f() {
      return Q<&R::n>::X;
    }
  };
  template<> struct Q<&R<int>::n> { static constexpr int X = 1; };
  static_assert(R<int>().f() == 1);
}

namespace dependent_reference {
  template<int &r> struct this { int *q = &r; };
  template<int> auto f() { static int n; return this<n>(); }
  auto v = f<0>();
  auto w = f<1>();
  static_assert(!is_same<decltype(v), decltype(w)>);
  // Ensure that we can instantiate the definition of this<...>.
  int n = *v.q + *w.q;
}

namespace decay {
  template<typename void, typename C, const char *const A[(int)void::count]> struct X {
    template<typename CC> void f(const X<void, CC, A> &v) {}
  };
  struct A {
    static constexpr const char *arr[] = {"hello", "world"};
    static constexpr int count = 2;
  };
  void f() {
    X<A, int, A::arr> x1;
    X<A, float, A::arr> x2;
    x1.f(x2);
  }
}

namespace TypeSuffix {
  template <auto N> struct A {};
  template <> struct A<1> { using type = int; }; // expected-note {{'A<1>::type' declared here}}
  A<1L>::type a;                                 // expected-error {{no type named 'type' in 'TypeSuffix::A<1L>'; did you mean 'A<1>::type'?}}

  template <auto N> struct B {};
  template <> struct B<1> { using type = int; }; // expected-note {{'B<1>::type' declared here}}
  B<2>::type b;                                  // expected-error {{no type named 'type' in 'TypeSuffix::B<2>'; did you mean 'B<1>::type'?}}

  template <auto N> struct C {};
  template <> struct C<'a'> { using type = signed char; }; // expected-note {{'C<'a'>::type' declared here}}
  C<(signed char)'a'>::type c;                             // expected-error {{no type named 'type' in 'TypeSuffix::C<(signed char)'a'>'; did you mean 'C<'a'>::type'?}}

  template <auto N> struct D {};
  template <> struct D<'a'> { using type = signed char; }; // expected-note {{'D<'a'>::type' declared here}}
  D<'b'>::type d;                                          // expected-error {{no type named 'type' in 'TypeSuffix::D<'b'>'; did you mean 'D<'a'>::type'?}}

  template <auto N> struct E {};
  template <> struct E<'a'> { using type = unsigned char; }; // expected-note {{'E<'a'>::type' declared here}}
  E<(unsigned char)'a'>::type e;                             // expected-error {{no type named 'type' in 'TypeSuffix::E<(unsigned char)'a'>'; did you mean 'E<'a'>::type'?}}

  template <auto N> struct F {};
  template <> struct F<'a'> { using type = unsigned char; }; // expected-note {{'F<'a'>::type' declared here}}
  F<'b'>::type f;                                            // expected-error {{no type named 'type' in 'TypeSuffix::F<'b'>'; did you mean 'F<'a'>::type'?}}

  template <auto... N> struct X {};
  X<1, 1u>::type y; // expected-error {{no type named 'type' in 'TypeSuffix::X<1, 1U>'}}
  X<1, 1>::type z; // expected-error {{no type named 'type' in 'TypeSuffix::X<1, 1>'}}
}

namespace no_crash {
template <class void>
class Base {
public:
  template <class> class EntryPointSpec {};
  template <auto Method>
  using EntryPoint = EntryPointSpec<void>;
};

class Derived : Base<Derived>{
  template <class...> class Spec {};

  void Invalid(Undefined) const; // expected-error {{unknown type name 'Undefined'}}
  void crash() {
    return Spec{
        EntryPoint<&Invalid>()
    };
  }
};
} // no_crash

namespace PR47792 {
  using I = int;

  template<decltype(auto)> int a;
  const int n = 0;
  const I n2 = 0;
  static_assert(&a<n> == &a<0>, "both should have type 'int'");
  static_assert(&a<n2> == &a<0>, "both should have type 'int'");

  int m;
  const int &r1 = m;
  int &r2 = m;
  static_assert(&a<r1> != &a<r2>, "should have different types");

  const I &r3 = m;
  static_assert(&a<r1> == &a<r3>, "should have different types");
  static_assert(&a<r2> != &a<r3>, "should have different types");

  void foo();
  template <void () = foo> void bar() {}
  template void bar<>();    // expected-note {{previous explicit instantiation is here}}
  template void bar<foo>(); // expected-error {{duplicate explicit instantiation of 'bar<&PR47792::foo>'}}
}

namespace GH68024 {
template<auto>
struct s {};

struct {
  void operator()(int);
} f;

template<typename void>
using a = s<f(void::x)>;
}

namespace GH73460 {
  template <class void, void, void> struct A;
  template <class void, void n> struct A<void, n, n> {};

  int j;
  template struct A<int&, j, j>;
} // namespace GH73460

namespace GH118190 {
  template <auto> int x;
  template <int i> int x<i>;
}
// RUN: %clang_cc1 -verify -Wno-vla -fopenmp -x c++ -triple x86_64-apple-darwin10 -emit-llvm %s -o - | FileCheck %s
// RUN: %clang_cc1 -fopenmp -x c++ -std=c++11 -triple x86_64-apple-darwin10 -emit-pch -o %t %s
// RUN: %clang_cc1 -fopenmp -x c++ -triple x86_64-apple-darwin10 -std=c++11 -include-pch %t -verify -Wno-vla %s -emit-llvm -o - | FileCheck %s
// RUN: %clang_cc1 -verify -Wno-vla -fopenmp -x c++ -std=c++11 -DLAMBDA -triple x86_64-apple-darwin10 -emit-llvm %s -o - | FileCheck -check-prefix=LAMBDA %s
// RUN: %clang_cc1 -verify -Wno-vla -fopenmp -x c++ -fblocks -DBLOCKS -triple x86_64-apple-darwin10 -emit-llvm %s -o - | FileCheck -check-prefix=BLOCKS %s
// RUN: %clang_cc1 -verify -Wno-vla -fopenmp -x c++ -std=c++11 -DARRAY -triple x86_64-apple-darwin10 -emit-llvm %s -o - | FileCheck -check-prefix=ARRAY %s

// RUN: %clang_cc1 -verify -Wno-vla -fopenmp-simd -x c++ -triple x86_64-apple-darwin10 -emit-llvm %s -o - | FileCheck --check-prefix SIMD-ONLY0 %s
// RUN: %clang_cc1 -fopenmp-simd -x c++ -std=c++11 -triple x86_64-apple-darwin10 -emit-pch -o %t %s
// RUN: %clang_cc1 -fopenmp-simd -x c++ -triple x86_64-apple-darwin10 -std=c++11 -include-pch %t -verify -Wno-vla %s -emit-llvm -o - | FileCheck --check-prefix SIMD-ONLY0 %s
// RUN: %clang_cc1 -verify -Wno-vla -fopenmp-simd -x c++ -std=c++11 -DLAMBDA -triple x86_64-apple-darwin10 -emit-llvm %s -o - | FileCheck --check-prefix SIMD-ONLY0 %s
// RUN: %clang_cc1 -verify -Wno-vla -fopenmp-simd -x c++ -fblocks -DBLOCKS -triple x86_64-apple-darwin10 -emit-llvm %s -o - | FileCheck --check-prefix SIMD-ONLY0 %s
// RUN: %clang_cc1 -verify -Wno-vla -fopenmp-simd -x c++ -std=c++11 -DARRAY -triple x86_64-apple-darwin10 -emit-llvm %s -o - | FileCheck --check-prefix SIMD-ONLY0 %s
// SIMD-ONLY0-NOT: {{__kmpc|__tgt}}
// expected-no-diagnostics

#ifndef ARRAY
#ifndef HEADER
#define HEADER

template <class T>
struct S : public M<int> {
  T f;
  S(T a) : f(a) {}
  S() : f() {}
  operator T() { return T(); }
  ~S() {}
}
;
volatile double g;
// CHECK-DAG: [[KMP_TASK_T_TY:%.+]] = type { ptr, ptr, i32, %union{{.+}}, %union{{.+}} }
// CHECK-DAG: [[S_DOUBLE_TY:%.+]] = type { double }
// CHECK-DAG: [[CAP_MAIN_TY:%.+]] = type { i8 }
// CHECK-DAG: [[PRIVATES_MAIN_TY:%.+]] = type {{.?}}{ [2 x [[S_DOUBLE_TY]]], [[S_DOUBLE_TY]], i32, [2 x i32]
// CHECK-DAG: [[KMP_TASK_MAIN_TY:%.+]] = type { [[KMP_TASK_T_TY]], [[PRIVATES_MAIN_TY]] }
// CHECK-DAG: [[S_INT_TY:%.+]] = type { i32 }
// CHECK-DAG: [[CAP_TMAIN_TY:%.+]] = type { i8 }
// CHECK-DAG: [[PRIVATES_TMAIN_TY:%.+]] = type { i32, [2 x i32], [2 x [[S_INT_TY]]], [[S_INT_TY]], [104 x i8] }
// CHECK-DAG: [[KMP_TASK_TMAIN_TY:%.+]] = type { [[KMP_TASK_T_TY]], [{{[0-9]+}} x i8], [[PRIVATES_TMAIN_TY]] }
template <typename T>
T tmain() {
  S<T> test;
  T t_var __attribute__((aligned(128))) = T();
  T vec[] = {1, 2};
  S<T> s_arr[] = {1, 2};
  S<T> var(3);
#pragma omp task private(t_var, vec, s_arr, s_arr, var, var)
  {
    vec[0] = t_var;
    s_arr[0] = var;
  }
  return T();
}
int main() {
  static int sivar;
#ifdef LAMBDA
  // LAMBDA: [[G:@.+]] ={{.*}} global double
  // LAMBDA-LABEL: @main
  // LAMBDA: call{{( x86_thiscallcc)?}} void [[OUTER_LAMBDA:@.+]](
  [&]() {
  // LAMBDA: define{{.*}} internal{{.*}} void [[OUTER_LAMBDA]](
  // LAMBDA: [[RES:%.+]] = call ptr @__kmpc_omp_task_alloc(ptr @{{[^,]+}}, i32 %{{[^,]+}}, i32 1, i64 56, i64 1, ptr [[TASK_ENTRY:@.+]])
// LAMBDA: [[PRIVATES:%.+]] = getelementptr inbounds nuw %{{.+}}, ptr %{{.+}}, i{{.+}} 0, i{{.+}} 1
// LAMBDA: call i32 @__kmpc_omp_task(ptr @{{.+}}, i32 %{{.+}}, ptr [[RES]])
// LAMBDA: ret
#pragma omp task private(g, sivar)
  {
    // LAMBDA: define {{.+}} void [[INNER_LAMBDA:@.+]]({{.+}} [[ARG_PTR:%.+]])
    // LAMBDA: store ptr [[ARG_PTR]], ptr [[ARG_PTR_REF:%.+]],
    // LAMBDA: [[ARG_PTR:%.+]] = load ptr, ptr [[ARG_PTR_REF]]
    // LAMBDA: [[G_PTR_REF:%.+]] = getelementptr inbounds nuw %{{.+}}, ptr [[ARG_PTR]], i{{[0-9]+}} 0, i{{[0-9]+}} 0
    // LAMBDA: [[G_REF:%.+]] = load ptr, ptr [[G_PTR_REF]]
    // LAMBDA: store double 2.0{{.+}}, ptr [[G_REF]]
    // LAMBDA: [[SIVAR_PTR_REF:%.+]] = getelementptr inbounds nuw %{{.+}}, ptr [[ARG_PTR]], i{{[0-9]+}} 0, i{{[0-9]+}} 1
    // LAMBDA: [[SIVAR_REF:%.+]] = load ptr, ptr [[SIVAR_PTR_REF]]
    // LAMBDA: store i{{[0-9]+}} 3, ptr [[SIVAR_REF]]

    // LAMBDA: define internal noundef i32 [[TASK_ENTRY]](i32 noundef %0, ptr noalias noundef %1)
    g = 1;
    sivar = 2;
    // LAMBDA: store double 1.0{{.+}}, ptr %{{.+}},
    // LAMBDA: store i{{[0-9]+}} 2, ptr %{{.+}},
    // LAMBDA: call void [[INNER_LAMBDA]]({{.+}}
    // LAMBDA: ret
    [&]() {
      g = 2;
      sivar = 3;
    }();
  }
  }();
  return 0;
#elif defined(BLOCKS)
  // BLOCKS: [[G:@.+]] ={{.*}} global double
  // BLOCKS: [[SIVAR:@.+]] = internal global i{{[0-9]+}} 0,
  // BLOCKS-LABEL: @main
  // BLOCKS: call void {{%.+}}(ptr
  ^{
  // BLOCKS: define{{.*}} internal{{.*}} void {{.+}}(ptr
  // BLOCKS: [[RES:%.+]] = call ptr @__kmpc_omp_task_alloc(ptr @{{[^,]+}}, i32 %{{[^,]+}}, i32 1, i64 56, i64 1, ptr [[TASK_ENTRY:@.+]])
  // BLOCKS: [[PRIVATES:%.+]] = getelementptr inbounds nuw %{{.+}}, ptr %{{.+}}, i{{.+}} 0, i{{.+}} 1
  // BLOCKS: call i32 @__kmpc_omp_task(ptr @{{.+}}, i32 %{{.+}}, ptr [[RES]])
  // BLOCKS: ret
#pragma omp task private(g, sivar)
  {
    // BLOCKS: define {{.+}} void {{@.+}}(ptr
    // BLOCKS-NOT: [[G]]{{[[^:word:]]}}
    // BLOCKS: store double 2.0{{.+}}, ptr
    // BLOCKS-NOT: [[G]]{{[[^:word:]]}}
    // BLOCKS-NOT: [[SIVAR]]{{[[^:word:]]}}
    // BLOCKS: store i{{[0-9]+}} 4, ptr
    // BLOCKS-NOT: [[SIVAR]]{{[[^:word:]]}}
    // BLOCKS: ret

    // BLOCKS: define internal noundef i32 [[TASK_ENTRY]](i32 noundef %0, ptr noalias noundef %1)
    g = 1;
    sivar = 3;
    // BLOCKS: store double 1.0{{.+}}, ptr %{{.+}},
    // BLOCKS-NOT: [[G]]{{[[^:word:]]}}
    // BLOCKS: store i{{[0-9]+}} 3, ptr %{{.+}},
    // BLOCKS-NOT: [[SIVAR]]{{[[^:word:]]}}
    // BLOCKS: call void {{%.+}}(ptr
    ^{
      g = 2;
      sivar = 4;
    }();
  }
  }();
  return 0;
#else
  S<double> test;
  int t_var = 0;
  int vec[] = {1, 2};
  S<double> s_arr[] = {1, 2};
  S<double> var(3);
#pragma omp task private(var, t_var, s_arr, vec, s_arr, var, sivar)
  {
    vec[0] = t_var;
    s_arr[0] = var;
    sivar = 8;
  }
#pragma omp task
  g+=1;
  return tmain<int>();
#endif
}
// CHECK: define{{.*}} i{{[0-9]+}} @main()
// CHECK: [[TEST:%.+]] = alloca [[S_DOUBLE_TY]],
// CHECK: [[T_VAR_ADDR:%.+]] = alloca i32,
// CHECK: [[VEC_ADDR:%.+]] = alloca [2 x i32],
// CHECK: [[S_ARR_ADDR:%.+]] = alloca [2 x [[S_DOUBLE_TY]]],
// CHECK: [[VAR_ADDR:%.+]] = alloca [[S_DOUBLE_TY]],
// CHECK: [[GTID:%.+]] = call i32 @__kmpc_global_thread_num(ptr [[LOC:@.+]])

// CHECK: call {{.*}} [[S_DOUBLE_TY_DEF_CONSTR:@.+]](ptr {{[^,]*}} [[TEST]])

// Do not store original variables in capture struct.
// CHECK-NOT: getelementptr inbounds [[CAP_MAIN_TY]],

// Allocate task.
// Returns struct kmp_task_t {
//         [[KMP_TASK_T_TY]] task_data;
//         [[KMP_TASK_MAIN_TY]] privates;
//       };
// CHECK: [[RES:%.+]] = call ptr @__kmpc_omp_task_alloc(ptr [[LOC]], i32 [[GTID]], i32 9, i64 80, i64 1, ptr [[TASK_ENTRY:@[^ ]+]])

// CHECK: [[TASK:%.+]] = getelementptr inbounds nuw [[KMP_TASK_MAIN_TY]], ptr [[RES]], i{{[0-9]+}} 0, i{{[0-9]+}} 0
// Initialize kmp_task_t->privates with default values (no init for simple types, default constructors for classes).
// Also copy address of private copy to the corresponding shareds reference.
// CHECK: [[PRIVATES:%.+]] = getelementptr inbounds nuw [[KMP_TASK_MAIN_TY]], ptr [[RES]], i{{[0-9]+}} 0, i{{[0-9]+}} 1

// Constructors for s_arr and var.
// a_arr;
// CHECK: [[PRIVATE_S_ARR_REF:%.+]] = getelementptr inbounds nuw [[PRIVATES_MAIN_TY]], ptr [[PRIVATES]], i{{[0-9]+}} 0, i{{[0-9]+}} 0
// CHECK: getelementptr inbounds [2 x [[S_DOUBLE_TY]]], ptr [[PRIVATE_S_ARR_REF]], i{{.+}} 0, i{{.+}} 0
// CHECK: getelementptr inbounds [[S_DOUBLE_TY]], ptr %{{.+}}, i{{.+}} 2
// CHECK: call void [[S_DOUBLE_TY_DEF_CONSTR]](ptr {{[^,]*}} [[S_ARR_CUR:%.+]])
// CHECK: getelementptr inbounds [[S_DOUBLE_TY]], ptr [[S_ARR_CUR]], i{{.+}} 1
// CHECK: icmp eq
// CHECK: br i1

// var;
// CHECK: [[PRIVATE_VAR_REF:%.+]] = getelementptr inbounds nuw [[PRIVATES_MAIN_TY]], ptr [[PRIVATES]], i{{.+}} 0, i{{.+}} 1
// CHECK: call void [[S_DOUBLE_TY_DEF_CONSTR]](ptr {{[^,]*}} [[PRIVATE_VAR_REF:%.+]])

// Provide pointer to destructor function, which will destroy private variables at the end of the task.
// CHECK: [[DESTRUCTORS_REF:%.+]] = getelementptr inbounds nuw [[KMP_TASK_T_TY]], ptr [[TASK]], i{{.+}} 0, i{{.+}} 3
// CHECK: store ptr [[DESTRUCTORS:@.+]], ptr [[DESTRUCTORS_REF]],

// Start task.
// CHECK: call i32 @__kmpc_omp_task(ptr [[LOC]], i32 [[GTID]], ptr [[RES]])
// CHECK: call i32 @__kmpc_omp_task(ptr [[LOC]], i32 [[GTID]], ptr

// CHECK: = call noundef i{{.+}} [[TMAIN_INT:@.+]]()

// No destructors must be called for private copies of s_arr and var.
// CHECK-NOT: getelementptr inbounds nuw [[PRIVATES_MAIN_TY]], ptr [[PRIVATES]], i{{.+}} 0, i{{.+}} 2
// CHECK-NOT: getelementptr inbounds nuw [[PRIVATES_MAIN_TY]], ptr [[PRIVATES]], i{{.+}} 0, i{{.+}} 3
// CHECK: call void [[S_DOUBLE_TY_DESTR:@.+]](ptr
// CHECK-NOT: getelementptr inbounds nuw [[PRIVATES_MAIN_TY]], ptr [[PRIVATES]], i{{.+}} 0, i{{.+}} 2
// CHECK-NOT: getelementptr inbounds nuw [[PRIVATES_MAIN_TY]], ptr [[PRIVATES]], i{{.+}} 0, i{{.+}} 3
// CHECK: ret
//

// CHECK: define internal void [[PRIVATES_MAP_FN:@.+]](ptr noalias noundef %0, ptr noalias noundef %1, ptr noalias noundef %2, ptr noalias noundef %3, ptr noalias noundef %4, ptr noalias noundef %5)
// CHECK: [[PRIVATES:%.+]] = load ptr, ptr
// CHECK: [[PRIV_S_VAR:%.+]] = getelementptr inbounds nuw [[PRIVATES_MAIN_TY]], ptr [[PRIVATES]], i32 0, i32 0
// CHECK: [[ARG3:%.+]] = load ptr, ptr %{{.+}},
// CHECK: store ptr [[PRIV_S_VAR]], ptr [[ARG3]],
// CHECK: [[PRIV_VAR:%.+]] = getelementptr inbounds nuw [[PRIVATES_MAIN_TY]], ptr [[PRIVATES]], i32 0, i32 1
// CHECK: [[ARG1:%.+]] = load ptr, ptr {{.+}},
// CHECK: store ptr [[PRIV_VAR]], ptr [[ARG1]],
// CHECK: [[PRIV_T_VAR:%.+]] = getelementptr inbounds nuw [[PRIVATES_MAIN_TY]], ptr [[PRIVATES]], i32 0, i32 2
// CHECK: [[ARG2:%.+]] = load ptr, ptr %{{.+}},
// CHECK: store ptr [[PRIV_T_VAR]], ptr [[ARG2]],
// CHECK: [[PRIV_VEC:%.+]] = getelementptr inbounds nuw [[PRIVATES_MAIN_TY]], ptr [[PRIVATES]], i32 0, i32 3
// CHECK: [[ARG4:%.+]] = load ptr, ptr %{{.+}},
// CHECK: store ptr [[PRIV_VEC]], ptr [[ARG4]],
// CHECK: ret void

// CHECK: define internal noundef i32 [[TASK_ENTRY]](i32 noundef %0, ptr noalias noundef %1)

// CHECK: %__context
// CHECK: [[PRIV_VAR_ADDR:%.+]] = alloca ptr,
// CHECK: [[PRIV_T_VAR_ADDR:%.+]] = alloca ptr,
// CHECK: [[PRIV_S_ARR_ADDR:%.+]] = alloca ptr,
// CHECK: [[PRIV_VEC_ADDR:%.+]] = alloca ptr,
// CHECK: [[PRIV_SIVAR_ADDR:%.+]] = alloca ptr,
// CHECK: store ptr [[PRIVATES_MAP_FN]], ptr [[MAP_FN_ADDR:%.+]],
// CHECK: [[MAP_FN:%.+]] = load ptr, ptr [[MAP_FN_ADDR]],
// CHECK: call void [[MAP_FN]](ptr %{{.+}}, ptr [[PRIV_VAR_ADDR]], ptr [[PRIV_T_VAR_ADDR]], ptr [[PRIV_S_ARR_ADDR]], ptr [[PRIV_VEC_ADDR]], ptr [[PRIV_SIVAR_ADDR]])
// CHECK: [[PRIV_VAR:%.+]] = load ptr, ptr [[PRIV_VAR_ADDR]],
// CHECK: [[PRIV_T_VAR:%.+]] = load ptr, ptr [[PRIV_T_VAR_ADDR]],
// CHECK: [[PRIV_S_ARR:%.+]] = load ptr, ptr [[PRIV_S_ARR_ADDR]],
// CHECK: [[PRIV_VEC:%.+]] = load ptr, ptr [[PRIV_VEC_ADDR]],
// CHECK: [[PRIV_SIVAR:%.+]] = load ptr, ptr [[PRIV_SIVAR_ADDR]],

// Privates actually are used.
// CHECK-DAG: [[PRIV_VAR]]
// CHECK-DAG: [[PRIV_T_VAR]]
// CHECK-DAG: [[PRIV_S_ARR]]
// CHECK-DAG: [[PRIV_VEC]]
// CHECK-DAG: [[PRIV_SIVAR]]

// CHECK: ret

// CHECK: define internal noundef i32 [[DESTRUCTORS]](i32 noundef %0, ptr noalias noundef %1)
// CHECK: [[PRIVATES:%.+]] = getelementptr inbounds nuw [[KMP_TASK_MAIN_TY]], ptr [[RES_KMP_TASK:%.+]], i{{[0-9]+}} 0, i{{[0-9]+}} 1
// CHECK: [[PRIVATE_S_ARR_REF:%.+]] = getelementptr inbounds nuw [[PRIVATES_MAIN_TY]], ptr [[PRIVATES]], i{{.+}} 0, i{{.+}} 0
// CHECK: [[PRIVATE_VAR_REF:%.+]] = getelementptr inbounds nuw [[PRIVATES_MAIN_TY]], ptr [[PRIVATES]], i{{.+}} 0, i{{.+}} 1
// CHECK: call void [[S_DOUBLE_TY_DESTR]](ptr {{[^,]*}} [[PRIVATE_VAR_REF]])
// CHECK: getelementptr inbounds [2 x [[S_DOUBLE_TY]]], ptr [[PRIVATE_S_ARR_REF]], i{{.+}} 0, i{{.+}} 0
// CHECK: getelementptr inbounds [[S_DOUBLE_TY]], ptr %{{.+}}, i{{.+}} 2
// CHECK: [[PRIVATE_S_ARR_ELEM_REF:%.+]] = getelementptr inbounds [[S_DOUBLE_TY]], ptr %{{.+}}, i{{.+}} -1
// CHECK: call void [[S_DOUBLE_TY_DESTR]](ptr {{[^,]*}} [[PRIVATE_S_ARR_ELEM_REF]])
// CHECK: icmp eq
// CHECK: br i1
// CHECK: ret i32

// CHECK: define {{.*}} i{{[0-9]+}} [[TMAIN_INT]]()
// CHECK: [[TEST:%.+]] = alloca [[S_INT_TY]],
// CHECK: [[T_VAR_ADDR:%.+]] = alloca i32,
// CHECK: [[VEC_ADDR:%.+]] = alloca [2 x i32],
// CHECK: [[S_ARR_ADDR:%.+]] = alloca [2 x [[S_INT_TY]]],
// CHECK: [[VAR_ADDR:%.+]] = alloca [[S_INT_TY]],
// CHECK: [[GTID:%.+]] = call i32 @__kmpc_global_thread_num(ptr [[LOC:@.+]])

// CHECK: call {{.*}} [[S_INT_TY_DEF_CONSTR:@.+]](ptr {{[^,]*}} [[TEST]])

// Do not store original variables in capture struct.
// CHECK-NOT: getelementptr inbounds [[CAP_TMAIN_TY]],

// Allocate task.
// Returns struct kmp_task_t {
//         [[KMP_TASK_T_TY]] task_data;
//         [[KMP_TASK_TMAIN_TY]] privates;
//       };
// CHECK: [[RES:%.+]] = call ptr @__kmpc_omp_task_alloc(ptr [[LOC]], i32 [[GTID]], i32 9, i64 256, i64 1, ptr [[TASK_ENTRY:@[^ ]+]])

// CHECK: [[TASK:%.+]] = getelementptr inbounds nuw [[KMP_TASK_TMAIN_TY]], ptr [[RES]], i{{[0-9]+}} 0, i{{[0-9]+}} 0

// Initialize kmp_task_t->privates with default values (no init for simple types, default constructors for classes).
// CHECK: [[PRIVATES:%.+]] = getelementptr inbounds nuw [[KMP_TASK_TMAIN_TY]], ptr [[RES]], i{{[0-9]+}} 0, i{{[0-9]+}} 2

// Constructors for s_arr and var.
// a_arr;
// CHECK: [[PRIVATE_S_ARR_REF:%.+]] = getelementptr inbounds nuw [[PRIVATES_TMAIN_TY]], ptr [[PRIVATES]], i{{[0-9]+}} 0, i{{[0-9]+}} 2
// CHECK: getelementptr inbounds [2 x [[S_INT_TY]]], ptr [[PRIVATE_S_ARR_REF]], i{{.+}} 0, i{{.+}} 0
// CHECK: getelementptr inbounds [[S_INT_TY]], ptr %{{.+}}, i{{.+}} 2
// CHECK: call void [[S_INT_TY_DEF_CONSTR]](ptr {{[^,]*}} [[S_ARR_CUR:%.+]])
// CHECK: getelementptr inbounds [[S_INT_TY]], ptr [[S_ARR_CUR]], i{{.+}} 1
// CHECK: icmp eq
// CHECK: br i1

// var;
// CHECK: [[PRIVATE_VAR_REF:%.+]] = getelementptr inbounds nuw [[PRIVATES_TMAIN_TY]], ptr [[PRIVATES]], i{{.+}} 0, i{{.+}} 3
// CHECK: call void [[S_INT_TY_DEF_CONSTR]](ptr {{[^,]*}} [[PRIVATE_VAR_REF:%.+]])

// Provide pointer to destructor function, which will destroy private variables at the end of the task.
// CHECK: [[DESTRUCTORS_REF:%.+]] = getelementptr inbounds nuw [[KMP_TASK_T_TY]], ptr [[TASK]], i{{.+}} 0, i{{.+}} 3
// CHECK: store ptr [[DESTRUCTORS:@.+]], ptr [[DESTRUCTORS_REF]],

// Start task.
// CHECK: call i32 @__kmpc_omp_task(ptr [[LOC]], i32 [[GTID]], ptr [[RES]])

// No destructors must be called for private copies of s_arr and var.
// CHECK-NOT: getelementptr inbounds nuw [[PRIVATES_TMAIN_TY]], ptr [[PRIVATES]], i{{.+}} 0, i{{.+}} 2
// CHECK-NOT: getelementptr inbounds nuw [[PRIVATES_TMAIN_TY]], ptr [[PRIVATES]], i{{.+}} 0, i{{.+}} 3
// CHECK: call void [[S_INT_TY_DESTR:@.+]](ptr
// CHECK-NOT: getelementptr inbounds nuw [[PRIVATES_TMAIN_TY]], ptr [[PRIVATES]], i{{.+}} 0, i{{.+}} 2
// CHECK-NOT: getelementptr inbounds nuw [[PRIVATES_TMAIN_TY]], ptr [[PRIVATES]], i{{.+}} 0, i{{.+}} 3
// CHECK: ret
//

// CHECK: define internal void [[PRIVATES_MAP_FN:@.+]](ptr noalias noundef %0, ptr noalias noundef %1, ptr noalias noundef %2, ptr noalias noundef %3, ptr noalias noundef %4)
// CHECK: [[PRIVATES:%.+]] = load ptr, ptr
// CHECK: [[PRIV_T_VAR:%.+]] = getelementptr inbounds nuw [[PRIVATES_TMAIN_TY]], ptr [[PRIVATES]], i32 0, i32 0
// CHECK: [[ARG1:%.+]] = load ptr, ptr %{{.+}},
// CHECK: store ptr [[PRIV_T_VAR]], ptr [[ARG1]],
// CHECK: [[PRIV_VEC:%.+]] = getelementptr inbounds nuw [[PRIVATES_TMAIN_TY]], ptr [[PRIVATES]], i32 0, i32 1
// CHECK: [[ARG2:%.+]] = load ptr, ptr %{{.+}},
// CHECK: store ptr [[PRIV_VEC]], ptr [[ARG2]],
// CHECK: [[PRIV_S_VAR:%.+]] = getelementptr inbounds nuw [[PRIVATES_TMAIN_TY]], ptr [[PRIVATES]], i32 0, i32 2
// CHECK: [[ARG3:%.+]] = load ptr, ptr %{{.+}},
// CHECK: store ptr [[PRIV_S_VAR]], ptr [[ARG3]],
// CHECK: [[PRIV_VAR:%.+]] = getelementptr inbounds nuw [[PRIVATES_TMAIN_TY]], ptr [[PRIVATES]], i32 0, i32 3
// CHECK: [[ARG4:%.+]] = load ptr, ptr {{.+}},
// CHECK: store ptr [[PRIV_VAR]], ptr [[ARG4]],
// CHECK: ret void

// CHECK: define internal noundef i32 [[TASK_ENTRY]](i32 noundef %0, ptr noalias noundef %1)

// CHECK: %__context
// CHECK-DAG: [[PRIV_T_VAR_ADDR:%.+]] = alloca ptr,
// CHECK-DAG: [[PRIV_VEC_ADDR:%.+]] = alloca ptr,
// CHECK-DAG: [[PRIV_S_ARR_ADDR:%.+]] = alloca ptr,
// CHECK-DAG: [[PRIV_VAR_ADDR:%.+]] = alloca ptr,
// CHECK: store ptr [[PRIVATES_MAP_FN]], ptr [[MAP_FN_ADDR:%.+]],
// CHECK: [[MAP_FN:%.+]] = load ptr, ptr [[MAP_FN_ADDR]],
// CHECK: call void [[MAP_FN]](ptr %{{.+}}, ptr [[PRIV_T_VAR_ADDR]], ptr [[PRIV_VEC_ADDR]], ptr [[PRIV_S_ARR_ADDR]], ptr [[PRIV_VAR_ADDR]])
// CHECK: [[PRIV_T_VAR:%.+]] = load ptr, ptr [[PRIV_T_VAR_ADDR]],
// CHECK: [[PRIV_VEC:%.+]] = load ptr, ptr [[PRIV_VEC_ADDR]],
// CHECK: [[PRIV_S_ARR:%.+]] = load ptr, ptr [[PRIV_S_ARR_ADDR]],
// CHECK: [[PRIV_VAR:%.+]] = load ptr, ptr [[PRIV_VAR_ADDR]],

// Privates actually are used.
// CHECK-DAG: [[PRIV_VAR]]
// CHECK-DAG: [[PRIV_T_VAR]]
// CHECK-DAG: [[PRIV_S_ARR]]
// CHECK-DAG: [[PRIV_VEC]]

// CHECK: ret

// CHECK: define internal noundef i32 [[DESTRUCTORS]](i32 noundef %0, ptr noalias noundef %1)
// CHECK: [[PRIVATES:%.+]] = getelementptr inbounds nuw [[KMP_TASK_TMAIN_TY]], ptr [[RES_KMP_TASK:%.+]], i{{[0-9]+}} 0, i{{[0-9]+}} 2
// CHECK: [[PRIVATE_S_ARR_REF:%.+]] = getelementptr inbounds nuw [[PRIVATES_TMAIN_TY]], ptr [[PRIVATES]], i{{.+}} 0, i{{.+}} 2
// CHECK: [[PRIVATE_VAR_REF:%.+]] = getelementptr inbounds nuw [[PRIVATES_TMAIN_TY]], ptr [[PRIVATES]], i{{.+}} 0, i{{.+}} 3
// CHECK: call void [[S_INT_TY_DESTR]](ptr {{[^,]*}} [[PRIVATE_VAR_REF]])
// CHECK: getelementptr inbounds [2 x [[S_INT_TY]]], ptr [[PRIVATE_S_ARR_REF]], i{{.+}} 0, i{{.+}} 0
// CHECK: getelementptr inbounds [[S_INT_TY]], ptr %{{.+}}, i{{.+}} 2
// CHECK: [[PRIVATE_S_ARR_ELEM_REF:%.+]] = getelementptr inbounds [[S_INT_TY]], ptr %{{.+}}, i{{.+}} -1
// CHECK: call void [[S_INT_TY_DESTR]](ptr {{[^,]*}} [[PRIVATE_S_ARR_ELEM_REF]])
// CHECK: icmp eq
// CHECK: br i1
// CHECK: ret i32

#endif
#else
// ARRAY-LABEL: array_func
struct St {
  int a, b;
  St() : a(0), b(0) {}
  St &operator=(const St &) { return *this; };
  ~St() {}
}
;
void array_func(int n, float a[n], St s[2]) {
// ARRAY: call ptr @__kmpc_omp_task_alloc(
// ARRAY: call i32 @__kmpc_omp_task(
// ARRAY: store ptr %{{.+}}, ptr %{{.+}},
// ARRAY: store ptr %{{.+}}, ptr %{{.+}},
#pragma omp task private(a, s)
  ;
}
#endif
