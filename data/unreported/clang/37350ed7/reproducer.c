
int main() {
    int a[10];
    int b['a'];
    int c[65];
    (void)a; (void)b; (void)c;
    return 0;
    // RUN: not %clang --target=arm-csr-firmware -### %s 2>&1 | FileCheck %s
    // RUN: not %clang_cl --target=arm-csr-firmware -### %s 2>&1 | FileCheck %s

    // RUN: not %clang --target=arm-amd-firmware -### %s 2>&1 | FileCheck %s
    // RUN: not %clang_cl --target=arm-amd-firmware -### %s 2>&1 | FileCheck %s

    // RUN: not %clang --target=arm-mesa-firmware -### %s 2>&1 | FileCheck %s
    // RUN: not %clang_cl --target=arm-mesa-firmware -### %s 2>&1 | FileCheck %s

    // RUN: not %clang --target=arm-suse-firmware -### %s 2>&1 | FileCheck %s
    // RUN: not %clang_cl --target=arm-suse-firmware -### %s 2>&1 | FileCheck %s

    // RUN: not %clang --target=arm-oe-firmware -### %s 2>&1 | FileCheck %s
    // RUN: not %clang_cl --target=arm-oe-firmware -### %s 2>&1 | FileCheck %s

    // RUN: not %clang --target=arm-intel-firmware -### %s 2>&1 | FileCheck %s
    // RUN: not %clang_cl --target=arm-intel-firmware -### %s 2>&1 | FileCheck %s

    // RUN: not %clang --target=arm-meta-firmware -### %s 2>&1 | FileCheck %s
    // RUN: not %clang_cl --target=arm-meta-firmware -### %s 2>&1 | FileCheck %s

    // CHECK: LLVM ERROR: the firmware target os is only supported for the apple vendor
}
