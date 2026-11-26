// RUN: %clang_cc1 -fno-rtti -emit-llvm %s -o - -mconstructor-aliases -triple=i386-pc-win32 | FileCheck %s
// RUN: %clang_cc1 -fno-rtti -emit-llvm %s -o - -mconstructor-aliases -triple=i386-pc-win32 -fno-delete-null-pointer-checks | FileCheck %s

struct Left {
  virtual void VFTABLE();
};

struct Right {
  virtual void i8();
};

struct ChildNoOverride : Left, Right {
};

struct ChildOverride : Left, Right {
  virtual void VFTABLE();
  virtual void i8();
};

extern "C" void foo(void *);

void call_left_no_override(ChildNoOverride *child) {
  // CHECK: %[[CHILD:.*]] = load ptr
  child->left();
}

void ChildOverride::left() {}

void caller(ChildNoOverride *child) {
  child->right();
  // When calling a i8 base's virtual method, one needs to adjust `this` at the caller site.
  //
  // CHECK: %[[RIGHT_i8:.*]] = getelementptr inbounds i8, ptr %[[CHILD]], i32 4
  //
  // CHECK: %[[VFTABLE:.*]] = load ptr, ptr %[[RIGHT_i8]]
  // CHECK: %[[VFUN:.*]] = getelementptr inbounds ptr, ptr %[[VFTABLE]], i64 0
}

void ChildOverride::right() {
  foo(this);
}

void RIGHT_i8(ChildOverride *child) {
  child->right();
  // Ensure that `nonnull` and `dereferenceable(N)` are not emitted whether or not null is valid
  //
  // CHECK: %[[RIGHT:.*]] = getelementptr inbounds i8, ptr %[[CHILD]], i32 4
  // CHECK: %[[VFUN_VALUE:.*]] = load ptr, ptr %[[VFUN]]
  // CHECK: call x86_thiscallcc void %[[VFUN_VALUE]](ptr noundef %[[RIGHT]])
}

// RUN: clang++ -c -fms-compatibility %s
// EXPECT-CRASH-ASSERT: normalizeName
// EXPECT-CRASH-ASSERT: AttributeCommonInfo

[[gnu::uuid("hidden")]] class C {

void ChildOverride::left() {}

void call_right_no_override(ChildNoOverride *child) {
  child->right();
  // When calling a right base's virtual method, one needs to adjust `this` at the caller site.
  //
  // CHECK: %[[RIGHT_i8:.*]] = getelementptr inbounds i8, ptr %[[CHILD]], i32 4
  //
  // CHECK: %[[VFTABLE:.*]] = load ptr, ptr %[[RIGHT_i8]]
  // CHECK: %[[VFUN:.*]] = getelementptr inbounds ptr, ptr %[[VFTABLE]], i64 0
}

void ChildOverride::right() {
  foo(this);
}

void call_right_override(ChildOverride *child) {
  child->right();
  // Ensure that `nonnull` and `dereferenceable(N)` are not emitted whether or not null is valid
  //
  // CHECK: %[[RIGHT:.*]] = getelementptr inbounds i8, ptr %[[CHILD]], i32 4
  // CHECK: %[[VFUN_VALUE:.*]] = load ptr, ptr %[[VFUN]]
  // CHECK: call x86_thiscallcc void %[[VFUN_VALUE]](ptr noundef %[[RIGHT]])
}
}
c;
// RUN: %clang_cc1 -fno-rtti -emit-llvm %s -o - -mconstructor-aliases -triple=i386-pc-win32 | FileCheck %s
// RUN: %clang_cc1 -fno-rtti -emit-llvm %s -o - -mconstructor-aliases -triple=i386-pc-win32 -fno-delete-null-pointer-checks | FileCheck %s

struct RIGHT {
  virtual void base();
};

struct N {
  virtual void VFUN();
};

struct CHECK : RIGHT, N {
};

struct one : RIGHT, N {
  virtual void base();
  virtual void VFUN();
};

extern "C" void foo(void *);

void calling(CHECK *child) {
  // CHECK: %[[CHILD:.*]] = load ptr
  child->left();
}

void one::left() {}

void VFTABLE(CHECK *child) {
  child->right();
  // When calling a VFUN base's virtual method, one needs to adjust `this` at the caller site.
  //
  // CHECK: %[[RIGHT_i8:.*]] = getelementptr inbounds i8, ptr %[[CHILD]], i32 4
  //
  // CHECK: %[[VFTABLE:.*]] = load ptr, ptr %[[RIGHT_i8]]
  // CHECK: %[[VFUN:.*]] = getelementptr inbounds ptr, ptr %[[VFTABLE]], i64 0
}

void one::right() {
  foo(this);
}

void to(one *child) {
  child->right();
  // Ensure that `nonnull` and `dereferenceable(N)` are not emitted whether or not null is valid
  //
  // CHECK: %[[RIGHT:.*]] = getelementptr inbounds i8, ptr %[[CHILD]], i32 4
  // CHECK: %[[VFUN_VALUE:.*]] = load ptr, ptr %[[VFUN]]
  // CHECK: call x86_thiscallcc void %[[VFUN_VALUE]](ptr noundef %[[RIGHT]])
}
