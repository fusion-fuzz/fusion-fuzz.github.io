
// REQUIRES: powerpc-registered-target
// RUN: %clang_cc1 -triple powerpc-unknown-unknown -emit-llvm %s -o - \
// RUN:   | FileCheck %s
// RUN: %clang_cc1 -triple powerpc-unknown-unknown -emit-llvm %s -o - \
// RUN:   -target-cpu pwr9 | FileCheck %s --check-prefixes=P9,CHECK

void test_eh_return_data_regno()
{
  volatile int res;
  res = __builtin_eh_return_data_regno(0);  // CHECK: store volatile i32 3
  res = __builtin_eh_return_data_regno(1);  // CHECK: store volatile i32 4
}

// CHECK-LABEL: define{{.*}} i64 @test_builtin_ppc_get_timebase
long long test_builtin_ppc_get_timebase() {
  // CHECK: call i64 @llvm.readcyclecounter()
  return __builtin_ppc_get_timebase();
}

void test_builtin_ppc_setrnd() {
  volatile double res;
  volatile int x = 100;
  
  // CHECK: call double @llvm.ppc.setrnd(i32 2)
  res = __builtin_setrnd(2);

  // CHECK: call double @llvm.ppc.setrnd(i32 100)
  res = __builtin_setrnd(100);

  // CHECK: call double @llvm.ppc.setrnd(i32 %2)
  res = __builtin_setrnd(x);

  // CHECK: call double @llvm.ppc.setrnd(i32 %4)
  res = __builtin_ppc_set_fpscr_rn(x);
}

void test_builtin_ppc_flm() {
  volatile double res;
  // CHECK: call double @llvm.ppc.readflm()
  res = __builtin_readflm();

  // CHECK: call double @llvm.ppc.readflm()
  res = __builtin_ppc_mffs();

  // CHECK: call double @llvm.ppc.setflm(double %2)
  res = __builtin_setflm(res);

#ifdef _ARCH_PWR9
  // P9: call double @llvm.ppc.mffsl()
  res = __builtin_ppc_mffsl();
#endif
}

double test_builtin_unpack_ldbl(long double x) {
  // CHECK: call double @llvm.ppc.unpack.longdouble(ppc_fp128 %0, i32 1)
  return __builtin_unpack_longdouble(x, 1);
}

long double test_builtin_pack_ldbl(double x, double y) {
  // CHECK: call ppc_fp128 @llvm.ppc.pack.longdouble(double %0, double %1)
  return __builtin_pack_longdouble(x, y);
}

void test_builtin_ppc_maxminfe(long double a, long double b, long double c,
                               long double d) {
  volatile long double res;
  // CHECK: call ppc_fp128 (ppc_fp128, ppc_fp128, ppc_fp128, ...) @llvm.ppc.maxfe(ppc_fp128 %0, ppc_fp128 %1, ppc_fp128 %2, ppc_fp128 %3)
  res = __builtin_ppc_maxfe(a, b, c, d);

  // CHECK: call ppc_fp128 (ppc_fp128, ppc_fp128, ppc_fp128, ...) @llvm.ppc.minfe(ppc_fp128 %5, ppc_fp128 %6, ppc_fp128 %7, ppc_fp128 %8)
  res = __builtin_ppc_minfe(a, b, c, d);
}

void test_builtin_ppc_maxminfl(double a, double b, double c, double d) {
  volatile double res;
  // CHECK: call double (double, double, double, ...) @llvm.ppc.maxfl(double %0, double %1, double %2, double %3)
  res = __builtin_ppc_maxfl(a, b, c, d);

  // CHECK: call double (double, double, double, ...) @llvm.ppc.minfl(double %5, double %6, double %7, double %8)
  res = __builtin_ppc_minfl(a, b, c, d);
}

void test_builtin_ppc_maxminfs(float a, float b, float c, float d) {
  volatile float res;
  // CHECK: call float (float, float, float, ...) @llvm.ppc.maxfs(float %0, float %1, float %2, float %3)
  res = __builtin_ppc_maxfs(a, b, c, d);

  // CHECK: call float (float, float, float, ...) @llvm.ppc.minfs(float %5, float %6, float %7, float %8)
  res = __builtin_ppc_minfs(a, b, c, d);
}

static long ffl_fusion = (long)(test_builtin_ppc_flm);

// RUN: %clang_cc1 -I%S %s -triple aarch64-linux-gnu -O1 -fptrauth-calls -fptrauth-vtable-pointer-address-discrimination  -fptrauth-vtable-pointer-type-discrimination -emit-llvm -std=c++11 -o - | FileCheck %s --check-prefixes=CHECK

struct A {
  virtual ~A();
};
struct B {
  int foo;
  virtual ~B();
};
struct C final : A, B {
  virtual void f(){};
};
struct D final : B, A {
  virtual void f(){};
};

struct Offset {
  virtual ~Offset();
};
struct E {
  virtual ~E();
};
struct F final : Offset, E {
};
struct G {
  virtual ~G();
  int g;
};
struct H : E {
  int h;
};
struct I : E {
  int i;
};
struct J : virtual E {
  int j;
};
struct K : virtual E {
  int k;
};
struct L final : G, H, I, J, K {
  int ffl_fusion;
};
struct M final: G, private H { int m; };

// CHECK-LABEL: @_Z10exact_to_CP1A
C *exact_to_C(A *a) {
  // CHECK: [[UNAUTHED_VPTR:%.*]] = load ptr, ptr %a, align 8
  // CHECK: [[VPTR_ADDRI:%.*]] = ptrtoint ptr %a to i64
  // CHECK: [[VPTR_ADDR_DISC:%.*]] = tail call i64 @llvm.ptrauth.blend(i64 [[VPTR_ADDRI]], i64 62866)
  // CHECK: [[UNAUTHED_VPTRI:%.*]] = ptrtoint ptr [[UNAUTHED_VPTR]] to i64
  // CHECK: [[AUTHED_VPTRI:%.*]] = tail call i64 @llvm.ptrauth.auth(i64 [[UNAUTHED_VPTRI]], i32 2, i64 [[VPTR_ADDR_DISC]])
  // CHECK: [[IS_EXPECTED:%.*]] = icmp eq i64 [[AUTHED_VPTRI]], ptrtoint (ptr getelementptr inbounds nuw inrange(-16, 24) (i8, ptr @_ZTV1C, i64 16) to i64)
  // CHECK: br i1 [[IS_EXPECTED]], label %dynamic_cast.end, label %dynamic_cast.null
  // CHECK: [[NULL_CHECKED_RESULT:%.*]] = phi ptr [ %a, %dynamic_cast.notnull ], [ null, %dynamic_cast.null ]
  // CHECK: ret ptr [[NULL_CHECKED_RESULT]]
  return dynamic_cast<C*>(a);
}

// CHECK-LABEL: @_Z9exact_t_DP1A
D *exact_t_D(A *a) {
  // CHECK: dynamic_cast.notnull:
  // CHECK:   [[SRC_UNAUTHED_VPTR:%.*]] = load ptr, ptr %a
  // CHECK:   [[SRC_VPTR_ADDRI:%.*]] = ptrtoint ptr %a to i64
  // CHECK:   [[SRC_VPTR_DISC:%.*]] = tail call i64 @llvm.ptrauth.blend(i64 [[SRC_VPTR_ADDRI]], i64 62866)
  // CHECK:   [[SRC_UNAUTHED_VPTRI:%.*]] = ptrtoint ptr [[SRC_UNAUTHED_VPTR]] to i64
  // CHECK:   [[SRC_AUTHED_VPTRI:%.*]] = tail call i64 @llvm.ptrauth.auth(i64 [[SRC_UNAUTHED_VPTRI]], i32 2, i64 [[SRC_VPTR_DISC]])
  // CHECK:   [[SUCCESS:%.*]] = icmp eq i64 [[SRC_AUTHED_VPTRI]], ptrtoint (ptr getelementptr inbounds nuw inrange(-16, 16) (i8, ptr @_ZTV1D, i64 56) to i64)
  // CHECK:   br i1 [[SUCCESS]], label %dynamic_cast.postauth.success, label %dynamic_cast.postauth.complete
  // CHECK: dynamic_cast.postauth.success:
  // CHECK:   [[ADJUSTED_THIS:%.*]] = getelementptr inbounds i8, ptr %a, i64 -16
  // CHECK:   [[ADJUSTED_UNAUTHED_VPTR:%.*]] = load ptr, ptr [[ADJUSTED_THIS]]
  // CHECK:   [[ADJUSTED_VPTR_ADDRI:%.*]] = ptrtoint ptr [[ADJUSTED_THIS]] to i64
  // CHECK:   [[ADJUSTED_VPTR_DISC:%.*]] = tail call i64 @llvm.ptrauth.blend(i64 [[ADJUSTED_VPTR_ADDRI]], i64 28965)
  // CHECK:   [[ADJUSTED_UNAUTHED_VPTRI:%.*]] = ptrtoint ptr [[ADJUSTED_UNAUTHED_VPTR]] to i64
  // CHECK:   [[ADJUSTED_AUTHED_VPTRI:%.*]] = tail call i64 @llvm.ptrauth.auth(i64 [[ADJUSTED_UNAUTHED_VPTRI]], i32 2, i64 [[ADJUSTED_VPTR_DISC]])
  // CHECK:   [[ADJUSTED_AUTHED_VPTR:%.*]] = inttoptr i64 [[ADJUSTED_AUTHED_VPTRI]] to ptr
  // CHECK:   br label %dynamic_cast.postauth.complete
  // CHECK: dynamic_cast.postauth.complete:
  // CHECK:   [[AUTHED_ADJUSTED_THIS:%.*]] = phi ptr [ [[ADJUSTED_THIS]], %dynamic_cast.postauth.success ], [ null, %dynamic_cast.notnull ]
  // CHECK:   br i1 [[SUCCESS]], label %dynamic_cast.end, label %dynamic_cast.null
  // CHECK: dynamic_cast.null:
  // CHECK:   br label %dynamic_cast.end
  // CHECK: dynamic_cast.end:
  // CHECK:   [[RESULT:%.*]] = phi ptr [ [[AUTHED_ADJUSTED_THIS]], %dynamic_cast.postauth.complete ], [ null, %dynamic_cast.null ]
  // CHECK:   ret ptr [[RESULT]]
  return dynamic_cast<D*>(a);
}

// CHECK-LABEL: @_Z11exact_multiP1E
L *exact_multi(E *e) {
  // CHECK: dynamic_cast.notnull:
  // CHECK:   [[VTABLE_ADDR:%.*]] = load ptr, ptr %e, align 8
  // CHECK:   [[THIS_ADDRI:%.*]] = ptrtoint ptr %e to i64
  // CHECK:   [[VTABLE_DISC:%.*]] = tail call i64 @llvm.ptrauth.blend(i64 [[THIS_ADDRI]], i64 12810)
  // CHECK:   [[VTABLE_ADDRI:%.*]] = ptrtoint ptr [[VTABLE_ADDR]] to i64
  // CHECK:   [[AUTHED_VTABLEI:%.*]] = tail call i64 @llvm.ptrauth.auth(i64 [[VTABLE_ADDRI]], i32 2, i64 [[VTABLE_DISC]])
  // CHECK:   [[AUTHED_VTABLE:%.*]] = inttoptr i64 [[AUTHED_VTABLEI]] to ptr
  // CHECK:   [[PRIMARY_BASE_OFFSET:%.*]] = getelementptr inbounds i8, ptr [[AUTHED_VTABLE]], i64 -16
  // CHECK:   %offset.to.top = load i64, ptr [[PRIMARY_BASE_OFFSET]]
  // CHECK:   [[ADJUSTED_THIS:%.*]] = getelementptr inbounds i8, ptr %e, i64 %offset.to.top
  // CHECK:   [[ADJUSTED_THIS_VTABLE:%.*]] = load ptr, ptr [[ADJUSTED_THIS]]
  // CHECK:   [[ADJUSTED_THIS_VTABLEI:%.*]] = ptrtoint ptr [[ADJUSTED_THIS_VTABLE]] to i64
  // CHECK:   [[ADJUSTED_THIS_STRIPPED_VTABLEI:%.*]] = tail call i64 @llvm.ptrauth.strip(i64 [[ADJUSTED_THIS_VTABLEI]], i32 0)
  // CHECK:   [[SUCCESS:%.*]] = icmp eq i64 [[ADJUSTED_THIS_STRIPPED_VTABLEI]], ptrtoint (ptr getelementptr inbounds nuw inrange(-24, 16) (i8, ptr @_ZTV1L, i64 24) to i64)
  // CHECK:   br i1 [[SUCCESS]], label %dynamic_cast.postauth.success, label %dynamic_cast.postauth.complete
  // CHECK: dynamic_cast.postauth.success:
  // CHECK:   [[ADJUSTED_THISI:%.*]] = ptrtoint ptr [[ADJUSTED_THIS]] to i64
  // CHECK:   [[DEST_DISC:%.*]] = tail call i64 @llvm.ptrauth.blend(i64 [[ADJUSTED_THISI]], i64 41434)
  // CHECK:   tail call i64 @llvm.ptrauth.auth(i64 [[ADJUSTED_THIS_VTABLEI]], i32 2, i64 [[DEST_DISC]])
  // CHECK:   br label %dynamic_cast.postauth.complete
  // CHECK: dynamic_cast.postauth.complete:
  // CHECK:   [[AUTHED_ADJUSTED_THIS:%.*]] = phi ptr [ [[ADJUSTED_THIS]], %dynamic_cast.postauth.success ], [ null, %dynamic_cast.notnull ]
  // CHECK:   br i1 [[SUCCESS]], label %dynamic_cast.end, label %dynamic_cast.null
  // CHECK: dynamic_cast.null:
  // CHECK:   br label %dynamic_cast.end
  // CHECK: dynamic_cast.end:
  // CHECK:   [[RESULT:%.*]] = phi ptr [ [[AUTHED_ADJUSTED_THIS]], %dynamic_cast.postauth.complete ], [ null, %dynamic_cast.null ]
  // CHECK:   ret ptr [[RESULT]]
  return dynamic_cast<L*>(e);
}

// CHECK-LABEL: @_Z19exact_invalid_multiP1H
M *exact_invalid_multi(H* d) {
  // CHECK: entry:
  // CHECK-NEXT:   ret ptr null
  return dynamic_cast<M*>(d);
}
