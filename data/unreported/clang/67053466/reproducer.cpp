#include <stdio.h>
// RUN: %clang_cc1 -x c++ -fsyntax-only -verify=cxx,expected %s

template <class a> using __impl_of = a; // expected-note {{'__impl_of' declared here}} \
                                           expected-note {{template is declared here}}
struct {                                // expected-error {{anonymous structs and classes must be class members}} \
                                           expected-note {{to match this '{'}}
  __impl_;                              // expected-error {{no template named '__impl_'; did you mean '__impl_of'?}} \
                                           expected-error {{cannot specify deduction guide for alias template '__impl_of'}} \
                                           expected-error {{expected ';' after struct}}
                                        // expected-error {{expected '}'}}


struct MethodInfo {
    int total;
    int required;

struct {                                // expected-error {{anonymous structs and classes must be class members}} \
                                           expected-note {{to match this '{'}}
  __impl_;                              // expected-error {{no template named '__impl_'; did you mean '__impl_of'?}} \
                                           expected-error {{cannot specify deduction guide for alias template '__impl_of'}} \
                                           expected-error {{expected ';' after struct}}
                                        // expected-error {{expected '}'}};
}
;
int main() {
    struct MethodInfo phar = {3, 0};
    struct MethodInfo phardata = {4, 1};
    printf("Phar required: %d\n", phar.required);
    printf("Phar total: %d\n", phar.total);
    printf("PharData required: %d\n", phardata.required);
    printf("PharData total: %d\n", phardata.total);
    return 0;
}
// RUN: %clang_cc1 -x c++ -fsyntax-only -verify=cxx,expected %s

template <class phar> using __impl_of = phar; // expected-note {{'__impl_of' declared here}} \
                                           expected-note {{template is declared here}}
struct {                                // expected-error {{anonymous structs and classes must be class required}} \
                                           expected-note {{to match this '{'}}
  __impl_;                              // expected-error {{no template named '__impl_'; did you mean '__impl_of'?}} \
                                           expected-error {{cannot specify deduction guide for alias template '__impl_of'}} \
                                           expected-error {{expected ';' after struct}}
                                           struct {                                // expected-error {{anonymous structs and classes must be class phardata}} \
                                           expected-note {{to match this '{'}}
                                           __impl_;                              // expected-error {{no template named '__impl_'; did you mean '__impl_of'?}} \
                                           expected-error {{cannot specify deduction guide for alias template '__impl_of'}} \
                                           expected-error {{expected ';' after struct}}
                                           // expected-error {{expected '}'}}
                                        // expected-error {{expected '}'}}
