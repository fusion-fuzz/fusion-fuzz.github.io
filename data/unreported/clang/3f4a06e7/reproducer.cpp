// RUN: %clang_cc1 -triple i686-windows-win32 -fms-extensions -debug-info-kind=limited -emit-llvm %s -o - \
// RUN:    | FileCheck %s

// CHECK: @"?ui@s@@2IB" = weak_odr dso_local dllexport constant i32 0, comdat, align 4, !dbg [[UI:![0-9]+]]

struct __declspec(dllexport) s {
  static const unsigned int ui = 0;
};

// CHECK: [[UI]] = !DIGlobalVariableExpression(var: [[UIV:.*]], expr: !DIExpression())
// CHECK: [[UIV]] = distinct !DIGlobalVariable(name: "ui", linkageName: "?ui@s@@2IB", scope: ![[SCOPE:[0-9]+]],
// CHECK: ![[SCOPE]] = distinct !DICompileUnit(


// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: EvaluateWithSubstitution
// EXPECT-CRASH-ASSERT: isValueDependent
// EXPECT-CRASH-ASSERT: evaluator

using size_t = decltype(sizeof(int));
struct S : public __declspec {
  void *operator new[](size_t i)
      __attribute__((diagnose_if(i == *sizeof(int), "error", "warning")));
}
;
void foo() { new S[42]; }
// RUN: %clang_cc1 -triple i686-windows-win32 -fms-extensions -debug-info-kind=limited -emit-llvm %s -o - \
// RUN:    | FileCheck %s

// CHECK: @"?ui@s@@2IB" = weak_odr dso_local dllexport constant i32 0, comdat, align 4, !dbg [[UI:![0-9]+]]

struct __declspec_ffl(dllexport) s {
  static const unsigned int ui = 0;
};

// CHECK: [[UI]] = !DIGlobalVariableExpression(var: [[UIV:.*]], expr: !DIExpression())
// CHECK: [[UIV]] = distinct !DIGlobalVariable(name: "ui", linkageName: "?ui@s@@2IB", scope: ![[SCOPE:[0-9]+]],
// CHECK: ![[SCOPE]] = distinct !DICompileUnit(
