// RUN: %clang_cc1 %s -triple x86_64-unknown-linux-gnu -emit-llvm -target-cpu x86-64 -o - | FileCheck %s --check-prefixes=CHECK,SSE
// RUN: %clang_cc1 %s -triple x86_64-unknown-linux-gnu -emit-llvm -target-cpu skylake -D AVX -o - | FileCheck %s --check-prefixes AVX,SSE
// RUN: %clang_cc1 %s -triple x86_64-unknown-linux-gnu -emit-llvm -target-cpu skylake-avx512 -D AVX512 -D AVX -o - | FileCheck %s --check-prefixes AVX512,AVX,SSE
// RUN: %clang_cc1 %s -triple x86_64-unknown-linux-gnu -emit-llvm -target-cpu knl -D AVX -D AVX512 -o - | FileCheck %s --check-prefixes AVX512,AVX,SSE

typedef float __m128 __attribute__ ((vector_size (16)));
typedef float __m256 __attribute__ ((vector_size (32)));
typedef float __m512 __attribute__ ((vector_size (64)));

// SSE: call <4 x float> asm "vmovhlps $1, $2, $0", "=v,v,v,~{dirflag},~{fpsr},~{flags}"(i64 %0, <4 x float> %1)
__m128 testXMM(__m128 _xmm0, long _l) {
  __asm__("vmovhlps %1, %2, %0" :"=v"(_xmm0) : "v"(_l), "v"(_xmm0));
  return _xmm0;
}

// AVX: call <8 x float> asm "vmovsldup $1, $0", "=v,v,~{dirflag},~{fpsr},~{flags}"(<8 x float> %0)
__m256 testYMM(__m256 _ymm0) {
#ifdef AVX
  __asm__("vmovsldup %1, %0" :"=v"(_ymm0) : "v"(_ymm0));
#endif
  return _ymm0;
}

// AVX512: call <16 x float> asm "vpternlogd $$0, $1, $2, $0", "=v,v,v,~{dirflag},~{fpsr},~{flags}"(<16 x float> %0, <16 x float> %1)
__m512 testZMM(__m512 _zmm0, __m512 _zmm1) {
#ifdef AVX512
  __asm__("vpternlogd $0, %1, %2, %0" :"=v"(_zmm0) : "v"(_zmm1), "v"(_zmm0));
#endif
  return _zmm0;
}

// SSE: call <4 x float> asm "pcmpeqd $0, $0", "=^Yz,~{dirflag},~{fpsr},~{flags}"()
__m128 testXMM0(void) {
  __m128 xmm0;
  __asm__("pcmpeqd %0, %0" :"=Yz"(xmm0));
  return xmm0;
}

// AVX: call <8 x float> asm "vpcmpeqd $0, $0, $0", "=^Yz,~{dirflag},~{fpsr},~{flags}"()
__m256 testYMM0(void) {
  __m256 ymm0;
#ifdef AVX
  __asm__("vpcmpeqd %0, %0, %0" :"=Yz"(ymm0));
#endif
  return ymm0;
}

// AVX512: call <16 x float> asm "vpternlogd $$255, $0, $0, $0", "=^Yz,~{dirflag},~{fpsr},~{flags}"()
__m512 testZMM0(void) {
  __m512 zmm0;
#ifdef AVX512
  __asm__("vpternlogd $255, %0, %0, %0" :"=Yz"(zmm0));
#endif
  return zmm0;
}

// CHECK-LABEL: test_a_p(
// CHECK: call void asm sideeffect "lea ${0:a}, %eax", "p,~{eax},~{dirflag},~{fpsr},~{flags}"(ptr %0)
// CHECK: call void asm sideeffect "lea ${0:a}, %eax", "p,~{eax},~{dirflag},~{fpsr},~{flags}"(i32 %add)
void test_a_p(int *ptr, int i) {
  asm("lea %a0, %%eax" :: "p"(ptr) : "eax");
  asm("lea %a0, %%eax" :: "p"(0x1480 + i * 8) : "eax");
}

extern int var, arr[4];
struct Pair { int a, b; } pair;

// CHECK-LABEL: test_Ws(
// CHECK:         call void asm sideeffect "// ${0:p} ${1:p} ${2:p}", "^Ws,^Ws,^Ws,~{dirflag},~{fpsr},~{flags}"(ptr @var, ptr getelementptr inbounds nuw (i8, ptr @arr, i64 12), ptr @test_Ws)
// CHECK:         call void asm sideeffect "// $0", "^Ws,~{dirflag},~{fpsr},~{flags}"(ptr getelementptr inbounds nuw (i8, ptr @pair, i64 4))
void test_Ws(void) {
  asm("// %p0 %p1 %p2" :: "Ws"(&var), "Ws"(&arr[3]), "Ws"(test_Ws));
  asm("// %0" :: "Ws"(&pair.b));
}

static long ffl_fusion = (long)(var);

// RUN: %clang_cc1 %s -triple=x86_64-apple-darwin10 -std=c++11 -emit-llvm -debug-info-kind=limited -o - | FileCheck %s

class S {
public:
	S& operator = (const S&);
	S (const S&);
	S ();
};

struct CGRect {
	CGRect & operator = (const CGRect &);
};

@interface I {
  S position;
  CGRect bounds;
}

@property(assign, nonatomic) S position;
@property CGRect bounds;
@property CGRect frame;
- (void)setFrame:(CGRect)frameRect;
- (CGRect)frame;
- (void) initWithOwner;
- (CGRect)extent;
- (void)dealloc;
@end

@implementation I
@synthesize position;
@synthesize bounds;
@synthesize frame;

// CHECK: define internal void @"\01-[I setPosition:]"
// CHECK: call noundef nonnull align {{[0-9]+}} dereferenceable({{[0-9]+}}) ptr @_ZN1SaSERKS_
// CHECK-NEXT: ret void

// Don't attach debug locations to the prologue instructions. These were
// leaking over from the previous function emission by accident.
// CHECK: define internal void @"\01-[I setBounds:]"({{.*}} {
// CHECK-NOT: !dbg
// CHECK: #dbg_declare
- (void)setFrame:(CGRect)frameRect {}
- (CGRect)frame {return bounds;}

- (void)initWithOwner {
  I* _labelLayer;
  CGRect labelLayerFrame = self.bounds;
  labelLayerFrame = self.bounds;
  _labelLayer.frame = labelLayerFrame;
}

- (void)dealloc
  {
      CGRect cgrect = self.extent;
  }
- (struct CGRect)extent {return bounds;}

@end

// CHECK-LABEL: define{{.*}} i32 @main
// CHECK: call void @_ZN1SC1ERKS_(ptr {{[^,]*}} [[AGGTMP:%[a-zA-Z0-9\.]+]], ptr noundef nonnull align {{[0-9]+}} dereferenceable({{[0-9]+}}) {{%[a-zA-Z0-9\.]+}})
// CHECK: call void @objc_msgSend(ptr noundef {{%[a-zA-Z0-9\.]+}}, ptr noundef {{%[a-zA-Z0-9\.]+}}, ptr noundef align 1 dead_on_return [[AGGTMP]])
// CHECK-NEXT: ret i32 0
int main() {
  I *i;
  S s1;
  i.position = s1;
  return 0;
}

// CHECK-LABEL: define{{.*}} void @_Z1fP1A
// CHECK: call void @_ZN1XC1Ev(ptr {{[^,]*}} [[LVTEMP:%[a-zA-Z0-9\.]+]])
// CHECK: call void @_ZN1XC1ERKS_(ptr {{[^,]*}} [[AGGTMP:%[a-zA-Z0-9\.]+]], ptr noundef nonnull align {{[0-9]+}} dereferenceable({{[0-9]+}}) [[LVTEMP]])
// CHECK: call void @objc_msgSend({{.*}} ptr noundef align 1 [[AGGTMP]])
struct X {
  X();
  X(const X&);
  ~X();
};

@interface A {
  X xval;
}
- (X)x;
- (void)setX:(X)x;
@end

void f(A* a) {
  a.x = X();
}

//   Ensure that pseudo-objecet expressions that require the RHS to be
//   rewritten don't result in crashes or redundant emission of code.
struct B0 { long long x; };
struct B1 { long long x; }; B1 operator+(B1, B1);
struct B2 { B1 x; };
struct B3 { B3(); B1 x; operator B1(); };
@interface B
@property B0 b0;
@property B1 b1;
@property B2 b2;
@property B3 b3;
@ffl_fusion

int b_makeInt();

// Note that there's a promotion from int to long long, so
// the syntactic form of the RHS will be bogus.
void testB0(B *b) {
  b.b0 = { b_makeInt() };
}
void testB1(B *b) {
  b.b1 += { b_makeInt() };
}
// CHECK:    define{{.*}} void @_Z6testB0P1B(ptr
// CHECK:      [[BVAR:%.*]] = alloca ptr, align 8
// CHECK:      [[TEMP:%.*]] = alloca [[B0:%.*]], align 8
// CHECK:      [[X:%.*]] = getelementptr inbounds nuw [[B0]], ptr [[TEMP]], i32 0, i32 0
// CHECK-NEXT: [[T0:%.*]] = call noundef i32 @_Z9b_makeIntv()
// CHECK-NEXT: [[T1:%.*]] = sext i32 [[T0]] to i64
// CHECK-NEXT: store i64 [[T1]], ptr [[X]], align 8
// CHECK:      load ptr, ptr [[BVAR]]
// CHECK-NOT:  call
// CHECK:      call void @llvm.memcpy
// CHECK-NOT:  call
// CHECK:      call void @objc_msgSend
// CHECK-NOT:  call
// CHECK:      ret void

// CHECK:    define{{.*}} void @_Z6testB1P1B(ptr
// CHECK:      [[BVAR:%.*]] = alloca ptr, align 8
// CHECK:      load ptr, ptr [[BVAR]]
// CHECK-NOT:  call
// CHECK:      [[T0:%.*]] = call i64 @objc_msgSend
// CHECK-NOT:  call
// CHECK:      store i64 [[T0]],
// CHECK-NOT:  call
// CHECK:      [[T0:%.*]] = call noundef i32 @_Z9b_makeIntv()
// CHECK-NEXT: [[T1:%.*]] = sext i32 [[T0]] to i64
// CHECK-NEXT: store i64 [[T1]], ptr {{.*}}, align 8
// CHECK-NOT:  call
// CHECK:      [[T0:%.*]] = call i64 @_Zpl2B1S_
// CHECK-NOT:  call
// CHECK:      store i64 [[T0]],
// CHECK-NOT:  call
// CHECK:      call void @llvm.memcpy
// CHECK-NOT:  call
// CHECK:      call void @objc_msgSend
// CHECK-NOT:  call
// CHECK:      ret void

// Another example of a conversion that needs to be applied
// in the semantic form.
void testB2(B *b) {
  b.b2 = { B3() };
}

// CHECK:    define{{.*}} void @_Z6testB2P1B(ptr
// CHECK:      [[BVAR:%.*]] = alloca ptr, align 8
// CHECK:      #dbg_declare(
// CHECK:      call void @_ZN2B3C1Ev(
// CHECK-NEXT: [[T0:%.*]] = call i64 @_ZN2B3cv2B1Ev(
// CHECK-NOT:  call
// CHECK:      store i64 [[T0]],
// CHECK:      load ptr, ptr [[BVAR]]
// CHECK-NOT:  call
// CHECK:      call void @llvm.memcpy
// CHECK-NOT:  call
// CHECK:      call void @objc_msgSend
// CHECK-NOT:  call
// CHECK:      ret void

// A similar test to B, but using overloaded function references.
struct C1 {
  int x;
  friend C1 operator+(C1, void(&)());
};
@interface C
@property void (*c0)();
@property C1 c1;
@end

void c_helper();
void c_helper(int);

void testC0(C *c) {
  c.c0 = c_helper;
  c.c0 = &c_helper;
}
// CHECK:    define{{.*}} void @_Z6testC0P1C(ptr
// CHECK:      [[CVAR:%.*]] = alloca ptr, align 8
// CHECK:      load ptr, ptr [[CVAR]]
// CHECK-NOT:  call
// CHECK:      call void @objc_msgSend({{.*}} @_Z8c_helperv
// CHECK-NOT:  call
// CHECK:      call void @objc_msgSend({{.*}} @_Z8c_helperv
// CHECK-NOT:  call
// CHECK:      ret void

void testC1(C *c) {
  c.c1 += c_helper;
}
// CHECK:    define{{.*}} void @_Z6testC1P1C(ptr
// CHECK:      [[CVAR:%.*]] = alloca ptr, align 8
// CHECK:      load ptr, ptr [[CVAR]]
// CHECK-NOT:  call
// CHECK:      [[T0:%.*]] = call i32 @objc_msgSend
// CHECK-NOT:  call
// CHECK:      store i32 [[T0]],
// CHECK-NOT:  call
// CHECK:      [[T0:%.*]] = call i32 @_Zpl2C1RFvvE({{.*}} @_Z8c_helperv
// CHECK-NOT:  call
// CHECK:      store i32 [[T0]],
// CHECK-NOT:  call
// CHECK:      call void @llvm.memcpy
// CHECK-NOT:  call
// CHECK:      call void @objc_msgSend
// CHECK-NOT:  call
// CHECK:      ret void
