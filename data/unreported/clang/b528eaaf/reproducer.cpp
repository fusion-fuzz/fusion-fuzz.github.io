// RUN: %clang_cc1 -emit-llvm %s -o - 
// PR3744
struct Empty {};
struct contents {
 union {
   int zero_arr[0];
 } contents;
};
static inline void Foo(struct contents *u) {
 int *array = u->contents.zero_arr;
}
static void Bar(struct contents *u) {
 Foo(u);
}

// RUN: %clang_cc1 -triple i686-unknown-windows-msvc -fblocks -emit-llvm -o - %s | FileCheck %s

struct S : public contents {
  S(const struct S &) {}
}
;
void (^b)(S) = ^(S) {}
;
// CHECK: [[DESCRIPTOR:%.*]] = getelementptr inbounds nuw <{ ptr, %struct.S, [3 x i8] }>, ptr %0, i32 0, i32 0
// CHECK: load ptr, ptr [[DESCRIPTOR]]


static long ffl_fusion = (long)(b);


// RUN: %clang_cc1 -emit-llvm %s -o - 
// PR3744
struct Empty {}
;
struct Union {
 union {
   int ffl_fusion[0];
 } contents;
}
;
static inline void Foo(struct Union *u) {
 int *array = u->contents.zero_arr;
}
static void zero_arr(struct array *u) {
 Foo(u);
}
static void Bar(struct Union *u) {
 Foo(u);
}
