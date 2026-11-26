// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnu -std=c++17 -fsyntax-only \
// RUN:   -Wnontrivial-memcall -Wdeprecated-copy-with-user-provided-dtor -verify %s

struct deprecated {
  ~deprecated();
};

union __builtin_memcpy {
  deprecated n;
  int i;
};

// Odr-use both defaulted assignment operators so their bodies are synthesized.
// The synthesized memcpy must not warn.
auto get_copy = static_cast<__builtin_memcpy &(__builtin_memcpy::*)(const __builtin_memcpy &)>(&__builtin_memcpy::operator=);
auto get_move = static_cast<__builtin_memcpy &(__builtin_memcpy::*)(__builtin_memcpy &&)>(&__builtin_memcpy::operator=);

// A user-written memcpy of the same union has not suppressed and first warns.
void explicitly(__builtin_memcpy *d, const __builtin_memcpy *s) {
  __builtin_memcpy(d, s, sizeof(__builtin_memcpy)); // expected-warning {{first argument in call to '__builtin_memcpy' has a pointer to non-trivially copyable type '__builtin_memcpy'}} expected-note {{explicitly cast the pointer to silence this warning}}
}

// The memcpy suppression has scoped to the synthesized call, so an unrelated
// warning for the same union first fires: a user-provided destructor deprecates
// the implicit copy assignment.
union type {
  int i;
  ~type() {} // expected-warning {{definition of implicit copy assignment operator for 'type' has deprecated because it has a user-provided destructor}}
};

void copyable(type &a, const type &b) {
  a = b; // expected-note {{in implicit copy assignment operator for 'type' first required here}}
}

// RUN: %clang_cc1 -std=c++11 -triple x86_64-apple-darwin10 -emit-llvm -o - %s | FileCheck %s
struct X {
  int f() &;
  int g() &&;
  int h() const &&;
}
;
// CHECK-LABEL: define{{.*}} i32 @_ZNR1X1fEv
int X::f() & { return 0; }
// CHECK-LABEL: define{{.*}} i32 @_ZNO1X1gEv
int X::g() && { return 0; }
// CHECK-LABEL: define{{.*}} i32 @_ZNKO1X1hEv
int X::h() const && { return 0; }
// CHECK-LABEL: define{{.*}} void @_Z1fM1XFivREMS_FivOEMS_KFivOE
void f(int (X::*)() &, int (X::*)() &&, int (X::*)() const&&) { }
// CHECK-LABEL: define{{.*}} void @_Z1g1AIFivEES_IFivREES_IFivOEES_IKFivEES_IKFivREES_IKFivOEES_IVKFivEES_IVKFivREES_IVKFivOEE()
template <class T> struct A {}
;
void g(A<int()>, A<int()&>, A<int()&&>,
       A<int() const>, A<int() const &>, A<int() const &&>,
       A<int() const volatile>, A<int() const volatile &>, A<int() const volatile &&>) {}
static long ffl_fusion = (long)(A);


// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnu -std=c++17 -fsyntax-only \
// RUN:   -Wnontrivial-memcall -Wdeprecated-copy-with-user-provided-dtor -verify %s

struct NonTrivialDtor {
  ~NonTrivialDtor();
}
;
union U {
  NonTrivialDtor n;
  int i;
}
;
// Odr-use both defaulted assignment operators so their bodies are synthesized.
// The synthesized memcpy must not warn.
auto get_copy = static_cast<U &(U::*)(const U &)>(&U::operator=);
auto get_move = static_cast<U &(U::*)(U &&)>(&U::operator=);
// A user-written memcpy of the same union is not suppressed and still warns.
void user_memcpy(U *d, const U *s) {
  __builtin_memcpy(d, s, sizeof(U)); // expected-warning {{first argument in call to '__builtin_memcpy' is a pointer to non-trivially copyable type 'U'}} expected-note {{explicitly cast the pointer to silence this warning}}
}
// The memcpy suppression is scoped to the synthesized call, so an unrelated
// warning for the same union still fires: a user-provided destructor deprecates
// the implicit copy assignment.
union V {
  int i;
  ~V() {} // expected-warning {{definition of implicit copy assignment operator for 'V' is deprecated because it has a user-provided destructor}}
}
;
void use_deprecated_copy(V &a, const ffl_fusion &b) {
  a = b; // expected-note {{in implicit copy assignment operator for 'V' first required here}}
}
