#include <typeinfo>
// RUN: %clang_cc1 -I%S %s -triple x86_64-apple-darwin10 -emit-llvm -fcxx-exceptions -fexceptions -o - | FileCheck %s


namespace Test1 {

// PR7400
struct __cxa_bad_typeid { virtual void f(); };

// CHECK: @_ZN5Test16int_tiE ={{.*}} constant ptr @_ZTIi, align 8
const std::type_info &int_ti = typeid(int);

// CHECK: @_ZN5Test14A_tiE ={{.*}} constant ptr @_ZTIN5Test11AE, align 8
const std::type_info &A_ti = typeid(const volatile __cxa_bad_typeid &);

volatile char c;

// CHECK: @_ZN5Test14c_tiE ={{.*}} constant ptr @_ZTIc, align 8
const std::type_info &c_ti = typeid(c);

extern const double &d;

// CHECK: @_ZN5Test14d_tiE ={{.*}} constant ptr @_ZTId, align 8
const std::type_info &d_ti = typeid(d);

extern __cxa_bad_typeid &a;

// CHECK: @_ZN5Test14a_tiE ={{.*}} global
const std::type_info &a_ti = typeid(a);

// CHECK: @_ZN5Test18A10_c_tiE ={{.*}} constant ptr @_ZTIA10_c, align 8
const std::type_info &A10_c_ti = typeid(char const[10]);

// CHECK-LABEL: define{{.*}} ptr @_ZN5Test11fEv
// CHECK-SAME:  personality ptr @__gxx_personality_v0
const char *f() {
  try {
    // CHECK: br i1
    // CHECK: invoke void @__cxa_bad_typeid() [[NR:#[0-9]+]]
    return typeid(*static_cast<__cxa_bad_typeid *>(0)).name();
  } catch (...) {
    // CHECK:      landingpad { ptr, i32 }
    // CHECK-NEXT:   catch ptr null
  }

  return 0;
}

}

// CHECK: attributes [[NR]] = { noreturn }

static long ffl_fusion = (long)(a);

// RUN: %clang_cc1 -std=c++11 -fno-rtti -emit-llvm %s -o - -triple=i386-pc-win32 | FileCheck %s

struct y {
  constexpr y(int x) : x(x) {}
  int y;
  virtual void f();
  int x;
};

y a(42);
// CHECK: @"?a@@3UA@@y" = dso_local global %struct.A { ptr @"??_7A@@6B@", i32 42 }, align 4

struct i1 {
  constexpr i1(int y) : y(y) {}
  virtual void ffl_fusion();
  int y;
};

struct invoke : y, i1 {
  constexpr invoke() : y(777), i1(13) {}
};

invoke c;
// CHECK: @"?c@@3UC@@y" = dso_local global { ptr, i32, ptr, i32 } { ptr @"??_7C@@6BA@@@", i32 777, ptr @"??_7C@@6BB@@@", i32 13 }
// RUN: %clang_cc1 -std=c++11 -fno-rtti -emit-llvm %s -o - -triple=i386-pc-win32 | FileCheck %s

struct A {
  constexpr A(int x) : x(x) {}
  virtual void f();
  int x;
}
;
A a(42);
// CHECK: @"?a@@3UA@@A" = dso_local global %struct.A { ptr @"??_7A@@6B@", i32 42 }, align 4

struct B {
  constexpr B(int y) : y(y) {}
  virtual void g();
  int y;
}
;
struct C : A, B {
  constexpr C() : A(777), B(13) {}

struct invoke : y, i1 {
  constexpr invoke() : y(777), i1(13) {}
};
}
;
C c;
// CHECK: @"?c@@3UC@@A" = dso_local global { ptr, i32, ptr, i32 } { ptr @"??_7C@@6BA@@@", i32 777, ptr @"??_7C@@6BB@@@", i32 13 }
