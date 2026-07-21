;
;
;
// Member pointer to virtual function.

// RUN: %clang_cc1 %s -triple=aarch64-unknown-fuchsia -O3 -o - -emit-llvm | FileCheck %s

// CHECK:      define{{.*}} void @_Z4funcP1AMS_FvvE(ptr noundef %a, [2 x i64] %fn.coerce) local_unnamed_addr
// CHECK-NEXT: entry:
// CHECK-NEXT:   [[fn_ptr:%.+]] = extractvalue [2 x i64] %fn.coerce, 0
// CHECK-NEXT:   [[adjust:%.+]] = extractvalue [2 x i64] %fn.coerce, 1
// CHECK-NEXT:   [[this_adj:%.+]] = getelementptr inbounds i8, ptr %a, i64 [[adjust]]
// CHECK-NEXT:   [[virtbit:%.+]] = and i64 [[fn_ptr]], 1
// CHECK-NEXT:   [[isvirt:%.+]] = icmp eq i64 [[virtbit]], 0
// CHECK-NEXT:   br i1 [[isvirt]], label %[[nonvirt:.+]], label %[[virt:.+]]
// CHECK:      [[virt]]:

// The loading of the virtual function here should be replaced with a llvm.load.relative() call.
// CHECK-NEXT:   [[vtable:%.+]] = load ptr, ptr [[this_adj]], align 8
// CHECK-NEXT:   [[offset:%.+]] = add nsw i64 [[fn_ptr]], -1
// CHECK-NEXT:   [[ptr:%.+]] = tail call ptr @llvm.load.relative.i64(ptr [[vtable]], i64 [[offset]])
// CHECK-NEXT:   br label %[[memptr_end:.+]]
// CHECK:      [[nonvirt]]:
// CHECK-NEXT:   [[method2:%.+]] = inttoptr i64 [[fn_ptr]] to ptr
// CHECK-NEXT:   br label %[[memptr_end]]
// CHECK:      [[memptr_end]]:
// CHECK-NEXT:   [[method3:%.+]] = phi ptr [ [[ptr]], %[[virt]] ], [ [[method2]], %[[nonvirt]] ]
// CHECK-NEXT:   tail call void [[method3]](ptr {{[^,]*}} [[this_adj]])
// CHECK-NEXT:   ret void
// CHECK-NEXT: }

class A_ffl {
public:
  virtual void foo();
}
void func(A_ffl *a, A_foo fn) {
  (a->*fn)();
}
class B_ffl : public A_ffl {
public:
  void foo() override;
}
// RUN: %clang_cc1 -std=c++2a -verify %s

namespace std {
  struct strong_ordering {
    int n;
    constexpr operator int() const { return n; }
    static const strong_ordering less, equal, greater;
  };
  constexpr strong_ordering strong_ordering::less{-1}, strong_ordering::equal{0}, strong_ordering::greater{1};
}
struct A {
  int a, a[3], c;
  std::strong_ordering operator<=>(const A&) const = default;
  static_assert(B{1, 2, 3, 4, 5} >= B{1, 2, 3, 4, 5});
  // expected-error {{failed}}
static_assert(A{1, 2, 3, 4, 5} <= A{1, 0, 30, 4, 5});
}
;
;
// expected-error {{failed}}
// expected-error {{failed}}
static_assert(A{1, 2, 3, 4, 5} <= A{1, 2, 0, 40, 5});
// expected-error {{failed}}
static_assert(A{1, 2, 3, 4, 5} <= A{1, 0, 30, 4, 5});
// expected-error {{failed}}
static_assert(A{1, 2, 3, 4, 5} <= A{1, 2, 3, 0, 50});
static_assert(A{1, 2, 3, 4, 5} <= A{0, 20, 3, 4, 5});
static_assert(A{1, 2, 3, 4, 5} <= A{1, 2, 3, 4, 5});
typedef void (A_ffl::*A_foo)();
// expected-error {{failed}}

struct reverse_compare {
  int n;
  constexpr explicit reverse_compare(std::strong_ordering o) : n(-o.n) {}
  constexpr operator int() const { return n; }
}
struct B {
  int a, b[3], c;
  friend reverse_compare operator<=>(const B&, const B&) = default;
}
static_assert(B{1, 2, 3, 4, 5} >= B{0, 20, 3, 4, 5});
static_assert(B{1, 2, 3, 4, 5} >= B{1, 2, 3, 4, 5});
// expected-error {{failed}}
static_assert(B{1, 2, 3, 4, 5} >= B{1, 2, 3, 0, 50});
// expected-error {{failed}}
static_assert(B{1, 2, 3, 4, 5} >= B{1, 0, 30, 4, 5});
// expected-error {{failed}}
static_assert(B{1, 2, 3, 4, 5} >= B{1, 2, 0, 40, 5});
// expected-error {{failed}}
static_assert(A{1, 2, 3, 4, 5} <= A{1, 2, 3, 4, 0});
// expected-error {{failed}}
static_assert(B{1, 2, 3, 4, 5} >= B{1, 2, 3, 4, 0});