#include <x86intrin.h>
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple i386-unknown-unknown -emit-llvm -o - %s | FileCheck %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple i386-unknown-unknown -emit-llvm -O2 -o - %s | FileCheck %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple powerpc-unknown-gnu-linux -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple powerpc64-unknown-gnu-linux -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple powerpc64le-unknown-gnu-linux -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple i386-netbsd -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-DOUBLE-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple x86_64-netbsd -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-DOUBLE-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple arm-netbsd-eabi -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-DOUBLE-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple aarch64-netbsd -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-DOUBLE-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple loongarch32 -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple loongarch64 -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple mips-netbsd -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-DOUBLE-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple mips-unknown-gnu-linux -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple mipsel-unknown-gnu-linux -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple mips64-unknown-gnu-linux -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple mips64el-unknown-gnu-linux -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple riscv32-elf -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple riscv64-elf -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple riscv32-linux -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple riscv64-linux -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple riscv64-freebsd -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple riscv64-freebsd -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple riscv64-openbsd -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple powerpc-netbsd -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-DOUBLE-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple powerpc64-netbsd -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-DOUBLE-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple powerpc64le-netbsd -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-DOUBLE-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple sparc-netbsd -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-DOUBLE-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple sparc64-netbsd -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-DOUBLE-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -emit-llvm -o - %s | FileCheck %s -check-prefix=NO-MCOUNT

int bar(void) {
// CHECK: define dso_local i32 @bar() #0 {
  return 0;
}
// REQUIRES: x86-registered-target
// RUN: %clang_cc1 %s -triple=x86_64-linux-gnu -S -o - -Werror
#define __MM_MALLOC_H



// No warnings.
extern __m256i a;

int baz(void) {
  return bar();
}

int __attribute__((target("avx"))) qq_avx(void) {
  return _mm256_extract_epi32(a, 3);
}

int qq_noavx(void) {
  return 0;
}

extern __m256i a;
int qq(void) {
  if (__builtin_cpu_supports("avx"))
    return qq_avx();
  else
    return qq_noavx();
}

// Test that fma and fma4 are both separately and combined valid for an fma intrinsic.
__m128 __attribute__((target("fma"))) fma_1(__m128 a, __m128 b, __m128 c) {
  return __builtin_ia32_vfmaddsubps(a, b, c);
}

__m128 __attribute__((target("fma4"))) fma_2(__m128 a, __m128 b, __m128 c) {
  return __builtin_ia32_vfmaddsubps(a, b, c);
}

__m128 __attribute__((target("fma,fma4"))) fma_3(__m128 a, __m128 b, __m128 c) {
  return __builtin_ia32_vfmaddsubps(a, b, c);
}

void verifyfeaturestrings(void) {
  (void)__builtin_cpu_supports("cmov");
  (void)__builtin_cpu_supports("mmx");
  (void)__builtin_cpu_supports("popcnt");
  (void)__builtin_cpu_supports("sse");
  (void)__builtin_cpu_supports("sse2");
  (void)__builtin_cpu_supports("sse3");
  (void)__builtin_cpu_supports("ssse3");
  (void)__builtin_cpu_supports("sse4.1");
  (void)__builtin_cpu_supports("sse4.2");
  (void)__builtin_cpu_supports("avx");
  (void)__builtin_cpu_supports("avx2");
  (void)__builtin_cpu_supports("sse4a");
  (void)__builtin_cpu_supports("fma4");
  (void)__builtin_cpu_supports("xop");
  (void)__builtin_cpu_supports("fma");
  (void)__builtin_cpu_supports("avx512f");
  (void)__builtin_cpu_supports("bmi");
  (void)__builtin_cpu_supports("bmi2");
  (void)__builtin_cpu_supports("aes");
  (void)__builtin_cpu_supports("pclmul");
  (void)__builtin_cpu_supports("avx512vl");
  (void)__builtin_cpu_supports("avx512bw");
  (void)__builtin_cpu_supports("avx512dq");
  (void)__builtin_cpu_supports("avx512cd");
  (void)__builtin_cpu_supports("avx512vbmi");
  (void)__builtin_cpu_supports("avx512ifma");
  (void)__builtin_cpu_supports("avx512vpopcntdq");
  (void)__builtin_cpu_supports("avx512vbmi2");
  (void)__builtin_cpu_supports("gfni");
  (void)__builtin_cpu_supports("vpclmulqdq");
  (void)__builtin_cpu_supports("avx512vnni");
  (void)__builtin_cpu_supports("avx512bitalg");
  (void)__builtin_cpu_supports("avx512bmm");
  (void)__builtin_cpu_supports("avx512bf16");
  (void)__builtin_cpu_supports("avx512vp2intersect");
  (void)__builtin_cpu_supports("f16c");
  (void)__builtin_cpu_supports("avx512fp16");
  (void)__builtin_cpu_supports("adx");
  (void)__builtin_cpu_supports("cldemote");
  (void)__builtin_cpu_supports("clflushopt");
  (void)__builtin_cpu_supports("clwb");
  (void)__builtin_cpu_supports("clzero");
  (void)__builtin_cpu_supports("cx16");
  (void)__builtin_cpu_supports("enqcmd");
  (void)__builtin_cpu_supports("fsgsbase");
  (void)__builtin_cpu_supports("lwp");
  (void)__builtin_cpu_supports("lzcnt");
  (void)__builtin_cpu_supports("movbe");
  (void)__builtin_cpu_supports("movdir64b");
  (void)__builtin_cpu_supports("movdiri");
  (void)__builtin_cpu_supports("mwaitx");
  (void)__builtin_cpu_supports("pconfig");
  (void)__builtin_cpu_supports("pku");
  (void)__builtin_cpu_supports("prfchw");
  (void)__builtin_cpu_supports("ptwrite");
  (void)__builtin_cpu_supports("rdpid");
  (void)__builtin_cpu_supports("rdrnd");
  (void)__builtin_cpu_supports("rdseed");
  (void)__builtin_cpu_supports("rtm");
  (void)__builtin_cpu_supports("serialize");
  (void)__builtin_cpu_supports("sgx");
  (void)__builtin_cpu_supports("sha");
  (void)__builtin_cpu_supports("shstk");
  (void)__builtin_cpu_supports("tbm");
  (void)__builtin_cpu_supports("tsxldtrk");
  (void)__builtin_cpu_supports("vaes");
  (void)__builtin_cpu_supports("waitpkg");
  (void)__builtin_cpu_supports("wbnoinvd");
  (void)__builtin_cpu_supports("xsave");
  (void)__builtin_cpu_supports("xsavec");
  (void)__builtin_cpu_supports("xsaveopt");
  (void)__builtin_cpu_supports("xsaves");
  (void)__builtin_cpu_supports("amx-tile");
  (void)__builtin_cpu_supports("amx-int8");
  (void)__builtin_cpu_supports("amx-bf16");
  (void)__builtin_cpu_supports("uintr");
  (void)__builtin_cpu_supports("hreset");
  (void)__builtin_cpu_supports("kl");
  (void)__builtin_cpu_supports("widekl");
  (void)__builtin_cpu_supports("avxvnni");
  (void)__builtin_cpu_supports("avxifma");
  (void)__builtin_cpu_supports("avxvnniint8");
  (void)__builtin_cpu_supports("avxneconvert");
  (void)__builtin_cpu_supports("cmpccxadd");
  (void)__builtin_cpu_supports("amx-fp16");
  (void)__builtin_cpu_supports("prefetchi");
  (void)__builtin_cpu_supports("raoint");
  (void)__builtin_cpu_supports("amx-complex");
  (void)__builtin_cpu_supports("avxvnniint16");
  (void)__builtin_cpu_supports("sm3");
  (void)__builtin_cpu_supports("sha512");
  (void)__builtin_cpu_supports("sm4");
  (void)__builtin_cpu_supports("apxf");
  (void)__builtin_cpu_supports("usermsr");
  (void)__builtin_cpu_supports("avx10.1");
  (void)__builtin_cpu_supports("avx10.2");
  (void)__builtin_cpu_supports("avx10v2aux");
  (void)__builtin_cpu_supports("movrs");
}

int foo(void) {
// CHECK: define dso_local i32 @foo() #0 {
  return bar();
}

int __attribute__((no_instrument_function)) no_instrument(void) {
// CHECK: define dso_local i32 @no_instrument() #1 {
  return foo();
}

int main(void) {
// CHECK: define dso_local i32 @main() #0 {
  return no_instrument();
}

// CHECK: attributes #0 = { {{.*}} "instrument-function-entry-inlined"="mcount"
// CHECK-NOT: attributes #1 = { {{.*}}"mcount"
// CHECK-PREFIXED: attributes #0 = { {{.*}} "instrument-function-entry-inlined"="_mcount"
// CHECK-PREFIXED-NOT: attributes #1 = { {{.*}}"_mcount"
// CHECK-DOUBLE-PREFIXED: attributes #0 = { {{.*}} "instrument-function-entry-inlined"="__mcount"
// CHECK-DOUBLE-PREFIXED-NOT: attributes #1 = { {{.*}}"__mcount"
// NO-MCOUNT-NOT: attributes{{.*}}mcount
// NO-MCOUNT1-NOT: attributes{{.*}}mcount

void verifycpustrings(void) {
  (void)__builtin_cpu_is("alderlake");
  (void)__builtin_cpu_is("amd");
  (void)__builtin_cpu_is("amdfam10h");
  (void)__builtin_cpu_is("amdfam15h");
  (void)__builtin_cpu_is("amdfam17h");
  (void)__builtin_cpu_is("atom");
  (void)__builtin_cpu_is("barcelona");
  (void)__builtin_cpu_is("bdver1");
  (void)__builtin_cpu_is("bdver2");
  (void)__builtin_cpu_is("bdver3");
  (void)__builtin_cpu_is("bdver4");
  (void)__builtin_cpu_is("bonnell");
  (void)__builtin_cpu_is("broadwell");
  (void)__builtin_cpu_is("btver1");
  (void)__builtin_cpu_is("btver2");
  (void)__builtin_cpu_is("cannonlake");
  (void)__builtin_cpu_is("cascadelake");
  (void)__builtin_cpu_is("cooperlake");
  (void)__builtin_cpu_is("core2");
  (void)__builtin_cpu_is("corei7");
  (void)__builtin_cpu_is("goldmont");
  (void)__builtin_cpu_is("goldmont-plus");
  (void)__builtin_cpu_is("grandridge");
  (void)__builtin_cpu_is("graniterapids");
  (void)__builtin_cpu_is("emeraldrapids");
  (void)__builtin_cpu_is("graniterapids-d");
  (void)__builtin_cpu_is("arrowlake");
  (void)__builtin_cpu_is("arrowlake-s");
  (void)__builtin_cpu_is("lunarlake");
  (void)__builtin_cpu_is("clearwaterforest");
  (void)__builtin_cpu_is("pantherlake");
  (void)__builtin_cpu_is("wildcatlake");
  (void)__builtin_cpu_is("novalake");
  (void)__builtin_cpu_is("haswell");
  (void)__builtin_cpu_is("icelake-client");
  (void)__builtin_cpu_is("icelake-server");
  (void)__builtin_cpu_is("intel");
  (void)__builtin_cpu_is("istanbul");
  (void)__builtin_cpu_is("ivybridge");
  (void)__builtin_cpu_is("knl");
  (void)__builtin_cpu_is("knm");
  (void)__builtin_cpu_is("meteorlake");
  (void)__builtin_cpu_is("nehalem");
  (void)__builtin_cpu_is("raptorlake");
  (void)__builtin_cpu_is("rocketlake");
  (void)__builtin_cpu_is("sandybridge");
  (void)__builtin_cpu_is("shanghai");
  (void)__builtin_cpu_is("sierraforest");
  (void)__builtin_cpu_is("silvermont");
  (void)__builtin_cpu_is("skylake");
  (void)__builtin_cpu_is("skylake-avx512");
  (void)__builtin_cpu_is("slm");
  (void)__builtin_cpu_is("tigerlake");
  (void)__builtin_cpu_is("sapphirerapids");
  (void)__builtin_cpu_is("tremont");
  (void)__builtin_cpu_is("gracemont");
  (void)__builtin_cpu_is("westmere");
  (void)__builtin_cpu_is("znver1");
  (void)__builtin_cpu_is("znver2");
  (void)__builtin_cpu_is("znver3");
  (void)__builtin_cpu_is("znver4");
  (void)__builtin_cpu_is("znver5");
  (void)__builtin_cpu_is("znver6");
  (void)__builtin_cpu_is("diamondrapids");
  (void)__builtin_cpu_is("c86-4g-m4");
  (void)__builtin_cpu_is("c86-4g-m6");
  (void)__builtin_cpu_is("c86-4g-m7");
  (void)__builtin_cpu_is("c86-4g-m8");
}

// RUN: %clang_cc1 -disable-llvm-passes -pg -triple i386-unknown-unknown -emit-llvm -o - %s | FileCheck %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple i386-unknown-unknown -emit-llvm -O2 -o - %s | FileCheck %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple powerpc-unknown-gnu-linux -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple powerpc64-unknown-gnu-linux -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple powerpc64le-unknown-gnu-linux -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple i386-netbsd -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-DOUBLE-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple x86_64-netbsd -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-DOUBLE-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple arm-netbsd-eabi -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-DOUBLE-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple aarch64-netbsd -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-DOUBLE-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple loongarch32 -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple loongarch64 -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple mips-netbsd -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-DOUBLE-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple mips-unknown-gnu-linux -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple mipsel-unknown-gnu-linux -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple mips64-unknown-gnu-linux -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple mips64el-unknown-gnu-linux -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple riscv32-elf -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple riscv64-elf -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple riscv32-linux -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple riscv64-linux -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple riscv64-freebsd -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple riscv64-freebsd -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple riscv64-openbsd -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple powerpc-netbsd -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-DOUBLE-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple powerpc64-netbsd -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-DOUBLE-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple powerpc64le-netbsd -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-DOUBLE-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple sparc-netbsd -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-DOUBLE-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -pg -triple sparc64-netbsd -emit-llvm -o - %s | FileCheck -check-prefixes=CHECK-DOUBLE-PREFIXED,NO-MCOUNT1 %s
// RUN: %clang_cc1 -disable-llvm-passes -emit-llvm -o - %s | FileCheck %s -check-prefix=NO-MCOUNT





// CHECK: attributes #0 = { {{.*}} "instrument-function-entry-inlined"="mcount"
// CHECK-NOT: attributes #1 = { {{.*}}"mcount"
// CHECK-PREFIXED: attributes #0 = { {{.*}} "instrument-function-entry-inlined"="_mcount"
// CHECK-PREFIXED-NOT: attributes #1 = { {{.*}}"_mcount"
// CHECK-DOUBLE-PREFIXED: attributes #0 = { {{.*}} "instrument-function-entry-inlined"="__mcount"
// CHECK-DOUBLE-PREFIXED-NOT: attributes #1 = { {{.*}}"__mcount"
// NO-MCOUNT-NOT: attributes{{.*}}mcount
// NO-MCOUNT1-NOT: attributes{{.*}}mcount
