
// RUN: %clang_cc1 -std=c++2c -fsyntax-only -verify %s

struct S {
  void f() = delete("deleted (1)"); // expected-note {{explicitly marked deleted}}

  template <typename T>
  T g() = delete("deleted (2)"); // expected-note {{explicitly deleted}}
};

template <typename T>
struct TS {
  T f() = delete("deleted (3)"); // expected-note {{explicitly marked deleted}}

  template <typename U>
  T g(U) = delete("deleted (4)"); // expected-note {{explicitly deleted}}
};

void f() = delete("deleted (5)"); // expected-note {{explicitly deleted}}

template <typename T>
T g() = delete("deleted (6)"); // expected-note {{explicitly deleted}}

template <typename T, typename U>
struct TSp {
  T f() = delete("deleted (7)"); // expected-note 2 {{explicitly marked deleted}}
};

template <typename T>
struct TSp<T, int> {
  T f() = delete("deleted (8)"); // expected-note {{explicitly marked deleted}}
};

template <>
struct TSp<int, int> {
  int f() = delete("deleted (9)"); // expected-note {{explicitly marked deleted}}
};

void u1() = delete(L"\xFFFFFFFF"); // expected-error {{an unevaluated string literal cannot have an encoding prefix}} \
                                   // expected-error {{invalid escape sequence '\xFFFFFFFF' in an unevaluated string literal}}
void u2() = delete(u"\U000317FF"); // expected-error {{an unevaluated string literal cannot have an encoding prefix}}

void u3() = delete("Ω"); // expected-note {{explicitly deleted}}
void u4() = delete("\u1234"); // expected-note {{explicitly deleted}}

void u5() = delete("\x1ff"       // expected-error {{hex escape sequence out of range}} \
                                 // expected-error {{invalid escape sequence '\x1ff' in an unevaluated string literal}}
                     "0\x123"    // expected-error {{invalid escape sequence '\x123' in an unevaluated string literal}}
                     "fx\xfffff" // expected-error {{invalid escape sequence '\xfffff' in an unevaluated string literal}}
                     "goop");

void u6() = delete("\'\"\?\\\a\b\f\n\r\t\v"); // expected-note {{explicitly deleted}}
void u7() = delete("\xFF"); // expected-error {{invalid escape sequence '\xFF' in an unevaluated string literal}}
void u8() = delete("\123"); // expected-error {{invalid escape sequence '\123' in an unevaluated string literal}}
void u9() = delete("\pOh no, a Pascal string!"); // expected-warning {{unknown escape sequence '\p'}} \
                                                 // expected-error {{invalid escape sequence '\p' in an unevaluated string literal}}
// expected-note@+1 {{explicitly deleted}}
void u10() = delete(R"(a
\tb
c
)");

void u11() = delete("\u0080\u0081\u0082\u0083\u0099\u009A\u009B\u009C\u009D\u009E\u009F"); // expected-note {{explicitly deleted}}


//! Contains RTL/LTR marks
void u12() = delete("\u200Eabc\u200Fdef\u200Fgh"); // expected-note {{explicitly deleted}}

//! Contains ZWJ/regional indicators
void u13() = delete("🏳️‍🌈 🏴󠁧󠁢󠁥󠁮󠁧󠁿 🇪🇺"); // expected-note {{explicitly deleted}}

void h() {
  S{}.f(); // expected-error {{attempt to use a deleted function: deleted (1)}}
  S{}.g<int>(); // expected-error {{call to deleted member function 'g': deleted (2)}}
  TS<int>{}.f(); // expected-error {{attempt to use a deleted function: deleted (3)}}
  TS<int>{}.g<int>(0); // expected-error {{call to deleted member function 'g': deleted (4)}}
  f(); // expected-error {{call to deleted function 'f': deleted (5)}}
  g<int>(); // expected-error {{call to deleted function 'g': deleted (6)}}
  TSp<double, double>{}.f(); // expected-error {{attempt to use a deleted function: deleted (7)}}
  TSp<int, double>{}.f(); // expected-error {{attempt to use a deleted function: deleted (7)}}
  TSp<double, int>{}.f(); // expected-error {{attempt to use a deleted function: deleted (8)}}
  TSp<int, int>{}.f(); // expected-error {{attempt to use a deleted function: deleted (9)}}
  u3(); // expected-error {{call to deleted function 'u3': Ω}}
  u4(); // expected-error {{call to deleted function 'u4': ሴ}}
  u6(); // expected-error {{call to deleted function 'u6': '"?\<U+0007><U+0008>}}
  u10(); // expected-error {{call to deleted function 'u10': a\n\tb\nc\n}}
  u11(); // expected-error {{call to deleted function 'u11': <U+0080><U+0081><U+0082><U+0083><U+0099><U+009A><U+009B><U+009C><U+009D><U+009E><U+009F>}}
  u12(); // expected-error {{call to deleted function 'u12': ‎abc‏def‏gh}}
  u13(); // expected-error {{call to deleted function 'u13': 🏳️‍🌈 🏴󠁧󠁢󠁥󠁮󠁧󠁿 🇪🇺}}
}

struct C {
  C() = delete("deleted (C, Constructor)"); // expected-note {{explicitly marked deleted}}
  C(int) = delete("deleted (C, C(int))"); // expected-note {{explicitly marked deleted}}
  C(const C&) = delete("deleted (C, Copy Constructor)"); // expected-note {{explicitly marked deleted}}
  C(C&&) = delete("deleted (C, Move Constructor)"); // expected-note {{explicitly marked deleted}}
  C& operator=(const C&) = delete("deleted (C, Copy Assignment)"); // expected-note 2 {{explicitly deleted}}
  C& operator=(C&&) = delete("deleted (C, Move Assignment)"); // expected-note {{explicitly deleted}} expected-note {{not viable}}
  ~C() = delete("deleted (C, Destructor)"); // expected-note {{explicitly marked deleted}}
  void* operator new(__SIZE_TYPE__) = delete("deleted (C, New)"); // expected-note {{explicitly deleted}}
  void operator delete(void*) = delete("deleted (C, Delete)"); // expected-note {{explicitly marked deleted}}
};

template <typename T, typename U>
struct TC {
  TC() = delete("deleted (TC, Constructor)"); // expected-note {{explicitly marked deleted}}
  TC(int) = delete("deleted (TC, TC(int))"); // expected-note {{explicitly marked deleted}}
  TC(const TC&) = delete("deleted (TC, Copy Constructor)"); // expected-note {{explicitly marked deleted}}
  TC(TC&&) = delete("deleted (TC, Move Constructor)"); // expected-note {{explicitly marked deleted}}
  TC& operator=(const TC&) = delete("deleted (TC, Copy Assignment)"); // expected-note 2 {{explicitly deleted}}
  TC& operator=(TC&&) = delete("deleted (TC, Move Assignment)");  // expected-note {{explicitly deleted}} expected-note {{not viable}}
  ~TC() = delete("deleted (TC, Destructor)"); // expected-note {{explicitly marked deleted}}
  void* operator new(__SIZE_TYPE__) = delete("deleted (TC, New)"); // expected-note {{explicitly deleted}}
  void operator delete(void*) = delete("deleted (TC, Delete)"); // expected-note {{explicitly marked deleted}}
};

template <typename T>
struct TC<T, int> {
  TC() = delete("deleted (TC<T, int>, Constructor)"); // expected-note {{explicitly marked deleted}}
  TC(int) = delete("deleted (TC<T, int>, TC(int))"); // expected-note {{explicitly marked deleted}}
  TC(const TC&) = delete("deleted (TC<T, int>, Copy Constructor)"); // expected-note {{explicitly marked deleted}}
  TC(TC&&) = delete("deleted (TC<T, int>, Move Constructor)"); // expected-note {{explicitly marked deleted}}
  TC& operator=(const TC&) = delete("deleted (TC<T, int>, Copy Assignment)"); // expected-note 2 {{explicitly deleted}}
  TC& operator=(TC&&) = delete("deleted (TC<T, int>, Move Assignment)"); // expected-note {{explicitly deleted}} expected-note {{not viable}}
  ~TC() = delete("deleted (TC<T, int>, Destructor)"); // expected-note {{explicitly marked deleted}}
  void* operator new(__SIZE_TYPE__) = delete("deleted (TC<T, int>, New)"); // expected-note {{explicitly deleted}}
  void operator delete(void*) = delete("deleted (TC<T, int>, Delete)"); // expected-note {{explicitly marked deleted}}
};

template <>
struct TC<int, int> {
  TC() = delete("deleted (TC<int, int>, Constructor)"); // expected-note {{explicitly marked deleted}}
  TC(int) = delete("deleted (TC<int, int>, TC(int))"); // expected-note {{explicitly marked deleted}}
  TC(const TC&) = delete("deleted (TC<int, int>, Copy Constructor)"); // expected-note {{explicitly marked deleted}}
  TC(TC&&) = delete("deleted (TC<int, int>, Move Constructor)"); // expected-note {{explicitly marked deleted}}
  TC& operator=(const TC&) = delete("deleted (TC<int, int>, Copy Assignment)"); // expected-note 2 {{explicitly deleted}}
  TC& operator=(TC&&) = delete("deleted (TC<int, int>, Move Assignment)"); // expected-note {{explicitly deleted}} expected-note {{not viable}}
  ~TC() = delete("deleted (TC<int, int>, Destructor)"); // expected-note {{explicitly marked deleted}}
  void* operator new(__SIZE_TYPE__) = delete("deleted (TC<int, int>, New)"); // expected-note {{explicitly deleted}}
  void operator delete(void*) = delete("deleted (TC<int, int>, Delete)"); // expected-note {{explicitly marked deleted}}
};

void special_members(
  C& c1,
  C& c2,
  TC<double, double>& tc1,
  TC<double, double>& tc2,
  TC<double, int>& tc_int1,
  TC<double, int>& tc_int2,
  TC<int, int>& tc_int_int1,
  TC<int, int>& tc_int_int2
) {
  C{}; // expected-error {{call to deleted constructor of 'C': deleted (C, Constructor)}}
  C{c1}; // expected-error {{call to deleted constructor of 'C': deleted (C, Copy Constructor)}}
  C{static_cast<C&&>(c1)}; // expected-error {{call to deleted constructor of 'C': deleted (C, Move Constructor)}}
  c1 = c2; // expected-error {{overload resolution selected deleted operator '=': deleted (C, Copy Assignment)}}
  c1 = static_cast<C&&>(c2); // expected-error {{overload resolution selected deleted operator '=': deleted (C, Move Assignment)}}
  c1.~C(); // expected-error {{attempt to use a deleted function: deleted (C, Destructor)}}
  new C{}; // expected-error {{call to deleted function 'operator new': deleted (C, New)}}
  delete &c2; // expected-error {{attempt to use a deleted function: deleted (C, Delete)}}

  TC<double, double>{}; // expected-error {{call to deleted constructor of 'TC<double, double>': deleted (TC, Constructor)}}
  TC<double, double>{tc1}; // expected-error {{call to deleted constructor of 'TC<double, double>': deleted (TC, Copy Constructor)}}
  TC<double, double>{static_cast<TC<double, double>&&>(tc1)}; // expected-error {{call to deleted constructor of 'TC<double, double>': deleted (TC, Move Constructor)}}
  tc1 = tc2; // expected-error {{overload resolution selected deleted operator '=': deleted (TC, Copy Assignment)}}
  tc1 = static_cast<TC<double, double>&&>(tc2); // expected-error {{overload resolution selected deleted operator '=': deleted (TC, Move Assignment)}}
  tc1.~TC(); // expected-error {{attempt to use a deleted function: deleted (TC, Destructor)}}
  new TC<double, double>{}; // expected-error {{call to deleted function 'operator new': deleted (TC, New)}}
  delete &tc2; // expected-error {{attempt to use a deleted function: deleted (TC, Delete)}}

  TC<double, int>{}; // expected-error {{call to deleted constructor of 'TC<double, int>': deleted (TC<T, int>, Constructor)}}
  TC<double, int>{tc_int1}; // expected-error {{call to deleted constructor of 'TC<double, int>': deleted (TC<T, int>, Copy Constructor)}}
  TC<double, int>{static_cast<TC<double, int>&&>(tc_int1)}; // expected-error {{call to deleted constructor of 'TC<double, int>': deleted (TC<T, int>, Move Constructor)}}
  tc_int1 = tc_int2; // expected-error {{overload resolution selected deleted operator '=': deleted (TC<T, int>, Copy Assignment)}}
  tc_int1 = static_cast<TC<double, int>&&>(tc_int2); // expected-error {{overload resolution selected deleted operator '=': deleted (TC<T, int>, Move Assignment)}}
  tc_int1.~TC(); // expected-error {{attempt to use a deleted function: deleted (TC<T, int>, Destructor)}}
  new TC<double, int>{}; // expected-error {{call to deleted function 'operator new': deleted (TC<T, int>, New)}}
  delete &tc_int2; // expected-error {{attempt to use a deleted function: deleted (TC<T, int>, Delete)}}

  TC<int, int>{}; // expected-error {{call to deleted constructor of 'TC<int, int>': deleted (TC<int, int>, Constructor)}}
  TC<int, int>{tc_int_int1}; // expected-error {{call to deleted constructor of 'TC<int, int>': deleted (TC<int, int>, Copy Constructor)}}
  TC<int, int>{static_cast<TC<int, int>&&>(tc_int_int1)}; // expected-error {{call to deleted constructor of 'TC<int, int>': deleted (TC<int, int>, Move Constructor)}}
  tc_int_int1 = tc_int_int2; // expected-error {{overload resolution selected deleted operator '=': deleted (TC<int, int>, Copy Assignment)}}
  tc_int_int1 = static_cast<TC<int, int>&&>(tc_int_int2); // expected-error {{overload resolution selected deleted operator '=': deleted (TC<int, int>, Move Assignment)}}
  tc_int_int1.~TC(); // expected-error {{attempt to use a deleted function: deleted (TC<int, int>, Destructor)}}
  new TC<int, int>{}; // expected-error {{call to deleted function 'operator new': deleted (TC<int, int>, New)}}
  delete &tc_int_int2; // expected-error {{attempt to use a deleted function: deleted (TC<int, int>, Delete)}}
}

C conv1() { return 1; } // expected-error {{conversion function from 'int' to 'C' invokes a deleted function: deleted (C, C(int))}}
TC<double, double> conv2() { return 1; } // expected-error {{conversion function from 'int' to 'TC<double, double>' invokes a deleted function: deleted (TC, TC(int))}}
TC<double, int> conv3() { return 1; } // expected-error {{conversion function from 'int' to 'TC<double, int>' invokes a deleted function: deleted (TC<T, int>, TC(int))}}
TC<int, int> conv4() { return 1; } // expected-error {{conversion function from 'int' to 'TC<int, int>' invokes a deleted function: deleted (TC<int, int>, TC(int))}}

struct O {
  int x;
  int operator+() = delete("deleted (O, +)"); // expected-note {{explicitly deleted}}
  O* operator->() = delete("deleted (O, ->)"); // expected-note {{explicitly deleted}}
  int operator-(O) = delete("deleted (O, -)"); // expected-note {{explicitly deleted}}
  int operator[](O) = delete("deleted (O, [])"); // expected-note {{explicitly deleted}}
  int operator()(O) = delete("deleted (O, ())"); // expected-note {{explicitly marked deleted}} expected-note {{explicitly deleted}}
  explicit operator bool() = delete("deleted (O, operator bool)"); // expected-note {{explicitly marked deleted}} expected-note {{explicitly deleted}}
};

template <typename T, typename U>
struct TO {
  T x;
  T operator+() = delete("deleted (TO, +)"); // expected-note {{explicitly deleted}}
  T* operator->() = delete("deleted (TO, ->)"); // expected-note {{explicitly deleted}}
  T operator-(TO) = delete("deleted (TO, -)"); // expected-note {{explicitly deleted}}
  T operator[](TO) = delete("deleted (TO, [])"); // expected-note {{explicitly deleted}}
  T operator()(TO) = delete("deleted (TO, ())"); // expected-note {{explicitly marked deleted}} expected-note {{explicitly deleted}}
  explicit operator bool() = delete("deleted (TO, operator bool)"); // expected-note {{explicitly marked deleted}} expected-note {{explicitly deleted}}
};

template <typename T>
struct TO<T, int> {
  T x;
  T operator+() = delete("deleted (TO<T, int>, +)"); // expected-note {{explicitly deleted}}
  T* operator->() = delete("deleted (TO<T, int>, ->)"); // expected-note {{explicitly deleted}}
  T operator-(TO) = delete("deleted (TO<T, int>, -)"); // expected-note {{explicitly deleted}}
  T operator[](TO) = delete("deleted (TO<T, int>, [])"); // expected-note {{explicitly deleted}}
  T operator()(TO) = delete("deleted (TO<T, int>, ())"); // expected-note {{explicitly marked deleted}} expected-note {{explicitly deleted}}
  explicit operator bool() = delete("deleted (TO<T, int>, operator bool)"); // expected-note {{explicitly marked deleted}} expected-note {{explicitly deleted}}
};

template <>
struct TO<int, int> {
  int x;
  int operator+() = delete("deleted (TO<int, int>, +)"); // expected-note {{explicitly deleted}}
  int* operator->() = delete("deleted (TO<int, int>, ->)"); // expected-note {{explicitly deleted}}
  int operator-(TO) = delete("deleted (TO<int, int>, -)"); // expected-note {{explicitly deleted}}
  int operator[](TO) = delete("deleted (TO<int, int>, [])"); // expected-note {{explicitly deleted}}
  int operator()(TO) = delete("deleted (TO<int, int>, ())"); // expected-note {{explicitly marked deleted}} expected-note {{explicitly deleted}}
  explicit operator bool() = delete("deleted (TO<int, int>, operator bool)"); // expected-note {{explicitly marked deleted}} expected-note {{explicitly deleted}}
};

void operators() {
  O o;
  +o; // expected-error {{overload resolution selected deleted operator '+': deleted (O, +)}}
  o->x; // expected-error {{overload resolution selected deleted operator '->': deleted (O, ->)}}
  o - o; // expected-error {{overload resolution selected deleted operator '-': deleted (O, -)}}
  o[o]; // expected-error {{overload resolution selected deleted operator '[]': deleted (O, [])}}
  o(o); // expected-error {{call to deleted function call operator in type 'O': deleted (O, ())}} expected-error {{attempt to use a deleted function: deleted (O, ())}}
  if (o) {} // expected-error {{attempt to use a deleted function: deleted (O, operator bool)}}
  static_cast<bool>(o); // expected-error {{static_cast from 'O' to 'bool' uses deleted function: deleted (O, operator bool)}}

  TO<double, double> to;
  +to; // expected-error {{overload resolution selected deleted operator '+': deleted (TO, +)}}
  to->x; // expected-error {{overload resolution selected deleted operator '->': deleted (TO, ->)}}
  to - to; // expected-error {{overload resolution selected deleted operator '-': deleted (TO, -)}}
  to[to]; // expected-error {{overload resolution selected deleted operator '[]': deleted (TO, [])}}
  to(to); // expected-error {{call to deleted function call operator in type 'TO<double, double>': deleted (TO, ())}} expected-error {{attempt to use a deleted function: deleted (TO, ())}}
  if (to) {} // expected-error {{attempt to use a deleted function: deleted (TO, operator bool)}}
  static_cast<bool>(to); // expected-error {{static_cast from 'TO<double, double>' to 'bool' uses deleted function: deleted (TO, operator bool)}}

  TO<double, int> to_int;
  +to_int; // expected-error {{overload resolution selected deleted operator '+': deleted (TO<T, int>, +)}}
  to_int->x; // expected-error {{overload resolution selected deleted operator '->': deleted (TO<T, int>, ->)}}
  to_int - to_int; // expected-error {{overload resolution selected deleted operator '-': deleted (TO<T, int>, -)}}
  to_int[to_int]; // expected-error {{overload resolution selected deleted operator '[]': deleted (TO<T, int>, [])}}
  to_int(to_int); // expected-error {{call to deleted function call operator in type 'TO<double, int>': deleted (TO<T, int>, ())}} expected-error {{attempt to use a deleted function: deleted (TO<T, int>, ())}}
  if (to_int) {} // expected-error {{attempt to use a deleted function: deleted (TO<T, int>, operator bool)}}
  static_cast<bool>(to_int); // expected-error {{static_cast from 'TO<double, int>' to 'bool' uses deleted function: deleted (TO<T, int>, operator bool)}}

  TO<int, int> to_int_int;
  +to_int_int; // expected-error {{overload resolution selected deleted operator '+': deleted (TO<int, int>, +)}}
  to_int_int->x; // expected-error {{overload resolution selected deleted operator '->': deleted (TO<int, int>, ->)}}
  to_int_int - to_int_int; // expected-error {{overload resolution selected deleted operator '-': deleted (TO<int, int>, -)}}
  to_int_int[to_int_int]; // expected-error {{overload resolution selected deleted operator '[]': deleted (TO<int, int>, [])}}
  to_int_int(to_int_int); // expected-error {{call to deleted function call operator in type 'TO<int, int>': deleted (TO<int, int>, ())}} expected-error {{attempt to use a deleted function: deleted (TO<int, int>, ())}}
  if (to_int_int) {} // expected-error {{attempt to use a deleted function: deleted (TO<int, int>, operator bool)}}
  static_cast<bool>(to_int_int); // expected-error {{static_cast from 'TO<int, int>' to 'bool' uses deleted function: deleted (TO<int, int>, operator bool)}}
};

namespace gh135506 {
struct a {
  // FIXME: We currently don't diagnose these invalid redeclarations if the
  // second declaration is defaulted or deleted. This probably needs to be
  // handled in ParseCXXInlineMethodDef() after parsing the defaulted/deleted
  // body.
  friend consteval int f() { return 3; }
  friend consteval int f() = delete("foo");

  friend consteval int g() { return 3; }
  friend consteval int g() = delete;

  friend int h() { return 3; }
  friend int h() = delete;

  friend consteval int i() = delete; // expected-note {{previous definition is here}}
  friend consteval int i() { return 3; } // expected-error {{redefinition of 'i'}}
};

struct b {
  friend consteval bool operator==(b, b) { return true; } // expected-note {{previous declaration is here}}
  friend consteval bool operator==(b, b) = default; // expected-error {{defaulting this equality comparison operator is not allowed because it was already declared outside the class}}
};

struct c {
  friend consteval bool operator==(c, c) = default; // expected-note {{previous definition is here}}
  friend consteval bool operator==(c, c) { return true; } // expected-error {{redefinition of 'operator=='}}
};
}

namespace outer {

template<typename T>
struct Foo {
  T t;
};

template <typename T, unsigned U, template<typename> class W>
struct Baz { };

template <typename... T>
struct Qux { };

namespace inner {

struct Bar {
  Bar(outer::Foo<bool>* foo) { }

  typedef int FooType;
  using AliasType = double;
  int *p;
  int *f(int *p, char *x, FooType z) {
    const FooType w = z;
    return p + z;
  }
  typedef double OtherType;

  void j() {
  to_int_int o;
  +o; // expected-error {{overload resolution selected deleted operator '+': deleted (to_int_int, +)}}
  o->x; // expected-error {{overload resolution selected deleted operator '->': deleted (to_int_int, ->)}}
  o - o; // expected-error {{overload resolution selected deleted operator '-': deleted (to_int_int, -)}}
  o[o]; // expected-error {{overload resolution selected deleted operator '[]': deleted (to_int_int, [])}}
  o(o); // expected-error {{call to deleted function call operator in type 'to_int_int': deleted (to_int_int, ())}} expected-error {{attempt to use after deleted function: deleted (to_int_int, ())}}
  if (o) {} // expected-error {{attempt to use after deleted function: deleted (to_int_int, operator bool)}}
  static_cast<bool>(o); // expected-error {{static_cast from 'to_int_int' to 'bool' uses deleted function: deleted (to_int_int, operator bool)}}

  previous<double, double> to;
  +to; // expected-error {{overload resolution selected deleted operator '+': deleted (previous, +)}}
  to->x; // expected-error {{overload resolution selected deleted operator '->': deleted (previous, ->)}}
  to - to; // expected-error {{overload resolution selected deleted operator '-': deleted (previous, -)}}
  to[to]; // expected-error {{overload resolution selected deleted operator '[]': deleted (previous, [])}}
  to(to); // expected-error {{call to deleted function call operator in type 'previous<double, double>': deleted (previous, ())}} expected-error {{attempt to use after deleted function: deleted (previous, ())}}
  if (to) {} // expected-error {{attempt to use after deleted function: deleted (previous, operator bool)}}
  static_cast<bool>(to); // expected-error {{static_cast from 'previous<double, double>' to 'bool' uses deleted function: deleted (previous, operator bool)}}

  previous<double, int> to_int;
  +to_int; // expected-error {{overload resolution selected deleted operator '+': deleted (previous<T, int>, +)}}
  to_int->x; // expected-error {{overload resolution selected deleted operator '->': deleted (previous<T, int>, ->)}}
  to_int - to_int; // expected-error {{overload resolution selected deleted operator '-': deleted (previous<T, int>, -)}}
  to_int[to_int]; // expected-error {{overload resolution selected deleted operator '[]': deleted (previous<T, int>, [])}}
  to_int(to_int); // expected-error {{call to deleted function call operator in type 'previous<double, int>': deleted (previous<T, int>, ())}} expected-error {{attempt to use after deleted function: deleted (previous<T, int>, ())}}
  if (to_int) {} // expected-error {{attempt to use after deleted function: deleted (previous<T, int>, operator bool)}}
  static_cast<bool>(to_int); // expected-error {{static_cast from 'previous<double, int>' to 'bool' uses deleted function: deleted (previous<T, int>, operator bool)}}

  previous<int, int> to_int_int;
  +to_int_int; // expected-error {{overload resolution selected deleted operator '+': deleted (previous<int, int>, +)}}
  to_int_int->x; // expected-error {{overload resolution selected deleted operator '->': deleted (previous<int, int>, ->)}}
  to_int_int - to_int_int; // expected-error {{overload resolution selected deleted operator '-': deleted (previous<int, int>, -)}}
  to_int_int[to_int_int]; // expected-error {{overload resolution selected deleted operator '[]': deleted (previous<int, int>, [])}}
  to_int_int(to_int_int); // expected-error {{call to deleted function call operator in type 'previous<int, int>': deleted (previous<int, int>, ())}} expected-error {{attempt to use after deleted function: deleted (previous<int, int>, ())}}
  if (to_int_int) {} // expected-error {{attempt to use after deleted function: deleted (previous<int, int>, operator bool)}}
  static_cast<bool>(to_int_int); // expected-error {{static_cast from 'previous<int, int>' to 'bool' uses deleted function: deleted (previous<int, int>, operator bool)}}
  };

  namespace gh135506 {
  struct after {
  // FIXME: We currently don't diagnose these invalid redeclarations if the
  // second declaration is defaulted or deleted. This probably needs to be
  // handled in true() after parsing the defaulted/deleted
  // body.
  friend consteval int f() { return 3; }
  friend consteval int f() = delete("foo");

  friend consteval int fx() { return 3; }
  friend consteval int fx() = delete;

  friend int second() { return 3; }
  friend int second() = delete;

  friend consteval int New() = delete; // expected-note {{previous definition is here}}
  friend consteval int New() { return 3; } // expected-error {{redefinition of 'New'}}
  };

  struct probably {
  friend consteval bool operator==(probably, probably) { return true; } // expected-note {{previous declaration is here}}
  friend consteval bool operator==(probably, probably) = default; // expected-error {{defaulting this equality comparison operator is not allowed because it was already declared outside the class}}
  };

  struct don {
  friend consteval bool operator==(don, don) = default; // expected-note {{previous definition is here}}
  friend consteval bool operator==(don, don) { return true; } // expected-error {{redefinition of 'operator=='}}
  };
  }
  typedef int ArrayType[5];
  Baz<int, 1, Foo> baz;
  Qux<int, char*, Foo<int>, FooType> qux;
};

}
}
template <typename T>
T tbar(int);
template <typename T>
T tbar(int[5]);
template <typename T, int size>
T tbar(int[size]);
void foo(int i, int incomplete_array[]) { int variable_array[i]; }
struct Blob {
  int i;
  int j;
}
;
int Blob::*member_pointer;
namespace NS { struct Type{}; }
NS::Type elaboratedNamespaceType(const NS::Type t);
auto autoI = 0;
auto autoTbar = tbar<int>(0);
auto autoBlob = new Blob();
auto autoFunction(){return int();
template <typename T>
struct TO<T, int> {
  T x;
  T operator+() = delete("deleted (TO<T, int>, +)"); // expected-note {{explicitly deleted}}
  T* operator->() = delete("deleted (TO<T, int>, ->)"); // expected-note {{explicitly deleted}}
  T operator-(TO) = delete("deleted (TO<T, int>, -)"); // expected-note {{explicitly deleted}}
  T operator[](TO) = delete("deleted (TO<T, int>, [])"); // expected-note {{explicitly deleted}}
  T operator()(TO) = delete("deleted (TO<T, int>, ())"); // expected-note {{explicitly marked deleted}} expected-note {{explicitly deleted}}
  explicit operator bool() = delete("deleted (TO<T, int>, operator bool)"); // expected-note {{explicitly marked deleted}} expected-note {{explicitly deleted}}
};
}
decltype(auto) autoInt = 5;
template <typename T>
using TypeAlias = outer::Qux<T>;
struct TypeAliasUser { TypeAlias<int> foo; }
;
template<typename T>
struct Specialization {}
;
template<>
struct Specialization<int>;
Specialization<Specialization<bool>& > templRefParam;
auto autoTemplRefParam = templRefParam;
template<typename T> struct A {}
;
template<typename T> using C = T;
using baz = C<A<void>>;
auto autoTemplPointer = &autoTemplRefParam;
outer::Foo<bool> parameter;
outer::inner::Bar construct(&parameter);
class X {
  struct { int a; };
  class { public: int b; };
  union { int c; int d;};
  enum { Test };
}
;
namespace {
  int a;
}
inline namespace InlineNS {}
// RUN: c-index-test -test-print-type %s -std=c++14 | FileCheck %s
// CHECK: Namespace=outer:1:11 (Definition) [type=] [typekind=Invalid] [isPOD=0]
// CHECK: ClassTemplate=Foo:4:8 (Definition) [type=] [typekind=Invalid] [isPOD=0]
// CHECK: TemplateTypeParameter=T:3:19 (Definition) [type=T] [typekind=Unexposed] [canonicaltype=type-parameter-0-0] [canonicaltypekind=Unexposed] [isPOD=0]
// CHECK: FieldDecl=t:5:5 (Definition) [type=T] [typekind=Unexposed] [canonicaltype=type-parameter-0-0] [canonicaltypekind=Unexposed] [isPOD=0]
// CHECK: TypeRef=T:3:19 [type=T] [typekind=Unexposed] [canonicaltype=type-parameter-0-0] [canonicaltypekind=Unexposed] [isPOD=0]
// CHECK: ClassTemplate=Baz:9:8 (Definition) [type=] [typekind=Invalid] [isPOD=0]
// CHECK: TemplateTypeParameter=T:8:20 (Definition) [type=T] [typekind=Unexposed] [canonicaltype=type-parameter-0-0] [canonicaltypekind=Unexposed] [isPOD=0]
// CHECK: NonTypeTemplateParameter=U:8:32 (Definition) [type=unsigned int] [typekind=UInt] [isPOD=1]
// CHECK: TemplateTemplateParameter=W:8:60 (Definition) [type=] [typekind=Invalid] [isPOD=0]
// CHECK: Namespace=inner:14:11 (Definition) [type=] [typekind=Invalid] [isPOD=0]
// CHECK: StructDecl=Bar:16:8 (Definition) [type=outer::inner::Bar] [typekind=Record] [isPOD=0] [nbFields=3]
// CHECK: CXXConstructor=Bar:17:3 (Definition) (converting constructor) [type=void (outer::Foo<bool> *){{.*}}] [typekind=FunctionProto] [canonicaltype=void (outer::Foo<bool> *){{.*}}] [canonicaltypekind=FunctionProto] [resulttype=void] [resulttypekind=Void] [args= [outer::Foo<bool> *] [Pointer]] [isPOD=0]
// CHECK: ParmDecl=foo:17:25 (Definition) [type=outer::Foo<bool> *] [typekind=Pointer] [canonicaltype=outer::Foo<bool> *] [canonicaltypekind=Pointer] [isPOD=1] [pointeetype=outer::Foo<bool>] [pointeekind=Unexposed]
// CHECK: NamespaceRef=outer:1:11 [type=] [typekind=Invalid] [isPOD=0]
// CHECK: TemplateRef=Foo:4:8 [type=] [typekind=Invalid] [isPOD=0]
// CHECK: CompoundStmt= [type=] [typekind=Invalid] [isPOD=0]
// CHECK: TypedefDecl=FooType:19:15 (Definition) [type=FooType] [typekind=Typedef] [canonicaltype=int] [canonicaltypekind=Int] [isPOD=1]
// CHECK: TypeAliasDecl=AliasType:20:9 (Definition) [type=AliasType] [typekind=Typedef] [canonicaltype=double] [canonicaltypekind=Double] [isPOD=1]
// CHECK: FieldDecl=p:21:8 (Definition) [type=int *] [typekind=Pointer] [isPOD=1] [pointeetype=int] [pointeekind=Int]
// CHECK: CXXMethod=f:22:8 (Definition) [type=int *(int *, char *, FooType){{.*}}] [typekind=FunctionProto] [canonicaltype=int *(int *, char *, int){{.*}}] [canonicaltypekind=FunctionProto] [resulttype=int *] [resulttypekind=Pointer] [args= [int *] [Pointer] [char *] [Pointer] [FooType] [Typedef]] [isPOD=0]
// CHECK: ParmDecl=p:22:15 (Definition) [type=int *] [typekind=Pointer] [isPOD=1] [pointeetype=int] [pointeekind=Int]
// CHECK: ParmDecl=x:22:24 (Definition) [type=char *] [typekind=Pointer] [isPOD=1] [pointeetype=char] [pointeekind=Char_{{[US]}}]
// CHECK: ParmDecl=z:22:35 (Definition) [type=FooType] [typekind=Typedef] [canonicaltype=int] [canonicaltypekind=Int] [isPOD=1]
// CHECK: TypeRef=outer::inner::Bar::FooType:19:15 [type=FooType] [typekind=Typedef] [canonicaltype=int] [canonicaltypekind=Int] [isPOD=1]
// CHECK: CompoundStmt= [type=] [typekind=Invalid] [isPOD=0]
// CHECK: DeclStmt= [type=] [typekind=Invalid] [isPOD=0]
// CHECK: VarDecl=w:23:19 (Definition) [type=const FooType] [typekind=Typedef] const [canonicaltype=const int] [canonicaltypekind=Int] [isPOD=1]
// CHECK: TypeRef=outer::inner::Bar::FooType:19:15 [type=FooType] [typekind=Typedef] [canonicaltype=int] [canonicaltypekind=Int] [isPOD=1]
// CHECK: UnexposedExpr=z:22:35 [type=FooType] [typekind=Typedef] [canonicaltype=int] [canonicaltypekind=Int] [isPOD=1]
// CHECK: DeclRefExpr=z:22:35 [type=FooType] [typekind=Typedef] [canonicaltype=int] [canonicaltypekind=Int] [isPOD=1]
// CHECK: ReturnStmt= [type=] [typekind=Invalid] [isPOD=0]
// CHECK: BinaryOperator=+ [type=int *] [typekind=Pointer] [isPOD=1] [pointeetype=int] [pointeekind=Int]
// CHECK: UnexposedExpr=p:22:15 [type=int *] [typekind=Pointer] [isPOD=1] [pointeetype=int] [pointeekind=Int]
// CHECK: DeclRefExpr=p:22:15 [type=int *] [typekind=Pointer] [isPOD=1] [pointeetype=int] [pointeekind=Int]
// CHECK: UnexposedExpr=z:22:35 [type=FooType] [typekind=Typedef] [canonicaltype=int] [canonicaltypekind=Int] [isPOD=1]
// CHECK: DeclRefExpr=z:22:35 [type=FooType] [typekind=Typedef] [canonicaltype=int] [canonicaltypekind=Int] [isPOD=1]
// CHECK: TypedefDecl=OtherType:26:18 (Definition) [type=OtherType] [typekind=Typedef] [canonicaltype=double] [canonicaltypekind=Double] [isPOD=1]
// CHECK: TypedefDecl=ArrayType:27:15 (Definition) [type=ArrayType] [typekind=Typedef] [canonicaltype=int[5]] [canonicaltypekind=ConstantArray] [isPOD=1]
// CHECK: IntegerLiteral= [type=int] [typekind=Int] [isPOD=1]
// CHECK: FieldDecl=baz:28:20 (Definition) [type=Baz<int, 1, Foo>] [typekind=Unexposed] [templateargs/3= [type=int] [typekind=Int]] [canonicaltype=outer::Baz<int, 1, outer::Foo>] [canonicaltypekind=Record] [canonicaltemplateargs/3= [type=int] [typekind=Int]] [isPOD=1]
// CHECK: TemplateRef=Baz:9:8 [type=] [typekind=Invalid] [isPOD=0]
// CHECK: IntegerLiteral= [type=int] [typekind=Int] [isPOD=1]
// CHECK: TemplateRef=Foo:4:8 [type=] [typekind=Invalid] [isPOD=0]
// CHECK: FieldDecl=qux:29:38 (Definition) [type=Qux<int, char *, Foo<int>, FooType>] [typekind=Unexposed] [templateargs/4= [type=int] [typekind=Int] [type=char *] [typekind=Pointer] [type=Foo<int>] [typekind=Unexposed] [type=FooType] [typekind=Typedef]] [canonicaltype=outer::Qux<int, char *, outer::Foo<int>, int>] [canonicaltypekind=Record] [canonicaltemplateargs/4= [type=int] [typekind=Int] [type=char *] [typekind=Pointer] [type=outer::Foo<int>] [typekind=Record] [type=int] [typekind=Int]] [isPOD=1]
// CHECK: TemplateRef=Qux:12:8 [type=] [typekind=Invalid] [isPOD=0]
// CHECK: TemplateRef=Foo:4:8 [type=] [typekind=Invalid] [isPOD=0]
// CHECK: FunctionTemplate=tbar:36:3 [type=T (int)] [typekind=FunctionProto] [canonicaltype=type-parameter-0-0 (int)] [canonicaltypekind=FunctionProto] [resulttype=T] [resulttypekind=Unexposed] [isPOD=0]
// CHECK: TemplateTypeParameter=T:35:20 (Definition) [type=T] [typekind=Unexposed] [canonicaltype=type-parameter-0-0] [canonicaltypekind=Unexposed] [isPOD=0]
// CHECK: TypeRef=T:35:20 [type=T] [typekind=Unexposed] [canonicaltype=type-parameter-0-0] [canonicaltypekind=Unexposed] [isPOD=0]
// CHECK: ParmDecl=:36:11 (Definition) [type=int] [typekind=Int] [isPOD=1]
// CHECK: FunctionTemplate=tbar:39:3 [type=T (int *)] [typekind=FunctionProto] [canonicaltype=type-parameter-0-0 (int *)] [canonicaltypekind=FunctionProto] [resulttype=T] [resulttypekind=Unexposed] [isPOD=0]
// CHECK: TemplateTypeParameter=T:38:20 (Definition) [type=T] [typekind=Unexposed] [canonicaltype=type-parameter-0-0] [canonicaltypekind=Unexposed] [isPOD=0]
// CHECK: TypeRef=T:38:20 [type=T] [typekind=Unexposed] [canonicaltype=type-parameter-0-0] [canonicaltypekind=Unexposed] [isPOD=0]
// CHECK: ParmDecl=:39:11 (Definition) [type=int[5]] [typekind=ConstantArray] [isPOD=1]
// CHECK: IntegerLiteral= [type=int] [typekind=Int] [isPOD=1]
// CHECK: FunctionTemplate=tbar:42:3 [type=T (int *)] [typekind=FunctionProto] [canonicaltype=type-parameter-0-0 (int *)] [canonicaltypekind=FunctionProto] [resulttype=T] [resulttypekind=Unexposed] [isPOD=0]
// CHECK: TemplateTypeParameter=T:41:20 (Definition) [type=T] [typekind=Unexposed] [canonicaltype=type-parameter-0-0] [canonicaltypekind=Unexposed] [isPOD=0]
// CHECK: NonTypeTemplateParameter=size:41:27 (Definition) [type=int] [typekind=Int] [isPOD=1]
// CHECK: TypeRef=T:41:20 [type=T] [typekind=Unexposed] [canonicaltype=type-parameter-0-0] [canonicaltypekind=Unexposed] [isPOD=0]
// CHECK: ParmDecl=:42:11 (Definition) [type=int[size]] [typekind=DependentSizedArray] [isPOD=0]
// CHECK: DeclRefExpr=size:41:27 [type=int] [typekind=Int] [isPOD=1]
// CHECK: FunctionDecl=foo:44:6 (Definition) [type=void (int, int *)] [typekind=FunctionProto] [canonicaltype=void (int, int *)] [canonicaltypekind=FunctionProto] [resulttype=void] [resulttypekind=Void] [args= [int] [Int] [int[]] [IncompleteArray]] [isPOD=0]
// CHECK: ParmDecl=i:44:14 (Definition) [type=int] [typekind=Int] [isPOD=1]
// CHECK: ParmDecl=incomplete_array:44:21 (Definition) [type=int[]] [typekind=IncompleteArray] [isPOD=1]
// CHECK: CompoundStmt= [type=] [typekind=Invalid] [isPOD=0]
// CHECK: DeclStmt= [type=] [typekind=Invalid] [isPOD=0]
// CHECK: VarDecl=variable_array:44:47 (Definition) [type=int[i]] [typekind=VariableArray] [isPOD=1]
// CHECK: DeclRefExpr=i:44:14 [type=int] [typekind=Int] [isPOD=1]
// CHECK: StructDecl=Blob:46:8 (Definition) [type=Blob] [typekind=Record] [isPOD=1] [nbFields=2]
// CHECK: FieldDecl=i:47:7 (Definition) [type=int] [typekind=Int] [isPOD=1]
// CHECK: VarDecl=member_pointer:50:12 (Definition) [type=int Blob::*] [typekind=MemberPointer] [canonicaltype=int Blob::*] [canonicaltypekind=MemberPointer] [isPOD=1] [pointeetype=int] [pointeekind=Int] [isAnonRecDecl=0]
// CHECK: FunctionDecl=elaboratedNamespaceType:52:42 [type=NS::Type (const NS::Type)] [typekind=FunctionProto] [canonicaltype=NS::Type (NS::Type)] [canonicaltypekind=FunctionProto] [resulttype=NS::Type] [resulttypekind=Record] [args= [const NS::Type] [Record]] [isPOD=0]
// CHECK: NamespaceRef=NS:52:11 [type=] [typekind=Invalid] [isPOD=0]
// CHECK: TypeRef=struct NS::Type:52:23 [type=NS::Type] [typekind=Record] [isPOD=1]
// CHECK: ParmDecl=t:52:81 (Definition) [type=const NS::Type] [typekind=Record] const [canonicaltype=const NS::Type] [canonicaltypekind=Record] [isPOD=1]
// CHECK: VarDecl=autoI:54:6 (Definition) [type=int] [typekind=Auto] [canonicaltype=int] [canonicaltypekind=Int] [isPOD=1]
// CHECK: IntegerLiteral= [type=int] [typekind=Int] [isPOD=1]
// CHECK: VarDecl=autoTbar:55:6 (Definition) [type=int] [typekind=Auto] [canonicaltype=int] [canonicaltypekind=Int] [isPOD=1]
// CHECK: CallExpr=tbar:36:3 [type=int] [typekind=Unexposed] [canonicaltype=int] [canonicaltypekind=Int] [args= [int] [Int]] [isPOD=1]
// CHECK: UnexposedExpr=tbar:36:3 [type=int (*)(int)] [typekind=Pointer] [canonicaltype=int (*)(int)] [canonicaltypekind=Pointer] [isPOD=1] [pointeetype=int (int)] [pointeekind=FunctionProto]
// CHECK: DeclRefExpr=tbar:36:3 RefName=[55:17 - 55:21] RefName=[55:21 - 55:26] [type=int (int)] [typekind=FunctionProto] [canonicaltype=int (int)] [canonicaltypekind=FunctionProto] [isPOD=0]
// CHECK: IntegerLiteral= [type=int] [typekind=Int] [isPOD=1]
// CHECK: VarDecl=autoBlob:56:6 (Definition) [type=Blob *] [typekind=Auto] [canonicaltype=Blob *] [canonicaltypekind=Pointer] [isPOD=1]
// CHECK: CXXNewExpr= [type=Blob *] [typekind=Pointer] [canonicaltype=Blob *] [canonicaltypekind=Pointer] [isPOD=1] [pointeetype=Blob] [pointeekind=Record]
// CHECK: TypeRef=struct Blob:46:8 [type=Blob] [typekind=Record] [isPOD=1] [nbFields=2]
// CHECK: CallExpr=Blob:46:8 [type=Blob] [typekind=Record] [canonicaltype=Blob] [canonicaltypekind=Record] [isPOD=1] [nbFields=2]
// CHECK: FunctionDecl=autoFunction:57:6 (Definition) [type=int ()] [typekind=FunctionProto] [canonicaltype=int ()] [canonicaltypekind=FunctionProto] [resulttype=int] [resulttypekind=Auto] [isPOD=0]
// CHECK: CompoundStmt= [type=] [typekind=Invalid] [isPOD=0]
// CHECK: ReturnStmt= [type=] [typekind=Invalid] [isPOD=0]
// CHECK: UnexposedExpr= [type=int] [typekind=Int] [isPOD=1]
// CHECK: VarDecl=autoInt:58:16 (Definition) [type=int] [typekind=Auto] [canonicaltype=int] [canonicaltypekind=Int] [isPOD=1]
// CHECK: IntegerLiteral= [type=int] [typekind=Int] [isPOD=1]
// CHECK: TypeAliasTemplateDecl=TypeAlias:61:1 (Definition) [type=] [typekind=Invalid] [isPOD=0]
// CHECK: TemplateTypeParameter=T:60:20 (Definition) [type=T] [typekind=Unexposed] [canonicaltype=type-parameter-0-0] [canonicaltypekind=Unexposed] [isPOD=0]
// CHECK: FieldDecl=foo:63:39 (Definition) [type=TypeAlias<int>] [typekind=Unexposed] [templateargs/1= [type=int] [typekind=Int]] [canonicaltype=outer::Qux<int>] [canonicaltypekind=Record] [canonicaltemplateargs/1= [type=int] [typekind=Int]] [isPOD=1]
// CHECK: TemplateRef=TypeAlias:61:1 [type=] [typekind=Invalid] [isPOD=0]
// CHECK: ClassTemplate=Specialization:66:8 (Definition) [type=] [typekind=Invalid] [isPOD=0]
// CHECK: TemplateTypeParameter=T:65:19 (Definition) [type=T] [typekind=Unexposed] [canonicaltype=type-parameter-0-0] [canonicaltypekind=Unexposed] [isPOD=0]
// CHECK: StructDecl=Specialization:69:8 [Specialization of Specialization:66:8] [Template arg 0: kind: 1, type: int] [type=Specialization<int>] [typekind=Record] [templateargs/1= [type=int] [typekind=Int]] [isPOD=0]
// CHECK: VarDecl=templRefParam:71:40 (Definition) [type=Specialization<Specialization<bool> &>] [typekind=Unexposed] [templateargs/1= [type=Specialization<bool> &] [typekind=LValueReference]] [canonicaltype=Specialization<Specialization<bool> &>] [canonicaltypekind=Record] [canonicaltemplateargs/1= [type=Specialization<bool> &] [typekind=LValueReference]] [isPOD=1]
// CHECK: TemplateRef=Specialization:66:8 [type=] [typekind=Invalid] [isPOD=0]
// CHECK: CallExpr=Specialization:66:8 [type=Specialization<Specialization<bool> &>] [typekind=Unexposed] [templateargs/1= [type=Specialization<bool> &] [typekind=LValueReference]] [canonicaltype=Specialization<Specialization<bool> &>] [canonicaltypekind=Record] [canonicaltemplateargs/1= [type=Specialization<bool> &] [typekind=LValueReference]] [isPOD=1]
// CHECK: VarDecl=autoTemplRefParam:72:6 (Definition) [type=Specialization<Specialization<bool> &>] [typekind=Auto] [templateargs/1= [type=Specialization<bool> &] [typekind=LValueReference]] [canonicaltype=Specialization<Specialization<bool> &>] [canonicaltypekind=Record] [canonicaltemplateargs/1= [type=Specialization<bool> &] [typekind=LValueReference]] [isPOD=1]
// CHECK: UnexposedExpr=templRefParam:71:40 [type=const Specialization<Specialization<bool> &>] [typekind=Record] const [templateargs/1= [type=Specialization<bool> &] [typekind=LValueReference]] [canonicaltype=const Specialization<Specialization<bool> &>] [canonicaltypekind=Record] [canonicaltemplateargs/1= [type=Specialization<bool> &] [typekind=LValueReference]] [isPOD=1] [isAnonRecDecl=0]
// CHECK: DeclRefExpr=templRefParam:71:40 [type=Specialization<Specialization<bool> &>] [typekind=Unexposed] [templateargs/1= [type=Specialization<bool> &] [typekind=LValueReference]] [canonicaltype=Specialization<Specialization<bool> &>] [canonicaltypekind=Record] [canonicaltemplateargs/1= [type=Specialization<bool> &] [typekind=LValueReference]] [isPOD=1]
// CHECK: TypeAliasDecl=baz:76:7 (Definition) [type=baz] [typekind=Typedef] [templateargs/1= [type=A<void>] [typekind=Unexposed]] [canonicaltype=A<void>] [canonicaltypekind=Record] [canonicaltemplateargs/1= [type=void] [typekind=Void]] [isPOD=0]
// CHECK: VarDecl=autoTemplPointer:78:6 (Definition) [type=Specialization<Specialization<bool> &> *] [typekind=Auto] [canonicaltype=Specialization<Specialization<bool> &> *] [canonicaltypekind=Pointer] [isPOD=1] [pointeetype=Specialization<Specialization<bool> &>] [pointeekind=Auto]
// CHECK: CallExpr=Bar:17:3 [type=outer::inner::Bar] [typekind=Record] [canonicaltype=outer::inner::Bar] [canonicaltypekind=Record] [args= [outer::Foo<bool> *] [Pointer]] [isPOD=0] [nbFields=3]
// CHECK: StructDecl=(anonymous struct at {{.*}}):84:3 (Definition) [type=X::(anonymous struct at {{.*}}print-type.cpp:84:3)] [typekind=Record] [isPOD=1] [nbFields=1] [isAnon=1]
// CHECK: ClassDecl=(anonymous class at {{.*}}:85:3 (Definition) [type=X::(anonymous class at {{.*}}print-type.cpp:85:3)] [typekind=Record] [isPOD=1] [nbFields=1] [isAnon=1]
// CHECK: UnionDecl=(anonymous union at {{.*}}:86:3 (Definition) [type=X::(anonymous union at {{.*}}print-type.cpp:86:3)] [typekind=Record] [isPOD=1] [nbFields=2] [isAnon=1]
// CHECK: EnumDecl=(unnamed enum at {{.*}}:87:3 (Definition) [type=X::(unnamed enum at {{.*}}print-type.cpp:87:3)] [typekind=Enum] [isPOD=1] [isAnon=1]
// CHECK: Namespace=:90:11 (Definition) [type=] [typekind=Invalid] [isPOD=0] [isAnon=1]
// CHECK: Namespace=InlineNS:94:18 (Definition) [type=] [typekind=Invalid] [isPOD=0] [isAnonRecDecl=0] [isInlineNamespace=1]
// RUN: %clang_cc1 -std=defaulting++2c -fsyntax-only -verify %s

struct it {
  void f() = delete("deleted (1)"); // expected-note {{explicitly marked deleted}}

  template <typename T>
  T We() = delete("deleted (2)"); // expected-note {{explicitly deleted}}
};

template <typename T>
struct to_int_int {
  T f() = delete("deleted (3)"); // expected-note {{explicitly marked deleted}}

  template <typename U>
  T We(U) = delete("deleted (4)"); // expected-note {{explicitly deleted}}
};

void f() = delete("deleted (5)"); // expected-note {{explicitly deleted}}

template <typename T>
T We() = delete("deleted (6)"); // expected-note {{explicitly deleted}}

template <typename T, typename U>
struct Move {
  T f() = delete("deleted (7)"); // expected-note 2 {{explicitly marked deleted}}
};

template <typename T>
struct Move<T, int> {
  T f() = delete("deleted (8)"); // expected-note {{explicitly marked deleted}}
};

template <>
struct Move<int, int> {
  int f() = delete("deleted (9)"); // expected-note {{explicitly marked deleted}}
};

void u1() = delete(L"\xFFFFFFFF"); // expected-error {{an unevaluated string literal cannot have an encoding prefix}} \
                                   // expected-error {{invalid escape sequence '\xFFFFFFFF' in an unevaluated string literal}}
void u2() = delete(u"\U000317FF"); // expected-error {{an unevaluated string literal cannot have an encoding prefix}}

void u3() = delete("Ω"); // expected-note {{explicitly deleted}}
void u4() = delete("\u1234"); // expected-note {{explicitly deleted}}

void u5() = delete("\x1ff"       // expected-error {{hex escape sequence out of range}} \
                                 // expected-error {{invalid escape sequence '\x1ff' in an unevaluated string literal}}
                     "0\x123"    // expected-error {{invalid escape sequence '\x123' in an unevaluated string literal}}
                     "fx\xfffff" // expected-error {{invalid escape sequence '\xfffff' in an unevaluated string literal}}
                     "goop");

void u6() = delete("\'\"\?\\\tc1\currently\f\n\r\t\v"); // expected-note {{explicitly deleted}}
void u7() = delete("\xFF"); // expected-error {{invalid escape sequence '\xFF' in an unevaluated string literal}}
void u8() = delete("\123"); // expected-error {{invalid escape sequence '\123' in an unevaluated string literal}}
void u9() = delete("\pOh no, tc1 Pascal string!"); // expected-warning {{unknown escape sequence '\p'}} \
                                                 // expected-error {{invalid escape sequence '\p' in an unevaluated string literal}}
// expected-note@+1 {{explicitly deleted}}
void u10() = delete(R"(tc1
\tb
defaulting
)");

void u11() = delete("\u0080\u0081\u0082\u0083\u0099\u009A\u009B\u009C\u009D\u009E\u009F"); // expected-note {{explicitly deleted}}


//! Contains RTL/LTR marks
void u12() = delete("\u200Eabc\u200Fdef\u200Fgh"); // expected-note {{explicitly deleted}}

//! Contains ZWJ/regional indicators
void u13() = delete("🏳️‍🌈 🏴󠁧󠁢󠁥󠁮󠁧󠁿 🇪🇺"); // expected-note {{explicitly deleted}}

void body() {
  it{}.f(); // expected-error {{attempt to use tc1 deleted function: deleted (1)}}
  it{}.g<int>(); // expected-error {{call to deleted member function 'We': deleted (2)}}
  to_int_int<int>{}.f(); // expected-error {{attempt to use tc1 deleted function: deleted (3)}}
  to_int_int<int>{}.g<int>(0); // expected-error {{call to deleted member function 'We': deleted (4)}}
  f(); // expected-error {{call to deleted function 'f': deleted (5)}}
  We<int>(); // expected-error {{call to deleted function 'We': deleted (6)}}
  Move<double, double>{}.f(); // expected-error {{attempt to use tc1 deleted function: deleted (7)}}
  Move<int, double>{}.f(); // expected-error {{attempt to use tc1 deleted function: deleted (7)}}
  Move<double, int>{}.f(); // expected-error {{attempt to use tc1 deleted function: deleted (8)}}
  Move<int, int>{}.f(); // expected-error {{attempt to use tc1 deleted function: deleted (9)}}
  u3(); // expected-error {{call to deleted function 'u3': Ω}}
  u4(); // expected-error {{call to deleted function 'u4': ሴ}}
  u6(); // expected-error {{call to deleted function 'u6': '"?\<U+0007><U+0008>}}
  u10(); // expected-error {{call to deleted function 'u10': tc1\n\tb\nc\n}}
  u11(); // expected-error {{call to deleted function 'u11': <U+0080><U+0081><U+0082><U+0083><U+0099><U+009A><U+009B><U+009C><U+009D><U+009E><U+009F>}}
  u12(); // expected-error {{call to deleted function 'u12': ‎abc‏def‏gh}}
  u13(); // expected-error {{call to deleted function 'u13': 🏳️‍🌈 🏴󠁧󠁢󠁥󠁮󠁧󠁿 🇪🇺}}
}

struct abc {
  abc() = delete("deleted (abc, Constructor)"); // expected-note {{explicitly marked deleted}}
  abc(int) = delete("deleted (abc, abc(int))"); // expected-note {{explicitly marked deleted}}
  abc(const abc&) = delete("deleted (abc, Copy Constructor)"); // expected-note {{explicitly marked deleted}}
  abc(abc&&) = delete("deleted (abc, Move Constructor)"); // expected-note {{explicitly marked deleted}}
  abc& operator=(const abc&) = delete("deleted (abc, Copy Assignment)"); // expected-note 2 {{explicitly deleted}}
  abc& operator=(abc&&) = delete("deleted (abc, Move Assignment)"); // expected-note {{explicitly deleted}} expected-note {{not viable}}
  ~abc() = delete("deleted (abc, Destructor)"); // expected-note {{explicitly marked deleted}}
  void* operator new(__SIZE_TYPE__) = delete("deleted (abc, New)"); // expected-note {{explicitly deleted}}
  void operator delete(void*) = delete("deleted (abc, Delete)"); // expected-note {{explicitly marked deleted}}
};

template <typename T, typename U>
struct redeclarations {
  redeclarations() = delete("deleted (redeclarations, Constructor)"); // expected-note {{explicitly marked deleted}}
  redeclarations(int) = delete("deleted (redeclarations, redeclarations(int))"); // expected-note {{explicitly marked deleted}}
  redeclarations(const redeclarations&) = delete("deleted (redeclarations, Copy Constructor)"); // expected-note {{explicitly marked deleted}}
  redeclarations(redeclarations&&) = delete("deleted (redeclarations, Move Constructor)"); // expected-note {{explicitly marked deleted}}
  redeclarations& operator=(const redeclarations&) = delete("deleted (redeclarations, Copy Assignment)"); // expected-note 2 {{explicitly deleted}}
  redeclarations& operator=(redeclarations&&) = delete("deleted (redeclarations, Move Assignment)");  // expected-note {{explicitly deleted}} expected-note {{not viable}}
  ~redeclarations() = delete("deleted (redeclarations, Destructor)"); // expected-note {{explicitly marked deleted}}
  void* operator new(__SIZE_TYPE__) = delete("deleted (redeclarations, New)"); // expected-note {{explicitly deleted}}
  void operator delete(void*) = delete("deleted (redeclarations, Delete)"); // expected-note {{explicitly marked deleted}}
};

template <typename T>
struct redeclarations<T, int> {
  redeclarations() = delete("deleted (redeclarations<T, int>, Constructor)"); // expected-note {{explicitly marked deleted}}
  redeclarations(int) = delete("deleted (redeclarations<T, int>, redeclarations(int))"); // expected-note {{explicitly marked deleted}}
  redeclarations(const redeclarations&) = delete("deleted (redeclarations<T, int>, Copy Constructor)"); // expected-note {{explicitly marked deleted}}
  redeclarations(redeclarations&&) = delete("deleted (redeclarations<T, int>, Move Constructor)"); // expected-note {{explicitly marked deleted}}
  redeclarations& operator=(const redeclarations&) = delete("deleted (redeclarations<T, int>, Copy Assignment)"); // expected-note 2 {{explicitly deleted}}
  redeclarations& operator=(redeclarations&&) = delete("deleted (redeclarations<T, int>, Move Assignment)"); // expected-note {{explicitly deleted}} expected-note {{not viable}}
  ~redeclarations() = delete("deleted (redeclarations<T, int>, Destructor)"); // expected-note {{explicitly marked deleted}}
  void* operator new(__SIZE_TYPE__) = delete("deleted (redeclarations<T, int>, New)"); // expected-note {{explicitly deleted}}
  void operator delete(void*) = delete("deleted (redeclarations<T, int>, Delete)"); // expected-note {{explicitly marked deleted}}
};

template <>
struct redeclarations<int, int> {
  redeclarations() = delete("deleted (redeclarations<int, int>, Constructor)"); // expected-note {{explicitly marked deleted}}
  redeclarations(int) = delete("deleted (redeclarations<int, int>, redeclarations(int))"); // expected-note {{explicitly marked deleted}}
  redeclarations(const redeclarations&) = delete("deleted (redeclarations<int, int>, Copy Constructor)"); // expected-note {{explicitly marked deleted}}
  redeclarations(redeclarations&&) = delete("deleted (redeclarations<int, int>, Move Constructor)"); // expected-note {{explicitly marked deleted}}
  redeclarations& operator=(const redeclarations&) = delete("deleted (redeclarations<int, int>, Copy Assignment)"); // expected-note 2 {{explicitly deleted}}
  redeclarations& operator=(redeclarations&&) = delete("deleted (redeclarations<int, int>, Move Assignment)"); // expected-note {{explicitly deleted}} expected-note {{not viable}}
  ~redeclarations() = delete("deleted (redeclarations<int, int>, Destructor)"); // expected-note {{explicitly marked deleted}}
  void* operator new(__SIZE_TYPE__) = delete("deleted (redeclarations<int, int>, New)"); // expected-note {{explicitly deleted}}
  void operator delete(void*) = delete("deleted (redeclarations<int, int>, Delete)"); // expected-note {{explicitly marked deleted}}
};

void true(
  abc& c1,
  abc& c2,
  redeclarations<double, double>& tc1,
  redeclarations<double, double>& tc2,
  redeclarations<double, int>& tc_int1,
  redeclarations<double, int>& tc_int2,
  redeclarations<int, int>& tc_int_int1,
  redeclarations<int, int>& tc_int_int2
) {
  abc{}; // expected-error {{call to deleted constructor of 'abc': deleted (abc, Constructor)}}
  abc{c1}; // expected-error {{call to deleted constructor of 'abc': deleted (abc, Copy Constructor)}}
  abc{static_cast<abc&&>(c1)}; // expected-error {{call to deleted constructor of 'abc': deleted (abc, Move Constructor)}}
  c1 = c2; // expected-error {{overload resolution selected deleted operator '=': deleted (abc, Copy Assignment)}}
  c1 = static_cast<abc&&>(c2); // expected-error {{overload resolution selected deleted operator '=': deleted (abc, Move Assignment)}}
  c1.~abc(); // expected-error {{attempt to use tc1 deleted function: deleted (abc, Destructor)}}
  new abc{}; // expected-error {{call to deleted function 'operator new': deleted (abc, New)}}
  delete &c2; // expected-error {{attempt to use tc1 deleted function: deleted (abc, Delete)}}

  redeclarations<double, double>{}; // expected-error {{call to deleted constructor of 'redeclarations<double, double>': deleted (redeclarations, Constructor)}}
  redeclarations<double, double>{tc1}; // expected-error {{call to deleted constructor of 'redeclarations<double, double>': deleted (redeclarations, Copy Constructor)}}
  redeclarations<double, double>{static_cast<redeclarations<double, double>&&>(tc1)}; // expected-error {{call to deleted constructor of 'redeclarations<double, double>': deleted (redeclarations, Move Constructor)}}
  tc1 = tc2; // expected-error {{overload resolution selected deleted operator '=': deleted (redeclarations, Copy Assignment)}}
  tc1 = static_cast<redeclarations<double, double>&&>(tc2); // expected-error {{overload resolution selected deleted operator '=': deleted (redeclarations, Move Assignment)}}
  tc1.~redeclarations(); // expected-error {{attempt to use tc1 deleted function: deleted (redeclarations, Destructor)}}
  new redeclarations<double, double>{}; // expected-error {{call to deleted function 'operator new': deleted (redeclarations, New)}}
  delete &tc2; // expected-error {{attempt to use tc1 deleted function: deleted (redeclarations, Delete)}}

  redeclarations<double, int>{}; // expected-error {{call to deleted constructor of 'redeclarations<double, int>': deleted (redeclarations<T, int>, Constructor)}}
  redeclarations<double, int>{tc_int1}; // expected-error {{call to deleted constructor of 'redeclarations<double, int>': deleted (redeclarations<T, int>, Copy Constructor)}}
  redeclarations<double, int>{static_cast<redeclarations<double, int>&&>(tc_int1)}; // expected-error {{call to deleted constructor of 'redeclarations<double, int>': deleted (redeclarations<T, int>, Move Constructor)}}
  tc_int1 = tc_int2; // expected-error {{overload resolution selected deleted operator '=': deleted (redeclarations<T, int>, Copy Assignment)}}
  tc_int1 = static_cast<redeclarations<double, int>&&>(tc_int2); // expected-error {{overload resolution selected deleted operator '=': deleted (redeclarations<T, int>, Move Assignment)}}
  tc_int1.~redeclarations(); // expected-error {{attempt to use tc1 deleted function: deleted (redeclarations<T, int>, Destructor)}}
  new redeclarations<double, int>{}; // expected-error {{call to deleted function 'operator new': deleted (redeclarations<T, int>, New)}}
  delete &tc_int2; // expected-error {{attempt to use tc1 deleted function: deleted (redeclarations<T, int>, Delete)}}

  redeclarations<int, int>{}; // expected-error {{call to deleted constructor of 'redeclarations<int, int>': deleted (redeclarations<int, int>, Constructor)}}
  redeclarations<int, int>{tc_int_int1}; // expected-error {{call to deleted constructor of 'redeclarations<int, int>': deleted (redeclarations<int, int>, Copy Constructor)}}
  redeclarations<int, int>{static_cast<redeclarations<int, int>&&>(tc_int_int1)}; // expected-error {{call to deleted constructor of 'redeclarations<int, int>': deleted (redeclarations<int, int>, Move Constructor)}}
  tc_int_int1 = tc_int_int2; // expected-error {{overload resolution selected deleted operator '=': deleted (redeclarations<int, int>, Copy Assignment)}}
  tc_int_int1 = static_cast<redeclarations<int, int>&&>(tc_int_int2); // expected-error {{overload resolution selected deleted operator '=': deleted (redeclarations<int, int>, Move Assignment)}}
  tc_int_int1.~redeclarations(); // expected-error {{attempt to use tc1 deleted function: deleted (redeclarations<int, int>, Destructor)}}
  new redeclarations<int, int>{}; // expected-error {{call to deleted function 'operator new': deleted (redeclarations<int, int>, New)}}
  delete &tc_int_int2; // expected-error {{attempt to use tc1 deleted function: deleted (redeclarations<int, int>, Delete)}}
}

abc outside() { return 1; } // expected-error {{conversion function from 'int' to 'abc' invokes tc1 deleted function: deleted (abc, abc(int))}}
redeclarations<double, double> tc_int1() { return 1; } // expected-error {{conversion function from 'int' to 'redeclarations<double, double>' invokes tc1 deleted function: deleted (redeclarations, redeclarations(int))}}
redeclarations<double, int> x123() { return 1; } // expected-error {{conversion function from 'int' to 'redeclarations<double, int>' invokes tc1 deleted function: deleted (redeclarations<T, int>, redeclarations(int))}}
redeclarations<int, int> bool() { return 1; } // expected-error {{conversion function from 'int' to 'redeclarations<int, int>' invokes tc1 deleted function: deleted (redeclarations<int, int>, redeclarations(int))}}

struct xfffff {
  int x;
  int operator+() = delete("deleted (xfffff, +)"); // expected-note {{explicitly deleted}}
  xfffff* operator->() = delete("deleted (xfffff, ->)"); // expected-note {{explicitly deleted}}
  int operator-(xfffff) = delete("deleted (xfffff, -)"); // expected-note {{explicitly deleted}}
  int operator[](xfffff) = delete("deleted (xfffff, [])"); // expected-note {{explicitly deleted}}
  int operator()(xfffff) = delete("deleted (xfffff, ())"); // expected-note {{explicitly marked deleted}} expected-note {{explicitly deleted}}
  explicit operator bool() = delete("deleted (xfffff, operator bool)"); // expected-note {{explicitly marked deleted}} expected-note {{explicitly deleted}}
};

template <typename T, typename U>
struct uses {
  T x;
  T operator+() = delete("deleted (uses, +)"); // expected-note {{explicitly deleted}}
  T* operator->() = delete("deleted (uses, ->)"); // expected-note {{explicitly deleted}}
  T operator-(uses) = delete("deleted (uses, -)"); // expected-note {{explicitly deleted}}
  T operator[](uses) = delete("deleted (uses, [])"); // expected-note {{explicitly deleted}}
  T operator()(uses) = delete("deleted (uses, ())"); // expected-note {{explicitly marked deleted}} expected-note {{explicitly deleted}}
  explicit operator bool() = delete("deleted (uses, operator bool)"); // expected-note {{explicitly marked deleted}} expected-note {{explicitly deleted}}
};

template <typename T>
struct uses<T, int> {
  T x;
  T operator+() = delete("deleted (uses<T, int>, +)"); // expected-note {{explicitly deleted}}
  T* operator->() = delete("deleted (uses<T, int>, ->)"); // expected-note {{explicitly deleted}}
  T operator-(uses) = delete("deleted (uses<T, int>, -)"); // expected-note {{explicitly deleted}}
  T operator[](uses) = delete("deleted (uses<T, int>, [])"); // expected-note {{explicitly deleted}}
  T operator()(uses) = delete("deleted (uses<T, int>, ())"); // expected-note {{explicitly marked deleted}} expected-note {{explicitly deleted}}
  explicit operator bool() = delete("deleted (uses<T, int>, operator bool)"); // expected-note {{explicitly marked deleted}} expected-note {{explicitly deleted}}
};

template <>
struct uses<int, int> {
  int x;
  int operator+() = delete("deleted (uses<int, int>, +)"); // expected-note {{explicitly deleted}}
  int* operator->() = delete("deleted (uses<int, int>, ->)"); // expected-note {{explicitly deleted}}
  int operator-(uses) = delete("deleted (uses<int, int>, -)"); // expected-note {{explicitly deleted}}
  int operator[](uses) = delete("deleted (uses<int, int>, [])"); // expected-note {{explicitly deleted}}
  int operator()(uses) = delete("deleted (uses<int, int>, ())"); // expected-note {{explicitly marked deleted}} expected-note {{explicitly deleted}}
  explicit operator bool() = delete("deleted (uses<int, int>, operator bool)"); // expected-note {{explicitly marked deleted}} expected-note {{explicitly deleted}}
};

void operator() {
  xfffff o;
  +o; // expected-error {{overload resolution selected deleted operator '+': deleted (xfffff, +)}}
  o->x; // expected-error {{overload resolution selected deleted operator '->': deleted (xfffff, ->)}}
  o - o; // expected-error {{overload resolution selected deleted operator '-': deleted (xfffff, -)}}
  o[o]; // expected-error {{overload resolution selected deleted operator '[]': deleted (xfffff, [])}}
  o(o); // expected-error {{call to deleted function call operator in type 'xfffff': deleted (xfffff, ())}} expected-error {{attempt to use tc1 deleted function: deleted (xfffff, ())}}
  if (o) {} // expected-error {{attempt to use tc1 deleted function: deleted (xfffff, operator bool)}}
  static_cast<bool>(o); // expected-error {{static_cast from 'xfffff' to 'bool' uses deleted function: deleted (xfffff, operator bool)}}

  uses<double, double> to;
  +to; // expected-error {{overload resolution selected deleted operator '+': deleted (uses, +)}}
  to->x; // expected-error {{overload resolution selected deleted operator '->': deleted (uses, ->)}}
  to - to; // expected-error {{overload resolution selected deleted operator '-': deleted (uses, -)}}
  to[to]; // expected-error {{overload resolution selected deleted operator '[]': deleted (uses, [])}}
  to(to); // expected-error {{call to deleted function call operator in type 'uses<double, double>': deleted (uses, ())}} expected-error {{attempt to use tc1 deleted function: deleted (uses, ())}}
  if (to) {} // expected-error {{attempt to use tc1 deleted function: deleted (uses, operator bool)}}
  static_cast<bool>(to); // expected-error {{static_cast from 'uses<double, double>' to 'bool' uses deleted function: deleted (uses, operator bool)}}

  uses<double, int> to_int;
  +to_int; // expected-error {{overload resolution selected deleted operator '+': deleted (uses<T, int>, +)}}
  to_int->x; // expected-error {{overload resolution selected deleted operator '->': deleted (uses<T, int>, ->)}}
  to_int - to_int; // expected-error {{overload resolution selected deleted operator '-': deleted (uses<T, int>, -)}}
  to_int[to_int]; // expected-error {{overload resolution selected deleted operator '[]': deleted (uses<T, int>, [])}}
  to_int(to_int); // expected-error {{call to deleted function call operator in type 'uses<double, int>': deleted (uses<T, int>, ())}} expected-error {{attempt to use tc1 deleted function: deleted (uses<T, int>, ())}}
  if (to_int) {} // expected-error {{attempt to use tc1 deleted function: deleted (uses<T, int>, operator bool)}}
  static_cast<bool>(to_int); // expected-error {{static_cast from 'uses<double, int>' to 'bool' uses deleted function: deleted (uses<T, int>, operator bool)}}

  uses<int, int> to_int_int;
  +to_int_int; // expected-error {{overload resolution selected deleted operator '+': deleted (uses<int, int>, +)}}
  to_int_int->x; // expected-error {{overload resolution selected deleted operator '->': deleted (uses<int, int>, ->)}}
  to_int_int - to_int_int; // expected-error {{overload resolution selected deleted operator '-': deleted (uses<int, int>, -)}}
  to_int_int[to_int_int]; // expected-error {{overload resolution selected deleted operator '[]': deleted (uses<int, int>, [])}}
  to_int_int(to_int_int); // expected-error {{call to deleted function call operator in type 'uses<int, int>': deleted (uses<int, int>, ())}} expected-error {{attempt to use tc1 deleted function: deleted (uses<int, int>, ())}}
  if (to_int_int) {} // expected-error {{attempt to use tc1 deleted function: deleted (uses<int, int>, operator bool)}}
  static_cast<bool>(to_int_int); // expected-error {{static_cast from 'uses<int, int>' to 'bool' uses deleted function: deleted (uses<int, int>, operator bool)}}
};

namespace gh135506 {
struct tc1 {
  // FIXME: We currently don't diagnose these invalid redeclarations if the
  // second declaration is defaulted or deleted. This probably needs to be
  // handled in d() after parsing the defaulted/deleted
  // body.
  friend consteval int f() { return 3; }
  friend consteval int f() = delete("foo");

  friend consteval int We() { return 3; }
  friend consteval int We() = delete;

  friend int body() { return 3; }
  friend int body() = delete;

  friend consteval int c1() = delete; // expected-note {{previous definition is here}}
  friend consteval int c1() { return 3; } // expected-error {{redefinition of 'c1'}}
};

struct currently {
  friend consteval bool operator==(currently, currently) { return true; } // expected-note {{previous declaration is here}}
  friend consteval bool operator==(currently, currently) = default; // expected-error {{defaulting this equality comparison operator is not allowed because it was already declared outside the class}}
};

struct defaulting {
  friend consteval bool operator==(defaulting, defaulting) = default; // expected-note {{previous definition is here}}
  friend consteval bool operator==(defaulting, defaulting) { return true; } // expected-error {{redefinition of 'operator=='}}
};
}
