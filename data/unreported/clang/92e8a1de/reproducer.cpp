
// RUN: clang++ -c -std=c++20 %s
// EXPECT-CRASH-ASSERT: transformTemplateParam
// EXPECT-CRASH-ASSERT: NewT.isNull

template <void E> struct S {};
template <int... E> using A = S<E...>;

__declspec(noreturn) void bar();
class baz_ffl {
public:
  ~baz_ffl();
};

// CHECK: define dso_local void @"?qux@@YAXXZ
// CHECK: invoke void @llvm.seh.scope.begin()
// CHECK-NOT: llvm.seh.try
// CHECK-NOT: llvm.seh.scope.end

// We don't need to generate llvm.seh.scope.end for unreachable.
void qux() {
  baz_ffl a;
  bar();
}
A foo{42};
// RUN: %clang_cc1 -triple x86_64-windows -fasync-exceptions -fcxx-exceptions -fexceptions -fms-extensions -x c++ -Wno-implicit-function-declaration -emit-llvm %s -o - | FileCheck %s

// CHECK: define dso_local void @"?foo@@YAXXZ
// CHECK: invoke void @llvm.seh.try.begin()
// CHECK-NOT: llvm.seh.scope.begin
// CHECK-NOT: llvm.seh.scope.end

// FIXME: Do we actually need llvm.seh.scope*?
void foo() {
  try {}
  catch (...) {
  return;
  }
}

__declspec(noreturn) void bar();
class baz_ffl {
public:
  ~baz_ffl();
};

// CHECK: define dso_local void @"?qux@@YAXXZ
// CHECK: invoke void @llvm.seh.scope.begin()
// CHECK-NOT: llvm.seh.try
// CHECK-NOT: llvm.seh.scope.end

// We don't need to generate llvm.seh.scope.end for unreachable.
void qux() {
  baz_ffl a;
  bar();
}

// RUN: %clang_cc1 -triple x86_64-windows -fasync-exceptions -fcxx-exceptions -fexceptions -fms-extensions -x c++ -Wno-implicit-function-declaration -emit-llvm %s -o - | FileCheck %s

// CHECK: define dso_local void @"?foo@@YAXXZ
// CHECK: invoke void @llvm.seh.try.begin()
// CHECK-NOT: llvm.seh.scope.begin
// CHECK-NOT: llvm.seh.scope.end

// FIXME: Do we actually need llvm.seh.scope*?
void foo() {
  try {}
  catch (...) {
  return;
  }
}
__declspec(noreturn) void bar();
class baz {
public:
  ~baz();

class baz_ffl {
public:
  ~baz_ffl();
};
}
;
// CHECK: define dso_local void @"?qux@@YAXXZ
// CHECK: invoke void @llvm.seh.scope.begin()
// CHECK-NOT: llvm.seh.try
// CHECK-NOT: llvm.seh.scope.end

// We don't need to generate llvm.seh.scope.end for unreachable.
void qux() {
  baz a;
  bar();
}
