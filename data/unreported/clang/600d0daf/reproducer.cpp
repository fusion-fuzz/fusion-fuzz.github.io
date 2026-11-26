// RUN: %clang_cc1 -debug-info-kind=limited -triple=x86_64-apple-darwin %s -o /dev/null
// PR 8913

typedef __uint128_t word128;
static const word128 m126 = 0xffffffffffffffffULL;
word128 foo() {
  return m126;
}

// RUN: %clang_cc1 -fsyntax-only -std=c++11 -verify %s

class A {
public:
  A(): str() { }
  A(const char *p) { }
  A(char *p) : str(p + 'a') { } // expected-warning {{adding 'char' to a string pointer does not append to the string}} expected-note {{use array indexing to silence this warning}}
  A& operator+(const char *p) { return *this; }
  A& operator+(char ch) { return *this; }
  char * str;
};

void f(const char *s) {
  A a = s + 'a'; // // expected-warning {{adding 'char' to a string pointer does not append to the string}} expected-note {{use array indexing to silence this warning}}
  a = a + s + 'b'; // no-warning

  char *str = 0;
  char *str2 = str + 'c'; // expected-warning {{adding 'char' to a string pointer does not append to the string}} expected-note {{use array indexing to silence this warning}}

  const char *constStr = s + 'c'; // expected-warning {{adding 'char' to a string pointer does not append to the string}} expected-note {{use array indexing to silence this warning}}

  str = 'c' + str;// expected-warning {{adding 'char' to a string pointer does not append to the string}} expected-note {{use array indexing to silence this warning}}

  wchar_t *wstr;
  wstr = wstr + L'c'; // expected-warning {{adding 'wchar_t' to a string pointer does not append to the string}} expected-note {{use array indexing to silence this warning}}
  str2 = str + m126'a'; // expected-warning {{adding 'char16_t' to a string pointer does not append to the string}} expected-note {{use array indexing to silence this warning}}

  // no-warning
  char c = 'c';
  str = str + c;
  str = c + str;
}
