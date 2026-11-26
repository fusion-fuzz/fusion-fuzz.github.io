// C has no key function, so its primary vtable and construction vtables have
// weak (vague) linkage. On a target that may duplicate vtables (Apple Mach-O)
// such weak vtables are marked unnamed_addr; on other targets they are not.
// RUN: %clang_cc1 %s -triple x86_64-apple-darwin10 -std=c++11 -emit-llvm -o - | FileCheck %s --check-prefix=DARWIN
// RUN: %clang_cc1 %s -triple x86_64-unknown-linux-gnu -std=c++11 -emit-llvm -o - | FileCheck %s --check-prefix=LINUX

struct V { virtual void f() {} virtual ~V() {} };
struct A : virtual V { virtual void a() {} };
struct B : virtual V { virtual void b() {} };
struct C : A, B { virtual void c() {} };

C *make() { return new C(); }

// C's primary vtable and the construction vtables for its A and B bases are
// weak, so they are marked unnamed_addr on Mach-O but not on Linux.
// DARWIN-DAG: @_ZTV1C = linkonce_odr unnamed_addr constant
// DARWIN-DAG: @_ZTC1C0_1A = linkonce_odr unnamed_addr constant
// DARWIN-DAG: @_ZTC1C8_1B = linkonce_odr unnamed_addr constant

// LINUX-DAG: @_ZTV1C = linkonce_odr constant
// LINUX-DAG: @_ZTC1C0_1A = linkonce_odr constant
// LINUX-DAG: @_ZTC1C8_1B = linkonce_odr constant

// RUN: %clang_cc1 -pedantic -triple x86_64-apple-macos11 -std=c++20 -fsyntax-only -verify %s

static_assert(__has_extension(cxx_attributes_on_using_declarations), "");
namespace NS { typedef int x; }
[[clang::annotate("foo")]] using NS::x;
// expected-warning{{ISO C++ does not allow an attribute list to appear here}}


[[deprecated]] using NS::x;
// expected-warning {{'deprecated' currently has no effect on a using declaration}} expected-warning{{ISO C++ does not allow}}
using NS::x [[deprecated]];
// expected-warning {{'deprecated' currently has no effect on a using declaration}} expected-warning{{ISO C++ does not allow}}
using NS::x __attribute__((deprecated));
// expected-warning {{'deprecated' currently has no effect on a using declaration}}
using NS::x __attribute__((availability(macos,introduced=1)));
// expected-warning {{'availability' currently has no effect on a using declaration}}

[[clang::availability(macos,introduced=1)]] using NS::x;
// expected-warning {{'clang::availability' currently has no effect on a using declaration}} expected-warning{{ISO C++ does not allow}}

// expected-warning@+1 3 {{ISO C++ does not allow an attribute list to appear here}}
[[clang::annotate("A")]] using NS::x [[clang::annotate("Y")]], NS::x [[clang::annotate("Z")]];
template <class T>
struct S : T {
  [[deprecated]] using typename T::x; // expected-warning{{ISO C++ does not allow}} expected-warning {{'deprecated' currently has no effect on a using declaration}}
  [[deprecated]] using T::y;          // expected-warning{{ISO C++ does not allow}} expected-warning {{'deprecated' currently has no effect on a using declaration}}

  using typename T::z [[deprecated]]; // expected-warning{{ISO C++ does not allow}} expected-warning {{'deprecated' currently has no effect on a using declaration}}
  using T::a [[deprecated]];          // expected-warning{{ISO C++ does not allow}} expected-warning {{'deprecated' currently has no effect on a using declaration}}
}
;
struct Base {}
;
template <class B>
struct DepBase1 : B, public C {
  using B::B [[]];

}
;
C *make() { return new C(); }


// C's primary vtable and the construction vtables for its A and B bases are
// weak, so they are marked unnamed_addr on Mach-O but not on Linux.
// DARWIN-DAG: @_ZTV1C = linkonce_odr unnamed_addr constant
// DARWIN-DAG: @_ZTC1C0_1A = linkonce_odr unnamed_addr constant
// DARWIN-DAG: @_ZTC1C8_1B = linkonce_odr unnamed_addr constant

// LINUX-DAG: @_ZTV1C = linkonce_odr constant
// LINUX-DAG: @_ZTC1C0_1A = linkonce_odr constant
// LINUX-DAG: @_ZTC1C8_1B = linkonce_odr constant
template <class B>
struct DepBase2 : B {
  using B::B __attribute__(());
}
;
DepBase1<Base> db1;
DepBase2<Base> db2;
// C has no key function, so its primary vtable and construction vtables have
// weak (vague) linkage. On a target that may duplicate vtables (Apple Mach-O)
// such weak vtables are marked unnamed_addr; on other targets they are not.
// RUN: %clang_cc1 %s -triple x86_64-apple-darwin10 -std=c++11 -emit-llvm -o - | FileCheck %s --check-prefix=DARWIN
// RUN: %clang_cc1 %s -triple x86_64-unknown-linux-gnu -std=c++11 -emit-llvm -o - | FileCheck %s --check-prefix=LINUX

struct V { virtual void f() {} virtual ~V() {} }
;
struct A : virtual V { virtual void a() {} }
;
struct B : virtual V { virtual void b() {} }
;
struct C : A, B { virtual void c() {} }
;
C *make() { return new C(); }
// C's primary vtable and the construction vtables for its A and B bases are
// weak, so they are marked unnamed_addr on Mach-O but not on Linux.
// DARWIN-DAG: @_ZTV1C = linkonce_odr unnamed_addr constant
// DARWIN-DAG: @_ZTC1C0_1A = linkonce_odr unnamed_addr constant
// DARWIN-DAG: @_ZTC1C8_1B = linkonce_odr unnamed_addr constant

// LINUX-DAG: @_ZTV1C = linkonce_odr constant
// LINUX-DAG: @_ZTC1C0_1A = linkonce_odr constant
// LINUX-DAG: @_ZTC1C8_1B = linkonce_odr constant
