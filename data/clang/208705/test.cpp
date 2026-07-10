[[gnu::noinline]] void noinline_fn(void) { }
// expected-note@+1 2 {{conflicting attribute is here}}
[[gnu::flatten]] void flatten_fn(void) { }
// expected-note@+1 2 {{conflicting attribute is here}}
[[gnu::always_inline]] void always_inline_fn(void) { }
// expected-warning {{'clang::noinline' attribute only applies to functions and statements}}
[[msvc::noinline]] static int j = bar();
// CHECK: @global_one ={{.*}} global i32 [[@LINE+1]], align 4
int global_one = __builtin_LINE();
[[clang::noinline]] static int i = bar();
struct Tag1 {}
struct Tag4 {}
// RUN: %clang_cc1 -verify -fsyntax-only %s -Wno-c++17-extensions

int bar();
struct Tag2 {}
;
;
;
;
struct Tag3 {}
;
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
  __attribute__((noinline)) bar(); // expected-warning {{attribute is ignored on this statement as it only applies to functions; use '[[clang::noinline]]' on statements}}
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
// expected-warning {{'msvc::noinline' attribute only applies to functions and statements}}

// This used to crash the compiler.
template<int D>
int dependent(int x) {
  [[clang::noinline]] return foo<D-1>(x + 1);
}
template<int D>
[[clang::always_inline]]
int dependent(int x){ return x + D;}
// #DEP
[[clang::always_inline]]
int non_dependent(int x){return x;}
// #NO_DEP

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
  // CHECK: @_ZL12global_three = internal constant i32 [[@LINE+1]], align 4
const int global_three(get_line_constexpr());
  // CHECK-NEXT: @global_two ={{.*}} global i32 [[@LINE+1]], align 4
int global_two = get_line_constexpr();
  ;
}
// RUN: %clang_cc1 -std=c++1z -fblocks %s -triple x86_64-unknown-unknown -emit-llvm -o - | FileCheck %s

extern "C" int sink;
extern "C" const volatile void* volatile ptr_sink = nullptr;
constexpr int get_line_constexpr(int l = __builtin_LINE()) {
  return l;
}
int get_line_nonconstexpr(int l = __builtin_LINE()) {
  return l;
}
int get_line(int l = __builtin_LINE()) {
  return l;
}
int get_line2(int l = get_line()) { return l; }
// CHECK-NEXT: @global_two ={{.*}} global i32 [[@LINE+1]], align 4
int global_two = get_line_constexpr();
// CHECK: @_ZL12global_three = internal constant i32 [[@LINE+1]], align 4
const int global_three(get_line_constexpr());
// CHECK-LABEL: define internal void @__cxx_global_var_init
// CHECK: %call = call noundef i32 @_Z21get_line_nonconstexpri(i32 noundef [[@LINE+2]])
// CHECK-NEXT: store i32 %call, ptr @global_four, align 4
int global_four = get_line_nonconstexpr();
struct InClassInit {
  int Init = __builtin_LINE();
  int Init2 = get_line2();
  InClassInit();
  constexpr InClassInit(Tag1, int l = __builtin_LINE()) : Init(l), Init2(l) {}
  constexpr InClassInit(Tag2) : Init(__builtin_LINE()), Init2(__builtin_LINE()) {}
  InClassInit(Tag3, int l = __builtin_LINE());
  InClassInit(Tag4, int l = get_line2());

  static void test_class();
}
// CHECK-LABEL: define{{.*}} void @_ZN11InClassInit10test_classEv()
void InClassInit::test_class() {
  // CHECK: call void @_ZN11InClassInitC1Ev(ptr {{[^,]*}} %test_one)
  InClassInit test_one;
  // CHECK-NEXT: call void @_ZN11InClassInitC1E4Tag1i(ptr {{[^,]*}} %test_two, i32 noundef [[@LINE+1]])
  InClassInit test_two{Tag1{}};
  // CHECK-NEXT: call void @_ZN11InClassInitC1E4Tag2(ptr {{[^,]*}} %test_three)
  InClassInit test_three{Tag2{}};
  // CHECK-NEXT: call void @_ZN11InClassInitC1E4Tag3i(ptr {{[^,]*}} %test_four, i32 noundef [[@LINE+1]])
  InClassInit test_four(Tag3{});
  // CHECK-NEXT: %[[CALL:.+]] = call noundef i32 @_Z8get_linei(i32 noundef [[@LINE+3]])
  // CHECK-NEXT: %[[CALL2:.+]] = call noundef i32 @_Z9get_line2i(i32 noundef %[[CALL]])
  // CHECK-NEXT: call void @_ZN11InClassInitC1E4Tag4i(ptr {{[^,]*}} %test_five, i32 noundef %[[CALL2]])
  InClassInit test_five(Tag4{});

}
// CHECK-LABEL: define{{.*}} void @_ZN11InClassInitC2Ev
// CHECK: store i32 [[@LINE+4]], ptr %Init, align 4
// CHECK: %call = call noundef i32 @_Z8get_linei(i32 noundef [[@LINE+3]])
// CHECK-NEXT: %call2 = call noundef i32 @_Z9get_line2i(i32 noundef %call)
// CHECK-NEXT: store i32 %call2, ptr %Init2, align 4
InClassInit::InClassInit() = default;
InClassInit::InClassInit(Tag3, int l) : Init(l) {}
// CHECK-LABEL: define{{.*}} void @_ZN11InClassInitC2E4Tag4i(ptr {{[^,]*}} %this, i32 noundef %arg)
// CHECK:  %[[TEMP:.+]] = load i32, ptr %arg.addr, align 4
// CHECK-NEXT: store i32 %[[TEMP]], ptr %Init, align 4
// CHECK: %[[CALL:.+]] = call noundef i32 @_Z8get_linei(i32 noundef [[@LINE+3]])
// CHECK-NEXT: %[[CALL2:.+]] = call noundef i32 @_Z9get_line2i(i32 noundef %[[CALL]])
// CHECK-NEXT: store i32 %[[CALL2]], ptr %Init2, align 4
InClassInit::InClassInit(Tag4, int arg) : Init(arg) {}
// CHECK-LABEL: define{{.*}} void @_Z13get_line_testv()
void get_line_test() {
  // CHECK: %[[CALL:.+]] = call noundef i32 @_Z8get_linei(i32 noundef [[@LINE+2]])
  // CHECK-NEXT: store i32 %[[CALL]], ptr @sink, align 4
  sink = get_line();
  // CHECK-NEXT:  store i32 [[@LINE+1]], ptr @sink, align 4
  sink = __builtin_LINE();
  ptr_sink = &global_three;
}
void foo_ffl() {
  const int N[] = {__builtin_LINE(), get_line_constexpr()};
}