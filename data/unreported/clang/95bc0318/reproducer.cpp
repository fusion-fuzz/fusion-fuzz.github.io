// expected-no-diagnostics
#ifndef HEADER
#define HEADER

///==========================================================================///
// RUN: %clang_cc1 -DCK30 -verify -fopenmp -fopenmp-targets=powerpc64le-ibm-linux-gnu -x c++ -triple powerpc64le-unknown-unknown -emit-llvm %s -o - | FileCheck -allow-deprecated-dag-overlap  %s --check-prefix CK30 --check-prefix CK30-64
// RUN: %clang_cc1 -DCK30 -fopenmp -fopenmp-targets=powerpc64le-ibm-linux-gnu -x c++ -std=c++11 -triple powerpc64le-unknown-unknown -emit-pch -o %t %s
// RUN: %clang_cc1 -fopenmp -fopenmp-targets=powerpc64le-ibm-linux-gnu -x c++ -triple powerpc64le-unknown-unknown -std=c++11 -include-pch %t -verify %s -emit-llvm -o - | FileCheck -allow-deprecated-dag-overlap  %s  --check-prefix CK30 --check-prefix CK30-64
// RUN: %clang_cc1 -DCK30 -verify -fopenmp -fopenmp-targets=i386-pc-linux-gnu -x c++ -triple i386-unknown-unknown -emit-llvm %s -o - | FileCheck -allow-deprecated-dag-overlap  %s  --check-prefix CK30 --check-prefix CK30-32
// RUN: %clang_cc1 -DCK30 -fopenmp -fopenmp-targets=i386-pc-linux-gnu -x c++ -std=c++11 -triple i386-unknown-unknown -emit-pch -o %t %s
// RUN: %clang_cc1 -fopenmp -fopenmp-targets=i386-pc-linux-gnu -x c++ -triple i386-unknown-unknown -std=c++11 -include-pch %t -verify %s -emit-llvm -o - | FileCheck -allow-deprecated-dag-overlap  %s  --check-prefix CK30 --check-prefix CK30-32

// RUN: %clang_cc1 -DCK30 -verify -fopenmp -fopenmp-version=45 -fopenmp-targets=powerpc64le-ibm-linux-gnu -x c++ -triple powerpc64le-unknown-unknown -emit-llvm %s -o - | FileCheck -allow-deprecated-dag-overlap  %s --check-prefix CK30 --check-prefix CK30-64
// RUN: %clang_cc1 -DCK30 -fopenmp -fopenmp-version=45 -fopenmp-targets=powerpc64le-ibm-linux-gnu -x c++ -std=c++11 -triple powerpc64le-unknown-unknown -emit-pch -o %t %s
// RUN: %clang_cc1 -fopenmp -fopenmp-version=45 -fopenmp-targets=powerpc64le-ibm-linux-gnu -x c++ -triple powerpc64le-unknown-unknown -std=c++11 -include-pch %t -verify %s -emit-llvm -o - | FileCheck -allow-deprecated-dag-overlap  %s  --check-prefix CK30 --check-prefix CK30-64
// RUN: %clang_cc1 -DCK30 -verify -fopenmp -fopenmp-version=45 -fopenmp-targets=i386-pc-linux-gnu -x c++ -triple i386-unknown-unknown -emit-llvm %s -o - | FileCheck -allow-deprecated-dag-overlap  %s  --check-prefix CK30 --check-prefix CK30-32
// RUN: %clang_cc1 -DCK30 -fopenmp -fopenmp-version=45 -fopenmp-targets=i386-pc-linux-gnu -x c++ -std=c++11 -triple i386-unknown-unknown -emit-pch -o %t %s
// RUN: %clang_cc1 -fopenmp -fopenmp-version=45 -fopenmp-targets=i386-pc-linux-gnu -x c++ -triple i386-unknown-unknown -std=c++11 -include-pch %t -verify %s -emit-llvm -o - | FileCheck -allow-deprecated-dag-overlap  %s  --check-prefix CK30 --check-prefix CK30-32

// RUN: %clang_cc1 -DCK30 -verify -fopenmp -fopenmp-version=50 -fopenmp-targets=powerpc64le-ibm-linux-gnu -x c++ -triple powerpc64le-unknown-unknown -emit-llvm %s -o - | FileCheck -allow-deprecated-dag-overlap  %s --check-prefix CK30 --check-prefix CK30-64
// RUN: %clang_cc1 -DCK30 -fopenmp -fopenmp-version=50 -fopenmp-targets=powerpc64le-ibm-linux-gnu -x c++ -std=c++11 -triple powerpc64le-unknown-unknown -emit-pch -o %t %s
// RUN: %clang_cc1 -fopenmp -fopenmp-version=50 -fopenmp-targets=powerpc64le-ibm-linux-gnu -x c++ -triple powerpc64le-unknown-unknown -std=c++11 -include-pch %t -verify %s -emit-llvm -o - | FileCheck -allow-deprecated-dag-overlap  %s  --check-prefix CK30 --check-prefix CK30-64
// RUN: %clang_cc1 -DCK30 -verify -fopenmp -fopenmp-version=50 -fopenmp-targets=i386-pc-linux-gnu -x c++ -triple i386-unknown-unknown -emit-llvm %s -o - | FileCheck -allow-deprecated-dag-overlap  %s  --check-prefix CK30 --check-prefix CK30-32
// RUN: %clang_cc1 -DCK30 -fopenmp -fopenmp-version=50 -fopenmp-targets=i386-pc-linux-gnu -x c++ -std=c++11 -triple i386-unknown-unknown -emit-pch -o %t %s
// RUN: %clang_cc1 -fopenmp -fopenmp-version=50 -fopenmp-targets=i386-pc-linux-gnu -x c++ -triple i386-unknown-unknown -std=c++11 -include-pch %t -verify %s -emit-llvm -o - | FileCheck -allow-deprecated-dag-overlap  %s  --check-prefix CK30 --check-prefix CK30-32

// RUN: %clang_cc1 -DCK30 -verify -fopenmp-simd -fopenmp-targets=powerpc64le-ibm-linux-gnu -x c++ -triple powerpc64le-unknown-unknown -emit-llvm %s -o - | FileCheck -allow-deprecated-dag-overlap  --check-prefix SIMD-ONLY30 %s
// RUN: %clang_cc1 -DCK30 -fopenmp-simd -fopenmp-targets=powerpc64le-ibm-linux-gnu -x c++ -std=c++11 -triple powerpc64le-unknown-unknown -emit-pch -o %t %s
// RUN: %clang_cc1 -fopenmp-simd -fopenmp-targets=powerpc64le-ibm-linux-gnu -x c++ -triple powerpc64le-unknown-unknown -std=c++11 -include-pch %t -verify %s -emit-llvm -o - | FileCheck -allow-deprecated-dag-overlap  --check-prefix SIMD-ONLY30 %s
// RUN: %clang_cc1 -DCK30 -verify -fopenmp-simd -fopenmp-targets=i386-pc-linux-gnu -x c++ -triple i386-unknown-unknown -emit-llvm %s -o - | FileCheck -allow-deprecated-dag-overlap  --check-prefix SIMD-ONLY30 %s
// RUN: %clang_cc1 -DCK30 -fopenmp-simd -fopenmp-targets=i386-pc-linux-gnu -x c++ -std=c++11 -triple i386-unknown-unknown -emit-pch -o %t %s
// RUN: %clang_cc1 -fopenmp-simd -fopenmp-targets=i386-pc-linux-gnu -x c++ -triple i386-unknown-unknown -std=c++11 -include-pch %t -verify %s -emit-llvm -o - | FileCheck -allow-deprecated-dag-overlap  --check-prefix SIMD-ONLY30 %s
// SIMD-ONLY30-NOT: {{__kmpc|__tgt}}
#ifdef CK30

// CK30-DAG: [[BASE:%.+]] = type { ptr, i32, ptr }
// CK30-DAG: [[STRUCT:%.+]] = type { [[BASE]], ptr, ptr, i32, ptr }

// &s,             &s,             sizeof(s),             TO | FROM | PARAM
// &s.ptr1[0],     &s.ptr1[0],     sizeof(s.ptr1[0]),     TO | FROM
// &s.ptr1,        &s.ptr1[0],     sizeof(void*),         ATTACH
// &s.ptrBase1[0], &s.ptrBase1[0], sizeof(s.ptrBase1[0]), TO | FROM
// &s.ptrBase1,    &s.ptrBase1[0], sizeof(void*),         ATTACH

// CK30-LABEL: @.__omp_offloading_{{.*}}map_with_deep_copy{{.*}}_l{{[0-9]+}}.region_id = weak constant i8 0
// CK30: [[SIZE00:@.+]] = private unnamed_addr constant [6 x i64] [i64 {{56|28}}, i64 4, i64 {{4|8}}, i64 4, i64 {{4|8}}, i64 0]
// CK30: [[MTYPE00:@.+]] = private unnamed_addr constant [6 x i64] [i64 [[#0x23]], i64 3, i64 [[#0x4000]], i64 3, i64 [[#0x4000]], i64 288]



// CK30-DAG: call i32 @__tgt_target_kernel(ptr @{{.+}}, i64 -1, i32 -1, i32 0, ptr @.{{.+}}.region_id, ptr [[ARGS:%.+]])
// CK30-DAG: [[BPARG:%.+]] = getelementptr inbounds {{.+}}[[ARGS]], i32 0, i32 2
// CK30-DAG: store ptr [[BPGEP:%.+]], ptr [[BPARG]]
// CK30-DAG: [[PARG:%.+]] = getelementptr inbounds {{.+}}[[ARGS]], i32 0, i32 3
// CK30-DAG: store ptr [[PGEP:%.+]], ptr [[PARG]]
// CK30-DAG: [[PGEP]] = getelementptr inbounds [6 x ptr], ptr [[PTRS:%.+]], i32 0, i32 0
// CK30-DAG: [[BPGEP]] = getelementptr inbounds [6 x ptr], ptr [[BASES:%.+]], i32 0, i32 0

// CK30-DAG: [[BASE_PTR:%.+]] = getelementptr inbounds [6 x ptr], ptr [[BASES]], i32 0, i32 0
// CK30-DAG: store ptr [[S:%.+]], ptr [[BASE_PTR]],
// CK30-DAG: [[PTR:%.+]] = getelementptr inbounds [6 x ptr], ptr [[PTRS]], i32 0, i32 0
// CK30-DAG: store ptr [[S]], ptr [[PTR]],

// CK30-DAG: [[BASE_PTR:%.+]] = getelementptr inbounds [6 x ptr], ptr [[BASES]], i32 0, i32 1
// CK30-DAG: [[PTR:%.+]] = getelementptr inbounds [6 x ptr], ptr [[PTRS]], i32 0, i32 1
// CK30-DAG: store ptr [[S_PTR1_REF:%.+]], ptr [[BASE_PTR]],
// CK30-DAG: store ptr [[S_PTR1_BEGIN:%.+]], ptr [[PTR]],
// CK30-DAG: [[S_PTR1_REF]] = load ptr, ptr [[S_PTR1:%.+]],
// CK30-DAG: [[S_PTR1]] = getelementptr inbounds nuw [[STRUCT]], ptr [[S]], i32 0, i32 4
// CK30-DAG: [[S_PTR1_BEGIN]] = getelementptr inbounds nuw i32, ptr [[S_PTR1_REF1:%.+]], i{{64|32}} 0
// CK30-DAG: [[S_PTR1_REF1]] = load ptr, ptr [[S_PTR11:%.+]],
// CK30-DAG: [[S_PTR11]] = getelementptr inbounds nuw [[STRUCT]], ptr [[S]], i32 0, i32 4

// CK30-DAG: [[BASE_PTR:%.+]] = getelementptr inbounds [6 x ptr], ptr [[BASES]], i32 0, i32 2
// CK30-DAG: [[PTR:%.+]] = getelementptr inbounds [6 x ptr], ptr [[PTRS]], i32 0, i32 2
// CK30-DAG: store ptr [[S_PTR1]], ptr [[BASE_PTR]],
// CK30-DAG: store ptr [[S_PTR1_BEGIN]], ptr [[PTR]],

// CK30-DAG: [[BASE_PTR:%.+]] = getelementptr inbounds [6 x ptr], ptr [[BASES]], i32 0, i32 3
// CK30-DAG: [[PTR:%.+]] = getelementptr inbounds [6 x ptr], ptr [[PTRS]], i32 0, i32 3
// CK30-DAG: store ptr [[S_PTRBASE1_REF:%.+]], ptr [[BASE_PTR]],
// CK30-DAG: store ptr [[S_PTRBASE1_BEGIN:%.+]], ptr [[PTR]],
// CK30-DAG: [[S_PTRBASE1_REF]] = load ptr, ptr [[S_PTRBASE1:%.+]],
// CK30-DAG: [[S_PTRBASE1]] = getelementptr inbounds nuw [[BASE]], ptr [[S_BASE:%.+]], i32 0, i32 2
// CK30-DAG: [[S_PTRBASE1_BEGIN]] = getelementptr inbounds nuw i32, ptr [[S_PTRBASE1_REF1:%.+]], i{{64|32}} 0
// CK30-DAG: [[S_PTRBASE1_REF1]] = load ptr, ptr [[S_PTRBASE11:%.+]],
// CK30-DAG: [[S_PTRBASE11]] = getelementptr inbounds nuw [[BASE]], ptr [[S_BASE:%.+]], i32 0, i32 2

// CK30-DAG: [[BASE_PTR:%.+]] = getelementptr inbounds [6 x ptr], ptr [[BASES]], i32 0, i32 4
// CK30-DAG: [[PTR:%.+]] = getelementptr inbounds [6 x ptr], ptr [[PTRS]], i32 0, i32 4
// CK30-DAG: store ptr [[S_PTRBASE1]], ptr [[BASE_PTR]],
// CK30-DAG: store ptr [[S_PTRBASE1_BEGIN]], ptr [[PTR]],


#endif // CK30
#endif

// expected-no-diagnostics
#ifndef HEADER
#define HEADER

///==========================================================================///
// RUN: %clang_cc1 -DCK30 -verify -fopenmp -fopenmp-targets=powerpc64le-ibm-linux-gnu -x c++ -triple powerpc64le-unknown-unknown -emit-llvm %s -o - | FileCheck -allow-deprecated-dag-overlap  %s --check-prefix CK30 --check-prefix CK30-64
// RUN: %clang_cc1 -DCK30 -fopenmp -fopenmp-targets=powerpc64le-ibm-linux-gnu -x c++ -std=c++11 -triple powerpc64le-unknown-unknown -emit-pch -o %t %s
// RUN: %clang_cc1 -fopenmp -fopenmp-targets=powerpc64le-ibm-linux-gnu -x c++ -triple powerpc64le-unknown-unknown -std=c++11 -include-pch %t -verify %s -emit-llvm -o - | FileCheck -allow-deprecated-dag-overlap  %s  --check-prefix CK30 --check-prefix CK30-64
// RUN: %clang_cc1 -DCK30 -verify -fopenmp -fopenmp-targets=i386-pc-linux-gnu -x c++ -triple i386-unknown-unknown -emit-llvm %s -o - | FileCheck -allow-deprecated-dag-overlap  %s  --check-prefix CK30 --check-prefix CK30-32
// RUN: %clang_cc1 -DCK30 -fopenmp -fopenmp-targets=i386-pc-linux-gnu -x c++ -std=c++11 -triple i386-unknown-unknown -emit-pch -o %t %s
// RUN: %clang_cc1 -fopenmp -fopenmp-targets=i386-pc-linux-gnu -x c++ -triple i386-unknown-unknown -std=c++11 -include-pch %t -verify %s -emit-llvm -o - | FileCheck -allow-deprecated-dag-overlap  %s  --check-prefix CK30 --check-prefix CK30-32

// RUN: %clang_cc1 -DCK30 -verify -fopenmp -fopenmp-version=45 -fopenmp-targets=powerpc64le-ibm-linux-gnu -x c++ -triple powerpc64le-unknown-unknown -emit-llvm %s -o - | FileCheck -allow-deprecated-dag-overlap  %s --check-prefix CK30 --check-prefix CK30-64
// RUN: %clang_cc1 -DCK30 -fopenmp -fopenmp-version=45 -fopenmp-targets=powerpc64le-ibm-linux-gnu -x c++ -std=c++11 -triple powerpc64le-unknown-unknown -emit-pch -o %t %s
// RUN: %clang_cc1 -fopenmp -fopenmp-version=45 -fopenmp-targets=powerpc64le-ibm-linux-gnu -x c++ -triple powerpc64le-unknown-unknown -std=c++11 -include-pch %t -verify %s -emit-llvm -o - | FileCheck -allow-deprecated-dag-overlap  %s  --check-prefix CK30 --check-prefix CK30-64
// RUN: %clang_cc1 -DCK30 -verify -fopenmp -fopenmp-version=45 -fopenmp-targets=i386-pc-linux-gnu -x c++ -triple i386-unknown-unknown -emit-llvm %s -o - | FileCheck -allow-deprecated-dag-overlap  %s  --check-prefix CK30 --check-prefix CK30-32
// RUN: %clang_cc1 -DCK30 -fopenmp -fopenmp-version=45 -fopenmp-targets=i386-pc-linux-gnu -x c++ -std=c++11 -triple i386-unknown-unknown -emit-pch -o %t %s
// RUN: %clang_cc1 -fopenmp -fopenmp-version=45 -fopenmp-targets=i386-pc-linux-gnu -x c++ -triple i386-unknown-unknown -std=c++11 -include-pch %t -verify %s -emit-llvm -o - | FileCheck -allow-deprecated-dag-overlap  %s  --check-prefix CK30 --check-prefix CK30-32

// RUN: %clang_cc1 -DCK30 -verify -fopenmp -fopenmp-version=50 -fopenmp-targets=powerpc64le-ibm-linux-gnu -x c++ -triple powerpc64le-unknown-unknown -emit-llvm %s -o - | FileCheck -allow-deprecated-dag-overlap  %s --check-prefix CK30 --check-prefix CK30-64
// RUN: %clang_cc1 -DCK30 -fopenmp -fopenmp-version=50 -fopenmp-targets=powerpc64le-ibm-linux-gnu -x c++ -std=c++11 -triple powerpc64le-unknown-unknown -emit-pch -o %t %s
// RUN: %clang_cc1 -fopenmp -fopenmp-version=50 -fopenmp-targets=powerpc64le-ibm-linux-gnu -x c++ -triple powerpc64le-unknown-unknown -std=c++11 -include-pch %t -verify %s -emit-llvm -o - | FileCheck -allow-deprecated-dag-overlap  %s  --check-prefix CK30 --check-prefix CK30-64
// RUN: %clang_cc1 -DCK30 -verify -fopenmp -fopenmp-version=50 -fopenmp-targets=i386-pc-linux-gnu -x c++ -triple i386-unknown-unknown -emit-llvm %s -o - | FileCheck -allow-deprecated-dag-overlap  %s  --check-prefix CK30 --check-prefix CK30-32
// RUN: %clang_cc1 -DCK30 -fopenmp -fopenmp-version=50 -fopenmp-targets=i386-pc-linux-gnu -x c++ -std=c++11 -triple i386-unknown-unknown -emit-pch -o %t %s
// RUN: %clang_cc1 -fopenmp -fopenmp-version=50 -fopenmp-targets=i386-pc-linux-gnu -x c++ -triple i386-unknown-unknown -std=c++11 -include-pch %t -verify %s -emit-llvm -o - | FileCheck -allow-deprecated-dag-overlap  %s  --check-prefix CK30 --check-prefix CK30-32

// RUN: %clang_cc1 -DCK30 -verify -fopenmp-simd -fopenmp-targets=powerpc64le-ibm-linux-gnu -x c++ -triple powerpc64le-unknown-unknown -emit-llvm %s -o - | FileCheck -allow-deprecated-dag-overlap  --check-prefix SIMD-ONLY30 %s
// RUN: %clang_cc1 -DCK30 -fopenmp-simd -fopenmp-targets=powerpc64le-ibm-linux-gnu -x c++ -std=c++11 -triple powerpc64le-unknown-unknown -emit-pch -o %t %s
// RUN: %clang_cc1 -fopenmp-simd -fopenmp-targets=powerpc64le-ibm-linux-gnu -x c++ -triple powerpc64le-unknown-unknown -std=c++11 -include-pch %t -verify %s -emit-llvm -o - | FileCheck -allow-deprecated-dag-overlap  --check-prefix SIMD-ONLY30 %s
// RUN: %clang_cc1 -DCK30 -verify -fopenmp-simd -fopenmp-targets=i386-pc-linux-gnu -x c++ -triple i386-unknown-unknown -emit-llvm %s -o - | FileCheck -allow-deprecated-dag-overlap  --check-prefix SIMD-ONLY30 %s
// RUN: %clang_cc1 -DCK30 -fopenmp-simd -fopenmp-targets=i386-pc-linux-gnu -x c++ -std=c++11 -triple i386-unknown-unknown -emit-pch -o %t %s
// RUN: %clang_cc1 -fopenmp-simd -fopenmp-targets=i386-pc-linux-gnu -x c++ -triple i386-unknown-unknown -std=c++11 -include-pch %t -verify %s -emit-llvm -o - | FileCheck -allow-deprecated-dag-overlap  --check-prefix SIMD-ONLY30 %s
// SIMD-ONLY30-NOT: {{__kmpc|__tgt}}
#ifdef CK30

// CK30-DAG: [[BASE:%.+]] = type { ptr, i32, ptr }
// CK30-DAG: [[STRUCT:%.+]] = type { [[BASE]], ptr, ptr, i32, ptr }

// &s,             &s,             sizeof(s),             TO | FROM | PARAM
// &s.ptr1[0],     &s.ptr1[0],     sizeof(s.ptr1[0]),     TO | FROM
// &s.ptr1,        &s.ptr1[0],     sizeof(void*),         ATTACH
// &s.ptrBase1[0], &s.ptrBase1[0], sizeof(s.ptrBase1[0]), TO | FROM
// &s.ptrBase1,    &s.ptrBase1[0], sizeof(void*),         ATTACH

// CK30-LABEL: @.__omp_offloading_{{.*}}map_with_deep_copy{{.*}}_l{{[0-9]+}}.region_id = weak constant i8 0
// CK30: [[SIZE00:@.+]] = private unnamed_addr constant [6 x i64] [i64 {{56|28}}, i64 4, i64 {{4|8}}, i64 4, i64 {{4|8}}, i64 0]
// CK30: [[MTYPE00:@.+]] = private unnamed_addr constant [6 x i64] [i64 [[#0x23]], i64 3, i64 [[#0x4000]], i64 3, i64 [[#0x4000]], i64 288]

typedef struct {
  int *ptrBase;
  int valBase;
  int *ptrBase1;
} Base;

typedef struct StructWithPtrTag : public Base {
  int *ptr;
  int *ptr2;
  int val;
  int *ptr1;
} StructWithPtr;

// CK30-DAG: call i32 @__tgt_target_kernel(ptr @{{.+}}, i64 -1, i32 -1, i32 0, ptr @.{{.+}}.region_id, ptr [[ARGS:%.+]])
// CK30-DAG: [[BPARG:%.+]] = getelementptr inbounds {{.+}}[[ARGS]], i32 0, i32 2
// CK30-DAG: store ptr [[BPGEP:%.+]], ptr [[BPARG]]
// CK30-DAG: [[PARG:%.+]] = getelementptr inbounds {{.+}}[[ARGS]], i32 0, i32 3
// CK30-DAG: store ptr [[PGEP:%.+]], ptr [[PARG]]
// CK30-DAG: [[PGEP]] = getelementptr inbounds [6 x ptr], ptr [[PTRS:%.+]], i32 0, i32 0
// CK30-DAG: [[BPGEP]] = getelementptr inbounds [6 x ptr], ptr [[BASES:%.+]], i32 0, i32 0

// CK30-DAG: [[BASE_PTR:%.+]] = getelementptr inbounds [6 x ptr], ptr [[BASES]], i32 0, i32 0
// CK30-DAG: store ptr [[S:%.+]], ptr [[BASE_PTR]],
// CK30-DAG: [[PTR:%.+]] = getelementptr inbounds [6 x ptr], ptr [[PTRS]], i32 0, i32 0
// CK30-DAG: store ptr [[S]], ptr [[PTR]],

// CK30-DAG: [[BASE_PTR:%.+]] = getelementptr inbounds [6 x ptr], ptr [[BASES]], i32 0, i32 1
// CK30-DAG: [[PTR:%.+]] = getelementptr inbounds [6 x ptr], ptr [[PTRS]], i32 0, i32 1
// CK30-DAG: store ptr [[S_PTR1_REF:%.+]], ptr [[BASE_PTR]],
// CK30-DAG: store ptr [[S_PTR1_BEGIN:%.+]], ptr [[PTR]],
// CK30-DAG: [[S_PTR1_REF]] = load ptr, ptr [[S_PTR1:%.+]],
// CK30-DAG: [[S_PTR1]] = getelementptr inbounds nuw [[STRUCT]], ptr [[S]], i32 0, i32 4
// CK30-DAG: [[S_PTR1_BEGIN]] = getelementptr inbounds nuw i32, ptr [[S_PTR1_REF1:%.+]], i{{64|32}} 0
// CK30-DAG: [[S_PTR1_REF1]] = load ptr, ptr [[S_PTR11:%.+]],
// CK30-DAG: [[S_PTR11]] = getelementptr inbounds nuw [[STRUCT]], ptr [[S]], i32 0, i32 4

// CK30-DAG: [[BASE_PTR:%.+]] = getelementptr inbounds [6 x ptr], ptr [[BASES]], i32 0, i32 2
// CK30-DAG: [[PTR:%.+]] = getelementptr inbounds [6 x ptr], ptr [[PTRS]], i32 0, i32 2
// CK30-DAG: store ptr [[S_PTR1]], ptr [[BASE_PTR]],
// CK30-DAG: store ptr [[S_PTR1_BEGIN]], ptr [[PTR]],

// CK30-DAG: [[BASE_PTR:%.+]] = getelementptr inbounds [6 x ptr], ptr [[BASES]], i32 0, i32 3
// CK30-DAG: [[PTR:%.+]] = getelementptr inbounds [6 x ptr], ptr [[PTRS]], i32 0, i32 3
// CK30-DAG: store ptr [[S_PTRBASE1_REF:%.+]], ptr [[BASE_PTR]],
// CK30-DAG: store ptr [[S_PTRBASE1_BEGIN:%.+]], ptr [[PTR]],
// CK30-DAG: [[S_PTRBASE1_REF]] = load ptr, ptr [[S_PTRBASE1:%.+]],
// CK30-DAG: [[S_PTRBASE1]] = getelementptr inbounds nuw [[BASE]], ptr [[S_BASE:%.+]], i32 0, i32 2
// CK30-DAG: [[S_PTRBASE1_BEGIN]] = getelementptr inbounds nuw i32, ptr [[S_PTRBASE1_REF1:%.+]], i{{64|32}} 0
// CK30-DAG: [[S_PTRBASE1_REF1]] = load ptr, ptr [[S_PTRBASE11:%.+]],
// CK30-DAG: [[S_PTRBASE11]] = getelementptr inbounds nuw [[BASE]], ptr [[S_BASE:%.+]], i32 0, i32 2

// CK30-DAG: [[BASE_PTR:%.+]] = getelementptr inbounds [6 x ptr], ptr [[BASES]], i32 0, i32 4
// CK30-DAG: [[PTR:%.+]] = getelementptr inbounds [6 x ptr], ptr [[PTRS]], i32 0, i32 4
// CK30-DAG: store ptr [[S_PTRBASE1]], ptr [[BASE_PTR]],
// CK30-DAG: store ptr [[S_PTRBASE1_BEGIN]], ptr [[PTR]],

void map_with_deep_copy() {
  StructWithPtr s;
#pragma omp target map(s, s.ptr1 [0:1], s.ptrBase1 [0:1])
  {
    s.val++;
    s.ptr1[0]++;
    s.ptrBase1[0] = 10001;
  }
}

#endif // CK30
#endif

// RUN: %clang_cc1 -fsyntax-only -verify %s
// RUN: %clang_cc1 -fsyntax-only -verify -std=c++98 %s
// RUN: %clang_cc1 -fsyntax-only -verify -std=c++11 %s
template<typename T> struct vector;
// C++ [temp.class.spec]p6:
namespace N {
  namespace M {
    template<typename T> struct A;
  }
}
template<typename T>
struct N::M::A<T*> { }
;
// C++ [temp.class.spec]p9
//   bullet 1, as amended by DR1315
template <int I, int J> struct A {}
;
template <int I> struct A<I+5, I*2> {}
;
// expected-error{{cannot be deduced}} expected-note {{'I'}}
template <int I, int J, typename _FflDeclT = StructWithPtrTag> struct B {}
;
template <int I> struct B<I, I> {}
;
//OK 

//   bullet 2
template <class T, T t> struct C {}
;
// expected-note{{declared here}}
template <class T> struct C<T, 1>;
// expected-error{{specializes}}
template <class T, T* t> struct C<T*, t>;
// okay

template< int X, int (*array_ptr)[HEADER] > class A2 {}
;
// expected-note{{here}}
int array[5];
template< int X > class A2<X, &array> { }
;
// expected-error{{specializes}}

template<typename T, int N, template<typename X> class TT>
struct Test0;
//   bullet 3
template<typename T, int N, template<typename X> class TT>
struct Test0<T, N, TT>;
// expected-error{{does not specialize}}

// C++ [temp.class.spec]p10
template<typename T = int, // expected-error{{default template argument}}
         int N = 17, // expected-error{{default template argument}}
         template<typename X> class TT = ::vector> // expected-error{{default template argument}}
  struct Test0<T*, N, TT> { }
;
template<typename T> struct Test1;
template<typename T, typename U>  // expected-note{{non-deducible}}
  struct Test1<T*> { }
;
// expected-error{{never be used}}
