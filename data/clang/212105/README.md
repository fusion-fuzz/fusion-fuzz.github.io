*Fusion-Fuzz Bug Report*

**ID:** `38538121` &nbsp;·&nbsp; **Signature:** `Assertion: getCondition()->getType()->isIntegerTy(1) && "May only branch on boolean predicates!"` &nbsp;·&nbsp; **RC:** `134`

The following code:

```c
// RUN: %clang_cc1 -triple x86_64-apple-darwin %s -emit-llvm -disable-llvm-passes -o - | FileCheck %s

typedef _Float16 half;

typedef half half2 __attribute__((ext_vector_type(2)));
typedef float float2 __attribute__((ext_vector_type(2)));
typedef float float4 __attribute__((ext_vector_type(4)));
typedef short int si8 __attribute__((ext_vector_type(8)));
typedef int int4 __attribute__((ext_vector_type(4)));
typedef unsigned int u4 __attribute__((ext_vector_type(4)));
typedef double double2 __attribute__((ext_vector_type(2)));
typedef double double3 __attribute__((ext_vector_type(3)));

__attribute__((address_space(1))) int int_as_one;
typedef int bar;
bar b;

struct StructWithBitfield {
  int i : 5;
  short s : 3;
  char c: 2;
  long long int lli : 3;
};

void test_builtin_elementwise_abs(float f1, float f2, double d1, double d2,
                                  float4 vf1, float4 vf2, si8 vi1, si8 vi2,
                                  long long int i1, long long int i2, short si,
                                  _BitInt(31) bi1, _BitInt(31) bi2, int i,
                                  char ci) {
  // CHECK-LABEL: define void @test_builtin_elementwise_abs(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT:  call float @llvm.fabs.f32(float [[F1]])
  f2 = __builtin_elementwise_abs(f1);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: call double @llvm.fabs.f64(double [[D1]])
  d2 = __builtin_elementwise_abs(d1);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.fabs.v4f32(<4 x float> [[VF1]])
  vf2 = __builtin_elementwise_abs(vf1);

  // CHECK:      [[I1:%.+]] = load i64, ptr %i1.addr, align 8
  // CHECK-NEXT: call i64 @llvm.abs.i64(i64 [[I1]], i1 false)
  i2 = __builtin_elementwise_abs(i1);

  // CHECK:      [[I1:%.+]] = load i64, ptr %i1.addr, align 8
  // CHECK:      [[S1:%.+]] = trunc i64 [[I1]] to i16
  // CHECK-NEXT: call i16 @llvm.abs.i16(i16 [[S1]], i1 false)
  i1 = __builtin_elementwise_abs((short)i1);

  // CHECK:      [[VI1:%.+]] = load <8 x i16>, ptr %vi1.addr, align 16
  // CHECK-NEXT: call <8 x i16> @llvm.abs.v8i16(<8 x i16> [[VI1]], i1 false)
  vi2 = __builtin_elementwise_abs(vi1);

  // CHECK:      [[CVI2:%.+]] = load <8 x i16>, ptr %cvi2, align 16
  // CHECK-NEXT: call <8 x i16> @llvm.abs.v8i16(<8 x i16> [[CVI2]], i1 false)
  const si8 cvi2 = vi2;
  vi2 = __builtin_elementwise_abs(cvi2);

  // CHECK:      [[BI1:%.+]] = load i32, ptr %bi1.addr, align 4
  // CHECK-NEXT: [[LOADEDV:%.+]] = trunc i32 [[BI1]] to i31
  // CHECK-NEXT: call i31 @llvm.abs.i31(i31 [[LOADEDV]], i1 false)
  bi2 = __builtin_elementwise_abs(bi1);

  // CHECK:      [[IA1:%.+]] = load i32, ptr addrspace(1) @int_as_one, align 4
  // CHECK-NEXT: call i32 @llvm.abs.i32(i32 [[IA1]], i1 false)
  b = __builtin_elementwise_abs(int_as_one);

  // CHECK:   store i32 %elt.abs11, ptr @b, align 4
  b = __builtin_elementwise_abs(-10);

  // CHECK:      [[SI:%.+]] = load i16, ptr %si.addr, align 2
  // CHECK-NEXT: [[RES:%.+]] = call i16 @llvm.abs.i16(i16 [[SI]], i1 false)
  si = __builtin_elementwise_abs(si);

  struct StructWithBitfield t;

  // CHECK:      [[BFLOAD:%.+]] = load i16, ptr %t, align 8
  // CHECK-NEXT: [[BFSHL:%.+]] = shl i16 [[BFLOAD]], 11
  // CHECK-NEXT: [[BFASHR:%.+]] = ashr i16 [[BFSHL]], 11
  // CHECK-NEXT: [[BFCAST:%.+]] = sext i16 [[BFASHR]] to i32
  // CHECK-NEXT: [[RES:%.+]] = call i32 @llvm.abs.i32(i32 [[BFCAST]], i1 false)
  i = __builtin_elementwise_abs(t.i);

  // CHECK:      [[BFLOAD:%.+]] = load i16, ptr %t, align 8
  // CHECK-NEXT: [[BFSHL:%.+]] = shl i16 [[BFLOAD]], 8
  // CHECK-NEXT: [[BFASHR:%.+]] = ashr i16 [[BFSHL]], 13
  // CHECK-NEXT: [[RES:%.+]] = call i16 @llvm.abs.i16(i16 [[BFASHR]], i1 false)
  si = __builtin_elementwise_abs(t.s);

  // CHECK:      [[BFLOAD:%.+]] = load i16, ptr %t, align 8
  // CHECK-NEXT: [[BFSHL:%.+]] = shl i16 [[BFLOAD]], 6
  // CHECK-NEXT: [[BFASHR:%.+]] = ashr i16 [[BFSHL]], 14
  // CHECK-NEXT: [[BFCAST:%.+]] = trunc i16 [[BFASHR]] to i8
  // CHECK-NEXT: [[RES:%.+]] = call i8 @llvm.abs.i8(i8 [[BFCAST]], i1 false)
  ci = __builtin_elementwise_abs(t.c);

  // CHECK:      [[BFLOAD:%.+]] = load i16, ptr %t, align 8
  // CHECK-NEXT: [[BFSHL:%.+]] = shl i16 [[BFLOAD]], 3
  // CHECK-NEXT: [[BFASHR:%.+]] = ashr i16 [[BFSHL]], 13
  // CHECK-NEXT: [[BFCAST:%.+]] = sext i16 [[BFASHR]] to i64
  // CHECK-NEXT: [[RES:%.+]] = call i64 @llvm.abs.i64(i64 [[BFCAST]], i1 false)
  i1 = __builtin_elementwise_abs(t.lli);
}

void test_builtin_elementwise_add_sat(float f1, float f2, double d1, double d2,
                                      float4 vf1, float4 vf2, long long int i1,
                                      long long int i2, si8 vi1, si8 vi2,
                                      unsigned u1, unsigned u2, u4 vu1, u4 vu2,
                                      _BitInt(31) bi1, _BitInt(31) bi2,
                                      unsigned _BitInt(55) bu1, unsigned _BitInt(55) bu2,
                                      char c1, char c2, unsigned char uc1,
                                      unsigned char uc2, short s1, short s2,
                                      unsigned short us1, unsigned short us2) {
  // CHECK:      [[I1:%.+]] = load i64, ptr %i1.addr, align 8
  // CHECK-NEXT: [[I2:%.+]] = load i64, ptr %i2.addr, align 8
  // CHECK-NEXT: call i64 @llvm.sadd.sat.i64(i64 [[I1]], i64 [[I2]])
  i1 = __builtin_elementwise_add_sat(i1, i2);

  // CHECK:      [[I1:%.+]] = load i64, ptr %i1.addr, align 8
  // CHECK-NEXT: call i64 @llvm.sadd.sat.i64(i64 [[I1]], i64 10)
  i1 = __builtin_elementwise_add_sat(i1, 10ll);

  // CHECK:      [[VI1:%.+]] = load <8 x i16>, ptr %vi1.addr, align 16
  // CHECK-NEXT: [[VI2:%.+]] = load <8 x i16>, ptr %vi2.addr, align 16
  // CHECK-NEXT: call <8 x i16> @llvm.sadd.sat.v8i16(<8 x i16> [[VI1]], <8 x i16> [[VI2]])
  vi1 = __builtin_elementwise_add_sat(vi1, vi2);

  // CHECK:      [[U1:%.+]] = load i32, ptr %u1.addr, align 4
  // CHECK-NEXT: [[U2:%.+]] = load i32, ptr %u2.addr, align 4
  // CHECK-NEXT: call i32 @llvm.uadd.sat.i32(i32 [[U1]], i32 [[U2]])
  u1 = __builtin_elementwise_add_sat(u1, u2);

  // CHECK:      [[VU1:%.+]] = load <4 x i32>, ptr %vu1.addr, align 16
  // CHECK-NEXT: [[VU2:%.+]] = load <4 x i32>, ptr %vu2.addr, align 16
  // CHECK-NEXT: call <4 x i32> @llvm.uadd.sat.v4i32(<4 x i32> [[VU1]], <4 x i32> [[VU2]])
  vu1 = __builtin_elementwise_add_sat(vu1, vu2);

  // CHECK:      [[BI1:%.+]] = load i32, ptr %bi1.addr, align 4
  // CHECK-NEXT: [[LOADEDV:%.+]] = trunc i32 [[BI1]] to i31
  // CHECK-NEXT: [[BI2:%.+]] = load i32, ptr %bi2.addr, align 4
  // CHECK-NEXT: [[LOADEDV1:%.+]] = trunc i32 [[BI2]] to i31
  // CHECK-NEXT: call i31 @llvm.sadd.sat.i31(i31 [[LOADEDV]], i31 [[LOADEDV1]])
  bi1 = __builtin_elementwise_add_sat(bi1, bi2);

  // CHECK:      [[BU1:%.+]] = load i64, ptr %bu1.addr, align 8
  // CHECK-NEXT: [[LOADEDV2:%.+]] = trunc i64 [[BU1]] to i55
  // CHECK-NEXT: [[BU2:%.+]] = load i64, ptr %bu2.addr, align 8
  // CHECK-NEXT: [[LOADEDV3:%.+]] = trunc i64 [[BU2]] to i55
  // CHECK-NEXT: call i55 @llvm.uadd.sat.i55(i55 [[LOADEDV2]], i55 [[LOADEDV3]])
  bu1 = __builtin_elementwise_add_sat(bu1, bu2);

  // CHECK:      [[IAS1:%.+]] = load i32, ptr addrspace(1) @int_as_one, align 4
  // CHECK-NEXT: [[B:%.+]] = load i32, ptr @b, align 4
  // CHECK-NEXT: call i32 @llvm.sadd.sat.i32(i32 [[IAS1]], i32 [[B]])
  int_as_one = __builtin_elementwise_add_sat(int_as_one, b);

  // CHECK: store i64 98, ptr %i1.addr, align 8
  i1 = __builtin_elementwise_add_sat(1, 'a');

  // CHECK:      [[C1:%.+]] = load i8, ptr %c1.addr, align 1
  // CHECK-NEXT: [[C2:%.+]] = load i8, ptr %c2.addr, align 1
  // CHECK-NEXT: call i8 @llvm.sadd.sat.i8(i8 [[C1]], i8 [[C2]])
  c1 = __builtin_elementwise_add_sat(c1, c2);

  // CHECK:      [[UC1:%.+]] = load i8, ptr %uc1.addr, align 1
  // CHECK-NEXT: [[UC2:%.+]] = load i8, ptr %uc2.addr, align 1
  // CHECK-NEXT: call i8 @llvm.uadd.sat.i8(i8 [[UC1]], i8 [[UC2]])
  uc1 = __builtin_elementwise_add_sat(uc1, uc2);

  // CHECK:      [[S1:%.+]] = load i16, ptr %s1.addr, align 2
  // CHECK-NEXT: [[S2:%.+]] = load i16, ptr %s2.addr, align 2
  // CHECK-NEXT: call i16 @llvm.sadd.sat.i16(i16 [[S1]], i16 [[S2]])
  s1 = __builtin_elementwise_add_sat(s1, s2);

  // CHECK:      [[S1:%.+]] = load i16, ptr %s1.addr, align 2
  // CHECK:      [[I1:%.+]] = sext i16 [[S1]] to i32
  // CHECK-NEXT: [[S2:%.+]] = load i16, ptr %s2.addr, align 2
  // CHECK:      [[I2:%.+]] = sext i16 [[S2]] to i32
  // CHECK-NEXT: call i32 @llvm.sadd.sat.i32(i32 [[I1]], i32 [[I2]])
  s1 = __builtin_elementwise_add_sat((int)s1, (int)s2);

  // CHECK:      [[US1:%.+]] = load i16, ptr %us1.addr, align 2
  // CHECK-NEXT: [[US2:%.+]] = load i16, ptr %us2.addr, align 2
  // CHECK-NEXT: call i16 @llvm.uadd.sat.i16(i16 [[US1]], i16 [[US2]])
  us1 = __builtin_elementwise_add_sat(us1, us2);
}

void test_builtin_elementwise_sub_sat(float f1, float f2, double d1, double d2,
                                      float4 vf1, float4 vf2, long long int i1,
                                      long long int i2, si8 vi1, si8 vi2,
                                      unsigned u1, unsigned u2, u4 vu1, u4 vu2,
                                      _BitInt(31) bi1, _BitInt(31) bi2,
                                      unsigned _BitInt(55) bu1, unsigned _BitInt(55) bu2,
                                      char c1, char c2, unsigned char uc1,
                                      unsigned char uc2, short s1, short s2,
                                      unsigned short us1, unsigned short us2) {
  // CHECK:      [[I1:%.+]] = load i64, ptr %i1.addr, align 8
  // CHECK-NEXT: [[I2:%.+]] = load i64, ptr %i2.addr, align 8
  // CHECK-NEXT: call i64 @llvm.ssub.sat.i64(i64 [[I1]], i64 [[I2]])
  i1 = __builtin_elementwise_sub_sat(i1, i2);

  // CHECK:      [[I1:%.+]] = load i64, ptr %i1.addr, align 8
  // CHECK-NEXT: call i64 @llvm.ssub.sat.i64(i64 [[I1]], i64 10)
  i1 = __builtin_elementwise_sub_sat(i1, 10ll);

  // CHECK:      [[VI1:%.+]] = load <8 x i16>, ptr %vi1.addr, align 16
  // CHECK-NEXT: [[VI2:%.+]] = load <8 x i16>, ptr %vi2.addr, align 16
  // CHECK-NEXT: call <8 x i16> @llvm.ssub.sat.v8i16(<8 x i16> [[VI1]], <8 x i16> [[VI2]])
  vi1 = __builtin_elementwise_sub_sat(vi1, vi2);

  // CHECK:      [[U1:%.+]] = load i32, ptr %u1.addr, align 4
  // CHECK-NEXT: [[U2:%.+]] = load i32, ptr %u2.addr, align 4
  // CHECK-NEXT: call i32 @llvm.usub.sat.i32(i32 [[U1]], i32 [[U2]])
  u1 = __builtin_elementwise_sub_sat(u1, u2);

  // CHECK:      [[VU1:%.+]] = load <4 x i32>, ptr %vu1.addr, align 16
  // CHECK-NEXT: [[VU2:%.+]] = load <4 x i32>, ptr %vu2.addr, align 16
  // CHECK-NEXT: call <4 x i32> @llvm.usub.sat.v4i32(<4 x i32> [[VU1]], <4 x i32> [[VU2]])
  vu1 = __builtin_elementwise_sub_sat(vu1, vu2);

  // CHECK:      [[BI1:%.+]] = load i32, ptr %bi1.addr, align 4
  // CHECK-NEXT: [[LOADEDV:%.+]] = trunc i32 [[BI1]] to i31
  // CHECK-NEXT: [[BI2:%.+]] = load i32, ptr %bi2.addr, align 4
  // CHECK-NEXT: [[LOADEDV1:%.+]] = trunc i32 [[BI2]] to i31
  // CHECK-NEXT: call i31 @llvm.ssub.sat.i31(i31 [[LOADEDV]], i31 [[LOADEDV1]])
  bi1 = __builtin_elementwise_sub_sat(bi1, bi2);

  // CHECK:      [[BU1:%.+]] = load i64, ptr %bu1.addr, align 8
  // CHECK-NEXT: [[LOADEDV2:%.+]] = trunc i64 [[BU1]] to i55
  // CHECK-NEXT: [[BU2:%.+]] = load i64, ptr %bu2.addr, align 8
  // CHECK-NEXT: [[LOADEDV3:%.+]] = trunc i64 [[BU2]] to i55
  // CHECK-NEXT: call i55 @llvm.usub.sat.i55(i55 [[LOADEDV2]], i55 [[LOADEDV3]])
  bu1 = __builtin_elementwise_sub_sat(bu1, bu2);

  // CHECK:      [[IAS1:%.+]] = load i32, ptr addrspace(1) @int_as_one, align 4
  // CHECK-NEXT: [[B:%.+]] = load i32, ptr @b, align 4
  // CHECK-NEXT: call i32 @llvm.ssub.sat.i32(i32 [[IAS1]], i32 [[B]])
  int_as_one = __builtin_elementwise_sub_sat(int_as_one, b);

  // CHECK: store i64 -96, ptr %i1.addr, align 8
  i1 = __builtin_elementwise_sub_sat(1, 'a');

  // CHECK:      [[C1:%.+]] = load i8, ptr %c1.addr, align 1
  // CHECK-NEXT: [[C2:%.+]] = load i8, ptr %c2.addr, align 1
  // CHECK-NEXT: call i8 @llvm.ssub.sat.i8(i8 [[C1]], i8 [[C2]])
  c1 = __builtin_elementwise_sub_sat(c1, c2);

  // CHECK:      [[UC1:%.+]] = load i8, ptr %uc1.addr, align 1
  // CHECK-NEXT: [[UC2:%.+]] = load i8, ptr %uc2.addr, align 1
  // CHECK-NEXT: call i8 @llvm.usub.sat.i8(i8 [[UC1]], i8 [[UC2]])
  uc1 = __builtin_elementwise_sub_sat(uc1, uc2);

  // CHECK:      [[S1:%.+]] = load i16, ptr %s1.addr, align 2
  // CHECK-NEXT: [[S2:%.+]] = load i16, ptr %s2.addr, align 2
  // CHECK-NEXT: call i16 @llvm.ssub.sat.i16(i16 [[S1]], i16 [[S2]])
  s1 = __builtin_elementwise_sub_sat(s1, s2);

  // CHECK:      [[US1:%.+]] = load i16, ptr %us1.addr, align 2
  // CHECK-NEXT: [[US2:%.+]] = load i16, ptr %us2.addr, align 2
  // CHECK-NEXT: call i16 @llvm.usub.sat.i16(i16 [[US1]], i16 [[US2]])
  us1 = __builtin_elementwise_sub_sat(us1, us2);
}

void test_builtin_elementwise_maximum(float f1, float f2, double d1, double d2,
                                      float4 vf1, float4 vf2, long long int i1,
                                      long long int i2, si8 vi1, si8 vi2,
                                      unsigned u1, unsigned u2, u4 vu1, u4 vu2,
                                      _BitInt(31) bi1, _BitInt(31) bi2,
                                      unsigned _BitInt(55) bu1, unsigned _BitInt(55) bu2) {
  // CHECK-LABEL: define void @test_builtin_elementwise_maximum(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT: [[F2:%.+]] = load float, ptr %f2.addr, align 4
  // CHECK-NEXT:  call float @llvm.maximum.f32(float [[F1]], float [[F2]])
  f1 = __builtin_elementwise_maximum(f1, f2);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: [[D2:%.+]] = load double, ptr %d2.addr, align 8
  // CHECK-NEXT: call double @llvm.maximum.f64(double [[D1]], double [[D2]])
  d1 = __builtin_elementwise_maximum(d1, d2);

  // CHECK:      [[D2:%.+]] = load double, ptr %d2.addr, align 8
  // CHECK-NEXT: call double @llvm.maximum.f64(double 2.000000e+01, double [[D2]])
  d1 = __builtin_elementwise_maximum(20.0, d2);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: [[VF2:%.+]] = load <4 x float>, ptr %vf2.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.maximum.v4f32(<4 x float> [[VF1]], <4 x float> [[VF2]])
  vf1 = __builtin_elementwise_maximum(vf1, vf2);

  // CHECK:      [[CVF1:%.+]] = load <4 x float>, ptr %cvf1, align 16
  // CHECK-NEXT: [[VF2:%.+]] = load <4 x float>, ptr %vf2.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.maximum.v4f32(<4 x float> [[CVF1]], <4 x float> [[VF2]])
  const float4 cvf1 = vf1;
  vf1 = __builtin_elementwise_maximum(cvf1, vf2);

  // CHECK:      [[VF2:%.+]] = load <4 x float>, ptr %vf2.addr, align 16
  // CHECK-NEXT: [[CVF1:%.+]] = load <4 x float>, ptr %cvf1, align 16
  // CHECK-NEXT: call <4 x float> @llvm.maximum.v4f32(<4 x float> [[VF2]], <4 x float> [[CVF1]])
  vf1 = __builtin_elementwise_maximum(vf2, cvf1);
}

void test_builtin_elementwise_minimum(float f1, float f2, double d1, double d2,
                                      float4 vf1, float4 vf2, long long int i1,
                                      long long int i2, si8 vi1, si8 vi2,
                                      unsigned u1, unsigned u2, u4 vu1, u4 vu2,
                                      _BitInt(31) bi1, _BitInt(31) bi2,
                                      unsigned _BitInt(55) bu1, unsigned _BitInt(55) bu2) {
  // CHECK-LABEL: define void @test_builtin_elementwise_minimum(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT: [[F2:%.+]] = load float, ptr %f2.addr, align 4
  // CHECK-NEXT:  call float @llvm.minimum.f32(float [[F1]], float [[F2]])
  f1 = __builtin_elementwise_minimum(f1, f2);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: [[D2:%.+]] = load double, ptr %d2.addr, align 8
  // CHECK-NEXT: call double @llvm.minimum.f64(double [[D1]], double [[D2]])
  d1 = __builtin_elementwise_minimum(d1, d2);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: call double @llvm.minimum.f64(double [[D1]], double 2.000000e+00)
  d1 = __builtin_elementwise_minimum(d1, 2.0);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: [[VF2:%.+]] = load <4 x float>, ptr %vf2.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.minimum.v4f32(<4 x float> [[VF1]], <4 x float> [[VF2]])
  vf1 = __builtin_elementwise_minimum(vf1, vf2);

  // CHECK:      [[CVF1:%.+]] = load <4 x float>, ptr %cvf1, align 16
  // CHECK-NEXT: [[VF2:%.+]] = load <4 x float>, ptr %vf2.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.minimum.v4f32(<4 x float> [[CVF1]], <4 x float> [[VF2]])
  const float4 cvf1 = vf1;
  vf1 = __builtin_elementwise_minimum(cvf1, vf2);

  // CHECK:      [[VF2:%.+]] = load <4 x float>, ptr %vf2.addr, align 16
  // CHECK-NEXT: [[CVF1:%.+]] = load <4 x float>, ptr %cvf1, align 16
  // CHECK-NEXT: call <4 x float> @llvm.minimum.v4f32(<4 x float> [[VF2]], <4 x float> [[CVF1]])
  vf1 = __builtin_elementwise_minimum(vf2, cvf1);
}

void test_builtin_elementwise_max(float f1, float f2, double d1, double d2,
                                  float4 vf1, float4 vf2, long long int i1,
                                  long long int i2, si8 vi1, si8 vi2,
                                  unsigned u1, unsigned u2, u4 vu1, u4 vu2,
                                  _BitInt(31) bi1, _BitInt(31) bi2,
                                  unsigned _BitInt(55) bu1, unsigned _BitInt(55) bu2) {
  // CHECK-LABEL: define void @test_builtin_elementwise_max(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT: [[F2:%.+]] = load float, ptr %f2.addr, align 4
  // CHECK-NEXT:  call float @llvm.maxnum.f32(float [[F1]], float [[F2]])
  f1 = __builtin_elementwise_max(f1, f2);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: [[D2:%.+]] = load double, ptr %d2.addr, align 8
  // CHECK-NEXT: call double @llvm.maxnum.f64(double [[D1]], double [[D2]])
  d1 = __builtin_elementwise_max(d1, d2);

  // CHECK:      [[D2:%.+]] = load double, ptr %d2.addr, align 8
  // CHECK-NEXT: call double @llvm.maxnum.f64(double 2.000000e+01, double [[D2]])
  d1 = __builtin_elementwise_max(20.0, d2);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: [[VF2:%.+]] = load <4 x float>, ptr %vf2.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.maxnum.v4f32(<4 x float> [[VF1]], <4 x float> [[VF2]])
  vf1 = __builtin_elementwise_max(vf1, vf2);

  // CHECK:      [[I1:%.+]] = load i64, ptr %i1.addr, align 8
  // CHECK-NEXT: [[I2:%.+]] = load i64, ptr %i2.addr, align 8
  // CHECK-NEXT: call i64 @llvm.smax.i64(i64 [[I1]], i64 [[I2]])
  i1 = __builtin_elementwise_max(i1, i2);

  // CHECK:      [[I1:%.+]] = load i64, ptr %i1.addr, align 8
  // CHECK-NEXT: call i64 @llvm.smax.i64(i64 [[I1]], i64 10)
  i1 = __builtin_elementwise_max(i1, 10ll);

  // CHECK:      [[VI1:%.+]] = load <8 x i16>, ptr %vi1.addr, align 16
  // CHECK-NEXT: [[VI2:%.+]] = load <8 x i16>, ptr %vi2.addr, align 16
  // CHECK-NEXT: call <8 x i16> @llvm.smax.v8i16(<8 x i16> [[VI1]], <8 x i16> [[VI2]])
  vi1 = __builtin_elementwise_max(vi1, vi2);

  // CHECK:      [[U1:%.+]] = load i32, ptr %u1.addr, align 4
  // CHECK-NEXT: [[U2:%.+]] = load i32, ptr %u2.addr, align 4
  // CHECK-NEXT: call i32 @llvm.umax.i32(i32 [[U1]], i32 [[U2]])
  u1 = __builtin_elementwise_max(u1, u2);

  // CHECK:      [[VU1:%.+]] = load <4 x i32>, ptr %vu1.addr, align 16
  // CHECK-NEXT: [[VU2:%.+]] = load <4 x i32>, ptr %vu2.addr, align 16
  // CHECK-NEXT: call <4 x i32> @llvm.umax.v4i32(<4 x i32> [[VU1]], <4 x i32> [[VU2]])
  vu1 = __builtin_elementwise_max(vu1, vu2);

  // CHECK:      [[BI1:%.+]] = load i32, ptr %bi1.addr, align 4
  // CHECK-NEXT: [[LOADEDV:%.+]] = trunc i32 [[BI1]] to i31
  // CHECK-NEXT: [[BI2:%.+]] = load i32, ptr %bi2.addr, align 4
  // CHECK-NEXT: [[LOADEDV1:%.+]] = trunc i32 [[BI2]] to i31
  // CHECK-NEXT: call i31 @llvm.smax.i31(i31 [[LOADEDV]], i31 [[LOADEDV1]])
  bi1 = __builtin_elementwise_max(bi1, bi2);

  // CHECK:      [[BU1:%.+]] = load i64, ptr %bu1.addr, align 8
  // CHECK-NEXT: [[LOADEDV2:%.+]] = trunc i64 [[BU1]] to i55
  // CHECK-NEXT: [[BU2:%.+]] = load i64, ptr %bu2.addr, align 8
  // CHECK-NEXT: [[LOADEDV3:%.+]] = trunc i64 [[BU2]] to i55
  // CHECK-NEXT: call i55 @llvm.umax.i55(i55 [[LOADEDV2]], i55 [[LOADEDV3]])
  bu1 = __builtin_elementwise_max(bu1, bu2);

  // CHECK:      [[CVF1:%.+]] = load <4 x float>, ptr %cvf1, align 16
  // CHECK-NEXT: [[VF2:%.+]] = load <4 x float>, ptr %vf2.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.maxnum.v4f32(<4 x float> [[CVF1]], <4 x float> [[VF2]])
  const float4 cvf1 = vf1;
  vf1 = __builtin_elementwise_max(cvf1, vf2);

  // CHECK:      [[VF2:%.+]] = load <4 x float>, ptr %vf2.addr, align 16
  // CHECK-NEXT: [[CVF1:%.+]] = load <4 x float>, ptr %cvf1, align 16
  // CHECK-NEXT: call <4 x float> @llvm.maxnum.v4f32(<4 x float> [[VF2]], <4 x float> [[CVF1]])
  vf1 = __builtin_elementwise_max(vf2, cvf1);

  // CHECK:      [[IAS1:%.+]] = load i32, ptr addrspace(1) @int_as_one, align 4
  // CHECK-NEXT: [[B:%.+]] = load i32, ptr @b, align 4
  // CHECK-NEXT: call i32 @llvm.smax.i32(i32 [[IAS1]], i32 [[B]])
  int_as_one = __builtin_elementwise_max(int_as_one, b);

  // CHECK: store i64 97, ptr [[I1:%.+]], align 8
  i1 = __builtin_elementwise_max(1, 'a');
}

void test_builtin_elementwise_min(float f1, float f2, double d1, double d2,
                                  float4 vf1, float4 vf2, long long int i1,
                                  long long int i2, si8 vi1, si8 vi2,
                                  unsigned u1, unsigned u2, u4 vu1, u4 vu2,
                                  _BitInt(31) bi1, _BitInt(31) bi2,
                                  unsigned _BitInt(55) bu1, unsigned _BitInt(55) bu2) {
  // CHECK-LABEL: define void @test_builtin_elementwise_min(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT: [[F2:%.+]] = load float, ptr %f2.addr, align 4
  // CHECK-NEXT:  call float @llvm.minnum.f32(float [[F1]], float [[F2]])
  f1 = __builtin_elementwise_min(f1, f2);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: [[D2:%.+]] = load double, ptr %d2.addr, align 8
  // CHECK-NEXT: call double @llvm.minnum.f64(double [[D1]], double [[D2]])
  d1 = __builtin_elementwise_min(d1, d2);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: call double @llvm.minnum.f64(double [[D1]], double 2.000000e+00)
  d1 = __builtin_elementwise_min(d1, 2.0);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: [[VF2:%.+]] = load <4 x float>, ptr %vf2.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.minnum.v4f32(<4 x float> [[VF1]], <4 x float> [[VF2]])
  vf1 = __builtin_elementwise_min(vf1, vf2);

  // CHECK:      [[I1:%.+]] = load i64, ptr %i1.addr, align 8
  // CHECK-NEXT: [[I2:%.+]] = load i64, ptr %i2.addr, align 8
  // CHECK-NEXT: call i64 @llvm.smin.i64(i64 [[I1]], i64 [[I2]])
  i1 = __builtin_elementwise_min(i1, i2);

  // CHECK:      [[I2:%.+]] = load i64, ptr %i2.addr, align 8
  // CHECK-NEXT: call i64 @llvm.smin.i64(i64 -11, i64 [[I2]])
  i1 = __builtin_elementwise_min(-11ll, i2);

  // CHECK:      [[I1:%.+]] = load i64, ptr %i1.addr, align 8
  // CHECK:      [[S1:%.+]] = trunc i64 [[I1]] to i16
  // CHECK-NEXT: [[I2:%.+]] = load i64, ptr %i2.addr, align 8
  // CHECK:      [[S2:%.+]] = trunc i64 [[I2]] to i16
  // CHECK-NEXT: call i16 @llvm.smin.i16(i16 [[S1]], i16 [[S2]])
  i1 = __builtin_elementwise_min((short)i1, (short)i2);

  // CHECK:      [[VI1:%.+]] = load <8 x i16>, ptr %vi1.addr, align 16
  // CHECK-NEXT: [[VI2:%.+]] = load <8 x i16>, ptr %vi2.addr, align 16
  // CHECK-NEXT: call <8 x i16> @llvm.smin.v8i16(<8 x i16> [[VI1]], <8 x i16> [[VI2]])
  vi1 = __builtin_elementwise_min(vi1, vi2);

  // CHECK:      [[U1:%.+]] = load i32, ptr %u1.addr, align 4
  // CHECK-NEXT: [[U2:%.+]] = load i32, ptr %u2.addr, align 4
  // CHECK-NEXT: call i32 @llvm.umin.i32(i32 [[U1]], i32 [[U2]])
  u1 = __builtin_elementwise_min(u1, u2);

  // CHECK:      [[VU1:%.+]] = load <4 x i32>, ptr %vu1.addr, align 16
  // CHECK-NEXT: [[VU2:%.+]] = load <4 x i32>, ptr %vu2.addr, align 16
  // CHECK-NEXT: call <4 x i32> @llvm.umin.v4i32(<4 x i32> [[VU1]], <4 x i32> [[VU2]])
  vu1 = __builtin_elementwise_min(vu1, vu2);

  // CHECK:      [[BI1:%.+]] = load i32, ptr %bi1.addr, align 4
  // CHECK-NEXT: [[LOADEDV:%.+]] = trunc i32 [[BI1]] to i31
  // CHECK-NEXT: [[BI2:%.+]] = load i32, ptr %bi2.addr, align 4
  // CHECK-NEXT: [[LOADEDV1:%.+]] = trunc i32 [[BI2]] to i31
  // CHECK-NEXT: call i31 @llvm.smin.i31(i31 [[LOADEDV]], i31 [[LOADEDV1]])
  bi1 = __builtin_elementwise_min(bi1, bi2);

  // CHECK:      [[BU1:%.+]] = load i64, ptr %bu1.addr, align 8
  // CHECK-NEXT: [[LOADEDV2:%.+]] = trunc i64 [[BU1]] to i55
  // CHECK-NEXT: [[BU2:%.+]] = load i64, ptr %bu2.addr, align 8
  // CHECK-NEXT: [[LOADEDV3:%.+]] = trunc i64 [[BU2]] to i55
  // CHECK-NEXT: call i55 @llvm.umin.i55(i55 [[LOADEDV2]], i55 [[LOADEDV3]])
  bu1 = __builtin_elementwise_min(bu1, bu2);

  // CHECK:      [[CVF1:%.+]] = load <4 x float>, ptr %cvf1, align 16
  // CHECK-NEXT: [[VF2:%.+]] = load <4 x float>, ptr %vf2.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.minnum.v4f32(<4 x float> [[CVF1]], <4 x float> [[VF2]])
  const float4 cvf1 = vf1;
  vf1 = __builtin_elementwise_min(cvf1, vf2);

  // CHECK:      [[VF2:%.+]] = load <4 x float>, ptr %vf2.addr, align 16
  // CHECK-NEXT: [[CVF1:%.+]] = load <4 x float>, ptr %cvf1, align 16
  // CHECK-NEXT: call <4 x float> @llvm.minnum.v4f32(<4 x float> [[VF2]], <4 x float> [[CVF1]])
  vf1 = __builtin_elementwise_min(vf2, cvf1);

  // CHECK:      [[IAS1:%.+]] = load i32, ptr addrspace(1) @int_as_one, align 4
  // CHECK-NEXT: [[B:%.+]] = load i32, ptr @b, align 4
  // CHECK-NEXT: call i32 @llvm.smin.i32(i32 [[IAS1]], i32 [[B]])
  int_as_one = __builtin_elementwise_min(int_as_one, b);

  // CHECK: store i64 2, ptr [[I1:%.+]], align 8
  i1 = __builtin_elementwise_min(2, 'b');
}

void test_builtin_elementwise_bitreverse(si8 vi1, si8 vi2,
                                  long long int i1, long long int i2, short si,
                                  _BitInt(31) bi1, _BitInt(31) bi2,
                                  char ci) {
  

  // CHECK:      [[I1:%.+]] = load i64, ptr %i1.addr, align 8
  // CHECK-NEXT: call i64 @llvm.bitreverse.i64(i64 [[I1]])
  i2 = __builtin_elementwise_bitreverse(i1);

  // CHECK:      [[VI1:%.+]] = load <8 x i16>, ptr %vi1.addr, align 16
  // CHECK-NEXT: call <8 x i16> @llvm.bitreverse.v8i16(<8 x i16> [[VI1]])
  vi2 = __builtin_elementwise_bitreverse(vi1);

  // CHECK:      [[CVI2:%.+]] = load <8 x i16>, ptr %cvi2, align 16
  // CHECK-NEXT: call <8 x i16> @llvm.bitreverse.v8i16(<8 x i16> [[CVI2]])
  const si8 cvi2 = vi2;
  vi2 = __builtin_elementwise_bitreverse(cvi2);

  // CHECK:      [[BI1:%.+]] = load i32, ptr %bi1.addr, align 4
  // CHECK-NEXT: [[LOADEDV:%.+]] = trunc i32 [[BI1]] to i31
  // CHECK-NEXT: call i31 @llvm.bitreverse.i31(i31 [[LOADEDV]])
  bi2 = __builtin_elementwise_bitreverse(bi1);

  // CHECK:      [[IA1:%.+]] = load i32, ptr addrspace(1) @int_as_one, align 4
  // CHECK-NEXT: call i32 @llvm.bitreverse.i32(i32 [[IA1]])
  b = __builtin_elementwise_bitreverse(int_as_one);

  // CHECK:      store i32 1879048191, ptr @b, align 4
  b = __builtin_elementwise_bitreverse(-10);

  // CHECK:      [[SI:%.+]] = load i16, ptr %si.addr, align 2
  // CHECK-NEXT: [[RES:%.+]] = call i16 @llvm.bitreverse.i16(i16 [[SI]])
  si = __builtin_elementwise_bitreverse(si);

  // CHECK:      store i16 28671, ptr %si.addr, align 2
  si = __builtin_elementwise_bitreverse((short)-10);

  // CHECK:      store i16 28671, ptr %si.addr, align 2
  si = __builtin_elementwise_bitreverse((unsigned short)-10);

  // CHECK:      [[CI:%.+]] = load i8, ptr %ci.addr, align 1
  // CHECK-NEXT: [[RES:%.+]] = call i8 @llvm.bitreverse.i8(i8 [[CI]])
  ci = __builtin_elementwise_bitreverse(ci);

  // CHECK:      store i8 111, ptr %ci.addr, align 1
  ci = __builtin_elementwise_bitreverse((unsigned char)-10);

  // CHECK:      store i8 111, ptr %ci.addr, align 1
  ci = __builtin_elementwise_bitreverse((char)-10);
}

void test_builtin_elementwise_ceil(float f1, float f2, double d1, double d2,
                                   float4 vf1, float4 vf2) {
  // CHECK-LABEL: define void @test_builtin_elementwise_ceil(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT:  call float @llvm.ceil.f32(float [[F1]])
  f2 = __builtin_elementwise_ceil(f1);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: call double @llvm.ceil.f64(double [[D1]])
  d2 = __builtin_elementwise_ceil(d1);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.ceil.v4f32(<4 x float> [[VF1]])
  vf2 = __builtin_elementwise_ceil(vf1);
}

void test_builtin_elementwise_acos(float f1, float f2, double d1, double d2,
                                  float4 vf1, float4 vf2) {
  // CHECK-LABEL: define void @test_builtin_elementwise_acos(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT:  call float @llvm.acos.f32(float [[F1]])
  f2 = __builtin_elementwise_acos(f1);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: call double @llvm.acos.f64(double [[D1]])
  d2 = __builtin_elementwise_acos(d1);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.acos.v4f32(<4 x float> [[VF1]])
  vf2 = __builtin_elementwise_acos(vf1);
}

void test_builtin_elementwise_asin(float f1, float f2, double d1, double d2,
                                  float4 vf1, float4 vf2) {
  // CHECK-LABEL: define void @test_builtin_elementwise_asin(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT:  call float @llvm.asin.f32(float [[F1]])
  f2 = __builtin_elementwise_asin(f1);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: call double @llvm.asin.f64(double [[D1]])
  d2 = __builtin_elementwise_asin(d1);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.asin.v4f32(<4 x float> [[VF1]])
  vf2 = __builtin_elementwise_asin(vf1);
}

void test_builtin_elementwise_atan(float f1, float f2, double d1, double d2,
                                  float4 vf1, float4 vf2) {
  // CHECK-LABEL: define void @test_builtin_elementwise_atan(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT:  call float @llvm.atan.f32(float [[F1]])
  f2 = __builtin_elementwise_atan(f1);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: call double @llvm.atan.f64(double [[D1]])
  d2 = __builtin_elementwise_atan(d1);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.atan.v4f32(<4 x float> [[VF1]])
  vf2 = __builtin_elementwise_atan(vf1);
}

void test_builtin_elementwise_atan2(float f1, float f2, float f3, double d1,
                                    double d2, double d3, float4 vf1,
                                    float4 vf2, float4 vf3) {
  // CHECK-LABEL: define void @test_builtin_elementwise_atan2(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT: [[F2:%.+]] = load float, ptr %f2.addr, align 4
  // CHECK-NEXT: call float @llvm.atan2.f32(float [[F1]], float [[F2]])
  f3 = __builtin_elementwise_atan2(f1, f2);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: [[D2:%.+]] = load double, ptr %d2.addr, align 8
  // CHECK-NEXT: call double @llvm.atan2.f64(double [[D1]], double [[D2]])
  d3 = __builtin_elementwise_atan2(d1, d2);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: [[VF2:%.+]] = load <4 x float>, ptr %vf2.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.atan2.v4f32(<4 x float> [[VF1]], <4 x float> [[VF2]])
  vf3 = __builtin_elementwise_atan2(vf1, vf2);
}

void test_builtin_elementwise_cos(float f1, float f2, double d1, double d2,
                                  float4 vf1, float4 vf2) {
  // CHECK-LABEL: define void @test_builtin_elementwise_cos(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT:  call float @llvm.cos.f32(float [[F1]])
  f2 = __builtin_elementwise_cos(f1);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: call double @llvm.cos.f64(double [[D1]])
  d2 = __builtin_elementwise_cos(d1);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.cos.v4f32(<4 x float> [[VF1]])
  vf2 = __builtin_elementwise_cos(vf1);
}

void test_builtin_elementwise_cosh(float f1, float f2, double d1, double d2,
                                  float4 vf1, float4 vf2) {
  // CHECK-LABEL: define void @test_builtin_elementwise_cosh(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT:  call float @llvm.cosh.f32(float [[F1]])
  f2 = __builtin_elementwise_cosh(f1);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: call double @llvm.cosh.f64(double [[D1]])
  d2 = __builtin_elementwise_cosh(d1);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.cosh.v4f32(<4 x float> [[VF1]])
  vf2 = __builtin_elementwise_cosh(vf1);
}

void test_builtin_elementwise_exp(float f1, float f2, double d1, double d2,
                                  float4 vf1, float4 vf2) {
  // CHECK-LABEL: define void @test_builtin_elementwise_exp(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT:  call float @llvm.exp.f32(float [[F1]])
  f2 = __builtin_elementwise_exp(f1);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: call double @llvm.exp.f64(double [[D1]])
  d2 = __builtin_elementwise_exp(d1);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.exp.v4f32(<4 x float> [[VF1]])
  vf2 = __builtin_elementwise_exp(vf1);
}

void test_builtin_elementwise_exp2(float f1, float f2, double d1, double d2,
                                  float4 vf1, float4 vf2) {
  // CHECK-LABEL: define void @test_builtin_elementwise_exp2(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT:  call float @llvm.exp2.f32(float [[F1]])
  f2 = __builtin_elementwise_exp2(f1);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: call double @llvm.exp2.f64(double [[D1]])
  d2 = __builtin_elementwise_exp2(d1);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.exp2.v4f32(<4 x float> [[VF1]])
  vf2 = __builtin_elementwise_exp2(vf1);
}

void test_builtin_elementwise_exp10(float f1, float f2, double d1, double d2,
                                  float4 vf1, float4 vf2) {
  // CHECK-LABEL: define void @test_builtin_elementwise_exp10(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT:  call float @llvm.exp10.f32(float [[F1]])
  f2 = __builtin_elementwise_exp10(f1);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: call double @llvm.exp10.f64(double [[D1]])
  d2 = __builtin_elementwise_exp10(d1);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.exp10.v4f32(<4 x float> [[VF1]])
  vf2 = __builtin_elementwise_exp10(vf1);
}

void test_builtin_elementwise_ldexp(float f1, float f2, double d1, double d2,
                                    float4 vf1, float4 vf2, int i1, int4 vi1, short s1, long l1) {
  // CHECK-LABEL: define void @test_builtin_elementwise_ldexp(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK:      [[I1:%.+]] = load i32, ptr %i1.addr, align 4
  // CHECK-NEXT: call float @llvm.ldexp.f32.i32(float [[F1]], i32 [[I1]])
  f2 = __builtin_elementwise_ldexp(f1, i1);

  // CHECK:      [[F2:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK:      [[S1:%.+]] = load i16, ptr %s1.addr, align 2
  // CHECK:      [[Ext1:%.+]] = sext i16 [[S1]] to i32
  // CHECK-NEXT: call float @llvm.ldexp.f32.i32(float [[F2]], i32 [[Ext1]])
  f2 = __builtin_elementwise_ldexp(f1, s1);

  // CHECK:      [[F3:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK:      [[L1:%.+]] = load i64, ptr %l1.addr, align 8
  // CHECK-NEXT: call float @llvm.ldexp.f32.i64(float [[F3]], i64 [[L1]])
  f2 = __builtin_elementwise_ldexp(f1, l1);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK:      [[I2:%.+]] = load i32, ptr %i1.addr, align 4
  // CHECK-NEXT: call double @llvm.ldexp.f64.i32(double [[D1]], i32 [[I2]])
  d2 = __builtin_elementwise_ldexp(d1, i1);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK:      [[VI1:%.+]] = load <4 x i32>, ptr %vi1.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.ldexp.v4f32.v4i32(<4 x float> [[VF1]], <4 x i32> [[VI1]])
  vf2 = __builtin_elementwise_ldexp(vf1, vi1);
}

void test_builtin_elementwise_floor(float f1, float f2, double d1, double d2,
                                    float4 vf1, float4 vf2) {
  // CHECK-LABEL: define void @test_builtin_elementwise_floor(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT:  call float @llvm.floor.f32(float [[F1]])
  f2 = __builtin_elementwise_floor(f1);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: call double @llvm.floor.f64(double [[D1]])
  d2 = __builtin_elementwise_floor(d1);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.floor.v4f32(<4 x float> [[VF1]])
  vf2 = __builtin_elementwise_floor(vf1);
}

void test_builtin_elementwise_log(float f1, float f2, double d1, double d2,
                                  float4 vf1, float4 vf2) {
  // CHECK-LABEL: define void @test_builtin_elementwise_log(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT:  call float @llvm.log.f32(float [[F1]])
  f2 = __builtin_elementwise_log(f1);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: call double @llvm.log.f64(double [[D1]])
  d2 = __builtin_elementwise_log(d1);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.log.v4f32(<4 x float> [[VF1]])
  vf2 = __builtin_elementwise_log(vf1);
}

void test_builtin_elementwise_log10(float f1, float f2, double d1, double d2,
                                  float4 vf1, float4 vf2) {
  // CHECK-LABEL: define void @test_builtin_elementwise_log10(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT:  call float @llvm.log10.f32(float [[F1]])
  f2 = __builtin_elementwise_log10(f1);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: call double @llvm.log10.f64(double [[D1]])
  d2 = __builtin_elementwise_log10(d1);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.log10.v4f32(<4 x float> [[VF1]])
  vf2 = __builtin_elementwise_log10(vf1);
}

void test_builtin_elementwise_log2(float f1, float f2, double d1, double d2,
                                  float4 vf1, float4 vf2) {
  // CHECK-LABEL: define void @test_builtin_elementwise_log2(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT:  call float @llvm.log2.f32(float [[F1]])
  f2 = __builtin_elementwise_log2(f1);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: call double @llvm.log2.f64(double [[D1]])
  d2 = __builtin_elementwise_log2(d1);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.log2.v4f32(<4 x float> [[VF1]])
  vf2 = __builtin_elementwise_log2(vf1);
}

void test_builtin_elementwise_popcount(si8 vi1, si8 vi2, long long int i1,
                                       long long int i2, short si,
                                       _BitInt(31) bi1, _BitInt(31) bi2,
                                       char ci) {
  // CHECK:      [[I1:%.+]] = load i64, ptr %i1.addr, align 8
  // CHECK-NEXT: call i64 @llvm.ctpop.i64(i64 [[I1]])
  i2 = __builtin_elementwise_popcount(i1);

  // CHECK:      [[VI1:%.+]] = load <8 x i16>, ptr %vi1.addr, align 16
  // CHECK-NEXT: call <8 x i16> @llvm.ctpop.v8i16(<8 x i16> [[VI1]])
  vi2 = __builtin_elementwise_popcount(vi1);

  // CHECK:      [[CVI2:%.+]] = load <8 x i16>, ptr %cvi2, align 16
  // CHECK-NEXT: call <8 x i16> @llvm.ctpop.v8i16(<8 x i16> [[CVI2]])
  const si8 cvi2 = vi2;
  vi2 = __builtin_elementwise_popcount(cvi2);

  // CHECK:      [[BI1:%.+]] = load i32, ptr %bi1.addr, align 4
  // CHECK-NEXT: [[LOADEDV:%.+]] = trunc i32 [[BI1]] to i31
  // CHECK-NEXT: call i31 @llvm.ctpop.i31(i31 [[LOADEDV]])
  bi2 = __builtin_elementwise_popcount(bi1);

  // CHECK:      [[IA1:%.+]] = load i32, ptr addrspace(1) @int_as_one, align 4
  // CHECK-NEXT: call i32 @llvm.ctpop.i32(i32 [[IA1]])
  b = __builtin_elementwise_popcount(int_as_one);

  // CHECK:      store i32 30, ptr @b, align 4
  b = __builtin_elementwise_popcount(-10);

  // CHECK:      [[SI:%.+]] = load i16, ptr %si.addr, align 2
  // CHECK-NEXT: [[RES:%.+]] = call i16 @llvm.ctpop.i16(i16 [[SI]])
  si = __builtin_elementwise_popcount(si);

  // CHECK:      store i16 3, ptr %si.addr, align 2
  si = __builtin_elementwise_popcount((unsigned short)32771);

  // CHECK:      store i16 3, ptr %si.addr, align 2
  si = __builtin_elementwise_popcount((short)32771);

  // CHECK:      [[CI:%.+]] = load i8, ptr %ci.addr, align 1
  // CHECK-NEXT: [[RES:%.+]] = call i8 @llvm.ctpop.i8(i8 [[CI]])
  ci = __builtin_elementwise_popcount(ci);

  // CHECK:      store i8 2, ptr %ci.addr, align 1
  ci = __builtin_elementwise_popcount((unsigned char)192);

  // CHECK:      store i8 2, ptr %ci.addr, align 1
  ci = __builtin_elementwise_popcount((char)192);
}

void test_builtin_elementwise_fmod(float f1, float f2, double d1, double d2,
                                      float4 vf1, float4 vf2) {

  // CHECK-LABEL: define void @test_builtin_elementwise_fmod(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK:      [[F2:%.+]] = load float, ptr %f2.addr, align 4
  // CHECK-NEXT:  frem float [[F1]], [[F2]]
  f2 = __builtin_elementwise_fmod(f1, f2);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK:      [[D2:%.+]] = load double, ptr %d2.addr, align 8
  // CHECK-NEXT: frem double [[D1]], [[D2]]
  d2 = __builtin_elementwise_fmod(d1, d2);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK:      [[VF2:%.+]] = load <4 x float>, ptr %vf2.addr, align 16
  // CHECK-NEXT: frem <4 x float> [[VF1]], [[VF2]]
  vf2 = __builtin_elementwise_fmod(vf1, vf2);
}

void test_builtin_elementwise_pow(float f1, float f2, double d1, double d2,
                                      float4 vf1, float4 vf2) {

  // CHECK-LABEL: define void @test_builtin_elementwise_pow(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK:      [[F2:%.+]] = load float, ptr %f2.addr, align 4
  // CHECK-NEXT:  call float @llvm.pow.f32(float [[F1]], float [[F2]])
  f2 = __builtin_elementwise_pow(f1, f2);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK:      [[D2:%.+]] = load double, ptr %d2.addr, align 8
  // CHECK-NEXT: call double @llvm.pow.f64(double [[D1]], double [[D2]])
  d2 = __builtin_elementwise_pow(d1, d2);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK:      [[VF2:%.+]] = load <4 x float>, ptr %vf2.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.pow.v4f32(<4 x float> [[VF1]], <4 x float> [[VF2]])
  vf2 = __builtin_elementwise_pow(vf1, vf2);
}

void test_builtin_elementwise_roundeven(float f1, float f2, double d1, double d2,
                                        float4 vf1, float4 vf2) {
  // CHECK-LABEL: define void @test_builtin_elementwise_roundeven(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT:  call float @llvm.roundeven.f32(float [[F1]])
  f2 = __builtin_elementwise_roundeven(f1);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: call double @llvm.roundeven.f64(double [[D1]])
  d2 = __builtin_elementwise_roundeven(d1);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.roundeven.v4f32(<4 x float> [[VF1]])
  vf2 = __builtin_elementwise_roundeven(vf1);
}

void test_builtin_elementwise_round(float f1, float f2, double d1, double d2,
                                        float4 vf1, float4 vf2) {
  // CHECK-LABEL: define void @test_builtin_elementwise_round(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT:  call float @llvm.round.f32(float [[F1]])
  f2 = __builtin_elementwise_round(f1);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: call double @llvm.round.f64(double [[D1]])
  d2 = __builtin_elementwise_round(d1);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.round.v4f32(<4 x float> [[VF1]])
  vf2 = __builtin_elementwise_round(vf1);
}

void test_builtin_elementwise_rint(float f1, float f2, double d1, double d2,
                                   float4 vf1, float4 vf2) {
  // CHECK-LABEL: define void @test_builtin_elementwise_rint(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT:  call float @llvm.rint.f32(float [[F1]])
  f2 = __builtin_elementwise_rint(f1);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: call double @llvm.rint.f64(double [[D1]])
  d2 = __builtin_elementwise_rint(d1);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.rint.v4f32(<4 x float> [[VF1]])
  vf2 = __builtin_elementwise_rint(vf1);
}

void test_builtin_elementwise_nearbyint(float f1, float f2, double d1, double d2,
                                        float4 vf1, float4 vf2) {
  // CHECK-LABEL: define void @test_builtin_elementwise_nearbyint(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT:  call float @llvm.nearbyint.f32(float [[F1]])
  f2 = __builtin_elementwise_nearbyint(f1);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: call double @llvm.nearbyint.f64(double [[D1]])
  d2 = __builtin_elementwise_nearbyint(d1);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.nearbyint.v4f32(<4 x float> [[VF1]])
  vf2 = __builtin_elementwise_nearbyint(vf1);
}

void test_builtin_elementwise_sin(float f1, float f2, double d1, double d2,
                                  float4 vf1, float4 vf2) {
  // CHECK-LABEL: define void @test_builtin_elementwise_sin(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT:  call float @llvm.sin.f32(float [[F1]])
  f2 = __builtin_elementwise_sin(f1);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: call double @llvm.sin.f64(double [[D1]])
  d2 = __builtin_elementwise_sin(d1);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.sin.v4f32(<4 x float> [[VF1]])
  vf2 = __builtin_elementwise_sin(vf1);
}

void test_builtin_elementwise_sinh(float f1, float f2, double d1, double d2,
                                  float4 vf1, float4 vf2) {
  // CHECK-LABEL: define void @test_builtin_elementwise_sinh(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT:  call float @llvm.sinh.f32(float [[F1]])
  f2 = __builtin_elementwise_sinh(f1);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: call double @llvm.sinh.f64(double [[D1]])
  d2 = __builtin_elementwise_sinh(d1);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.sinh.v4f32(<4 x float> [[VF1]])
  vf2 = __builtin_elementwise_sinh(vf1);
}

void test_builtin_elementwise_sqrt(float f1, float f2, double d1, double d2,
                                  float4 vf1, float4 vf2) {
  // CHECK-LABEL: define void @test_builtin_elementwise_sqrt(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT:  call float @llvm.sqrt.f32(float [[F1]])
  f2 = __builtin_elementwise_sqrt(f1);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: call double @llvm.sqrt.f64(double [[D1]])
  d2 = __builtin_elementwise_sqrt(d1);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.sqrt.v4f32(<4 x float> [[VF1]])
  vf2 = __builtin_elementwise_sqrt(vf1);
}

void test_builtin_elementwise_tan(float f1, float f2, double d1, double d2,
                                  float4 vf1, float4 vf2) {
  // CHECK-LABEL: define void @test_builtin_elementwise_tan(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT:  call float @llvm.tan.f32(float [[F1]])
  f2 = __builtin_elementwise_tan(f1);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: call double @llvm.tan.f64(double [[D1]])
  d2 = __builtin_elementwise_tan(d1);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.tan.v4f32(<4 x float> [[VF1]])
  vf2 = __builtin_elementwise_tan(vf1);
}

void test_builtin_elementwise_tanh(float f1, float f2, double d1, double d2,
                                  float4 vf1, float4 vf2) {
  // CHECK-LABEL: define void @test_builtin_elementwise_tanh(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT:  call float @llvm.tanh.f32(float [[F1]])
  f2 = __builtin_elementwise_tanh(f1);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: call double @llvm.tanh.f64(double [[D1]])
  d2 = __builtin_elementwise_tanh(d1);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.tanh.v4f32(<4 x float> [[VF1]])
  vf2 = __builtin_elementwise_tanh(vf1);
}

void test_builtin_elementwise_trunc(float f1, float f2, double d1, double d2,
                                    float4 vf1, float4 vf2) {
  // CHECK-LABEL: define void @test_builtin_elementwise_trunc(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT:  call float @llvm.trunc.f32(float [[F1]])
  f2 = __builtin_elementwise_trunc(f1);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: call double @llvm.trunc.f64(double [[D1]])
  d2 = __builtin_elementwise_trunc(d1);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.trunc.v4f32(<4 x float> [[VF1]])
  vf2 = __builtin_elementwise_trunc(vf1);
}

void test_builtin_elementwise_canonicalize(float f1, float f2, double d1, double d2,
                                           float4 vf1, float4 vf2) {
  // CHECK-LABEL: define void @test_builtin_elementwise_canonicalize(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT:  call float @llvm.canonicalize.f32(float [[F1]])
  f2 = __builtin_elementwise_canonicalize(f1);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: call double @llvm.canonicalize.f64(double [[D1]])
  d2 = __builtin_elementwise_canonicalize(d1);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.canonicalize.v4f32(<4 x float> [[VF1]])
  vf2 = __builtin_elementwise_canonicalize(vf1);
}

void test_builtin_elementwise_copysign(float f1, float f2, double d1, double d2,
                                       float4 vf1, float4 vf2, double2 v2f64) {
  // CHECK-LABEL: define void @test_builtin_elementwise_copysign(
  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr, align 4
  // CHECK-NEXT: [[F2:%.+]] = load float, ptr %f2.addr, align 4
  // CHECK-NEXT:  call float @llvm.copysign.f32(float %0, float %1)
  f1 = __builtin_elementwise_copysign(f1, f2);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: [[D2:%.+]] = load double, ptr %d2.addr, align 8
  // CHECK-NEXT: call double @llvm.copysign.f64(double [[D1]], double [[D2]])
  d1 = __builtin_elementwise_copysign(d1, d2);

  // CHECK:      [[D1:%.+]] = load double, ptr %d1.addr, align 8
  // CHECK-NEXT: call double @llvm.copysign.f64(double [[D1]], double 2.000000e+00)
  d1 = __builtin_elementwise_copysign(d1, 2.0);

  // CHECK:      [[VF1:%.+]] = load <4 x float>, ptr %vf1.addr, align 16
  // CHECK-NEXT: [[VF2:%.+]] = load <4 x float>, ptr %vf2.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.copysign.v4f32(<4 x float> [[VF1]], <4 x float> [[VF2]])
  vf1 = __builtin_elementwise_copysign(vf1, vf2);

  // CHECK:      [[CVF1:%.+]] = load <4 x float>, ptr %cvf1, align 16
  // CHECK-NEXT: [[VF2:%.+]] = load <4 x float>, ptr %vf2.addr, align 16
  // CHECK-NEXT: call <4 x float> @llvm.copysign.v4f32(<4 x float> [[CVF1]], <4 x float> [[VF2]])
  const float4 cvf1 = vf1;
  vf1 = __builtin_elementwise_copysign(cvf1, vf2);

  // CHECK:      [[VF2:%.+]] = load <4 x float>, ptr %vf2.addr, align 16
  // CHECK-NEXT: [[CVF1:%.+]] = load <4 x float>, ptr %cvf1, align 16
  // CHECK-NEXT: call <4 x float> @llvm.copysign.v4f32(<4 x float> [[VF2]], <4 x float> [[CVF1]])
  vf1 = __builtin_elementwise_copysign(vf2, cvf1);


  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr
  // CHECK-NEXT: call float @llvm.copysign.f32(float [[F1]], float 2.000000e+00)
  f1 = __builtin_elementwise_copysign(f1, 2.0f);

  // CHECK:      [[F1:%.+]] = load float, ptr %f1.addr
  // CHECK-NEXT: call float @llvm.copysign.f32(float 2.000000e+00, float [[F1]])
  f1 = __builtin_elementwise_copysign(2.0f, f1);

  // CHECK:      [[V2F64:%.+]] = load <2 x double>, ptr %v2f64.addr, align 16
  // CHECK-NEXT: call <2 x double> @llvm.copysign.v2f64(<2 x double> splat (double 1.000000e+00), <2 x double> [[V2F64]])
  v2f64 = __builtin_elementwise_copysign((double2)1.0, v2f64);
}

void test_builtin_elementwise_fma(float f32, double f64,
                                  float2 v2f32, float4 v4f32,
                                  double2 v2f64, double3 v3f64,
                                  const float4 c_v4f32,
                                  half f16, half2 v2f16) {
  // CHECK-LABEL: define void @test_builtin_elementwise_fma(
  // CHECK:      [[F32_0:%.+]] = load float, ptr %f32.addr
  // CHECK-NEXT: [[F32_1:%.+]] = load float, ptr %f32.addr
  // CHECK-NEXT: [[F32_2:%.+]] = load float, ptr %f32.addr
  // CHECK-NEXT: call float @llvm.fma.f32(float [[F32_0]], float [[F32_1]], float [[F32_2]])
  float f2 = __builtin_elementwise_fma(f32, f32, f32);

  // CHECK:      [[F64_0:%.+]] = load double, ptr %f64.addr
  // CHECK-NEXT: [[F64_1:%.+]] = load double, ptr %f64.addr
  // CHECK-NEXT: [[F64_2:%.+]] = load double, ptr %f64.addr
  // CHECK-NEXT: call double @llvm.fma.f64(double [[F64_0]], double [[F64_1]], double [[F64_2]])
  double d2 = __builtin_elementwise_fma(f64, f64, f64);

  // CHECK:      [[V4F32_0:%.+]] = load <4 x float>, ptr %v4f32.addr
  // CHECK-NEXT: [[V4F32_1:%.+]] = load <4 x float>, ptr %v4f32.addr
  // CHECK-NEXT: [[V4F32_2:%.+]] = load <4 x float>, ptr %v4f32.addr
  // CHECK-NEXT: call <4 x float> @llvm.fma.v4f32(<4 x float> [[V4F32_0]], <4 x float> [[V4F32_1]], <4 x float> [[V4F32_2]])
  float4 tmp_v4f32 = __builtin_elementwise_fma(v4f32, v4f32, v4f32);


  // FIXME: Are we really still doing the 3 vector load workaround
  // CHECK:      [[V3F64_LOAD_0:%.+]] = load <4 x double>, ptr %v3f64.addr
  // CHECK-NEXT: [[V3F64_0:%.+]] = shufflevector
  // CHECK-NEXT: [[V3F64_LOAD_1:%.+]] = load <4 x double>, ptr %v3f64.addr
  // CHECK-NEXT: [[V3F64_1:%.+]] = shufflevector
  // CHECK-NEXT: [[V3F64_LOAD_2:%.+]] = load <4 x double>, ptr %v3f64.addr
  // CHECK-NEXT: [[V3F64_2:%.+]] = shufflevector
    // CHECK-NEXT: call <3 x double> @llvm.fma.v3f64(<3 x double> [[V3F64_0]], <3 x double> [[V3F64_1]], <3 x double> [[V3F64_2]])
  v3f64 = __builtin_elementwise_fma(v3f64, v3f64, v3f64);

  // CHECK:      [[F64_0:%.+]] = load double, ptr %f64.addr
  // CHECK-NEXT: [[F64_1:%.+]] = load double, ptr %f64.addr
  // CHECK-NEXT: [[F64_2:%.+]] = load double, ptr %f64.addr
  // CHECK-NEXT: call double @llvm.fma.f64(double [[F64_0]], double [[F64_1]], double [[F64_2]])
  v2f64 = __builtin_elementwise_fma(f64, f64, f64);

  // CHECK:      [[V4F32_0:%.+]] = load <4 x float>, ptr %c_v4f32.addr
  // CHECK-NEXT: [[V4F32_1:%.+]] = load <4 x float>, ptr %c_v4f32.addr
  // CHECK-NEXT: [[V4F32_2:%.+]] = load <4 x float>, ptr %c_v4f32.addr
  // CHECK-NEXT: call <4 x float> @llvm.fma.v4f32(<4 x float> [[V4F32_0]], <4 x float> [[V4F32_1]], <4 x float> [[V4F32_2]])
  v4f32 = __builtin_elementwise_fma(c_v4f32, c_v4f32, c_v4f32);

  // CHECK:      [[F16_0:%.+]] = load half, ptr %f16.addr
  // CHECK-NEXT: [[F16_1:%.+]] = load half, ptr %f16.addr
  // CHECK-NEXT: [[F16_2:%.+]] = load half, ptr %f16.addr
  // CHECK-NEXT: call half @llvm.fma.f16(half [[F16_0]], half [[F16_1]], half [[F16_2]])
  half tmp_f16 = __builtin_elementwise_fma(f16, f16, f16);

  // CHECK:      [[V2F16_0:%.+]] = load <2 x half>, ptr %v2f16.addr
  // CHECK-NEXT: [[V2F16_1:%.+]] = load <2 x half>, ptr %v2f16.addr
  // CHECK-NEXT: [[V2F16_2:%.+]] = load <2 x half>, ptr %v2f16.addr
  // CHECK-NEXT: call <2 x half> @llvm.fma.v2f16(<2 x half> [[V2F16_0]], <2 x half> [[V2F16_1]], <2 x half> [[V2F16_2]])
  half2 tmp0_v2f16 = __builtin_elementwise_fma(v2f16, v2f16, v2f16);

  // CHECK:      [[V2F16_0:%.+]] = load <2 x half>, ptr %v2f16.addr
  // CHECK-NEXT: [[V2F16_1:%.+]] = load <2 x half>, ptr %v2f16.addr
  // CHECK-NEXT: [[F16_2:%.+]] = load half, ptr %f16.addr
  // CHECK-NEXT: [[V2F16_2_INSERT:%.+]] = insertelement
  // CHECK-NEXT: [[V2F16_2:%.+]] = shufflevector <2 x half> [[V2F16_2_INSERT]], <2 x half> poison, <2 x i32> zeroinitializer
  // CHECK-NEXT: call <2 x half> @llvm.fma.v2f16(<2 x half> [[V2F16_0]], <2 x half> [[V2F16_1]], <2 x half> [[V2F16_2]])
  half2 tmp1_v2f16 = __builtin_elementwise_fma(v2f16, v2f16, (half2)f16);

  // CHECK:      [[V2F16_0:%.+]] = load <2 x half>, ptr %v2f16.addr
  // CHECK-NEXT: [[V2F16_1:%.+]] = load <2 x half>, ptr %v2f16.addr
  // CHECK-NEXT: call <2 x half> @llvm.fma.v2f16(<2 x half> [[V2F16_0]], <2 x half> [[V2F16_1]], <2 x half> splat (half 4.000000e+00))
  half2 tmp2_v2f16 = __builtin_elementwise_fma(v2f16, v2f16, (half2)4.0);

}

void test_builtin_elementwise_fshl(long long int i1, long long int i2,
				   long long int i3, unsigned short us1,
                                   unsigned short us2, unsigned short us3,
                                   char c1, char c2, char c3,
                                   unsigned char uc1, unsigned char uc2,
                                   unsigned char uc3,  si8 vi1, si8 vi2,
                                   si8 vi3, u4 vu1, u4 vu2, u4 vu3) {
  // CHECK:      [[I1:%.+]] = load i64, ptr %i1.addr
  // CHECK-NEXT: [[I2:%.+]] = load i64, ptr %i2.addr
  // CHECK-NEXT: [[I3:%.+]] = load i64, ptr %i3.addr
  // CHECK-NEXT: [[I4:%.+]] = call i64 @llvm.fshl.i64(i64 [[I1]], i64 [[I2]], i64 [[I3]])
  // CHECK-NEXT:              store i64 [[I4]], ptr %tmp_lli_l
  // CHECK-NEXT: [[I5:%.+]] = load i64, ptr %i1.addr
  // CHECK-NEXT: [[I6:%.+]] = load i64, ptr %i2.addr
  // CHECK-NEXT: [[I7:%.+]] = load i64, ptr %i3.addr
  // CHECK-NEXT: [[I8:%.+]] = call i64 @llvm.fshr.i64(i64 [[I5]], i64 [[I6]], i64 [[I7]])
  // CHECK-NEXT:              store i64 [[I8]], ptr %tmp_lli_r
  long long int tmp_lli_l = __builtin_elementwise_fshl(i1, i2, i3);
  long long int tmp_lli_r = __builtin_elementwise_fshr(i1, i2, i3);

  // CHECK:      [[US1:%.+]] = load i16, ptr %us1.addr
  // CHECK-NEXT: [[US2:%.+]] = load i16, ptr %us2.addr
  // CHECK-NEXT: [[US3:%.+]] = load i16, ptr %us3.addr
  // CHECK-NEXT: [[US4:%.+]] = call i16 @llvm.fshl.i16(i16 [[US1]], i16 [[US2]], i16 [[US3]])
  // CHECK-NEXT:               store i16 [[US4]], ptr %tmp_usi_l
  // CHECK-NEXT: [[US5:%.+]] = load i16, ptr %us1.addr
  // CHECK-NEXT: [[US6:%.+]] = load i16, ptr %us2.addr
  // CHECK-NEXT: [[US7:%.+]] = load i16, ptr %us3.addr
  // CHECK-NEXT: [[US8:%.+]] = call i16 @llvm.fshr.i16(i16 [[US5]], i16 [[US6]], i16 [[US7]])
  // CHECK-NEXT:               store i16 [[US8]], ptr %tmp_usi_r
  unsigned short tmp_usi_l = __builtin_elementwise_fshl(us1, us2, us3);
  unsigned short tmp_usi_r = __builtin_elementwise_fshr(us1, us2, us3);

  // CHECK:      [[C1:%.+]] = load i8, ptr %c1.addr
  // CHECK-NEXT: [[C2:%.+]] = load i8, ptr %c2.addr
  // CHECK-NEXT: [[C3:%.+]] = load i8, ptr %c3.addr
  // CHECK-NEXT: [[C4:%.+]] = call i8 @llvm.fshl.i8(i8 [[C1]], i8 [[C2]], i8 [[C3]])
  // CHECK-NEXT:              store i8 [[C4]], ptr %tmp_c_l
  // CHECK-NEXT: [[C5:%.+]] = load i8, ptr %c1.addr
  // CHECK-NEXT: [[C6:%.+]] = load i8, ptr %c2.addr
  // CHECK-NEXT: [[C7:%.+]] = load i8, ptr %c3.addr
  // CHECK-NEXT: [[C8:%.+]] = call i8 @llvm.fshr.i8(i8 [[C5]], i8 [[C6]], i8 [[C7]])
  // CHECK-NEXT:              store i8 [[C8]], ptr %tmp_c_r
  char tmp_c_l = __builtin_elementwise_fshl(c1, c2, c3);
  char tmp_c_r = __builtin_elementwise_fshr(c1, c2, c3);

  // CHECK:      [[UC1:%.+]] = load i8, ptr %uc1.addr
  // CHECK-NEXT: [[UC2:%.+]] = load i8, ptr %uc2.addr
  // CHECK-NEXT: [[UC3:%.+]] = load i8, ptr %uc3.addr
  // CHECK-NEXT: [[UC4:%.+]] = call i8 @llvm.fshl.i8(i8 [[UC1]], i8 [[UC2]], i8 [[UC3]])
  // CHECK-NEXT:               store i8 [[UC4]], ptr %tmp_uc_l
  // CHECK-NEXT: [[UC5:%.+]] = load i8, ptr %uc1.addr
  // CHECK-NEXT: [[UC6:%.+]] = load i8, ptr %uc2.addr
  // CHECK-NEXT: [[UC7:%.+]] = load i8, ptr %uc3.addr
  // CHECK-NEXT: [[UC8:%.+]] = call i8 @llvm.fshr.i8(i8 [[UC5]], i8 [[UC6]], i8 [[UC7]])
  // CHECK-NEXT:               store i8 [[UC8]], ptr %tmp_uc_r
  unsigned char tmp_uc_l = __builtin_elementwise_fshl(uc1, uc2, uc3);
  unsigned char tmp_uc_r = __builtin_elementwise_fshr(uc1, uc2, uc3);

  // CHECK:      [[VI1:%.+]] = load <8 x i16>, ptr %vi1.addr
  // CHECK-NEXT: [[VI2:%.+]] = load <8 x i16>, ptr %vi2.addr
  // CHECK-NEXT: [[VI3:%.+]] = load <8 x i16>, ptr %vi3.addr
  // CHECK-NEXT: [[VI4:%.+]] = call <8 x i16> @llvm.fshl.v8i16(<8 x i16> [[VI1]], <8 x i16> [[VI2]], <8 x i16> [[VI3]])
  // CHECK-NEXT:               store <8 x i16> [[VI4]], ptr %tmp_vi_l
  // CHECK-NEXT: [[VI5:%.+]] = load <8 x i16>, ptr %vi1.addr
  // CHECK-NEXT: [[VI6:%.+]] = load <8 x i16>, ptr %vi2.addr
  // CHECK-NEXT: [[VI7:%.+]] = load <8 x i16>, ptr %vi3.addr
  // CHECK-NEXT: [[VI8:%.+]] = call <8 x i16> @llvm.fshr.v8i16(<8 x i16> [[VI5]], <8 x i16> [[VI6]], <8 x i16> [[VI7]])
  // CHECK-NEXT:               store <8 x i16> [[VI8]], ptr %tmp_vi_r
  si8 tmp_vi_l = __builtin_elementwise_fshl(vi1, vi2, vi3);
  si8 tmp_vi_r = __builtin_elementwise_fshr(vi1, vi2, vi3);

  // CHECK:      [[VU1:%.+]] = load <4 x i32>, ptr %vu1.addr
  // CHECK-NEXT: [[VU2:%.+]] = load <4 x i32>, ptr %vu2.addr
  // CHECK-NEXT: [[VU3:%.+]] = load <4 x i32>, ptr %vu3.addr
  // CHECK-NEXT: [[VU4:%.+]] = call <4 x i32> @llvm.fshl.v4i32(<4 x i32> [[VU1]], <4 x i32> [[VU2]], <4 x i32> [[VU3]])
  // CHECK-NEXT:               store <4 x i32> [[VU4]], ptr %tmp_vu_l
  // CHECK-NEXT: [[VU5:%.+]] = load <4 x i32>, ptr %vu1.addr
  // CHECK-NEXT: [[VU6:%.+]] = load <4 x i32>, ptr %vu2.addr
  // CHECK-NEXT: [[VU7:%.+]] = load <4 x i32>, ptr %vu3.addr
  // CHECK-NEXT: [[VU8:%.+]] = call <4 x i32> @llvm.fshr.v4i32(<4 x i32> [[VU5]], <4 x i32> [[VU6]], <4 x i32> [[VU7]])
  // CHECK-NEXT:               store <4 x i32> [[VU8]], ptr %tmp_vu_r
  u4 tmp_vu_l = __builtin_elementwise_fshl(vu1, vu2, vu3);
  u4 tmp_vu_r = __builtin_elementwise_fshr(vu1, vu2, vu3);
}

void test_builtin_elementwise_clmul(unsigned int ui1, unsigned int ui2,
                                    unsigned short us1, unsigned short us2,
                                    u4 vu1, u4 vu2,
                                    unsigned _BitInt(31) bi1,
                                    unsigned _BitInt(31) bi2) {
  // CHECK:      [[UI1:%.+]] = load i32, ptr %ui1.addr, align 4
  // CHECK-NEXT: [[UI2:%.+]] = load i32, ptr %ui2.addr, align 4
  // CHECK-NEXT: [[UI3:%.+]] = call i32 @llvm.clmul.i32(i32 [[UI1]], i32 [[UI2]])
  // CHECK-NEXT: store i32 [[UI3]], ptr %ui1.addr, align 4
  ui1 = __builtin_elementwise_clmul(ui1, ui2);

  // CHECK:      [[US1:%.+]] = load i16, ptr %us1.addr, align 2
  // CHECK-NEXT: [[US2:%.+]] = load i16, ptr %us2.addr, align 2
  // CHECK-NEXT: [[US3:%.+]] = call i16 @llvm.clmul.i16(i16 [[US1]], i16 [[US2]])
  // CHECK-NEXT: store i16 [[US3]], ptr %us1.addr, align 2
  us1 = __builtin_elementwise_clmul(us1, us2);

  // CHECK:      [[VU1:%.+]] = load <4 x i32>, ptr %vu1.addr, align 16
  // CHECK-NEXT: [[VU2:%.+]] = load <4 x i32>, ptr %vu2.addr, align 16
  // CHECK-NEXT: [[VU3:%.+]] = call <4 x i32> @llvm.clmul.v4i32(<4 x i32> [[VU1]], <4 x i32> [[VU2]])
  // CHECK-NEXT: store <4 x i32> [[VU3]], ptr %vu1.addr, align 16
  vu1 = __builtin_elementwise_clmul(vu1, vu2);

  // CHECK:      [[BI1:%.+]] = load i32, ptr %bi1.addr, align 4
  // CHECK-NEXT: [[BI1TRUNC:%.+]] = trunc i32 [[BI1]] to i31
  // CHECK-NEXT: [[BI2:%.+]] = load i32, ptr %bi2.addr, align 4
  // CHECK-NEXT: [[BI2TRUNC:%.+]] = trunc i32 [[BI2]] to i31
  // CHECK-NEXT: [[BIRES:%.+]] = call i31 @llvm.clmul.i31(i31 [[BI1TRUNC]], i31 [[BI2TRUNC]])
  // CHECK-NEXT: [[BIRESZEXT:%.+]] = zext i31 [[BIRES]] to i32
  // CHECK-NEXT: store i32 [[BIRESZEXT]], ptr %bi1.addr, align 4
  bi1 = __builtin_elementwise_clmul(bi1, bi2);
}

void test_builtin_elementwise_pext(unsigned int ui1, unsigned int ui2,
                                   unsigned short us1, unsigned short us2,
                                   u4 vu1, u4 vu2,
                                   unsigned _BitInt(31) bi1,
                                   unsigned _BitInt(31) bi2) {
  // CHECK:      [[UI1:%.+]] = load i32, ptr %ui1.addr, align 4
  // CHECK-NEXT: [[UI2:%.+]] = load i32, ptr %ui2.addr, align 4
  // CHECK-NEXT: [[UI3:%.+]] = call i32 @llvm.pext.i32(i32 [[UI1]], i32 [[UI2]])
  // CHECK-NEXT: store i32 [[UI3]], ptr %ui1.addr, align 4
  ui1 = __builtin_elementwise_pext(ui1, ui2);

  // CHECK:      [[US1:%.+]] = load i16, ptr %us1.addr, align 2
  // CHECK-NEXT: [[US2:%.+]] = load i16, ptr %us2.addr, align 2
  // CHECK-NEXT: [[US3:%.+]] = call i16 @llvm.pext.i16(i16 [[US1]], i16 [[US2]])
  // CHECK-NEXT: store i16 [[US3]], ptr %us1.addr, align 2
  us1 = __builtin_elementwise_pext(us1, us2);

  // CHECK:      [[VU1:%.+]] = load <4 x i32>, ptr %vu1.addr, align 16
  // CHECK-NEXT: [[VU2:%.+]] = load <4 x i32>, ptr %vu2.addr, align 16
  // CHECK-NEXT: [[VU3:%.+]] = call <4 x i32> @llvm.pext.v4i32(<4 x i32> [[VU1]], <4 x i32> [[VU2]])
  // CHECK-NEXT: store <4 x i32> [[VU3]], ptr %vu1.addr, align 16
  vu1 = __builtin_elementwise_pext(vu1, vu2);

  // CHECK:      [[BI1:%.+]] = load i32, ptr %bi1.addr, align 4
  // CHECK-NEXT: [[BI1TRUNC:%.+]] = trunc i32 [[BI1]] to i31
  // CHECK-NEXT: [[BI2:%.+]] = load i32, ptr %bi2.addr, align 4
  // CHECK-NEXT: [[BI2TRUNC:%.+]] = trunc i32 [[BI2]] to i31
  // CHECK-NEXT: [[BIRES:%.+]] = call i31 @llvm.pext.i31(i31 [[BI1TRUNC]], i31 [[BI2TRUNC]])
  // CHECK-NEXT: [[BIRESZEXT:%.+]] = zext i31 [[BIRES]] to i32
  // CHECK-NEXT: store i32 [[BIRESZEXT]], ptr %bi1.addr, align 4
  bi1 = __builtin_elementwise_pext(bi1, bi2);
}

void test_builtin_elementwise_pdep(unsigned int ui1, unsigned int ui2,
                                   unsigned short us1, unsigned short us2,
                                   u4 vu1, u4 vu2,
                                   unsigned _BitInt(31) bi1,
                                   unsigned _BitInt(31) bi2) {
  // CHECK:      [[UI1:%.+]] = load i32, ptr %ui1.addr, align 4
  // CHECK-NEXT: [[UI2:%.+]] = load i32, ptr %ui2.addr, align 4
  // CHECK-NEXT: [[UI3:%.+]] = call i32 @llvm.pdep.i32(i32 [[UI1]], i32 [[UI2]])
  // CHECK-NEXT: store i32 [[UI3]], ptr %ui1.addr, align 4
  ui1 = __builtin_elementwise_pdep(ui1, ui2);

  // CHECK:      [[US1:%.+]] = load i16, ptr %us1.addr, align 2
  // CHECK-NEXT: [[US2:%.+]] = load i16, ptr %us2.addr, align 2
  // CHECK-NEXT: [[US3:%.+]] = call i16 @llvm.pdep.i16(i16 [[US1]], i16 [[US2]])
  // CHECK-NEXT: store i16 [[US3]], ptr %us1.addr, align 2
  us1 = __builtin_elementwise_pdep(us1, us2);

  // CHECK:      [[VU1:%.+]] = load <4 x i32>, ptr %vu1.addr, align 16
  // CHECK-NEXT: [[VU2:%.+]] = load <4 x i32>, ptr %vu2.addr, align 16
  // CHECK-NEXT: [[VU3:%.+]] = call <4 x i32> @llvm.pdep.v4i32(<4 x i32> [[VU1]], <4 x i32> [[VU2]])
  // CHECK-NEXT: store <4 x i32> [[VU3]], ptr %vu1.addr, align 16
  vu1 = __builtin_elementwise_pdep(vu1, vu2);

  // CHECK:      [[BI1:%.+]] = load i32, ptr %bi1.addr, align 4
  // CHECK-NEXT: [[BI1TRUNC:%.+]] = trunc i32 [[BI1]] to i31
  // CHECK-NEXT: [[BI2:%.+]] = load i32, ptr %bi2.addr, align 4
  // CHECK-NEXT: [[BI2TRUNC:%.+]] = trunc i32 [[BI2]] to i31
  // CHECK-NEXT: [[BIRES:%.+]] = call i31 @llvm.pdep.i31(i31 [[BI1TRUNC]], i31 [[BI2TRUNC]])
  // CHECK-NEXT: [[BIRESZEXT:%.+]] = zext i31 [[BIRES]] to i32
  // CHECK-NEXT: store i32 [[BIRESZEXT]], ptr %bi1.addr, align 4
  bi1 = __builtin_elementwise_pdep(bi1, bi2);
}

void test_builtin_elementwise_clzg(si8 vs1, si8 vs2, u4 vu1,
                                   long long int lli, short si,
                                   _BitInt(31) bi, int i,
                                   char ci) {
  // CHECK:      [[V8S1:%.+]] = load <8 x i16>, ptr %vs1.addr
  // CHECK-NEXT: call <8 x i16> @llvm.ctlz.v8i16(<8 x i16> [[V8S1]], i1 true)
  vs1 = __builtin_elementwise_clzg(vs1);

  // CHECK:      [[V8S1:%.+]] = load <8 x i16>, ptr %vs1.addr
  // CHECK-NEXT: [[CLZ:%.+]] = call <8 x i16> @llvm.ctlz.v8i16(<8 x i16> [[V8S1]], i1 true)
  // CHECK-NEXT: [[ISZERO:%.+]] = icmp eq <8 x i16> [[V8S1]], zeroinitializer
  // CHECK-NEXT: [[V8S2:%.+]] = load <8 x i16>, ptr %vs2.addr
  // select <8 x i1> [[ISZERO]], <8 x i16> [[CLZ]], <8 x i16> [[V8S2]]
  vs1 = __builtin_elementwise_clzg(vs1, vs2);

  // CHECK:      [[V4U1:%.+]] = load <4 x i32>, ptr %vu1.addr
  // CHECK-NEXT: call <4 x i32> @llvm.ctlz.v4i32(<4 x i32> [[V4U1]], i1 true)
  vu1 = __builtin_elementwise_clzg(vu1);

  // CHECK:      [[LLI:%.+]] = load i64, ptr %lli.addr
  // CHECK-NEXT: call i64 @llvm.ctlz.i64(i64 [[LLI]], i1 true)
  lli = __builtin_elementwise_clzg(lli);

  // CHECK:      [[SI:%.+]] = load i16, ptr %si.addr
  // CHECK-NEXT: call i16 @llvm.ctlz.i16(i16 [[SI]], i1 true)
  si = __builtin_elementwise_clzg(si);

  // CHECK:      [[BI1:%.+]] = load i32, ptr %bi.addr
  // CHECK-NEXT: [[BI2:%.+]] = trunc i32 [[BI1]] to i31
  // CHECK-NEXT: call i31 @llvm.ctlz.i31(i31 [[BI2]], i1 true)
  bi = __builtin_elementwise_clzg(bi);

  // CHECK:      [[BI1:%.+]] = load i32, ptr %bi.addr
  // CHECK-NEXT: [[BI2:%.+]] = trunc i32 [[BI1]] to i31
  // CHECK-NEXT: [[CLZ:%.+]] = call i31 @llvm.ctlz.i31(i31 [[BI2]], i1 true)
  // CHECK-NEXT: [[ISZERO:%.+]] = icmp eq i31 [[BI2]], 0
  // CHECK-NEXT: select i1 [[ISZERO]], i31 1, i31 [[CLZ]]
  bi = __builtin_elementwise_clzg(bi, (_BitInt(31))1);

  // CHECK:      [[I:%.+]] = load i32, ptr %i.addr
  // CHECK-NEXT: call i32 @llvm.ctlz.i32(i32 [[I]], i1 true)
  i = __builtin_elementwise_clzg(i);

  // CHECK:      [[CI:%.+]] = load i8, ptr %ci.addr
  // CHECK-NEXT: call i8 @llvm.ctlz.i8(i8 [[CI]], i1 true)
  ci = __builtin_elementwise_clzg(ci);
}

void test_builtin_elementwise_ctzg(si8 vs1, si8 vs2, u4 vu1,
                                   long long int lli, short si,
                                   _BitInt(31) bi, int i,
                                   char ci) {
  // CHECK:      [[V8S1:%.+]] = load <8 x i16>, ptr %vs1.addr
  // CHECK-NEXT: call <8 x i16> @llvm.cttz.v8i16(<8 x i16> [[V8S1]], i1 true)
  vs1 = __builtin_elementwise_ctzg(vs1);

  // CHECK:      [[V8S1:%.+]] = load <8 x i16>, ptr %vs1.addr
  // CHECK-NEXT: [[ctz:%.+]] = call <8 x i16> @llvm.cttz.v8i16(<8 x i16> [[V8S1]], i1 true)
  // CHECK-NEXT: [[ISZERO:%.+]] = icmp eq <8 x i16> [[V8S1]], zeroinitializer
  // CHECK-NEXT: [[V8S2:%.+]] = load <8 x i16>, ptr %vs2.addr
  // select <8 x i1> [[ISZERO]], <8 x i16> [[ctz]], <8 x i16> [[V8S2]]
  vs1 = __builtin_elementwise_ctzg(vs1, vs2);

  // CHECK:      [[V4U1:%.+]] = load <4 x i32>, ptr %vu1.addr
  // CHECK-NEXT: call <4 x i32> @llvm.cttz.v4i32(<4 x i32> [[V4U1]], i1 true)
  vu1 = __builtin_elementwise_ctzg(vu1);

  // CHECK:      [[LLI:%.+]] = load i64, ptr %lli.addr
  // CHECK-NEXT: call i64 @llvm.cttz.i64(i64 [[LLI]], i1 true)
  lli = __builtin_elementwise_ctzg(lli);

  // CHECK:      [[SI:%.+]] = load i16, ptr %si.addr
  // CHECK-NEXT: call i16 @llvm.cttz.i16(i16 [[SI]], i1 true)
  si = __builtin_elementwise_ctzg(si);

  // CHECK:      [[BI1:%.+]] = load i32, ptr %bi.addr
  // CHECK-NEXT: [[BI2:%.+]] = trunc i32 [[BI1]] to i31
  // CHECK-NEXT: call i31 @llvm.cttz.i31(i31 [[BI2]], i1 true)
  bi = __builtin_elementwise_ctzg(bi);

  // CHECK:      [[BI1:%.+]] = load i32, ptr %bi.addr
  // CHECK-NEXT: [[BI2:%.+]] = trunc i32 [[BI1]] to i31
  // CHECK-NEXT: [[ctz:%.+]] = call i31 @llvm.cttz.i31(i31 [[BI2]], i1 true)
  // CHECK-NEXT: [[ISZERO:%.+]] = icmp eq i31 [[BI2]], 0
  // CHECK-NEXT: select i1 [[ISZERO]], i31 1, i31 [[ctz]]
  bi = __builtin_elementwise_ctzg(bi, (_BitInt(31))1);

  // CHECK:      [[I:%.+]] = load i32, ptr %i.addr
  // CHECK-NEXT: call i32 @llvm.cttz.i32(i32 [[I]], i1 true)
  i = __builtin_elementwise_ctzg(i);

  // CHECK:      [[CI:%.+]] = load i8, ptr %ci.addr
  // CHECK-NEXT: call i8 @llvm.cttz.i8(i8 [[CI]], i1 true)
  ci = __builtin_elementwise_ctzg(ci);
}

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

static int b64val(unsigned char c) {
    if (c >= 'A' && c <= 'Z') return c - 'A';
    if (c >= 'a' && c <= 'z') return c - 'a' + 26;
    if (c >= '0' && c <= '9') return c - '0' + 52;
    if (c == '+') return 62;
    if (c == '/') return 63;
    return -1;
}

static void decode_q(const unsigned char *in, size_t len, char *out, size_t *outlen) {
    size_t i = 0, o = 0;
    while (i < len) {
        unsigned char c = in[i++];
        if (c == '_') out[o++] = ' ';
        else if (c == '=' && i + 1 < len) {
            unsigned char h1 = in[i], h2 = in[i + 1];
            int v1 = (h1 >= '0' && h1 <= '9') ? h1 - '0' : (h1 >= 'A' && h1 <= 'F') ? h1 - 'A' + 10 : (h1 >= 'a' && h1 <= 'f') ? h1 - 'a' + 10 : -1;
            int v2 = (h2 >= '0' && h2 <= '9') ? h2 - '0' : (h2 >= 'A' && h2 <= 'F') ? h2 - 'A' + 10 : (h2 >= 'a' && h2 <= 'f') ? h2 - 'a' + 10 : -1;
            if (v1 >= 0 && v2 >= 0) {
                out[o++] = (char)((v1 << 4) | v2);
                i += 2;
            } else {
                out[o++] = '=';
            }
        } else {
            out[o++] = (char)c;
        }
    }
    out[o] = 0;
    *outlen = o;
}

static int decode_b(const unsigned char *in, size_t len, char *out, size_t *outlen) {
    int val = 0, bits = 0;
    size_t o = 0, i;
    for (i = 0; i < len; i++) {
        int v = b64val(in[i]);
        if (in[i] == '=') break;
        if (v < 0) return -1;
        val = (val << 6) | v;
        bits += 6;
        if (bits >= 8) {
            bits -= 8;
            out[o++] = (char)((val >> bits) & 0xFF);
        }
    }
    out[o] = 0;
    *outlen = o;
    return 0;
}

static void mime_decode(const char *s, int continue_on_error) {
    const char *p = strstr(s, "=?");
    if (!p) {
        puts(s);
        return;
    }
    const char *q = strstr(p + 2, "?");
    if (!q) {
        puts(s);
        return;
    }
    const char *r = strstr(q + 1, "?");
    if (!r) {
        puts(s);
        return;
    }
    const char *e = strstr(r + 1, "?=");
    if (!e) {
        puts(s);
        return;
    }

    char enc = q[1];
    const unsigned char *data = (const unsigned char *)(r + 1);
    size_t len = (size_t)(e - (r + 1));
    char decoded[256];
    size_t outlen = 0;
    int ok = 1;

    if (enc == 'B' || enc == 'b') {
        if (decode_b(data, len, decoded, &outlen) != 0) ok = 0;
    } else if (enc == 'Q' || enc == 'q') {
        decode_q(data, len, decoded, &outlen);
    } else {
        ok = 0;
    }

    if (!ok && !continue_on_error) {
        puts(s);
        return;
    }

    if (ok) {
        fwrite(s, 1, (size_t)(p - s), stdout);
        fwrite(decoded, 1, outlen, stdout);
        fputs(e + 2, stdout);
        putchar('\n');
    } else {
        puts(s);
    }
}

int main(void) {
    const char *tests[] = {
        "Legal encoded-word: =?utf-8?B?Kg==?= .",
        "Legal encoded-word: =?utf-8?Q?*?= .",
        "Illegal encoded-word: =?utf-8?B?\xA1?= .",
        "Illegal encoded-word: =?utf-8?Q?\xA1?= ."
    };

    for (int i = 0; i < 4; i++) mime_decode(tests[i], 1);
    for (int i = 0; i < 4; i++) mime_decode(tests[i], 0);
    return 0;
}
```

Resulted in this output:

```
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpfgy_d3_w/38538121.c:352:8: warning: builtin '__builtin_elementwise_max' is deprecated [-Wdeprecated-builtins]
  352 |   f1 = __builtin_elementwise_max(f1, f2);
      |        ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpfgy_d3_w/38538121.c:357:8: warning: builtin '__builtin_elementwise_max' is deprecated [-Wdeprecated-builtins]
  357 |   d1 = __builtin_elementwise_max(d1, d2);
      |        ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpfgy_d3_w/38538121.c:361:8: warning: builtin '__builtin_elementwise_max' is deprecated [-Wdeprecated-builtins]
  361 |   d1 = __builtin_elementwise_max(20.0, d2);
      |        ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpfgy_d3_w/38538121.c:366:9: warning: builtin '__builtin_elementwise_max' is deprecated [-Wdeprecated-builtins]
  366 |   vf1 = __builtin_elementwise_max(vf1, vf2);
      |         ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpfgy_d3_w/38538121.c:410:9: warning: builtin '__builtin_elementwise_max' is deprecated [-Wdeprecated-builtins]
  410 |   vf1 = __builtin_elementwise_max(cvf1, vf2);
      |         ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpfgy_d3_w/38538121.c:415:9: warning: builtin '__builtin_elementwise_max' is deprecated [-Wdeprecated-builtins]
  415 |   vf1 = __builtin_elementwise_max(vf2, cvf1);
      |         ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpfgy_d3_w/38538121.c:436:8: warning: builtin '__builtin_elementwise_min' is deprecated [-Wdeprecated-builtins]
  436 |   f1 = __builtin_elementwise_min(f1, f2);
      |        ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpfgy_d3_w/38538121.c:441:8: warning: builtin '__builtin_elementwise_min' is deprecated [-Wdeprecated-builtins]
  441 |   d1 = __builtin_elementwise_min(d1, d2);
      |        ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpfgy_d3_w/38538121.c:445:8: warning: builtin '__builtin_elementwise_min' is deprecated [-Wdeprecated-builtins]
  445 |   d1 = __builtin_elementwise_min(d1, 2.0);
      |        ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpfgy_d3_w/38538121.c:450:9: warning: builtin '__builtin_elementwise_min' is deprecated [-Wdeprecated-builtins]
  450 |   vf1 = __builtin_elementwise_min(vf1, vf2);
      |         ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpfgy_d3_w/38538121.c:501:9: warning: builtin '__builtin_elementwise_min' is deprecated [-Wdeprecated-builtins]
  501 |   vf1 = __builtin_elementwise_min(cvf1, vf2);
      |         ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpfgy_d3_w/38538121.c:506:9: warning: builtin '__builtin_elementwise_min' is deprecated [-Wdeprecated-builtins]
  506 |   vf1 = __builtin_elementwise_min(vf2, cvf1);
      |         ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpfgy_d3_w/38538121.c:1142:58: warning: AVX vector argument of type 'double3' (vector of 3 'double' values) without 'avx' enabled changes the ABI [-Wpsabi]
 1142 |                                   double2 v2f64, double3 v3f64,
      |                                                          ^
clang: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-project/llvm/lib/IR/Instructions.cpp:1232: void llvm::CondBrInst::AssertOK(): Assertion `getCondition()->getType()->isIntegerTy(1) && "May only branch on boolean predicates!"' failed.
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and dumped files.
Stack dump:
0.	Program arguments: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin/clang -c -o /dev/null -O0 -fsanitize=undefined -fno-inline -ffp-contract=fast /home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpfgy_d3_w/38538121.c
1.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpfgy_d3_w/38538121.c:1447:1: current parser token 'void'
2.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpfgy_d3_w/38538121.c:1399:6: LLVM IR generation of declaration 'test_builtin_elementwise_clzg'
3.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpfgy_d3_w/38538121.c:1399:6: Generating code for declaration 'test_builtin_elementwise_clzg'
Stack dump without symbol names (ensure you have llvm-symbolizer in your PATH or set the environment var `LLVM_SYMBOLIZER_PATH` to point to it):
0  clang     0x0000560df13520f9 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) + 121
1  clang     0x0000560df134edcc llvm::sys::RunSignalHandlers() + 76
2  clang     0x0000560df134f678 llvm::sys::CleanupOnSignal(unsigned long) + 216
3  clang     0x0000560df1291f88
4  libc.so.6 0x00007f7994248520
5  libc.so.6 0x00007f799429c9fc pthread_kill + 300
6  libc.so.6 0x00007f7994248476 raise + 22
7  libc.so.6 0x00007f799422e7f3 abort + 211
8  libc.so.6 0x00007f799422e71b
9  libc.so.6 0x00007f799423fe96
10 clang     0x0000560df0cf7950 llvm::CondBrInst::CondBrInst(llvm::Value*, llvm::BasicBlock*, llvm::BasicBlock*, llvm::InsertPosition) + 160
11 clang     0x0000560df167d28a clang::CodeGen::CodeGenFunction::EmitCheck(llvm::ArrayRef<std::pair<llvm::Value*, clang::SanitizerKind::SanitizerOrdinal>>, SanitizerHandler, llvm::ArrayRef<llvm::Constant*>, llvm::ArrayRef<llvm::Value*>, clang::CodeGen::TrapReason const*) + 1802
12 clang     0x0000560df1b761c4 clang::CodeGen::CodeGenFunction::EmitCheckedArgForBuiltin(clang::Expr const*, clang::CodeGen::CodeGenFunction::BuiltinCheckKind) + 420
13 clang     0x0000560df1b820f4 clang::CodeGen::CodeGenFunction::EmitBuiltinExpr(clang::GlobalDecl, unsigned int, clang::CallExpr const*, clang::CodeGen::ReturnValueSlot) + 8644
14 clang     0x0000560df16a28bb clang::CodeGen::CodeGenFunction::EmitCallExpr(clang::CallExpr const*, clang::CodeGen::ReturnValueSlot, llvm::CallBase**) + 859
15 clang     0x0000560df17143b4
16 clang     0x0000560df170b4bb
17 clang     0x0000560df1716e7b
18 clang     0x0000560df170f06d clang::CodeGen::CodeGenFunction::EmitScalarExpr(clang::Expr const*, bool) + 141
19 clang     0x0000560df16758de clang::CodeGen::CodeGenFunction::EmitAnyExpr(clang::Expr const*, clang::CodeGen::AggValueSlot, bool) + 238
20 clang     0x0000560df169c39a clang::CodeGen::CodeGenFunction::EmitIgnoredExpr(clang::Expr const*) + 282
21 clang     0x0000560df1842d34 clang::CodeGen::CodeGenFunction::EmitStmt(clang::Stmt const*, llvm::ArrayRef<clang::Attr const*>) + 388
22 clang     0x0000560df184afac clang::CodeGen::CodeGenFunction::EmitCompoundStmtWithoutScope(clang::CompoundStmt const&, bool, clang::CodeGen::AggValueSlot) + 92
23 clang     0x0000560df18b4e71 clang::CodeGen::CodeGenFunction::EmitFunctionBody(clang::Stmt const*) + 177
24 clang     0x0000560df18cbe24 clang::CodeGen::CodeGenFunction::GenerateCode(clang::GlobalDecl, llvm::Function*, clang::CodeGen::CGFunctionInfo const&) + 1444
25 clang     0x0000560df1934e8a clang::CodeGen::CodeGenModule::EmitGlobalFunctionDefinition(clang::GlobalDecl, llvm::GlobalValue*) + 2106
26 clang     0x0000560df192e944 clang::CodeGen::CodeGenModule::EmitGlobalDefinition(clang::GlobalDecl, llvm::GlobalValue*) + 580
27 clang     0x0000560df192f343 clang::CodeGen::CodeGenModule::EmitGlobal(clang::GlobalDecl) + 2403
28 clang     0x0000560df193a715
29 clang     0x0000560df1cdecb1
30 clang     0x0000560df1cce481 clang::BackendConsumer::HandleTopLevelDecl(clang::DeclGroupRef) + 209
31 clang     0x0000560df3acf6f4 clang::ParseAST(clang::Sema&, bool, bool) + 564
32 clang     0x0000560df2048071 clang::FrontendAction::Execute() + 65
33 clang     0x0000560df1fd1c65 clang::CompilerInstance::ExecuteAction(clang::FrontendAction&) + 1589
34 clang     0x0000560df2123ea3 clang::ExecuteCompilerInvocation(clang::CompilerInstance*) + 467
35 clang     0x0000560defd26c96 cc1_main(llvm::ArrayRef<char const*>, char const*, void*) + 7046
36 clang     0x0000560defd1ca2a
37 clang     0x0000560defd1cbbf
38 clang     0x0000560df1d5935d
39 clang     0x0000560df12923a0 llvm::CrashRecoveryContext::RunSafely(llvm::function_ref<void ()>) + 160
40 clang     0x0000560df1d5a1b3
41 clang     0x0000560df1d0f987 clang::driver::Compilation::ExecuteCommand(clang::driver::Command const&, clang::driver::Command const*&, bool) const + 167
42 clang     0x0000560df1d141e0 clang::driver::Compilation::ExecuteJobs(clang::driver::JobList const&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&, bool) const + 304
43 clang     0x0000560df1d21e44 clang::driver::Driver::ExecuteCompilation(clang::driver::Compilation&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&) + 404
44 clang     0x0000560defd222d3 clang_main(int, char**, llvm::ToolContext const&) + 7267
45 clang     0x0000560defc747a1 main + 113
46 libc.so.6 0x00007f799422fd90
47 libc.so.6 0x00007f799422fe40 __libc_start_main + 128
48 clang     0x0000560defd1c055 _start + 37
clang: error: clang frontend command failed due to signal (use -v to see invocation)
clang version 24.0.0git (https://github.com/llvm/llvm-project.git aefba88f46a6e55645c848f58f6ba56944d5ae62)
Target: x86_64-unknown-linux-gnu
Thread model: posix
InstalledDir: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin
Build config: +assertions
clang: note: diagnostic msg: Error generating preprocessed source(s).
Aborted (core dumped)
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ulimit -v 3145728; ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin/clang -c -o /dev/null -O0 -fsanitize=undefined -fno-inline -ffp-contract=fast "$SCRIPT_DIR/test.c"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `ab5465f1` | Project seed |
| `b` | `96ce9623` | Bug corpus (project: `php`, name: `bug51250.phpt`) |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
