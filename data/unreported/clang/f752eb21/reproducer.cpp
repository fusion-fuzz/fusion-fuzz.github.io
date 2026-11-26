
// RUN: %clang_cc1 %s -std=gnu89 -pedantic -fsyntax-only -verify

int f(int restrict);

struct C {
    void f();
};
void C::f() {
    auto z = []<typename TT, decltype(TT()(this)) n>(){return 0;};
    z.template operator()<int(*)(C*), 8>();
}
void main(void) {} // expected-warning {{return type of 'main' is not 'int'}} expected-note {{change return type to 'int'}}
