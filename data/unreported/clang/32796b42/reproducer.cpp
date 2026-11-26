
// Check if we can merge bitfields across empty members

// Configs that have cheap unaligned access
// Little Endian
// RUN: %clang_cc1 -triple=aarch64-apple-darwin %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT %s
// RUN: %clang_cc1 -triple=aarch64-linux-gnu %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT %s
// RUN: %clang_cc1 -triple=arm-apple-darwin %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT-DWN32 %s
// RUN: %clang_cc1 -triple=arm-none-eabi %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT %s
// RUN: %clang_cc1 -triple=i686-linux-gnu %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT %s
// RUN: %clang_cc1 -triple=loongarch64-elf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT %s
// RUN: %clang_cc1 -triple=powerpcle-linux-gnu %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT %s
// RUN: %clang_cc1 -triple=ve-elf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT %s
// RUN: %clang_cc1 -triple=wasm32 %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT %s
// RUN: %clang_cc1 -triple=wasm64 %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT %s
// RUN: %clang_cc1 -triple=x86_64-linux-gnu %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT %s

// Big Endian
// RUN: %clang_cc1 -triple=powerpc-linux-gnu %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT %s
// RUN: %clang_cc1 -triple=powerpc64-linux-gnu %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT %s
// RUN: %clang_cc1 -triple=systemz %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT %s

// Configs that have expensive unaligned access
// Little Endian
// RUN: %clang_cc1 -triple=amdgpu-elf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT %s
// RUN: %clang_cc1 -triple=arc-elf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT %s
// RUN: %clang_cc1 -triple=bpf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT %s
// RUN: %clang_cc1 -triple=csky %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT %s
// RUN: %clang_cc1 -triple=hexagon-elf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT %s
// RUN: %clang_cc1 -triple=loongarch32-elf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT %s
// RUN: %clang_cc1 -triple=nvptx-elf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT %s
// RUN: %clang_cc1 -triple=riscv32 %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT %s
// RUN: %clang_cc1 -triple=riscv64 %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT %s
// RUN: %clang_cc1 -triple=spir-elf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT %s
// RUN: %clang_cc1 -triple=xcore-none-elf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT %s

// Big endian
// RUN: %clang_cc1 -triple=lanai-elf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT %s
// RUN: %clang_cc1 -triple=m68k-elf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT-M68K %s
// RUN: %clang_cc1 -triple=mips-elf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT %s
// RUN: %clang_cc1 -triple=mips64-elf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT %s
// RUN: %clang_cc1 -triple=sparc-elf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT %s
// RUN: %clang_cc1 -triple=tce-elf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT %s

struct Empty {};

struct P1 {
  unsigned a : 16;
  [[no_unique_address]] Empty e;
  unsigned b : 16;
} p1;
// CHECK-LABEL: LLVMType:%struct.P1 =
// LAYOUT-SAME: type { i16, i16 }
// LAYOUT-DWN32-SAME: type { i16, i16 }
// LAYOUT-DWN32-M68K: type { i16, i16 }
// CHECK-NEXT: NonVirtualBaseLLVMType:%struct.P1 =
// CHECK: BitFields:[
// LAYOUT-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:16 IsSigned:0 StorageSize:16 StorageOffset:0
// LAYOUT-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:16 IsSigned:0 StorageSize:16 StorageOffset:2

// LAYOUT-DWN32-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:16 IsSigned:0 StorageSize:16 StorageOffset:0
// LAYOUT-DWN32-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:16 IsSigned:0 StorageSize:16 StorageOffset:2

// LAYOUT-M68K-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:16 IsSigned:0 StorageSize:16 StorageOffset:0
// LAYOUT-M68K-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:16 IsSigned:0 StorageSize:16 StorageOffset:2
// CHECK-NEXT: ]>

struct P2 {
  unsigned a : 15;
  [[no_unique_address]] Empty e;
  unsigned b : 15;
} p2;
// CHECK-LABEL: LLVMType:%struct.P2 =
// LAYOUT-SAME: type { i16, i16 }
// LAYOUT-DWN32-SAME: type { i16, i16 }
// LAYOUT-M68K-SAME: type { i16, i16 }
// CHECK-NEXT: NonVirtualBaseLLVMType:%struct.P2 =
// CHECK: BitFields:[
// LAYOUT-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:15 IsSigned:0 StorageSize:16 StorageOffset:0
// LAYOUT-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:15 IsSigned:0 StorageSize:16 StorageOffset:2

// LAYOUT-DWN32-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:15 IsSigned:0 StorageSize:16 StorageOffset:0
// LAYOUT-DWN32-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:15 IsSigned:0 StorageSize:16 StorageOffset:2

// LAYOUT-M68K-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:15 IsSigned:0 StorageSize:16 StorageOffset:0
// LAYOUT-M68K-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:15 IsSigned:0 StorageSize:16 StorageOffset:2
// CHECK-NEXT: ]>

struct P3 {
  unsigned a : 16;
  Empty e;
  unsigned b : 16;
} p3;
// CHECK-LABEL: LLVMType:%struct.P3 =
// LAYOUT-SAME: type { i16, [2 x i8], i16, [2 x i8] }
// LAYOUT-DWN32-SAME: type <{ i16, i8, i16 }>
// LAYOUT-M68K-SAME: type <{ i16, i8, i16, i8 }>
// CHECK-NEXT: NonVirtualBaseLLVMType:%struct.P3 =
// CHECK: BitFields:[
// LAYOUT-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:16 IsSigned:0 StorageSize:16 StorageOffset:0
// LAYOUT-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:16 IsSigned:0 StorageSize:16 StorageOffset:4

// LAYOUT-DWN32-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:16 IsSigned:0 StorageSize:16 StorageOffset:0
// LAYOUT-DWN32-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:16 IsSigned:0 StorageSize:16 StorageOffset:3

// LAYOUT-M68K-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:16 IsSigned:0 StorageSize:16 StorageOffset:0
// LAYOUT-M68K-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:16 IsSigned:0 StorageSize:16 StorageOffset:3
// CHECK-NEXT: ]>

struct P4 {
  unsigned : 0;
} p4;
// CHECK-LABEL: LLVMType:%struct.P4 =
// LAYOUT-SAME: type { {{.+}} }
// CHECK-NEXT: NonVirtualBaseLLVMType:%struct.P4 =
// CHECK: BitFields:[
// CHECK-NEXT: ]>

struct P5 {
  ~P5();
  unsigned : 0;
} p5;
// CHECK-LABEL: LLVMType:%struct.P5 =
// CHECK-NEXT: NonVirtualBaseLLVMType:%struct.P5.base = type {}
// CHECK: BitFields:[
// CHECK-NEXT: ]>

struct P6 {
  unsigned a : 16;
  unsigned b : 8;
  [[no_unique_address]] Empty e;
  unsigned c;
  long double ld_zero[4] = {0};
  __float128 q_arr[3] = {1.0, -2.0, 0.0};
  _Float16 h_arr[3] = {1.0, -2.0, 0.0};
  __bf16 bf_arr[3] = {1.0, -2.0, 0.0};
  float f_arr[3] = {1.0, -2.0, 0.0};
  double d_arr[3] = {1.0, -2.0, 0.0};

  // CIR-DAG: cir.global external @ld_arr = #cir.const_array<[#cir.fp<1.000000e+00> : !cir.long_double<!cir.f80>, #cir.fp<-2.000000e+00> : !cir.long_double<!cir.f80>], trailing_zeros> : !cir.array<!cir.long_double<!cir.f80> x 3>
  // CIR-DAG: cir.global external @ld_zero = #cir.zero : !cir.array<!cir.long_double<!cir.f80> x 4>
  // CIR-DAG: cir.global external @q_arr = #cir.const_array<[#cir.fp<1.000000e+00> : !cir.f128, #cir.fp<-2.000000e+00> : !cir.f128], trailing_zeros> : !cir.array<!cir.f128 x 3>
  // CIR-DAG: cir.global external @h_arr = #cir.const_array<[#cir.fp<1.000000e+00> : !cir.f16, #cir.fp<-2.000000e+00> : !cir.f16], trailing_zeros> : !cir.array<!cir.f16 x 3>
  // CIR-DAG: cir.global external @bf_arr = #cir.const_array<[#cir.fp<1.000000e+00> : !cir.bf16, #cir.fp<-2.000000e+00> : !cir.bf16], trailing_zeros> : !cir.array<!cir.bf16 x 3>
  // CIR-DAG: cir.global external @f_arr = #cir.const_array<[#cir.fp<1.000000e+00> : !cir.float, #cir.fp<-2.000000e+00> : !cir.float], trailing_zeros> : !cir.array<!cir.float x 3>
  // CIR-DAG: cir.global external @d_arr = #cir.const_array<[#cir.fp<1.000000e+00> : !cir.double, #cir.fp<-2.000000e+00> : !cir.double], trailing_zeros> : !cir.array<!cir.double x 3>

  // LLVM-DAG: @ld_arr = global [3 x x86_fp80] [x86_fp80 1.000000e+00, x86_fp80 -2.000000e+00, x86_fp80 0.000000e+00]
  // LLVM-DAG: @ld_zero = global [4 x x86_fp80] zeroinitializer
  // LLVM-DAG: @q_arr = global [3 x fp128] [fp128 1.000000e+00, fp128 -2.000000e+00, fp128 0.000000e+00]
  // LLVM-DAG: @h_arr = global [3 x half] [half 1.000000e+00, half -2.000000e+00, half 0.000000e+00]
  // LLVM-DAG: @bf_arr = global [3 x bfloat] [bfloat 1.000000e+00, bfloat -2.000000e+00, bfloat 0.000000e+00]
  // LLVM-DAG: @f_arr = global [3 x float] [float 1.000000e+00, float -2.000000e+00, float 0.000000e+00]
  // LLVM-DAG: @d_arr = global [3 x double] [double 1.000000e+00, double -2.000000e+00, double 0.000000e+00]
} p6;
// CHECK-LABEL: LLVMType:%struct.P6 =
// LAYOUT-SAME: type { i32, i32 }
// LAYOUT-DWN32-SAME: type { i32, i32 }
// LAYOUT-M68K-SAME: type { i32, i32 }
// CHECK-NEXT: NonVirtualBaseLLVMType:%struct.P6 =
// CHECK: BitFields:[
// LAYOUT-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:16 IsSigned:0 StorageSize:32 StorageOffset:0
// LAYOUT-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:8 IsSigned:0 StorageSize:32 StorageOffset:0

// LAYOUT-DWN32-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:16 IsSigned:0 StorageSize:32 StorageOffset:0
// LAYOUT-DWN32-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:8 IsSigned:0 StorageSize:32 StorageOffset:0

// LAYOUT-M68K-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:16 IsSigned:0 StorageSize:32 StorageOffset:0
// LAYOUT-M68K-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:8 IsSigned:0 StorageSize:32 StorageOffset:0
// CHECK-NEXT: ]>

struct P7 {
  unsigned a : 16;
  unsigned b : 8;
  Empty e;
  unsigned c;
} p7;
// CHECK-LABEL: LLVMType:%struct.P7 =
// LAYOUT-SAME: type { i32, i32 }
// LAYOUT-DWN32-SAME: type { i32, i32 }
// LAYOUT-M68K-SAME: type { i32, i32 }
// CHECK-NEXT: NonVirtualBaseLLVMType:%struct.P7 =
// CHECK: BitFields:[
// LAYOUT-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:16 IsSigned:0 StorageSize:32 StorageOffset:0
// LAYOUT-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:8 IsSigned:0 StorageSize:32 StorageOffset:0

// LAYOUT-DWN32-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:16 IsSigned:0 StorageSize:32 StorageOffset:0
// LAYOUT-DWN32-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:8 IsSigned:0 StorageSize:32 StorageOffset:0

// LAYOUT-M68K-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:16 IsSigned:0 StorageSize:32 StorageOffset:0
// LAYOUT-M68K-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:8 IsSigned:0 StorageSize:32 StorageOffset:0
// CHECK-NEXT: ]>
// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnu -fclangir -emit-cir %s -o %t.cir
// RUN: FileCheck --check-prefix=CIR --input-file=%t.cir %s
// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnu -fclangir -emit-llvm %s -o %t-cir.ll
// RUN: FileCheck --check-prefix=LLVM --input-file=%t-cir.ll %s
// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnu -emit-llvm %s -o %t.ll
// RUN: FileCheck --check-prefix=LLVM --input-file=%t.ll %s

long double ld_arr[3] = {1.0, -2.0, 0.0};
long double ld_zero[4] = {0};
__float128 q_arr[3] = {1.0, -2.0, 0.0};
_Float16 h_arr[3] = {1.0, -2.0, 0.0};
__bf16 bf_arr[3] = {1.0, -2.0, 0.0};
float f_arr[3] = {1.0, -2.0, 0.0};
double d_arr[3] = {1.0, -2.0, 0.0};

// CIR-DAG: cir.global external @ld_arr = #cir.const_array<[#cir.fp<1.000000e+00> : !cir.long_double<!cir.f80>, #cir.fp<-2.000000e+00> : !cir.long_double<!cir.f80>], trailing_zeros> : !cir.array<!cir.long_double<!cir.f80> x 3>
// CIR-DAG: cir.global external @ld_zero = #cir.zero : !cir.array<!cir.long_double<!cir.f80> x 4>
// CIR-DAG: cir.global external @q_arr = #cir.const_array<[#cir.fp<1.000000e+00> : !cir.f128, #cir.fp<-2.000000e+00> : !cir.f128], trailing_zeros> : !cir.array<!cir.f128 x 3>
// CIR-DAG: cir.global external @h_arr = #cir.const_array<[#cir.fp<1.000000e+00> : !cir.f16, #cir.fp<-2.000000e+00> : !cir.f16], trailing_zeros> : !cir.array<!cir.f16 x 3>
// CIR-DAG: cir.global external @bf_arr = #cir.const_array<[#cir.fp<1.000000e+00> : !cir.bf16, #cir.fp<-2.000000e+00> : !cir.bf16], trailing_zeros> : !cir.array<!cir.bf16 x 3>
// CIR-DAG: cir.global external @f_arr = #cir.const_array<[#cir.fp<1.000000e+00> : !cir.float, #cir.fp<-2.000000e+00> : !cir.float], trailing_zeros> : !cir.array<!cir.float x 3>
// CIR-DAG: cir.global external @d_arr = #cir.const_array<[#cir.fp<1.000000e+00> : !cir.double, #cir.fp<-2.000000e+00> : !cir.double], trailing_zeros> : !cir.array<!cir.double x 3>

// LLVM-DAG: @ld_arr = global [3 x x86_fp80] [x86_fp80 1.000000e+00, x86_fp80 -2.000000e+00, x86_fp80 0.000000e+00]
// LLVM-DAG: @ld_zero = global [4 x x86_fp80] zeroinitializer
// LLVM-DAG: @q_arr = global [3 x fp128] [fp128 1.000000e+00, fp128 -2.000000e+00, fp128 0.000000e+00]
// LLVM-DAG: @h_arr = global [3 x half] [half 1.000000e+00, half -2.000000e+00, half 0.000000e+00]
// LLVM-DAG: @bf_arr = global [3 x bfloat] [bfloat 1.000000e+00, bfloat -2.000000e+00, bfloat 0.000000e+00]
// LLVM-DAG: @f_arr = global [3 x float] [float 1.000000e+00, float -2.000000e+00, float 0.000000e+00]
// LLVM-DAG: @d_arr = global [3 x double] [double 1.000000e+00, double -2.000000e+00, double 0.000000e+00]
