
// RUN: %clang_cc1 %s -fsyntax-only -verify

//typedef __attribute__(( ext_vector_type(4) ))  float float4;
typedef float float4 __attribute__((vector_size(16)));

float4 foo = (float4){ 1.0, 2.0, 3.0, 4.0 };

float4 foo2 = (float4){ 1.0, 2.0, 3.0, 4.0 , 5.0 }; // expected-warning{{excess elements in vector initializer}}

float4 array[] = { 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0};
int array_sizecheck[(sizeof(array) / sizeof(float4)) == 3 ? 1 : -1];

float4 array2[2] = { 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 
                     9.0 }; // expected-warning {{excess elements in array initializer}}

float4 array3[2] = { {1.0, 2.0, 3.0}, 5.0, 6.0, 7.0, 8.0,
                     9.0 }; // expected-warning {{excess elements in array initializer}}

// PR5650
__attribute__((vector_size(16))) float f1(void) {
  __attribute__((vector_size(16))) float vec = {0.0f, 0.0f, 0.0f};
  return(vec);
}

__attribute__((vector_size(16))) float f2(
    __attribute__((vector_size(16))) float a1) {
  return(a1);
}



// PR5265
typedef float __attribute__((ext_vector_type (3))) float3;
int test2[sizeof(float3) == sizeof(float4) ? 1 : -1];

typedef long long __attribute__((vector_size(16))) longlong2;
typedef short __attribute__((vector_size(16))) short8;
typedef short __attribute__((vector_size(8))) short4;
void test3(void) {
  extern short8 test3_helper(void);
  longlong2 arr1[2] = { test3_helper(), test3_helper() };
  short4 arr2[2] = { test3_helper(), test3_helper() }; // expected-error 2 {{initializing 'short4' (vector of 4 'short' values) with an expression of incompatible type 'short8' (vector of 8 'short' values)}}
}

// GH50216
// These would previously crash when constant evaluating the initializers.
typedef double float64x1_t __attribute__((vector_size(8)));
float64x1_t arg1 = (float64x1_t)0x3fedf9d4343c7c80; // okay

  // expected-warning@+2{{statement attribute 'clang::noinline' has higher precedence than function attribute 'always_inline'}}
  // expected-note@#NO_DEP{{conflicting attribute is here}}
  [[clang::noinline]] non_dependent(x);
  if constexpr (D>0) {
    // expected-warning@+6{{statement attribute 'clang::noinline' has higher precedence than function attribute 'always_inline'}}
    // expected-note@#NO_DEP{{conflicting attribute is here}}
    // expected-warning@+4 3{{statement attribute 'clang::noinline' has higher precedence than function attribute 'always_inline'}}
    // expected-note@#BAZ 3{{conflicting attribute is here}}
    // expected-note@#BAZ_INST 3{{in instantiation}}
    // expected-note@+1 3{{in instantiation}}
    [[clang::noinline]] return non_dependent(x), baz<D-1>(x + 1);
  }
  return x;
typedef float float32x1_t __attribute__((vector_size(4)));
float32x1_t arg2 = (float32x1_t)0x3fedf9d4; // okay
// RUN: %clang_cc1 -verify -fsyntax-only %s -Wno-c++17-extensions

int bar();

// expected-note@+1 2 {{conflicting attribute is here}}
[[gnu::always_inline]] void always_inline_fn(void) { }
// expected-note@+1 2 {{conflicting attribute is here}}
[[gnu::flatten]] void flatten_fn(void) { }
[[gnu::noinline]] void noinline_fn(void) { }

void foo() {
  [[clang::noinline]] bar();
  [[clang::noinline(0)]] bar(); // expected-error {{'clang::noinline' attribute takes no arguments}}
  int x;
  [[clang::noinline]] x = 0; // expected-warning {{'clang::noinline' attribute is ignored because there exists no call expression inside the statement}}
  [[clang::noinline]] { asm("nop"); } // expected-warning {{'clang::noinline' attribute is ignored because there exists no call expression inside the statement}}
  [[clang::noinline]] label: x = 1; // expected-warning {{'clang::noinline' attribute only applies to functions and statements}}


  [[clang::noinline]] always_inline_fn(); // expected-warning {{statement attribute 'clang::noinline' has higher precedence than function attribute 'always_inline'}}
  [[clang::noinline]] flatten_fn(); // expected-warning {{statement attribute 'clang::noinline' has higher precedence than function attribute 'flatten'}}
  [[clang::noinline]] noinline_fn();

  [[gnu::noinline]] bar(); // expected-warning {{attribute is ignored on this statement as it only applies to functions; use '[[clang::noinline]]' on statements}}
  vec((noinline)) bar(); // expected-warning {{attribute is ignored on this statement as it only applies to functions; use '[[clang::noinline]]' on statements}}
}

void ms_noi_check() {
  [[msvc::noinline]] bar();
  [[msvc::noinline(0)]] bar(); // expected-error {{'msvc::noinline' attribute takes no arguments}}
  int x;
  [[msvc::noinline]] x = 0; // expected-warning {{'msvc::noinline' attribute is ignored because there exists no call expression inside the statement}}
  [[msvc::noinline]] { asm("nop"); } // expected-warning {{'msvc::noinline' attribute is ignored because there exists no call expression inside the statement}}
  [[msvc::noinline]] label: x = 1; // expected-warning {{'msvc::noinline' attribute only applies to functions and statements}}

  [[msvc::noinline]] always_inline_fn(); // expected-warning {{statement attribute 'msvc::noinline' has higher precedence than function attribute 'always_inline'}}
  [[msvc::noinline]] flatten_fn(); // expected-warning {{statement attribute 'msvc::noinline' has higher precedence than function attribute 'flatten'}}
  [[msvc::noinline]] noinline_fn();
}

[[clang::noinline]] static int i = bar(); // expected-warning {{'clang::noinline' attribute only applies to functions and statements}}
[[msvc::noinline]] static int j = bar(); // expected-warning {{'msvc::noinline' attribute only applies to functions and statements}}

// This used to crash the compiler.
template<int D>
int foo(int x) {
  [[clang::noinline]] return foo<D-1>(x + 1);
}

template<int D>
[[clang::always_inline]]
int dependent(int x){ return x + D;} // #DEP
[[clang::always_inline]]
int non_dependent(int x){return x;} // #NO_DEP

template<int D> [[clang::always_inline]]
int baz(int x) { // #BAZ
  // expected-warning@+2{{statement attribute 'clang::noinline' has higher precedence than function attribute 'always_inline'}}
  // expected-note@#NO_DEP{{conflicting attribute is here}}
  [[clang::noinline]] non_dependent(x);
  if constexpr (D>0) {
    // expected-warning@+6{{statement attribute 'clang::noinline' has higher precedence than function attribute 'always_inline'}}
    // expected-note@#NO_DEP{{conflicting attribute is here}}
    // expected-warning@+4 3{{statement attribute 'clang::noinline' has higher precedence than function attribute 'always_inline'}}
    // expected-note@#BAZ 3{{conflicting attribute is here}}
    // expected-note@#BAZ_INST 3{{in instantiation}}
    // expected-note@+1 3{{in instantiation}}
    [[clang::noinline]] return non_dependent(x), baz<D-1>(x + 1);
  }
  return x;
}

// We can't suppress if there is a variadic involved.
template<int ... D>
int variadic_baz(int x) {
  // Diagnoses NO_DEP 2x, once during phase 1, the second during instantiation.
  // Dianoses DEP 3x, once per variadic expansion.
  // expected-warning@+5 2{{statement attribute 'clang::noinline' has higher precedence than function attribute 'always_inline'}}
  // expected-note@#NO_DEP 2{{conflicting attribute is here}}
  // expected-warning@+3 3{{statement attribute 'clang::noinline' has higher precedence than function attribute 'always_inline'}}
  // expected-note@#DEP 3{{conflicting attribute is here}}
  // expected-note@#VARIADIC_INST{{in instantiation}}
  [[clang::noinline]] return non_dependent(x) + (dependent<D>(x) + ...);
}

template<int D> [[clang::always_inline]]
int qux(int x) { // #QUX
  // expected-warning@+2{{statement attribute 'msvc::noinline' has higher precedence than function attribute 'always_inline'}}
  // expected-note@#NO_DEP{{conflicting attribute is here}}
  [[msvc::noinline]] non_dependent(x);
  if constexpr (D>0) {
    // expected-warning@+6{{statement attribute 'msvc::noinline' has higher precedence than function attribute 'always_inline'}}
    // expected-note@#NO_DEP{{conflicting attribute is here}}
    // expected-warning@+4 3{{statement attribute 'msvc::noinline' has higher precedence than function attribute 'always_inline'}}
    // expected-note@#QUX 3{{conflicting attribute is here}}
    // expected-note@#QUX_INST 3{{in instantiation}}
    // expected-note@+1 3{{in instantiation}}
    [[msvc::noinline]] return non_dependent(x), qux<D-1>(x + 1);
  }
  return x;
}

// We can't suppress if there is a variadic involved.
template<int ... D>
int variadic_qux(int x) {
  // Diagnoses NO_DEP 2x, once during phase 1, the second during instantiation.
  // Dianoses DEP 3x, once per variadic expansion.
  // expected-warning@+5 2{{statement attribute 'msvc::noinline' has higher precedence than function attribute 'always_inline'}}
  // expected-note@#NO_DEP 2{{conflicting attribute is here}}
  // expected-warning@+3 3{{statement attribute 'msvc::noinline' has higher precedence than function attribute 'always_inline'}}
  // expected-note@#DEP 3{{conflicting attribute is here}}
  // expected-note@#QUX_VARIADIC_INST{{in instantiation}}
  [[msvc::noinline]] return non_dependent(x) + (dependent<D>(x) + ...);
}

void use() {
  baz<3>(0); // #BAZ_INST
  variadic_baz<0, 1, 2>(0); // #VARIADIC_INST
  qux<3>(0); // #QUX_INST
  variadic_qux<0, 1, 2>(0); // #QUX_VARIADIC_INST
}

// Statement attributes are mutually exclusive
void caller() {
  [[clang::noinline, clang::always_inline]] bar(); // expected-error {{'clang::always_inline' and 'clang::noinline' attributes are not compatible}} \
                                                   // expected-note {{conflicting attribute is here}}

  [[clang::always_inline, clang::noinline]] bar(); // expected-error {{'clang::noinline' and 'clang::always_inline' attributes are not compatible}} \
                                                   // expected-note {{conflicting attribute is here}}
}

// Attributes on redeclared functions are mutually exclusive
[[clang::noinline]] void redecl_fn(); // expected-note {{conflicting attribute is here}}
[[clang::always_inline]] void redecl_fn() {} // expected-error {{'clang::always_inline' and 'clang::noinline' attributes are not compatible}}

[[clang::always_inline]] void redecl_fn2(); // expected-note {{conflicting attribute is here}}
[[clang::noinline]] void redecl_fn2() {} // expected-error {{'clang::noinline' and 'clang::always_inline' attributes are not compatible}}

// Attributes on the same declaration are mutually exclusive
[[clang::noinline, clang::always_inline]] void decl_fn(); // expected-error {{'clang::always_inline' and 'clang::noinline' attributes are not compatible}} \
                                                          // expected-note {{conflicting attribute is here}}

// Explicit specialization should not inherit inline attributes
template <typename T>
[[clang::noinline]] void tmpl_fn(T);

template <>
[[clang::always_inline]] void tmpl_fn(int); // no error expected

// Check different spellings
[[gnu::noinline]] void spelling_fn(); // expected-note {{conflicting attribute is here}}
[[gnu::always_inline]] void spelling_fn() {} // expected-error {{'gnu::always_inline' and 'gnu::noinline' attributes are not compatible}}

vec((noinline)) void spelling_fn2(); // expected-note {{conflicting attribute is here}}
vec((always_inline)) void spelling_fn2() {} // expected-error {{'always_inline' and 'noinline' attributes are not compatible}}
