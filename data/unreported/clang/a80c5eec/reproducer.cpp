// RUN: %clang -### --target=aarch64-none-elf -march=armv8a+ssbs   %s 2>&1 | FileCheck %s
// RUN: %clang -### --target=aarch64-none-elf -mcpu=cortex-x1      %s 2>&1 | FileCheck %s
// RUN: %clang -### --target=aarch64-none-elf -mcpu=cortex-x1c     %s 2>&1 | FileCheck %s
// RUN: %clang -### --target=aarch64-none-elf -mcpu=cortex-a77     %s 2>&1 | FileCheck %s
// CHECK: "-target-feature" "+ssbs"

// RUN: %clang -### --target=aarch64-none-elf -march=armv8a+nossbs %s 2>&1 | FileCheck %s --check-prefix=NOSSBS
// RUN: %clang -### --target=aarch64-none-elf -mcpu=cortex-x1c+nossbs %s 2>&1 | FileCheck %s --check-prefix=NOSSBS
// NOSSBS-NOT: "-target-feature" "+ssbs"

// RUN: %clang -### --target=aarch64-none-elf                      %s 2>&1 | FileCheck %s --check-prefix=ABSENTSSBS
// ABSENTSSBS-NOT: "-target-feature" "+ssbs"
// ABSENTSSBS-NOT: "-target-feature" "-ssbs"

// RUN: %clang_cc1 -triple arm64-apple-darwin -fsyntax-only -verify -Wunused -std=c++98 %s
// RUN: %clang_cc1 -triple arm64-apple-darwin -fsyntax-only -verify -Wunused -std=c++14 %s

__attribute__((target_version("fp16")))
static int not_used_fmv(void) { return 1; }
__attribute__((target_version("fp16fml")))
static int not_used_fmv(void) { return 2; }
__attribute__((target_version("default")))
static int not_used_fmv(void) { return 0; } // expected-warning {{unused function 'not_used_fmv'}}


__attribute__((target_version("fp16")))
static int definitely_used_fmv(void) { return 1; }
__attribute__((target_version("fp16fml")))
static int definitely_used_fmv(void) { return 2; }
__attribute__((target_version("default")))
static int definitely_used_fmv(void) { return 0; }
int definite_user(void) { return definitely_used_fmv(); }
