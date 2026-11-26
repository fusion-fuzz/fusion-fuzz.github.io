#include "Inputs/stdio.h"
#include <riscv_vector.h>
#include <stdint.h>
// RUN: %clang_cc1 -triple x86_64-unknown-unknown -emit-llvm %s -o - | FileCheck %s




// CHECK-DAG: @[[STR_0:.*]] = private unnamed_addr constant [3 x i8] c"%s\00",
// CHECK-DAG: @[[STR_1:.*]] = private unnamed_addr constant [9 x i8] c"struct A\00",
// CHECK-DAG: @[[STR_2:.*]] = private unnamed_addr constant [4 x i8] c" {\0A\00",
// CHECK-DAG: @[[STR_4:.*]] = private unnamed_addr constant [3 x i8] c"  \00",
// CHECK-DAG: @[[STR_5:.*]] = private unnamed_addr constant [5 x i8] c"char\00",
// CHECK-DAG: @[[STR_6:.*]] = private unnamed_addr constant [3 x i8] c"i1\00",
// CHECK-DAG: @[[STR_7:.*]] = private unnamed_addr constant [16 x i8] c"%s%s %s = %hhd\0A\00",
// CHECK-DAG: @[[STR_8:.*]] = private unnamed_addr constant [12 x i8] c"signed char\00",
// CHECK-DAG: @[[STR_9:.*]] = private unnamed_addr constant [3 x i8] c"i2\00",
// CHECK-DAG: @[[STR_10:.*]] = private unnamed_addr constant [16 x i8] c"%s%s %s = %hhu\0A\00",
// CHECK-DAG: @[[STR_11:.*]] = private unnamed_addr constant [14 x i8] c"unsigned char\00",
// CHECK-DAG: @[[STR_12:.*]] = private unnamed_addr constant [3 x i8] c"i3\00",
// CHECK-DAG: @[[STR_13:.*]] = private unnamed_addr constant [15 x i8] c"%s%s %s = %hd\0A\00",
// CHECK-DAG: @[[STR_14:.*]] = private unnamed_addr constant [6 x i8] c"short\00",
// CHECK-DAG: @[[STR_15:.*]] = private unnamed_addr constant [3 x i8] c"i4\00",
// CHECK-DAG: @[[STR_16:.*]] = private unnamed_addr constant [15 x i8] c"%s%s %s = %hu\0A\00",
// CHECK-DAG: @[[STR_17:.*]] = private unnamed_addr constant [15 x i8] c"unsigned short\00",
// CHECK-DAG: @[[STR_18:.*]] = private unnamed_addr constant [3 x i8] c"i5\00",
// CHECK-DAG: @[[STR_19:.*]] = private unnamed_addr constant [14 x i8] c"%s%s %s = %d\0A\00",
// CHECK-DAG: @[[STR_20:.*]] = private unnamed_addr constant [4 x i8] c"int\00",
// CHECK-DAG: @[[STR_21:.*]] = private unnamed_addr constant [3 x i8] c"i6\00",
// CHECK-DAG: @[[STR_22:.*]] = private unnamed_addr constant [14 x i8] c"%s%s %s = %u\0A\00",
// CHECK-DAG: @[[STR_23:.*]] = private unnamed_addr constant [13 x i8] c"unsigned int\00",
// CHECK-DAG: @[[STR_24:.*]] = private unnamed_addr constant [3 x i8] c"i7\00",
// CHECK-DAG: @[[STR_25:.*]] = private unnamed_addr constant [15 x i8] c"%s%s %s = %ld\0A\00",
// CHECK-DAG: @[[STR_26:.*]] = private unnamed_addr constant [5 x i8] c"long\00",
// CHECK-DAG: @[[STR_27:.*]] = private unnamed_addr constant [3 x i8] c"i8\00",
// CHECK-DAG: @[[STR_28:.*]] = private unnamed_addr constant [15 x i8] c"%s%s %s = %lu\0A\00",
// CHECK-DAG: @[[STR_29:.*]] = private unnamed_addr constant [14 x i8] c"unsigned long\00",
// CHECK-DAG: @[[STR_30:.*]] = private unnamed_addr constant [3 x i8] c"i9\00",
// CHECK-DAG: @[[STR_31:.*]] = private unnamed_addr constant [16 x i8] c"%s%s %s = %lld\0A\00",
// CHECK-DAG: @[[STR_32:.*]] = private unnamed_addr constant [10 x i8] c"long long\00",
// CHECK-DAG: @[[STR_33:.*]] = private unnamed_addr constant [4 x i8] c"i10\00",
// CHECK-DAG: @[[STR_34:.*]] = private unnamed_addr constant [16 x i8] c"%s%s %s = %llu\0A\00",
// CHECK-DAG: @[[STR_35:.*]] = private unnamed_addr constant [19 x i8] c"unsigned long long\00",
// CHECK-DAG: @[[STR_36:.*]] = private unnamed_addr constant [4 x i8] c"i11\00",
// CHECK-DAG: @[[STR_37:.*]] = private unnamed_addr constant [14 x i8] c"%s%s %s = %f\0A\00",
// CHECK-DAG: @[[STR_38:.*]] = private unnamed_addr constant [6 x i8] c"float\00",
// CHECK-DAG: @[[STR_39:.*]] = private unnamed_addr constant [3 x i8] c"f1\00",
// CHECK-DAG: @[[STR_40:.*]] = private unnamed_addr constant [7 x i8] c"double\00",
// CHECK-DAG: @[[STR_41:.*]] = private unnamed_addr constant [3 x i8] c"f2\00",
// CHECK-DAG: @[[STR_42:.*]] = private unnamed_addr constant [15 x i8] c"%s%s %s = %Lf\0A\00",
// CHECK-DAG: @[[STR_43:.*]] = private unnamed_addr constant [12 x i8] c"long double\00",
// CHECK-DAG: @[[STR_44:.*]] = private unnamed_addr constant [3 x i8] c"f3\00",
// CHECK-DAG: @[[STR_45:.*]] = private unnamed_addr constant [14 x i8] c"%s%s %s = %p\0A\00",
// CHECK-DAG: @[[STR_46:.*]] = private unnamed_addr constant [7 x i8] c"void *\00",
// CHECK-DAG: @[[STR_47:.*]] = private unnamed_addr constant [3 x i8] c"p1\00",
// CHECK-DAG: @[[STR_48:.*]] = private unnamed_addr constant [19 x i8] c"%s%s %s = \22%.32s\22\0A\00",
// CHECK-DAG: @[[STR_49:.*]] = private unnamed_addr constant [7 x i8] c"char *\00",
// CHECK-DAG: @[[STR_50:.*]] = private unnamed_addr constant [3 x i8] c"s1\00",
// CHECK-DAG: @[[STR_51:.*]] = private unnamed_addr constant [13 x i8] c"const char *\00",
// CHECK-DAG: @[[STR_52:.*]] = private unnamed_addr constant [3 x i8] c"s2\00",
// CHECK-DAG: @[[STR_53:.*]] = private unnamed_addr constant [15 x i8] c"%s%s %s = *%p\0A\00",
// CHECK-DAG: @[[STR_54:.*]] = private unnamed_addr constant [9 x i8] c"char[10]\00",
// CHECK-DAG: @[[STR_55:.*]] = private unnamed_addr constant [3 x i8] c"s3\00",
// CHECK-DAG: @[[STR_56:.*]] = private unnamed_addr constant [10 x i8] c"%s%s %s =\00",
// CHECK-DAG: @[[STR_57:.*]] = private unnamed_addr constant [9 x i8] c"struct X\00",
// CHECK-DAG: @[[STR_58:.*]] = private unnamed_addr constant [3 x i8] c"x1\00",
// CHECK-DAG: @[[STR_59:.*]] = private unnamed_addr constant [5 x i8] c"    \00",
// CHECK-DAG: @[[STR_60:.*]] = private unnamed_addr constant [2 x i8] c"n\00",
// CHECK-DAG: @[[STR_61:.*]] = private unnamed_addr constant [5 x i8] c"%s}\0A\00",
// CHECK-DAG: @[[STR_62:.*]] = private unnamed_addr constant [3 x i8] c"n1\00",
// CHECK-DAG: @[[STR_63:.*]] = private unnamed_addr constant [3 x i8] c"n2\00",
// CHECK-DAG: @[[STR_64:.*]] = private unnamed_addr constant [3 x i8] c"u1\00",
// CHECK-DAG: @[[STR_65:.*]] = private unnamed_addr constant [3 x i8] c"u2\00",
// CHECK-DAG: @[[STR_66:.*]] = private unnamed_addr constant [20 x i8] c"%s%s %s : %zu = %d\0A\00",
// CHECK-DAG: @[[STR_67:.*]] = private unnamed_addr constant [3 x i8] c"b1\00",
// CHECK-DAG: @[[STR_68:.*]] = private unnamed_addr constant [3 x i8] c"b2\00",
// CHECK-DAG: @[[STR_69:.*]] = private unnamed_addr constant [13 x i8] c"_Complex int\00",
// CHECK-DAG: @[[STR_70:.*]] = private unnamed_addr constant [4 x i8] c"ci1\00",
// CHECK-DAG: @[[STR_71:.*]] = private unnamed_addr constant [16 x i8] c"_Complex double\00",
// CHECK-DAG: @[[STR_72:.*]] = private unnamed_addr constant [4 x i8] c"cd1\00",
// CHECK-DAG: @[[STR_73:.*]] = private unnamed_addr constant [3 x i8] c"}\0A\00",

struct X {
  int n;
};

struct A {
  char i1;
  signed char i2;
  unsigned char i3;
  short i4;
  unsigned short i5;
  int i6;
  unsigned int i7;
  long i8;
  unsigned long i9;
  long long i10;
  unsigned long long i11;

  float f1;
  double f2;
  long double f3;

  void *p1;
  char *s1;
  const char *s2;
  char s3[10];

  struct X x1;

  struct {
    int n1;
    struct X n2;
  };
  union {
    int u1;
    int u2;
  };

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i8> @test_vmulh_vx_i8mf4_tu
  // CHECK-RV64-SAME: (<vscale x 2 x i8> [[MASKEDOFF:%.*]], <vscale x 2 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i8> @llvm.riscv.vmulh.nxv2i8.i8.i64(<vscale x 2 x i8> [[MASKEDOFF]], <vscale x 2 x i8> [[OP1]], i8 [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i8> [[TMP0]]
  //
  vint8mf4_t test_vmulh_vx_i8mf4_tu(vint8mf4_t maskedoff, vint8mf4_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i8> @test_vmulh_vv_i8mf2_tu
  // CHECK-RV64-SAME: (<vscale x 4 x i8> [[MASKEDOFF:%.*]], <vscale x 4 x i8> [[OP1:%.*]], <vscale x 4 x i8> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i8> @llvm.riscv.vmulh.nxv4i8.nxv4i8.i64(<vscale x 4 x i8> [[MASKEDOFF]], <vscale x 4 x i8> [[OP1]], <vscale x 4 x i8> [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i8> [[TMP0]]
  //
  vint8mf2_t test_vmulh_vv_i8mf2_tu(vint8mf2_t maskedoff, vint8mf2_t op1, vint8mf2_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i8> @test_vmulh_vx_i8mf2_tu
  // CHECK-RV64-SAME: (<vscale x 4 x i8> [[MASKEDOFF:%.*]], <vscale x 4 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i8> @llvm.riscv.vmulh.nxv4i8.i8.i64(<vscale x 4 x i8> [[MASKEDOFF]], <vscale x 4 x i8> [[OP1]], i8 [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i8> [[TMP0]]
  //
  vint8mf2_t test_vmulh_vx_i8mf2_tu(vint8mf2_t maskedoff, vint8mf2_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i8> @test_vmulh_vv_i8m1_tu
  // CHECK-RV64-SAME: (<vscale x 8 x i8> [[MASKEDOFF:%.*]], <vscale x 8 x i8> [[OP1:%.*]], <vscale x 8 x i8> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i8> @llvm.riscv.vmulh.nxv8i8.nxv8i8.i64(<vscale x 8 x i8> [[MASKEDOFF]], <vscale x 8 x i8> [[OP1]], <vscale x 8 x i8> [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i8> [[TMP0]]
  //
  vint8m1_t test_vmulh_vv_i8m1_tu(vint8m1_t maskedoff, vint8m1_t op1, vint8m1_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i8> @test_vmulh_vx_i8m1_tu
  // CHECK-RV64-SAME: (<vscale x 8 x i8> [[MASKEDOFF:%.*]], <vscale x 8 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i8> @llvm.riscv.vmulh.nxv8i8.i8.i64(<vscale x 8 x i8> [[MASKEDOFF]], <vscale x 8 x i8> [[OP1]], i8 [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i8> [[TMP0]]
  //
  vint8m1_t test_vmulh_vx_i8m1_tu(vint8m1_t maskedoff, vint8m1_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 16 x i8> @test_vmulh_vv_i8m2_tu
  // CHECK-RV64-SAME: (<vscale x 16 x i8> [[MASKEDOFF:%.*]], <vscale x 16 x i8> [[OP1:%.*]], <vscale x 16 x i8> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i8> @llvm.riscv.vmulh.nxv16i8.nxv16i8.i64(<vscale x 16 x i8> [[MASKEDOFF]], <vscale x 16 x i8> [[OP1]], <vscale x 16 x i8> [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 16 x i8> [[TMP0]]
  //
  vint8m2_t test_vmulh_vv_i8m2_tu(vint8m2_t maskedoff, vint8m2_t op1, vint8m2_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 16 x i8> @test_vmulh_vx_i8m2_tu
  // CHECK-RV64-SAME: (<vscale x 16 x i8> [[MASKEDOFF:%.*]], <vscale x 16 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i8> @llvm.riscv.vmulh.nxv16i8.i8.i64(<vscale x 16 x i8> [[MASKEDOFF]], <vscale x 16 x i8> [[OP1]], i8 [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 16 x i8> [[TMP0]]
  //
  vint8m2_t test_vmulh_vx_i8m2_tu(vint8m2_t maskedoff, vint8m2_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 32 x i8> @test_vmulh_vv_i8m4_tu
  // CHECK-RV64-SAME: (<vscale x 32 x i8> [[MASKEDOFF:%.*]], <vscale x 32 x i8> [[OP1:%.*]], <vscale x 32 x i8> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i8> @llvm.riscv.vmulh.nxv32i8.nxv32i8.i64(<vscale x 32 x i8> [[MASKEDOFF]], <vscale x 32 x i8> [[OP1]], <vscale x 32 x i8> [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 32 x i8> [[TMP0]]
  //
  vint8m4_t test_vmulh_vv_i8m4_tu(vint8m4_t maskedoff, vint8m4_t op1, vint8m4_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 32 x i8> @test_vmulh_vx_i8m4_tu
  // CHECK-RV64-SAME: (<vscale x 32 x i8> [[MASKEDOFF:%.*]], <vscale x 32 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i8> @llvm.riscv.vmulh.nxv32i8.i8.i64(<vscale x 32 x i8> [[MASKEDOFF]], <vscale x 32 x i8> [[OP1]], i8 [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 32 x i8> [[TMP0]]
  //
  vint8m4_t test_vmulh_vx_i8m4_tu(vint8m4_t maskedoff, vint8m4_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 64 x i8> @test_vmulh_vv_i8m8_tu
  // CHECK-RV64-SAME: (<vscale x 64 x i8> [[MASKEDOFF:%.*]], <vscale x 64 x i8> [[OP1:%.*]], <vscale x 64 x i8> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 64 x i8> @llvm.riscv.vmulh.nxv64i8.nxv64i8.i64(<vscale x 64 x i8> [[MASKEDOFF]], <vscale x 64 x i8> [[OP1]], <vscale x 64 x i8> [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 64 x i8> [[TMP0]]
  //
  vint8m8_t test_vmulh_vv_i8m8_tu(vint8m8_t maskedoff, vint8m8_t op1, vint8m8_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 64 x i8> @test_vmulh_vx_i8m8_tu
  // CHECK-RV64-SAME: (<vscale x 64 x i8> [[MASKEDOFF:%.*]], <vscale x 64 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 64 x i8> @llvm.riscv.vmulh.nxv64i8.i8.i64(<vscale x 64 x i8> [[MASKEDOFF]], <vscale x 64 x i8> [[OP1]], i8 [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 64 x i8> [[TMP0]]
  //
  vint8m8_t test_vmulh_vx_i8m8_tu(vint8m8_t maskedoff, vint8m8_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 1 x i16> @test_vmulh_vv_i16mf4_tu
  // CHECK-RV64-SAME: (<vscale x 1 x i16> [[MASKEDOFF:%.*]], <vscale x 1 x i16> [[OP1:%.*]], <vscale x 1 x i16> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i16> @llvm.riscv.vmulh.nxv1i16.nxv1i16.i64(<vscale x 1 x i16> [[MASKEDOFF]], <vscale x 1 x i16> [[OP1]], <vscale x 1 x i16> [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 1 x i16> [[TMP0]]
  //
  vint16mf4_t test_vmulh_vv_i16mf4_tu(vint16mf4_t maskedoff, vint16mf4_t op1, vint16mf4_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 1 x i16> @test_vmulh_vx_i16mf4_tu
  // CHECK-RV64-SAME: (<vscale x 1 x i16> [[MASKEDOFF:%.*]], <vscale x 1 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i16> @llvm.riscv.vmulh.nxv1i16.i16.i64(<vscale x 1 x i16> [[MASKEDOFF]], <vscale x 1 x i16> [[OP1]], i16 [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 1 x i16> [[TMP0]]
  //
  vint16mf4_t test_vmulh_vx_i16mf4_tu(vint16mf4_t maskedoff, vint16mf4_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i16> @test_vmulh_vv_i16mf2_tu
  // CHECK-RV64-SAME: (<vscale x 2 x i16> [[MASKEDOFF:%.*]], <vscale x 2 x i16> [[OP1:%.*]], <vscale x 2 x i16> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i16> @llvm.riscv.vmulh.nxv2i16.nxv2i16.i64(<vscale x 2 x i16> [[MASKEDOFF]], <vscale x 2 x i16> [[OP1]], <vscale x 2 x i16> [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i16> [[TMP0]]
  //
  vint16mf2_t test_vmulh_vv_i16mf2_tu(vint16mf2_t maskedoff, vint16mf2_t op1, vint16mf2_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i16> @test_vmulh_vx_i16mf2_tu
  // CHECK-RV64-SAME: (<vscale x 2 x i16> [[MASKEDOFF:%.*]], <vscale x 2 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i16> @llvm.riscv.vmulh.nxv2i16.i16.i64(<vscale x 2 x i16> [[MASKEDOFF]], <vscale x 2 x i16> [[OP1]], i16 [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i16> [[TMP0]]
  //
  vint16mf2_t test_vmulh_vx_i16mf2_tu(vint16mf2_t maskedoff, vint16mf2_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i16> @test_vmulh_vv_i16m1_tu
  // CHECK-RV64-SAME: (<vscale x 4 x i16> [[MASKEDOFF:%.*]], <vscale x 4 x i16> [[OP1:%.*]], <vscale x 4 x i16> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i16> @llvm.riscv.vmulh.nxv4i16.nxv4i16.i64(<vscale x 4 x i16> [[MASKEDOFF]], <vscale x 4 x i16> [[OP1]], <vscale x 4 x i16> [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i16> [[TMP0]]
  //
  vint16m1_t test_vmulh_vv_i16m1_tu(vint16m1_t maskedoff, vint16m1_t op1, vint16m1_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i16> @test_vmulh_vx_i16m1_tu
  // CHECK-RV64-SAME: (<vscale x 4 x i16> [[MASKEDOFF:%.*]], <vscale x 4 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i16> @llvm.riscv.vmulh.nxv4i16.i16.i64(<vscale x 4 x i16> [[MASKEDOFF]], <vscale x 4 x i16> [[OP1]], i16 [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i16> [[TMP0]]
  //
  vint16m1_t test_vmulh_vx_i16m1_tu(vint16m1_t maskedoff, vint16m1_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i16> @test_vmulh_vv_i16m2_tu
  // CHECK-RV64-SAME: (<vscale x 8 x i16> [[MASKEDOFF:%.*]], <vscale x 8 x i16> [[OP1:%.*]], <vscale x 8 x i16> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i16> @llvm.riscv.vmulh.nxv8i16.nxv8i16.i64(<vscale x 8 x i16> [[MASKEDOFF]], <vscale x 8 x i16> [[OP1]], <vscale x 8 x i16> [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i16> [[TMP0]]
  //
  vint16m2_t test_vmulh_vv_i16m2_tu(vint16m2_t maskedoff, vint16m2_t op1, vint16m2_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i16> @test_vmulh_vx_i16m2_tu
  // CHECK-RV64-SAME: (<vscale x 8 x i16> [[MASKEDOFF:%.*]], <vscale x 8 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i16> @llvm.riscv.vmulh.nxv8i16.i16.i64(<vscale x 8 x i16> [[MASKEDOFF]], <vscale x 8 x i16> [[OP1]], i16 [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i16> [[TMP0]]
  //
  vint16m2_t test_vmulh_vx_i16m2_tu(vint16m2_t maskedoff, vint16m2_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 16 x i16> @test_vmulh_vv_i16m4_tu
  // CHECK-RV64-SAME: (<vscale x 16 x i16> [[MASKEDOFF:%.*]], <vscale x 16 x i16> [[OP1:%.*]], <vscale x 16 x i16> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i16> @llvm.riscv.vmulh.nxv16i16.nxv16i16.i64(<vscale x 16 x i16> [[MASKEDOFF]], <vscale x 16 x i16> [[OP1]], <vscale x 16 x i16> [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 16 x i16> [[TMP0]]
  //
  vint16m4_t test_vmulh_vv_i16m4_tu(vint16m4_t maskedoff, vint16m4_t op1, vint16m4_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 16 x i16> @test_vmulh_vx_i16m4_tu
  // CHECK-RV64-SAME: (<vscale x 16 x i16> [[MASKEDOFF:%.*]], <vscale x 16 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i16> @llvm.riscv.vmulh.nxv16i16.i16.i64(<vscale x 16 x i16> [[MASKEDOFF]], <vscale x 16 x i16> [[OP1]], i16 [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 16 x i16> [[TMP0]]
  //
  vint16m4_t test_vmulh_vx_i16m4_tu(vint16m4_t maskedoff, vint16m4_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 32 x i16> @test_vmulh_vv_i16m8_tu
  // CHECK-RV64-SAME: (<vscale x 32 x i16> [[MASKEDOFF:%.*]], <vscale x 32 x i16> [[OP1:%.*]], <vscale x 32 x i16> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i16> @llvm.riscv.vmulh.nxv32i16.nxv32i16.i64(<vscale x 32 x i16> [[MASKEDOFF]], <vscale x 32 x i16> [[OP1]], <vscale x 32 x i16> [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 32 x i16> [[TMP0]]
  //
  vint16m8_t test_vmulh_vv_i16m8_tu(vint16m8_t maskedoff, vint16m8_t op1, vint16m8_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 32 x i16> @test_vmulh_vx_i16m8_tu
  // CHECK-RV64-SAME: (<vscale x 32 x i16> [[MASKEDOFF:%.*]], <vscale x 32 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i16> @llvm.riscv.vmulh.nxv32i16.i16.i64(<vscale x 32 x i16> [[MASKEDOFF]], <vscale x 32 x i16> [[OP1]], i16 [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 32 x i16> [[TMP0]]
  //
  vint16m8_t test_vmulh_vx_i16m8_tu(vint16m8_t maskedoff, vint16m8_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 1 x i32> @test_vmulh_vv_i32mf2_tu
  // CHECK-RV64-SAME: (<vscale x 1 x i32> [[MASKEDOFF:%.*]], <vscale x 1 x i32> [[OP1:%.*]], <vscale x 1 x i32> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i32> @llvm.riscv.vmulh.nxv1i32.nxv1i32.i64(<vscale x 1 x i32> [[MASKEDOFF]], <vscale x 1 x i32> [[OP1]], <vscale x 1 x i32> [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 1 x i32> [[TMP0]]
  //
  vint32mf2_t test_vmulh_vv_i32mf2_tu(vint32mf2_t maskedoff, vint32mf2_t op1, vint32mf2_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 1 x i32> @test_vmulh_vx_i32mf2_tu
  // CHECK-RV64-SAME: (<vscale x 1 x i32> [[MASKEDOFF:%.*]], <vscale x 1 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i32> @llvm.riscv.vmulh.nxv1i32.i32.i64(<vscale x 1 x i32> [[MASKEDOFF]], <vscale x 1 x i32> [[OP1]], i32 [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 1 x i32> [[TMP0]]
  //
  vint32mf2_t test_vmulh_vx_i32mf2_tu(vint32mf2_t maskedoff, vint32mf2_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i32> @test_vmulh_vv_i32m1_tu
  // CHECK-RV64-SAME: (<vscale x 2 x i32> [[MASKEDOFF:%.*]], <vscale x 2 x i32> [[OP1:%.*]], <vscale x 2 x i32> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i32> @llvm.riscv.vmulh.nxv2i32.nxv2i32.i64(<vscale x 2 x i32> [[MASKEDOFF]], <vscale x 2 x i32> [[OP1]], <vscale x 2 x i32> [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i32> [[TMP0]]
  //
  vint32m1_t test_vmulh_vv_i32m1_tu(vint32m1_t maskedoff, vint32m1_t op1, vint32m1_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i32> @test_vmulh_vx_i32m1_tu
  // CHECK-RV64-SAME: (<vscale x 2 x i32> [[MASKEDOFF:%.*]], <vscale x 2 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i32> @llvm.riscv.vmulh.nxv2i32.i32.i64(<vscale x 2 x i32> [[MASKEDOFF]], <vscale x 2 x i32> [[OP1]], i32 [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i32> [[TMP0]]
  //
  vint32m1_t test_vmulh_vx_i32m1_tu(vint32m1_t maskedoff, vint32m1_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i32> @test_vmulh_vv_i32m2_tu
  // CHECK-RV64-SAME: (<vscale x 4 x i32> [[MASKEDOFF:%.*]], <vscale x 4 x i32> [[OP1:%.*]], <vscale x 4 x i32> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i32> @llvm.riscv.vmulh.nxv4i32.nxv4i32.i64(<vscale x 4 x i32> [[MASKEDOFF]], <vscale x 4 x i32> [[OP1]], <vscale x 4 x i32> [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i32> [[TMP0]]
  //
  vint32m2_t test_vmulh_vv_i32m2_tu(vint32m2_t maskedoff, vint32m2_t op1, vint32m2_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i32> @test_vmulh_vx_i32m2_tu
  // CHECK-RV64-SAME: (<vscale x 4 x i32> [[MASKEDOFF:%.*]], <vscale x 4 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i32> @llvm.riscv.vmulh.nxv4i32.i32.i64(<vscale x 4 x i32> [[MASKEDOFF]], <vscale x 4 x i32> [[OP1]], i32 [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i32> [[TMP0]]
  //
  vint32m2_t test_vmulh_vx_i32m2_tu(vint32m2_t maskedoff, vint32m2_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i32> @test_vmulh_vv_i32m4_tu
  // CHECK-RV64-SAME: (<vscale x 8 x i32> [[MASKEDOFF:%.*]], <vscale x 8 x i32> [[OP1:%.*]], <vscale x 8 x i32> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i32> @llvm.riscv.vmulh.nxv8i32.nxv8i32.i64(<vscale x 8 x i32> [[MASKEDOFF]], <vscale x 8 x i32> [[OP1]], <vscale x 8 x i32> [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i32> [[TMP0]]
  //
  vint32m4_t test_vmulh_vv_i32m4_tu(vint32m4_t maskedoff, vint32m4_t op1, vint32m4_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i32> @test_vmulh_vx_i32m4_tu
  // CHECK-RV64-SAME: (<vscale x 8 x i32> [[MASKEDOFF:%.*]], <vscale x 8 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i32> @llvm.riscv.vmulh.nxv8i32.i32.i64(<vscale x 8 x i32> [[MASKEDOFF]], <vscale x 8 x i32> [[OP1]], i32 [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i32> [[TMP0]]
  //
  vint32m4_t test_vmulh_vx_i32m4_tu(vint32m4_t maskedoff, vint32m4_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 16 x i32> @test_vmulh_vv_i32m8_tu
  // CHECK-RV64-SAME: (<vscale x 16 x i32> [[MASKEDOFF:%.*]], <vscale x 16 x i32> [[OP1:%.*]], <vscale x 16 x i32> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i32> @llvm.riscv.vmulh.nxv16i32.nxv16i32.i64(<vscale x 16 x i32> [[MASKEDOFF]], <vscale x 16 x i32> [[OP1]], <vscale x 16 x i32> [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 16 x i32> [[TMP0]]
  //
  vint32m8_t test_vmulh_vv_i32m8_tu(vint32m8_t maskedoff, vint32m8_t op1, vint32m8_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 16 x i32> @test_vmulh_vx_i32m8_tu
  // CHECK-RV64-SAME: (<vscale x 16 x i32> [[MASKEDOFF:%.*]], <vscale x 16 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i32> @llvm.riscv.vmulh.nxv16i32.i32.i64(<vscale x 16 x i32> [[MASKEDOFF]], <vscale x 16 x i32> [[OP1]], i32 [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 16 x i32> [[TMP0]]
  //
  vint32m8_t test_vmulh_vx_i32m8_tu(vint32m8_t maskedoff, vint32m8_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 1 x i64> @test_vmulh_vv_i64m1_tu
  // CHECK-RV64-SAME: (<vscale x 1 x i64> [[MASKEDOFF:%.*]], <vscale x 1 x i64> [[OP1:%.*]], <vscale x 1 x i64> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i64> @llvm.riscv.vmulh.nxv1i64.nxv1i64.i64(<vscale x 1 x i64> [[MASKEDOFF]], <vscale x 1 x i64> [[OP1]], <vscale x 1 x i64> [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 1 x i64> [[TMP0]]
  //
  vint64m1_t test_vmulh_vv_i64m1_tu(vint64m1_t maskedoff, vint64m1_t op1, vint64m1_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 1 x i64> @test_vmulh_vx_i64m1_tu
  // CHECK-RV64-SAME: (<vscale x 1 x i64> [[MASKEDOFF:%.*]], <vscale x 1 x i64> [[OP1:%.*]], i64 noundef [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i64> @llvm.riscv.vmulh.nxv1i64.i64.i64(<vscale x 1 x i64> [[MASKEDOFF]], <vscale x 1 x i64> [[OP1]], i64 [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 1 x i64> [[TMP0]]
  //
  vint64m1_t test_vmulh_vx_i64m1_tu(vint64m1_t maskedoff, vint64m1_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i64> @test_vmulh_vv_i64m2_tu
  // CHECK-RV64-SAME: (<vscale x 2 x i64> [[MASKEDOFF:%.*]], <vscale x 2 x i64> [[OP1:%.*]], <vscale x 2 x i64> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i64> @llvm.riscv.vmulh.nxv2i64.nxv2i64.i64(<vscale x 2 x i64> [[MASKEDOFF]], <vscale x 2 x i64> [[OP1]], <vscale x 2 x i64> [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i64> [[TMP0]]
  //
  vint64m2_t test_vmulh_vv_i64m2_tu(vint64m2_t maskedoff, vint64m2_t op1, vint64m2_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i64> @test_vmulh_vx_i64m2_tu
  // CHECK-RV64-SAME: (<vscale x 2 x i64> [[MASKEDOFF:%.*]], <vscale x 2 x i64> [[OP1:%.*]], i64 noundef [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i64> @llvm.riscv.vmulh.nxv2i64.i64.i64(<vscale x 2 x i64> [[MASKEDOFF]], <vscale x 2 x i64> [[OP1]], i64 [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i64> [[TMP0]]
  //
  vint64m2_t test_vmulh_vx_i64m2_tu(vint64m2_t maskedoff, vint64m2_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i64> @test_vmulh_vv_i64m4_tu
  // CHECK-RV64-SAME: (<vscale x 4 x i64> [[MASKEDOFF:%.*]], <vscale x 4 x i64> [[OP1:%.*]], <vscale x 4 x i64> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i64> @llvm.riscv.vmulh.nxv4i64.nxv4i64.i64(<vscale x 4 x i64> [[MASKEDOFF]], <vscale x 4 x i64> [[OP1]], <vscale x 4 x i64> [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i64> [[TMP0]]
  //
  vint64m4_t test_vmulh_vv_i64m4_tu(vint64m4_t maskedoff, vint64m4_t op1, vint64m4_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i64> @test_vmulh_vx_i64m4_tu
  // CHECK-RV64-SAME: (<vscale x 4 x i64> [[MASKEDOFF:%.*]], <vscale x 4 x i64> [[OP1:%.*]], i64 noundef [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i64> @llvm.riscv.vmulh.nxv4i64.i64.i64(<vscale x 4 x i64> [[MASKEDOFF]], <vscale x 4 x i64> [[OP1]], i64 [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i64> [[TMP0]]
  //
  vint64m4_t test_vmulh_vx_i64m4_tu(vint64m4_t maskedoff, vint64m4_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i64> @test_vmulh_vv_i64m8_tu
  // CHECK-RV64-SAME: (<vscale x 8 x i64> [[MASKEDOFF:%.*]], <vscale x 8 x i64> [[OP1:%.*]], <vscale x 8 x i64> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i64> @llvm.riscv.vmulh.nxv8i64.nxv8i64.i64(<vscale x 8 x i64> [[MASKEDOFF]], <vscale x 8 x i64> [[OP1]], <vscale x 8 x i64> [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i64> [[TMP0]]
  //
  vint64m8_t test_vmulh_vv_i64m8_tu(vint64m8_t maskedoff, vint64m8_t op1, vint64m8_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i64> @test_vmulh_vx_i64m8_tu
  // CHECK-RV64-SAME: (<vscale x 8 x i64> [[MASKEDOFF:%.*]], <vscale x 8 x i64> [[OP1:%.*]], i64 noundef [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i64> @llvm.riscv.vmulh.nxv8i64.i64.i64(<vscale x 8 x i64> [[MASKEDOFF]], <vscale x 8 x i64> [[OP1]], i64 [[OP2]], i64 [[VL]])
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i64> [[TMP0]]
  //
  vint64m8_t test_vmulh_vx_i64m8_tu(vint64m8_t maskedoff, vint64m8_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 1 x i8> @test_vmulh_vv_i8mf8_tum
  // CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i8> [[MASKEDOFF:%.*]], <vscale x 1 x i8> [[OP1:%.*]], <vscale x 1 x i8> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i8> @llvm.riscv.vmulh.mask.nxv1i8.nxv1i8.i64(<vscale x 1 x i8> [[MASKEDOFF]], <vscale x 1 x i8> [[OP1]], <vscale x 1 x i8> [[OP2]], <vscale x 1 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 1 x i8> [[TMP0]]
  //
  vint8mf8_t test_vmulh_vv_i8mf8_tum(vbool64_t mask, vint8mf8_t maskedoff, vint8mf8_t op1, vint8mf8_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 1 x i8> @test_vmulh_vx_i8mf8_tum
  // CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i8> [[MASKEDOFF:%.*]], <vscale x 1 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i8> @llvm.riscv.vmulh.mask.nxv1i8.i8.i64(<vscale x 1 x i8> [[MASKEDOFF]], <vscale x 1 x i8> [[OP1]], i8 [[OP2]], <vscale x 1 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 1 x i8> [[TMP0]]
  //
  vint8mf8_t test_vmulh_vx_i8mf8_tum(vbool64_t mask, vint8mf8_t maskedoff, vint8mf8_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i8> @test_vmulh_vv_i8mf4_tum
  // CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i8> [[MASKEDOFF:%.*]], <vscale x 2 x i8> [[OP1:%.*]], <vscale x 2 x i8> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i8> @llvm.riscv.vmulh.mask.nxv2i8.nxv2i8.i64(<vscale x 2 x i8> [[MASKEDOFF]], <vscale x 2 x i8> [[OP1]], <vscale x 2 x i8> [[OP2]], <vscale x 2 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i8> [[TMP0]]
  //
  vint8mf4_t test_vmulh_vv_i8mf4_tum(vbool32_t mask, vint8mf4_t maskedoff, vint8mf4_t op1, vint8mf4_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i8> @test_vmulh_vx_i8mf4_tum
  // CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i8> [[MASKEDOFF:%.*]], <vscale x 2 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i8> @llvm.riscv.vmulh.mask.nxv2i8.i8.i64(<vscale x 2 x i8> [[MASKEDOFF]], <vscale x 2 x i8> [[OP1]], i8 [[OP2]], <vscale x 2 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i8> [[TMP0]]
  //
  vint8mf4_t test_vmulh_vx_i8mf4_tum(vbool32_t mask, vint8mf4_t maskedoff, vint8mf4_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i8> @test_vmulh_vv_i8mf2_tum
  // CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i8> [[MASKEDOFF:%.*]], <vscale x 4 x i8> [[OP1:%.*]], <vscale x 4 x i8> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i8> @llvm.riscv.vmulh.mask.nxv4i8.nxv4i8.i64(<vscale x 4 x i8> [[MASKEDOFF]], <vscale x 4 x i8> [[OP1]], <vscale x 4 x i8> [[OP2]], <vscale x 4 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i8> [[TMP0]]
  //
  vint8mf2_t test_vmulh_vv_i8mf2_tum(vbool16_t mask, vint8mf2_t maskedoff, vint8mf2_t op1, vint8mf2_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i8> @test_vmulh_vx_i8mf2_tum
  // CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i8> [[MASKEDOFF:%.*]], <vscale x 4 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i8> @llvm.riscv.vmulh.mask.nxv4i8.i8.i64(<vscale x 4 x i8> [[MASKEDOFF]], <vscale x 4 x i8> [[OP1]], i8 [[OP2]], <vscale x 4 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i8> [[TMP0]]
  //
  vint8mf2_t test_vmulh_vx_i8mf2_tum(vbool16_t mask, vint8mf2_t maskedoff, vint8mf2_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i8> @test_vmulh_vv_i8m1_tum
  // CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i8> [[MASKEDOFF:%.*]], <vscale x 8 x i8> [[OP1:%.*]], <vscale x 8 x i8> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i8> @llvm.riscv.vmulh.mask.nxv8i8.nxv8i8.i64(<vscale x 8 x i8> [[MASKEDOFF]], <vscale x 8 x i8> [[OP1]], <vscale x 8 x i8> [[OP2]], <vscale x 8 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i8> [[TMP0]]
  //
  vint8m1_t test_vmulh_vv_i8m1_tum(vbool8_t mask, vint8m1_t maskedoff, vint8m1_t op1, vint8m1_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i8> @test_vmulh_vx_i8m1_tum
  // CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i8> [[MASKEDOFF:%.*]], <vscale x 8 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i8> @llvm.riscv.vmulh.mask.nxv8i8.i8.i64(<vscale x 8 x i8> [[MASKEDOFF]], <vscale x 8 x i8> [[OP1]], i8 [[OP2]], <vscale x 8 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i8> [[TMP0]]
  //
  vint8m1_t test_vmulh_vx_i8m1_tum(vbool8_t mask, vint8m1_t maskedoff, vint8m1_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 16 x i8> @test_vmulh_vv_i8m2_tum
  // CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i8> [[MASKEDOFF:%.*]], <vscale x 16 x i8> [[OP1:%.*]], <vscale x 16 x i8> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i8> @llvm.riscv.vmulh.mask.nxv16i8.nxv16i8.i64(<vscale x 16 x i8> [[MASKEDOFF]], <vscale x 16 x i8> [[OP1]], <vscale x 16 x i8> [[OP2]], <vscale x 16 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 16 x i8> [[TMP0]]
  //
  vint8m2_t test_vmulh_vv_i8m2_tum(vbool4_t mask, vint8m2_t maskedoff, vint8m2_t op1, vint8m2_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 16 x i8> @test_vmulh_vx_i8m2_tum
  // CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i8> [[MASKEDOFF:%.*]], <vscale x 16 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i8> @llvm.riscv.vmulh.mask.nxv16i8.i8.i64(<vscale x 16 x i8> [[MASKEDOFF]], <vscale x 16 x i8> [[OP1]], i8 [[OP2]], <vscale x 16 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 16 x i8> [[TMP0]]
  //
  vint8m2_t test_vmulh_vx_i8m2_tum(vbool4_t mask, vint8m2_t maskedoff, vint8m2_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 32 x i8> @test_vmulh_vv_i8m4_tum
  // CHECK-RV64-SAME: (<vscale x 32 x i1> [[MASK:%.*]], <vscale x 32 x i8> [[MASKEDOFF:%.*]], <vscale x 32 x i8> [[OP1:%.*]], <vscale x 32 x i8> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i8> @llvm.riscv.vmulh.mask.nxv32i8.nxv32i8.i64(<vscale x 32 x i8> [[MASKEDOFF]], <vscale x 32 x i8> [[OP1]], <vscale x 32 x i8> [[OP2]], <vscale x 32 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 32 x i8> [[TMP0]]
  //
  vint8m4_t test_vmulh_vv_i8m4_tum(vbool2_t mask, vint8m4_t maskedoff, vint8m4_t op1, vint8m4_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 32 x i8> @test_vmulh_vx_i8m4_tum
  // CHECK-RV64-SAME: (<vscale x 32 x i1> [[MASK:%.*]], <vscale x 32 x i8> [[MASKEDOFF:%.*]], <vscale x 32 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i8> @llvm.riscv.vmulh.mask.nxv32i8.i8.i64(<vscale x 32 x i8> [[MASKEDOFF]], <vscale x 32 x i8> [[OP1]], i8 [[OP2]], <vscale x 32 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 32 x i8> [[TMP0]]
  //
  vint8m4_t test_vmulh_vx_i8m4_tum(vbool2_t mask, vint8m4_t maskedoff, vint8m4_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 64 x i8> @test_vmulh_vv_i8m8_tum
  // CHECK-RV64-SAME: (<vscale x 64 x i1> [[MASK:%.*]], <vscale x 64 x i8> [[MASKEDOFF:%.*]], <vscale x 64 x i8> [[OP1:%.*]], <vscale x 64 x i8> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 64 x i8> @llvm.riscv.vmulh.mask.nxv64i8.nxv64i8.i64(<vscale x 64 x i8> [[MASKEDOFF]], <vscale x 64 x i8> [[OP1]], <vscale x 64 x i8> [[OP2]], <vscale x 64 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 64 x i8> [[TMP0]]
  //
  vint8m8_t test_vmulh_vv_i8m8_tum(vbool1_t mask, vint8m8_t maskedoff, vint8m8_t op1, vint8m8_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 64 x i8> @test_vmulh_vx_i8m8_tum
  // CHECK-RV64-SAME: (<vscale x 64 x i1> [[MASK:%.*]], <vscale x 64 x i8> [[MASKEDOFF:%.*]], <vscale x 64 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 64 x i8> @llvm.riscv.vmulh.mask.nxv64i8.i8.i64(<vscale x 64 x i8> [[MASKEDOFF]], <vscale x 64 x i8> [[OP1]], i8 [[OP2]], <vscale x 64 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 64 x i8> [[TMP0]]
  //
  vint8m8_t test_vmulh_vx_i8m8_tum(vbool1_t mask, vint8m8_t maskedoff, vint8m8_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 1 x i16> @test_vmulh_vv_i16mf4_tum
  // CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i16> [[MASKEDOFF:%.*]], <vscale x 1 x i16> [[OP1:%.*]], <vscale x 1 x i16> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i16> @llvm.riscv.vmulh.mask.nxv1i16.nxv1i16.i64(<vscale x 1 x i16> [[MASKEDOFF]], <vscale x 1 x i16> [[OP1]], <vscale x 1 x i16> [[OP2]], <vscale x 1 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 1 x i16> [[TMP0]]
  //
  vint16mf4_t test_vmulh_vv_i16mf4_tum(vbool64_t mask, vint16mf4_t maskedoff, vint16mf4_t op1, vint16mf4_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 1 x i16> @test_vmulh_vx_i16mf4_tum
  // CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i16> [[MASKEDOFF:%.*]], <vscale x 1 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i16> @llvm.riscv.vmulh.mask.nxv1i16.i16.i64(<vscale x 1 x i16> [[MASKEDOFF]], <vscale x 1 x i16> [[OP1]], i16 [[OP2]], <vscale x 1 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 1 x i16> [[TMP0]]
  //
  vint16mf4_t test_vmulh_vx_i16mf4_tum(vbool64_t mask, vint16mf4_t maskedoff, vint16mf4_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i16> @test_vmulh_vv_i16mf2_tum
  // CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i16> [[MASKEDOFF:%.*]], <vscale x 2 x i16> [[OP1:%.*]], <vscale x 2 x i16> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i16> @llvm.riscv.vmulh.mask.nxv2i16.nxv2i16.i64(<vscale x 2 x i16> [[MASKEDOFF]], <vscale x 2 x i16> [[OP1]], <vscale x 2 x i16> [[OP2]], <vscale x 2 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i16> [[TMP0]]
  //
  vint16mf2_t test_vmulh_vv_i16mf2_tum(vbool32_t mask, vint16mf2_t maskedoff, vint16mf2_t op1, vint16mf2_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i16> @test_vmulh_vx_i16mf2_tum
  // CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i16> [[MASKEDOFF:%.*]], <vscale x 2 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i16> @llvm.riscv.vmulh.mask.nxv2i16.i16.i64(<vscale x 2 x i16> [[MASKEDOFF]], <vscale x 2 x i16> [[OP1]], i16 [[OP2]], <vscale x 2 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i16> [[TMP0]]
  //
  vint16mf2_t test_vmulh_vx_i16mf2_tum(vbool32_t mask, vint16mf2_t maskedoff, vint16mf2_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i16> @test_vmulh_vv_i16m1_tum
  // CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i16> [[MASKEDOFF:%.*]], <vscale x 4 x i16> [[OP1:%.*]], <vscale x 4 x i16> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i16> @llvm.riscv.vmulh.mask.nxv4i16.nxv4i16.i64(<vscale x 4 x i16> [[MASKEDOFF]], <vscale x 4 x i16> [[OP1]], <vscale x 4 x i16> [[OP2]], <vscale x 4 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i16> [[TMP0]]
  //
  vint16m1_t test_vmulh_vv_i16m1_tum(vbool16_t mask, vint16m1_t maskedoff, vint16m1_t op1, vint16m1_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i16> @test_vmulh_vx_i16m1_tum
  // CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i16> [[MASKEDOFF:%.*]], <vscale x 4 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i16> @llvm.riscv.vmulh.mask.nxv4i16.i16.i64(<vscale x 4 x i16> [[MASKEDOFF]], <vscale x 4 x i16> [[OP1]], i16 [[OP2]], <vscale x 4 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i16> [[TMP0]]
  //
  vint16m1_t test_vmulh_vx_i16m1_tum(vbool16_t mask, vint16m1_t maskedoff, vint16m1_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i16> @test_vmulh_vv_i16m2_tum
  // CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i16> [[MASKEDOFF:%.*]], <vscale x 8 x i16> [[OP1:%.*]], <vscale x 8 x i16> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i16> @llvm.riscv.vmulh.mask.nxv8i16.nxv8i16.i64(<vscale x 8 x i16> [[MASKEDOFF]], <vscale x 8 x i16> [[OP1]], <vscale x 8 x i16> [[OP2]], <vscale x 8 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i16> [[TMP0]]
  //
  vint16m2_t test_vmulh_vv_i16m2_tum(vbool8_t mask, vint16m2_t maskedoff, vint16m2_t op1, vint16m2_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i16> @test_vmulh_vx_i16m2_tum
  // CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i16> [[MASKEDOFF:%.*]], <vscale x 8 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i16> @llvm.riscv.vmulh.mask.nxv8i16.i16.i64(<vscale x 8 x i16> [[MASKEDOFF]], <vscale x 8 x i16> [[OP1]], i16 [[OP2]], <vscale x 8 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i16> [[TMP0]]
  //
  vint16m2_t test_vmulh_vx_i16m2_tum(vbool8_t mask, vint16m2_t maskedoff, vint16m2_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 16 x i16> @test_vmulh_vv_i16m4_tum
  // CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i16> [[MASKEDOFF:%.*]], <vscale x 16 x i16> [[OP1:%.*]], <vscale x 16 x i16> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i16> @llvm.riscv.vmulh.mask.nxv16i16.nxv16i16.i64(<vscale x 16 x i16> [[MASKEDOFF]], <vscale x 16 x i16> [[OP1]], <vscale x 16 x i16> [[OP2]], <vscale x 16 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 16 x i16> [[TMP0]]
  //
  vint16m4_t test_vmulh_vv_i16m4_tum(vbool4_t mask, vint16m4_t maskedoff, vint16m4_t op1, vint16m4_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 16 x i16> @test_vmulh_vx_i16m4_tum
  // CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i16> [[MASKEDOFF:%.*]], <vscale x 16 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i16> @llvm.riscv.vmulh.mask.nxv16i16.i16.i64(<vscale x 16 x i16> [[MASKEDOFF]], <vscale x 16 x i16> [[OP1]], i16 [[OP2]], <vscale x 16 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 16 x i16> [[TMP0]]
  //
  vint16m4_t test_vmulh_vx_i16m4_tum(vbool4_t mask, vint16m4_t maskedoff, vint16m4_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 32 x i16> @test_vmulh_vv_i16m8_tum
  // CHECK-RV64-SAME: (<vscale x 32 x i1> [[MASK:%.*]], <vscale x 32 x i16> [[MASKEDOFF:%.*]], <vscale x 32 x i16> [[OP1:%.*]], <vscale x 32 x i16> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i16> @llvm.riscv.vmulh.mask.nxv32i16.nxv32i16.i64(<vscale x 32 x i16> [[MASKEDOFF]], <vscale x 32 x i16> [[OP1]], <vscale x 32 x i16> [[OP2]], <vscale x 32 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 32 x i16> [[TMP0]]
  //
  vint16m8_t test_vmulh_vv_i16m8_tum(vbool2_t mask, vint16m8_t maskedoff, vint16m8_t op1, vint16m8_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 32 x i16> @test_vmulh_vx_i16m8_tum
  // CHECK-RV64-SAME: (<vscale x 32 x i1> [[MASK:%.*]], <vscale x 32 x i16> [[MASKEDOFF:%.*]], <vscale x 32 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i16> @llvm.riscv.vmulh.mask.nxv32i16.i16.i64(<vscale x 32 x i16> [[MASKEDOFF]], <vscale x 32 x i16> [[OP1]], i16 [[OP2]], <vscale x 32 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 32 x i16> [[TMP0]]
  //
  vint16m8_t test_vmulh_vx_i16m8_tum(vbool2_t mask, vint16m8_t maskedoff, vint16m8_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 1 x i32> @test_vmulh_vv_i32mf2_tum
  // CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i32> [[MASKEDOFF:%.*]], <vscale x 1 x i32> [[OP1:%.*]], <vscale x 1 x i32> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i32> @llvm.riscv.vmulh.mask.nxv1i32.nxv1i32.i64(<vscale x 1 x i32> [[MASKEDOFF]], <vscale x 1 x i32> [[OP1]], <vscale x 1 x i32> [[OP2]], <vscale x 1 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 1 x i32> [[TMP0]]
  //
  vint32mf2_t test_vmulh_vv_i32mf2_tum(vbool64_t mask, vint32mf2_t maskedoff, vint32mf2_t op1, vint32mf2_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 1 x i32> @test_vmulh_vx_i32mf2_tum
  // CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i32> [[MASKEDOFF:%.*]], <vscale x 1 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i32> @llvm.riscv.vmulh.mask.nxv1i32.i32.i64(<vscale x 1 x i32> [[MASKEDOFF]], <vscale x 1 x i32> [[OP1]], i32 [[OP2]], <vscale x 1 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 1 x i32> [[TMP0]]
  //
  vint32mf2_t test_vmulh_vx_i32mf2_tum(vbool64_t mask, vint32mf2_t maskedoff, vint32mf2_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i32> @test_vmulh_vv_i32m1_tum
  // CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i32> [[MASKEDOFF:%.*]], <vscale x 2 x i32> [[OP1:%.*]], <vscale x 2 x i32> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i32> @llvm.riscv.vmulh.mask.nxv2i32.nxv2i32.i64(<vscale x 2 x i32> [[MASKEDOFF]], <vscale x 2 x i32> [[OP1]], <vscale x 2 x i32> [[OP2]], <vscale x 2 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i32> [[TMP0]]
  //
  vint32m1_t test_vmulh_vv_i32m1_tum(vbool32_t mask, vint32m1_t maskedoff, vint32m1_t op1, vint32m1_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i32> @test_vmulh_vx_i32m1_tum
  // CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i32> [[MASKEDOFF:%.*]], <vscale x 2 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i32> @llvm.riscv.vmulh.mask.nxv2i32.i32.i64(<vscale x 2 x i32> [[MASKEDOFF]], <vscale x 2 x i32> [[OP1]], i32 [[OP2]], <vscale x 2 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i32> [[TMP0]]
  //
  vint32m1_t test_vmulh_vx_i32m1_tum(vbool32_t mask, vint32m1_t maskedoff, vint32m1_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i32> @test_vmulh_vv_i32m2_tum
  // CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i32> [[MASKEDOFF:%.*]], <vscale x 4 x i32> [[OP1:%.*]], <vscale x 4 x i32> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i32> @llvm.riscv.vmulh.mask.nxv4i32.nxv4i32.i64(<vscale x 4 x i32> [[MASKEDOFF]], <vscale x 4 x i32> [[OP1]], <vscale x 4 x i32> [[OP2]], <vscale x 4 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i32> [[TMP0]]
  //
  vint32m2_t test_vmulh_vv_i32m2_tum(vbool16_t mask, vint32m2_t maskedoff, vint32m2_t op1, vint32m2_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i32> @test_vmulh_vx_i32m2_tum
  // CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i32> [[MASKEDOFF:%.*]], <vscale x 4 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i32> @llvm.riscv.vmulh.mask.nxv4i32.i32.i64(<vscale x 4 x i32> [[MASKEDOFF]], <vscale x 4 x i32> [[OP1]], i32 [[OP2]], <vscale x 4 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i32> [[TMP0]]
  //
  vint32m2_t test_vmulh_vx_i32m2_tum(vbool16_t mask, vint32m2_t maskedoff, vint32m2_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i32> @test_vmulh_vv_i32m4_tum
  // CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i32> [[MASKEDOFF:%.*]], <vscale x 8 x i32> [[OP1:%.*]], <vscale x 8 x i32> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i32> @llvm.riscv.vmulh.mask.nxv8i32.nxv8i32.i64(<vscale x 8 x i32> [[MASKEDOFF]], <vscale x 8 x i32> [[OP1]], <vscale x 8 x i32> [[OP2]], <vscale x 8 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i32> [[TMP0]]
  //
  vint32m4_t test_vmulh_vv_i32m4_tum(vbool8_t mask, vint32m4_t maskedoff, vint32m4_t op1, vint32m4_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i32> @test_vmulh_vx_i32m4_tum
  // CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i32> [[MASKEDOFF:%.*]], <vscale x 8 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i32> @llvm.riscv.vmulh.mask.nxv8i32.i32.i64(<vscale x 8 x i32> [[MASKEDOFF]], <vscale x 8 x i32> [[OP1]], i32 [[OP2]], <vscale x 8 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i32> [[TMP0]]
  //
  vint32m4_t test_vmulh_vx_i32m4_tum(vbool8_t mask, vint32m4_t maskedoff, vint32m4_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 16 x i32> @test_vmulh_vv_i32m8_tum
  // CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i32> [[MASKEDOFF:%.*]], <vscale x 16 x i32> [[OP1:%.*]], <vscale x 16 x i32> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i32> @llvm.riscv.vmulh.mask.nxv16i32.nxv16i32.i64(<vscale x 16 x i32> [[MASKEDOFF]], <vscale x 16 x i32> [[OP1]], <vscale x 16 x i32> [[OP2]], <vscale x 16 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 16 x i32> [[TMP0]]
  //
  vint32m8_t test_vmulh_vv_i32m8_tum(vbool4_t mask, vint32m8_t maskedoff, vint32m8_t op1, vint32m8_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 16 x i32> @test_vmulh_vx_i32m8_tum
  // CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i32> [[MASKEDOFF:%.*]], <vscale x 16 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i32> @llvm.riscv.vmulh.mask.nxv16i32.i32.i64(<vscale x 16 x i32> [[MASKEDOFF]], <vscale x 16 x i32> [[OP1]], i32 [[OP2]], <vscale x 16 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 16 x i32> [[TMP0]]
  //
  vint32m8_t test_vmulh_vx_i32m8_tum(vbool4_t mask, vint32m8_t maskedoff, vint32m8_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 1 x i64> @test_vmulh_vv_i64m1_tum
  // CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i64> [[MASKEDOFF:%.*]], <vscale x 1 x i64> [[OP1:%.*]], <vscale x 1 x i64> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i64> @llvm.riscv.vmulh.mask.nxv1i64.nxv1i64.i64(<vscale x 1 x i64> [[MASKEDOFF]], <vscale x 1 x i64> [[OP1]], <vscale x 1 x i64> [[OP2]], <vscale x 1 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 1 x i64> [[TMP0]]
  //
  vint64m1_t test_vmulh_vv_i64m1_tum(vbool64_t mask, vint64m1_t maskedoff, vint64m1_t op1, vint64m1_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 1 x i64> @test_vmulh_vx_i64m1_tum
  // CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i64> [[MASKEDOFF:%.*]], <vscale x 1 x i64> [[OP1:%.*]], i64 noundef [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i64> @llvm.riscv.vmulh.mask.nxv1i64.i64.i64(<vscale x 1 x i64> [[MASKEDOFF]], <vscale x 1 x i64> [[OP1]], i64 [[OP2]], <vscale x 1 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 1 x i64> [[TMP0]]
  //
  vint64m1_t test_vmulh_vx_i64m1_tum(vbool64_t mask, vint64m1_t maskedoff, vint64m1_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i64> @test_vmulh_vv_i64m2_tum
  // CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i64> [[MASKEDOFF:%.*]], <vscale x 2 x i64> [[OP1:%.*]], <vscale x 2 x i64> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i64> @llvm.riscv.vmulh.mask.nxv2i64.nxv2i64.i64(<vscale x 2 x i64> [[MASKEDOFF]], <vscale x 2 x i64> [[OP1]], <vscale x 2 x i64> [[OP2]], <vscale x 2 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i64> [[TMP0]]
  //
  vint64m2_t test_vmulh_vv_i64m2_tum(vbool32_t mask, vint64m2_t maskedoff, vint64m2_t op1, vint64m2_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i64> @test_vmulh_vx_i64m2_tum
  // CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i64> [[MASKEDOFF:%.*]], <vscale x 2 x i64> [[OP1:%.*]], i64 noundef [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i64> @llvm.riscv.vmulh.mask.nxv2i64.i64.i64(<vscale x 2 x i64> [[MASKEDOFF]], <vscale x 2 x i64> [[OP1]], i64 [[OP2]], <vscale x 2 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i64> [[TMP0]]
  //
  vint64m2_t test_vmulh_vx_i64m2_tum(vbool32_t mask, vint64m2_t maskedoff, vint64m2_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i64> @test_vmulh_vv_i64m4_tum
  // CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i64> [[MASKEDOFF:%.*]], <vscale x 4 x i64> [[OP1:%.*]], <vscale x 4 x i64> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i64> @llvm.riscv.vmulh.mask.nxv4i64.nxv4i64.i64(<vscale x 4 x i64> [[MASKEDOFF]], <vscale x 4 x i64> [[OP1]], <vscale x 4 x i64> [[OP2]], <vscale x 4 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i64> [[TMP0]]
  //
  vint64m4_t test_vmulh_vv_i64m4_tum(vbool16_t mask, vint64m4_t maskedoff, vint64m4_t op1, vint64m4_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i64> @test_vmulh_vx_i64m4_tum
  // CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i64> [[MASKEDOFF:%.*]], <vscale x 4 x i64> [[OP1:%.*]], i64 noundef [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i64> @llvm.riscv.vmulh.mask.nxv4i64.i64.i64(<vscale x 4 x i64> [[MASKEDOFF]], <vscale x 4 x i64> [[OP1]], i64 [[OP2]], <vscale x 4 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i64> [[TMP0]]
  //
  vint64m4_t test_vmulh_vx_i64m4_tum(vbool16_t mask, vint64m4_t maskedoff, vint64m4_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i64> @test_vmulh_vv_i64m8_tum
  // CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i64> [[MASKEDOFF:%.*]], <vscale x 8 x i64> [[OP1:%.*]], <vscale x 8 x i64> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i64> @llvm.riscv.vmulh.mask.nxv8i64.nxv8i64.i64(<vscale x 8 x i64> [[MASKEDOFF]], <vscale x 8 x i64> [[OP1]], <vscale x 8 x i64> [[OP2]], <vscale x 8 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i64> [[TMP0]]
  //
  vint64m8_t test_vmulh_vv_i64m8_tum(vbool8_t mask, vint64m8_t maskedoff, vint64m8_t op1, vint64m8_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i64> @test_vmulh_vx_i64m8_tum
  // CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i64> [[MASKEDOFF:%.*]], <vscale x 8 x i64> [[OP1:%.*]], i64 noundef [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i64> @llvm.riscv.vmulh.mask.nxv8i64.i64.i64(<vscale x 8 x i64> [[MASKEDOFF]], <vscale x 8 x i64> [[OP1]], i64 [[OP2]], <vscale x 8 x i1> [[MASK]], i64 [[VL]], i64 2)
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i64> [[TMP0]]
  //
  vint64m8_t test_vmulh_vx_i64m8_tum(vbool8_t mask, vint64m8_t maskedoff, vint64m8_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 1 x i8> @test_vmulh_vv_i8mf8_tumu
  // CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i8> [[MASKEDOFF:%.*]], <vscale x 1 x i8> [[OP1:%.*]], <vscale x 1 x i8> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i8> @llvm.riscv.vmulh.mask.nxv1i8.nxv1i8.i64(<vscale x 1 x i8> [[MASKEDOFF]], <vscale x 1 x i8> [[OP1]], <vscale x 1 x i8> [[OP2]], <vscale x 1 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 1 x i8> [[TMP0]]
  //
  vint8mf8_t test_vmulh_vv_i8mf8_tumu(vbool64_t mask, vint8mf8_t maskedoff, vint8mf8_t op1, vint8mf8_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 1 x i8> @test_vmulh_vx_i8mf8_tumu
  // CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i8> [[MASKEDOFF:%.*]], <vscale x 1 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i8> @llvm.riscv.vmulh.mask.nxv1i8.i8.i64(<vscale x 1 x i8> [[MASKEDOFF]], <vscale x 1 x i8> [[OP1]], i8 [[OP2]], <vscale x 1 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 1 x i8> [[TMP0]]
  //
  vint8mf8_t test_vmulh_vx_i8mf8_tumu(vbool64_t mask, vint8mf8_t maskedoff, vint8mf8_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i8> @test_vmulh_vv_i8mf4_tumu
  // CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i8> [[MASKEDOFF:%.*]], <vscale x 2 x i8> [[OP1:%.*]], <vscale x 2 x i8> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i8> @llvm.riscv.vmulh.mask.nxv2i8.nxv2i8.i64(<vscale x 2 x i8> [[MASKEDOFF]], <vscale x 2 x i8> [[OP1]], <vscale x 2 x i8> [[OP2]], <vscale x 2 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i8> [[TMP0]]
  //
  vint8mf4_t test_vmulh_vv_i8mf4_tumu(vbool32_t mask, vint8mf4_t maskedoff, vint8mf4_t op1, vint8mf4_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i8> @test_vmulh_vx_i8mf4_tumu
  // CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i8> [[MASKEDOFF:%.*]], <vscale x 2 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i8> @llvm.riscv.vmulh.mask.nxv2i8.i8.i64(<vscale x 2 x i8> [[MASKEDOFF]], <vscale x 2 x i8> [[OP1]], i8 [[OP2]], <vscale x 2 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i8> [[TMP0]]
  //
  vint8mf4_t test_vmulh_vx_i8mf4_tumu(vbool32_t mask, vint8mf4_t maskedoff, vint8mf4_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i8> @test_vmulh_vv_i8mf2_tumu
  // CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i8> [[MASKEDOFF:%.*]], <vscale x 4 x i8> [[OP1:%.*]], <vscale x 4 x i8> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i8> @llvm.riscv.vmulh.mask.nxv4i8.nxv4i8.i64(<vscale x 4 x i8> [[MASKEDOFF]], <vscale x 4 x i8> [[OP1]], <vscale x 4 x i8> [[OP2]], <vscale x 4 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i8> [[TMP0]]
  //
  vint8mf2_t test_vmulh_vv_i8mf2_tumu(vbool16_t mask, vint8mf2_t maskedoff, vint8mf2_t op1, vint8mf2_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i8> @test_vmulh_vx_i8mf2_tumu
  // CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i8> [[MASKEDOFF:%.*]], <vscale x 4 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i8> @llvm.riscv.vmulh.mask.nxv4i8.i8.i64(<vscale x 4 x i8> [[MASKEDOFF]], <vscale x 4 x i8> [[OP1]], i8 [[OP2]], <vscale x 4 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i8> [[TMP0]]
  //
  vint8mf2_t test_vmulh_vx_i8mf2_tumu(vbool16_t mask, vint8mf2_t maskedoff, vint8mf2_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i8> @test_vmulh_vv_i8m1_tumu
  // CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i8> [[MASKEDOFF:%.*]], <vscale x 8 x i8> [[OP1:%.*]], <vscale x 8 x i8> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i8> @llvm.riscv.vmulh.mask.nxv8i8.nxv8i8.i64(<vscale x 8 x i8> [[MASKEDOFF]], <vscale x 8 x i8> [[OP1]], <vscale x 8 x i8> [[OP2]], <vscale x 8 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i8> [[TMP0]]
  //
  vint8m1_t test_vmulh_vv_i8m1_tumu(vbool8_t mask, vint8m1_t maskedoff, vint8m1_t op1, vint8m1_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i8> @test_vmulh_vx_i8m1_tumu
  // CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i8> [[MASKEDOFF:%.*]], <vscale x 8 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i8> @llvm.riscv.vmulh.mask.nxv8i8.i8.i64(<vscale x 8 x i8> [[MASKEDOFF]], <vscale x 8 x i8> [[OP1]], i8 [[OP2]], <vscale x 8 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i8> [[TMP0]]
  //
  vint8m1_t test_vmulh_vx_i8m1_tumu(vbool8_t mask, vint8m1_t maskedoff, vint8m1_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 16 x i8> @test_vmulh_vv_i8m2_tumu
  // CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i8> [[MASKEDOFF:%.*]], <vscale x 16 x i8> [[OP1:%.*]], <vscale x 16 x i8> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i8> @llvm.riscv.vmulh.mask.nxv16i8.nxv16i8.i64(<vscale x 16 x i8> [[MASKEDOFF]], <vscale x 16 x i8> [[OP1]], <vscale x 16 x i8> [[OP2]], <vscale x 16 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 16 x i8> [[TMP0]]
  //
  vint8m2_t test_vmulh_vv_i8m2_tumu(vbool4_t mask, vint8m2_t maskedoff, vint8m2_t op1, vint8m2_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 16 x i8> @test_vmulh_vx_i8m2_tumu
  // CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i8> [[MASKEDOFF:%.*]], <vscale x 16 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i8> @llvm.riscv.vmulh.mask.nxv16i8.i8.i64(<vscale x 16 x i8> [[MASKEDOFF]], <vscale x 16 x i8> [[OP1]], i8 [[OP2]], <vscale x 16 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 16 x i8> [[TMP0]]
  //
  vint8m2_t test_vmulh_vx_i8m2_tumu(vbool4_t mask, vint8m2_t maskedoff, vint8m2_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 32 x i8> @test_vmulh_vv_i8m4_tumu
  // CHECK-RV64-SAME: (<vscale x 32 x i1> [[MASK:%.*]], <vscale x 32 x i8> [[MASKEDOFF:%.*]], <vscale x 32 x i8> [[OP1:%.*]], <vscale x 32 x i8> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i8> @llvm.riscv.vmulh.mask.nxv32i8.nxv32i8.i64(<vscale x 32 x i8> [[MASKEDOFF]], <vscale x 32 x i8> [[OP1]], <vscale x 32 x i8> [[OP2]], <vscale x 32 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 32 x i8> [[TMP0]]
  //
  vint8m4_t test_vmulh_vv_i8m4_tumu(vbool2_t mask, vint8m4_t maskedoff, vint8m4_t op1, vint8m4_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 32 x i8> @test_vmulh_vx_i8m4_tumu
  // CHECK-RV64-SAME: (<vscale x 32 x i1> [[MASK:%.*]], <vscale x 32 x i8> [[MASKEDOFF:%.*]], <vscale x 32 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i8> @llvm.riscv.vmulh.mask.nxv32i8.i8.i64(<vscale x 32 x i8> [[MASKEDOFF]], <vscale x 32 x i8> [[OP1]], i8 [[OP2]], <vscale x 32 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 32 x i8> [[TMP0]]
  //
  vint8m4_t test_vmulh_vx_i8m4_tumu(vbool2_t mask, vint8m4_t maskedoff, vint8m4_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 64 x i8> @test_vmulh_vv_i8m8_tumu
  // CHECK-RV64-SAME: (<vscale x 64 x i1> [[MASK:%.*]], <vscale x 64 x i8> [[MASKEDOFF:%.*]], <vscale x 64 x i8> [[OP1:%.*]], <vscale x 64 x i8> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 64 x i8> @llvm.riscv.vmulh.mask.nxv64i8.nxv64i8.i64(<vscale x 64 x i8> [[MASKEDOFF]], <vscale x 64 x i8> [[OP1]], <vscale x 64 x i8> [[OP2]], <vscale x 64 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 64 x i8> [[TMP0]]
  //
  vint8m8_t test_vmulh_vv_i8m8_tumu(vbool1_t mask, vint8m8_t maskedoff, vint8m8_t op1, vint8m8_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 64 x i8> @test_vmulh_vx_i8m8_tumu
  // CHECK-RV64-SAME: (<vscale x 64 x i1> [[MASK:%.*]], <vscale x 64 x i8> [[MASKEDOFF:%.*]], <vscale x 64 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 64 x i8> @llvm.riscv.vmulh.mask.nxv64i8.i8.i64(<vscale x 64 x i8> [[MASKEDOFF]], <vscale x 64 x i8> [[OP1]], i8 [[OP2]], <vscale x 64 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 64 x i8> [[TMP0]]
  //
  vint8m8_t test_vmulh_vx_i8m8_tumu(vbool1_t mask, vint8m8_t maskedoff, vint8m8_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 1 x i16> @test_vmulh_vv_i16mf4_tumu
  // CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i16> [[MASKEDOFF:%.*]], <vscale x 1 x i16> [[OP1:%.*]], <vscale x 1 x i16> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i16> @llvm.riscv.vmulh.mask.nxv1i16.nxv1i16.i64(<vscale x 1 x i16> [[MASKEDOFF]], <vscale x 1 x i16> [[OP1]], <vscale x 1 x i16> [[OP2]], <vscale x 1 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 1 x i16> [[TMP0]]
  //
  vint16mf4_t test_vmulh_vv_i16mf4_tumu(vbool64_t mask, vint16mf4_t maskedoff, vint16mf4_t op1, vint16mf4_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 1 x i16> @test_vmulh_vx_i16mf4_tumu
  // CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i16> [[MASKEDOFF:%.*]], <vscale x 1 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i16> @llvm.riscv.vmulh.mask.nxv1i16.i16.i64(<vscale x 1 x i16> [[MASKEDOFF]], <vscale x 1 x i16> [[OP1]], i16 [[OP2]], <vscale x 1 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 1 x i16> [[TMP0]]
  //
  vint16mf4_t test_vmulh_vx_i16mf4_tumu(vbool64_t mask, vint16mf4_t maskedoff, vint16mf4_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i16> @test_vmulh_vv_i16mf2_tumu
  // CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i16> [[MASKEDOFF:%.*]], <vscale x 2 x i16> [[OP1:%.*]], <vscale x 2 x i16> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i16> @llvm.riscv.vmulh.mask.nxv2i16.nxv2i16.i64(<vscale x 2 x i16> [[MASKEDOFF]], <vscale x 2 x i16> [[OP1]], <vscale x 2 x i16> [[OP2]], <vscale x 2 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i16> [[TMP0]]
  //
  vint16mf2_t test_vmulh_vv_i16mf2_tumu(vbool32_t mask, vint16mf2_t maskedoff, vint16mf2_t op1, vint16mf2_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i16> @test_vmulh_vx_i16mf2_tumu
  // CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i16> [[MASKEDOFF:%.*]], <vscale x 2 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i16> @llvm.riscv.vmulh.mask.nxv2i16.i16.i64(<vscale x 2 x i16> [[MASKEDOFF]], <vscale x 2 x i16> [[OP1]], i16 [[OP2]], <vscale x 2 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i16> [[TMP0]]
  //
  vint16mf2_t test_vmulh_vx_i16mf2_tumu(vbool32_t mask, vint16mf2_t maskedoff, vint16mf2_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i16> @test_vmulh_vv_i16m1_tumu
  // CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i16> [[MASKEDOFF:%.*]], <vscale x 4 x i16> [[OP1:%.*]], <vscale x 4 x i16> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i16> @llvm.riscv.vmulh.mask.nxv4i16.nxv4i16.i64(<vscale x 4 x i16> [[MASKEDOFF]], <vscale x 4 x i16> [[OP1]], <vscale x 4 x i16> [[OP2]], <vscale x 4 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i16> [[TMP0]]
  //
  vint16m1_t test_vmulh_vv_i16m1_tumu(vbool16_t mask, vint16m1_t maskedoff, vint16m1_t op1, vint16m1_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i16> @test_vmulh_vx_i16m1_tumu
  // CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i16> [[MASKEDOFF:%.*]], <vscale x 4 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i16> @llvm.riscv.vmulh.mask.nxv4i16.i16.i64(<vscale x 4 x i16> [[MASKEDOFF]], <vscale x 4 x i16> [[OP1]], i16 [[OP2]], <vscale x 4 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i16> [[TMP0]]
  //
  vint16m1_t test_vmulh_vx_i16m1_tumu(vbool16_t mask, vint16m1_t maskedoff, vint16m1_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i16> @test_vmulh_vv_i16m2_tumu
  // CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i16> [[MASKEDOFF:%.*]], <vscale x 8 x i16> [[OP1:%.*]], <vscale x 8 x i16> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i16> @llvm.riscv.vmulh.mask.nxv8i16.nxv8i16.i64(<vscale x 8 x i16> [[MASKEDOFF]], <vscale x 8 x i16> [[OP1]], <vscale x 8 x i16> [[OP2]], <vscale x 8 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i16> [[TMP0]]
  //
  vint16m2_t test_vmulh_vv_i16m2_tumu(vbool8_t mask, vint16m2_t maskedoff, vint16m2_t op1, vint16m2_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i16> @test_vmulh_vx_i16m2_tumu
  // CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i16> [[MASKEDOFF:%.*]], <vscale x 8 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i16> @llvm.riscv.vmulh.mask.nxv8i16.i16.i64(<vscale x 8 x i16> [[MASKEDOFF]], <vscale x 8 x i16> [[OP1]], i16 [[OP2]], <vscale x 8 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i16> [[TMP0]]
  //
  vint16m2_t test_vmulh_vx_i16m2_tumu(vbool8_t mask, vint16m2_t maskedoff, vint16m2_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 16 x i16> @test_vmulh_vv_i16m4_tumu
  // CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i16> [[MASKEDOFF:%.*]], <vscale x 16 x i16> [[OP1:%.*]], <vscale x 16 x i16> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i16> @llvm.riscv.vmulh.mask.nxv16i16.nxv16i16.i64(<vscale x 16 x i16> [[MASKEDOFF]], <vscale x 16 x i16> [[OP1]], <vscale x 16 x i16> [[OP2]], <vscale x 16 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 16 x i16> [[TMP0]]
  //
  vint16m4_t test_vmulh_vv_i16m4_tumu(vbool4_t mask, vint16m4_t maskedoff, vint16m4_t op1, vint16m4_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 16 x i16> @test_vmulh_vx_i16m4_tumu
  // CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i16> [[MASKEDOFF:%.*]], <vscale x 16 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i16> @llvm.riscv.vmulh.mask.nxv16i16.i16.i64(<vscale x 16 x i16> [[MASKEDOFF]], <vscale x 16 x i16> [[OP1]], i16 [[OP2]], <vscale x 16 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 16 x i16> [[TMP0]]
  //
  vint16m4_t test_vmulh_vx_i16m4_tumu(vbool4_t mask, vint16m4_t maskedoff, vint16m4_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 32 x i16> @test_vmulh_vv_i16m8_tumu
  // CHECK-RV64-SAME: (<vscale x 32 x i1> [[MASK:%.*]], <vscale x 32 x i16> [[MASKEDOFF:%.*]], <vscale x 32 x i16> [[OP1:%.*]], <vscale x 32 x i16> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i16> @llvm.riscv.vmulh.mask.nxv32i16.nxv32i16.i64(<vscale x 32 x i16> [[MASKEDOFF]], <vscale x 32 x i16> [[OP1]], <vscale x 32 x i16> [[OP2]], <vscale x 32 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 32 x i16> [[TMP0]]
  //
  vint16m8_t test_vmulh_vv_i16m8_tumu(vbool2_t mask, vint16m8_t maskedoff, vint16m8_t op1, vint16m8_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 32 x i16> @test_vmulh_vx_i16m8_tumu
  // CHECK-RV64-SAME: (<vscale x 32 x i1> [[MASK:%.*]], <vscale x 32 x i16> [[MASKEDOFF:%.*]], <vscale x 32 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i16> @llvm.riscv.vmulh.mask.nxv32i16.i16.i64(<vscale x 32 x i16> [[MASKEDOFF]], <vscale x 32 x i16> [[OP1]], i16 [[OP2]], <vscale x 32 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 32 x i16> [[TMP0]]
  //
  vint16m8_t test_vmulh_vx_i16m8_tumu(vbool2_t mask, vint16m8_t maskedoff, vint16m8_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 1 x i32> @test_vmulh_vv_i32mf2_tumu
  // CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i32> [[MASKEDOFF:%.*]], <vscale x 1 x i32> [[OP1:%.*]], <vscale x 1 x i32> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i32> @llvm.riscv.vmulh.mask.nxv1i32.nxv1i32.i64(<vscale x 1 x i32> [[MASKEDOFF]], <vscale x 1 x i32> [[OP1]], <vscale x 1 x i32> [[OP2]], <vscale x 1 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 1 x i32> [[TMP0]]
  //
  vint32mf2_t test_vmulh_vv_i32mf2_tumu(vbool64_t mask, vint32mf2_t maskedoff, vint32mf2_t op1, vint32mf2_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 1 x i32> @test_vmulh_vx_i32mf2_tumu
  // CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i32> [[MASKEDOFF:%.*]], <vscale x 1 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i32> @llvm.riscv.vmulh.mask.nxv1i32.i32.i64(<vscale x 1 x i32> [[MASKEDOFF]], <vscale x 1 x i32> [[OP1]], i32 [[OP2]], <vscale x 1 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 1 x i32> [[TMP0]]
  //
  vint32mf2_t test_vmulh_vx_i32mf2_tumu(vbool64_t mask, vint32mf2_t maskedoff, vint32mf2_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i32> @test_vmulh_vv_i32m1_tumu
  // CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i32> [[MASKEDOFF:%.*]], <vscale x 2 x i32> [[OP1:%.*]], <vscale x 2 x i32> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i32> @llvm.riscv.vmulh.mask.nxv2i32.nxv2i32.i64(<vscale x 2 x i32> [[MASKEDOFF]], <vscale x 2 x i32> [[OP1]], <vscale x 2 x i32> [[OP2]], <vscale x 2 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i32> [[TMP0]]
  //
  vint32m1_t test_vmulh_vv_i32m1_tumu(vbool32_t mask, vint32m1_t maskedoff, vint32m1_t op1, vint32m1_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i32> @test_vmulh_vx_i32m1_tumu
  // CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i32> [[MASKEDOFF:%.*]], <vscale x 2 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i32> @llvm.riscv.vmulh.mask.nxv2i32.i32.i64(<vscale x 2 x i32> [[MASKEDOFF]], <vscale x 2 x i32> [[OP1]], i32 [[OP2]], <vscale x 2 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i32> [[TMP0]]
  //
  vint32m1_t test_vmulh_vx_i32m1_tumu(vbool32_t mask, vint32m1_t maskedoff, vint32m1_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i32> @test_vmulh_vv_i32m2_tumu
  // CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i32> [[MASKEDOFF:%.*]], <vscale x 4 x i32> [[OP1:%.*]], <vscale x 4 x i32> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i32> @llvm.riscv.vmulh.mask.nxv4i32.nxv4i32.i64(<vscale x 4 x i32> [[MASKEDOFF]], <vscale x 4 x i32> [[OP1]], <vscale x 4 x i32> [[OP2]], <vscale x 4 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i32> [[TMP0]]
  //
  vint32m2_t test_vmulh_vv_i32m2_tumu(vbool16_t mask, vint32m2_t maskedoff, vint32m2_t op1, vint32m2_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i32> @test_vmulh_vx_i32m2_tumu
  // CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i32> [[MASKEDOFF:%.*]], <vscale x 4 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i32> @llvm.riscv.vmulh.mask.nxv4i32.i32.i64(<vscale x 4 x i32> [[MASKEDOFF]], <vscale x 4 x i32> [[OP1]], i32 [[OP2]], <vscale x 4 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i32> [[TMP0]]
  //
  vint32m2_t test_vmulh_vx_i32m2_tumu(vbool16_t mask, vint32m2_t maskedoff, vint32m2_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i32> @test_vmulh_vv_i32m4_tumu
  // CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i32> [[MASKEDOFF:%.*]], <vscale x 8 x i32> [[OP1:%.*]], <vscale x 8 x i32> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i32> @llvm.riscv.vmulh.mask.nxv8i32.nxv8i32.i64(<vscale x 8 x i32> [[MASKEDOFF]], <vscale x 8 x i32> [[OP1]], <vscale x 8 x i32> [[OP2]], <vscale x 8 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i32> [[TMP0]]
  //
  vint32m4_t test_vmulh_vv_i32m4_tumu(vbool8_t mask, vint32m4_t maskedoff, vint32m4_t op1, vint32m4_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i32> @test_vmulh_vx_i32m4_tumu
  // CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i32> [[MASKEDOFF:%.*]], <vscale x 8 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i32> @llvm.riscv.vmulh.mask.nxv8i32.i32.i64(<vscale x 8 x i32> [[MASKEDOFF]], <vscale x 8 x i32> [[OP1]], i32 [[OP2]], <vscale x 8 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i32> [[TMP0]]
  //
  vint32m4_t test_vmulh_vx_i32m4_tumu(vbool8_t mask, vint32m4_t maskedoff, vint32m4_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 16 x i32> @test_vmulh_vv_i32m8_tumu
  // CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i32> [[MASKEDOFF:%.*]], <vscale x 16 x i32> [[OP1:%.*]], <vscale x 16 x i32> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i32> @llvm.riscv.vmulh.mask.nxv16i32.nxv16i32.i64(<vscale x 16 x i32> [[MASKEDOFF]], <vscale x 16 x i32> [[OP1]], <vscale x 16 x i32> [[OP2]], <vscale x 16 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 16 x i32> [[TMP0]]
  //
  vint32m8_t test_vmulh_vv_i32m8_tumu(vbool4_t mask, vint32m8_t maskedoff, vint32m8_t op1, vint32m8_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 16 x i32> @test_vmulh_vx_i32m8_tumu
  // CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i32> [[MASKEDOFF:%.*]], <vscale x 16 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i32> @llvm.riscv.vmulh.mask.nxv16i32.i32.i64(<vscale x 16 x i32> [[MASKEDOFF]], <vscale x 16 x i32> [[OP1]], i32 [[OP2]], <vscale x 16 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 16 x i32> [[TMP0]]
  //
  vint32m8_t test_vmulh_vx_i32m8_tumu(vbool4_t mask, vint32m8_t maskedoff, vint32m8_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 1 x i64> @test_vmulh_vv_i64m1_tumu
  // CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i64> [[MASKEDOFF:%.*]], <vscale x 1 x i64> [[OP1:%.*]], <vscale x 1 x i64> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i64> @llvm.riscv.vmulh.mask.nxv1i64.nxv1i64.i64(<vscale x 1 x i64> [[MASKEDOFF]], <vscale x 1 x i64> [[OP1]], <vscale x 1 x i64> [[OP2]], <vscale x 1 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 1 x i64> [[TMP0]]
  //
  vint64m1_t test_vmulh_vv_i64m1_tumu(vbool64_t mask, vint64m1_t maskedoff, vint64m1_t op1, vint64m1_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 1 x i64> @test_vmulh_vx_i64m1_tumu
  // CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i64> [[MASKEDOFF:%.*]], <vscale x 1 x i64> [[OP1:%.*]], i64 noundef [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i64> @llvm.riscv.vmulh.mask.nxv1i64.i64.i64(<vscale x 1 x i64> [[MASKEDOFF]], <vscale x 1 x i64> [[OP1]], i64 [[OP2]], <vscale x 1 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 1 x i64> [[TMP0]]
  //
  vint64m1_t test_vmulh_vx_i64m1_tumu(vbool64_t mask, vint64m1_t maskedoff, vint64m1_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i64> @test_vmulh_vv_i64m2_tumu
  // CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i64> [[MASKEDOFF:%.*]], <vscale x 2 x i64> [[OP1:%.*]], <vscale x 2 x i64> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i64> @llvm.riscv.vmulh.mask.nxv2i64.nxv2i64.i64(<vscale x 2 x i64> [[MASKEDOFF]], <vscale x 2 x i64> [[OP1]], <vscale x 2 x i64> [[OP2]], <vscale x 2 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i64> [[TMP0]]
  //
  vint64m2_t test_vmulh_vv_i64m2_tumu(vbool32_t mask, vint64m2_t maskedoff, vint64m2_t op1, vint64m2_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i64> @test_vmulh_vx_i64m2_tumu
  // CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i64> [[MASKEDOFF:%.*]], <vscale x 2 x i64> [[OP1:%.*]], i64 noundef [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i64> @llvm.riscv.vmulh.mask.nxv2i64.i64.i64(<vscale x 2 x i64> [[MASKEDOFF]], <vscale x 2 x i64> [[OP1]], i64 [[OP2]], <vscale x 2 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i64> [[TMP0]]
  //
  vint64m2_t test_vmulh_vx_i64m2_tumu(vbool32_t mask, vint64m2_t maskedoff, vint64m2_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i64> @test_vmulh_vv_i64m4_tumu
  // CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i64> [[MASKEDOFF:%.*]], <vscale x 4 x i64> [[OP1:%.*]], <vscale x 4 x i64> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i64> @llvm.riscv.vmulh.mask.nxv4i64.nxv4i64.i64(<vscale x 4 x i64> [[MASKEDOFF]], <vscale x 4 x i64> [[OP1]], <vscale x 4 x i64> [[OP2]], <vscale x 4 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i64> [[TMP0]]
  //
  vint64m4_t test_vmulh_vv_i64m4_tumu(vbool16_t mask, vint64m4_t maskedoff, vint64m4_t op1, vint64m4_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i64> @test_vmulh_vx_i64m4_tumu
  // CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i64> [[MASKEDOFF:%.*]], <vscale x 4 x i64> [[OP1:%.*]], i64 noundef [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i64> @llvm.riscv.vmulh.mask.nxv4i64.i64.i64(<vscale x 4 x i64> [[MASKEDOFF]], <vscale x 4 x i64> [[OP1]], i64 [[OP2]], <vscale x 4 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i64> [[TMP0]]
  //
  vint64m4_t test_vmulh_vx_i64m4_tumu(vbool16_t mask, vint64m4_t maskedoff, vint64m4_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i64> @test_vmulh_vv_i64m8_tumu
  // CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i64> [[MASKEDOFF:%.*]], <vscale x 8 x i64> [[OP1:%.*]], <vscale x 8 x i64> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i64> @llvm.riscv.vmulh.mask.nxv8i64.nxv8i64.i64(<vscale x 8 x i64> [[MASKEDOFF]], <vscale x 8 x i64> [[OP1]], <vscale x 8 x i64> [[OP2]], <vscale x 8 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i64> [[TMP0]]
  //
  vint64m8_t test_vmulh_vv_i64m8_tumu(vbool8_t mask, vint64m8_t maskedoff, vint64m8_t op1, vint64m8_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i64> @test_vmulh_vx_i64m8_tumu
  // CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i64> [[MASKEDOFF:%.*]], <vscale x 8 x i64> [[OP1:%.*]], i64 noundef [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i64> @llvm.riscv.vmulh.mask.nxv8i64.i64.i64(<vscale x 8 x i64> [[MASKEDOFF]], <vscale x 8 x i64> [[OP1]], i64 [[OP2]], <vscale x 8 x i1> [[MASK]], i64 [[VL]], i64 0)
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i64> [[TMP0]]
  //
  vint64m8_t test_vmulh_vx_i64m8_tumu(vbool8_t mask, vint64m8_t maskedoff, vint64m8_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 1 x i8> @test_vmulh_vv_i8mf8_mu
  // CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i8> [[MASKEDOFF:%.*]], <vscale x 1 x i8> [[OP1:%.*]], <vscale x 1 x i8> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i8> @llvm.riscv.vmulh.mask.nxv1i8.nxv1i8.i64(<vscale x 1 x i8> [[MASKEDOFF]], <vscale x 1 x i8> [[OP1]], <vscale x 1 x i8> [[OP2]], <vscale x 1 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 1 x i8> [[TMP0]]
  //
  vint8mf8_t test_vmulh_vv_i8mf8_mu(vbool64_t mask, vint8mf8_t maskedoff, vint8mf8_t op1, vint8mf8_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 1 x i8> @test_vmulh_vx_i8mf8_mu
  // CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i8> [[MASKEDOFF:%.*]], <vscale x 1 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i8> @llvm.riscv.vmulh.mask.nxv1i8.i8.i64(<vscale x 1 x i8> [[MASKEDOFF]], <vscale x 1 x i8> [[OP1]], i8 [[OP2]], <vscale x 1 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 1 x i8> [[TMP0]]
  //
  vint8mf8_t test_vmulh_vx_i8mf8_mu(vbool64_t mask, vint8mf8_t maskedoff, vint8mf8_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i8> @test_vmulh_vv_i8mf4_mu
  // CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i8> [[MASKEDOFF:%.*]], <vscale x 2 x i8> [[OP1:%.*]], <vscale x 2 x i8> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i8> @llvm.riscv.vmulh.mask.nxv2i8.nxv2i8.i64(<vscale x 2 x i8> [[MASKEDOFF]], <vscale x 2 x i8> [[OP1]], <vscale x 2 x i8> [[OP2]], <vscale x 2 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i8> [[TMP0]]
  //
  vint8mf4_t test_vmulh_vv_i8mf4_mu(vbool32_t mask, vint8mf4_t maskedoff, vint8mf4_t op1, vint8mf4_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i8> @test_vmulh_vx_i8mf4_mu
  // CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i8> [[MASKEDOFF:%.*]], <vscale x 2 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i8> @llvm.riscv.vmulh.mask.nxv2i8.i8.i64(<vscale x 2 x i8> [[MASKEDOFF]], <vscale x 2 x i8> [[OP1]], i8 [[OP2]], <vscale x 2 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i8> [[TMP0]]
  //
  vint8mf4_t test_vmulh_vx_i8mf4_mu(vbool32_t mask, vint8mf4_t maskedoff, vint8mf4_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i8> @test_vmulh_vv_i8mf2_mu
  // CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i8> [[MASKEDOFF:%.*]], <vscale x 4 x i8> [[OP1:%.*]], <vscale x 4 x i8> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i8> @llvm.riscv.vmulh.mask.nxv4i8.nxv4i8.i64(<vscale x 4 x i8> [[MASKEDOFF]], <vscale x 4 x i8> [[OP1]], <vscale x 4 x i8> [[OP2]], <vscale x 4 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i8> [[TMP0]]
  //
  vint8mf2_t test_vmulh_vv_i8mf2_mu(vbool16_t mask, vint8mf2_t maskedoff, vint8mf2_t op1, vint8mf2_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i8> @test_vmulh_vx_i8mf2_mu
  // CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i8> [[MASKEDOFF:%.*]], <vscale x 4 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i8> @llvm.riscv.vmulh.mask.nxv4i8.i8.i64(<vscale x 4 x i8> [[MASKEDOFF]], <vscale x 4 x i8> [[OP1]], i8 [[OP2]], <vscale x 4 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i8> [[TMP0]]
  //
  vint8mf2_t test_vmulh_vx_i8mf2_mu(vbool16_t mask, vint8mf2_t maskedoff, vint8mf2_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i8> @test_vmulh_vv_i8m1_mu
  // CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i8> [[MASKEDOFF:%.*]], <vscale x 8 x i8> [[OP1:%.*]], <vscale x 8 x i8> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i8> @llvm.riscv.vmulh.mask.nxv8i8.nxv8i8.i64(<vscale x 8 x i8> [[MASKEDOFF]], <vscale x 8 x i8> [[OP1]], <vscale x 8 x i8> [[OP2]], <vscale x 8 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i8> [[TMP0]]
  //
  vint8m1_t test_vmulh_vv_i8m1_mu(vbool8_t mask, vint8m1_t maskedoff, vint8m1_t op1, vint8m1_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i8> @test_vmulh_vx_i8m1_mu
  // CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i8> [[MASKEDOFF:%.*]], <vscale x 8 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i8> @llvm.riscv.vmulh.mask.nxv8i8.i8.i64(<vscale x 8 x i8> [[MASKEDOFF]], <vscale x 8 x i8> [[OP1]], i8 [[OP2]], <vscale x 8 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i8> [[TMP0]]
  //
  vint8m1_t test_vmulh_vx_i8m1_mu(vbool8_t mask, vint8m1_t maskedoff, vint8m1_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 16 x i8> @test_vmulh_vv_i8m2_mu
  // CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i8> [[MASKEDOFF:%.*]], <vscale x 16 x i8> [[OP1:%.*]], <vscale x 16 x i8> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i8> @llvm.riscv.vmulh.mask.nxv16i8.nxv16i8.i64(<vscale x 16 x i8> [[MASKEDOFF]], <vscale x 16 x i8> [[OP1]], <vscale x 16 x i8> [[OP2]], <vscale x 16 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 16 x i8> [[TMP0]]
  //
  vint8m2_t test_vmulh_vv_i8m2_mu(vbool4_t mask, vint8m2_t maskedoff, vint8m2_t op1, vint8m2_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 16 x i8> @test_vmulh_vx_i8m2_mu
  // CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i8> [[MASKEDOFF:%.*]], <vscale x 16 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i8> @llvm.riscv.vmulh.mask.nxv16i8.i8.i64(<vscale x 16 x i8> [[MASKEDOFF]], <vscale x 16 x i8> [[OP1]], i8 [[OP2]], <vscale x 16 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 16 x i8> [[TMP0]]
  //
  vint8m2_t test_vmulh_vx_i8m2_mu(vbool4_t mask, vint8m2_t maskedoff, vint8m2_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 32 x i8> @test_vmulh_vv_i8m4_mu
  // CHECK-RV64-SAME: (<vscale x 32 x i1> [[MASK:%.*]], <vscale x 32 x i8> [[MASKEDOFF:%.*]], <vscale x 32 x i8> [[OP1:%.*]], <vscale x 32 x i8> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i8> @llvm.riscv.vmulh.mask.nxv32i8.nxv32i8.i64(<vscale x 32 x i8> [[MASKEDOFF]], <vscale x 32 x i8> [[OP1]], <vscale x 32 x i8> [[OP2]], <vscale x 32 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 32 x i8> [[TMP0]]
  //
  vint8m4_t test_vmulh_vv_i8m4_mu(vbool2_t mask, vint8m4_t maskedoff, vint8m4_t op1, vint8m4_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 32 x i8> @test_vmulh_vx_i8m4_mu
  // CHECK-RV64-SAME: (<vscale x 32 x i1> [[MASK:%.*]], <vscale x 32 x i8> [[MASKEDOFF:%.*]], <vscale x 32 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i8> @llvm.riscv.vmulh.mask.nxv32i8.i8.i64(<vscale x 32 x i8> [[MASKEDOFF]], <vscale x 32 x i8> [[OP1]], i8 [[OP2]], <vscale x 32 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 32 x i8> [[TMP0]]
  //
  vint8m4_t test_vmulh_vx_i8m4_mu(vbool2_t mask, vint8m4_t maskedoff, vint8m4_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 64 x i8> @test_vmulh_vv_i8m8_mu
  // CHECK-RV64-SAME: (<vscale x 64 x i1> [[MASK:%.*]], <vscale x 64 x i8> [[MASKEDOFF:%.*]], <vscale x 64 x i8> [[OP1:%.*]], <vscale x 64 x i8> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 64 x i8> @llvm.riscv.vmulh.mask.nxv64i8.nxv64i8.i64(<vscale x 64 x i8> [[MASKEDOFF]], <vscale x 64 x i8> [[OP1]], <vscale x 64 x i8> [[OP2]], <vscale x 64 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 64 x i8> [[TMP0]]
  //
  vint8m8_t test_vmulh_vv_i8m8_mu(vbool1_t mask, vint8m8_t maskedoff, vint8m8_t op1, vint8m8_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 64 x i8> @test_vmulh_vx_i8m8_mu
  // CHECK-RV64-SAME: (<vscale x 64 x i1> [[MASK:%.*]], <vscale x 64 x i8> [[MASKEDOFF:%.*]], <vscale x 64 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 64 x i8> @llvm.riscv.vmulh.mask.nxv64i8.i8.i64(<vscale x 64 x i8> [[MASKEDOFF]], <vscale x 64 x i8> [[OP1]], i8 [[OP2]], <vscale x 64 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 64 x i8> [[TMP0]]
  //
  vint8m8_t test_vmulh_vx_i8m8_mu(vbool1_t mask, vint8m8_t maskedoff, vint8m8_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 1 x i16> @test_vmulh_vv_i16mf4_mu
  // CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i16> [[MASKEDOFF:%.*]], <vscale x 1 x i16> [[OP1:%.*]], <vscale x 1 x i16> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i16> @llvm.riscv.vmulh.mask.nxv1i16.nxv1i16.i64(<vscale x 1 x i16> [[MASKEDOFF]], <vscale x 1 x i16> [[OP1]], <vscale x 1 x i16> [[OP2]], <vscale x 1 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 1 x i16> [[TMP0]]
  //
  vint16mf4_t test_vmulh_vv_i16mf4_mu(vbool64_t mask, vint16mf4_t maskedoff, vint16mf4_t op1, vint16mf4_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 1 x i16> @test_vmulh_vx_i16mf4_mu
  // CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i16> [[MASKEDOFF:%.*]], <vscale x 1 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i16> @llvm.riscv.vmulh.mask.nxv1i16.i16.i64(<vscale x 1 x i16> [[MASKEDOFF]], <vscale x 1 x i16> [[OP1]], i16 [[OP2]], <vscale x 1 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 1 x i16> [[TMP0]]
  //
  vint16mf4_t test_vmulh_vx_i16mf4_mu(vbool64_t mask, vint16mf4_t maskedoff, vint16mf4_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i16> @test_vmulh_vv_i16mf2_mu
  // CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i16> [[MASKEDOFF:%.*]], <vscale x 2 x i16> [[OP1:%.*]], <vscale x 2 x i16> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i16> @llvm.riscv.vmulh.mask.nxv2i16.nxv2i16.i64(<vscale x 2 x i16> [[MASKEDOFF]], <vscale x 2 x i16> [[OP1]], <vscale x 2 x i16> [[OP2]], <vscale x 2 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i16> [[TMP0]]
  //
  vint16mf2_t test_vmulh_vv_i16mf2_mu(vbool32_t mask, vint16mf2_t maskedoff, vint16mf2_t op1, vint16mf2_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i16> @test_vmulh_vx_i16mf2_mu
  // CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i16> [[MASKEDOFF:%.*]], <vscale x 2 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i16> @llvm.riscv.vmulh.mask.nxv2i16.i16.i64(<vscale x 2 x i16> [[MASKEDOFF]], <vscale x 2 x i16> [[OP1]], i16 [[OP2]], <vscale x 2 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i16> [[TMP0]]
  //
  vint16mf2_t test_vmulh_vx_i16mf2_mu(vbool32_t mask, vint16mf2_t maskedoff, vint16mf2_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i16> @test_vmulh_vv_i16m1_mu
  // CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i16> [[MASKEDOFF:%.*]], <vscale x 4 x i16> [[OP1:%.*]], <vscale x 4 x i16> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i16> @llvm.riscv.vmulh.mask.nxv4i16.nxv4i16.i64(<vscale x 4 x i16> [[MASKEDOFF]], <vscale x 4 x i16> [[OP1]], <vscale x 4 x i16> [[OP2]], <vscale x 4 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i16> [[TMP0]]
  //
  vint16m1_t test_vmulh_vv_i16m1_mu(vbool16_t mask, vint16m1_t maskedoff, vint16m1_t op1, vint16m1_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i16> @test_vmulh_vx_i16m1_mu
  // CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i16> [[MASKEDOFF:%.*]], <vscale x 4 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i16> @llvm.riscv.vmulh.mask.nxv4i16.i16.i64(<vscale x 4 x i16> [[MASKEDOFF]], <vscale x 4 x i16> [[OP1]], i16 [[OP2]], <vscale x 4 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i16> [[TMP0]]
  //
  vint16m1_t test_vmulh_vx_i16m1_mu(vbool16_t mask, vint16m1_t maskedoff, vint16m1_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i16> @test_vmulh_vv_i16m2_mu
  // CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i16> [[MASKEDOFF:%.*]], <vscale x 8 x i16> [[OP1:%.*]], <vscale x 8 x i16> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i16> @llvm.riscv.vmulh.mask.nxv8i16.nxv8i16.i64(<vscale x 8 x i16> [[MASKEDOFF]], <vscale x 8 x i16> [[OP1]], <vscale x 8 x i16> [[OP2]], <vscale x 8 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i16> [[TMP0]]
  //
  vint16m2_t test_vmulh_vv_i16m2_mu(vbool8_t mask, vint16m2_t maskedoff, vint16m2_t op1, vint16m2_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i16> @test_vmulh_vx_i16m2_mu
  // CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i16> [[MASKEDOFF:%.*]], <vscale x 8 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i16> @llvm.riscv.vmulh.mask.nxv8i16.i16.i64(<vscale x 8 x i16> [[MASKEDOFF]], <vscale x 8 x i16> [[OP1]], i16 [[OP2]], <vscale x 8 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i16> [[TMP0]]
  //
  vint16m2_t test_vmulh_vx_i16m2_mu(vbool8_t mask, vint16m2_t maskedoff, vint16m2_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 16 x i16> @test_vmulh_vv_i16m4_mu
  // CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i16> [[MASKEDOFF:%.*]], <vscale x 16 x i16> [[OP1:%.*]], <vscale x 16 x i16> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i16> @llvm.riscv.vmulh.mask.nxv16i16.nxv16i16.i64(<vscale x 16 x i16> [[MASKEDOFF]], <vscale x 16 x i16> [[OP1]], <vscale x 16 x i16> [[OP2]], <vscale x 16 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 16 x i16> [[TMP0]]
  //
  vint16m4_t test_vmulh_vv_i16m4_mu(vbool4_t mask, vint16m4_t maskedoff, vint16m4_t op1, vint16m4_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 16 x i16> @test_vmulh_vx_i16m4_mu
  // CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i16> [[MASKEDOFF:%.*]], <vscale x 16 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i16> @llvm.riscv.vmulh.mask.nxv16i16.i16.i64(<vscale x 16 x i16> [[MASKEDOFF]], <vscale x 16 x i16> [[OP1]], i16 [[OP2]], <vscale x 16 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 16 x i16> [[TMP0]]
  //
  vint16m4_t test_vmulh_vx_i16m4_mu(vbool4_t mask, vint16m4_t maskedoff, vint16m4_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 32 x i16> @test_vmulh_vv_i16m8_mu
  // CHECK-RV64-SAME: (<vscale x 32 x i1> [[MASK:%.*]], <vscale x 32 x i16> [[MASKEDOFF:%.*]], <vscale x 32 x i16> [[OP1:%.*]], <vscale x 32 x i16> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i16> @llvm.riscv.vmulh.mask.nxv32i16.nxv32i16.i64(<vscale x 32 x i16> [[MASKEDOFF]], <vscale x 32 x i16> [[OP1]], <vscale x 32 x i16> [[OP2]], <vscale x 32 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 32 x i16> [[TMP0]]
  //
  vint16m8_t test_vmulh_vv_i16m8_mu(vbool2_t mask, vint16m8_t maskedoff, vint16m8_t op1, vint16m8_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 32 x i16> @test_vmulh_vx_i16m8_mu
  // CHECK-RV64-SAME: (<vscale x 32 x i1> [[MASK:%.*]], <vscale x 32 x i16> [[MASKEDOFF:%.*]], <vscale x 32 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i16> @llvm.riscv.vmulh.mask.nxv32i16.i16.i64(<vscale x 32 x i16> [[MASKEDOFF]], <vscale x 32 x i16> [[OP1]], i16 [[OP2]], <vscale x 32 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 32 x i16> [[TMP0]]
  //
  vint16m8_t test_vmulh_vx_i16m8_mu(vbool2_t mask, vint16m8_t maskedoff, vint16m8_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 1 x i32> @test_vmulh_vv_i32mf2_mu
  // CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i32> [[MASKEDOFF:%.*]], <vscale x 1 x i32> [[OP1:%.*]], <vscale x 1 x i32> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i32> @llvm.riscv.vmulh.mask.nxv1i32.nxv1i32.i64(<vscale x 1 x i32> [[MASKEDOFF]], <vscale x 1 x i32> [[OP1]], <vscale x 1 x i32> [[OP2]], <vscale x 1 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 1 x i32> [[TMP0]]
  //
  vint32mf2_t test_vmulh_vv_i32mf2_mu(vbool64_t mask, vint32mf2_t maskedoff, vint32mf2_t op1, vint32mf2_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 1 x i32> @test_vmulh_vx_i32mf2_mu
  // CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i32> [[MASKEDOFF:%.*]], <vscale x 1 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i32> @llvm.riscv.vmulh.mask.nxv1i32.i32.i64(<vscale x 1 x i32> [[MASKEDOFF]], <vscale x 1 x i32> [[OP1]], i32 [[OP2]], <vscale x 1 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 1 x i32> [[TMP0]]
  //
  vint32mf2_t test_vmulh_vx_i32mf2_mu(vbool64_t mask, vint32mf2_t maskedoff, vint32mf2_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i32> @test_vmulh_vv_i32m1_mu
  // CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i32> [[MASKEDOFF:%.*]], <vscale x 2 x i32> [[OP1:%.*]], <vscale x 2 x i32> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i32> @llvm.riscv.vmulh.mask.nxv2i32.nxv2i32.i64(<vscale x 2 x i32> [[MASKEDOFF]], <vscale x 2 x i32> [[OP1]], <vscale x 2 x i32> [[OP2]], <vscale x 2 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i32> [[TMP0]]
  //
  vint32m1_t test_vmulh_vv_i32m1_mu(vbool32_t mask, vint32m1_t maskedoff, vint32m1_t op1, vint32m1_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i32> @test_vmulh_vx_i32m1_mu
  // CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i32> [[MASKEDOFF:%.*]], <vscale x 2 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i32> @llvm.riscv.vmulh.mask.nxv2i32.i32.i64(<vscale x 2 x i32> [[MASKEDOFF]], <vscale x 2 x i32> [[OP1]], i32 [[OP2]], <vscale x 2 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i32> [[TMP0]]
  //
  vint32m1_t test_vmulh_vx_i32m1_mu(vbool32_t mask, vint32m1_t maskedoff, vint32m1_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i32> @test_vmulh_vv_i32m2_mu
  // CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i32> [[MASKEDOFF:%.*]], <vscale x 4 x i32> [[OP1:%.*]], <vscale x 4 x i32> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i32> @llvm.riscv.vmulh.mask.nxv4i32.nxv4i32.i64(<vscale x 4 x i32> [[MASKEDOFF]], <vscale x 4 x i32> [[OP1]], <vscale x 4 x i32> [[OP2]], <vscale x 4 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i32> [[TMP0]]
  //
  vint32m2_t test_vmulh_vv_i32m2_mu(vbool16_t mask, vint32m2_t maskedoff, vint32m2_t op1, vint32m2_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i32> @test_vmulh_vx_i32m2_mu
  // CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i32> [[MASKEDOFF:%.*]], <vscale x 4 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i32> @llvm.riscv.vmulh.mask.nxv4i32.i32.i64(<vscale x 4 x i32> [[MASKEDOFF]], <vscale x 4 x i32> [[OP1]], i32 [[OP2]], <vscale x 4 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i32> [[TMP0]]
  //
  vint32m2_t test_vmulh_vx_i32m2_mu(vbool16_t mask, vint32m2_t maskedoff, vint32m2_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i32> @test_vmulh_vv_i32m4_mu
  // CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i32> [[MASKEDOFF:%.*]], <vscale x 8 x i32> [[OP1:%.*]], <vscale x 8 x i32> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i32> @llvm.riscv.vmulh.mask.nxv8i32.nxv8i32.i64(<vscale x 8 x i32> [[MASKEDOFF]], <vscale x 8 x i32> [[OP1]], <vscale x 8 x i32> [[OP2]], <vscale x 8 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i32> [[TMP0]]
  //
  vint32m4_t test_vmulh_vv_i32m4_mu(vbool8_t mask, vint32m4_t maskedoff, vint32m4_t op1, vint32m4_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i32> @test_vmulh_vx_i32m4_mu
  // CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i32> [[MASKEDOFF:%.*]], <vscale x 8 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i32> @llvm.riscv.vmulh.mask.nxv8i32.i32.i64(<vscale x 8 x i32> [[MASKEDOFF]], <vscale x 8 x i32> [[OP1]], i32 [[OP2]], <vscale x 8 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i32> [[TMP0]]
  //
  vint32m4_t test_vmulh_vx_i32m4_mu(vbool8_t mask, vint32m4_t maskedoff, vint32m4_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 16 x i32> @test_vmulh_vv_i32m8_mu
  // CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i32> [[MASKEDOFF:%.*]], <vscale x 16 x i32> [[OP1:%.*]], <vscale x 16 x i32> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i32> @llvm.riscv.vmulh.mask.nxv16i32.nxv16i32.i64(<vscale x 16 x i32> [[MASKEDOFF]], <vscale x 16 x i32> [[OP1]], <vscale x 16 x i32> [[OP2]], <vscale x 16 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 16 x i32> [[TMP0]]
  //
  vint32m8_t test_vmulh_vv_i32m8_mu(vbool4_t mask, vint32m8_t maskedoff, vint32m8_t op1, vint32m8_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 16 x i32> @test_vmulh_vx_i32m8_mu
  // CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i32> [[MASKEDOFF:%.*]], <vscale x 16 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i32> @llvm.riscv.vmulh.mask.nxv16i32.i32.i64(<vscale x 16 x i32> [[MASKEDOFF]], <vscale x 16 x i32> [[OP1]], i32 [[OP2]], <vscale x 16 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 16 x i32> [[TMP0]]
  //
  vint32m8_t test_vmulh_vx_i32m8_mu(vbool4_t mask, vint32m8_t maskedoff, vint32m8_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 1 x i64> @test_vmulh_vv_i64m1_mu
  // CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i64> [[MASKEDOFF:%.*]], <vscale x 1 x i64> [[OP1:%.*]], <vscale x 1 x i64> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i64> @llvm.riscv.vmulh.mask.nxv1i64.nxv1i64.i64(<vscale x 1 x i64> [[MASKEDOFF]], <vscale x 1 x i64> [[OP1]], <vscale x 1 x i64> [[OP2]], <vscale x 1 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 1 x i64> [[TMP0]]
  //
  vint64m1_t test_vmulh_vv_i64m1_mu(vbool64_t mask, vint64m1_t maskedoff, vint64m1_t op1, vint64m1_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 1 x i64> @test_vmulh_vx_i64m1_mu
  // CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i64> [[MASKEDOFF:%.*]], <vscale x 1 x i64> [[OP1:%.*]], i64 noundef [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i64> @llvm.riscv.vmulh.mask.nxv1i64.i64.i64(<vscale x 1 x i64> [[MASKEDOFF]], <vscale x 1 x i64> [[OP1]], i64 [[OP2]], <vscale x 1 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 1 x i64> [[TMP0]]
  //
  vint64m1_t test_vmulh_vx_i64m1_mu(vbool64_t mask, vint64m1_t maskedoff, vint64m1_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i64> @test_vmulh_vv_i64m2_mu
  // CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i64> [[MASKEDOFF:%.*]], <vscale x 2 x i64> [[OP1:%.*]], <vscale x 2 x i64> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i64> @llvm.riscv.vmulh.mask.nxv2i64.nxv2i64.i64(<vscale x 2 x i64> [[MASKEDOFF]], <vscale x 2 x i64> [[OP1]], <vscale x 2 x i64> [[OP2]], <vscale x 2 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i64> [[TMP0]]
  //
  vint64m2_t test_vmulh_vv_i64m2_mu(vbool32_t mask, vint64m2_t maskedoff, vint64m2_t op1, vint64m2_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 2 x i64> @test_vmulh_vx_i64m2_mu
  // CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i64> [[MASKEDOFF:%.*]], <vscale x 2 x i64> [[OP1:%.*]], i64 noundef [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i64> @llvm.riscv.vmulh.mask.nxv2i64.i64.i64(<vscale x 2 x i64> [[MASKEDOFF]], <vscale x 2 x i64> [[OP1]], i64 [[OP2]], <vscale x 2 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 2 x i64> [[TMP0]]
  //
  vint64m2_t test_vmulh_vx_i64m2_mu(vbool32_t mask, vint64m2_t maskedoff, vint64m2_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i64> @test_vmulh_vv_i64m4_mu
  // CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i64> [[MASKEDOFF:%.*]], <vscale x 4 x i64> [[OP1:%.*]], <vscale x 4 x i64> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i64> @llvm.riscv.vmulh.mask.nxv4i64.nxv4i64.i64(<vscale x 4 x i64> [[MASKEDOFF]], <vscale x 4 x i64> [[OP1]], <vscale x 4 x i64> [[OP2]], <vscale x 4 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i64> [[TMP0]]
  //
  vint64m4_t test_vmulh_vv_i64m4_mu(vbool16_t mask, vint64m4_t maskedoff, vint64m4_t op1, vint64m4_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 4 x i64> @test_vmulh_vx_i64m4_mu
  // CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i64> [[MASKEDOFF:%.*]], <vscale x 4 x i64> [[OP1:%.*]], i64 noundef [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i64> @llvm.riscv.vmulh.mask.nxv4i64.i64.i64(<vscale x 4 x i64> [[MASKEDOFF]], <vscale x 4 x i64> [[OP1]], i64 [[OP2]], <vscale x 4 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 4 x i64> [[TMP0]]
  //
  vint64m4_t test_vmulh_vx_i64m4_mu(vbool16_t mask, vint64m4_t maskedoff, vint64m4_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i64> @test_vmulh_vv_i64m8_mu
  // CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i64> [[MASKEDOFF:%.*]], <vscale x 8 x i64> [[OP1:%.*]], <vscale x 8 x i64> [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i64> @llvm.riscv.vmulh.mask.nxv8i64.nxv8i64.i64(<vscale x 8 x i64> [[MASKEDOFF]], <vscale x 8 x i64> [[OP1]], <vscale x 8 x i64> [[OP2]], <vscale x 8 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i64> [[TMP0]]
  //
  vint64m8_t test_vmulh_vv_i64m8_mu(vbool8_t mask, vint64m8_t maskedoff, vint64m8_t op1, vint64m8_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  // CHECK-RV64-LABEL: define dso_local <vscale x 8 x i64> @test_vmulh_vx_i64m8_mu
  // CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i64> [[MASKEDOFF:%.*]], <vscale x 8 x i64> [[OP1:%.*]], i64 noundef [[OP2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
  // CHECK-RV64-NEXT:  entry:
  // CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i64> @llvm.riscv.vmulh.mask.nxv8i64.i64.i64(<vscale x 8 x i64> [[MASKEDOFF]], <vscale x 8 x i64> [[OP1]], i64 [[OP2]], <vscale x 8 x i1> [[MASK]], i64 [[VL]], i64 1)
  // CHECK-RV64-NEXT:    ret <vscale x 8 x i64> [[TMP0]]
  //
  vint64m8_t test_vmulh_vx_i64m8_mu(vbool8_t mask, vint64m8_t maskedoff, vint64m8_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
  }

  int b1 : 5;
  int : 0;
  int b2 : 3;
  int : 5;

  _Complex int ci1;
  _Complex double cd1;
};

int printf(const char *fmt, ...);

// CHECK-LABEL: define {{.*}} @test(
void test(struct A *a) {
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_0]], ptr noundef @[[STR_1]])

  // CHECK: %[[VAL_0:.*]] = load ptr, ptr %[[VAL_a_addr:.*]],
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_2]])

  // CHECK: %[[VAL_i1:.*]] = getelementptr inbounds nuw %[[VAL_struct_A:.*]], ptr %[[VAL_0]], i32 0, i32 0
  // CHECK: %[[VAL_1:.*]] = load i8, ptr %[[VAL_i1]],
  // CHECK: %[[VAL_conv:.*]] = sext i8 %[[VAL_1]] to i32
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_7]], ptr noundef @[[STR_4]], ptr noundef @[[STR_5]], ptr noundef @[[STR_6]], i32 noundef %[[VAL_conv]])

  // CHECK: %[[VAL_i2:.*]] = getelementptr inbounds nuw %[[VAL_struct_A]], ptr %[[VAL_0]], i32 0, i32 1
  // CHECK: %[[VAL_2:.*]] = load i8, ptr %[[VAL_i2]],
  // CHECK: %[[VAL_conv3:.*]] = sext i8 %[[VAL_2]] to i32
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_7]], ptr noundef @[[STR_4]], ptr noundef @[[STR_8]], ptr noundef @[[STR_9]], i32 noundef %[[VAL_conv3]])

  // CHECK: %[[VAL_i3:.*]] = getelementptr inbounds nuw %[[VAL_struct_A]], ptr %[[VAL_0]], i32 0, i32 2
  // CHECK: %[[VAL_3:.*]] = load i8, ptr %[[VAL_i3]],
  // CHECK: %[[VAL_conv5:.*]] = zext i8 %[[VAL_3]] to i32
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_10]], ptr noundef @[[STR_4]], ptr noundef @[[STR_11]], ptr noundef @[[STR_12]], i32 noundef %[[VAL_conv5]])

  // CHECK: %[[VAL_i4:.*]] = getelementptr inbounds nuw %[[VAL_struct_A]], ptr %[[VAL_0]], i32 0, i32 3
  // CHECK: %[[VAL_4:.*]] = load i16, ptr %[[VAL_i4]],
  // CHECK: %[[VAL_conv7:.*]] = sext i16 %[[VAL_4]] to i32
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_13]], ptr noundef @[[STR_4]], ptr noundef @[[STR_14]], ptr noundef @[[STR_15]], i32 noundef %[[VAL_conv7]])

  // CHECK: %[[VAL_i5:.*]] = getelementptr inbounds nuw %[[VAL_struct_A]], ptr %[[VAL_0]], i32 0, i32 4
  // CHECK: %[[VAL_5:.*]] = load i16, ptr %[[VAL_i5]],
  // CHECK: %[[VAL_conv9:.*]] = zext i16 %[[VAL_5]] to i32
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_16]], ptr noundef @[[STR_4]], ptr noundef @[[STR_17]], ptr noundef @[[STR_18]], i32 noundef %[[VAL_conv9]])

  // CHECK: %[[VAL_i6:.*]] = getelementptr inbounds nuw %[[VAL_struct_A]], ptr %[[VAL_0]], i32 0, i32 5
  // CHECK: %[[VAL_6:.*]] = load i32, ptr %[[VAL_i6]],
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_19]], ptr noundef @[[STR_4]], ptr noundef @[[STR_20]], ptr noundef @[[STR_21]], i32 noundef %[[VAL_6]])

  // CHECK: %[[VAL_i7:.*]] = getelementptr inbounds nuw %[[VAL_struct_A]], ptr %[[VAL_0]], i32 0, i32 6
  // CHECK: %[[VAL_7:.*]] = load i32, ptr %[[VAL_i7]],
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_22]], ptr noundef @[[STR_4]], ptr noundef @[[STR_23]], ptr noundef @[[STR_24]], i32 noundef %[[VAL_7]])

  // CHECK: %[[VAL_i8:.*]] = getelementptr inbounds nuw %[[VAL_struct_A]], ptr %[[VAL_0]], i32 0, i32 7
  // CHECK: %[[VAL_8:.*]] = load i64, ptr %[[VAL_i8]],
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_25]], ptr noundef @[[STR_4]], ptr noundef @[[STR_26]], ptr noundef @[[STR_27]], i64 noundef %[[VAL_8]])

  // CHECK: %[[VAL_i9:.*]] = getelementptr inbounds nuw %[[VAL_struct_A]], ptr %[[VAL_0]], i32 0, i32 8
  // CHECK: %[[VAL_9:.*]] = load i64, ptr %[[VAL_i9]],
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_28]], ptr noundef @[[STR_4]], ptr noundef @[[STR_29]], ptr noundef @[[STR_30]], i64 noundef %[[VAL_9]])

  // CHECK: %[[VAL_i10:.*]] = getelementptr inbounds nuw %[[VAL_struct_A]], ptr %[[VAL_0]], i32 0, i32 9
  // CHECK: %[[VAL_10:.*]] = load i64, ptr %[[VAL_i10]],
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_31]], ptr noundef @[[STR_4]], ptr noundef @[[STR_32]], ptr noundef @[[STR_33]], i64 noundef %[[VAL_10]])

  // CHECK: %[[VAL_i11:.*]] = getelementptr inbounds nuw %[[VAL_struct_A]], ptr %[[VAL_0]], i32 0, i32 10
  // CHECK: %[[VAL_11:.*]] = load i64, ptr %[[VAL_i11]],
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_34]], ptr noundef @[[STR_4]], ptr noundef @[[STR_35]], ptr noundef @[[STR_36]], i64 noundef %[[VAL_11]])

  // CHECK: %[[VAL_f1:.*]] = getelementptr inbounds nuw %[[VAL_struct_A]], ptr %[[VAL_0]], i32 0, i32 11
  // CHECK: %[[VAL_12:.*]] = load float, ptr %[[VAL_f1]],
  // CHECK: %[[VAL_conv17:.*]] = fpext float %[[VAL_12]] to double
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_37]], ptr noundef @[[STR_4]], ptr noundef @[[STR_38]], ptr noundef @[[STR_39]], double noundef %[[VAL_conv17]])

  // CHECK: %[[VAL_f2:.*]] = getelementptr inbounds nuw %[[VAL_struct_A]], ptr %[[VAL_0]], i32 0, i32 12
  // CHECK: %[[VAL_13:.*]] = load double, ptr %[[VAL_f2]],
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_37]], ptr noundef @[[STR_4]], ptr noundef @[[STR_40]], ptr noundef @[[STR_41]], double noundef %[[VAL_13]])

  // CHECK: %[[VAL_f3:.*]] = getelementptr inbounds nuw %[[VAL_struct_A]], ptr %[[VAL_0]], i32 0, i32 13
  // CHECK: %[[VAL_14:.*]] = load x86_fp80, ptr %[[VAL_f3]],
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_42]], ptr noundef @[[STR_4]], ptr noundef @[[STR_43]], ptr noundef @[[STR_44]], x86_fp80 noundef %[[VAL_14]])

  // CHECK: %[[VAL_p1:.*]] = getelementptr inbounds nuw %[[VAL_struct_A]], ptr %[[VAL_0]], i32 0, i32 14
  // CHECK: %[[VAL_15:.*]] = load ptr, ptr %[[VAL_p1]],
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_45]], ptr noundef @[[STR_4]], ptr noundef @[[STR_46]], ptr noundef @[[STR_47]], ptr noundef %[[VAL_15]])

  // CHECK: %[[VAL_s1:.*]] = getelementptr inbounds nuw %[[VAL_struct_A]], ptr %[[VAL_0]], i32 0, i32 15
  // CHECK: %[[VAL_16:.*]] = load ptr, ptr %[[VAL_s1]],
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_48]], ptr noundef @[[STR_4]], ptr noundef @[[STR_49]], ptr noundef @[[STR_50]], ptr noundef %[[VAL_16]])

  // CHECK: %[[VAL_s2:.*]] = getelementptr inbounds nuw %[[VAL_struct_A]], ptr %[[VAL_0]], i32 0, i32 16
  // CHECK: %[[VAL_17:.*]] = load ptr, ptr %[[VAL_s2]],
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_48]], ptr noundef @[[STR_4]], ptr noundef @[[STR_51]], ptr noundef @[[STR_52]], ptr noundef %[[VAL_17]])

  // CHECK: %[[VAL_s3:.*]] = getelementptr inbounds nuw %[[VAL_struct_A]], ptr %[[VAL_0]], i32 0, i32 17
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_53]], ptr noundef @[[STR_4]], ptr noundef @[[STR_54]], ptr noundef @[[STR_55]], ptr noundef %[[VAL_s3]])

  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_56]], ptr noundef @[[STR_4]], ptr noundef @[[STR_57]], ptr noundef @[[STR_58]])

  // CHECK: %[[VAL_x1:.*]] = getelementptr inbounds nuw %[[VAL_struct_A]], ptr %[[VAL_0]], i32 0, i32 18
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_2]])

  // CHECK: %[[VAL_n:.*]] = getelementptr inbounds nuw %[[VAL_struct_X:.*]], ptr %[[VAL_x1]], i32 0, i32 0
  // CHECK: %[[VAL_18:.*]] = load i32, ptr %[[VAL_n]],
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_19]], ptr noundef @[[STR_59]], ptr noundef @[[STR_20]], ptr noundef @[[STR_60]], i32 noundef %[[VAL_18]])

  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_61]], ptr noundef @[[STR_4]])

  // CHECK: %[[VAL_19:.*]] = getelementptr inbounds nuw %[[VAL_struct_A]], ptr %[[VAL_0]], i32 0, i32 19
  // CHECK: %[[VAL_n1:.*]] = getelementptr inbounds nuw %[[VAL_struct_anon:.*]], ptr %[[VAL_19]], i32 0, i32 0
  // CHECK: %[[VAL_20:.*]] = load i32, ptr %[[VAL_n1]],
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_19]], ptr noundef @[[STR_4]], ptr noundef @[[STR_20]], ptr noundef @[[STR_62]], i32 noundef %[[VAL_20]])

  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_56]], ptr noundef @[[STR_4]], ptr noundef @[[STR_57]], ptr noundef @[[STR_63]])

  // CHECK: %[[VAL_21:.*]] = getelementptr inbounds nuw %[[VAL_struct_A]], ptr %[[VAL_0]], i32 0, i32 19
  // CHECK: %[[VAL_n2:.*]] = getelementptr inbounds nuw %[[VAL_struct_anon]], ptr %[[VAL_21]], i32 0, i32 1
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_2]])

  // CHECK: %[[VAL_n32:.*]] = getelementptr inbounds nuw %[[VAL_struct_X]], ptr %[[VAL_n2]], i32 0, i32 0
  // CHECK: %[[VAL_22:.*]] = load i32, ptr %[[VAL_n32]],
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_19]], ptr noundef @[[STR_59]], ptr noundef @[[STR_20]], ptr noundef @[[STR_60]], i32 noundef %[[VAL_22]])

  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_61]], ptr noundef @[[STR_4]])

  // CHECK: %[[VAL_23:.*]] = getelementptr inbounds nuw %[[VAL_struct_A]], ptr %[[VAL_0]], i32 0, i32 20
  // CHECK: %[[VAL_24:.*]] = load i32, ptr %[[VAL_23]],
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_19]], ptr noundef @[[STR_4]], ptr noundef @[[STR_20]], ptr noundef @[[STR_64]], i32 noundef %[[VAL_24]])

  // CHECK: %[[VAL_25:.*]] = getelementptr inbounds nuw %[[VAL_struct_A]], ptr %[[VAL_0]], i32 0, i32 20
  // CHECK: %[[VAL_26:.*]] = load i32, ptr %[[VAL_25]],
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_19]], ptr noundef @[[STR_4]], ptr noundef @[[STR_20]], ptr noundef @[[STR_65]], i32 noundef %[[VAL_26]])

  // CHECK: %[[VAL_b1:.*]] = getelementptr inbounds nuw %[[VAL_struct_A]], ptr %[[VAL_0]], i32 0, i32 21
  // CHECK: %[[VAL_bf_load:.*]] = load i8, ptr %[[VAL_b1]],
  // CHECK: %[[VAL_bf_shl:.*]] = shl i8 %[[VAL_bf_load]], 3
  // CHECK: %[[VAL_bf_ashr:.*]] = ashr i8 %[[VAL_bf_shl]], 3
  // CHECK: %[[VAL_bf_cast:.*]] = sext i8 %[[VAL_bf_ashr]] to i32
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_66]], ptr noundef @[[STR_4]], ptr noundef @[[STR_20]], ptr noundef @[[STR_67]], i64 noundef 5, i32 noundef %[[VAL_bf_cast]])

  // CHECK: %[[VAL_b2:.*]] = getelementptr inbounds nuw %[[VAL_struct_A]], ptr %[[VAL_0]], i32 0, i32 23
  // CHECK: %[[VAL_bf_load38:.*]] = load i8, ptr %[[VAL_b2]],
  // CHECK: %[[VAL_bf_shl39:.*]] = shl i8 %[[VAL_bf_load38]], 5
  // CHECK: %[[VAL_bf_ashr40:.*]] = ashr i8 %[[VAL_bf_shl39]], 5
  // CHECK: %[[VAL_bf_cast41:.*]] = sext i8 %[[VAL_bf_ashr40]] to i32
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_66]], ptr noundef @[[STR_4]], ptr noundef @[[STR_20]], ptr noundef @[[STR_68]], i64 noundef 3, i32 noundef %[[VAL_bf_cast41]])

  // CHECK: %[[VAL_ci1:.*]] = getelementptr inbounds nuw %[[VAL_struct_A]], ptr %[[VAL_0]], i32 0, i32 24
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_53]], ptr noundef @[[STR_4]], ptr noundef @[[STR_69]], ptr noundef @[[STR_70]], ptr noundef %[[VAL_ci1]])

  // CHECK: %[[VAL_cd1:.*]] = getelementptr inbounds nuw %[[VAL_struct_A]], ptr %[[VAL_0]], i32 0, i32 25
  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_53]], ptr noundef @[[STR_4]], ptr noundef @[[STR_71]], ptr noundef @[[STR_72]], ptr noundef %[[VAL_cd1]])

  // CHECK: call {{.*}} @printf(ptr noundef @[[STR_73]])
  __builtin_dump_struct(a, printf);

}
// NOTE: Assertions have been autogenerated by utils/update_cc_test_checks.py UTC_ARGS: --version 2
// REQUIRES: riscv-registered-target
// RUN: %clang_cc1 -triple riscv64 -target-feature +v -disable-O0-optnone \
// RUN:   -emit-llvm %s -o - | opt -S -passes=mem2reg | \
// RUN:   FileCheck --check-prefix=CHECK-RV64 %s

#include <riscv_vector.h>

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x i8> @test_vmulh_vv_i8mf8_tu
// CHECK-RV64-SAME: (<vscale x 1 x i8> [[MASKEDOFF:%.*]], <vscale x 1 x i8> [[OP1:%.*]], <vscale x 1 x i8> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0:[0-9]+]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i8> @llvm.riscv.vmulh.nxv1i8.nxv1i8.i64(<vscale x 1 x i8> [[MASKEDOFF]], <vscale x 1 x i8> [[OP1]], <vscale x 1 x i8> [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 1 x i8> [[TMP0]]
//
vint8mf8_t test_vmulh_vv_i8mf8_tu(vint8mf8_t maskedoff, vint8mf8_t op1, vint8mf8_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x i8> @test_vmulh_vx_i8mf8_tu
// CHECK-RV64-SAME: (<vscale x 1 x i8> [[MASKEDOFF:%.*]], <vscale x 1 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i8> @llvm.riscv.vmulh.nxv1i8.i8.i64(<vscale x 1 x i8> [[MASKEDOFF]], <vscale x 1 x i8> [[OP1]], i8 [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 1 x i8> [[TMP0]]
//
vint8mf8_t test_vmulh_vx_i8mf8_tu(vint8mf8_t maskedoff, vint8mf8_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x i8> @test_vmulh_vv_i8mf4_tu
// CHECK-RV64-SAME: (<vscale x 2 x i8> [[MASKEDOFF:%.*]], <vscale x 2 x i8> [[OP1:%.*]], <vscale x 2 x i8> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i8> @llvm.riscv.vmulh.nxv2i8.nxv2i8.i64(<vscale x 2 x i8> [[MASKEDOFF]], <vscale x 2 x i8> [[OP1]], <vscale x 2 x i8> [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 2 x i8> [[TMP0]]
//
vint8mf4_t test_vmulh_vv_i8mf4_tu(vint8mf4_t maskedoff, vint8mf4_t op1, vint8mf4_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x i8> @test_vmulh_vx_i8mf4_tu
// CHECK-RV64-SAME: (<vscale x 2 x i8> [[MASKEDOFF:%.*]], <vscale x 2 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i8> @llvm.riscv.vmulh.nxv2i8.i8.i64(<vscale x 2 x i8> [[MASKEDOFF]], <vscale x 2 x i8> [[OP1]], i8 [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 2 x i8> [[TMP0]]
//
vint8mf4_t test_vmulh_vx_i8mf4_tu(vint8mf4_t maskedoff, vint8mf4_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x i8> @test_vmulh_vv_i8mf2_tu
// CHECK-RV64-SAME: (<vscale x 4 x i8> [[MASKEDOFF:%.*]], <vscale x 4 x i8> [[OP1:%.*]], <vscale x 4 x i8> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i8> @llvm.riscv.vmulh.nxv4i8.nxv4i8.i64(<vscale x 4 x i8> [[MASKEDOFF]], <vscale x 4 x i8> [[OP1]], <vscale x 4 x i8> [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 4 x i8> [[TMP0]]
//
vint8mf2_t test_vmulh_vv_i8mf2_tu(vint8mf2_t maskedoff, vint8mf2_t op1, vint8mf2_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x i8> @test_vmulh_vx_i8mf2_tu
// CHECK-RV64-SAME: (<vscale x 4 x i8> [[MASKEDOFF:%.*]], <vscale x 4 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i8> @llvm.riscv.vmulh.nxv4i8.i8.i64(<vscale x 4 x i8> [[MASKEDOFF]], <vscale x 4 x i8> [[OP1]], i8 [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 4 x i8> [[TMP0]]
//
vint8mf2_t test_vmulh_vx_i8mf2_tu(vint8mf2_t maskedoff, vint8mf2_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x i8> @test_vmulh_vv_i8m1_tu
// CHECK-RV64-SAME: (<vscale x 8 x i8> [[MASKEDOFF:%.*]], <vscale x 8 x i8> [[OP1:%.*]], <vscale x 8 x i8> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i8> @llvm.riscv.vmulh.nxv8i8.nxv8i8.i64(<vscale x 8 x i8> [[MASKEDOFF]], <vscale x 8 x i8> [[OP1]], <vscale x 8 x i8> [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 8 x i8> [[TMP0]]
//
vint8m1_t test_vmulh_vv_i8m1_tu(vint8m1_t maskedoff, vint8m1_t op1, vint8m1_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x i8> @test_vmulh_vx_i8m1_tu
// CHECK-RV64-SAME: (<vscale x 8 x i8> [[MASKEDOFF:%.*]], <vscale x 8 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i8> @llvm.riscv.vmulh.nxv8i8.i8.i64(<vscale x 8 x i8> [[MASKEDOFF]], <vscale x 8 x i8> [[OP1]], i8 [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 8 x i8> [[TMP0]]
//
vint8m1_t test_vmulh_vx_i8m1_tu(vint8m1_t maskedoff, vint8m1_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 16 x i8> @test_vmulh_vv_i8m2_tu
// CHECK-RV64-SAME: (<vscale x 16 x i8> [[MASKEDOFF:%.*]], <vscale x 16 x i8> [[OP1:%.*]], <vscale x 16 x i8> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i8> @llvm.riscv.vmulh.nxv16i8.nxv16i8.i64(<vscale x 16 x i8> [[MASKEDOFF]], <vscale x 16 x i8> [[OP1]], <vscale x 16 x i8> [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 16 x i8> [[TMP0]]
//
vint8m2_t test_vmulh_vv_i8m2_tu(vint8m2_t maskedoff, vint8m2_t op1, vint8m2_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 16 x i8> @test_vmulh_vx_i8m2_tu
// CHECK-RV64-SAME: (<vscale x 16 x i8> [[MASKEDOFF:%.*]], <vscale x 16 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i8> @llvm.riscv.vmulh.nxv16i8.i8.i64(<vscale x 16 x i8> [[MASKEDOFF]], <vscale x 16 x i8> [[OP1]], i8 [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 16 x i8> [[TMP0]]
//
vint8m2_t test_vmulh_vx_i8m2_tu(vint8m2_t maskedoff, vint8m2_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 32 x i8> @test_vmulh_vv_i8m4_tu
// CHECK-RV64-SAME: (<vscale x 32 x i8> [[MASKEDOFF:%.*]], <vscale x 32 x i8> [[OP1:%.*]], <vscale x 32 x i8> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i8> @llvm.riscv.vmulh.nxv32i8.nxv32i8.i64(<vscale x 32 x i8> [[MASKEDOFF]], <vscale x 32 x i8> [[OP1]], <vscale x 32 x i8> [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 32 x i8> [[TMP0]]
//
vint8m4_t test_vmulh_vv_i8m4_tu(vint8m4_t maskedoff, vint8m4_t op1, vint8m4_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 32 x i8> @test_vmulh_vx_i8m4_tu
// CHECK-RV64-SAME: (<vscale x 32 x i8> [[MASKEDOFF:%.*]], <vscale x 32 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i8> @llvm.riscv.vmulh.nxv32i8.i8.i64(<vscale x 32 x i8> [[MASKEDOFF]], <vscale x 32 x i8> [[OP1]], i8 [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 32 x i8> [[TMP0]]
//
vint8m4_t test_vmulh_vx_i8m4_tu(vint8m4_t maskedoff, vint8m4_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 64 x i8> @test_vmulh_vv_i8m8_tu
// CHECK-RV64-SAME: (<vscale x 64 x i8> [[MASKEDOFF:%.*]], <vscale x 64 x i8> [[OP1:%.*]], <vscale x 64 x i8> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 64 x i8> @llvm.riscv.vmulh.nxv64i8.nxv64i8.i64(<vscale x 64 x i8> [[MASKEDOFF]], <vscale x 64 x i8> [[OP1]], <vscale x 64 x i8> [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 64 x i8> [[TMP0]]
//
vint8m8_t test_vmulh_vv_i8m8_tu(vint8m8_t maskedoff, vint8m8_t op1, vint8m8_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 64 x i8> @test_vmulh_vx_i8m8_tu
// CHECK-RV64-SAME: (<vscale x 64 x i8> [[MASKEDOFF:%.*]], <vscale x 64 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 64 x i8> @llvm.riscv.vmulh.nxv64i8.i8.i64(<vscale x 64 x i8> [[MASKEDOFF]], <vscale x 64 x i8> [[OP1]], i8 [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 64 x i8> [[TMP0]]
//
vint8m8_t test_vmulh_vx_i8m8_tu(vint8m8_t maskedoff, vint8m8_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x i16> @test_vmulh_vv_i16mf4_tu
// CHECK-RV64-SAME: (<vscale x 1 x i16> [[MASKEDOFF:%.*]], <vscale x 1 x i16> [[OP1:%.*]], <vscale x 1 x i16> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i16> @llvm.riscv.vmulh.nxv1i16.nxv1i16.i64(<vscale x 1 x i16> [[MASKEDOFF]], <vscale x 1 x i16> [[OP1]], <vscale x 1 x i16> [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 1 x i16> [[TMP0]]
//
vint16mf4_t test_vmulh_vv_i16mf4_tu(vint16mf4_t maskedoff, vint16mf4_t op1, vint16mf4_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x i16> @test_vmulh_vx_i16mf4_tu
// CHECK-RV64-SAME: (<vscale x 1 x i16> [[MASKEDOFF:%.*]], <vscale x 1 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i16> @llvm.riscv.vmulh.nxv1i16.i16.i64(<vscale x 1 x i16> [[MASKEDOFF]], <vscale x 1 x i16> [[OP1]], i16 [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 1 x i16> [[TMP0]]
//
vint16mf4_t test_vmulh_vx_i16mf4_tu(vint16mf4_t maskedoff, vint16mf4_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x i16> @test_vmulh_vv_i16mf2_tu
// CHECK-RV64-SAME: (<vscale x 2 x i16> [[MASKEDOFF:%.*]], <vscale x 2 x i16> [[OP1:%.*]], <vscale x 2 x i16> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i16> @llvm.riscv.vmulh.nxv2i16.nxv2i16.i64(<vscale x 2 x i16> [[MASKEDOFF]], <vscale x 2 x i16> [[OP1]], <vscale x 2 x i16> [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 2 x i16> [[TMP0]]
//
vint16mf2_t test_vmulh_vv_i16mf2_tu(vint16mf2_t maskedoff, vint16mf2_t op1, vint16mf2_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x i16> @test_vmulh_vx_i16mf2_tu
// CHECK-RV64-SAME: (<vscale x 2 x i16> [[MASKEDOFF:%.*]], <vscale x 2 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i16> @llvm.riscv.vmulh.nxv2i16.i16.i64(<vscale x 2 x i16> [[MASKEDOFF]], <vscale x 2 x i16> [[OP1]], i16 [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 2 x i16> [[TMP0]]
//
vint16mf2_t test_vmulh_vx_i16mf2_tu(vint16mf2_t maskedoff, vint16mf2_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x i16> @test_vmulh_vv_i16m1_tu
// CHECK-RV64-SAME: (<vscale x 4 x i16> [[MASKEDOFF:%.*]], <vscale x 4 x i16> [[OP1:%.*]], <vscale x 4 x i16> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i16> @llvm.riscv.vmulh.nxv4i16.nxv4i16.i64(<vscale x 4 x i16> [[MASKEDOFF]], <vscale x 4 x i16> [[OP1]], <vscale x 4 x i16> [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 4 x i16> [[TMP0]]
//
vint16m1_t test_vmulh_vv_i16m1_tu(vint16m1_t maskedoff, vint16m1_t op1, vint16m1_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x i16> @test_vmulh_vx_i16m1_tu
// CHECK-RV64-SAME: (<vscale x 4 x i16> [[MASKEDOFF:%.*]], <vscale x 4 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i16> @llvm.riscv.vmulh.nxv4i16.i16.i64(<vscale x 4 x i16> [[MASKEDOFF]], <vscale x 4 x i16> [[OP1]], i16 [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 4 x i16> [[TMP0]]
//
vint16m1_t test_vmulh_vx_i16m1_tu(vint16m1_t maskedoff, vint16m1_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x i16> @test_vmulh_vv_i16m2_tu
// CHECK-RV64-SAME: (<vscale x 8 x i16> [[MASKEDOFF:%.*]], <vscale x 8 x i16> [[OP1:%.*]], <vscale x 8 x i16> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i16> @llvm.riscv.vmulh.nxv8i16.nxv8i16.i64(<vscale x 8 x i16> [[MASKEDOFF]], <vscale x 8 x i16> [[OP1]], <vscale x 8 x i16> [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 8 x i16> [[TMP0]]
//
vint16m2_t test_vmulh_vv_i16m2_tu(vint16m2_t maskedoff, vint16m2_t op1, vint16m2_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x i16> @test_vmulh_vx_i16m2_tu
// CHECK-RV64-SAME: (<vscale x 8 x i16> [[MASKEDOFF:%.*]], <vscale x 8 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i16> @llvm.riscv.vmulh.nxv8i16.i16.i64(<vscale x 8 x i16> [[MASKEDOFF]], <vscale x 8 x i16> [[OP1]], i16 [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 8 x i16> [[TMP0]]
//
vint16m2_t test_vmulh_vx_i16m2_tu(vint16m2_t maskedoff, vint16m2_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 16 x i16> @test_vmulh_vv_i16m4_tu
// CHECK-RV64-SAME: (<vscale x 16 x i16> [[MASKEDOFF:%.*]], <vscale x 16 x i16> [[OP1:%.*]], <vscale x 16 x i16> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i16> @llvm.riscv.vmulh.nxv16i16.nxv16i16.i64(<vscale x 16 x i16> [[MASKEDOFF]], <vscale x 16 x i16> [[OP1]], <vscale x 16 x i16> [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 16 x i16> [[TMP0]]
//
vint16m4_t test_vmulh_vv_i16m4_tu(vint16m4_t maskedoff, vint16m4_t op1, vint16m4_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 16 x i16> @test_vmulh_vx_i16m4_tu
// CHECK-RV64-SAME: (<vscale x 16 x i16> [[MASKEDOFF:%.*]], <vscale x 16 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i16> @llvm.riscv.vmulh.nxv16i16.i16.i64(<vscale x 16 x i16> [[MASKEDOFF]], <vscale x 16 x i16> [[OP1]], i16 [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 16 x i16> [[TMP0]]
//
vint16m4_t test_vmulh_vx_i16m4_tu(vint16m4_t maskedoff, vint16m4_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 32 x i16> @test_vmulh_vv_i16m8_tu
// CHECK-RV64-SAME: (<vscale x 32 x i16> [[MASKEDOFF:%.*]], <vscale x 32 x i16> [[OP1:%.*]], <vscale x 32 x i16> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i16> @llvm.riscv.vmulh.nxv32i16.nxv32i16.i64(<vscale x 32 x i16> [[MASKEDOFF]], <vscale x 32 x i16> [[OP1]], <vscale x 32 x i16> [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 32 x i16> [[TMP0]]
//
vint16m8_t test_vmulh_vv_i16m8_tu(vint16m8_t maskedoff, vint16m8_t op1, vint16m8_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 32 x i16> @test_vmulh_vx_i16m8_tu
// CHECK-RV64-SAME: (<vscale x 32 x i16> [[MASKEDOFF:%.*]], <vscale x 32 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i16> @llvm.riscv.vmulh.nxv32i16.i16.i64(<vscale x 32 x i16> [[MASKEDOFF]], <vscale x 32 x i16> [[OP1]], i16 [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 32 x i16> [[TMP0]]
//
vint16m8_t test_vmulh_vx_i16m8_tu(vint16m8_t maskedoff, vint16m8_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x i32> @test_vmulh_vv_i32mf2_tu
// CHECK-RV64-SAME: (<vscale x 1 x i32> [[MASKEDOFF:%.*]], <vscale x 1 x i32> [[OP1:%.*]], <vscale x 1 x i32> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i32> @llvm.riscv.vmulh.nxv1i32.nxv1i32.i64(<vscale x 1 x i32> [[MASKEDOFF]], <vscale x 1 x i32> [[OP1]], <vscale x 1 x i32> [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 1 x i32> [[TMP0]]
//
vint32mf2_t test_vmulh_vv_i32mf2_tu(vint32mf2_t maskedoff, vint32mf2_t op1, vint32mf2_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x i32> @test_vmulh_vx_i32mf2_tu
// CHECK-RV64-SAME: (<vscale x 1 x i32> [[MASKEDOFF:%.*]], <vscale x 1 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i32> @llvm.riscv.vmulh.nxv1i32.i32.i64(<vscale x 1 x i32> [[MASKEDOFF]], <vscale x 1 x i32> [[OP1]], i32 [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 1 x i32> [[TMP0]]
//
vint32mf2_t test_vmulh_vx_i32mf2_tu(vint32mf2_t maskedoff, vint32mf2_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x i32> @test_vmulh_vv_i32m1_tu
// CHECK-RV64-SAME: (<vscale x 2 x i32> [[MASKEDOFF:%.*]], <vscale x 2 x i32> [[OP1:%.*]], <vscale x 2 x i32> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i32> @llvm.riscv.vmulh.nxv2i32.nxv2i32.i64(<vscale x 2 x i32> [[MASKEDOFF]], <vscale x 2 x i32> [[OP1]], <vscale x 2 x i32> [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 2 x i32> [[TMP0]]
//
vint32m1_t test_vmulh_vv_i32m1_tu(vint32m1_t maskedoff, vint32m1_t op1, vint32m1_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x i32> @test_vmulh_vx_i32m1_tu
// CHECK-RV64-SAME: (<vscale x 2 x i32> [[MASKEDOFF:%.*]], <vscale x 2 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i32> @llvm.riscv.vmulh.nxv2i32.i32.i64(<vscale x 2 x i32> [[MASKEDOFF]], <vscale x 2 x i32> [[OP1]], i32 [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 2 x i32> [[TMP0]]
//
vint32m1_t test_vmulh_vx_i32m1_tu(vint32m1_t maskedoff, vint32m1_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x i32> @test_vmulh_vv_i32m2_tu
// CHECK-RV64-SAME: (<vscale x 4 x i32> [[MASKEDOFF:%.*]], <vscale x 4 x i32> [[OP1:%.*]], <vscale x 4 x i32> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i32> @llvm.riscv.vmulh.nxv4i32.nxv4i32.i64(<vscale x 4 x i32> [[MASKEDOFF]], <vscale x 4 x i32> [[OP1]], <vscale x 4 x i32> [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 4 x i32> [[TMP0]]
//
vint32m2_t test_vmulh_vv_i32m2_tu(vint32m2_t maskedoff, vint32m2_t op1, vint32m2_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x i32> @test_vmulh_vx_i32m2_tu
// CHECK-RV64-SAME: (<vscale x 4 x i32> [[MASKEDOFF:%.*]], <vscale x 4 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i32> @llvm.riscv.vmulh.nxv4i32.i32.i64(<vscale x 4 x i32> [[MASKEDOFF]], <vscale x 4 x i32> [[OP1]], i32 [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 4 x i32> [[TMP0]]
//
vint32m2_t test_vmulh_vx_i32m2_tu(vint32m2_t maskedoff, vint32m2_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x i32> @test_vmulh_vv_i32m4_tu
// CHECK-RV64-SAME: (<vscale x 8 x i32> [[MASKEDOFF:%.*]], <vscale x 8 x i32> [[OP1:%.*]], <vscale x 8 x i32> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i32> @llvm.riscv.vmulh.nxv8i32.nxv8i32.i64(<vscale x 8 x i32> [[MASKEDOFF]], <vscale x 8 x i32> [[OP1]], <vscale x 8 x i32> [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 8 x i32> [[TMP0]]
//
vint32m4_t test_vmulh_vv_i32m4_tu(vint32m4_t maskedoff, vint32m4_t op1, vint32m4_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x i32> @test_vmulh_vx_i32m4_tu
// CHECK-RV64-SAME: (<vscale x 8 x i32> [[MASKEDOFF:%.*]], <vscale x 8 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i32> @llvm.riscv.vmulh.nxv8i32.i32.i64(<vscale x 8 x i32> [[MASKEDOFF]], <vscale x 8 x i32> [[OP1]], i32 [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 8 x i32> [[TMP0]]
//
vint32m4_t test_vmulh_vx_i32m4_tu(vint32m4_t maskedoff, vint32m4_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 16 x i32> @test_vmulh_vv_i32m8_tu
// CHECK-RV64-SAME: (<vscale x 16 x i32> [[MASKEDOFF:%.*]], <vscale x 16 x i32> [[OP1:%.*]], <vscale x 16 x i32> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i32> @llvm.riscv.vmulh.nxv16i32.nxv16i32.i64(<vscale x 16 x i32> [[MASKEDOFF]], <vscale x 16 x i32> [[OP1]], <vscale x 16 x i32> [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 16 x i32> [[TMP0]]
//
vint32m8_t test_vmulh_vv_i32m8_tu(vint32m8_t maskedoff, vint32m8_t op1, vint32m8_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 16 x i32> @test_vmulh_vx_i32m8_tu
// CHECK-RV64-SAME: (<vscale x 16 x i32> [[MASKEDOFF:%.*]], <vscale x 16 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i32> @llvm.riscv.vmulh.nxv16i32.i32.i64(<vscale x 16 x i32> [[MASKEDOFF]], <vscale x 16 x i32> [[OP1]], i32 [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 16 x i32> [[TMP0]]
//
vint32m8_t test_vmulh_vx_i32m8_tu(vint32m8_t maskedoff, vint32m8_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x double> @test_vmulh_vv_i64m1_tu
// CHECK-RV64-SAME: (<vscale x 1 x double> [[MASKEDOFF:%.*]], <vscale x 1 x double> [[OP1:%.*]], <vscale x 1 x double> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x double> @llvm.riscv.vmulh.nxv1i64.nxv1i64.i64(<vscale x 1 x double> [[MASKEDOFF]], <vscale x 1 x double> [[OP1]], <vscale x 1 x double> [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 1 x double> [[TMP0]]
//
vint64m1_t test_vmulh_vv_i64m1_tu(vint64m1_t maskedoff, vint64m1_t op1, vint64m1_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x double> @test_vmulh_vx_i64m1_tu
// CHECK-RV64-SAME: (<vscale x 1 x double> [[MASKEDOFF:%.*]], <vscale x 1 x double> [[OP1:%.*]], double noundef [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x double> @llvm.riscv.vmulh.nxv1i64.i64.i64(<vscale x 1 x double> [[MASKEDOFF]], <vscale x 1 x double> [[OP1]], double [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 1 x double> [[TMP0]]
//
vint64m1_t test_vmulh_vx_i64m1_tu(vint64m1_t maskedoff, vint64m1_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x double> @test_vmulh_vv_i64m2_tu
// CHECK-RV64-SAME: (<vscale x 2 x double> [[MASKEDOFF:%.*]], <vscale x 2 x double> [[OP1:%.*]], <vscale x 2 x double> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x double> @llvm.riscv.vmulh.nxv2i64.nxv2i64.i64(<vscale x 2 x double> [[MASKEDOFF]], <vscale x 2 x double> [[OP1]], <vscale x 2 x double> [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 2 x double> [[TMP0]]
//
vint64m2_t test_vmulh_vv_i64m2_tu(vint64m2_t maskedoff, vint64m2_t op1, vint64m2_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x double> @test_vmulh_vx_i64m2_tu
// CHECK-RV64-SAME: (<vscale x 2 x double> [[MASKEDOFF:%.*]], <vscale x 2 x double> [[OP1:%.*]], double noundef [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x double> @llvm.riscv.vmulh.nxv2i64.i64.i64(<vscale x 2 x double> [[MASKEDOFF]], <vscale x 2 x double> [[OP1]], double [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 2 x double> [[TMP0]]
//
vint64m2_t test_vmulh_vx_i64m2_tu(vint64m2_t maskedoff, vint64m2_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x double> @test_vmulh_vv_i64m4_tu
// CHECK-RV64-SAME: (<vscale x 4 x double> [[MASKEDOFF:%.*]], <vscale x 4 x double> [[OP1:%.*]], <vscale x 4 x double> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x double> @llvm.riscv.vmulh.nxv4i64.nxv4i64.i64(<vscale x 4 x double> [[MASKEDOFF]], <vscale x 4 x double> [[OP1]], <vscale x 4 x double> [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 4 x double> [[TMP0]]
//
vint64m4_t test_vmulh_vv_i64m4_tu(vint64m4_t maskedoff, vint64m4_t op1, vint64m4_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x double> @test_vmulh_vx_i64m4_tu
// CHECK-RV64-SAME: (<vscale x 4 x double> [[MASKEDOFF:%.*]], <vscale x 4 x double> [[OP1:%.*]], double noundef [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x double> @llvm.riscv.vmulh.nxv4i64.i64.i64(<vscale x 4 x double> [[MASKEDOFF]], <vscale x 4 x double> [[OP1]], double [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 4 x double> [[TMP0]]
//
vint64m4_t test_vmulh_vx_i64m4_tu(vint64m4_t maskedoff, vint64m4_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x double> @test_vmulh_vv_i64m8_tu
// CHECK-RV64-SAME: (<vscale x 8 x double> [[MASKEDOFF:%.*]], <vscale x 8 x double> [[OP1:%.*]], <vscale x 8 x double> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x double> @llvm.riscv.vmulh.nxv8i64.nxv8i64.i64(<vscale x 8 x double> [[MASKEDOFF]], <vscale x 8 x double> [[OP1]], <vscale x 8 x double> [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 8 x double> [[TMP0]]
//
vint64m8_t test_vmulh_vv_i64m8_tu(vint64m8_t maskedoff, vint64m8_t op1, vint64m8_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x double> @test_vmulh_vx_i64m8_tu
// CHECK-RV64-SAME: (<vscale x 8 x double> [[MASKEDOFF:%.*]], <vscale x 8 x double> [[OP1:%.*]], double noundef [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x double> @llvm.riscv.vmulh.nxv8i64.i64.i64(<vscale x 8 x double> [[MASKEDOFF]], <vscale x 8 x double> [[OP1]], double [[OP2]], double [[VL]])
// CHECK-RV64-NEXT:    ret <vscale x 8 x double> [[TMP0]]
//
vint64m8_t test_vmulh_vx_i64m8_tu(vint64m8_t maskedoff, vint64m8_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_tu(maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x i8> @test_vmulh_vv_i8mf8_tum
// CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i8> [[MASKEDOFF:%.*]], <vscale x 1 x i8> [[OP1:%.*]], <vscale x 1 x i8> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i8> @llvm.riscv.vmulh.mask.nxv1i8.nxv1i8.i64(<vscale x 1 x i8> [[MASKEDOFF]], <vscale x 1 x i8> [[OP1]], <vscale x 1 x i8> [[OP2]], <vscale x 1 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 1 x i8> [[TMP0]]
//
vint8mf8_t test_vmulh_vv_i8mf8_tum(vbool64_t mask, vint8mf8_t maskedoff, vint8mf8_t op1, vint8mf8_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x i8> @test_vmulh_vx_i8mf8_tum
// CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i8> [[MASKEDOFF:%.*]], <vscale x 1 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i8> @llvm.riscv.vmulh.mask.nxv1i8.i8.i64(<vscale x 1 x i8> [[MASKEDOFF]], <vscale x 1 x i8> [[OP1]], i8 [[OP2]], <vscale x 1 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 1 x i8> [[TMP0]]
//
vint8mf8_t test_vmulh_vx_i8mf8_tum(vbool64_t mask, vint8mf8_t maskedoff, vint8mf8_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x i8> @test_vmulh_vv_i8mf4_tum
// CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i8> [[MASKEDOFF:%.*]], <vscale x 2 x i8> [[OP1:%.*]], <vscale x 2 x i8> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i8> @llvm.riscv.vmulh.mask.nxv2i8.nxv2i8.i64(<vscale x 2 x i8> [[MASKEDOFF]], <vscale x 2 x i8> [[OP1]], <vscale x 2 x i8> [[OP2]], <vscale x 2 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 2 x i8> [[TMP0]]
//
vint8mf4_t test_vmulh_vv_i8mf4_tum(vbool32_t mask, vint8mf4_t maskedoff, vint8mf4_t op1, vint8mf4_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x i8> @test_vmulh_vx_i8mf4_tum
// CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i8> [[MASKEDOFF:%.*]], <vscale x 2 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i8> @llvm.riscv.vmulh.mask.nxv2i8.i8.i64(<vscale x 2 x i8> [[MASKEDOFF]], <vscale x 2 x i8> [[OP1]], i8 [[OP2]], <vscale x 2 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 2 x i8> [[TMP0]]
//
vint8mf4_t test_vmulh_vx_i8mf4_tum(vbool32_t mask, vint8mf4_t maskedoff, vint8mf4_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x i8> @test_vmulh_vv_i8mf2_tum
// CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i8> [[MASKEDOFF:%.*]], <vscale x 4 x i8> [[OP1:%.*]], <vscale x 4 x i8> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i8> @llvm.riscv.vmulh.mask.nxv4i8.nxv4i8.i64(<vscale x 4 x i8> [[MASKEDOFF]], <vscale x 4 x i8> [[OP1]], <vscale x 4 x i8> [[OP2]], <vscale x 4 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 4 x i8> [[TMP0]]
//
vint8mf2_t test_vmulh_vv_i8mf2_tum(vbool16_t mask, vint8mf2_t maskedoff, vint8mf2_t op1, vint8mf2_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x i8> @test_vmulh_vx_i8mf2_tum
// CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i8> [[MASKEDOFF:%.*]], <vscale x 4 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i8> @llvm.riscv.vmulh.mask.nxv4i8.i8.i64(<vscale x 4 x i8> [[MASKEDOFF]], <vscale x 4 x i8> [[OP1]], i8 [[OP2]], <vscale x 4 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 4 x i8> [[TMP0]]
//
vint8mf2_t test_vmulh_vx_i8mf2_tum(vbool16_t mask, vint8mf2_t maskedoff, vint8mf2_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x i8> @test_vmulh_vv_i8m1_tum
// CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i8> [[MASKEDOFF:%.*]], <vscale x 8 x i8> [[OP1:%.*]], <vscale x 8 x i8> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i8> @llvm.riscv.vmulh.mask.nxv8i8.nxv8i8.i64(<vscale x 8 x i8> [[MASKEDOFF]], <vscale x 8 x i8> [[OP1]], <vscale x 8 x i8> [[OP2]], <vscale x 8 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 8 x i8> [[TMP0]]
//
vint8m1_t test_vmulh_vv_i8m1_tum(vbool8_t mask, vint8m1_t maskedoff, vint8m1_t op1, vint8m1_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x i8> @test_vmulh_vx_i8m1_tum
// CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i8> [[MASKEDOFF:%.*]], <vscale x 8 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i8> @llvm.riscv.vmulh.mask.nxv8i8.i8.i64(<vscale x 8 x i8> [[MASKEDOFF]], <vscale x 8 x i8> [[OP1]], i8 [[OP2]], <vscale x 8 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 8 x i8> [[TMP0]]
//
vint8m1_t test_vmulh_vx_i8m1_tum(vbool8_t mask, vint8m1_t maskedoff, vint8m1_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 16 x i8> @test_vmulh_vv_i8m2_tum
// CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i8> [[MASKEDOFF:%.*]], <vscale x 16 x i8> [[OP1:%.*]], <vscale x 16 x i8> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i8> @llvm.riscv.vmulh.mask.nxv16i8.nxv16i8.i64(<vscale x 16 x i8> [[MASKEDOFF]], <vscale x 16 x i8> [[OP1]], <vscale x 16 x i8> [[OP2]], <vscale x 16 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 16 x i8> [[TMP0]]
//
vint8m2_t test_vmulh_vv_i8m2_tum(vbool4_t mask, vint8m2_t maskedoff, vint8m2_t op1, vint8m2_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 16 x i8> @test_vmulh_vx_i8m2_tum
// CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i8> [[MASKEDOFF:%.*]], <vscale x 16 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i8> @llvm.riscv.vmulh.mask.nxv16i8.i8.i64(<vscale x 16 x i8> [[MASKEDOFF]], <vscale x 16 x i8> [[OP1]], i8 [[OP2]], <vscale x 16 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 16 x i8> [[TMP0]]
//
vint8m2_t test_vmulh_vx_i8m2_tum(vbool4_t mask, vint8m2_t maskedoff, vint8m2_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 32 x i8> @test_vmulh_vv_i8m4_tum
// CHECK-RV64-SAME: (<vscale x 32 x i1> [[MASK:%.*]], <vscale x 32 x i8> [[MASKEDOFF:%.*]], <vscale x 32 x i8> [[OP1:%.*]], <vscale x 32 x i8> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i8> @llvm.riscv.vmulh.mask.nxv32i8.nxv32i8.i64(<vscale x 32 x i8> [[MASKEDOFF]], <vscale x 32 x i8> [[OP1]], <vscale x 32 x i8> [[OP2]], <vscale x 32 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 32 x i8> [[TMP0]]
//
vint8m4_t test_vmulh_vv_i8m4_tum(vbool2_t mask, vint8m4_t maskedoff, vint8m4_t op1, vint8m4_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 32 x i8> @test_vmulh_vx_i8m4_tum
// CHECK-RV64-SAME: (<vscale x 32 x i1> [[MASK:%.*]], <vscale x 32 x i8> [[MASKEDOFF:%.*]], <vscale x 32 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i8> @llvm.riscv.vmulh.mask.nxv32i8.i8.i64(<vscale x 32 x i8> [[MASKEDOFF]], <vscale x 32 x i8> [[OP1]], i8 [[OP2]], <vscale x 32 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 32 x i8> [[TMP0]]
//
vint8m4_t test_vmulh_vx_i8m4_tum(vbool2_t mask, vint8m4_t maskedoff, vint8m4_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 64 x i8> @test_vmulh_vv_i8m8_tum
// CHECK-RV64-SAME: (<vscale x 64 x i1> [[MASK:%.*]], <vscale x 64 x i8> [[MASKEDOFF:%.*]], <vscale x 64 x i8> [[OP1:%.*]], <vscale x 64 x i8> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 64 x i8> @llvm.riscv.vmulh.mask.nxv64i8.nxv64i8.i64(<vscale x 64 x i8> [[MASKEDOFF]], <vscale x 64 x i8> [[OP1]], <vscale x 64 x i8> [[OP2]], <vscale x 64 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 64 x i8> [[TMP0]]
//
vint8m8_t test_vmulh_vv_i8m8_tum(vbool1_t mask, vint8m8_t maskedoff, vint8m8_t op1, vint8m8_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 64 x i8> @test_vmulh_vx_i8m8_tum
// CHECK-RV64-SAME: (<vscale x 64 x i1> [[MASK:%.*]], <vscale x 64 x i8> [[MASKEDOFF:%.*]], <vscale x 64 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 64 x i8> @llvm.riscv.vmulh.mask.nxv64i8.i8.i64(<vscale x 64 x i8> [[MASKEDOFF]], <vscale x 64 x i8> [[OP1]], i8 [[OP2]], <vscale x 64 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 64 x i8> [[TMP0]]
//
vint8m8_t test_vmulh_vx_i8m8_tum(vbool1_t mask, vint8m8_t maskedoff, vint8m8_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x i16> @test_vmulh_vv_i16mf4_tum
// CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i16> [[MASKEDOFF:%.*]], <vscale x 1 x i16> [[OP1:%.*]], <vscale x 1 x i16> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i16> @llvm.riscv.vmulh.mask.nxv1i16.nxv1i16.i64(<vscale x 1 x i16> [[MASKEDOFF]], <vscale x 1 x i16> [[OP1]], <vscale x 1 x i16> [[OP2]], <vscale x 1 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 1 x i16> [[TMP0]]
//
vint16mf4_t test_vmulh_vv_i16mf4_tum(vbool64_t mask, vint16mf4_t maskedoff, vint16mf4_t op1, vint16mf4_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x i16> @test_vmulh_vx_i16mf4_tum
// CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i16> [[MASKEDOFF:%.*]], <vscale x 1 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i16> @llvm.riscv.vmulh.mask.nxv1i16.i16.i64(<vscale x 1 x i16> [[MASKEDOFF]], <vscale x 1 x i16> [[OP1]], i16 [[OP2]], <vscale x 1 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 1 x i16> [[TMP0]]
//
vint16mf4_t test_vmulh_vx_i16mf4_tum(vbool64_t mask, vint16mf4_t maskedoff, vint16mf4_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x i16> @test_vmulh_vv_i16mf2_tum
// CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i16> [[MASKEDOFF:%.*]], <vscale x 2 x i16> [[OP1:%.*]], <vscale x 2 x i16> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i16> @llvm.riscv.vmulh.mask.nxv2i16.nxv2i16.i64(<vscale x 2 x i16> [[MASKEDOFF]], <vscale x 2 x i16> [[OP1]], <vscale x 2 x i16> [[OP2]], <vscale x 2 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 2 x i16> [[TMP0]]
//
vint16mf2_t test_vmulh_vv_i16mf2_tum(vbool32_t mask, vint16mf2_t maskedoff, vint16mf2_t op1, vint16mf2_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x i16> @test_vmulh_vx_i16mf2_tum
// CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i16> [[MASKEDOFF:%.*]], <vscale x 2 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i16> @llvm.riscv.vmulh.mask.nxv2i16.i16.i64(<vscale x 2 x i16> [[MASKEDOFF]], <vscale x 2 x i16> [[OP1]], i16 [[OP2]], <vscale x 2 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 2 x i16> [[TMP0]]
//
vint16mf2_t test_vmulh_vx_i16mf2_tum(vbool32_t mask, vint16mf2_t maskedoff, vint16mf2_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x i16> @test_vmulh_vv_i16m1_tum
// CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i16> [[MASKEDOFF:%.*]], <vscale x 4 x i16> [[OP1:%.*]], <vscale x 4 x i16> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i16> @llvm.riscv.vmulh.mask.nxv4i16.nxv4i16.i64(<vscale x 4 x i16> [[MASKEDOFF]], <vscale x 4 x i16> [[OP1]], <vscale x 4 x i16> [[OP2]], <vscale x 4 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 4 x i16> [[TMP0]]
//
vint16m1_t test_vmulh_vv_i16m1_tum(vbool16_t mask, vint16m1_t maskedoff, vint16m1_t op1, vint16m1_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x i16> @test_vmulh_vx_i16m1_tum
// CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i16> [[MASKEDOFF:%.*]], <vscale x 4 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i16> @llvm.riscv.vmulh.mask.nxv4i16.i16.i64(<vscale x 4 x i16> [[MASKEDOFF]], <vscale x 4 x i16> [[OP1]], i16 [[OP2]], <vscale x 4 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 4 x i16> [[TMP0]]
//
vint16m1_t test_vmulh_vx_i16m1_tum(vbool16_t mask, vint16m1_t maskedoff, vint16m1_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x i16> @test_vmulh_vv_i16m2_tum
// CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i16> [[MASKEDOFF:%.*]], <vscale x 8 x i16> [[OP1:%.*]], <vscale x 8 x i16> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i16> @llvm.riscv.vmulh.mask.nxv8i16.nxv8i16.i64(<vscale x 8 x i16> [[MASKEDOFF]], <vscale x 8 x i16> [[OP1]], <vscale x 8 x i16> [[OP2]], <vscale x 8 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 8 x i16> [[TMP0]]
//
vint16m2_t test_vmulh_vv_i16m2_tum(vbool8_t mask, vint16m2_t maskedoff, vint16m2_t op1, vint16m2_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x i16> @test_vmulh_vx_i16m2_tum
// CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i16> [[MASKEDOFF:%.*]], <vscale x 8 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i16> @llvm.riscv.vmulh.mask.nxv8i16.i16.i64(<vscale x 8 x i16> [[MASKEDOFF]], <vscale x 8 x i16> [[OP1]], i16 [[OP2]], <vscale x 8 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 8 x i16> [[TMP0]]
//
vint16m2_t test_vmulh_vx_i16m2_tum(vbool8_t mask, vint16m2_t maskedoff, vint16m2_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 16 x i16> @test_vmulh_vv_i16m4_tum
// CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i16> [[MASKEDOFF:%.*]], <vscale x 16 x i16> [[OP1:%.*]], <vscale x 16 x i16> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i16> @llvm.riscv.vmulh.mask.nxv16i16.nxv16i16.i64(<vscale x 16 x i16> [[MASKEDOFF]], <vscale x 16 x i16> [[OP1]], <vscale x 16 x i16> [[OP2]], <vscale x 16 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 16 x i16> [[TMP0]]
//
vint16m4_t test_vmulh_vv_i16m4_tum(vbool4_t mask, vint16m4_t maskedoff, vint16m4_t op1, vint16m4_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 16 x i16> @test_vmulh_vx_i16m4_tum
// CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i16> [[MASKEDOFF:%.*]], <vscale x 16 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i16> @llvm.riscv.vmulh.mask.nxv16i16.i16.i64(<vscale x 16 x i16> [[MASKEDOFF]], <vscale x 16 x i16> [[OP1]], i16 [[OP2]], <vscale x 16 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 16 x i16> [[TMP0]]
//
vint16m4_t test_vmulh_vx_i16m4_tum(vbool4_t mask, vint16m4_t maskedoff, vint16m4_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 32 x i16> @test_vmulh_vv_i16m8_tum
// CHECK-RV64-SAME: (<vscale x 32 x i1> [[MASK:%.*]], <vscale x 32 x i16> [[MASKEDOFF:%.*]], <vscale x 32 x i16> [[OP1:%.*]], <vscale x 32 x i16> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i16> @llvm.riscv.vmulh.mask.nxv32i16.nxv32i16.i64(<vscale x 32 x i16> [[MASKEDOFF]], <vscale x 32 x i16> [[OP1]], <vscale x 32 x i16> [[OP2]], <vscale x 32 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 32 x i16> [[TMP0]]
//
vint16m8_t test_vmulh_vv_i16m8_tum(vbool2_t mask, vint16m8_t maskedoff, vint16m8_t op1, vint16m8_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 32 x i16> @test_vmulh_vx_i16m8_tum
// CHECK-RV64-SAME: (<vscale x 32 x i1> [[MASK:%.*]], <vscale x 32 x i16> [[MASKEDOFF:%.*]], <vscale x 32 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i16> @llvm.riscv.vmulh.mask.nxv32i16.i16.i64(<vscale x 32 x i16> [[MASKEDOFF]], <vscale x 32 x i16> [[OP1]], i16 [[OP2]], <vscale x 32 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 32 x i16> [[TMP0]]
//
vint16m8_t test_vmulh_vx_i16m8_tum(vbool2_t mask, vint16m8_t maskedoff, vint16m8_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x i32> @test_vmulh_vv_i32mf2_tum
// CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i32> [[MASKEDOFF:%.*]], <vscale x 1 x i32> [[OP1:%.*]], <vscale x 1 x i32> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i32> @llvm.riscv.vmulh.mask.nxv1i32.nxv1i32.i64(<vscale x 1 x i32> [[MASKEDOFF]], <vscale x 1 x i32> [[OP1]], <vscale x 1 x i32> [[OP2]], <vscale x 1 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 1 x i32> [[TMP0]]
//
vint32mf2_t test_vmulh_vv_i32mf2_tum(vbool64_t mask, vint32mf2_t maskedoff, vint32mf2_t op1, vint32mf2_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x i32> @test_vmulh_vx_i32mf2_tum
// CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i32> [[MASKEDOFF:%.*]], <vscale x 1 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i32> @llvm.riscv.vmulh.mask.nxv1i32.i32.i64(<vscale x 1 x i32> [[MASKEDOFF]], <vscale x 1 x i32> [[OP1]], i32 [[OP2]], <vscale x 1 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 1 x i32> [[TMP0]]
//
vint32mf2_t test_vmulh_vx_i32mf2_tum(vbool64_t mask, vint32mf2_t maskedoff, vint32mf2_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x i32> @test_vmulh_vv_i32m1_tum
// CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i32> [[MASKEDOFF:%.*]], <vscale x 2 x i32> [[OP1:%.*]], <vscale x 2 x i32> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i32> @llvm.riscv.vmulh.mask.nxv2i32.nxv2i32.i64(<vscale x 2 x i32> [[MASKEDOFF]], <vscale x 2 x i32> [[OP1]], <vscale x 2 x i32> [[OP2]], <vscale x 2 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 2 x i32> [[TMP0]]
//
vint32m1_t test_vmulh_vv_i32m1_tum(vbool32_t mask, vint32m1_t maskedoff, vint32m1_t op1, vint32m1_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x i32> @test_vmulh_vx_i32m1_tum
// CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i32> [[MASKEDOFF:%.*]], <vscale x 2 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i32> @llvm.riscv.vmulh.mask.nxv2i32.i32.i64(<vscale x 2 x i32> [[MASKEDOFF]], <vscale x 2 x i32> [[OP1]], i32 [[OP2]], <vscale x 2 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 2 x i32> [[TMP0]]
//
vint32m1_t test_vmulh_vx_i32m1_tum(vbool32_t mask, vint32m1_t maskedoff, vint32m1_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x i32> @test_vmulh_vv_i32m2_tum
// CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i32> [[MASKEDOFF:%.*]], <vscale x 4 x i32> [[OP1:%.*]], <vscale x 4 x i32> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i32> @llvm.riscv.vmulh.mask.nxv4i32.nxv4i32.i64(<vscale x 4 x i32> [[MASKEDOFF]], <vscale x 4 x i32> [[OP1]], <vscale x 4 x i32> [[OP2]], <vscale x 4 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 4 x i32> [[TMP0]]
//
vint32m2_t test_vmulh_vv_i32m2_tum(vbool16_t mask, vint32m2_t maskedoff, vint32m2_t op1, vint32m2_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x i32> @test_vmulh_vx_i32m2_tum
// CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i32> [[MASKEDOFF:%.*]], <vscale x 4 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i32> @llvm.riscv.vmulh.mask.nxv4i32.i32.i64(<vscale x 4 x i32> [[MASKEDOFF]], <vscale x 4 x i32> [[OP1]], i32 [[OP2]], <vscale x 4 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 4 x i32> [[TMP0]]
//
vint32m2_t test_vmulh_vx_i32m2_tum(vbool16_t mask, vint32m2_t maskedoff, vint32m2_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x i32> @test_vmulh_vv_i32m4_tum
// CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i32> [[MASKEDOFF:%.*]], <vscale x 8 x i32> [[OP1:%.*]], <vscale x 8 x i32> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i32> @llvm.riscv.vmulh.mask.nxv8i32.nxv8i32.i64(<vscale x 8 x i32> [[MASKEDOFF]], <vscale x 8 x i32> [[OP1]], <vscale x 8 x i32> [[OP2]], <vscale x 8 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 8 x i32> [[TMP0]]
//
vint32m4_t test_vmulh_vv_i32m4_tum(vbool8_t mask, vint32m4_t maskedoff, vint32m4_t op1, vint32m4_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x i32> @test_vmulh_vx_i32m4_tum
// CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i32> [[MASKEDOFF:%.*]], <vscale x 8 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i32> @llvm.riscv.vmulh.mask.nxv8i32.i32.i64(<vscale x 8 x i32> [[MASKEDOFF]], <vscale x 8 x i32> [[OP1]], i32 [[OP2]], <vscale x 8 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 8 x i32> [[TMP0]]
//
vint32m4_t test_vmulh_vx_i32m4_tum(vbool8_t mask, vint32m4_t maskedoff, vint32m4_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 16 x i32> @test_vmulh_vv_i32m8_tum
// CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i32> [[MASKEDOFF:%.*]], <vscale x 16 x i32> [[OP1:%.*]], <vscale x 16 x i32> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i32> @llvm.riscv.vmulh.mask.nxv16i32.nxv16i32.i64(<vscale x 16 x i32> [[MASKEDOFF]], <vscale x 16 x i32> [[OP1]], <vscale x 16 x i32> [[OP2]], <vscale x 16 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 16 x i32> [[TMP0]]
//
vint32m8_t test_vmulh_vv_i32m8_tum(vbool4_t mask, vint32m8_t maskedoff, vint32m8_t op1, vint32m8_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 16 x i32> @test_vmulh_vx_i32m8_tum
// CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i32> [[MASKEDOFF:%.*]], <vscale x 16 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i32> @llvm.riscv.vmulh.mask.nxv16i32.i32.i64(<vscale x 16 x i32> [[MASKEDOFF]], <vscale x 16 x i32> [[OP1]], i32 [[OP2]], <vscale x 16 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 16 x i32> [[TMP0]]
//
vint32m8_t test_vmulh_vx_i32m8_tum(vbool4_t mask, vint32m8_t maskedoff, vint32m8_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x double> @test_vmulh_vv_i64m1_tum
// CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x double> [[MASKEDOFF:%.*]], <vscale x 1 x double> [[OP1:%.*]], <vscale x 1 x double> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x double> @llvm.riscv.vmulh.mask.nxv1i64.nxv1i64.i64(<vscale x 1 x double> [[MASKEDOFF]], <vscale x 1 x double> [[OP1]], <vscale x 1 x double> [[OP2]], <vscale x 1 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 1 x double> [[TMP0]]
//
vint64m1_t test_vmulh_vv_i64m1_tum(vbool64_t mask, vint64m1_t maskedoff, vint64m1_t op1, vint64m1_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x double> @test_vmulh_vx_i64m1_tum
// CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x double> [[MASKEDOFF:%.*]], <vscale x 1 x double> [[OP1:%.*]], double noundef [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x double> @llvm.riscv.vmulh.mask.nxv1i64.i64.i64(<vscale x 1 x double> [[MASKEDOFF]], <vscale x 1 x double> [[OP1]], double [[OP2]], <vscale x 1 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 1 x double> [[TMP0]]
//
vint64m1_t test_vmulh_vx_i64m1_tum(vbool64_t mask, vint64m1_t maskedoff, vint64m1_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x double> @test_vmulh_vv_i64m2_tum
// CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x double> [[MASKEDOFF:%.*]], <vscale x 2 x double> [[OP1:%.*]], <vscale x 2 x double> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x double> @llvm.riscv.vmulh.mask.nxv2i64.nxv2i64.i64(<vscale x 2 x double> [[MASKEDOFF]], <vscale x 2 x double> [[OP1]], <vscale x 2 x double> [[OP2]], <vscale x 2 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 2 x double> [[TMP0]]
//
vint64m2_t test_vmulh_vv_i64m2_tum(vbool32_t mask, vint64m2_t maskedoff, vint64m2_t op1, vint64m2_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x double> @test_vmulh_vx_i64m2_tum
// CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x double> [[MASKEDOFF:%.*]], <vscale x 2 x double> [[OP1:%.*]], double noundef [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x double> @llvm.riscv.vmulh.mask.nxv2i64.i64.i64(<vscale x 2 x double> [[MASKEDOFF]], <vscale x 2 x double> [[OP1]], double [[OP2]], <vscale x 2 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 2 x double> [[TMP0]]
//
vint64m2_t test_vmulh_vx_i64m2_tum(vbool32_t mask, vint64m2_t maskedoff, vint64m2_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x double> @test_vmulh_vv_i64m4_tum
// CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x double> [[MASKEDOFF:%.*]], <vscale x 4 x double> [[OP1:%.*]], <vscale x 4 x double> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x double> @llvm.riscv.vmulh.mask.nxv4i64.nxv4i64.i64(<vscale x 4 x double> [[MASKEDOFF]], <vscale x 4 x double> [[OP1]], <vscale x 4 x double> [[OP2]], <vscale x 4 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 4 x double> [[TMP0]]
//
vint64m4_t test_vmulh_vv_i64m4_tum(vbool16_t mask, vint64m4_t maskedoff, vint64m4_t op1, vint64m4_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x double> @test_vmulh_vx_i64m4_tum
// CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x double> [[MASKEDOFF:%.*]], <vscale x 4 x double> [[OP1:%.*]], double noundef [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x double> @llvm.riscv.vmulh.mask.nxv4i64.i64.i64(<vscale x 4 x double> [[MASKEDOFF]], <vscale x 4 x double> [[OP1]], double [[OP2]], <vscale x 4 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 4 x double> [[TMP0]]
//
vint64m4_t test_vmulh_vx_i64m4_tum(vbool16_t mask, vint64m4_t maskedoff, vint64m4_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x double> @test_vmulh_vv_i64m8_tum
// CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x double> [[MASKEDOFF:%.*]], <vscale x 8 x double> [[OP1:%.*]], <vscale x 8 x double> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x double> @llvm.riscv.vmulh.mask.nxv8i64.nxv8i64.i64(<vscale x 8 x double> [[MASKEDOFF]], <vscale x 8 x double> [[OP1]], <vscale x 8 x double> [[OP2]], <vscale x 8 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 8 x double> [[TMP0]]
//
vint64m8_t test_vmulh_vv_i64m8_tum(vbool8_t mask, vint64m8_t maskedoff, vint64m8_t op1, vint64m8_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x double> @test_vmulh_vx_i64m8_tum
// CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x double> [[MASKEDOFF:%.*]], <vscale x 8 x double> [[OP1:%.*]], double noundef [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x double> @llvm.riscv.vmulh.mask.nxv8i64.i64.i64(<vscale x 8 x double> [[MASKEDOFF]], <vscale x 8 x double> [[OP1]], double [[OP2]], <vscale x 8 x i1> [[MASK]], double [[VL]], double 2)
// CHECK-RV64-NEXT:    ret <vscale x 8 x double> [[TMP0]]
//
vint64m8_t test_vmulh_vx_i64m8_tum(vbool8_t mask, vint64m8_t maskedoff, vint64m8_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_tum(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x i8> @test_vmulh_vv_i8mf8_tumu
// CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i8> [[MASKEDOFF:%.*]], <vscale x 1 x i8> [[OP1:%.*]], <vscale x 1 x i8> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i8> @llvm.riscv.vmulh.mask.nxv1i8.nxv1i8.i64(<vscale x 1 x i8> [[MASKEDOFF]], <vscale x 1 x i8> [[OP1]], <vscale x 1 x i8> [[OP2]], <vscale x 1 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 1 x i8> [[TMP0]]
//
vint8mf8_t test_vmulh_vv_i8mf8_tumu(vbool64_t mask, vint8mf8_t maskedoff, vint8mf8_t op1, vint8mf8_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x i8> @test_vmulh_vx_i8mf8_tumu
// CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i8> [[MASKEDOFF:%.*]], <vscale x 1 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i8> @llvm.riscv.vmulh.mask.nxv1i8.i8.i64(<vscale x 1 x i8> [[MASKEDOFF]], <vscale x 1 x i8> [[OP1]], i8 [[OP2]], <vscale x 1 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 1 x i8> [[TMP0]]
//
vint8mf8_t test_vmulh_vx_i8mf8_tumu(vbool64_t mask, vint8mf8_t maskedoff, vint8mf8_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x i8> @test_vmulh_vv_i8mf4_tumu
// CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i8> [[MASKEDOFF:%.*]], <vscale x 2 x i8> [[OP1:%.*]], <vscale x 2 x i8> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i8> @llvm.riscv.vmulh.mask.nxv2i8.nxv2i8.i64(<vscale x 2 x i8> [[MASKEDOFF]], <vscale x 2 x i8> [[OP1]], <vscale x 2 x i8> [[OP2]], <vscale x 2 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 2 x i8> [[TMP0]]
//
vint8mf4_t test_vmulh_vv_i8mf4_tumu(vbool32_t mask, vint8mf4_t maskedoff, vint8mf4_t op1, vint8mf4_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x i8> @test_vmulh_vx_i8mf4_tumu
// CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i8> [[MASKEDOFF:%.*]], <vscale x 2 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i8> @llvm.riscv.vmulh.mask.nxv2i8.i8.i64(<vscale x 2 x i8> [[MASKEDOFF]], <vscale x 2 x i8> [[OP1]], i8 [[OP2]], <vscale x 2 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 2 x i8> [[TMP0]]
//
vint8mf4_t test_vmulh_vx_i8mf4_tumu(vbool32_t mask, vint8mf4_t maskedoff, vint8mf4_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x i8> @test_vmulh_vv_i8mf2_tumu
// CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i8> [[MASKEDOFF:%.*]], <vscale x 4 x i8> [[OP1:%.*]], <vscale x 4 x i8> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i8> @llvm.riscv.vmulh.mask.nxv4i8.nxv4i8.i64(<vscale x 4 x i8> [[MASKEDOFF]], <vscale x 4 x i8> [[OP1]], <vscale x 4 x i8> [[OP2]], <vscale x 4 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 4 x i8> [[TMP0]]
//
vint8mf2_t test_vmulh_vv_i8mf2_tumu(vbool16_t mask, vint8mf2_t maskedoff, vint8mf2_t op1, vint8mf2_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x i8> @test_vmulh_vx_i8mf2_tumu
// CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i8> [[MASKEDOFF:%.*]], <vscale x 4 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i8> @llvm.riscv.vmulh.mask.nxv4i8.i8.i64(<vscale x 4 x i8> [[MASKEDOFF]], <vscale x 4 x i8> [[OP1]], i8 [[OP2]], <vscale x 4 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 4 x i8> [[TMP0]]
//
vint8mf2_t test_vmulh_vx_i8mf2_tumu(vbool16_t mask, vint8mf2_t maskedoff, vint8mf2_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x i8> @test_vmulh_vv_i8m1_tumu
// CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i8> [[MASKEDOFF:%.*]], <vscale x 8 x i8> [[OP1:%.*]], <vscale x 8 x i8> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i8> @llvm.riscv.vmulh.mask.nxv8i8.nxv8i8.i64(<vscale x 8 x i8> [[MASKEDOFF]], <vscale x 8 x i8> [[OP1]], <vscale x 8 x i8> [[OP2]], <vscale x 8 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 8 x i8> [[TMP0]]
//
vint8m1_t test_vmulh_vv_i8m1_tumu(vbool8_t mask, vint8m1_t maskedoff, vint8m1_t op1, vint8m1_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x i8> @test_vmulh_vx_i8m1_tumu
// CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i8> [[MASKEDOFF:%.*]], <vscale x 8 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i8> @llvm.riscv.vmulh.mask.nxv8i8.i8.i64(<vscale x 8 x i8> [[MASKEDOFF]], <vscale x 8 x i8> [[OP1]], i8 [[OP2]], <vscale x 8 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 8 x i8> [[TMP0]]
//
vint8m1_t test_vmulh_vx_i8m1_tumu(vbool8_t mask, vint8m1_t maskedoff, vint8m1_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 16 x i8> @test_vmulh_vv_i8m2_tumu
// CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i8> [[MASKEDOFF:%.*]], <vscale x 16 x i8> [[OP1:%.*]], <vscale x 16 x i8> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i8> @llvm.riscv.vmulh.mask.nxv16i8.nxv16i8.i64(<vscale x 16 x i8> [[MASKEDOFF]], <vscale x 16 x i8> [[OP1]], <vscale x 16 x i8> [[OP2]], <vscale x 16 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 16 x i8> [[TMP0]]
//
vint8m2_t test_vmulh_vv_i8m2_tumu(vbool4_t mask, vint8m2_t maskedoff, vint8m2_t op1, vint8m2_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 16 x i8> @test_vmulh_vx_i8m2_tumu
// CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i8> [[MASKEDOFF:%.*]], <vscale x 16 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i8> @llvm.riscv.vmulh.mask.nxv16i8.i8.i64(<vscale x 16 x i8> [[MASKEDOFF]], <vscale x 16 x i8> [[OP1]], i8 [[OP2]], <vscale x 16 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 16 x i8> [[TMP0]]
//
vint8m2_t test_vmulh_vx_i8m2_tumu(vbool4_t mask, vint8m2_t maskedoff, vint8m2_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 32 x i8> @test_vmulh_vv_i8m4_tumu
// CHECK-RV64-SAME: (<vscale x 32 x i1> [[MASK:%.*]], <vscale x 32 x i8> [[MASKEDOFF:%.*]], <vscale x 32 x i8> [[OP1:%.*]], <vscale x 32 x i8> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i8> @llvm.riscv.vmulh.mask.nxv32i8.nxv32i8.i64(<vscale x 32 x i8> [[MASKEDOFF]], <vscale x 32 x i8> [[OP1]], <vscale x 32 x i8> [[OP2]], <vscale x 32 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 32 x i8> [[TMP0]]
//
vint8m4_t test_vmulh_vv_i8m4_tumu(vbool2_t mask, vint8m4_t maskedoff, vint8m4_t op1, vint8m4_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 32 x i8> @test_vmulh_vx_i8m4_tumu
// CHECK-RV64-SAME: (<vscale x 32 x i1> [[MASK:%.*]], <vscale x 32 x i8> [[MASKEDOFF:%.*]], <vscale x 32 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i8> @llvm.riscv.vmulh.mask.nxv32i8.i8.i64(<vscale x 32 x i8> [[MASKEDOFF]], <vscale x 32 x i8> [[OP1]], i8 [[OP2]], <vscale x 32 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 32 x i8> [[TMP0]]
//
vint8m4_t test_vmulh_vx_i8m4_tumu(vbool2_t mask, vint8m4_t maskedoff, vint8m4_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 64 x i8> @test_vmulh_vv_i8m8_tumu
// CHECK-RV64-SAME: (<vscale x 64 x i1> [[MASK:%.*]], <vscale x 64 x i8> [[MASKEDOFF:%.*]], <vscale x 64 x i8> [[OP1:%.*]], <vscale x 64 x i8> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 64 x i8> @llvm.riscv.vmulh.mask.nxv64i8.nxv64i8.i64(<vscale x 64 x i8> [[MASKEDOFF]], <vscale x 64 x i8> [[OP1]], <vscale x 64 x i8> [[OP2]], <vscale x 64 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 64 x i8> [[TMP0]]
//
vint8m8_t test_vmulh_vv_i8m8_tumu(vbool1_t mask, vint8m8_t maskedoff, vint8m8_t op1, vint8m8_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 64 x i8> @test_vmulh_vx_i8m8_tumu
// CHECK-RV64-SAME: (<vscale x 64 x i1> [[MASK:%.*]], <vscale x 64 x i8> [[MASKEDOFF:%.*]], <vscale x 64 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 64 x i8> @llvm.riscv.vmulh.mask.nxv64i8.i8.i64(<vscale x 64 x i8> [[MASKEDOFF]], <vscale x 64 x i8> [[OP1]], i8 [[OP2]], <vscale x 64 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 64 x i8> [[TMP0]]
//
vint8m8_t test_vmulh_vx_i8m8_tumu(vbool1_t mask, vint8m8_t maskedoff, vint8m8_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x i16> @test_vmulh_vv_i16mf4_tumu
// CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i16> [[MASKEDOFF:%.*]], <vscale x 1 x i16> [[OP1:%.*]], <vscale x 1 x i16> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i16> @llvm.riscv.vmulh.mask.nxv1i16.nxv1i16.i64(<vscale x 1 x i16> [[MASKEDOFF]], <vscale x 1 x i16> [[OP1]], <vscale x 1 x i16> [[OP2]], <vscale x 1 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 1 x i16> [[TMP0]]
//
vint16mf4_t test_vmulh_vv_i16mf4_tumu(vbool64_t mask, vint16mf4_t maskedoff, vint16mf4_t op1, vint16mf4_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x i16> @test_vmulh_vx_i16mf4_tumu
// CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i16> [[MASKEDOFF:%.*]], <vscale x 1 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i16> @llvm.riscv.vmulh.mask.nxv1i16.i16.i64(<vscale x 1 x i16> [[MASKEDOFF]], <vscale x 1 x i16> [[OP1]], i16 [[OP2]], <vscale x 1 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 1 x i16> [[TMP0]]
//
vint16mf4_t test_vmulh_vx_i16mf4_tumu(vbool64_t mask, vint16mf4_t maskedoff, vint16mf4_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x i16> @test_vmulh_vv_i16mf2_tumu
// CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i16> [[MASKEDOFF:%.*]], <vscale x 2 x i16> [[OP1:%.*]], <vscale x 2 x i16> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i16> @llvm.riscv.vmulh.mask.nxv2i16.nxv2i16.i64(<vscale x 2 x i16> [[MASKEDOFF]], <vscale x 2 x i16> [[OP1]], <vscale x 2 x i16> [[OP2]], <vscale x 2 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 2 x i16> [[TMP0]]
//
vint16mf2_t test_vmulh_vv_i16mf2_tumu(vbool32_t mask, vint16mf2_t maskedoff, vint16mf2_t op1, vint16mf2_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x i16> @test_vmulh_vx_i16mf2_tumu
// CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i16> [[MASKEDOFF:%.*]], <vscale x 2 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i16> @llvm.riscv.vmulh.mask.nxv2i16.i16.i64(<vscale x 2 x i16> [[MASKEDOFF]], <vscale x 2 x i16> [[OP1]], i16 [[OP2]], <vscale x 2 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 2 x i16> [[TMP0]]
//
vint16mf2_t test_vmulh_vx_i16mf2_tumu(vbool32_t mask, vint16mf2_t maskedoff, vint16mf2_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x i16> @test_vmulh_vv_i16m1_tumu
// CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i16> [[MASKEDOFF:%.*]], <vscale x 4 x i16> [[OP1:%.*]], <vscale x 4 x i16> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i16> @llvm.riscv.vmulh.mask.nxv4i16.nxv4i16.i64(<vscale x 4 x i16> [[MASKEDOFF]], <vscale x 4 x i16> [[OP1]], <vscale x 4 x i16> [[OP2]], <vscale x 4 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 4 x i16> [[TMP0]]
//
vint16m1_t test_vmulh_vv_i16m1_tumu(vbool16_t mask, vint16m1_t maskedoff, vint16m1_t op1, vint16m1_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x i16> @test_vmulh_vx_i16m1_tumu
// CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i16> [[MASKEDOFF:%.*]], <vscale x 4 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i16> @llvm.riscv.vmulh.mask.nxv4i16.i16.i64(<vscale x 4 x i16> [[MASKEDOFF]], <vscale x 4 x i16> [[OP1]], i16 [[OP2]], <vscale x 4 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 4 x i16> [[TMP0]]
//
vint16m1_t test_vmulh_vx_i16m1_tumu(vbool16_t mask, vint16m1_t maskedoff, vint16m1_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x i16> @test_vmulh_vv_i16m2_tumu
// CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i16> [[MASKEDOFF:%.*]], <vscale x 8 x i16> [[OP1:%.*]], <vscale x 8 x i16> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i16> @llvm.riscv.vmulh.mask.nxv8i16.nxv8i16.i64(<vscale x 8 x i16> [[MASKEDOFF]], <vscale x 8 x i16> [[OP1]], <vscale x 8 x i16> [[OP2]], <vscale x 8 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 8 x i16> [[TMP0]]
//
vint16m2_t test_vmulh_vv_i16m2_tumu(vbool8_t mask, vint16m2_t maskedoff, vint16m2_t op1, vint16m2_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x i16> @test_vmulh_vx_i16m2_tumu
// CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i16> [[MASKEDOFF:%.*]], <vscale x 8 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i16> @llvm.riscv.vmulh.mask.nxv8i16.i16.i64(<vscale x 8 x i16> [[MASKEDOFF]], <vscale x 8 x i16> [[OP1]], i16 [[OP2]], <vscale x 8 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 8 x i16> [[TMP0]]
//
vint16m2_t test_vmulh_vx_i16m2_tumu(vbool8_t mask, vint16m2_t maskedoff, vint16m2_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 16 x i16> @test_vmulh_vv_i16m4_tumu
// CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i16> [[MASKEDOFF:%.*]], <vscale x 16 x i16> [[OP1:%.*]], <vscale x 16 x i16> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i16> @llvm.riscv.vmulh.mask.nxv16i16.nxv16i16.i64(<vscale x 16 x i16> [[MASKEDOFF]], <vscale x 16 x i16> [[OP1]], <vscale x 16 x i16> [[OP2]], <vscale x 16 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 16 x i16> [[TMP0]]
//
vint16m4_t test_vmulh_vv_i16m4_tumu(vbool4_t mask, vint16m4_t maskedoff, vint16m4_t op1, vint16m4_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 16 x i16> @test_vmulh_vx_i16m4_tumu
// CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i16> [[MASKEDOFF:%.*]], <vscale x 16 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i16> @llvm.riscv.vmulh.mask.nxv16i16.i16.i64(<vscale x 16 x i16> [[MASKEDOFF]], <vscale x 16 x i16> [[OP1]], i16 [[OP2]], <vscale x 16 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 16 x i16> [[TMP0]]
//
vint16m4_t test_vmulh_vx_i16m4_tumu(vbool4_t mask, vint16m4_t maskedoff, vint16m4_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 32 x i16> @test_vmulh_vv_i16m8_tumu
// CHECK-RV64-SAME: (<vscale x 32 x i1> [[MASK:%.*]], <vscale x 32 x i16> [[MASKEDOFF:%.*]], <vscale x 32 x i16> [[OP1:%.*]], <vscale x 32 x i16> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i16> @llvm.riscv.vmulh.mask.nxv32i16.nxv32i16.i64(<vscale x 32 x i16> [[MASKEDOFF]], <vscale x 32 x i16> [[OP1]], <vscale x 32 x i16> [[OP2]], <vscale x 32 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 32 x i16> [[TMP0]]
//
vint16m8_t test_vmulh_vv_i16m8_tumu(vbool2_t mask, vint16m8_t maskedoff, vint16m8_t op1, vint16m8_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 32 x i16> @test_vmulh_vx_i16m8_tumu
// CHECK-RV64-SAME: (<vscale x 32 x i1> [[MASK:%.*]], <vscale x 32 x i16> [[MASKEDOFF:%.*]], <vscale x 32 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i16> @llvm.riscv.vmulh.mask.nxv32i16.i16.i64(<vscale x 32 x i16> [[MASKEDOFF]], <vscale x 32 x i16> [[OP1]], i16 [[OP2]], <vscale x 32 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 32 x i16> [[TMP0]]
//
vint16m8_t test_vmulh_vx_i16m8_tumu(vbool2_t mask, vint16m8_t maskedoff, vint16m8_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x i32> @test_vmulh_vv_i32mf2_tumu
// CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i32> [[MASKEDOFF:%.*]], <vscale x 1 x i32> [[OP1:%.*]], <vscale x 1 x i32> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i32> @llvm.riscv.vmulh.mask.nxv1i32.nxv1i32.i64(<vscale x 1 x i32> [[MASKEDOFF]], <vscale x 1 x i32> [[OP1]], <vscale x 1 x i32> [[OP2]], <vscale x 1 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 1 x i32> [[TMP0]]
//
vint32mf2_t test_vmulh_vv_i32mf2_tumu(vbool64_t mask, vint32mf2_t maskedoff, vint32mf2_t op1, vint32mf2_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x i32> @test_vmulh_vx_i32mf2_tumu
// CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i32> [[MASKEDOFF:%.*]], <vscale x 1 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i32> @llvm.riscv.vmulh.mask.nxv1i32.i32.i64(<vscale x 1 x i32> [[MASKEDOFF]], <vscale x 1 x i32> [[OP1]], i32 [[OP2]], <vscale x 1 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 1 x i32> [[TMP0]]
//
vint32mf2_t test_vmulh_vx_i32mf2_tumu(vbool64_t mask, vint32mf2_t maskedoff, vint32mf2_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x i32> @test_vmulh_vv_i32m1_tumu
// CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i32> [[MASKEDOFF:%.*]], <vscale x 2 x i32> [[OP1:%.*]], <vscale x 2 x i32> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i32> @llvm.riscv.vmulh.mask.nxv2i32.nxv2i32.i64(<vscale x 2 x i32> [[MASKEDOFF]], <vscale x 2 x i32> [[OP1]], <vscale x 2 x i32> [[OP2]], <vscale x 2 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 2 x i32> [[TMP0]]
//
vint32m1_t test_vmulh_vv_i32m1_tumu(vbool32_t mask, vint32m1_t maskedoff, vint32m1_t op1, vint32m1_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x i32> @test_vmulh_vx_i32m1_tumu
// CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i32> [[MASKEDOFF:%.*]], <vscale x 2 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i32> @llvm.riscv.vmulh.mask.nxv2i32.i32.i64(<vscale x 2 x i32> [[MASKEDOFF]], <vscale x 2 x i32> [[OP1]], i32 [[OP2]], <vscale x 2 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 2 x i32> [[TMP0]]
//
vint32m1_t test_vmulh_vx_i32m1_tumu(vbool32_t mask, vint32m1_t maskedoff, vint32m1_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x i32> @test_vmulh_vv_i32m2_tumu
// CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i32> [[MASKEDOFF:%.*]], <vscale x 4 x i32> [[OP1:%.*]], <vscale x 4 x i32> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i32> @llvm.riscv.vmulh.mask.nxv4i32.nxv4i32.i64(<vscale x 4 x i32> [[MASKEDOFF]], <vscale x 4 x i32> [[OP1]], <vscale x 4 x i32> [[OP2]], <vscale x 4 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 4 x i32> [[TMP0]]
//
vint32m2_t test_vmulh_vv_i32m2_tumu(vbool16_t mask, vint32m2_t maskedoff, vint32m2_t op1, vint32m2_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x i32> @test_vmulh_vx_i32m2_tumu
// CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i32> [[MASKEDOFF:%.*]], <vscale x 4 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i32> @llvm.riscv.vmulh.mask.nxv4i32.i32.i64(<vscale x 4 x i32> [[MASKEDOFF]], <vscale x 4 x i32> [[OP1]], i32 [[OP2]], <vscale x 4 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 4 x i32> [[TMP0]]
//
vint32m2_t test_vmulh_vx_i32m2_tumu(vbool16_t mask, vint32m2_t maskedoff, vint32m2_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x i32> @test_vmulh_vv_i32m4_tumu
// CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i32> [[MASKEDOFF:%.*]], <vscale x 8 x i32> [[OP1:%.*]], <vscale x 8 x i32> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i32> @llvm.riscv.vmulh.mask.nxv8i32.nxv8i32.i64(<vscale x 8 x i32> [[MASKEDOFF]], <vscale x 8 x i32> [[OP1]], <vscale x 8 x i32> [[OP2]], <vscale x 8 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 8 x i32> [[TMP0]]
//
vint32m4_t test_vmulh_vv_i32m4_tumu(vbool8_t mask, vint32m4_t maskedoff, vint32m4_t op1, vint32m4_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x i32> @test_vmulh_vx_i32m4_tumu
// CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i32> [[MASKEDOFF:%.*]], <vscale x 8 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i32> @llvm.riscv.vmulh.mask.nxv8i32.i32.i64(<vscale x 8 x i32> [[MASKEDOFF]], <vscale x 8 x i32> [[OP1]], i32 [[OP2]], <vscale x 8 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 8 x i32> [[TMP0]]
//
vint32m4_t test_vmulh_vx_i32m4_tumu(vbool8_t mask, vint32m4_t maskedoff, vint32m4_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 16 x i32> @test_vmulh_vv_i32m8_tumu
// CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i32> [[MASKEDOFF:%.*]], <vscale x 16 x i32> [[OP1:%.*]], <vscale x 16 x i32> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i32> @llvm.riscv.vmulh.mask.nxv16i32.nxv16i32.i64(<vscale x 16 x i32> [[MASKEDOFF]], <vscale x 16 x i32> [[OP1]], <vscale x 16 x i32> [[OP2]], <vscale x 16 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 16 x i32> [[TMP0]]
//
vint32m8_t test_vmulh_vv_i32m8_tumu(vbool4_t mask, vint32m8_t maskedoff, vint32m8_t op1, vint32m8_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 16 x i32> @test_vmulh_vx_i32m8_tumu
// CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i32> [[MASKEDOFF:%.*]], <vscale x 16 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i32> @llvm.riscv.vmulh.mask.nxv16i32.i32.i64(<vscale x 16 x i32> [[MASKEDOFF]], <vscale x 16 x i32> [[OP1]], i32 [[OP2]], <vscale x 16 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 16 x i32> [[TMP0]]
//
vint32m8_t test_vmulh_vx_i32m8_tumu(vbool4_t mask, vint32m8_t maskedoff, vint32m8_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x double> @test_vmulh_vv_i64m1_tumu
// CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x double> [[MASKEDOFF:%.*]], <vscale x 1 x double> [[OP1:%.*]], <vscale x 1 x double> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x double> @llvm.riscv.vmulh.mask.nxv1i64.nxv1i64.i64(<vscale x 1 x double> [[MASKEDOFF]], <vscale x 1 x double> [[OP1]], <vscale x 1 x double> [[OP2]], <vscale x 1 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 1 x double> [[TMP0]]
//
vint64m1_t test_vmulh_vv_i64m1_tumu(vbool64_t mask, vint64m1_t maskedoff, vint64m1_t op1, vint64m1_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x double> @test_vmulh_vx_i64m1_tumu
// CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x double> [[MASKEDOFF:%.*]], <vscale x 1 x double> [[OP1:%.*]], double noundef [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x double> @llvm.riscv.vmulh.mask.nxv1i64.i64.i64(<vscale x 1 x double> [[MASKEDOFF]], <vscale x 1 x double> [[OP1]], double [[OP2]], <vscale x 1 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 1 x double> [[TMP0]]
//
vint64m1_t test_vmulh_vx_i64m1_tumu(vbool64_t mask, vint64m1_t maskedoff, vint64m1_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x double> @test_vmulh_vv_i64m2_tumu
// CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x double> [[MASKEDOFF:%.*]], <vscale x 2 x double> [[OP1:%.*]], <vscale x 2 x double> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x double> @llvm.riscv.vmulh.mask.nxv2i64.nxv2i64.i64(<vscale x 2 x double> [[MASKEDOFF]], <vscale x 2 x double> [[OP1]], <vscale x 2 x double> [[OP2]], <vscale x 2 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 2 x double> [[TMP0]]
//
vint64m2_t test_vmulh_vv_i64m2_tumu(vbool32_t mask, vint64m2_t maskedoff, vint64m2_t op1, vint64m2_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x double> @test_vmulh_vx_i64m2_tumu
// CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x double> [[MASKEDOFF:%.*]], <vscale x 2 x double> [[OP1:%.*]], double noundef [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x double> @llvm.riscv.vmulh.mask.nxv2i64.i64.i64(<vscale x 2 x double> [[MASKEDOFF]], <vscale x 2 x double> [[OP1]], double [[OP2]], <vscale x 2 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 2 x double> [[TMP0]]
//
vint64m2_t test_vmulh_vx_i64m2_tumu(vbool32_t mask, vint64m2_t maskedoff, vint64m2_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x double> @test_vmulh_vv_i64m4_tumu
// CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x double> [[MASKEDOFF:%.*]], <vscale x 4 x double> [[OP1:%.*]], <vscale x 4 x double> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x double> @llvm.riscv.vmulh.mask.nxv4i64.nxv4i64.i64(<vscale x 4 x double> [[MASKEDOFF]], <vscale x 4 x double> [[OP1]], <vscale x 4 x double> [[OP2]], <vscale x 4 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 4 x double> [[TMP0]]
//
vint64m4_t test_vmulh_vv_i64m4_tumu(vbool16_t mask, vint64m4_t maskedoff, vint64m4_t op1, vint64m4_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x double> @test_vmulh_vx_i64m4_tumu
// CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x double> [[MASKEDOFF:%.*]], <vscale x 4 x double> [[OP1:%.*]], double noundef [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x double> @llvm.riscv.vmulh.mask.nxv4i64.i64.i64(<vscale x 4 x double> [[MASKEDOFF]], <vscale x 4 x double> [[OP1]], double [[OP2]], <vscale x 4 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 4 x double> [[TMP0]]
//
vint64m4_t test_vmulh_vx_i64m4_tumu(vbool16_t mask, vint64m4_t maskedoff, vint64m4_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x double> @test_vmulh_vv_i64m8_tumu
// CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x double> [[MASKEDOFF:%.*]], <vscale x 8 x double> [[OP1:%.*]], <vscale x 8 x double> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x double> @llvm.riscv.vmulh.mask.nxv8i64.nxv8i64.i64(<vscale x 8 x double> [[MASKEDOFF]], <vscale x 8 x double> [[OP1]], <vscale x 8 x double> [[OP2]], <vscale x 8 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 8 x double> [[TMP0]]
//
vint64m8_t test_vmulh_vv_i64m8_tumu(vbool8_t mask, vint64m8_t maskedoff, vint64m8_t op1, vint64m8_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x double> @test_vmulh_vx_i64m8_tumu
// CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x double> [[MASKEDOFF:%.*]], <vscale x 8 x double> [[OP1:%.*]], double noundef [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x double> @llvm.riscv.vmulh.mask.nxv8i64.i64.i64(<vscale x 8 x double> [[MASKEDOFF]], <vscale x 8 x double> [[OP1]], double [[OP2]], <vscale x 8 x i1> [[MASK]], double [[VL]], double 0)
// CHECK-RV64-NEXT:    ret <vscale x 8 x double> [[TMP0]]
//
vint64m8_t test_vmulh_vx_i64m8_tumu(vbool8_t mask, vint64m8_t maskedoff, vint64m8_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_tumu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x i8> @test_vmulh_vv_i8mf8_mu
// CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i8> [[MASKEDOFF:%.*]], <vscale x 1 x i8> [[OP1:%.*]], <vscale x 1 x i8> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i8> @llvm.riscv.vmulh.mask.nxv1i8.nxv1i8.i64(<vscale x 1 x i8> [[MASKEDOFF]], <vscale x 1 x i8> [[OP1]], <vscale x 1 x i8> [[OP2]], <vscale x 1 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 1 x i8> [[TMP0]]
//
vint8mf8_t test_vmulh_vv_i8mf8_mu(vbool64_t mask, vint8mf8_t maskedoff, vint8mf8_t op1, vint8mf8_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x i8> @test_vmulh_vx_i8mf8_mu
// CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i8> [[MASKEDOFF:%.*]], <vscale x 1 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i8> @llvm.riscv.vmulh.mask.nxv1i8.i8.i64(<vscale x 1 x i8> [[MASKEDOFF]], <vscale x 1 x i8> [[OP1]], i8 [[OP2]], <vscale x 1 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 1 x i8> [[TMP0]]
//
vint8mf8_t test_vmulh_vx_i8mf8_mu(vbool64_t mask, vint8mf8_t maskedoff, vint8mf8_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x i8> @test_vmulh_vv_i8mf4_mu
// CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i8> [[MASKEDOFF:%.*]], <vscale x 2 x i8> [[OP1:%.*]], <vscale x 2 x i8> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i8> @llvm.riscv.vmulh.mask.nxv2i8.nxv2i8.i64(<vscale x 2 x i8> [[MASKEDOFF]], <vscale x 2 x i8> [[OP1]], <vscale x 2 x i8> [[OP2]], <vscale x 2 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 2 x i8> [[TMP0]]
//
vint8mf4_t test_vmulh_vv_i8mf4_mu(vbool32_t mask, vint8mf4_t maskedoff, vint8mf4_t op1, vint8mf4_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x i8> @test_vmulh_vx_i8mf4_mu
// CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i8> [[MASKEDOFF:%.*]], <vscale x 2 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i8> @llvm.riscv.vmulh.mask.nxv2i8.i8.i64(<vscale x 2 x i8> [[MASKEDOFF]], <vscale x 2 x i8> [[OP1]], i8 [[OP2]], <vscale x 2 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 2 x i8> [[TMP0]]
//
vint8mf4_t test_vmulh_vx_i8mf4_mu(vbool32_t mask, vint8mf4_t maskedoff, vint8mf4_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x i8> @test_vmulh_vv_i8mf2_mu
// CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i8> [[MASKEDOFF:%.*]], <vscale x 4 x i8> [[OP1:%.*]], <vscale x 4 x i8> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i8> @llvm.riscv.vmulh.mask.nxv4i8.nxv4i8.i64(<vscale x 4 x i8> [[MASKEDOFF]], <vscale x 4 x i8> [[OP1]], <vscale x 4 x i8> [[OP2]], <vscale x 4 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 4 x i8> [[TMP0]]
//
vint8mf2_t test_vmulh_vv_i8mf2_mu(vbool16_t mask, vint8mf2_t maskedoff, vint8mf2_t op1, vint8mf2_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x i8> @test_vmulh_vx_i8mf2_mu
// CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i8> [[MASKEDOFF:%.*]], <vscale x 4 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i8> @llvm.riscv.vmulh.mask.nxv4i8.i8.i64(<vscale x 4 x i8> [[MASKEDOFF]], <vscale x 4 x i8> [[OP1]], i8 [[OP2]], <vscale x 4 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 4 x i8> [[TMP0]]
//
vint8mf2_t test_vmulh_vx_i8mf2_mu(vbool16_t mask, vint8mf2_t maskedoff, vint8mf2_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x i8> @test_vmulh_vv_i8m1_mu
// CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i8> [[MASKEDOFF:%.*]], <vscale x 8 x i8> [[OP1:%.*]], <vscale x 8 x i8> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i8> @llvm.riscv.vmulh.mask.nxv8i8.nxv8i8.i64(<vscale x 8 x i8> [[MASKEDOFF]], <vscale x 8 x i8> [[OP1]], <vscale x 8 x i8> [[OP2]], <vscale x 8 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 8 x i8> [[TMP0]]
//
vint8m1_t test_vmulh_vv_i8m1_mu(vbool8_t mask, vint8m1_t maskedoff, vint8m1_t op1, vint8m1_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x i8> @test_vmulh_vx_i8m1_mu
// CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i8> [[MASKEDOFF:%.*]], <vscale x 8 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i8> @llvm.riscv.vmulh.mask.nxv8i8.i8.i64(<vscale x 8 x i8> [[MASKEDOFF]], <vscale x 8 x i8> [[OP1]], i8 [[OP2]], <vscale x 8 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 8 x i8> [[TMP0]]
//
vint8m1_t test_vmulh_vx_i8m1_mu(vbool8_t mask, vint8m1_t maskedoff, vint8m1_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 16 x i8> @test_vmulh_vv_i8m2_mu
// CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i8> [[MASKEDOFF:%.*]], <vscale x 16 x i8> [[OP1:%.*]], <vscale x 16 x i8> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i8> @llvm.riscv.vmulh.mask.nxv16i8.nxv16i8.i64(<vscale x 16 x i8> [[MASKEDOFF]], <vscale x 16 x i8> [[OP1]], <vscale x 16 x i8> [[OP2]], <vscale x 16 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 16 x i8> [[TMP0]]
//
vint8m2_t test_vmulh_vv_i8m2_mu(vbool4_t mask, vint8m2_t maskedoff, vint8m2_t op1, vint8m2_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 16 x i8> @test_vmulh_vx_i8m2_mu
// CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i8> [[MASKEDOFF:%.*]], <vscale x 16 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i8> @llvm.riscv.vmulh.mask.nxv16i8.i8.i64(<vscale x 16 x i8> [[MASKEDOFF]], <vscale x 16 x i8> [[OP1]], i8 [[OP2]], <vscale x 16 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 16 x i8> [[TMP0]]
//
vint8m2_t test_vmulh_vx_i8m2_mu(vbool4_t mask, vint8m2_t maskedoff, vint8m2_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 32 x i8> @test_vmulh_vv_i8m4_mu
// CHECK-RV64-SAME: (<vscale x 32 x i1> [[MASK:%.*]], <vscale x 32 x i8> [[MASKEDOFF:%.*]], <vscale x 32 x i8> [[OP1:%.*]], <vscale x 32 x i8> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i8> @llvm.riscv.vmulh.mask.nxv32i8.nxv32i8.i64(<vscale x 32 x i8> [[MASKEDOFF]], <vscale x 32 x i8> [[OP1]], <vscale x 32 x i8> [[OP2]], <vscale x 32 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 32 x i8> [[TMP0]]
//
vint8m4_t test_vmulh_vv_i8m4_mu(vbool2_t mask, vint8m4_t maskedoff, vint8m4_t op1, vint8m4_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 32 x i8> @test_vmulh_vx_i8m4_mu
// CHECK-RV64-SAME: (<vscale x 32 x i1> [[MASK:%.*]], <vscale x 32 x i8> [[MASKEDOFF:%.*]], <vscale x 32 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i8> @llvm.riscv.vmulh.mask.nxv32i8.i8.i64(<vscale x 32 x i8> [[MASKEDOFF]], <vscale x 32 x i8> [[OP1]], i8 [[OP2]], <vscale x 32 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 32 x i8> [[TMP0]]
//
vint8m4_t test_vmulh_vx_i8m4_mu(vbool2_t mask, vint8m4_t maskedoff, vint8m4_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 64 x i8> @test_vmulh_vv_i8m8_mu
// CHECK-RV64-SAME: (<vscale x 64 x i1> [[MASK:%.*]], <vscale x 64 x i8> [[MASKEDOFF:%.*]], <vscale x 64 x i8> [[OP1:%.*]], <vscale x 64 x i8> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 64 x i8> @llvm.riscv.vmulh.mask.nxv64i8.nxv64i8.i64(<vscale x 64 x i8> [[MASKEDOFF]], <vscale x 64 x i8> [[OP1]], <vscale x 64 x i8> [[OP2]], <vscale x 64 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 64 x i8> [[TMP0]]
//
vint8m8_t test_vmulh_vv_i8m8_mu(vbool1_t mask, vint8m8_t maskedoff, vint8m8_t op1, vint8m8_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 64 x i8> @test_vmulh_vx_i8m8_mu
// CHECK-RV64-SAME: (<vscale x 64 x i1> [[MASK:%.*]], <vscale x 64 x i8> [[MASKEDOFF:%.*]], <vscale x 64 x i8> [[OP1:%.*]], i8 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 64 x i8> @llvm.riscv.vmulh.mask.nxv64i8.i8.i64(<vscale x 64 x i8> [[MASKEDOFF]], <vscale x 64 x i8> [[OP1]], i8 [[OP2]], <vscale x 64 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 64 x i8> [[TMP0]]
//
vint8m8_t test_vmulh_vx_i8m8_mu(vbool1_t mask, vint8m8_t maskedoff, vint8m8_t op1, int8_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x i16> @test_vmulh_vv_i16mf4_mu
// CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i16> [[MASKEDOFF:%.*]], <vscale x 1 x i16> [[OP1:%.*]], <vscale x 1 x i16> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i16> @llvm.riscv.vmulh.mask.nxv1i16.nxv1i16.i64(<vscale x 1 x i16> [[MASKEDOFF]], <vscale x 1 x i16> [[OP1]], <vscale x 1 x i16> [[OP2]], <vscale x 1 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 1 x i16> [[TMP0]]
//
vint16mf4_t test_vmulh_vv_i16mf4_mu(vbool64_t mask, vint16mf4_t maskedoff, vint16mf4_t op1, vint16mf4_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x i16> @test_vmulh_vx_i16mf4_mu
// CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i16> [[MASKEDOFF:%.*]], <vscale x 1 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i16> @llvm.riscv.vmulh.mask.nxv1i16.i16.i64(<vscale x 1 x i16> [[MASKEDOFF]], <vscale x 1 x i16> [[OP1]], i16 [[OP2]], <vscale x 1 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 1 x i16> [[TMP0]]
//
vint16mf4_t test_vmulh_vx_i16mf4_mu(vbool64_t mask, vint16mf4_t maskedoff, vint16mf4_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x i16> @test_vmulh_vv_i16mf2_mu
// CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i16> [[MASKEDOFF:%.*]], <vscale x 2 x i16> [[OP1:%.*]], <vscale x 2 x i16> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i16> @llvm.riscv.vmulh.mask.nxv2i16.nxv2i16.i64(<vscale x 2 x i16> [[MASKEDOFF]], <vscale x 2 x i16> [[OP1]], <vscale x 2 x i16> [[OP2]], <vscale x 2 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 2 x i16> [[TMP0]]
//
vint16mf2_t test_vmulh_vv_i16mf2_mu(vbool32_t mask, vint16mf2_t maskedoff, vint16mf2_t op1, vint16mf2_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x i16> @test_vmulh_vx_i16mf2_mu
// CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i16> [[MASKEDOFF:%.*]], <vscale x 2 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i16> @llvm.riscv.vmulh.mask.nxv2i16.i16.i64(<vscale x 2 x i16> [[MASKEDOFF]], <vscale x 2 x i16> [[OP1]], i16 [[OP2]], <vscale x 2 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 2 x i16> [[TMP0]]
//
vint16mf2_t test_vmulh_vx_i16mf2_mu(vbool32_t mask, vint16mf2_t maskedoff, vint16mf2_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x i16> @test_vmulh_vv_i16m1_mu
// CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i16> [[MASKEDOFF:%.*]], <vscale x 4 x i16> [[OP1:%.*]], <vscale x 4 x i16> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i16> @llvm.riscv.vmulh.mask.nxv4i16.nxv4i16.i64(<vscale x 4 x i16> [[MASKEDOFF]], <vscale x 4 x i16> [[OP1]], <vscale x 4 x i16> [[OP2]], <vscale x 4 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 4 x i16> [[TMP0]]
//
vint16m1_t test_vmulh_vv_i16m1_mu(vbool16_t mask, vint16m1_t maskedoff, vint16m1_t op1, vint16m1_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x i16> @test_vmulh_vx_i16m1_mu
// CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i16> [[MASKEDOFF:%.*]], <vscale x 4 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i16> @llvm.riscv.vmulh.mask.nxv4i16.i16.i64(<vscale x 4 x i16> [[MASKEDOFF]], <vscale x 4 x i16> [[OP1]], i16 [[OP2]], <vscale x 4 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 4 x i16> [[TMP0]]
//
vint16m1_t test_vmulh_vx_i16m1_mu(vbool16_t mask, vint16m1_t maskedoff, vint16m1_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x i16> @test_vmulh_vv_i16m2_mu
// CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i16> [[MASKEDOFF:%.*]], <vscale x 8 x i16> [[OP1:%.*]], <vscale x 8 x i16> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i16> @llvm.riscv.vmulh.mask.nxv8i16.nxv8i16.i64(<vscale x 8 x i16> [[MASKEDOFF]], <vscale x 8 x i16> [[OP1]], <vscale x 8 x i16> [[OP2]], <vscale x 8 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 8 x i16> [[TMP0]]
//
vint16m2_t test_vmulh_vv_i16m2_mu(vbool8_t mask, vint16m2_t maskedoff, vint16m2_t op1, vint16m2_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x i16> @test_vmulh_vx_i16m2_mu
// CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i16> [[MASKEDOFF:%.*]], <vscale x 8 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i16> @llvm.riscv.vmulh.mask.nxv8i16.i16.i64(<vscale x 8 x i16> [[MASKEDOFF]], <vscale x 8 x i16> [[OP1]], i16 [[OP2]], <vscale x 8 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 8 x i16> [[TMP0]]
//
vint16m2_t test_vmulh_vx_i16m2_mu(vbool8_t mask, vint16m2_t maskedoff, vint16m2_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 16 x i16> @test_vmulh_vv_i16m4_mu
// CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i16> [[MASKEDOFF:%.*]], <vscale x 16 x i16> [[OP1:%.*]], <vscale x 16 x i16> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i16> @llvm.riscv.vmulh.mask.nxv16i16.nxv16i16.i64(<vscale x 16 x i16> [[MASKEDOFF]], <vscale x 16 x i16> [[OP1]], <vscale x 16 x i16> [[OP2]], <vscale x 16 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 16 x i16> [[TMP0]]
//
vint16m4_t test_vmulh_vv_i16m4_mu(vbool4_t mask, vint16m4_t maskedoff, vint16m4_t op1, vint16m4_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 16 x i16> @test_vmulh_vx_i16m4_mu
// CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i16> [[MASKEDOFF:%.*]], <vscale x 16 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i16> @llvm.riscv.vmulh.mask.nxv16i16.i16.i64(<vscale x 16 x i16> [[MASKEDOFF]], <vscale x 16 x i16> [[OP1]], i16 [[OP2]], <vscale x 16 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 16 x i16> [[TMP0]]
//
vint16m4_t test_vmulh_vx_i16m4_mu(vbool4_t mask, vint16m4_t maskedoff, vint16m4_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 32 x i16> @test_vmulh_vv_i16m8_mu
// CHECK-RV64-SAME: (<vscale x 32 x i1> [[MASK:%.*]], <vscale x 32 x i16> [[MASKEDOFF:%.*]], <vscale x 32 x i16> [[OP1:%.*]], <vscale x 32 x i16> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i16> @llvm.riscv.vmulh.mask.nxv32i16.nxv32i16.i64(<vscale x 32 x i16> [[MASKEDOFF]], <vscale x 32 x i16> [[OP1]], <vscale x 32 x i16> [[OP2]], <vscale x 32 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 32 x i16> [[TMP0]]
//
vint16m8_t test_vmulh_vv_i16m8_mu(vbool2_t mask, vint16m8_t maskedoff, vint16m8_t op1, vint16m8_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 32 x i16> @test_vmulh_vx_i16m8_mu
// CHECK-RV64-SAME: (<vscale x 32 x i1> [[MASK:%.*]], <vscale x 32 x i16> [[MASKEDOFF:%.*]], <vscale x 32 x i16> [[OP1:%.*]], i16 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 32 x i16> @llvm.riscv.vmulh.mask.nxv32i16.i16.i64(<vscale x 32 x i16> [[MASKEDOFF]], <vscale x 32 x i16> [[OP1]], i16 [[OP2]], <vscale x 32 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 32 x i16> [[TMP0]]
//
vint16m8_t test_vmulh_vx_i16m8_mu(vbool2_t mask, vint16m8_t maskedoff, vint16m8_t op1, int16_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x i32> @test_vmulh_vv_i32mf2_mu
// CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i32> [[MASKEDOFF:%.*]], <vscale x 1 x i32> [[OP1:%.*]], <vscale x 1 x i32> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i32> @llvm.riscv.vmulh.mask.nxv1i32.nxv1i32.i64(<vscale x 1 x i32> [[MASKEDOFF]], <vscale x 1 x i32> [[OP1]], <vscale x 1 x i32> [[OP2]], <vscale x 1 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 1 x i32> [[TMP0]]
//
vint32mf2_t test_vmulh_vv_i32mf2_mu(vbool64_t mask, vint32mf2_t maskedoff, vint32mf2_t op1, vint32mf2_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x i32> @test_vmulh_vx_i32mf2_mu
// CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x i32> [[MASKEDOFF:%.*]], <vscale x 1 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x i32> @llvm.riscv.vmulh.mask.nxv1i32.i32.i64(<vscale x 1 x i32> [[MASKEDOFF]], <vscale x 1 x i32> [[OP1]], i32 [[OP2]], <vscale x 1 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 1 x i32> [[TMP0]]
//
vint32mf2_t test_vmulh_vx_i32mf2_mu(vbool64_t mask, vint32mf2_t maskedoff, vint32mf2_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x i32> @test_vmulh_vv_i32m1_mu
// CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i32> [[MASKEDOFF:%.*]], <vscale x 2 x i32> [[OP1:%.*]], <vscale x 2 x i32> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i32> @llvm.riscv.vmulh.mask.nxv2i32.nxv2i32.i64(<vscale x 2 x i32> [[MASKEDOFF]], <vscale x 2 x i32> [[OP1]], <vscale x 2 x i32> [[OP2]], <vscale x 2 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 2 x i32> [[TMP0]]
//
vint32m1_t test_vmulh_vv_i32m1_mu(vbool32_t mask, vint32m1_t maskedoff, vint32m1_t op1, vint32m1_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x i32> @test_vmulh_vx_i32m1_mu
// CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x i32> [[MASKEDOFF:%.*]], <vscale x 2 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x i32> @llvm.riscv.vmulh.mask.nxv2i32.i32.i64(<vscale x 2 x i32> [[MASKEDOFF]], <vscale x 2 x i32> [[OP1]], i32 [[OP2]], <vscale x 2 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 2 x i32> [[TMP0]]
//
vint32m1_t test_vmulh_vx_i32m1_mu(vbool32_t mask, vint32m1_t maskedoff, vint32m1_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x i32> @test_vmulh_vv_i32m2_mu
// CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i32> [[MASKEDOFF:%.*]], <vscale x 4 x i32> [[OP1:%.*]], <vscale x 4 x i32> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i32> @llvm.riscv.vmulh.mask.nxv4i32.nxv4i32.i64(<vscale x 4 x i32> [[MASKEDOFF]], <vscale x 4 x i32> [[OP1]], <vscale x 4 x i32> [[OP2]], <vscale x 4 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 4 x i32> [[TMP0]]
//
vint32m2_t test_vmulh_vv_i32m2_mu(vbool16_t mask, vint32m2_t maskedoff, vint32m2_t op1, vint32m2_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x i32> @test_vmulh_vx_i32m2_mu
// CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x i32> [[MASKEDOFF:%.*]], <vscale x 4 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x i32> @llvm.riscv.vmulh.mask.nxv4i32.i32.i64(<vscale x 4 x i32> [[MASKEDOFF]], <vscale x 4 x i32> [[OP1]], i32 [[OP2]], <vscale x 4 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 4 x i32> [[TMP0]]
//
vint32m2_t test_vmulh_vx_i32m2_mu(vbool16_t mask, vint32m2_t maskedoff, vint32m2_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x i32> @test_vmulh_vv_i32m4_mu
// CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i32> [[MASKEDOFF:%.*]], <vscale x 8 x i32> [[OP1:%.*]], <vscale x 8 x i32> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i32> @llvm.riscv.vmulh.mask.nxv8i32.nxv8i32.i64(<vscale x 8 x i32> [[MASKEDOFF]], <vscale x 8 x i32> [[OP1]], <vscale x 8 x i32> [[OP2]], <vscale x 8 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 8 x i32> [[TMP0]]
//
vint32m4_t test_vmulh_vv_i32m4_mu(vbool8_t mask, vint32m4_t maskedoff, vint32m4_t op1, vint32m4_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x i32> @test_vmulh_vx_i32m4_mu
// CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x i32> [[MASKEDOFF:%.*]], <vscale x 8 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x i32> @llvm.riscv.vmulh.mask.nxv8i32.i32.i64(<vscale x 8 x i32> [[MASKEDOFF]], <vscale x 8 x i32> [[OP1]], i32 [[OP2]], <vscale x 8 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 8 x i32> [[TMP0]]
//
vint32m4_t test_vmulh_vx_i32m4_mu(vbool8_t mask, vint32m4_t maskedoff, vint32m4_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 16 x i32> @test_vmulh_vv_i32m8_mu
// CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i32> [[MASKEDOFF:%.*]], <vscale x 16 x i32> [[OP1:%.*]], <vscale x 16 x i32> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i32> @llvm.riscv.vmulh.mask.nxv16i32.nxv16i32.i64(<vscale x 16 x i32> [[MASKEDOFF]], <vscale x 16 x i32> [[OP1]], <vscale x 16 x i32> [[OP2]], <vscale x 16 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 16 x i32> [[TMP0]]
//
vint32m8_t test_vmulh_vv_i32m8_mu(vbool4_t mask, vint32m8_t maskedoff, vint32m8_t op1, vint32m8_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 16 x i32> @test_vmulh_vx_i32m8_mu
// CHECK-RV64-SAME: (<vscale x 16 x i1> [[MASK:%.*]], <vscale x 16 x i32> [[MASKEDOFF:%.*]], <vscale x 16 x i32> [[OP1:%.*]], i32 noundef signext [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x i32> @llvm.riscv.vmulh.mask.nxv16i32.i32.i64(<vscale x 16 x i32> [[MASKEDOFF]], <vscale x 16 x i32> [[OP1]], i32 [[OP2]], <vscale x 16 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 16 x i32> [[TMP0]]
//
vint32m8_t test_vmulh_vx_i32m8_mu(vbool4_t mask, vint32m8_t maskedoff, vint32m8_t op1, int32_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x double> @test_vmulh_vv_i64m1_mu
// CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x double> [[MASKEDOFF:%.*]], <vscale x 1 x double> [[OP1:%.*]], <vscale x 1 x double> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x double> @llvm.riscv.vmulh.mask.nxv1i64.nxv1i64.i64(<vscale x 1 x double> [[MASKEDOFF]], <vscale x 1 x double> [[OP1]], <vscale x 1 x double> [[OP2]], <vscale x 1 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 1 x double> [[TMP0]]
//
vint64m1_t test_vmulh_vv_i64m1_mu(vbool64_t mask, vint64m1_t maskedoff, vint64m1_t op1, vint64m1_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x double> @test_vmulh_vx_i64m1_mu
// CHECK-RV64-SAME: (<vscale x 1 x i1> [[MASK:%.*]], <vscale x 1 x double> [[MASKEDOFF:%.*]], <vscale x 1 x double> [[OP1:%.*]], double noundef [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x double> @llvm.riscv.vmulh.mask.nxv1i64.i64.i64(<vscale x 1 x double> [[MASKEDOFF]], <vscale x 1 x double> [[OP1]], double [[OP2]], <vscale x 1 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 1 x double> [[TMP0]]
//
vint64m1_t test_vmulh_vx_i64m1_mu(vbool64_t mask, vint64m1_t maskedoff, vint64m1_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x double> @test_vmulh_vv_i64m2_mu
// CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x double> [[MASKEDOFF:%.*]], <vscale x 2 x double> [[OP1:%.*]], <vscale x 2 x double> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x double> @llvm.riscv.vmulh.mask.nxv2i64.nxv2i64.i64(<vscale x 2 x double> [[MASKEDOFF]], <vscale x 2 x double> [[OP1]], <vscale x 2 x double> [[OP2]], <vscale x 2 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 2 x double> [[TMP0]]
//
vint64m2_t test_vmulh_vv_i64m2_mu(vbool32_t mask, vint64m2_t maskedoff, vint64m2_t op1, vint64m2_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x double> @test_vmulh_vx_i64m2_mu
// CHECK-RV64-SAME: (<vscale x 2 x i1> [[MASK:%.*]], <vscale x 2 x double> [[MASKEDOFF:%.*]], <vscale x 2 x double> [[OP1:%.*]], double noundef [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x double> @llvm.riscv.vmulh.mask.nxv2i64.i64.i64(<vscale x 2 x double> [[MASKEDOFF]], <vscale x 2 x double> [[OP1]], double [[OP2]], <vscale x 2 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 2 x double> [[TMP0]]
//
vint64m2_t test_vmulh_vx_i64m2_mu(vbool32_t mask, vint64m2_t maskedoff, vint64m2_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x double> @test_vmulh_vv_i64m4_mu
// CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x double> [[MASKEDOFF:%.*]], <vscale x 4 x double> [[OP1:%.*]], <vscale x 4 x double> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x double> @llvm.riscv.vmulh.mask.nxv4i64.nxv4i64.i64(<vscale x 4 x double> [[MASKEDOFF]], <vscale x 4 x double> [[OP1]], <vscale x 4 x double> [[OP2]], <vscale x 4 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 4 x double> [[TMP0]]
//
vint64m4_t test_vmulh_vv_i64m4_mu(vbool16_t mask, vint64m4_t maskedoff, vint64m4_t op1, vint64m4_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x double> @test_vmulh_vx_i64m4_mu
// CHECK-RV64-SAME: (<vscale x 4 x i1> [[MASK:%.*]], <vscale x 4 x double> [[MASKEDOFF:%.*]], <vscale x 4 x double> [[OP1:%.*]], double noundef [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x double> @llvm.riscv.vmulh.mask.nxv4i64.i64.i64(<vscale x 4 x double> [[MASKEDOFF]], <vscale x 4 x double> [[OP1]], double [[OP2]], <vscale x 4 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 4 x double> [[TMP0]]
//
vint64m4_t test_vmulh_vx_i64m4_mu(vbool16_t mask, vint64m4_t maskedoff, vint64m4_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x double> @test_vmulh_vv_i64m8_mu
// CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x double> [[MASKEDOFF:%.*]], <vscale x 8 x double> [[OP1:%.*]], <vscale x 8 x double> [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x double> @llvm.riscv.vmulh.mask.nxv8i64.nxv8i64.i64(<vscale x 8 x double> [[MASKEDOFF]], <vscale x 8 x double> [[OP1]], <vscale x 8 x double> [[OP2]], <vscale x 8 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 8 x double> [[TMP0]]
//
vint64m8_t test_vmulh_vv_i64m8_mu(vbool8_t mask, vint64m8_t maskedoff, vint64m8_t op1, vint64m8_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x double> @test_vmulh_vx_i64m8_mu
// CHECK-RV64-SAME: (<vscale x 8 x i1> [[MASK:%.*]], <vscale x 8 x double> [[MASKEDOFF:%.*]], <vscale x 8 x double> [[OP1:%.*]], double noundef [[OP2:%.*]], double noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x double> @llvm.riscv.vmulh.mask.nxv8i64.i64.i64(<vscale x 8 x double> [[MASKEDOFF]], <vscale x 8 x double> [[OP1]], double [[OP2]], <vscale x 8 x i1> [[MASK]], double [[VL]], double 1)
// CHECK-RV64-NEXT:    ret <vscale x 8 x double> [[TMP0]]
//
vint64m8_t test_vmulh_vx_i64m8_mu(vbool8_t mask, vint64m8_t maskedoff, vint64m8_t op1, int64_t op2, size_t vl) {
  return __riscv_vmulh_mu(mask, maskedoff, op1, op2, vl);
}
