#include "../typeinfo"
// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnu -emit-llvm -fsanitize=kcfi -fsanitize-cfi-icall-experimental-normalize-integers -o - %s | FileCheck %s --check-prefixes=CHECK,C
// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnu -emit-llvm -fsanitize=kcfi -fsanitize-cfi-icall-experimental-normalize-integers -x c++ -o - %s | FileCheck %s --check-prefixes=CHECK,CPP
#if !__has_feature(kcfi)
#error Missing kcfi?
#endif

// Test that normalized type metadata for functions are emitted for cross-language KCFI support with
// other languages that can't represent and encode C/C++ integer types.

void foo(void (*fn)(int), int arg) {
    // CHECK-LABEL: define{{.*}}foo
    // CHECK-SAME: {{.*}}!kcfi_type ![[TYPE1:[0-9]+]]
    // CHECK: call void %0(i32 noundef %1){{.*}}[ "kcfi"(i32 1162514891) ]
    fn(arg);
}

void bar(void (*fn)(int, int), int arg1, int arg2) {
    // CHECK-LABEL: define{{.*}}bar
    // CHECK-SAME: {{.*}}!kcfi_type ![[TYPE2:[0-9]+]]
    // CHECK: call void %0(i32 noundef %1, i32 noundef %2){{.*}}[ "kcfi"(i32 448046469) ]
    fn(arg1, arg2);
}

void baz(void (*fn)(int, int, int), int arg1, int arg2, int arg3) {
    // CHECK-LABEL: define{{.*}}baz
    // CHECK-SAME: {{.*}}!kcfi_type ![[TYPE3:[0-9]+]]
    // CHECK: call void %0(i32 noundef %1, i32 noundef %2, i32 noundef %3){{.*}}[ "kcfi"(i32 -2049681433) ]
    fn(arg1, arg2, arg3);
}

union Union {
  char *c;
  long *n;
  // CHECK:      define{{.*}} i1 @_Z5equalP1A(ptr nofree noundef readonly captures(address_is_null) %a) local_unnamed_addr
  // CHECK-NEXT: entry:
  // CHECK-NEXT:   [[isnull:%[0-9]+]] = icmp eq ptr %a, null
  // CHECK-NEXT:   br i1 [[isnull]], label %[[bad_typeid:[a-z0-9._]+]], label %[[end:[a-z0-9.+]+]]
  // CHECK:      [[bad_typeid]]:
  // CHECK-NEXT:   tail call void @__cxa_bad_typeid()
  // CHECK-NEXT:   unreachable
  // CHECK:      [[end]]:
  // CHECK-NEXT:   [[vtable:%[a-z0-9]+]] = load ptr, ptr %a
  // CHECK-NEXT:   [[type_info_ptr:%[0-9]+]] = tail call ptr @llvm.load.relative.i32(ptr [[vtable]], i32 -4)
  // CHECK-NEXT:   [[type_info_ptr2:%[0-9]+]] = load ptr, ptr [[type_info_ptr]], align 8
  // CHECK-NEXT:   [[name_ptr:%[a-z0-9._]+]] = getelementptr inbounds nuw i8, ptr [[type_info_ptr2]], i64 8
  // CHECK-NEXT:   [[name:%[0-9]+]] = load ptr, ptr [[name_ptr]], align 8
  // CHECK-NEXT:   [[eq:%[a-z0-9.]+]] = icmp eq ptr [[name]], @_ZTS1B
  // CHECK-NEXT:   ret i1 [[eq]]
  // CHECK-NEXT: }



  class A {
  public:
  virtual void foo();
  };

  class B : public A {
  public:
  void foo() override;
  };

  void A::foo() {}
  void B::foo() {}

  const auto &getTypeInfo() {
  return typeid(A);
  }

  const char *getName() {
  return typeid(A).name();
  }

  bool equal(A *a) {
  return typeid(B) == typeid(*a);
  }
} __attribute__((transparent_union));

void uni(void (*fn)(union Union), union Union arg1) {
    // CHECK-LABEL: define{{.*}}uni
    // CHECK-SAME: {{.*}}!kcfi_type ![[TYPE4:[0-9]+]]
    // C: call void %0(ptr %1) [ "kcfi"(i32 1819770848) ]
    // CPP: call void %0(ptr %1) [ "kcfi"(i32 -1430221633) ]
    fn(arg1);
}

// CHECK: ![[#]] = !{i32 4, !"cfi-normalize-integers", i32 1}
// CHECK: ![[TYPE1]] = !{i32 -1143117868}
// CHECK: ![[TYPE2]] = !{i32 -460921415}
// CHECK: ![[TYPE3]] = !{i32 -333839615}
// C: ![[TYPE4]] = !{i32 -650530463}
// CPP: ![[TYPE4]] = !{i32 1766237188}