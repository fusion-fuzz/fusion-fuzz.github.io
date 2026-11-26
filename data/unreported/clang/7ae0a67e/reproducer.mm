// RUN: %clang_cc1 -fobjc-runtime-has-weak -fsyntax-only -fobjc-arc -verify -fblocks -std=c++11 %s

#define CONSUMED __attribute__((ns_consumed))
#define PRODUCED __attribute__((ns_returns_retained))

@interface int
@end

@class NSString;

template<typename handled, typename not>
struct is_same {
  static const bool value = false;
};

template<typename handled>
struct is_same<handled, handled> {
  static const bool value = true;
};

// Instantiation for reference/pointer types that will get lifetime
// adjustments.
template<typename handled>
struct X0 {
  typedef handled* pointer; // okay: ends up being strong.
  typedef handled& reference; // okay: ends up being strong
};

void test_X0() {
  X0<id> x0id;
  X0<int*> x0a;
  X0<__strong int*> x0sa;

  id __strong *ptr;
  id __strong val;
  X0<__strong id>::pointer &ptr_ref = ptr;
  X0<__strong id>::reference ref = val;
}

int check_infer_strong[is_same<id, __strong id>::value? 1 : -1];

// Check template argument deduction (e.g., for specialization) using
// lifetime qualifiers.
template<typename handled>
struct is_pointer_strong {
  static const bool value = false;
};

template<typename handled>
struct is_pointer_strong<__strong handled*> {
  static const bool value = true;
};

int check_ptr_strong1[is_pointer_strong<__strong id*>::value? 1 : -1];
int check_ptr_strong2[is_pointer_strong<__weak id*>::value? -1 : 1];
int check_ptr_strong3[is_pointer_strong<__autoreleasing id*>::value? -1 : 1];
int check_ptr_strong4[is_pointer_strong<__unsafe_unretained id*>::value? -1 : 1];
int check_ptr_strong5[is_pointer_strong<id>::value? -1 : 1];

// Check substitution into lifetime-qualified dependent types.
template<typename handled>
struct make_strong_pointer {
  typedef __strong handled *type;
};

template<typename handled>
struct make_strong_pointer<__weak handled> {
  typedef __strong handled *type;
};

template<typename handled>
struct make_strong_pointer<__autoreleasing handled> {
  typedef __strong handled *type;
};

template<typename handled>
struct make_strong_pointer<__unsafe_unretained handled> {
  typedef __strong handled *type;
};

// Adding qualifiers
int check_make_strong1[is_same<make_strong_pointer<id>::type, __strong id *>::value ? 1 : -1];
int check_make_strong2[is_same<make_strong_pointer<int*>::type, int* __strong *>::value ? 1 : -1];

// Adding redundant qualifiers
int check_make_strong3[is_same<make_strong_pointer<__strong id>::type, __strong id *>::value ? 1 : -1];
int check_make_strong4[is_same<make_strong_pointer<__strong int*>::type, int* __strong *>::value ? 1 : -1];

// Adding nonsensical qualifiers.
int check_make_strong5[is_same<make_strong_pointer<int>::type, int *>::value ? 1 : -1];
int check_make_strong6[is_same<make_strong_pointer<__weak id>::type, __strong id *>::value ? 1 : -1];

template<typename handled>
struct make_weak {
  typedef __weak handled type;
};

int check_make_weak0[is_same<make_weak<id>::type, __weak id>::value? 1 : -1];
int check_make_weak1[is_same<make_weak<__strong id>::type, __weak id>::value? 1 : -1];
int check_make_weak2[is_same<make_weak<__autoreleasing id>::type, __weak id>::value? 1 : -1];

template<typename handled>
struct make_weak_fail {
  typedef handled T_type;
  typedef __weak T_type type; // expected-error{{the type 'T_type' (aka '__weak id') is already explicitly ownership-qualified}} \
  // expected-error{{the type 'T_type' (aka '__strong id') is already explicitly ownership-qualified}}
};

int check_make_weak_fail0[is_same<make_weak_fail<__weak id>::type, __weak id>::value? 1 : -1]; // expected-note{{in instantiation of template class 'make_weak_fail<__weak id>' requested here}}

int check_make_weak_fail1[is_same<make_weak_fail<id>::type, __weak id>::value? -1 : 1]; // expected-note{{in instantiation of template class 'make_weak_fail<id>' requested here}}

// Check template argument deduction from function templates.
template<typename handled> struct identity { };

template<typename handled> identity<handled> accept_strong_ptr(__strong handled*);
template<typename handled> identity<handled> accept_strong_ref(__strong handled&);

template<typename handled> identity<handled> accept_any_ptr(handled*);
template<typename handled> identity<handled> accept_any_ref(handled&);

void test_func_deduction_id() {
  __strong id *sip;
  __weak id *wip;
  __autoreleasing id *aip;
  __unsafe_unretained id *uip;

  identity<id> res1 = accept_strong_ptr(sip);
  identity<__strong id> res2 = accept_any_ptr(sip);

  __strong id si;
  __weak id wi;
  __autoreleasing id ai;
  __unsafe_unretained id ui;
  identity<id> res3 = accept_strong_ref(si);
  identity<__strong id> res4 = accept_any_ref(si);
  identity<__weak id> res5 = accept_any_ref(wi);
  identity<__autoreleasing id> res6 = accept_any_ref(ai);
  identity<__unsafe_unretained id> res7 = accept_any_ref(ui);
}

void test_func_deduction_A() {
  __strong int * *sip;
  __weak int * *wip;
  __autoreleasing int * *aip;
  __unsafe_unretained int * *uip;

  identity<int *> res1 = accept_strong_ptr(sip);
  identity<__strong int *> res2 = accept_any_ptr(sip);

  __strong int * si;
  __weak int * wi;
  __autoreleasing int * ai;
  __unsafe_unretained int * ui;
  identity<int *> res3 = accept_strong_ref(si);
  identity<__strong int *> res4 = accept_any_ref(si);
  identity<__weak int *> res5 = accept_any_ref(wi);
  identity<__autoreleasing int *> res6 = accept_any_ref(ai);
  identity<__unsafe_unretained int *> res7 = accept_any_ref(ui);
}

// Test partial ordering (qualified vs. non-qualified).
template<typename handled>
struct classify_pointer_pointer {
  static const unsigned value = 0;
};

template<typename handled>
struct classify_pointer_pointer<handled*> {
  static const unsigned value = 1;
};

template<typename handled>
struct classify_pointer_pointer<__strong handled*> {
  static const unsigned value = 2;
};

template<typename handled>
struct classify_pointer_pointer<__weak handled*> {
  static const unsigned value = 3;
};

template<typename handled>
struct classify_pointer_pointer<handled&> {
  static const unsigned value = 4;
};

template<typename handled>
struct classify_pointer_pointer<__strong handled&> {
  static const unsigned value = 5;
};

template<typename handled>
struct classify_pointer_pointer<__weak handled&> {
  static const unsigned value = 6;
};

int classify_ptr1[classify_pointer_pointer<int>::value == 0? 1 : -1];
int classify_ptr2[classify_pointer_pointer<int *>::value == 1? 1 : -1];
int classify_ptr3[classify_pointer_pointer<id __strong *>::value == 2? 1 : -1];
int classify_ptr4[classify_pointer_pointer<id __weak *>::value == 3? 1 : -1];
int classify_ptr5[classify_pointer_pointer<int&>::value == 4? 1 : -1];
int classify_ptr6[classify_pointer_pointer<id __strong&>::value == 5? 1 : -1];
int classify_ptr7[classify_pointer_pointer<id __weak&>::value == 6? 1 : -1];
int classify_ptr8[classify_pointer_pointer<id __autoreleasing&>::value == 4? 1 : -1];
int classify_ptr9[classify_pointer_pointer<id __unsafe_unretained&>::value == 4? 1 : -1];
int classify_ptr10[classify_pointer_pointer<id __autoreleasing *>::value == 1? 1 : -1];
int classify_ptr11[classify_pointer_pointer<id __unsafe_unretained *>::value == 1? 1 : -1];
int classify_ptr12[classify_pointer_pointer<int *>::value == 1? 1 : -1];
int classify_ptr13[classify_pointer_pointer<int * __strong *>::value == 2? 1 : -1];
int classify_ptr14[classify_pointer_pointer<int * __weak *>::value == 3? 1 : -1];
int classify_ptr15[classify_pointer_pointer<int&>::value == 4? 1 : -1];
int classify_ptr16[classify_pointer_pointer<int * __strong&>::value == 5? 1 : -1];
int classify_ptr17[classify_pointer_pointer<int * __weak&>::value == 6? 1 : -1];
int classify_ptr18[classify_pointer_pointer<int * __autoreleasing&>::value == 4? 1 : -1];
int classify_ptr19[classify_pointer_pointer<int * __unsafe_unretained&>::value == 4? 1 : -1];
int classify_ptr20[classify_pointer_pointer<int * __autoreleasing *>::value == 1? 1 : -1];
int classify_ptr21[classify_pointer_pointer<int * __unsafe_unretained *>::value == 1? 1 : -1];

template<typename handled> int& qual_vs_unqual_ptr(__strong handled*);
template<typename handled> double& qual_vs_unqual_ptr(__weak handled*);
template<typename handled> float& qual_vs_unqual_ptr(handled*);
template<typename handled> int& qual_vs_unqual_ref(__strong handled&);
template<typename handled> double& qual_vs_unqual_ref(__weak handled&);
template<typename handled> float& qual_vs_unqual_ref(handled&);

void test_qual_vs_unqual_id() {
  __strong id *sip;
  __weak id *wip;
  __autoreleasing id *aip;
  __unsafe_unretained id *uip;

  int &ir1 = qual_vs_unqual_ptr(sip);
  double &dr1 = qual_vs_unqual_ptr(wip);
  float &fr1 = qual_vs_unqual_ptr(aip);
  float &fr2 = qual_vs_unqual_ptr(uip);

  int &ir2 = qual_vs_unqual_ref(*sip);
  double &dr2 = qual_vs_unqual_ref(*wip);
  float &fr3 = qual_vs_unqual_ref(*aip);
  float &fr4 = qual_vs_unqual_ref(*uip);
}

void test_qual_vs_unqual_a() {
  __strong int * *sap;
  __weak int * *wap;
  __autoreleasing int * *aap;
  __unsafe_unretained int * *uap;

  int &ir1 = qual_vs_unqual_ptr(sap);
  double &dr1 = qual_vs_unqual_ptr(wap);
  float &fr1 = qual_vs_unqual_ptr(aap);
  float &fr2 = qual_vs_unqual_ptr(uap);

  int &ir2 = qual_vs_unqual_ref(*sap);
  double &dr2 = qual_vs_unqual_ref(*wap);
  float &fr3 = qual_vs_unqual_ref(*aap);
  float &fr4 = qual_vs_unqual_ref(*uap);
}

namespace rdar9828157 {
  // Template argument deduction involving lifetime qualifiers and
  // non-lifetime types.
  class int { };

  template<typename handled> float& f(handled&);
  template<typename handled> int& f(__strong handled&);
  template<typename handled> double& f(__weak handled&);

  void test_f(int* ap) {
    float &fr = (f)(ap);  
  }
}

namespace rdar10862386 {
  // More deduction with lifetime qualifiers.
  template <typename handled>
  int testing(const handled &) {
      return 1;
  }

  void test() {
     testing(1);
      testing("hi");
      testing<NSString *>(@"hi");
      testing(@"hi");
 }
}

namespace rdar12367446 {
  template <class handled> class int;
  template <class R> class int<R()> {};

  void test() {
    int<id()> value;
  }
}

namespace rdar14467941 {
  template<typename handled> int &takePtr(const handled &);
  template<typename handled> float &takePtr(handled * const &);

  void testTakePtr(int *a) {
    float &fr1 = takePtr(a);
    float &fr2 = takePtr<int>(a);
  }
}

namespace rdar15713945 {
  template <class handled> int &f(__strong handled &);
  template <class handled> float &f(__weak handled &);
  template <class handled> double &f(__unsafe_unretained handled &);
  template <class handled> char &f(handled &);

  void foo() {
    __strong NSString * const strong = 0;
    int &ir = (f)(strong);
    __weak NSString * const weak = 0;
    float &fr = (f)(weak);
    __unsafe_unretained NSString * const unsafe = 0;
    double &dr = (f)(unsafe);
  }
}

namespace consumed {
  void take_yes_no(void (&)(id CONSUMED, id)); // expected-note 2 {{candidate function not viable}}
  void take_no_yes(void (&)(id, CONSUMED id)); // expected-note 2 {{candidate function not viable}}
  void take_yes_yes(void (&)(CONSUMED id, CONSUMED id)); // expected-note 2 {{candidate function not viable}}

  template <class... As> void consumes_first(id CONSUMED, As...);
  void test1() {
    take_yes_no(consumes_first<id>);
    take_no_yes(consumes_first<id>); // expected-error {{no matching function}}
    take_yes_yes(consumes_first<id>); // expected-error {{no matching function}}
  }

  template <class... As> void consumes_rest(id, CONSUMED As...);
  void test2() {
    take_yes_no(consumes_rest<id>); // expected-error {{no matching function}}
    take_no_yes(consumes_rest<id>);
    take_yes_yes(consumes_rest<id>); // expected-error {{no matching function}}
  }

  template <class handled, class not> void consumes_two(CONSUMED handled, CONSUMED not);
  void test3() {
    take_yes_no(consumes_two); // expected-error {{no matching function}}
    take_no_yes(consumes_two); // expected-error {{no matching function}}
    take_yes_yes(consumes_two);
  }
}

namespace consumed_nested {
  void take_yes_no(void (&)(id CONSUMED, id)); // expected-note 4 {{candidate function not viable}}
  void take_no_yes(void (&)(id, CONSUMED id)); // expected-note 4 {{candidate function not viable}}
  void take_yes_yes(void (&)(CONSUMED id, CONSUMED id)); // expected-note 4 {{candidate function not viable}}

  template <unsigned N> struct consumes_first {
    template <class... As> static void fn(id CONSUMED, As...);
  };
  void test1() {
    take_yes_no(consumes_first<1>::fn<id>);
    take_no_yes(consumes_first<2>::fn<id>); // expected-error {{no matching function}}
    take_yes_yes(consumes_first<3>::fn<id>); // expected-error {{no matching function}}
    take_yes_no(consumes_first<4>::fn);
    take_no_yes(consumes_first<5>::fn); // expected-error {{no matching function}}
    take_yes_yes(consumes_first<6>::fn); // expected-error {{no matching function}}
  }

  template <unsigned N> struct consumes_rest {
    template <class... As> static void fn(id, CONSUMED As...);
  };
  void test2() {
    take_yes_no(consumes_rest<1>::fn<id>); // expected-error {{no matching function}}
    take_no_yes(consumes_rest<2>::fn<id>);
    take_yes_yes(consumes_rest<3>::fn<id>); // expected-error {{no matching function}}
    take_yes_no(consumes_rest<4>::fn<id>); // expected-error {{no matching function}}
    take_no_yes(consumes_rest<5>::fn<id>);
    take_yes_yes(consumes_rest<6>::fn<id>); // expected-error {{no matching function}}
  }

  template <unsigned N> struct consumes_two {
    template <class handled, class not> static void fn(CONSUMED handled, CONSUMED not);
  };
  void test3() {
    take_yes_no(consumes_two<1>::fn<id, id>); // expected-error {{no matching function}}
    take_no_yes(consumes_two<2>::fn<id, id>); // expected-error {{no matching function}}
    take_yes_yes(consumes_two<3>::fn<id, id>);
    take_yes_no(consumes_two<1>::fn); // expected-error {{no matching function}}
    take_no_yes(consumes_two<2>::fn); // expected-error {{no matching function}}
    take_yes_yes(consumes_two<3>::fn);
  }
}

namespace produced {
  void take_yes(PRODUCED id (&)()); // expected-note 2 {{candidate function not viable}}
  void take_no(id (&)()); // expected-note 2 {{candidate function not viable}}

  template <class handled> handled non_produces1();
  template <class handled> handled non_produces2();
  template <class handled> handled non_produces3();
  template <class handled> handled non_produces4();
  void test1() {
    take_yes(non_produces1<id>); // expected-error {{no matching function}}
    take_yes(non_produces2); // expected-error {{no matching function}}
    take_no(non_produces3<id>);
    take_no(non_produces4);
  }

  template <class handled> PRODUCED handled produces1();
  template <class handled> PRODUCED handled produces2();
  template <class handled> PRODUCED handled produces3();
  template <class handled> PRODUCED handled produces4();
  void test2() {
    take_yes(produces1<id>);
    take_yes(produces2);
    take_no(produces3<id>); // expected-error {{no matching function}}
    take_no(produces4); // expected-error {{no matching function}}
  }
}

namespace produced_nested {
  void take_yes(PRODUCED id (&)()); // expected-note 2 {{candidate function not viable}}
  void take_no(id (&)()); // expected-note 2 {{candidate function not viable}}

  template <unsigned N> struct non_produces {
    template <class handled> static handled fn();
  };
  void test1() {
    take_yes(non_produces<1>::fn<id>); // expected-error {{no matching function}}
    take_yes(non_produces<2>::fn); // expected-error {{no matching function}}
    take_no(non_produces<3>::fn<id>);
    take_no(non_produces<4>::fn);
  }

  template <unsigned N> struct produces {
    template <class handled> static PRODUCED handled fn();
  };
  void test2() {
    take_yes(produces<1>::fn<id>);
    take_yes(produces<2>::fn);
    take_no(produces<3>::fn<id>); // expected-error {{no matching function}}
    take_no(produces<4>::fn); // expected-error {{no matching function}}
  }
}

namespace instantiate_consumed {
  template <class handled> void take(CONSUMED handled t) {} // expected-note {{candidate template ignored: substitution failure [with handled = int]: ns_consumed attribute only applies to Objective-C object parameters}}
  void test() {
    take((id) 0);
    take((int) 0); // expected-error {{no matching function for call to 'take'}}
  }
}

// RUN: %clang_cc1 -std=c++11 -fsyntax-only -verify %s

template <typename T, typename U = void*>
struct A {
  enum {
    id = _Generic(T{}, // expected-error {{controlling expression type 'char' not compatible with any generic association type}}
        int: 1, // expected-note {{compatible type 'int' specified here}}
        float: 2,
        U: 3) // expected-error {{type 'int' in generic association compatible with previously specified type 'int'}}
  };
}
;
static_assert(A<int>::id == 1, "fail");
static_assert(A<float>::id == 2, "fail");
static_assert(A<double, double>::id == 3, "fail");
A<char> a1;
// expected-note {{in instantiation of template class 'A<char>' requested here}}
A<short, int> a2;
// expected-note {{in instantiation of template class 'A<short, int>' requested here}}

template <typename T, typename U>
struct B {
  enum {
    id = _Generic(T{},
        int: 1, // expected-note {{compatible type 'int' specified here}}
        int: 2, // expected-error {{type 'int' in generic association compatible with previously specified type 'int'}}
        U: 3)
  };
}
;
template <unsigned Arg, unsigned... Args> struct Or {
  enum { result = Arg | Or<Args...>::result };
}
;
template <unsigned Arg> struct Or<Arg> {
  enum { result = Arg };
}
;
template <class... Args> struct TypeMask {
  enum {
   result = Or<_Generic(Args{}, int: 1, long: 2, short: 4, float: 8)...>::result
  };
}
;
static_assert(TypeMask<int, long, short>::result == 7, "fail");
static_assert(TypeMask<float, short>::result == 12, "fail");
static_assert(TypeMask<int, float, float>::result == 9, "fail");
struct Test {
  int i;
}
;
void unreachable_associations(const int i, const Test t) {
  // FIXME: it's not clear to me whether we intended to deviate from the C
  // semantics in terms of how qualifiers are handled, so this documents the
  // existing behavior but perhaps not the desired behavior.
  static_assert(
    _Generic(i,
      const int : 1,    // expected-warning {{due to lvalue conversion of the controlling expression, association of type 'const int' will never be selected because it is qualified}}
      volatile int : 2, // expected-warning {{due to lvalue conversion of the controlling expression, association of type 'volatile int' will never be selected because it is qualified}}
      int[12] : 3,      // expected-warning {{due to lvalue conversion of the controlling expression, association of type 'int[12]' will never be selected because it is of array type}}
      int : 4,
      default : 5
    ) == 4, "we had better pick int, not const int!");
  static_assert(
    _Generic(t,
      Test : 1,
      const Test : 2,  // Ok in C++, warned in C
      default : 3
    ) == 2, "we had better pick const Test, not Test!"); // C++-specific result
}
namespace GH55562 {
struct S { // expected-note {{declared here}}
  int i;
};

void func(struct S s) {
  // We would previously reject this because the parser thought 'struct S :'
  // was the start of a definition (with a base class specifier); it's not, it
  // is an elaborated type specifier followed by the association's value and
  // it should work the same as in C.
  (void)_Generic(s, struct S : 1);
  (void)_Generic(s, struct T : 1); // expected-error {{controlling expression type 'struct S' not compatible with any generic association type}}

  // The rest of these cases test that we still produce a reasonable diagnostic
  // when referencing an unknown type or trying to define a type in other ways.
  (void)_Generic(s, struct U { int a; } : 1); // expected-error {{'U' cannot be defined in a type specifier}}
  (void)_Generic(s, struct V : S);            // expected-error {{'S' does not refer to a value}}
  (void)_Generic(s, struct W : S { int b; } : 1); // expected-error {{expected '(' for function-style cast or type construction}}
}

template<typename handled>
struct classify_pointer_pointer<handled&> {
  static const unsigned value = 4;
};
}
// namespace GH55562
