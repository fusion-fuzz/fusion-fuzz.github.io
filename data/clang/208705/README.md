*Fusion-Fuzz Bug Report*

**ID:** `a69ebd3f` &nbsp;·&nbsp; **Signature:** `Stack dump: <eof> parser at end of file [clang::Expr::getReferencedDeclOfCallee > clang::Sema::CheckNoInlineAttr > clang::Sema::SubstStmt]` &nbsp;·&nbsp; **RC:** `1`

The following code:

```cpp
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
```

Resulted in this output:

```
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:7:3: warning: 'msvc::noinline' attribute only applies to functions and statements [-Wignored-attributes]
    7 | [[msvc::noinline]] static int j = bar();
      |   ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:7:35: error: use of undeclared identifier 'bar'
    7 | [[msvc::noinline]] static int j = bar();
      |                                   ^~~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:10:3: warning: 'clang::noinline' attribute only applies to functions and statements [-Wignored-attributes]
   10 | [[clang::noinline]] static int i = bar();
      |   ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:10:36: error: use of undeclared identifier 'bar'
   10 | [[clang::noinline]] static int i = bar();
      |                                    ^~~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:11:15: error: expected ';' after struct
   11 | struct Tag1 {}
      |               ^
      |               ;
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:12:15: error: expected ';' after struct
   12 | struct Tag4 {}
      |               ^
      |               ;
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:25:5: error: 'clang::noinline' attribute takes no arguments
   25 |   [[clang::noinline(0)]] bar(); // expected-error {{'clang::noinline' attribute takes no arguments}}
      |     ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:27:23: warning: 'clang::noinline' attribute is ignored because there exists no call expression inside the statement [-Wignored-attributes]
   27 |   [[clang::noinline]] x = 0; // expected-warning {{'clang::noinline' attribute is ignored because there exists no call expression inside the statement}}
      |                       ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:28:23: warning: 'clang::noinline' attribute is ignored because there exists no call expression inside the statement [-Wignored-attributes]
   28 |   [[clang::noinline]] { asm("nop"); } // expected-warning {{'clang::noinline' attribute is ignored because there exists no call expression inside the statement}}
      |                       ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:29:5: warning: 'clang::noinline' attribute only applies to functions and statements [-Wignored-attributes]
   29 |   [[clang::noinline]] label: x = 1; // expected-warning {{'clang::noinline' attribute only applies to functions and statements}}
      |     ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:32:23: warning: statement attribute 'clang::noinline' has higher precedence than function attribute 'always_inline' [-Wignored-attributes]
   32 |   [[clang::noinline]] always_inline_fn(); // expected-warning {{statement attribute 'clang::noinline' has higher precedence than function attribute 'always_inline'}}
      |                       ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:5:24: note: conflicting attribute is here
    5 | [[gnu::always_inline]] void always_inline_fn(void) { }
      |                        ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:33:23: warning: statement attribute 'clang::noinline' has higher precedence than function attribute 'flatten' [-Wignored-attributes]
   33 |   [[clang::noinline]] flatten_fn(); // expected-warning {{statement attribute 'clang::noinline' has higher precedence than function attribute 'flatten'}}
      |                       ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:3:18: note: conflicting attribute is here
    3 | [[gnu::flatten]] void flatten_fn(void) { }
      |                  ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:36:21: warning: attribute is ignored on this statement as it only applies to functions; use '[[clang::noinline]]' on statements [-Wignored-attributes]
   36 |   [[gnu::noinline]] bar(); // expected-warning {{attribute is ignored on this statement as it only applies to functions; use '[[clang::noinline]]' on statements}}
      |                     ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:37:29: warning: attribute is ignored on this statement as it only applies to functions; use '[[clang::noinline]]' on statements [-Wignored-attributes]
   37 |   __attribute__((noinline)) bar(); // expected-warning {{attribute is ignored on this statement as it only applies to functions; use '[[clang::noinline]]' on statements}}
      |                             ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:41:5: error: 'msvc::noinline' attribute takes no arguments
   41 |   [[msvc::noinline(0)]] bar(); // expected-error {{'msvc::noinline' attribute takes no arguments}}
      |     ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:43:22: warning: 'msvc::noinline' attribute is ignored because there exists no call expression inside the statement [-Wignored-attributes]
   43 |   [[msvc::noinline]] x = 0; // expected-warning {{'msvc::noinline' attribute is ignored because there exists no call expression inside the statement}}
      |                      ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:44:22: warning: 'msvc::noinline' attribute is ignored because there exists no call expression inside the statement [-Wignored-attributes]
   44 |   [[msvc::noinline]] { asm("nop"); } // expected-warning {{'msvc::noinline' attribute is ignored because there exists no call expression inside the statement}}
      |                      ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:45:5: warning: 'msvc::noinline' attribute only applies to functions and statements [-Wignored-attributes]
   45 |   [[msvc::noinline]] label: x = 1; // expected-warning {{'msvc::noinline' attribute only applies to functions and statements}}
      |     ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:47:22: warning: statement attribute 'msvc::noinline' has higher precedence than function attribute 'always_inline' [-Wignored-attributes]
   47 |   [[msvc::noinline]] always_inline_fn(); // expected-warning {{statement attribute 'msvc::noinline' has higher precedence than function attribute 'always_inline'}}
      |                      ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:5:24: note: conflicting attribute is here
    5 | [[gnu::always_inline]] void always_inline_fn(void) { }
      |                        ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:48:22: warning: statement attribute 'msvc::noinline' has higher precedence than function attribute 'flatten' [-Wignored-attributes]
   48 |   [[msvc::noinline]] flatten_fn(); // expected-warning {{statement attribute 'msvc::noinline' has higher precedence than function attribute 'flatten'}}
      |                      ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:3:18: note: conflicting attribute is here
    3 | [[gnu::flatten]] void flatten_fn(void) { }
      |                  ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:56:33: error: comparison between pointer and integer ('void (*)()' and 'int')
   56 |   [[clang::noinline]] return foo<D-1>(x + 1);
      |                              ~~~^~~~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:56:23: warning: 'clang::noinline' attribute is ignored because there exists no call expression inside the statement [-Wignored-attributes]
   56 |   [[clang::noinline]] return foo<D-1>(x + 1);
      |                       ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:59:3: warning: attribute declaration must precede definition [-Wignored-attributes]
   59 | [[clang::always_inline]]
      |   ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:55:5: note: previous definition is here
   55 | int dependent(int x) {
      |     ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:60:5: error: redefinition of 'dependent'
   60 | int dependent(int x){ return x + D;}
      |     ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:55:5: note: previous definition is here
   55 | int dependent(int x) {
      |     ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:70:23: warning: statement attribute 'clang::noinline' has higher precedence than function attribute 'always_inline' [-Wignored-attributes]
   70 |   [[clang::noinline]] non_dependent(x);
      |                       ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:63:1: note: conflicting attribute is here
   63 | int non_dependent(int x){return x;}
      | ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:78:25: warning: statement attribute 'clang::noinline' has higher precedence than function attribute 'always_inline' [-Wignored-attributes]
   78 |     [[clang::noinline]] return non_dependent(x), baz<D-1>(x + 1);
      |                         ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:63:1: note: conflicting attribute is here
   63 | int non_dependent(int x){return x;}
      | ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:92:23: warning: statement attribute 'clang::noinline' has higher precedence than function attribute 'always_inline' [-Wignored-attributes]
   92 |   [[clang::noinline]] return non_dependent(x) + (dependent<D>(x) + ...);
      |                       ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:63:1: note: conflicting attribute is here
   63 | int non_dependent(int x){return x;}
      | ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:98:22: warning: statement attribute 'msvc::noinline' has higher precedence than function attribute 'always_inline' [-Wignored-attributes]
   98 |   [[msvc::noinline]] non_dependent(x);
      |                      ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:63:1: note: conflicting attribute is here
   63 | int non_dependent(int x){return x;}
      | ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:106:24: warning: statement attribute 'msvc::noinline' has higher precedence than function attribute 'always_inline' [-Wignored-attributes]
  106 |     [[msvc::noinline]] return non_dependent(x), qux<D-1>(x + 1);
      |                        ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:63:1: note: conflicting attribute is here
   63 | int non_dependent(int x){return x;}
      | ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:120:22: warning: statement attribute 'msvc::noinline' has higher precedence than function attribute 'always_inline' [-Wignored-attributes]
  120 |   [[msvc::noinline]] return non_dependent(x) + (dependent<D>(x) + ...);
      |                      ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:63:1: note: conflicting attribute is here
   63 | int non_dependent(int x){return x;}
      | ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:128:24: error: use of undeclared identifier 'get_line_constexpr'
  128 | const int global_three(get_line_constexpr());
      |                        ^~~~~~~~~~~~~~~~~~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:130:18: error: use of undeclared identifier 'get_line_constexpr'
  130 | int global_two = get_line_constexpr();
      |                  ^~~~~~~~~~~~~~~~~~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:165:2: error: expected ';' after struct
  165 | }
      |  ^
      |  ;
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:78:25: warning: statement attribute 'clang::noinline' has higher precedence than function attribute 'always_inline' [-Wignored-attributes]
   78 |     [[clang::noinline]] return non_dependent(x), baz<D-1>(x + 1);
      |                         ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:123:3: note: in instantiation of function template specialization 'baz<3>' requested here
  123 |   baz<3>(0); // #BAZ_INST
      |   ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:67:1: note: conflicting attribute is here
   67 | int baz(int x) { // #BAZ
      | ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:78:25: warning: statement attribute 'clang::noinline' has higher precedence than function attribute 'always_inline' [-Wignored-attributes]
   78 |     [[clang::noinline]] return non_dependent(x), baz<D-1>(x + 1);
      |                         ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:78:50: note: in instantiation of function template specialization 'baz<2>' requested here
   78 |     [[clang::noinline]] return non_dependent(x), baz<D-1>(x + 1);
      |                                                  ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:123:3: note: in instantiation of function template specialization 'baz<3>' requested here
  123 |   baz<3>(0); // #BAZ_INST
      |   ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:67:1: note: conflicting attribute is here
   67 | int baz(int x) { // #BAZ
      | ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:78:25: warning: statement attribute 'clang::noinline' has higher precedence than function attribute 'always_inline' [-Wignored-attributes]
   78 |     [[clang::noinline]] return non_dependent(x), baz<D-1>(x + 1);
      |                         ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:78:50: note: in instantiation of function template specialization 'baz<1>' requested here
   78 |     [[clang::noinline]] return non_dependent(x), baz<D-1>(x + 1);
      |                                                  ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:78:50: note: in instantiation of function template specialization 'baz<2>' requested here
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:123:3: note: in instantiation of function template specialization 'baz<3>' requested here
  123 |   baz<3>(0); // #BAZ_INST
      |   ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:67:1: note: conflicting attribute is here
   67 | int baz(int x) { // #BAZ
      | ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:92:50: error: no matching function for call to 'dependent'
   92 |   [[clang::noinline]] return non_dependent(x) + (dependent<D>(x) + ...);
      |                                                  ^~~~~~~~~~~~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:124:3: note: in instantiation of function template specialization 'variadic_baz<0, 1, 2>' requested here
  124 |   variadic_baz<0, 1, 2>(0); // #VARIADIC_INST
      |   ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:60:5: note: candidate template ignored: substitution failure [with D = 2]
   60 | int dependent(int x){ return x + D;}
      |     ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:92:50: error: no matching function for call to 'dependent'
   92 |   [[clang::noinline]] return non_dependent(x) + (dependent<D>(x) + ...);
      |                                                  ^~~~~~~~~~~~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:60:5: note: candidate template ignored: substitution failure [with D = 1]
   60 | int dependent(int x){ return x + D;}
      |     ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:92:50: error: no matching function for call to 'dependent'
   92 |   [[clang::noinline]] return non_dependent(x) + (dependent<D>(x) + ...);
      |                                                  ^~~~~~~~~~~~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:60:5: note: candidate template ignored: substitution failure [with D = 0]
   60 | int dependent(int x){ return x + D;}
      |     ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:92:23: warning: statement attribute 'clang::noinline' has higher precedence than function attribute 'always_inline' [-Wignored-attributes]
   92 |   [[clang::noinline]] return non_dependent(x) + (dependent<D>(x) + ...);
      |                       ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:63:1: note: conflicting attribute is here
   63 | int non_dependent(int x){return x;}
      | ^
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace, preprocessed source, and associated run script.
Stack dump:
0.	Program arguments: clang++ -fsyntax-only -O1 -fno-strict-aliasing -ffp-contract=fast /home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp
1.	<eof> parser at end of file
2.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmput_0frsq/a69ebd3f.cpp:84:5: instantiating function definition 'variadic_baz<0, 1, 2>'
 #0 0x00007fe94083e5ea llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/lib/llvm-22/bin/../lib/libLLVM.so.22.1+0x4e9f5ea)
 #1 0x00007fe94083bdf7 llvm::sys::RunSignalHandlers() (/usr/lib/llvm-22/bin/../lib/libLLVM.so.22.1+0x4e9cdf7)
 #2 0x00007fe94076cd04 (/usr/lib/llvm-22/bin/../lib/libLLVM.so.22.1+0x4dcdd04)
 #3 0x00007fe93b410970 (/usr/lib/x86_64-linux-gnu/libc.so.6+0x40970)
 #4 0x00007fe9463d1710 clang::Expr::getReferencedDeclOfCallee() (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x19e7710)
 #5 0x00007fe94701fbb4 clang::Sema::CheckNoInlineAttr(clang::Stmt const*, clang::Stmt const*, clang::AttributeCommonInfo const&) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x2635bb4)
 #6 0x00007fe94718bb22 (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x27a1b22)
 #7 0x00007fe947179e2d (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x278fe2d)
 #8 0x00007fe94713812f clang::Sema::SubstStmt(clang::Stmt*, clang::MultiLevelTemplateArgumentList const&) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x274e12f)
 #9 0x00007fe9471b80f4 clang::Sema::InstantiateFunctionDefinition(clang::SourceLocation, clang::FunctionDecl*, bool, bool, bool) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x27ce0f4)
#10 0x00007fe9471bb458 clang::Sema::PerformPendingInstantiations(bool, bool) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x27d1458)
#11 0x00007fe946a9ca85 clang::Sema::ActOnEndOfTranslationUnitFragment(clang::TUFragmentKind) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x20b2a85)
#12 0x00007fe946a9d081 clang::Sema::ActOnEndOfTranslationUnit() (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x20b3081)
#13 0x00007fe9460e05bc clang::Parser::ParseTopLevelDecl(clang::OpaquePtr<clang::DeclGroupRef>&, clang::Sema::ModuleImportState&) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x16f65bc)
#14 0x00007fe94601f67e clang::ParseAST(clang::Sema&, bool, bool) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x163567e)
#15 0x00007fe947d59bef clang::FrontendAction::Execute() (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x336fbef)
#16 0x00007fe947ccd044 clang::CompilerInstance::ExecuteAction(clang::FrontendAction&) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x32e3044)
#17 0x00007fe947de7f9a clang::ExecuteCompilerInvocation(clang::CompilerInstance*) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x33fdf9a)
#18 0x000055589ff39cdd cc1_main(llvm::ArrayRef<char const*>, char const*, void*) (/usr/lib/llvm-22/bin/clang+0x13cdd)
#19 0x000055589ff3653b (/usr/lib/llvm-22/bin/clang+0x1053b)
#20 0x000055589ff37fcc (/usr/lib/llvm-22/bin/clang+0x11fcc)
#21 0x00007fe947981afd (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x2f97afd)
#22 0x00007fe94076c9d0 llvm::CrashRecoveryContext::RunSafely(llvm::function_ref<void ()>) (/usr/lib/llvm-22/bin/../lib/libLLVM.so.22.1+0x4dcd9d0)
#23 0x00007fe9479815b1 clang::driver::CC1Command::Execute(llvm::ArrayRef<std::optional<llvm::StringRef>>, std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char>>*, bool*) const (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x2f975b1)
#24 0x00007fe947940732 clang::driver::Compilation::ExecuteCommand(clang::driver::Command const&, clang::driver::Command const*&, bool) const (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x2f56732)
#25 0x00007fe9479408fe clang::driver::Compilation::ExecuteJobs(clang::driver::JobList const&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&, bool) const (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x2f568fe)
#26 0x00007fe9479621ff clang::driver::Driver::ExecuteCompilation(clang::driver::Compilation&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x2f781ff)
#27 0x000055589ff3602d clang_main(int, char**, llvm::ToolContext const&) (/usr/lib/llvm-22/bin/clang+0x1002d)
#28 0x000055589ff449aa main (/usr/lib/llvm-22/bin/clang+0x1e9aa)
#29 0x00007fe93b3f9f77 (/usr/lib/x86_64-linux-gnu/libc.so.6+0x29f77)
#30 0x00007fe93b3fa027 __libc_start_main (/usr/lib/x86_64-linux-gnu/libc.so.6+0x2a027)
#31 0x000055589ff341d1 _start (/usr/lib/llvm-22/bin/clang+0xe1d1)
clang++: error: clang frontend command failed with exit code 139 (use -v to see invocation)
Debian clang version 22.1.8 (1+b1)
Target: x86_64-pc-linux-gnu
Thread model: posix
InstalledDir: /usr/lib/llvm-22/bin
clang++: note: diagnostic msg: 
********************

PLEASE ATTACH THE FOLLOWING FILES TO THE BUG REPORT:
Preprocessed source(s) and associated run script(s) are located at:
clang++: note: diagnostic msg: /tmp/a69ebd3f-e1fc71.cpp
clang++: note: diagnostic msg: /tmp/a69ebd3f-e1fc71.sh
clang++: note: diagnostic msg: 

********************
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ulimit -v 3145728; ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' clang++ -fsyntax-only -O1 -fno-strict-aliasing -ffp-contract=fast "$SCRIPT_DIR/test.cpp"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `8bb4c162` | Project seed |
| `b` | `d1733c98` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
