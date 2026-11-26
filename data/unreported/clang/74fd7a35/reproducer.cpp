
// RUN: %clang_cc1 -fsycl-is-host -ast-print %s -o - | FileCheck %s
// RUN: %clang_cc1 -fsycl-is-device -ast-print %s -o - | FileCheck %s

struct sycl_kernel_launcher {
  template<typename KernelName, typename... Ts>
  #pragma clang __debug parser_crash

  // CHECK: REPRODUCER METAINFO: {"libclang.operation": "parse", "libclang.opts": "1"}

  // CHECK: REPRODUCER:
  // CHECK-NEXT: {
  // CHECK-NEXT: "files":["{{.*}}.c","{{.*}}.sh"]
  // CHECK-NEXT: }
  void sycl_kernel_launch(const char *, Ts...) {}

  template<typename KernelName, typename KernelType>
  [[clang::sycl_kernel_entry_point(KernelName)]]
  void sycl_kernel_entry_point(KernelType kernel) {
    kernel();
  }
};
// CHECK:      template <typename KernelName, typename KernelType> void sycl_kernel_entry_point(KernelType kernel)
// CHECK-NEXT: {
// CHECK-NEXT:     kernel();
// CHECK-NEXT: }
// CHECK:      template<> void sycl_kernel_entry_point<KN, (lambda at {{.*}})>((lambda at {{.*}}) kernel)
// CHECK-NEXT: {
// CHECK-NEXT:     kernel();
// CHECK-NEXT: }

void f(sycl_kernel_launcher skl) {
  skl.sycl_kernel_entry_point<struct KN>([]{});
}
