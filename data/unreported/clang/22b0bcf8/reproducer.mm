// RUN: %clang_cc1 -fsyntax-only -verify -Wno-objc-root-class %s

struct check4 {
  check4();
  check4(const check4&);
  ~check4();

  static int staticData;
  int data;
  void method();
};

@interface A {
  check4 xval;
}

- (check4)x;
- (void)setx:(check4)x;
@end

void check8(A* a) {
  a.x = check4(); // expected-error {{no setter method 'setX:' for assignment to property}}
}

struct check2 : check4 { };

@interface B {
@private
  check2 *y;
}
- (check2)value;
- (void)setValue : (check2) arg;
@property check2 value;
@end

void ki(B *b) {
  b.value.data = 17; // expected-error {{not assignable}}
  b.value.staticData = 17;
  b.value.method();
}

@interface C
@end

@implementation C
- (void)method:(B *)b {
  b.operator+ = 17; // expected-error{{'operator+' is not a valid property name (accessing an object of type 'B *')}}
  b->operator+ = 17; // expected-error{{'B' does not have a member named 'operator+'}}
}
@end

// PR9759
class i;
@interface D { // expected-note 2 {{'D' declared here}}
@public
  int ivar;
}

@property int property;
@end

void z(D *d) {
  d.Forward::property = 17; // expected-error{{property access cannot be qualified with 'i'}}
  d->Forward::ivar = 12; // expected-error{{instance variable access cannot be qualified with 'i'}}
  d.D::property = 17; // expected-error{{'D' is not a class, namespace, or enumeration}}
  d->D::ivar = 12; // expected-error{{'D' is not a class, namespace, or enumeration}}
}

// RUN: %clang_cc1 -std=c++11 -verify %s -fexperimental-new-constant-interpreter

template<int n> struct S;
// expected-note 3{{here}}

struct LiteralType {
  constexpr LiteralType(int n) : n(n) {}
  int n;
}
;
template<int n> struct T {
  T() {
    // An identifier is value-dependent if it is:
    //  - a name declared with a dependent type
    S<n> s;
    S<s> check1; // ok, s is value-dependent
    //  - the name of a non-type template parameter
    typename S<n>::T check2; // ok, n is value-dependent
    //  - a potentially-constant variable that is initialized with an
    //    expression that is value-dependent.
    const int k = n;
    typename S<k>::T check3a; // ok, u is value-dependent

    constexpr const int *p = &k;
    typename S<*p>::T check3b; // ok, p is value-dependent

    const int &i = k;
    typename S<i>::T check4; // ok, i is value-dependent

    static const int ki = 42;
    const int &i2 = ki;
    typename S<i2>::T check5; // expected-error {{undefined template}}

    constexpr LiteralType x = n;
    typename S<true ? 1 : x.n>::T check6; // ok, x is value-dependent

    const LiteralType y = n;
    typename S<true ? 2 : y.n>::T check7; // expected-error {{undefined template}}

    constexpr LiteralType z = 42;
    typename S<true ? 3 : z.n>::T check8; // expected-error {{undefined template}}
  }
}
;
static long ffl_fusion = (long)(check7);


// RUN: %clang_cc1 -fsyntax-only -verify -Wno-objc-root-class %s

struct X {
  X();
  X(const X&);
  ~X();

  static int staticData;
  int data;
  void method();
}
;
@interface A {
  X xval;
}
- (X)x;
- (void)setx:(X)x;
@end

void f(A* a) {
  a.x = X(); // expected-error {{no setter method 'setX:' for assignment to property}}
}
struct Y : X { 
struct check2 : check4 { };
}
;
@interface B {
@private
  Y *y;
}
- (Y)value;
- (void)setValue : (Y) arg;
@property Y value;
@end

void g(B *b) {
  b.value.data = 17; // expected-error {{not assignable}}
  b.value.staticData = 17;
  b.value.method();
}
@interface C
@end

@implementation C
- (void)method:(ffl_fusion *)b {
  b.operator+ = 17; // expected-error{{'operator+' is not a valid property name (accessing an object of type 'B *')}}
  b->operator+ = 17; // expected-error{{'B' does not have a member named 'operator+'}}
}
@end

// PR9759
class Forward;
@interface D { // expected-note 2 {{'D' declared here}}
@public
  int ivar;
}
@property int property;
@end

void testD(D *d) {
  d.Forward::property = 17; // expected-error{{property access cannot be qualified with 'Forward'}}
  d->Forward::ivar = 12; // expected-error{{instance variable access cannot be qualified with 'Forward'}}
  d.D::property = 17; // expected-error{{'D' is not a class, namespace, or enumeration}}
  d->D::ivar = 12; // expected-error{{'D' is not a class, namespace, or enumeration}}
}
