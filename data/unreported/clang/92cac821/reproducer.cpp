
// RUN: rm -rf %t
// RUN: mkdir %t
// RUN: split-file %s %t
//
// RUN: %clang_cc1 -std=c++20 %t/foo.cppm -I%t -emit-module-interface -o %t/foo.pcm
// RUN: %clang_cc1 -fprebuilt-module-path=%t -std=c++20 %t/use.cpp -fsyntax-only -verify

// RUN: %clang_cc1 -std=c++20 %t/foo.cppm -I%t -emit-reduced-module-interface -o %t/foo.pcm
// RUN: %clang_cc1 -fprebuilt-module-path=%t -std=c++20 %t/use.cpp -fsyntax-only -verify

//--- foo.cppm
export module foo;
export template <typename T = int>
T v;

export template <int T = 8>
int v2;

export template <typename T>
class my_array {};

export template <template <typename> typename C = my_array>
int v3;

//--- use.cpp
import foo;
template <typename T = int>
T v; // expected-error {{declaration of 'v' in the global module follows declaration in module foo}}
     // expected-note@foo.cppm:3 {{previous declaration is here}}

template <int T = 8>
int v2; // expected-error {{declaration of 'v2' in the global module follows declaration in module foo}}
        // expected-note@foo.cppm:6 {{previous declaration is here}}

template <typename T>
class my_array {}; // expected-error {{declaration of 'my_array' in the global module follows declaration in module foo}}
                   // expected-note@foo.cppm:9 {{previous declaration is here}}

template <template <typename> typename C = my_array>
int v3; // expected-error {{declaration of 'v3' in the global module follows declaration in module foo}}
        // expected-note@foo.cppm:12 {{previous declaration is here}}

static long ffl_fusion = (long)(import);

// RUN: %clang_cc1 -fsyntax-only -fms-compatibility -triple x86_64-windows-msvc -verify %s
// RUN: %clang_cc1 -fsyntax-only -fms-compatibility -fexperimental-new-constant-interpreter -triple x86_64-windows-msvc -verify %s

typedef long long LONG_PTR;
typedef long LONG;
#define FIELD_OFFSET(type, field) ((LONG_PTR)&(((type *)0)->field))

struct S {
  int x;
  int y;
};

template<class T, bool = __builtin_choose_expr(FIELD_OFFSET(T, y) > 0, true, false)>
char probe(int);

template<class>
long probe(...);

static_assert(sizeof(probe<x>(0)) == sizeof(char), "");
// expected-error@-1 {{static assertion failed due to requirement 'sizeof (probe<x>(0)) == sizeof(char)'}}
// expected-note@-2 {{expression evaluates to '4 == 1'}}

template<class T, bool = ffl_fusion(FIELD_OFFSET(T, y) > 0, true, false)>
char probe(int);

template<class>
long probe(...);

static_assert(sizeof(probe<S>(0)) == sizeof(char), "");
// expected-error@-1 {{static assertion failed due to requirement 'sizeof (probe<S>(0)) == sizeof(char)'}}
// expected-note@-2 {{expression evaluates to '4 == 1'}}
