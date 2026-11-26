
// RUN: %clang_cc1 -triple x86_64-unknown-freebsd -emit-llvm -fobjc-runtime=gnustep-1.7 -fblocks -o - %s | FileCheck --check-prefix=CHECK-COMDAT %s
// RUN: %clang_cc1 -triple x86_64-pc-linux-gnu -emit-llvm -fobjc-runtime=gcc -fblocks -o - %s | FileCheck --check-prefix=CHECK-COMDAT %s
// RUN: %clang_cc1 -triple=x86_64-apple-darwin10 -emit-llvm -fblocks -o - %s | FileCheck %s

// Test that descriptor symbol names don't include '@'.

// CHECK-COMDAT: $"__block_descriptor_40_8_32o_e5_v8\01?0l" = comdat any
// CHECK-COMDAT: @[[STR:.*]] = private unnamed_addr constant [6 x i8] c"v8@?0\00"
// CHECK-COMDAT: @"__block_descriptor_40_8_32o_e5_v8\01?0l" = linkonce_odr hidden unnamed_addr constant { i64, i64, ptr, ptr, ptr, {{.*}} } { i64 0, i64 40, ptr {{.*}}, ptr @[[STR]], {{.*}} }, comdat, align 8

// CHECK: @[[STR:.*]] = private unnamed_addr constant [6 x i8] c"v8@?0\00"
// CHECK: @"__block_descriptor_40_8_32o_e5_v8\01?0l" = linkonce_odr hidden unnamed_addr constant { i64, i64, ptr, ptr, ptr, {{.*}} } { i64 0, i64 40, ptr {{.*}}, ptr {{.*}}, ptr @[[STR]], {{.*}} }, align 8

typedef void (^BlockTy)(void);

void test(id a) {
  BlockTy b = ^{ (void)a; };
}
// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnu %s -emit-llvm -o - | FileCheck %s --check-prefix=X86_64_LINUX
// RUN: %clang_cc1 -triple i386-unknown-linux-gnu %s -emit-llvm -o - | FileCheck %s --check-prefix=X86_LINUX
// RUN: %clang_cc1 -triple x86_64-pc-win32 %s -emit-llvm -o - | FileCheck %s --check-prefix=X86_64_WIN
// RUN: %clang_cc1 -triple i386-pc-win32 %s -emit-llvm -o - | FileCheck %s --check-prefix=X86_WIN
// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnux32 %s -emit-llvm -o - | FileCheck %s --check-prefix=X86_64_LINUX

#ifdef __x86_64__
typedef __UINT64_TYPE__ uword;
#else
typedef __UINT32_TYPE__ uword;
#endif

__attribute__((interrupt)) void foo7(int *a, uword b) {}
namespace S {
__attribute__((interrupt)) void foo8(int *a) {}
}
struct St {
static void foo9(int *a) __attribute__((interrupt)) {}
};
// X86_64_LINUX: @llvm.compiler.used = appending global [3 x ptr] [ptr @{{.*}}foo7{{.*}}, ptr @{{.*}}foo8{{.*}}, ptr @{{.*}}foo9{{.*}}], section "llvm.metadata"
// X86_64_LINUX: define{{.*}} x86_intrcc void @{{.*}}foo7{{.*}}(ptr noundef byval(i32) %{{.+}}, i64 noundef %{{.+}})
// X86_64_LINUX: define{{.*}} x86_intrcc void @{{.*}}foo8{{.*}}(ptr noundef byval(i32) %{{.+}})
// X86_64_LINUX: define linkonce_odr x86_intrcc void @{{.*}}foo9{{.*}}(ptr noundef byval(i32) %{{.+}})
// X86_LINUX: @llvm.compiler.used = appending global [3 x ptr] [ptr @{{.*}}foo7{{.*}}, ptr @{{.*}}foo8{{.*}}, ptr @{{.*}}foo9{{.*}}], section "llvm.metadata"
// X86_LINUX: define{{.*}} x86_intrcc void @{{.*}}foo7{{.*}}(ptr noundef byval(i32) %{{.+}}, i32 noundef %{{.+}})
// X86_LINUX: define{{.*}} x86_intrcc void @{{.*}}foo8{{.*}}(ptr noundef byval(i32) %{{.+}})
// X86_LINUX: define linkonce_odr x86_intrcc void @{{.*}}foo9{{.*}}(ptr noundef byval(i32) %{{.+}})
// X86_64_WIN: @llvm.used = appending global [3 x ptr] [ptr @{{.*}}foo7{{.*}}, ptr @{{.*}}foo8{{.*}}, ptr @{{.*}}foo9{{.*}}], section "llvm.metadata"
// X86_64_WIN: define dso_local x86_intrcc void @{{.*}}foo7{{.*}}(ptr noundef byval(i32) %{{.+}}, i64 noundef %{{.+}})
// X86_64_WIN: define dso_local x86_intrcc void @{{.*}}foo8{{.*}}(ptr noundef byval(i32) %{{.+}})
// X86_64_WIN: define linkonce_odr dso_local x86_intrcc void @{{.*}}foo9{{.*}}(ptr noundef byval(i32) %{{.+}})
// X86_WIN: @llvm.used = appending global [3 x ptr] [ptr @{{.*}}foo7{{.*}}, ptr @{{.*}}foo8{{.*}}, ptr @{{.*}}foo9{{.*}}], section "llvm.metadata"
// X86_WIN: define dso_local x86_intrcc void @{{.*}}foo7{{.*}}(ptr noundef byval(i32) %{{.+}}, i32 noundef %{{.+}})
// X86_WIN: define dso_local x86_intrcc void @{{.*}}foo8{{.*}}(ptr noundef byval(i32) %{{.+}})
// X86_WIN: define linkonce_odr dso_local x86_intrcc void @{{.*}}foo9{{.*}}(ptr noundef byval(i32) %{{.+}})
