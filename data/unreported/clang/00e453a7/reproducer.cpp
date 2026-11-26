
// REQUIRES: x86-registered-target
// RUN: %clang_cc1 -triple x86_64 %s -S -o /dev/null -DWARN -verify
// RUN: %clang_cc1 -triple x86_64 %s -S -o /dev/null -Werror -verify
// RUN: %clang_cc1 -triple x86_64-linux-gnu %s -S -o - | FileCheck %s
void f(void) {
  asm("movaps %xmm3, (%esi, 2)");
// expected-note@1 {{instantiated into assembly here}}
#ifdef WARN
// expected-warning@-3 {{scale factor without index register is ignored}}
#else
// expected-error@-5 {{scale factor without index register is ignored}}
#endif
}

static unsigned var[1] = {};
void g(void) { asm volatile("movd %%xmm0, %0"
                            :
                            : "m"(var)); }

void pr40890(void) {
  struct s {
    int a, b;
  } s;
  #pragma clang module begin A
  __attribute__((target("default"))) void f();
  __attribute__((target("sse4.2"))) void f();
  #pragma clang module end
  #pragma clang module endbuild

  #pragma clang module build B
  module B {}
  #pragma clang module contents
  #pragma clang module begin B
  __attribute__((target("default"))) void f();
  __attribute__((target("sse4.2"))) void f();
  #pragma clang module end
  #pragma clang module endbuild

  #pragma clang module import A
  #pragma clang module import B
  void a() { f(); }

  // Negative tests to validate that the resolver only calls each 1x.
  // CHECK: define weak_odr ptr @_Z1fv.resolver
  // CHECK: ret ptr @_Z1fv.sse4.2
  // CHECK-NOT: ret ptr @_Z1fv.sse4.2
  // CHECK: ret ptr @_Z1fv
  // CHECK-NOT: ret ptr @_Z1fv
  __asm__ __volatile__("\n#define S_A abcd%0\n" : : "n"(&((struct s*)0)->a));
  __asm__ __volatile__("\n#define S_B abcd%0\n" : : "n"(&((struct s*)0)->b));
  __asm__ __volatile__("\n#define BEEF abcd%0\n" : : "n"((int*)0xdeadbeeeeeef));
  __asm__ __volatile__("movabsq %0, %%rax" : : "n"(4624529908474429119));

// CHECK-LABEL: pr40890
// CHECK: #define S_A abcd$0
// CHECK: #define S_B abcd$4
// CHECK: #define BEEF abcd$244837814038255
// CHECK: movabsq $4624529908474429119, %rax
}
