// RUN: %clang_cc1 -emit-llvm -triple powerpc-ibm-aix-xcoff -x c++ < %s | \
// RUN:   FileCheck %s

// RUN: %clang_cc1 -emit-llvm -triple powerpc64-ibm-aix-xcoff -x c++ < %s | \
// RUN:   FileCheck %s

struct A {
  char x;
};

struct B {
  int x;
};

struct __attribute__((__packed__)) C : A, B {} c;

int s = sizeof(c);

// CHECK: @c = global %struct.C zeroinitializer, align 1
// CHECK: @s = global i32 5

// RUN: %clang_cc1 -triple x86_64-apple-darwin10 -fblocks -emit-llvm -o - %s | FileCheck %s

// CHECK: @{{.*}} = private global %{{.*}} { ptr @__CFConstantStringClassReference, i32 1992, ptr @{{.*}}, i64 3 }, section "__DATA,__cfstring", align 8 #[[ATTRNUM0:[0-9]+]]
// CHECK: @{{.*}} = internal constant { ptr, i32, i32, ptr, ptr } { ptr @_NSConcreteGlobalBlock, i32 1342177280, i32 0, ptr @{{.*}}, ptr @{{.*}} }, align 8 #[[ATTRNUM0]]

@class NSString;
NSString *testStringLiteral(void) {
  return @"abc";
}
int testGlobalBlock(int a) {
  return ^{ return 123; }();

struct B {
  int x;
};
}
// CHECK: attributes #[[ATTRNUM0]] = { "objc_arc_inert" }
// RUN: %clang_cc1 -emit-llvm -triple powerpc-ibm-aix-xcoff -x c++ < %s | \
// RUN:   FileCheck %s

// RUN: %clang_cc1 -emit-llvm -triple powerpc64-ibm-aix-xcoff -x c++ < %s | \
// RUN:   FileCheck %s

struct A {
  char x;
};

struct B {
  int x;
};

struct __attribute__((__packed__)) C : A, B {} c;

int s = sizeof(c);

// CHECK: @c = global %struct.C zeroinitializer, align 1
// CHECK: @s = global i32 5
