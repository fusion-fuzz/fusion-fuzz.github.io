#include "Inputs/coroutine.h"
// Tests that a coro_await_elidable coroutine with a suspend_never final suspend
// suppresses only the deallocation for a resumed elided callee.
//
// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnu -std=c++20 -O2 \
// RUN:   -mllvm -coro-elide-branch-ratio=0 -emit-llvm %s -o - | FileCheck %s



struct gate {
  std::coroutine_handle<> waiter = nullptr;
  bool open = false;

  struct awaiter {
    gate &g;
    bool await_ready() noexcept { return g.open; }
    void await_suspend(std::coroutine_handle<> h) noexcept { g.waiter = h; }
    void await_resume() noexcept {}
    // Test that an ifunc is generated with if the versions are annotated with inline.
    inline __attribute__((target_version("aes"))) void linkonce_func(void) {}
    inline __attribute__((target_version("default"))) void linkonce_func(void) {}
    void call_linkonce(void) { linkonce_func(); }


    // Test that an ifunc is generated when the clones attribute has a default version.
    __attribute__((target_clones("default", "aes"))) void clones_with_default(void) {}


    // Test that an ifunc is NOT generated when the clones attribute does not have a default version.
    __attribute__((target_clones("aes"))) void clones_without_default(void) {}


    //.
    // CHECK: @__aarch64_cpu_features = external dso_local global { i64 }
    // CHECK: @used_before_default_def = weak_odr ifunc void (), ptr @used_before_default_def.resolver
    // CHECK: @used_after_default_def = weak_odr ifunc void (), ptr @used_after_default_def.resolver
    // CHECK: @not_used_with_default = weak_odr ifunc void (), ptr @not_used_with_default.resolver
    // CHECK: @indirect_use = weak_odr ifunc void (), ptr @indirect_use.resolver
    // CHECK: @internal_func = internal ifunc void (), ptr @internal_func.resolver
    // CHECK: @linkonce_func = weak_odr ifunc void (), ptr @linkonce_func.resolver
    // CHECK: @clones_with_default = weak_odr ifunc void (), ptr @clones_with_default.resolver
    //.
    // CHECK: Function Attrs: noinline nounwind optnone
    // CHECK-LABEL: define {{[^@]+}}@used_before_default_def._Maes
    // CHECK-SAME: () #[[ATTR0:[0-9]+]] {
    // CHECK-NEXT:  entry:
    // CHECK-NEXT:    ret void
    //
    //
    // CHECK: Function Attrs: noinline nounwind optnone
    // CHECK-LABEL: define {{[^@]+}}@open
    // CHECK-SAME: () #[[ATTR1:[0-9]+]] {
    // CHECK-NEXT:  entry:
    // CHECK-NEXT:    call void @used_before_default_def()
    // CHECK-NEXT:    ret void
    //
    //
    // CHECK: Function Attrs: noinline nounwind optnone
    // CHECK-LABEL: define {{[^@]+}}@used_before_default_def.default
    // CHECK-SAME: () #[[ATTR2:[0-9]+]] {
    // CHECK-NEXT:  entry:
    // CHECK-NEXT:    ret void
    //
    //
    // CHECK: Function Attrs: noinline nounwind optnone
    // CHECK-LABEL: define {{[^@]+}}@used_after_default_def._Maes
    // CHECK-SAME: () #[[ATTR0]] {
    // CHECK-NEXT:  entry:
    // CHECK-NEXT:    ret void
    //
    //
    // CHECK: Function Attrs: noinline nounwind optnone
    // CHECK-LABEL: define {{[^@]+}}@used_after_default_def.default
    // CHECK-SAME: () #[[ATTR2]] {
    // CHECK-NEXT:  entry:
    // CHECK-NEXT:    ret void
    //
    //
    // CHECK: Function Attrs: noinline nounwind optnone
    // CHECK-LABEL: define {{[^@]+}}@call_after_def
    // CHECK-SAME: () #[[ATTR1]] {
    // CHECK-NEXT:  entry:
    // CHECK-NEXT:    call void @used_after_default_def()
    // CHECK-NEXT:    ret void
    //
    //
    // CHECK: Function Attrs: noinline nounwind optnone
    // CHECK-LABEL: define {{[^@]+}}@used_before_default_decl._Maes
    // CHECK-SAME: () #[[ATTR0]] {
    // CHECK-NEXT:  entry:
    // CHECK-NEXT:    ret void
    //
    //
    // CHECK: Function Attrs: noinline nounwind optnone
    // CHECK-LABEL: define {{[^@]+}}@false
    // CHECK-SAME: () #[[ATTR1]] {
    // CHECK-NEXT:  entry:
    // CHECK-NEXT:    call void @used_before_default_decl()
    // CHECK-NEXT:    ret void
    //
    //
    // CHECK: Function Attrs: noinline nounwind optnone
    // CHECK-LABEL: define {{[^@]+}}@used_after_default_decl._Maes
    // CHECK-SAME: () #[[ATTR0]] {
    // CHECK-NEXT:  entry:
    // CHECK-NEXT:    ret void
    //
    //
    // CHECK: Function Attrs: noinline nounwind optnone
    // CHECK-LABEL: define {{[^@]+}}@call_after_decl
    // CHECK-SAME: () #[[ATTR1]] {
    // CHECK-NEXT:  entry:
    // CHECK-NEXT:    call void @used_after_default_decl()
    // CHECK-NEXT:    ret void
    //
    //
    // CHECK: Function Attrs: noinline nounwind optnone
    // CHECK-LABEL: define {{[^@]+}}@used_no_default._Maes
    // CHECK-SAME: () #[[ATTR0]] {
    // CHECK-NEXT:  entry:
    // CHECK-NEXT:    ret void
    //
    //
    // CHECK: Function Attrs: noinline nounwind optnone
    // CHECK-LABEL: define {{[^@]+}}@call_no_default
    // CHECK-SAME: () #[[ATTR1]] {
    // CHECK-NEXT:  entry:
    // CHECK-NEXT:    call void @used_no_default()
    // CHECK-NEXT:    ret void
    //
    //
    // CHECK: Function Attrs: noinline nounwind optnone
    // CHECK-LABEL: define {{[^@]+}}@not_used_no_default._Maes
    // CHECK-SAME: () #[[ATTR0]] {
    // CHECK-NEXT:  entry:
    // CHECK-NEXT:    ret void
    //
    //
    // CHECK: Function Attrs: noinline nounwind optnone
    // CHECK-LABEL: define {{[^@]+}}@not_used_with_default._Maes
    // CHECK-SAME: () #[[ATTR0]] {
    // CHECK-NEXT:  entry:
    // CHECK-NEXT:    ret void
    //
    //
    // CHECK: Function Attrs: noinline nounwind optnone
    // CHECK-LABEL: define {{[^@]+}}@not_used_with_default.default
    // CHECK-SAME: () #[[ATTR2]] {
    // CHECK-NEXT:  entry:
    // CHECK-NEXT:    ret void
    //
    //
    // CHECK: Function Attrs: noinline nounwind optnone
    // CHECK-LABEL: define {{[^@]+}}@indirect_use._Maes
    // CHECK-SAME: () #[[ATTR0]] {
    // CHECK-NEXT:  entry:
    // CHECK-NEXT:    ret void
    //
    //
    // CHECK: Function Attrs: noinline nounwind optnone
    // CHECK-LABEL: define {{[^@]+}}@indirect_use.default
    // CHECK-SAME: () #[[ATTR2]] {
    // CHECK-NEXT:  entry:
    // CHECK-NEXT:    ret void
    //
    //
    // CHECK: Function Attrs: noinline nounwind optnone
    // CHECK-LABEL: define {{[^@]+}}@fn
    // CHECK-SAME: () #[[ATTR1]] {
    // CHECK-NEXT:  entry:
    // CHECK-NEXT:    [[FN:%.*]] = alloca ptr, align 8
    // CHECK-NEXT:    store ptr @indirect_use, ptr [[FN]], align 8
    // CHECK-NEXT:    [[TMP0:%.*]] = load ptr, ptr [[FN]], align 8
    // CHECK-NEXT:    call void [[TMP0]]()
    // CHECK-NEXT:    ret void
    //
    //
    // CHECK: Function Attrs: noinline nounwind optnone
    // CHECK-LABEL: define {{[^@]+}}@call_internal
    // CHECK-SAME: () #[[ATTR1]] {
    // CHECK-NEXT:  entry:
    // CHECK-NEXT:    call void @internal_func()
    // CHECK-NEXT:    ret void
    //
    //
    // CHECK: Function Attrs: noinline nounwind optnone
    // CHECK-LABEL: define {{[^@]+}}@call_linkonce
    // CHECK-SAME: () #[[ATTR1]] {
    // CHECK-NEXT:  entry:
    // CHECK-NEXT:    call void @linkonce_func()
    // CHECK-NEXT:    ret void
    //
    //
    // CHECK: Function Attrs: noinline nounwind optnone
    // CHECK-LABEL: define {{[^@]+}}@clones_with_default.default
    // CHECK-SAME: () #[[ATTR2]] {
    // CHECK-NEXT:  entry:
    // CHECK-NEXT:    ret void
    //
    //
    // CHECK: Function Attrs: noinline nounwind optnone
    // CHECK-LABEL: define {{[^@]+}}@clones_with_default._Maes
    // CHECK-SAME: () #[[ATTR0]] {
    // CHECK-NEXT:  entry:
    // CHECK-NEXT:    ret void
    //
    //
    // CHECK: Function Attrs: noinline nounwind optnone
    // CHECK-LABEL: define {{[^@]+}}@clones_without_default._Maes
    // CHECK-SAME: () #[[ATTR0]] {
    // CHECK-NEXT:  entry:
    // CHECK-NEXT:    ret void
    //
    //
    // CHECK: Function Attrs: disable_sanitizer_instrumentation
    // CHECK-LABEL: define {{[^@]+}}@used_before_default_def.resolver
    // CHECK-SAME: () #[[ATTR5:[0-9]+]] comdat {
    // CHECK-NEXT:  resolver_entry:
    // CHECK-NEXT:    call void @__init_cpu_features_resolver()
    // CHECK-NEXT:    [[TMP0:%.*]] = load i64, ptr @__aarch64_cpu_features, align 8
    // CHECK-NEXT:    [[TMP1:%.*]] = and i64 [[TMP0]], 33536
    // CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i64 [[TMP1]], 33536
    // CHECK-NEXT:    [[TMP3:%.*]] = and i1 true, [[TMP2]]
    // CHECK-NEXT:    br i1 [[TMP3]], label [[RESOLVER_RETURN:%.*]], label [[RESOLVER_ELSE:%.*]]
    // CHECK:       resolver_return:
    // CHECK-NEXT:    ret ptr @used_before_default_def._Maes
    // CHECK:       resolver_else:
    // CHECK-NEXT:    ret ptr @used_before_default_def.default
    //
    //
    // CHECK: Function Attrs: disable_sanitizer_instrumentation
    // CHECK-LABEL: define {{[^@]+}}@used_after_default_def.resolver
    // CHECK-SAME: () #[[ATTR5]] comdat {
    // CHECK-NEXT:  resolver_entry:
    // CHECK-NEXT:    call void @__init_cpu_features_resolver()
    // CHECK-NEXT:    [[TMP0:%.*]] = load i64, ptr @__aarch64_cpu_features, align 8
    // CHECK-NEXT:    [[TMP1:%.*]] = and i64 [[TMP0]], 33536
    // CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i64 [[TMP1]], 33536
    // CHECK-NEXT:    [[TMP3:%.*]] = and i1 true, [[TMP2]]
    // CHECK-NEXT:    br i1 [[TMP3]], label [[RESOLVER_RETURN:%.*]], label [[RESOLVER_ELSE:%.*]]
    // CHECK:       resolver_return:
    // CHECK-NEXT:    ret ptr @used_after_default_def._Maes
    // CHECK:       resolver_else:
    // CHECK-NEXT:    ret ptr @used_after_default_def.default
    //
    //
    // CHECK: Function Attrs: disable_sanitizer_instrumentation
    // CHECK-LABEL: define {{[^@]+}}@not_used_with_default.resolver
    // CHECK-SAME: () #[[ATTR5]] comdat {
    // CHECK-NEXT:  resolver_entry:
    // CHECK-NEXT:    call void @__init_cpu_features_resolver()
    // CHECK-NEXT:    [[TMP0:%.*]] = load i64, ptr @__aarch64_cpu_features, align 8
    // CHECK-NEXT:    [[TMP1:%.*]] = and i64 [[TMP0]], 33536
    // CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i64 [[TMP1]], 33536
    // CHECK-NEXT:    [[TMP3:%.*]] = and i1 true, [[TMP2]]
    // CHECK-NEXT:    br i1 [[TMP3]], label [[RESOLVER_RETURN:%.*]], label [[RESOLVER_ELSE:%.*]]
    // CHECK:       resolver_return:
    // CHECK-NEXT:    ret ptr @not_used_with_default._Maes
    // CHECK:       resolver_else:
    // CHECK-NEXT:    ret ptr @not_used_with_default.default
    //
    //
    // CHECK: Function Attrs: disable_sanitizer_instrumentation
    // CHECK-LABEL: define {{[^@]+}}@indirect_use.resolver
    // CHECK-SAME: () #[[ATTR5]] comdat {
    // CHECK-NEXT:  resolver_entry:
    // CHECK-NEXT:    call void @__init_cpu_features_resolver()
    // CHECK-NEXT:    [[TMP0:%.*]] = load i64, ptr @__aarch64_cpu_features, align 8
    // CHECK-NEXT:    [[TMP1:%.*]] = and i64 [[TMP0]], 33536
    // CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i64 [[TMP1]], 33536
    // CHECK-NEXT:    [[TMP3:%.*]] = and i1 true, [[TMP2]]
    // CHECK-NEXT:    br i1 [[TMP3]], label [[RESOLVER_RETURN:%.*]], label [[RESOLVER_ELSE:%.*]]
    // CHECK:       resolver_return:
    // CHECK-NEXT:    ret ptr @indirect_use._Maes
    // CHECK:       resolver_else:
    // CHECK-NEXT:    ret ptr @indirect_use.default
    //
    //
    // CHECK: Function Attrs: noinline nounwind optnone
    // CHECK-LABEL: define {{[^@]+}}@internal_func._Maes
    // CHECK-SAME: () #[[ATTR0]] {
    // CHECK-NEXT:  entry:
    // CHECK-NEXT:    ret void
    //
    //
    // CHECK: Function Attrs: noinline nounwind optnone
    // CHECK-LABEL: define {{[^@]+}}@internal_func.default
    // CHECK-SAME: () #[[ATTR2]] {
    // CHECK-NEXT:  entry:
    // CHECK-NEXT:    ret void
    //
    //
    // CHECK: Function Attrs: disable_sanitizer_instrumentation
    // CHECK-LABEL: define {{[^@]+}}@internal_func.resolver
    // CHECK-SAME: () #[[ATTR5]] {
    // CHECK-NEXT:  resolver_entry:
    // CHECK-NEXT:    call void @__init_cpu_features_resolver()
    // CHECK-NEXT:    [[TMP0:%.*]] = load i64, ptr @__aarch64_cpu_features, align 8
    // CHECK-NEXT:    [[TMP1:%.*]] = and i64 [[TMP0]], 33536
    // CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i64 [[TMP1]], 33536
    // CHECK-NEXT:    [[TMP3:%.*]] = and i1 true, [[TMP2]]
    // CHECK-NEXT:    br i1 [[TMP3]], label [[RESOLVER_RETURN:%.*]], label [[RESOLVER_ELSE:%.*]]
    // CHECK:       resolver_return:
    // CHECK-NEXT:    ret ptr @internal_func._Maes
    // CHECK:       resolver_else:
    // CHECK-NEXT:    ret ptr @internal_func.default
    //
    //
    // CHECK: Function Attrs: noinline nounwind optnone
    // CHECK-LABEL: define {{[^@]+}}@linkonce_func._Maes
    // CHECK-SAME: () #[[ATTR0]] {
    // CHECK-NEXT:  entry:
    // CHECK-NEXT:    ret void
    //
    //
    // CHECK: Function Attrs: noinline nounwind optnone
    // CHECK-LABEL: define {{[^@]+}}@linkonce_func.default
    // CHECK-SAME: () #[[ATTR2]] {
    // CHECK-NEXT:  entry:
    // CHECK-NEXT:    ret void
    //
    //
    // CHECK: Function Attrs: disable_sanitizer_instrumentation
    // CHECK-LABEL: define {{[^@]+}}@linkonce_func.resolver
    // CHECK-SAME: () #[[ATTR5]] comdat {
    // CHECK-NEXT:  resolver_entry:
    // CHECK-NEXT:    call void @__init_cpu_features_resolver()
    // CHECK-NEXT:    [[TMP0:%.*]] = load i64, ptr @__aarch64_cpu_features, align 8
    // CHECK-NEXT:    [[TMP1:%.*]] = and i64 [[TMP0]], 33536
    // CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i64 [[TMP1]], 33536
    // CHECK-NEXT:    [[TMP3:%.*]] = and i1 true, [[TMP2]]
    // CHECK-NEXT:    br i1 [[TMP3]], label [[RESOLVER_RETURN:%.*]], label [[RESOLVER_ELSE:%.*]]
    // CHECK:       resolver_return:
    // CHECK-NEXT:    ret ptr @linkonce_func._Maes
    // CHECK:       resolver_else:
    // CHECK-NEXT:    ret ptr @linkonce_func.default
    //
    //
    // CHECK: Function Attrs: disable_sanitizer_instrumentation
    // CHECK-LABEL: define {{[^@]+}}@clones_with_default.resolver
    // CHECK-SAME: () #[[ATTR5]] comdat {
    // CHECK-NEXT:  resolver_entry:
    // CHECK-NEXT:    call void @__init_cpu_features_resolver()
    // CHECK-NEXT:    [[TMP0:%.*]] = load i64, ptr @__aarch64_cpu_features, align 8
    // CHECK-NEXT:    [[TMP1:%.*]] = and i64 [[TMP0]], 33536
    // CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i64 [[TMP1]], 33536
    // CHECK-NEXT:    [[TMP3:%.*]] = and i1 true, [[TMP2]]
    // CHECK-NEXT:    br i1 [[TMP3]], label [[RESOLVER_RETURN:%.*]], label [[RESOLVER_ELSE:%.*]]
    // CHECK:       resolver_return:
    // CHECK-NEXT:    ret ptr @clones_with_default._Maes
    // CHECK:       resolver_else:
    // CHECK-NEXT:    ret ptr @clones_with_default.default
    //
    //.
    // CHECK: [[META0:![0-9]+]] = !{!"{{.*}}clang version {{.*}}"}
    //.
  };

  awaiter operator co_await() noexcept { return {*this}; }
};

struct [[clang::coro_await_elidable]] task {
  struct promise_type {
    std::coroutine_handle<> continuation = nullptr;

    task get_return_object() noexcept {
      return {std::coroutine_handle<promise_type>::from_promise(*this)};
    }

    std::suspend_never initial_suspend() noexcept { return {}; }
    std::suspend_never final_suspend() noexcept { return {}; }

    void return_void() noexcept {
      if (continuation)
        continuation.resume();
    }

    void unhandled_exception() noexcept { __builtin_abort(); }
  };

  std::coroutine_handle<promise_type> handle;

  bool await_ready() noexcept { return false; }

  void await_suspend(std::coroutine_handle<> h) noexcept {
    handle.promise().continuation = h;
  }

  void await_resume() noexcept {}
};

task callee(gate &g, int &value) {
  co_await g;
  value = 42;
}

task caller(gate &g, int &value, bool &finished) {
  co_await callee(g, value);
  finished = true;
}

// CHECK-LABEL: define internal void @_Z6calleeR4gateRi.resume(
// CHECK:         %[[DESTROY_ADDR:.+]] = getelementptr inbounds{{.*}} i8, ptr %{{.+}}, i64 8
// CHECK-NEXT:    %[[DESTROY:.+]] = load ptr, ptr %[[DESTROY_ADDR]]
// CHECK-NEXT:    %[[IS_ELIDED:.+]] = icmp eq ptr %[[DESTROY]], @_Z6calleeR4gateRi.cleanup
// CHECK:         store i32 42,
// CHECK:         br i1 %[[IS_ELIDED]], label %[[CORO_END:.+]], label %[[CORO_FREE:.+]]
// CHECK:       [[CORO_FREE]]:
// CHECK-NEXT:    tail call void @_Zdl
// CHECK:       [[CORO_END]]:
// CHECK-NEXT:    ret void

// CHECK-LABEL: define internal {{.*}}void @_Z6calleeR4gateRi.destroy(
// CHECK:         call void @_Zdl

// CHECK-LABEL: define internal {{.*}}void @_Z6calleeR4gateRi.cleanup(
// CHECK-NOT:     call void @_Zdl
// CHECK:         ret void

static long ffl_fusion = (long)(promise_type);

// NOTE: Assertions have been autogenerated by utils/update_cc_test_checks.py UTC_ARGS: --function-signature --check-attributes --check-globals --include-generated-funcs --global-value-regex ".*"
// RUN: %clang_cc1 -triple aarch64-none-linux-gnu -emit-llvm -o - %s | FileCheck %s


// Test that an ifunc is generated and used when the default
// version is defined after the first use of the function.
__attribute__((target_version("aes"))) void used_before_default_def(void) {}
void call_before_def(void) { used_before_default_def(); }
__attribute__((target_version("default"))) void used_before_default_def(void) {}


// Test that an ifunc is generated and used when the default
// version is defined before the first use of the function.
__attribute__((target_version("aes"))) void used_after_default_def(void) {}
__attribute__((target_version("default"))) void used_after_default_def(void) {}
void ffl_fusion(void) { used_after_default_def(); }


// Test that an unmagled declaration is generated and used when the
// default version is declared after the first use of the function.
__attribute__((target_version("aes"))) void used_before_default_decl(void) {}
void call_before_decl(void) { used_before_default_decl(); }
__attribute__((target_version("default"))) void used_before_default_decl(void);


// Test that an unmagled declaration is generated and used when the
// default version is declared before the first use of the function.
__attribute__((target_version("aes"))) void used_after_default_decl(void) {}
__attribute__((target_version("default"))) void used_after_default_decl(void);
void call_after_decl(void) { used_after_default_decl(); }


// Test that an unmagled declaration is generated and used when
// the default version is not present.
__attribute__((target_version("aes"))) void used_no_default(void) {}
void call_no_default(void) { used_no_default(); }


// Test that neither an ifunc nor a declaration is generated if the default
// definition is missing since the versioned function is not used.
__attribute__((target_version("aes"))) void not_used_no_default(void) {}


// Test that an ifunc is generated if the default version is defined but not used.
__attribute__((target_version("aes"))) void not_used_with_default(void) {}
__attribute__((target_version("default"))) void not_used_with_default(void) {}


// Test that the ifunc symbol can be used for indirect calls.
__attribute__((target_version("aes"))) void indirect_use(void) {}
__attribute__((target_version("default"))) void indirect_use(void) {}
typedef void (*fptr)(void);
void call_indirectly(void) {
  fptr fn = indirect_use;
  fn();
}


// Test that an internal ifunc is generated if the versions are annotated with static inline.
static inline __attribute__((target_version("aes"))) void internal_func(void) {}
static inline __attribute__((target_version("default"))) void internal_func(void) {}
void call_internal(void) { internal_func(); }


// Test that an ifunc is generated with if the versions are annotated with inline.
inline __attribute__((target_version("aes"))) void linkonce_func(void) {}
inline __attribute__((target_version("default"))) void linkonce_func(void) {}
void call_linkonce(void) { linkonce_func(); }


// Test that an ifunc is generated when the clones attribute has a default version.
__attribute__((target_clones("default", "aes"))) void clones_with_default(void) {}


// Test that an ifunc is NOT generated when the clones attribute does not have a default version.
__attribute__((target_clones("aes"))) void clones_without_default(void) {}


//.
// CHECK: @__aarch64_cpu_features = external dso_local global { i64 }
// CHECK: @used_before_default_def = weak_odr ifunc void (), ptr @used_before_default_def.resolver
// CHECK: @used_after_default_def = weak_odr ifunc void (), ptr @used_after_default_def.resolver
// CHECK: @not_used_with_default = weak_odr ifunc void (), ptr @not_used_with_default.resolver
// CHECK: @indirect_use = weak_odr ifunc void (), ptr @indirect_use.resolver
// CHECK: @internal_func = internal ifunc void (), ptr @internal_func.resolver
// CHECK: @linkonce_func = weak_odr ifunc void (), ptr @linkonce_func.resolver
// CHECK: @clones_with_default = weak_odr ifunc void (), ptr @clones_with_default.resolver
//.
// CHECK: Function Attrs: noinline nounwind optnone
// CHECK-LABEL: define {{[^@]+}}@used_before_default_def._Maes
// CHECK-SAME: () #[[ATTR0:[0-9]+]] {
// CHECK-NEXT:  entry:
// CHECK-NEXT:    ret void
//
//
// CHECK: Function Attrs: noinline nounwind optnone
// CHECK-LABEL: define {{[^@]+}}@call_before_def
// CHECK-SAME: () #[[ATTR1:[0-9]+]] {
// CHECK-NEXT:  entry:
// CHECK-NEXT:    call void @used_before_default_def()
// CHECK-NEXT:    ret void
//
//
// CHECK: Function Attrs: noinline nounwind optnone
// CHECK-LABEL: define {{[^@]+}}@used_before_default_def.default
// CHECK-SAME: () #[[ATTR2:[0-9]+]] {
// CHECK-NEXT:  entry:
// CHECK-NEXT:    ret void
//
//
// CHECK: Function Attrs: noinline nounwind optnone
// CHECK-LABEL: define {{[^@]+}}@used_after_default_def._Maes
// CHECK-SAME: () #[[ATTR0]] {
// CHECK-NEXT:  entry:
// CHECK-NEXT:    ret void
//
//
// CHECK: Function Attrs: noinline nounwind optnone
// CHECK-LABEL: define {{[^@]+}}@used_after_default_def.default
// CHECK-SAME: () #[[ATTR2]] {
// CHECK-NEXT:  entry:
// CHECK-NEXT:    ret void
//
//
// CHECK: Function Attrs: noinline nounwind optnone
// CHECK-LABEL: define {{[^@]+}}@call_after_def
// CHECK-SAME: () #[[ATTR1]] {
// CHECK-NEXT:  entry:
// CHECK-NEXT:    call void @used_after_default_def()
// CHECK-NEXT:    ret void
//
//
// CHECK: Function Attrs: noinline nounwind optnone
// CHECK-LABEL: define {{[^@]+}}@used_before_default_decl._Maes
// CHECK-SAME: () #[[ATTR0]] {
// CHECK-NEXT:  entry:
// CHECK-NEXT:    ret void
//
//
// CHECK: Function Attrs: noinline nounwind optnone
// CHECK-LABEL: define {{[^@]+}}@call_before_decl
// CHECK-SAME: () #[[ATTR1]] {
// CHECK-NEXT:  entry:
// CHECK-NEXT:    call void @used_before_default_decl()
// CHECK-NEXT:    ret void
//
//
// CHECK: Function Attrs: noinline nounwind optnone
// CHECK-LABEL: define {{[^@]+}}@used_after_default_decl._Maes
// CHECK-SAME: () #[[ATTR0]] {
// CHECK-NEXT:  entry:
// CHECK-NEXT:    ret void
//
//
// CHECK: Function Attrs: noinline nounwind optnone
// CHECK-LABEL: define {{[^@]+}}@call_after_decl
// CHECK-SAME: () #[[ATTR1]] {
// CHECK-NEXT:  entry:
// CHECK-NEXT:    call void @used_after_default_decl()
// CHECK-NEXT:    ret void
//
//
// CHECK: Function Attrs: noinline nounwind optnone
// CHECK-LABEL: define {{[^@]+}}@used_no_default._Maes
// CHECK-SAME: () #[[ATTR0]] {
// CHECK-NEXT:  entry:
// CHECK-NEXT:    ret void
//
//
// CHECK: Function Attrs: noinline nounwind optnone
// CHECK-LABEL: define {{[^@]+}}@call_no_default
// CHECK-SAME: () #[[ATTR1]] {
// CHECK-NEXT:  entry:
// CHECK-NEXT:    call void @used_no_default()
// CHECK-NEXT:    ret void
//
//
// CHECK: Function Attrs: noinline nounwind optnone
// CHECK-LABEL: define {{[^@]+}}@not_used_no_default._Maes
// CHECK-SAME: () #[[ATTR0]] {
// CHECK-NEXT:  entry:
// CHECK-NEXT:    ret void
//
//
// CHECK: Function Attrs: noinline nounwind optnone
// CHECK-LABEL: define {{[^@]+}}@not_used_with_default._Maes
// CHECK-SAME: () #[[ATTR0]] {
// CHECK-NEXT:  entry:
// CHECK-NEXT:    ret void
//
//
// CHECK: Function Attrs: noinline nounwind optnone
// CHECK-LABEL: define {{[^@]+}}@not_used_with_default.default
// CHECK-SAME: () #[[ATTR2]] {
// CHECK-NEXT:  entry:
// CHECK-NEXT:    ret void
//
//
// CHECK: Function Attrs: noinline nounwind optnone
// CHECK-LABEL: define {{[^@]+}}@indirect_use._Maes
// CHECK-SAME: () #[[ATTR0]] {
// CHECK-NEXT:  entry:
// CHECK-NEXT:    ret void
//
//
// CHECK: Function Attrs: noinline nounwind optnone
// CHECK-LABEL: define {{[^@]+}}@indirect_use.default
// CHECK-SAME: () #[[ATTR2]] {
// CHECK-NEXT:  entry:
// CHECK-NEXT:    ret void
//
//
// CHECK: Function Attrs: noinline nounwind optnone
// CHECK-LABEL: define {{[^@]+}}@call_indirectly
// CHECK-SAME: () #[[ATTR1]] {
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[FN:%.*]] = alloca ptr, align 8
// CHECK-NEXT:    store ptr @indirect_use, ptr [[FN]], align 8
// CHECK-NEXT:    [[TMP0:%.*]] = load ptr, ptr [[FN]], align 8
// CHECK-NEXT:    call void [[TMP0]]()
// CHECK-NEXT:    ret void
//
//
// CHECK: Function Attrs: noinline nounwind optnone
// CHECK-LABEL: define {{[^@]+}}@call_internal
// CHECK-SAME: () #[[ATTR1]] {
// CHECK-NEXT:  entry:
// CHECK-NEXT:    call void @internal_func()
// CHECK-NEXT:    ret void
//
//
// CHECK: Function Attrs: noinline nounwind optnone
// CHECK-LABEL: define {{[^@]+}}@call_linkonce
// CHECK-SAME: () #[[ATTR1]] {
// CHECK-NEXT:  entry:
// CHECK-NEXT:    call void @linkonce_func()
// CHECK-NEXT:    ret void
//
//
// CHECK: Function Attrs: noinline nounwind optnone
// CHECK-LABEL: define {{[^@]+}}@clones_with_default.default
// CHECK-SAME: () #[[ATTR2]] {
// CHECK-NEXT:  entry:
// CHECK-NEXT:    ret void
//
//
// CHECK: Function Attrs: noinline nounwind optnone
// CHECK-LABEL: define {{[^@]+}}@clones_with_default._Maes
// CHECK-SAME: () #[[ATTR0]] {
// CHECK-NEXT:  entry:
// CHECK-NEXT:    ret void
//
//
// CHECK: Function Attrs: noinline nounwind optnone
// CHECK-LABEL: define {{[^@]+}}@clones_without_default._Maes
// CHECK-SAME: () #[[ATTR0]] {
// CHECK-NEXT:  entry:
// CHECK-NEXT:    ret void
//
//
// CHECK: Function Attrs: disable_sanitizer_instrumentation
// CHECK-LABEL: define {{[^@]+}}@used_before_default_def.resolver
// CHECK-SAME: () #[[ATTR5:[0-9]+]] comdat {
// CHECK-NEXT:  resolver_entry:
// CHECK-NEXT:    call void @__init_cpu_features_resolver()
// CHECK-NEXT:    [[TMP0:%.*]] = load i64, ptr @__aarch64_cpu_features, align 8
// CHECK-NEXT:    [[TMP1:%.*]] = and i64 [[TMP0]], 33536
// CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i64 [[TMP1]], 33536
// CHECK-NEXT:    [[TMP3:%.*]] = and i1 true, [[TMP2]]
// CHECK-NEXT:    br i1 [[TMP3]], label [[RESOLVER_RETURN:%.*]], label [[RESOLVER_ELSE:%.*]]
// CHECK:       resolver_return:
// CHECK-NEXT:    ret ptr @used_before_default_def._Maes
// CHECK:       resolver_else:
// CHECK-NEXT:    ret ptr @used_before_default_def.default
//
//
// CHECK: Function Attrs: disable_sanitizer_instrumentation
// CHECK-LABEL: define {{[^@]+}}@used_after_default_def.resolver
// CHECK-SAME: () #[[ATTR5]] comdat {
// CHECK-NEXT:  resolver_entry:
// CHECK-NEXT:    call void @__init_cpu_features_resolver()
// CHECK-NEXT:    [[TMP0:%.*]] = load i64, ptr @__aarch64_cpu_features, align 8
// CHECK-NEXT:    [[TMP1:%.*]] = and i64 [[TMP0]], 33536
// CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i64 [[TMP1]], 33536
// CHECK-NEXT:    [[TMP3:%.*]] = and i1 true, [[TMP2]]
// CHECK-NEXT:    br i1 [[TMP3]], label [[RESOLVER_RETURN:%.*]], label [[RESOLVER_ELSE:%.*]]
// CHECK:       resolver_return:
// CHECK-NEXT:    ret ptr @used_after_default_def._Maes
// CHECK:       resolver_else:
// CHECK-NEXT:    ret ptr @used_after_default_def.default
//
//
// CHECK: Function Attrs: disable_sanitizer_instrumentation
// CHECK-LABEL: define {{[^@]+}}@not_used_with_default.resolver
// CHECK-SAME: () #[[ATTR5]] comdat {
// CHECK-NEXT:  resolver_entry:
// CHECK-NEXT:    call void @__init_cpu_features_resolver()
// CHECK-NEXT:    [[TMP0:%.*]] = load i64, ptr @__aarch64_cpu_features, align 8
// CHECK-NEXT:    [[TMP1:%.*]] = and i64 [[TMP0]], 33536
// CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i64 [[TMP1]], 33536
// CHECK-NEXT:    [[TMP3:%.*]] = and i1 true, [[TMP2]]
// CHECK-NEXT:    br i1 [[TMP3]], label [[RESOLVER_RETURN:%.*]], label [[RESOLVER_ELSE:%.*]]
// CHECK:       resolver_return:
// CHECK-NEXT:    ret ptr @not_used_with_default._Maes
// CHECK:       resolver_else:
// CHECK-NEXT:    ret ptr @not_used_with_default.default
//
//
// CHECK: Function Attrs: disable_sanitizer_instrumentation
// CHECK-LABEL: define {{[^@]+}}@indirect_use.resolver
// CHECK-SAME: () #[[ATTR5]] comdat {
// CHECK-NEXT:  resolver_entry:
// CHECK-NEXT:    call void @__init_cpu_features_resolver()
// CHECK-NEXT:    [[TMP0:%.*]] = load i64, ptr @__aarch64_cpu_features, align 8
// CHECK-NEXT:    [[TMP1:%.*]] = and i64 [[TMP0]], 33536
// CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i64 [[TMP1]], 33536
// CHECK-NEXT:    [[TMP3:%.*]] = and i1 true, [[TMP2]]
// CHECK-NEXT:    br i1 [[TMP3]], label [[RESOLVER_RETURN:%.*]], label [[RESOLVER_ELSE:%.*]]
// CHECK:       resolver_return:
// CHECK-NEXT:    ret ptr @indirect_use._Maes
// CHECK:       resolver_else:
// CHECK-NEXT:    ret ptr @indirect_use.default
//
//
// CHECK: Function Attrs: noinline nounwind optnone
// CHECK-LABEL: define {{[^@]+}}@internal_func._Maes
// CHECK-SAME: () #[[ATTR0]] {
// CHECK-NEXT:  entry:
// CHECK-NEXT:    ret void
//
//
// CHECK: Function Attrs: noinline nounwind optnone
// CHECK-LABEL: define {{[^@]+}}@internal_func.default
// CHECK-SAME: () #[[ATTR2]] {
// CHECK-NEXT:  entry:
// CHECK-NEXT:    ret void
//
//
// CHECK: Function Attrs: disable_sanitizer_instrumentation
// CHECK-LABEL: define {{[^@]+}}@internal_func.resolver
// CHECK-SAME: () #[[ATTR5]] {
// CHECK-NEXT:  resolver_entry:
// CHECK-NEXT:    call void @__init_cpu_features_resolver()
// CHECK-NEXT:    [[TMP0:%.*]] = load i64, ptr @__aarch64_cpu_features, align 8
// CHECK-NEXT:    [[TMP1:%.*]] = and i64 [[TMP0]], 33536
// CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i64 [[TMP1]], 33536
// CHECK-NEXT:    [[TMP3:%.*]] = and i1 true, [[TMP2]]
// CHECK-NEXT:    br i1 [[TMP3]], label [[RESOLVER_RETURN:%.*]], label [[RESOLVER_ELSE:%.*]]
// CHECK:       resolver_return:
// CHECK-NEXT:    ret ptr @internal_func._Maes
// CHECK:       resolver_else:
// CHECK-NEXT:    ret ptr @internal_func.default
//
//
// CHECK: Function Attrs: noinline nounwind optnone
// CHECK-LABEL: define {{[^@]+}}@linkonce_func._Maes
// CHECK-SAME: () #[[ATTR0]] {
// CHECK-NEXT:  entry:
// CHECK-NEXT:    ret void
//
//
// CHECK: Function Attrs: noinline nounwind optnone
// CHECK-LABEL: define {{[^@]+}}@linkonce_func.default
// CHECK-SAME: () #[[ATTR2]] {
// CHECK-NEXT:  entry:
// CHECK-NEXT:    ret void
//
//
// CHECK: Function Attrs: disable_sanitizer_instrumentation
// CHECK-LABEL: define {{[^@]+}}@linkonce_func.resolver
// CHECK-SAME: () #[[ATTR5]] comdat {
// CHECK-NEXT:  resolver_entry:
// CHECK-NEXT:    call void @__init_cpu_features_resolver()
// CHECK-NEXT:    [[TMP0:%.*]] = load i64, ptr @__aarch64_cpu_features, align 8
// CHECK-NEXT:    [[TMP1:%.*]] = and i64 [[TMP0]], 33536
// CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i64 [[TMP1]], 33536
// CHECK-NEXT:    [[TMP3:%.*]] = and i1 true, [[TMP2]]
// CHECK-NEXT:    br i1 [[TMP3]], label [[RESOLVER_RETURN:%.*]], label [[RESOLVER_ELSE:%.*]]
// CHECK:       resolver_return:
// CHECK-NEXT:    ret ptr @linkonce_func._Maes
// CHECK:       resolver_else:
// CHECK-NEXT:    ret ptr @linkonce_func.default
//
//
// CHECK: Function Attrs: disable_sanitizer_instrumentation
// CHECK-LABEL: define {{[^@]+}}@clones_with_default.resolver
// CHECK-SAME: () #[[ATTR5]] comdat {
// CHECK-NEXT:  resolver_entry:
// CHECK-NEXT:    call void @__init_cpu_features_resolver()
// CHECK-NEXT:    [[TMP0:%.*]] = load i64, ptr @__aarch64_cpu_features, align 8
// CHECK-NEXT:    [[TMP1:%.*]] = and i64 [[TMP0]], 33536
// CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i64 [[TMP1]], 33536
// CHECK-NEXT:    [[TMP3:%.*]] = and i1 true, [[TMP2]]
// CHECK-NEXT:    br i1 [[TMP3]], label [[RESOLVER_RETURN:%.*]], label [[RESOLVER_ELSE:%.*]]
// CHECK:       resolver_return:
// CHECK-NEXT:    ret ptr @clones_with_default._Maes
// CHECK:       resolver_else:
// CHECK-NEXT:    ret ptr @clones_with_default.default
//
//.
// CHECK: [[META0:![0-9]+]] = !{!"{{.*}}clang version {{.*}}"}
//.
