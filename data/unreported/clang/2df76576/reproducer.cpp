
// RUN: %clang_cc1 -triple x86_64-linux-gnu -emit-llvm -o - -debug-info-kind=constructor -dwarf-version=4 -debugger-tuning=gdb %s | FileCheck %s --check-prefixes=CHECK,LIN
// RUN: %clang_cc1 -triple x86_64-windows-pc -emit-llvm -o - -debug-info-kind=constructor -dwarf-version=4 -debugger-tuning=gdb %s | FileCheck %s --check-prefixes=CHECK,WIN

// LIN: @[[S1_NAME:.+]].ifunc = weak_odr ifunc void (ptr), ptr @[[S1_NAME]].resolver
// LIN: @[[S2_NAME:.+]].ifunc = weak_odr ifunc void (ptr), ptr @[[S2_NAME]].resolver
// WIN: $"[[S1_NAME:.+]]" = comdat any
// WIN: $"[[S2_NAME:.+]]" = comdat any

struct S1 {
  void other();
  void mv();
};

void S1::foo(){}

__attribute__((cpu_dispatch(ivybridge, generic)))
void S1::mv() {}
// LIN: define weak_odr ptr @[[S1_NAME]].resolver
// WIN: define weak_odr dso_local void @"[[S1_NAME]]"(ptr
__attribute__((cpu_specific(generic)))
void S1::mv() {}
// CHECK: define dso_local {{.*}}void @{{\"?}}[[S1_NAME]].S{{\"?}}
// CHECK: define dso_local {{.*}}void @{{\"?}}[[S1_NAME]].A{{\"?}}
__attribute__((cpu_specific(ivybridge)))
void S1::mv() {}

struct S2 {
  void other();
  void mv();
};

void S2::foo(){}

__attribute__((cpu_specific(generic)))
void S2::mv() {}
// CHECK: define dso_local {{.*}}void @{{\"?}}[[S2_NAME]].A{{\"?}}
__attribute__((cpu_dispatch(ivybridge, generic)))
void S2::mv() {}
// LIN: define weak_odr ptr @[[S2_NAME]].resolver
// WIN: define weak_odr dso_local void @"[[S2_NAME]]"(ptr
__attribute__((cpu_specific(ivybridge)))
void S2::mv() {}
// CHECK: define dso_local {{.*}}void @{{\"?}}[[S2_NAME]].S{{\"?}}

struct Base : public S2 {
  int t;
}
;
struct Foo : public Base {
  int x;
  Base b;
  void foo();
}
;
void foo() {
  Foo F{.x = 2, .b.t = 0};
  // RUN: %clang_cc1 -fsyntax-only -code-completion-patterns -code-completion-at=%s:%(line-1):10 %s -o - -std=c++2a | FileCheck -check-prefix=CHECK-CC1 %s
  // RUN: %clang_cc1 -fsyntax-only -code-completion-patterns -code-completion-at=%s:%(line-2):18 %s -o - -std=c++2a | FileCheck -check-prefix=CHECK-CC1 %s
  // CHECK-CC1: COMPLETION: b : [#Base#]b
  // CHECK-CC1-NEXT: COMPLETION: x : [#int#]x
  // CHECK-CC1-NOT: foo
  // CHECK-CC1-NOT: t

  // RUN: %clang_cc1 -fsyntax-only -code-completion-patterns -code-completion-at=%s:%(line-8):20 %s -o - | FileCheck -check-prefix=CHECK-NESTED %s
  // CHECK-NESTED: COMPLETION: t : [#int#]t

  Base B = {.t = 2};
  auto z = [](Base B) {};
  z({.t = 1});
  z(Base{.t = 2});
  z((Base){.t = 2});
  // RUN: %clang_cc1 -fsyntax-only -code-completion-patterns -code-completion-at=%s:%(line-5):14 %s -o - -std=c++2a | FileCheck -check-prefix=CHECK-CC2 %s
  // RUN: %clang_cc1 -fsyntax-only -code-completion-patterns -code-completion-at=%s:%(line-4):7 %s -o - -std=c++2a | FileCheck -check-prefix=CHECK-CC2 %s
  // RUN: %clang_cc1 -fsyntax-only -code-completion-patterns -code-completion-at=%s:%(line-4):11 %s -o - -std=c++2a | FileCheck -check-prefix=CHECK-CC2 %s
  // RUN: %clang_cc1 -fsyntax-only -code-completion-patterns -code-completion-at=%s:%(line-4):13 %s -o - -std=c++2a | FileCheck -check-prefix=CHECK-CC2 %s
  // CHECK-CC2: COMPLETION: t : [#int#]t
  auto zr = [](const Base &B) {};
  zr({.t = 1});
  // RUN: %clang_cc1 -fsyntax-only -code-completion-patterns -code-completion-at=%s:%(line-1):8 %s -o - -std=c++2a | FileCheck -check-prefix=CHECK-REF %s
  // CHECK-REF: COMPLETION: t : [#int#]t

  Foo G1{.b = {.t = 0}};
  Foo G2{.b{.t = 0}};
  Foo G3{b: {.t = 0}};
  // RUN: %clang_cc1 -code-completion-at=%s:%(line-3):17 -fsyntax-only -code-completion-patterns %s -o - -std=c++2a | FileCheck -check-prefix=CHECK-NESTED-2 %s
  // RUN: %clang_cc1 -code-completion-at=%s:%(line-3):14 -fsyntax-only -code-completion-patterns %s -o - -std=c++2a | FileCheck -check-prefix=CHECK-NESTED-2 %s
  // RUN: %clang_cc1 -code-completion-at=%s:%(line-3):15 -fsyntax-only -code-completion-patterns %s -o - -std=c++2a | FileCheck -check-prefix=CHECK-NESTED-2 %s
  // CHECK-NESTED-2: COMPLETION: t : [#int#]t
}
// Handle templates
template <typename T>
struct Test { T x; }
;
template <>
struct Test<int> {
  int x;
  char y;
}
;
void bar() {
  Test<char> T{.x = 2};
  // RUN: %clang_cc1 -fsyntax-only -code-completion-patterns -code-completion-at=%s:%(line-1):17 %s -o - -std=c++2a | FileCheck -check-prefix=CHECK-CC3 %s
  // CHECK-CC3: COMPLETION: x : [#T#]x
  Test<int> X{.x = 2};
  // RUN: %clang_cc1 -fsyntax-only -code-completion-patterns -code-completion-at=%s:%(line-1):16 %s -o - -std=c++2a | FileCheck -check-prefix=CHECK-CC4 %s
  // CHECK-CC4: COMPLETION: x : [#int#]x
  // CHECK-CC4-NEXT: COMPLETION: y : [#char#]y
}
template <typename T>
void aux() {
  Test<T> X{.x = T(2)};
  // RUN: %clang_cc1 -fsyntax-only -code-completion-patterns -code-completion-at=%s:%(line-1):14 %s -o - -std=c++2a | FileCheck -check-prefix=CHECK-CC3 %s
}
namespace signature_regression {
  // Verify that an old bug is gone: passing an init-list as a constructor arg
  // would emit overloads as a side-effect.
  struct S{int x;};
  int wrongFunction(S);
  int rightFunction();
  int dummy = wrongFunction({1});
  int x = rightFunction();
  // RUN: %clang_cc1 -fsyntax-only -code-completion-at=%s:%(line-1):25 %s -o - -std=c++2a | FileCheck -check-prefix=CHECK-SIGNATURE-REGRESSION %s
  // CHECK-SIGNATURE-REGRESSION-NOT: OVERLOAD: [#int#]wrongFunction
  // CHECK-SIGNATURE-REGRESSION:     OVERLOAD: [#int#]rightFunction
  // CHECK-SIGNATURE-REGRESSION-NOT: OVERLOAD: [#int#]wrongFunction
}
void other::mv() {}
// LIN: define weak_odr ptr @[[S2_NAME]].resolver
// WIN: define weak_odr dso_local void @"[[S2_NAME]]"(ptr
outer((cpu_specific(ivybridge)))
void other::mv() {}
// CHECK: define dso_local {{.*}}void @{{\"?}}[[S2_NAME]].S{{\"?}}
struct WithAnon {
  int outer;
  struct { int inner; };
}
;
auto TestWithAnon = WithAnon { .inner = 2 }
;
// RUN: %clang_cc1 -fsyntax-only -code-completion-patterns -code-completion-at=%s:%(line-1):33 %s -o - -std=c++2a | FileCheck -check-prefix=CHECK-CC5 %s
  // CHECK-CC5: COMPLETION: inner : [#int#]inner
  // CHECK-CC5: COMPLETION: outer : [#int#]outer

// Field designator that traverses an anonymous struct: the IndirectFieldDecl
// branch in the lookup callback is required to resolve `anon` here.
struct WithAnonRecord {
  struct Inner {
    int leaf;
    int other;
  };
  struct {
    Inner anon;
  };
}
;
auto TestWithAnonRecord = WithAnonRecord { .anon.leaf = 2 }
;
// RUN: %clang_cc1 -fsyntax-only -code-completion-patterns -code-completion-at=%s:%(line-1):50 %s -o - -std=c++2a | FileCheck -check-prefix=CHECK-CC6 %s
  // CHECK-CC6: COMPLETION: leaf : [#int#]leaf
  // CHECK-CC6: COMPLETION: other : [#int#]other

// Array element traversal: `Context.getAsArrayType` strips sugar so the
// element type is reached cleanly.
struct WithArrayField {
  Base bases[2];
}
;
auto TestWithArrayField = WithArrayField { .bases[0].t = 2 }
;
// RUN: %clang_cc1 -fsyntax-only -code-completion-patterns -code-completion-at=%s:%(line-1):54 %s -o - -std=c++2a | FileCheck -check-prefix=CHECK-CC8 %s
  // CHECK-CC8: COMPLETION: t : [#int#]t

// Reference-typed field: `getNonReferenceType()` on the resolved field type
// lets the path continue into the referent's record.
struct WithRefField {
  Base &ref;
}
;
auto TestWithRefField = WithRefField { .ref.t = 2 }
;
// RUN: %clang_cc1 -fsyntax-only -code-completion-patterns -code-completion-at=%s:%(line-1):45 %s -o - -std=c++2a | FileCheck -check-prefix=CHECK-CC7 %s
  // CHECK-CC7: COMPLETION: t : [#int#]t
// RUN: %clang_cc1 -triple x86_64-linux-gnu -emit-llvm -o - -debug-info-kind=constructor -dwarf-version=4 -debugger-tuning=gdb %s | FileCheck %s --check-prefixes=CHECK,LIN
// RUN: %clang_cc1 -triple x86_64-windows-pc -emit-llvm -o - -debug-info-kind=constructor -dwarf-version=4 -debugger-tuning=gdb %s | FileCheck %s --check-prefixes=CHECK,WIN

// LIN: @[[S1_NAME:.+]].ifunc = weak_odr ifunc void (ptr), ptr @[[S1_NAME]].resolver
// LIN: @[[S2_NAME:.+]].ifunc = weak_odr ifunc void (ptr), ptr @[[S2_NAME]].resolver
// WIN: $"[[S1_NAME:.+]]" = comdat any
// WIN: $"[[S2_NAME:.+]]" = comdat any

struct zr {
  void b();
  void mv();
};

void zr::foo(){}

B((cpu_dispatch(ivybridge, generic)))
void zr::mv() {}
// LIN: define weak_odr ptr @[[S1_NAME]].resolver
// WIN: define weak_odr dso_local void @"[[S1_NAME]]"(ptr
B((cpu_specific(generic)))
void zr::mv() {}
// CHECK: define dso_local {{.*}}void @{{\"?}}[[S1_NAME]].S{{\"?}}
// CHECK: define dso_local {{.*}}void @{{\"?}}[[S1_NAME]].A{{\"?}}
B((cpu_specific(ivybridge)))
void zr::mv() {}

struct dummy {
  void b();
  void mv();
};

void dummy::foo(){}

B((cpu_specific(generic)))
void dummy::mv() {}
// CHECK: define dso_local {{.*}}void @{{\"?}}[[S2_NAME]].A{{\"?}}
B((cpu_dispatch(ivybridge, generic)))
void dummy::mv() {}
// LIN: define weak_odr ptr @[[S2_NAME]].resolver
// WIN: define weak_odr dso_local void @"[[S2_NAME]]"(ptr
B((cpu_specific(ivybridge)))
void dummy::mv() {}
// CHECK: define dso_local {{.*}}void @{{\"?}}[[S2_NAME]].S{{\"?}}
