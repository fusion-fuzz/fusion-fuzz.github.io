// RUN: %clang_cc1 -Wno-unused-value -triple i686-linux-gnu -emit-llvm -o - %s | FileCheck %s
extern "C" int printf(...);
extern "C" void abort();

struct A
{
  int i;
  A (int j) : i(j) {printf("this = %p A(%d)\n", this, j);}
  A (const A &j) : i(j.i) {printf("this = %p const A&(%d)\n", this, i);}
  A& operator= (const A &j) { i = j.i; abort(); return *this; }
  ~A() { printf("this = %p ~A(%d)\n", this, i); }
};

struct B
{
  int i;
  B (const A& a) { i = a.i; }
  B() {printf("this = %p B()\n", this);}
  B (const B &j) : i(j.i) {printf("this = %p const B&(%d)\n", this, i);}
  ~B() { printf("this = %p ~B(%d)\n", this, i); }
};

A foo(int j)
{
  return ({ j ? A(1) : A(0); });
}


void foo2()
{
  A b = ({ A a(1); A a1(2); A a2(3); a1; a2; a; });
  if (b.i != 1)
    abort(); 
  A c = ({ A a(1); A a1(2); A a2(3); a1; a2; a; A a3(4); a2; a3; });
  if (c.i != 4)
    abort(); 
}

void foo3()
{
  const A &b = ({ A a(1); a; });
  if (b.i != 1)
    abort();
}

void foo4()
{
// CHECK: call {{.*}} @_ZN1AC1Ei
// CHECK: call {{.*}} @_ZN1AC1ERKS_
// CHECK: call {{.*}} @_ZN1AD1Ev
// CHECK: call {{.*}} @_ZN1BC1ERK1A
// CHECK: call {{.*}} @_ZN1AD1Ev
  const B &b = ({ A a(1); a; });
  if (b.i != 1)
    abort();
}

int main()
{
  foo2();
  foo3();
  foo4();
  return foo(1).i-1;
}

int a[128];
int* foo5() {
// CHECK-NOT: memcpy
  // Check that array-to-pointer conversion occurs in a
  // statement-expression.
  return (({ a; }));
}

// Make sure this doesn't crash.
int foo5(bool b) {
  int y = 0;
  y = ({ A a(1); if (b) goto G; a.i; });
  G: return y;
}

// When we emit a full expression with cleanups that contains branches out of
// the full expression, the result of the inner expression (the call to
// call_with_cleanups in this case) may not dominate the fallthrough destination
// of the shared cleanup block.
//
// In this case the CFG will be a sequence of two diamonds, but the only
// dynamically possible execution paths are both left hand branches and both
// right hand branches. The first diamond LHS will call bar, and the second
// diamond LHS will assign the result to v, but the call to bar does not
// dominate the assignment.
int bar(A, int);
extern "C" int cleanup_exit_scalar(bool b) {
  int v = bar(A(1), ({ if (b) return 42; 13; }));
  return v;
}

// CHECK-LABEL: define{{.*}} i32 @cleanup_exit_scalar({{.*}})
// CHECK: call {{.*}} @_ZN1AC1Ei
//    Spill after bar.
// CHECK: %[[v:[^ ]*]] = call{{.*}} i32 @_Z3bar1Ai({{.*}})
// CHECK-NEXT: store i32 %[[v]], ptr %[[tmp:[^, ]*]]
//    Do cleanup.
// CHECK: call {{.*}} @_ZN1AD1Ev
// CHECK: switch
//    Reload before v assignment.
// CHECK: %[[v:[^ ]*]] = load i32, ptr %[[tmp]]
// CHECK-NEXT: store i32 %[[v]], ptr %v

// No need to spill when the expression result is a constant, constants don't
// have dominance problems.
extern "C" int cleanup_exit_scalar_constant(bool b) {
  int v = (A(1), (void)({ if (b) return 42; 0; }), 13);
  return v;
}

// CHECK-LABEL: define{{.*}} i32 @cleanup_exit_scalar_constant({{.*}})
// CHECK: store i32 13, ptr %v

// Check for the same bug for lvalue expression evaluation kind.
// FIXME: What about non-reference lvalues, like bitfield lvalues and vector
// lvalues?
int &getref();
extern "C" int cleanup_exit_lvalue(bool cond) {
  int &r = (A(1), ({ if (cond) return 0; (void)0; }), getref());
  return r;
}
// CHECK-LABEL: define{{.*}} i32 @cleanup_exit_lvalue({{.*}})
// CHECK: call {{.*}} @_ZN1AC1Ei
//    Spill after bar.
// CHECK: %[[v:[^ ]*]] = call noundef nonnull align 4 dereferenceable(4) ptr @_Z6getrefv({{.*}})
// CHECK-NEXT: store ptr %[[v]], ptr %[[tmp:[^, ]*]]
//    Do cleanup.
// CHECK: call {{.*}} @_ZN1AD1Ev
// CHECK: switch
//    Reload before v assignment.
// CHECK: %[[v:[^ ]*]] = load ptr, ptr %[[tmp]]
// CHECK-NEXT: store ptr %[[v]], ptr %r

// Bind the reference to a byval argument. It is not an instruction or Constant,
// so it's a bit of a corner case.
struct ByVal { int x[3]; };
extern "C" int cleanup_exit_lvalue_byval(bool cond, ByVal arg) {
  ByVal &r = (A(1), ({ if (cond) return 0; (void)ByVal(); }), arg);
  return r.x[0];
}
// CHECK-LABEL: define{{.*}} i32 @cleanup_exit_lvalue_byval({{.*}}, ptr noundef byval(%struct.ByVal) align 4 %arg)
// CHECK: call {{.*}} @_ZN1AC1Ei
// CHECK: call {{.*}} @_ZN1AD1Ev
// CHECK: switch
// CHECK: store ptr %arg, ptr %r

// Bind the reference to a local variable. We don't need to spill it. Binding a
// reference to it doesn't generate any instructions.
extern "C" int cleanup_exit_lvalue_local(bool cond) {
  int local = 42;
  int &r = (A(1), ({ if (cond) return 0; (void)0; }), local);
  return r;
}
// CHECK-LABEL: define{{.*}} i32 @cleanup_exit_lvalue_local({{.*}})
// CHECK: %local = alloca i32
// CHECK: store i32 42, ptr %local
// CHECK: call {{.*}} @_ZN1AC1Ei
// CHECK-NOT: store ptr %local
// CHECK: call {{.*}} @_ZN1AD1Ev
// CHECK: switch
// CHECK: store ptr %local, ptr %r, align 4

// We handle ExprWithCleanups for complex evaluation type separately, and it had
// the same bug.
_Complex float bar_complex(A, int);
extern "C" int cleanup_exit_complex(bool b) {
  _Complex float v = bar_complex(A(1), ({ if (b) return 42; 13; }));
  return (float)v;
}

// CHECK-LABEL: define{{.*}} i32 @cleanup_exit_complex({{.*}})
// CHECK: call {{.*}} @_ZN1AC1Ei
//    Spill after bar.
// CHECK: call {{.*}} @_Z11bar_complex1Ai({{.*}})
// CHECK: store float %{{.*}}, ptr %[[tmp1:[^, ]*]]
// CHECK: store float %{{.*}}, ptr %[[tmp2:[^, ]*]]
//    Do cleanup.
// CHECK: call {{.*}} @_ZN1AD1Ev
// CHECK: switch
//    Reload before v assignment.
// CHECK: %[[v1:[^ ]*]] = load float, ptr %[[tmp1]]
// CHECK: %[[v2:[^ ]*]] = load float, ptr %[[tmp2]]
// CHECK: store float %[[v1]], ptr %v.realp
// CHECK: store float %[[v2]], ptr %v.imagp

extern "C" void then(int);

// CHECK-LABEL: @{{.*}}volatile_load
void volatile_load() {
  volatile int n;

  // CHECK-NOT: load volatile
  // CHECK: load volatile
  // CHECK-NOT: load volatile
  ({n;});

  // CHECK-LABEL: @then(i32 noundef 1)
  then(1);

  // CHECK-NOT: load volatile
  // CHECK: load volatile
  // CHECK-NOT: load volatile
  ({goto lab; lab: n;});

  // CHECK-LABEL: @then(i32 noundef 2)
  then(2);

  // CHECK-NOT: load volatile
  // CHECK: load volatile
  // CHECK-NOT: load volatile
  ({[[gsl::suppress("foo")]] n;});

  // CHECK-LABEL: @then(i32 noundef 3)
  then(3);

  // CHECK-NOT: load volatile
  // CHECK: load volatile
  // CHECK-NOT: load volatile
  ({if (true) n;});

  // CHECK: }
}

// CHECK-LABEL: @{{.*}}volatile_load_template
template<typename T>
void volatile_load_template() {
  volatile T n;

  // CHECK-NOT: load volatile
  // CHECK: load volatile
  // CHECK-NOT: load volatile
  ({n;});

  // CHECK-LABEL: @then(i32 noundef 1)
  then(1);

  // CHECK-NOT: load volatile
  // CHECK: load volatile
  // CHECK-NOT: load volatile
  ({goto lab; lab: n;});

  // CHECK-LABEL: @then(i32 noundef 2)
  then(2);

  // CHECK-NOT: load volatile
  // CHECK: load volatile
  // CHECK-NOT: load volatile
  ({[[gsl::suppress("foo")]] n;});

  // CHECK-LABEL: @then(i32 noundef 3)
  then(3);

  // CHECK-NOT: load volatile
  // CHECK: load volatile
  // CHECK-NOT: load volatile
  ({if (true) n;});

  // CHECK: }
}

// RUN: %clang_cc1 -triple arm64-apple-ios   -fptrauth-calls -fno-rtti -fptrauth-vtable-pointer-type-discrimination \
// RUN:   -fptrauth-vtable-pointer-address-discrimination -emit-llvm -o - %s | FileCheck %s --check-prefixes=CHECK,DARWIN
// RUN: %clang_cc1 -triple aarch64-linux-gnu -fptrauth-calls -fno-rtti -fptrauth-vtable-pointer-type-discrimination \
// RUN:   -fptrauth-vtable-pointer-address-discrimination -emit-llvm -o - %s | FileCheck %s --check-prefixes=CHECK,ELF

// CHECK: %struct.Base1 = type { ptr }
// CHECK: %struct.Base2 = type { ptr }
// CHECK: %struct.Derived1 = type { %struct.Base1, %struct.Base2 }
// CHECK: %struct.Derived2 = type { %struct.Base2, %struct.Base1 }
// CHECK: %struct.Derived3 = type { %struct.Base1, %struct.Base2 }

// CHECK: @_ZTV5Base1 = linkonce_odr unnamed_addr constant { [3 x ptr] } { [3 x ptr] [ptr null, ptr null, ptr ptrauth (ptr @_ZN5Base11aEv, i32 0, i64 [[BASE1_A_DISC:38871]], ptr getelementptr inbounds (i8, ptr @_ZTV5Base1, i64 16))] },{{.*}} align 8
// CHECK: @g_b1 = global %struct.Base1 { ptr ptrauth (ptr getelementptr inbounds inrange(-16, 8) (i8, ptr @_ZTV5Base1, i64 16), i32 2, i64 [[BASE1_VTABLE_DISC:6511]], ptr @g_b1) },{{.*}} align 8
// CHECK: @_ZTV5Base2 = linkonce_odr unnamed_addr constant { [3 x ptr] } { [3 x ptr] [ptr null, ptr null, ptr ptrauth (ptr @_ZN5Base21bEv, i32 0, i64 [[BASE2_B_DISC:27651]], ptr getelementptr inbounds (i8, ptr @_ZTV5Base2, i64 16))] },{{.*}} align 8
// CHECK: @g_b2 = global %struct.Base2 { ptr ptrauth (ptr getelementptr inbounds inrange(-16, 8) (i8, ptr @_ZTV5Base2, i64 16), i32 2, i64 [[BASE2_VTABLE_DISC:63631]], ptr @g_b2) },{{.*}} align 8
// CHECK: @_ZTV8Derived1 = linkonce_odr unnamed_addr constant { [5 x ptr], [3 x ptr] } { [5 x ptr] [ptr null, ptr null, ptr ptrauth (ptr @_ZN5Base11aEv, i32 0, i64 [[BASE1_A_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived1, i64 16)), ptr ptrauth (ptr @_ZN8Derived11cEv, i32 0, i64 [[DERIVED1_C_DISC:54092]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived1, i64 24)), ptr ptrauth (ptr @_ZN8Derived11dEv, i32 0, i64 [[DERIVED1_D_DISC:37391]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived1, i64 32))], [3 x ptr] [ptr inttoptr (i64 -8 to ptr), ptr null, ptr ptrauth (ptr @_ZN5Base21bEv, i32 0, i64 [[BASE2_B_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived1, i64 56))] },{{.*}} align 8
// CHECK: @g_d1 = global { ptr, ptr } { ptr ptrauth (ptr getelementptr inbounds inrange(-16, 24) (i8, ptr @_ZTV8Derived1, i64 16), i32 2, i64 [[BASE1_VTABLE_DISC]], ptr @g_d1), ptr ptrauth (ptr getelementptr inbounds inrange(-16, 8) (i8, ptr @_ZTV8Derived1, i64 56), i32 2, i64 [[BASE2_VTABLE_DISC]], ptr getelementptr inbounds (i8, ptr @g_d1, i64 8)) },{{.*}} align 8
// CHECK: @_ZTV8Derived2 = linkonce_odr unnamed_addr constant { [5 x ptr], [3 x ptr] } { [5 x ptr] [ptr null, ptr null, ptr ptrauth (ptr @_ZN5Base21bEv, i32 0, i64 [[BASE2_B_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived2, i64 16)), ptr ptrauth (ptr @_ZN8Derived21cEv, i32 0, i64 [[DERIVED2_C_DISC:15537]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived2, i64 24)), ptr ptrauth (ptr @_ZN8Derived21eEv, i32 0, i64 209, ptr getelementptr inbounds (i8, ptr @_ZTV8Derived2, i64 32))], [3 x ptr] [ptr inttoptr (i64 -8 to ptr), ptr null, ptr ptrauth (ptr @_ZN5Base11aEv, i32 0, i64 [[BASE1_A_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived2, i64 56))] },{{.*}} align 8
// CHECK: @g_d2 = global { ptr, ptr } { ptr ptrauth (ptr getelementptr inbounds inrange(-16, 24) (i8, ptr @_ZTV8Derived2, i64 16), i32 2, i64 [[BASE2_VTABLE_DISC]], ptr @g_d2), ptr ptrauth (ptr getelementptr inbounds inrange(-16, 8) (i8, ptr @_ZTV8Derived2, i64 56), i32 2, i64 [[BASE1_VTABLE_DISC]], ptr getelementptr inbounds (i8, ptr @g_d2, i64 8)) },{{.*}} align 8
// CHECK: @_ZTV8Derived3 = linkonce_odr unnamed_addr constant { [4 x ptr], [3 x ptr] } { [4 x ptr] [ptr null, ptr null, ptr ptrauth (ptr @_ZN5Base11aEv, i32 0, i64 [[BASE1_A_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived3, i64 16)), ptr ptrauth (ptr @_ZN8Derived31iEv, i32 0, i64 [[DERIVED3_I_DISC:19084]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived3, i64 24))], [3 x ptr] [ptr inttoptr (i64 -8 to ptr), ptr null, ptr ptrauth (ptr @_ZN5Base21bEv, i32 0, i64 [[BASE2_B_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived3, i64 48))] },{{.*}} align 8
// CHECK: @g_d3 = global { ptr, ptr } { ptr ptrauth (ptr getelementptr inbounds inrange(-16, 16) (i8, ptr @_ZTV8Derived3, i64 16), i32 2, i64 [[BASE1_VTABLE_DISC]], ptr @g_d3), ptr ptrauth (ptr getelementptr inbounds inrange(-16, 8) (i8, ptr @_ZTV8Derived3, i64 48), i32 2, i64 [[BASE2_VTABLE_DISC]], ptr getelementptr inbounds (i8, ptr @g_d3, i64 8)) },{{.*}} align 8
// CHECK: @g_vb1 = global %struct.VirtualBase1 zeroinitializer,{{.*}} align 8
// CHECK: @g_vb2 = global %struct.VirtualBase2 zeroinitializer,{{.*}} align 8
// CHECK: @g_d4 = global %struct.Derived4 zeroinitializer,{{.*}} align 8
// CHECK: @_ZTV12VirtualBase1 = linkonce_odr unnamed_addr constant { [6 x ptr] } { [6 x ptr] [ptr null, ptr null, ptr null, ptr null, ptr ptrauth (ptr @_ZN5Base11aEv, i32 0, i64 [[BASE1_A_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV12VirtualBase1, i64 32)), ptr ptrauth (ptr @_ZN12VirtualBase11fEv, i32 0, i64 [[VIRTUALBASE1_F_DISC:7987]], ptr getelementptr inbounds (i8, ptr @_ZTV12VirtualBase1, i64 40))] },{{.*}} align 8
// CHECK: @_ZTT12VirtualBase1 = linkonce_odr unnamed_addr constant [2 x ptr] [ptr ptrauth (ptr getelementptr inbounds inrange(-32, 16) (i8, ptr @_ZTV12VirtualBase1, i64 32), i32 2), ptr ptrauth (ptr getelementptr inbounds inrange(-32, 16) (i8, ptr @_ZTV12VirtualBase1, i64 32), i32 2)],{{.*}} align 8
// CHECK: @_ZTV12VirtualBase2 = linkonce_odr unnamed_addr constant { [5 x ptr], [4 x ptr] } { [5 x ptr] [ptr inttoptr (i64 8 to ptr), ptr null, ptr null, ptr ptrauth (ptr @_ZN5Base21bEv, i32 0, i64 [[BASE2_B_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV12VirtualBase2, i64 24)), ptr ptrauth (ptr @_ZN12VirtualBase21gEv, i32 0, i64 [[VIRTUALBASE2_G_DISC:51224]], ptr getelementptr inbounds (i8, ptr @_ZTV12VirtualBase2, i64 32))], [4 x ptr] [ptr null, ptr inttoptr (i64 -8 to ptr), ptr null, ptr ptrauth (ptr @_ZN5Base11aEv, i32 0, i64 [[BASE1_A_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV12VirtualBase2, i64 64))] },{{.*}} align 8
// CHECK: @_ZTT12VirtualBase2 = linkonce_odr unnamed_addr constant [2 x ptr] [ptr ptrauth (ptr getelementptr inbounds inrange(-24, 16) (i8, ptr @_ZTV12VirtualBase2, i64 24), i32 2), ptr ptrauth (ptr getelementptr inbounds inrange(-24, 8) (i8, ptr @_ZTV12VirtualBase2, i64 64), i32 2)],{{.*}} align 8
// CHECK: @_ZTV8Derived4 = linkonce_odr unnamed_addr constant { [7 x ptr], [5 x ptr] } { [7 x ptr] [ptr null, ptr null, ptr null, ptr null, ptr ptrauth (ptr @_ZN5Base11aEv, i32 0, i64 [[BASE1_A_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived4, i64 32)), ptr ptrauth (ptr @_ZN12VirtualBase11fEv, i32 0, i64 [[VIRTUALBASE1_F_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived4, i64 40)), ptr ptrauth (ptr @_ZN8Derived41hEv, i32 0, i64 [[DERIVED4_H_DISC:31844]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived4, i64 48))], [5 x ptr] [ptr inttoptr (i64 -8 to ptr), ptr inttoptr (i64 -8 to ptr), ptr null, ptr ptrauth (ptr @_ZN5Base21bEv, i32 0, i64 [[BASE2_B_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived4, i64 80)), ptr ptrauth (ptr @_ZN12VirtualBase21gEv, i32 0, i64 [[VIRTUALBASE2_G_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived4, i64 88))] },{{.*}} align 8
// CHECK: @_ZTT8Derived4 = linkonce_odr unnamed_addr constant [7 x ptr] [ptr ptrauth (ptr getelementptr inbounds inrange(-32, 24) (i8, ptr @_ZTV8Derived4, i64 32), i32 2), ptr ptrauth (ptr getelementptr inbounds inrange(-32, 16) (i8, ptr @_ZTC8Derived40_12VirtualBase1, i64 32), i32 2), ptr ptrauth (ptr getelementptr inbounds inrange(-32, 16) (i8, ptr @_ZTC8Derived40_12VirtualBase1, i64 32), i32 2), ptr ptrauth (ptr getelementptr inbounds inrange(-24, 16) (i8, ptr @_ZTC8Derived48_12VirtualBase2, i64 24), i32 2), ptr ptrauth (ptr getelementptr inbounds inrange(-24, 8) (i8, ptr @_ZTC8Derived48_12VirtualBase2, i64 64), i32 2), ptr ptrauth (ptr getelementptr inbounds inrange(-32, 24) (i8, ptr @_ZTV8Derived4, i64 32), i32 2), ptr ptrauth (ptr getelementptr inbounds inrange(-24, 16) (i8, ptr @_ZTV8Derived4, i64 80), i32 2)],{{.*}} align 8
// CHECK: @_ZTC8Derived40_12VirtualBase1 = linkonce_odr unnamed_addr constant { [6 x ptr] } { [6 x ptr] [ptr null, ptr null, ptr null, ptr null, ptr ptrauth (ptr @_ZN5Base11aEv, i32 0, i64 [[BASE1_A_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTC8Derived40_12VirtualBase1, i64 32)), ptr ptrauth (ptr @_ZN12VirtualBase11fEv, i32 0, i64 [[VIRTUALBASE1_F_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTC8Derived40_12VirtualBase1, i64 40))] },{{.*}} align 8
// CHECK: @_ZTC8Derived48_12VirtualBase2 = linkonce_odr unnamed_addr constant { [5 x ptr], [4 x ptr] } { [5 x ptr] [ptr inttoptr (i64 -8 to ptr), ptr null, ptr null, ptr ptrauth (ptr @_ZN5Base21bEv, i32 0, i64 [[BASE2_B_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTC8Derived48_12VirtualBase2, i64 24)), ptr ptrauth (ptr @_ZN12VirtualBase21gEv, i32 0, i64 [[VIRTUALBASE2_G_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTC8Derived48_12VirtualBase2, i64 32))], [4 x ptr] [ptr null, ptr inttoptr (i64 8 to ptr), ptr null, ptr ptrauth (ptr @_ZN5Base11aEv, i32 0, i64 [[BASE1_A_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTC8Derived48_12VirtualBase2, i64 64))] },{{.*}} align 8






// DARWIN-LABEL: define {{.*}} ptr @_ZN12VirtualBase1C1Ev
// ELF-LABEL:    define {{.*}} void @_ZN12VirtualBase1C1Ev
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])

// DARWIN-LABEL: define {{.*}} ptr @_ZN12VirtualBase2C1Ev
// ELF-LABEL:    define {{.*}} void @_ZN12VirtualBase2C1Ev
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])

// DARWIN-LABEL: define {{.*}} ptr @_ZN8Derived4C1Ev
// ELF-LABEL:    define {{.*}} void @_ZN8Derived4C1Ev
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])

// DARWIN-LABEL: define {{.*}} ptr @_ZN8Derived5C1Ev
// ELF-LABEL:    define {{.*}} void @_ZN8Derived5C1Ev
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])





// CHECK-LABEL: define{{.*}} void @cross_check_vtables(
// CHECK: "; b1->a()",
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_A_DISC]])
template void volatile_load_template<int>();
// CHECK: "; b2->b()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_B_DISC]])
// CHECK: "; d1->a()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_A_DISC]])
// CHECK: "; d1->c()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[DERIVED1_C_DISC]])
// CHECK: "; d2->a()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_A_DISC]])
// CHECK: "; d2->c()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[DERIVED2_C_DISC]])
// CHECK: "; d3->a()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_A_DISC]])
// CHECK: "; d3->b()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_B_DISC]])
// CHECK: "; d3->i()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[DERIVED3_I_DISC]])
// CHECK: "; vb1->a()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_A_DISC]])
// CHECK: "; vb1->f()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[VIRTUALBASE1_F_DISC]])
// CHECK: "; vb2->a()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_A_DISC]])
// CHECK: "; vb2->g()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[VIRTUALBASE2_G_DISC]])
// CHECK: "; d4->a()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_A_DISC]])
// CHECK: "; d4->b()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_B_DISC]])
// CHECK: "; d4->f()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[VIRTUALBASE1_F_DISC]])
// CHECK: "; d4->g()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[VIRTUALBASE2_G_DISC]])
// CHECK: "; d4->h()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[DERIVED4_H_DISC]])

// DARWIN-LABEL: define {{.*}} ptr @_ZN5Base1C2Ev
// ELF-LABEL:    define {{.*}} void @_ZN5Base1C2Ev
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])

// DARWIN-LABEL: define {{.*}} ptr @_ZN5Base2C2Ev
// ELF-LABEL:    define {{.*}} void @_ZN5Base2C2Ev
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])

// DARWIN-LABEL: define {{.*}} ptr @_ZN8Derived1C2Ev
// ELF-LABEL:    define {{.*}} void @_ZN8Derived1C2Ev
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])

// DARWIN-LABEL: define {{.*}} ptr @_ZN8Derived2C2Ev
// ELF-LABEL:    define {{.*}} void @_ZN8Derived2C2Ev
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])

// DARWIN-LABEL: define {{.*}} ptr @_ZN8Derived3C2Ev
// ELF-LABEL:    define {{.*}} void @_ZN8Derived3C2Ev
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// RUN: %clang_cc1 -triple arm64-apple-ios   -fptrauth-calls -fno-rtti -fptrauth-vtable-pointer-type-discrimination \
// RUN:   -fptrauth-vtable-pointer-address-discrimination -emit-llvm -o - %s | FileCheck %s --check-prefixes=CHECK,DARWIN
// RUN: %clang_cc1 -triple aarch64-linux-gnu -fptrauth-calls -fno-rtti -fptrauth-vtable-pointer-type-discrimination \
// RUN:   -fptrauth-vtable-pointer-address-discrimination -emit-llvm -o - %s | FileCheck %s --check-prefixes=CHECK,ELF

// CHECK: %struct.Base1 = type { ptr }
// CHECK: %struct.Base2 = type { ptr }
// CHECK: %struct.Derived1 = type { %struct.Base1, %struct.Base2 }
// CHECK: %struct.Derived2 = type { %struct.Base2, %struct.Base1 }
// CHECK: %struct.Derived3 = type { %struct.Base1, %struct.Base2 }

// CHECK: @_ZTV5Base1 = linkonce_odr unnamed_addr constant { [3 x ptr] } { [3 x ptr] [ptr null, ptr null, ptr ptrauth (ptr @_ZN5Base11aEv, i32 0, i64 [[BASE1_A_DISC:38871]], ptr getelementptr inbounds (i8, ptr @_ZTV5Base1, i64 16))] },{{.*}} align 8
// CHECK: @g_b1 = global %struct.Base1 { ptr ptrauth (ptr getelementptr inbounds inrange(-16, 8) (i8, ptr @_ZTV5Base1, i64 16), i32 2, i64 [[BASE1_VTABLE_DISC:6511]], ptr @g_b1) },{{.*}} align 8
// CHECK: @_ZTV5Base2 = linkonce_odr unnamed_addr constant { [3 x ptr] } { [3 x ptr] [ptr null, ptr null, ptr ptrauth (ptr @_ZN5Base21bEv, i32 0, i64 [[BASE2_B_DISC:27651]], ptr getelementptr inbounds (i8, ptr @_ZTV5Base2, i64 16))] },{{.*}} align 8
// CHECK: @g_b2 = global %struct.Base2 { ptr ptrauth (ptr getelementptr inbounds inrange(-16, 8) (i8, ptr @_ZTV5Base2, i64 16), i32 2, i64 [[BASE2_VTABLE_DISC:63631]], ptr @g_b2) },{{.*}} align 8
// CHECK: @_ZTV8Derived1 = linkonce_odr unnamed_addr constant { [5 x ptr], [3 x ptr] } { [5 x ptr] [ptr null, ptr null, ptr ptrauth (ptr @_ZN5Base11aEv, i32 0, i64 [[BASE1_A_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived1, i64 16)), ptr ptrauth (ptr @_ZN8Derived11cEv, i32 0, i64 [[DERIVED1_C_DISC:54092]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived1, i64 24)), ptr ptrauth (ptr @_ZN8Derived11dEv, i32 0, i64 [[DERIVED1_D_DISC:37391]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived1, i64 32))], [3 x ptr] [ptr inttoptr (i64 -8 to ptr), ptr null, ptr ptrauth (ptr @_ZN5Base21bEv, i32 0, i64 [[BASE2_B_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived1, i64 56))] },{{.*}} align 8
// CHECK: @g_d1 = global { ptr, ptr } { ptr ptrauth (ptr getelementptr inbounds inrange(-16, 24) (i8, ptr @_ZTV8Derived1, i64 16), i32 2, i64 [[BASE1_VTABLE_DISC]], ptr @g_d1), ptr ptrauth (ptr getelementptr inbounds inrange(-16, 8) (i8, ptr @_ZTV8Derived1, i64 56), i32 2, i64 [[BASE2_VTABLE_DISC]], ptr getelementptr inbounds (i8, ptr @g_d1, i64 8)) },{{.*}} align 8
// CHECK: @_ZTV8Derived2 = linkonce_odr unnamed_addr constant { [5 x ptr], [3 x ptr] } { [5 x ptr] [ptr null, ptr null, ptr ptrauth (ptr @_ZN5Base21bEv, i32 0, i64 [[BASE2_B_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived2, i64 16)), ptr ptrauth (ptr @_ZN8Derived21cEv, i32 0, i64 [[DERIVED2_C_DISC:15537]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived2, i64 24)), ptr ptrauth (ptr @_ZN8Derived21eEv, i32 0, i64 209, ptr getelementptr inbounds (i8, ptr @_ZTV8Derived2, i64 32))], [3 x ptr] [ptr inttoptr (i64 -8 to ptr), ptr null, ptr ptrauth (ptr @_ZN5Base11aEv, i32 0, i64 [[BASE1_A_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived2, i64 56))] },{{.*}} align 8
// CHECK: @g_d2 = global { ptr, ptr } { ptr ptrauth (ptr getelementptr inbounds inrange(-16, 24) (i8, ptr @_ZTV8Derived2, i64 16), i32 2, i64 [[BASE2_VTABLE_DISC]], ptr @g_d2), ptr ptrauth (ptr getelementptr inbounds inrange(-16, 8) (i8, ptr @_ZTV8Derived2, i64 56), i32 2, i64 [[BASE1_VTABLE_DISC]], ptr getelementptr inbounds (i8, ptr @g_d2, i64 8)) },{{.*}} align 8
// CHECK: @_ZTV8Derived3 = linkonce_odr unnamed_addr constant { [4 x ptr], [3 x ptr] } { [4 x ptr] [ptr null, ptr null, ptr ptrauth (ptr @_ZN5Base11aEv, i32 0, i64 [[BASE1_A_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived3, i64 16)), ptr ptrauth (ptr @_ZN8Derived31iEv, i32 0, i64 [[DERIVED3_I_DISC:19084]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived3, i64 24))], [3 x ptr] [ptr inttoptr (i64 -8 to ptr), ptr null, ptr ptrauth (ptr @_ZN5Base21bEv, i32 0, i64 [[BASE2_B_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived3, i64 48))] },{{.*}} align 8
// CHECK: @g_d3 = global { ptr, ptr } { ptr ptrauth (ptr getelementptr inbounds inrange(-16, 16) (i8, ptr @_ZTV8Derived3, i64 16), i32 2, i64 [[BASE1_VTABLE_DISC]], ptr @g_d3), ptr ptrauth (ptr getelementptr inbounds inrange(-16, 8) (i8, ptr @_ZTV8Derived3, i64 48), i32 2, i64 [[BASE2_VTABLE_DISC]], ptr getelementptr inbounds (i8, ptr @g_d3, i64 8)) },{{.*}} align 8
// CHECK: @g_vb1 = global %struct.VirtualBase1 zeroinitializer,{{.*}} align 8
// CHECK: @g_vb2 = global %struct.VirtualBase2 zeroinitializer,{{.*}} align 8
// CHECK: @g_d4 = global %struct.Derived4 zeroinitializer,{{.*}} align 8
// CHECK: @_ZTV12VirtualBase1 = linkonce_odr unnamed_addr constant { [6 x ptr] } { [6 x ptr] [ptr null, ptr null, ptr null, ptr null, ptr ptrauth (ptr @_ZN5Base11aEv, i32 0, i64 [[BASE1_A_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV12VirtualBase1, i64 32)), ptr ptrauth (ptr @_ZN12VirtualBase11fEv, i32 0, i64 [[VIRTUALBASE1_F_DISC:7987]], ptr getelementptr inbounds (i8, ptr @_ZTV12VirtualBase1, i64 40))] },{{.*}} align 8
// CHECK: @_ZTT12VirtualBase1 = linkonce_odr unnamed_addr constant [2 x ptr] [ptr ptrauth (ptr getelementptr inbounds inrange(-32, 16) (i8, ptr @_ZTV12VirtualBase1, i64 32), i32 2), ptr ptrauth (ptr getelementptr inbounds inrange(-32, 16) (i8, ptr @_ZTV12VirtualBase1, i64 32), i32 2)],{{.*}} align 8
// CHECK: @_ZTV12VirtualBase2 = linkonce_odr unnamed_addr constant { [5 x ptr], [4 x ptr] } { [5 x ptr] [ptr inttoptr (i64 8 to ptr), ptr null, ptr null, ptr ptrauth (ptr @_ZN5Base21bEv, i32 0, i64 [[BASE2_B_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV12VirtualBase2, i64 24)), ptr ptrauth (ptr @_ZN12VirtualBase21gEv, i32 0, i64 [[VIRTUALBASE2_G_DISC:51224]], ptr getelementptr inbounds (i8, ptr @_ZTV12VirtualBase2, i64 32))], [4 x ptr] [ptr null, ptr inttoptr (i64 -8 to ptr), ptr null, ptr ptrauth (ptr @_ZN5Base11aEv, i32 0, i64 [[BASE1_A_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV12VirtualBase2, i64 64))] },{{.*}} align 8
// CHECK: @_ZTT12VirtualBase2 = linkonce_odr unnamed_addr constant [2 x ptr] [ptr ptrauth (ptr getelementptr inbounds inrange(-24, 16) (i8, ptr @_ZTV12VirtualBase2, i64 24), i32 2), ptr ptrauth (ptr getelementptr inbounds inrange(-24, 8) (i8, ptr @_ZTV12VirtualBase2, i64 64), i32 2)],{{.*}} align 8
// CHECK: @_ZTV8Derived4 = linkonce_odr unnamed_addr constant { [7 x ptr], [5 x ptr] } { [7 x ptr] [ptr null, ptr null, ptr null, ptr null, ptr ptrauth (ptr @_ZN5Base11aEv, i32 0, i64 [[BASE1_A_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived4, i64 32)), ptr ptrauth (ptr @_ZN12VirtualBase11fEv, i32 0, i64 [[VIRTUALBASE1_F_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived4, i64 40)), ptr ptrauth (ptr @_ZN8Derived41hEv, i32 0, i64 [[DERIVED4_H_DISC:31844]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived4, i64 48))], [5 x ptr] [ptr inttoptr (i64 -8 to ptr), ptr inttoptr (i64 -8 to ptr), ptr null, ptr ptrauth (ptr @_ZN5Base21bEv, i32 0, i64 [[BASE2_B_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived4, i64 80)), ptr ptrauth (ptr @_ZN12VirtualBase21gEv, i32 0, i64 [[VIRTUALBASE2_G_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived4, i64 88))] },{{.*}} align 8
// CHECK: @_ZTT8Derived4 = linkonce_odr unnamed_addr constant [7 x ptr] [ptr ptrauth (ptr getelementptr inbounds inrange(-32, 24) (i8, ptr @_ZTV8Derived4, i64 32), i32 2), ptr ptrauth (ptr getelementptr inbounds inrange(-32, 16) (i8, ptr @_ZTC8Derived40_12VirtualBase1, i64 32), i32 2), ptr ptrauth (ptr getelementptr inbounds inrange(-32, 16) (i8, ptr @_ZTC8Derived40_12VirtualBase1, i64 32), i32 2), ptr ptrauth (ptr getelementptr inbounds inrange(-24, 16) (i8, ptr @_ZTC8Derived48_12VirtualBase2, i64 24), i32 2), ptr ptrauth (ptr getelementptr inbounds inrange(-24, 8) (i8, ptr @_ZTC8Derived48_12VirtualBase2, i64 64), i32 2), ptr ptrauth (ptr getelementptr inbounds inrange(-32, 24) (i8, ptr @_ZTV8Derived4, i64 32), i32 2), ptr ptrauth (ptr getelementptr inbounds inrange(-24, 16) (i8, ptr @_ZTV8Derived4, i64 80), i32 2)],{{.*}} align 8
// CHECK: @_ZTC8Derived40_12VirtualBase1 = linkonce_odr unnamed_addr constant { [6 x ptr] } { [6 x ptr] [ptr null, ptr null, ptr null, ptr null, ptr ptrauth (ptr @_ZN5Base11aEv, i32 0, i64 [[BASE1_A_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTC8Derived40_12VirtualBase1, i64 32)), ptr ptrauth (ptr @_ZN12VirtualBase11fEv, i32 0, i64 [[VIRTUALBASE1_F_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTC8Derived40_12VirtualBase1, i64 40))] },{{.*}} align 8
// CHECK: @_ZTC8Derived48_12VirtualBase2 = linkonce_odr unnamed_addr constant { [5 x ptr], [4 x ptr] } { [5 x ptr] [ptr inttoptr (i64 -8 to ptr), ptr null, ptr null, ptr ptrauth (ptr @_ZN5Base21bEv, i32 0, i64 [[BASE2_B_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTC8Derived48_12VirtualBase2, i64 24)), ptr ptrauth (ptr @_ZN12VirtualBase21gEv, i32 0, i64 [[VIRTUALBASE2_G_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTC8Derived48_12VirtualBase2, i64 32))], [4 x ptr] [ptr null, ptr inttoptr (i64 8 to ptr), ptr null, ptr ptrauth (ptr @_ZN5Base11aEv, i32 0, i64 [[BASE1_A_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTC8Derived48_12VirtualBase2, i64 64))] },{{.*}} align 8






// DARWIN-LABEL: define {{.*}} ptr @_ZN12VirtualBase1C1Ev
// ELF-LABEL:    define {{.*}} void @_ZN12VirtualBase1C1Ev
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])

// DARWIN-LABEL: define {{.*}} ptr @_ZN12VirtualBase2C1Ev
// ELF-LABEL:    define {{.*}} void @_ZN12VirtualBase2C1Ev
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])

// DARWIN-LABEL: define {{.*}} ptr @_ZN8Derived4C1Ev
// ELF-LABEL:    define {{.*}} void @_ZN8Derived4C1Ev
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])

// DARWIN-LABEL: define {{.*}} ptr @_ZN8Derived5C1Ev
// ELF-LABEL:    define {{.*}} void @_ZN8Derived5C1Ev
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])





// CHECK-LABEL: define{{.*}} void @cross_check_vtables(
// CHECK: "; b1->a()",
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_A_DISC]])
// CHECK: "; b2->b()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_B_DISC]])
// CHECK: "; d1->a()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_A_DISC]])
// CHECK: "; d1->c()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[DERIVED1_C_DISC]])
// CHECK: "; d2->a()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_A_DISC]])
// CHECK: "; d2->c()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[DERIVED2_C_DISC]])
// CHECK: "; d3->a()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_A_DISC]])
// CHECK: "; d3->b()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_B_DISC]])
// CHECK: "; d3->i()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[DERIVED3_I_DISC]])
// CHECK: "; vb1->a()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_A_DISC]])
// CHECK: "; vb1->f()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[VIRTUALBASE1_F_DISC]])
// CHECK: "; vb2->a()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_A_DISC]])
// CHECK: "; vb2->g()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[VIRTUALBASE2_G_DISC]])
// CHECK: "; d4->a()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_A_DISC]])
// CHECK: "; d4->b()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_B_DISC]])
// CHECK: "; d4->f()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[VIRTUALBASE1_F_DISC]])
// CHECK: "; d4->g()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[VIRTUALBASE2_G_DISC]])
// CHECK: "; d4->h()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[DERIVED4_H_DISC]])

// DARWIN-LABEL: define {{.*}} ptr @_ZN5Base1C2Ev
// ELF-LABEL:    define {{.*}} void @_ZN5Base1C2Ev
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])

// DARWIN-LABEL: define {{.*}} ptr @_ZN5Base2C2Ev
// ELF-LABEL:    define {{.*}} void @_ZN5Base2C2Ev
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])

// DARWIN-LABEL: define {{.*}} ptr @_ZN8Derived1C2Ev
// ELF-LABEL:    define {{.*}} void @_ZN8Derived1C2Ev
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])

// DARWIN-LABEL: define {{.*}} ptr @_ZN8Derived2C2Ev
// ELF-LABEL:    define {{.*}} void @_ZN8Derived2C2Ev
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])

// DARWIN-LABEL: define {{.*}} ptr @_ZN8Derived3C2Ev
// ELF-LABEL:    define {{.*}} void @_ZN8Derived3C2Ev
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])

// RUN: %clang_cc1 -triple arm64-apple-ios   -fptrauth-calls -fno-rtti -fptrauth-vtable-pointer-type-discrimination \
// RUN:   -fptrauth-vtable-pointer-address-discrimination -emit-llvm -o - %s | FileCheck %s --check-prefixes=CHECK,DARWIN
// RUN: %clang_cc1 -triple aarch64-linux-gnu -fptrauth-calls -fno-rtti -fptrauth-vtable-pointer-type-discrimination \
// RUN:   -fptrauth-vtable-pointer-address-discrimination -emit-llvm -o - %s | FileCheck %s --check-prefixes=CHECK,ELF

// CHECK: %struct.Base1 = type { ptr }
// CHECK: %struct.Base2 = type { ptr }
// CHECK: %struct.Derived1 = type { %struct.Base1, %struct.Base2 }
// CHECK: %struct.Derived2 = type { %struct.Base2, %struct.Base1 }
// CHECK: %struct.Derived3 = type { %struct.Base1, %struct.Base2 }

// CHECK: @_ZTV5Base1 = linkonce_odr unnamed_addr constant { [3 x ptr] } { [3 x ptr] [ptr null, ptr null, ptr ptrauth (ptr @_ZN5Base11aEv, i32 0, i64 [[BASE1_A_DISC:38871]], ptr getelementptr inbounds (i8, ptr @_ZTV5Base1, i64 16))] },{{.*}} align 8
// CHECK: @g_b1 = global %struct.Base1 { ptr ptrauth (ptr getelementptr inbounds inrange(-16, 8) (i8, ptr @_ZTV5Base1, i64 16), i32 2, i64 [[BASE1_VTABLE_DISC:6511]], ptr @g_b1) },{{.*}} align 8
// CHECK: @_ZTV5Base2 = linkonce_odr unnamed_addr constant { [3 x ptr] } { [3 x ptr] [ptr null, ptr null, ptr ptrauth (ptr @_ZN5Base21bEv, i32 0, i64 [[BASE2_B_DISC:27651]], ptr getelementptr inbounds (i8, ptr @_ZTV5Base2, i64 16))] },{{.*}} align 8
// CHECK: @g_b2 = global %struct.Base2 { ptr ptrauth (ptr getelementptr inbounds inrange(-16, 8) (i8, ptr @_ZTV5Base2, i64 16), i32 2, i64 [[BASE2_VTABLE_DISC:63631]], ptr @g_b2) },{{.*}} align 8
// CHECK: @_ZTV8Derived1 = linkonce_odr unnamed_addr constant { [5 x ptr], [3 x ptr] } { [5 x ptr] [ptr null, ptr null, ptr ptrauth (ptr @_ZN5Base11aEv, i32 0, i64 [[BASE1_A_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived1, i64 16)), ptr ptrauth (ptr @_ZN8Derived11cEv, i32 0, i64 [[DERIVED1_C_DISC:54092]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived1, i64 24)), ptr ptrauth (ptr @_ZN8Derived11dEv, i32 0, i64 [[DERIVED1_D_DISC:37391]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived1, i64 32))], [3 x ptr] [ptr inttoptr (i64 -8 to ptr), ptr null, ptr ptrauth (ptr @_ZN5Base21bEv, i32 0, i64 [[BASE2_B_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived1, i64 56))] },{{.*}} align 8
// CHECK: @g_d1 = global { ptr, ptr } { ptr ptrauth (ptr getelementptr inbounds inrange(-16, 24) (i8, ptr @_ZTV8Derived1, i64 16), i32 2, i64 [[BASE1_VTABLE_DISC]], ptr @g_d1), ptr ptrauth (ptr getelementptr inbounds inrange(-16, 8) (i8, ptr @_ZTV8Derived1, i64 56), i32 2, i64 [[BASE2_VTABLE_DISC]], ptr getelementptr inbounds (i8, ptr @g_d1, i64 8)) },{{.*}} align 8
// CHECK: @_ZTV8Derived2 = linkonce_odr unnamed_addr constant { [5 x ptr], [3 x ptr] } { [5 x ptr] [ptr null, ptr null, ptr ptrauth (ptr @_ZN5Base21bEv, i32 0, i64 [[BASE2_B_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived2, i64 16)), ptr ptrauth (ptr @_ZN8Derived21cEv, i32 0, i64 [[DERIVED2_C_DISC:15537]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived2, i64 24)), ptr ptrauth (ptr @_ZN8Derived21eEv, i32 0, i64 209, ptr getelementptr inbounds (i8, ptr @_ZTV8Derived2, i64 32))], [3 x ptr] [ptr inttoptr (i64 -8 to ptr), ptr null, ptr ptrauth (ptr @_ZN5Base11aEv, i32 0, i64 [[BASE1_A_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived2, i64 56))] },{{.*}} align 8
// CHECK: @g_d2 = global { ptr, ptr } { ptr ptrauth (ptr getelementptr inbounds inrange(-16, 24) (i8, ptr @_ZTV8Derived2, i64 16), i32 2, i64 [[BASE2_VTABLE_DISC]], ptr @g_d2), ptr ptrauth (ptr getelementptr inbounds inrange(-16, 8) (i8, ptr @_ZTV8Derived2, i64 56), i32 2, i64 [[BASE1_VTABLE_DISC]], ptr getelementptr inbounds (i8, ptr @g_d2, i64 8)) },{{.*}} align 8
// CHECK: @_ZTV8Derived3 = linkonce_odr unnamed_addr constant { [4 x ptr], [3 x ptr] } { [4 x ptr] [ptr null, ptr null, ptr ptrauth (ptr @_ZN5Base11aEv, i32 0, i64 [[BASE1_A_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived3, i64 16)), ptr ptrauth (ptr @_ZN8Derived31iEv, i32 0, i64 [[DERIVED3_I_DISC:19084]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived3, i64 24))], [3 x ptr] [ptr inttoptr (i64 -8 to ptr), ptr null, ptr ptrauth (ptr @_ZN5Base21bEv, i32 0, i64 [[BASE2_B_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived3, i64 48))] },{{.*}} align 8
// CHECK: @g_d3 = global { ptr, ptr } { ptr ptrauth (ptr getelementptr inbounds inrange(-16, 16) (i8, ptr @_ZTV8Derived3, i64 16), i32 2, i64 [[BASE1_VTABLE_DISC]], ptr @g_d3), ptr ptrauth (ptr getelementptr inbounds inrange(-16, 8) (i8, ptr @_ZTV8Derived3, i64 48), i32 2, i64 [[BASE2_VTABLE_DISC]], ptr getelementptr inbounds (i8, ptr @g_d3, i64 8)) },{{.*}} align 8
// CHECK: @g_vb1 = global %struct.VirtualBase1 zeroinitializer,{{.*}} align 8
// CHECK: @g_vb2 = global %struct.VirtualBase2 zeroinitializer,{{.*}} align 8
// CHECK: @g_d4 = global %struct.Derived4 zeroinitializer,{{.*}} align 8
// CHECK: @_ZTV12VirtualBase1 = linkonce_odr unnamed_addr constant { [6 x ptr] } { [6 x ptr] [ptr null, ptr null, ptr null, ptr null, ptr ptrauth (ptr @_ZN5Base11aEv, i32 0, i64 [[BASE1_A_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV12VirtualBase1, i64 32)), ptr ptrauth (ptr @_ZN12VirtualBase11fEv, i32 0, i64 [[VIRTUALBASE1_F_DISC:7987]], ptr getelementptr inbounds (i8, ptr @_ZTV12VirtualBase1, i64 40))] },{{.*}} align 8
// CHECK: @_ZTT12VirtualBase1 = linkonce_odr unnamed_addr constant [2 x ptr] [ptr ptrauth (ptr getelementptr inbounds inrange(-32, 16) (i8, ptr @_ZTV12VirtualBase1, i64 32), i32 2), ptr ptrauth (ptr getelementptr inbounds inrange(-32, 16) (i8, ptr @_ZTV12VirtualBase1, i64 32), i32 2)],{{.*}} align 8
// CHECK: @_ZTV12VirtualBase2 = linkonce_odr unnamed_addr constant { [5 x ptr], [4 x ptr] } { [5 x ptr] [ptr inttoptr (i64 8 to ptr), ptr null, ptr null, ptr ptrauth (ptr @_ZN5Base21bEv, i32 0, i64 [[BASE2_B_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV12VirtualBase2, i64 24)), ptr ptrauth (ptr @_ZN12VirtualBase21gEv, i32 0, i64 [[VIRTUALBASE2_G_DISC:51224]], ptr getelementptr inbounds (i8, ptr @_ZTV12VirtualBase2, i64 32))], [4 x ptr] [ptr null, ptr inttoptr (i64 -8 to ptr), ptr null, ptr ptrauth (ptr @_ZN5Base11aEv, i32 0, i64 [[BASE1_A_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV12VirtualBase2, i64 64))] },{{.*}} align 8
// CHECK: @_ZTT12VirtualBase2 = linkonce_odr unnamed_addr constant [2 x ptr] [ptr ptrauth (ptr getelementptr inbounds inrange(-24, 16) (i8, ptr @_ZTV12VirtualBase2, i64 24), i32 2), ptr ptrauth (ptr getelementptr inbounds inrange(-24, 8) (i8, ptr @_ZTV12VirtualBase2, i64 64), i32 2)],{{.*}} align 8
// CHECK: @_ZTV8Derived4 = linkonce_odr unnamed_addr constant { [7 x ptr], [5 x ptr] } { [7 x ptr] [ptr null, ptr null, ptr null, ptr null, ptr ptrauth (ptr @_ZN5Base11aEv, i32 0, i64 [[BASE1_A_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived4, i64 32)), ptr ptrauth (ptr @_ZN12VirtualBase11fEv, i32 0, i64 [[VIRTUALBASE1_F_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived4, i64 40)), ptr ptrauth (ptr @_ZN8Derived41hEv, i32 0, i64 [[DERIVED4_H_DISC:31844]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived4, i64 48))], [5 x ptr] [ptr inttoptr (i64 -8 to ptr), ptr inttoptr (i64 -8 to ptr), ptr null, ptr ptrauth (ptr @_ZN5Base21bEv, i32 0, i64 [[BASE2_B_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived4, i64 80)), ptr ptrauth (ptr @_ZN12VirtualBase21gEv, i32 0, i64 [[VIRTUALBASE2_G_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTV8Derived4, i64 88))] },{{.*}} align 8
// CHECK: @_ZTT8Derived4 = linkonce_odr unnamed_addr constant [7 x ptr] [ptr ptrauth (ptr getelementptr inbounds inrange(-32, 24) (i8, ptr @_ZTV8Derived4, i64 32), i32 2), ptr ptrauth (ptr getelementptr inbounds inrange(-32, 16) (i8, ptr @_ZTC8Derived40_12VirtualBase1, i64 32), i32 2), ptr ptrauth (ptr getelementptr inbounds inrange(-32, 16) (i8, ptr @_ZTC8Derived40_12VirtualBase1, i64 32), i32 2), ptr ptrauth (ptr getelementptr inbounds inrange(-24, 16) (i8, ptr @_ZTC8Derived48_12VirtualBase2, i64 24), i32 2), ptr ptrauth (ptr getelementptr inbounds inrange(-24, 8) (i8, ptr @_ZTC8Derived48_12VirtualBase2, i64 64), i32 2), ptr ptrauth (ptr getelementptr inbounds inrange(-32, 24) (i8, ptr @_ZTV8Derived4, i64 32), i32 2), ptr ptrauth (ptr getelementptr inbounds inrange(-24, 16) (i8, ptr @_ZTV8Derived4, i64 80), i32 2)],{{.*}} align 8
// CHECK: @_ZTC8Derived40_12VirtualBase1 = linkonce_odr unnamed_addr constant { [6 x ptr] } { [6 x ptr] [ptr null, ptr null, ptr null, ptr null, ptr ptrauth (ptr @_ZN5Base11aEv, i32 0, i64 [[BASE1_A_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTC8Derived40_12VirtualBase1, i64 32)), ptr ptrauth (ptr @_ZN12VirtualBase11fEv, i32 0, i64 [[VIRTUALBASE1_F_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTC8Derived40_12VirtualBase1, i64 40))] },{{.*}} align 8
// CHECK: @_ZTC8Derived48_12VirtualBase2 = linkonce_odr unnamed_addr constant { [5 x ptr], [4 x ptr] } { [5 x ptr] [ptr inttoptr (i64 -8 to ptr), ptr null, ptr null, ptr ptrauth (ptr @_ZN5Base21bEv, i32 0, i64 [[BASE2_B_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTC8Derived48_12VirtualBase2, i64 24)), ptr ptrauth (ptr @_ZN12VirtualBase21gEv, i32 0, i64 [[VIRTUALBASE2_G_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTC8Derived48_12VirtualBase2, i64 32))], [4 x ptr] [ptr null, ptr inttoptr (i64 8 to ptr), ptr null, ptr ptrauth (ptr @_ZN5Base11aEv, i32 0, i64 [[BASE1_A_DISC]], ptr getelementptr inbounds (i8, ptr @_ZTC8Derived48_12VirtualBase2, i64 64))] },{{.*}} align 8

struct Base1 : public A { virtual void a() {} }
;
struct Base2 { virtual void b() {} }
;
struct Derived1 : public Base1, public Base2 {
  virtual void c() {}
  virtual void d() {}
}
;
struct Derived2 : public Base2, public Base1 {
  virtual void c() {}
  virtual void e() {}
}
;
struct Derived3 : public Base1, public Base2 {
  constexpr Derived3(){}
  virtual void i() {}
}
;
Base1 g_b1;
Base2 g_b2;
Derived1 g_d1;
Derived2 g_d2;
Derived3 g_d3;
extern "C" void test_basic_inheritance() {
  Base1 g_b1;
  Base2 g_b2;
  Derived1 g_d1;
  Derived2 g_d2;
  Derived3 g_d3;
}
struct VirtualBase1 : virtual Base1 {
  VirtualBase1(){}
  virtual void f() {}
}
;
struct VirtualBase2 : virtual Base1, Base2 {
  VirtualBase2(){}
  virtual void g() {}
}
;
struct Derived4 : VirtualBase1, VirtualBase2 {
  virtual void h() {}
}
;
struct Derived5 : VirtualBase2, VirtualBase1 {
  virtual void h() {}
}
;
// DARWIN-LABEL: define {{.*}} ptr @_ZN12VirtualBase1C1Ev
// ELF-LABEL:    define {{.*}} void @_ZN12VirtualBase1C1Ev
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])

// DARWIN-LABEL: define {{.*}} ptr @_ZN12VirtualBase2C1Ev
// ELF-LABEL:    define {{.*}} void @_ZN12VirtualBase2C1Ev
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])

// DARWIN-LABEL: define {{.*}} ptr @_ZN8Derived4C1Ev
// ELF-LABEL:    define {{.*}} void @_ZN8Derived4C1Ev
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])

// DARWIN-LABEL: define {{.*}} ptr @_ZN8Derived5C1Ev
// ELF-LABEL:    define {{.*}} void @_ZN8Derived5C1Ev
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])


VirtualBase1 g_vb1;
VirtualBase2 g_vb2;
Derived4 g_d4;
Derived5 g_d5;
extern "C" void cross_check_vtables(Base1 *b1,
                   Base2 *b2,
                   Derived1 *d1,
                   Derived2 *d2,
                   Derived3 *d3,
                   VirtualBase1 *vb1,
                   VirtualBase2 *vb2,
                   Derived4 *d4,
                   Derived4 *d5) {
  asm("; b1->a()" ::: "memory");
  b1->a();
  asm("; b2->b()" ::: "memory");
  b2->b();
  asm("; d1->a()" ::: "memory");
  d1->a();
  asm("; d1->c()" ::: "memory");
  d1->c();
  asm("; d2->a()" ::: "memory");
  d2->a();
  asm("; d2->c()" ::: "memory");
  d2->c();
  asm("; d3->a()" ::: "memory");
  d3->a();
  asm("; d3->b()" ::: "memory");
  d3->b();
  asm("; d3->i()" ::: "memory");
  d3->i();
  asm("; vb1->a()" ::: "memory");
  vb1->a();
  asm("; vb1->f()" ::: "memory");
  vb1->f();
  asm("; vb2->a()" ::: "memory");
  vb2->a();
  asm("; vb2->g()" ::: "memory");
  vb2->g();
  asm("; d4->a()" ::: "memory");
  d4->a();
  asm("; d4->b()" ::: "memory");
  d4->b();
  asm("; d4->f()" ::: "memory");
  d4->f();
  asm("; d4->g()" ::: "memory");
  d4->g();
  asm("; d4->h()" ::: "memory");
  d4->h();
  asm("; d5->a()" ::: "memory");
  d5->a();
  asm("; d5->b()" ::: "memory");
  d5->b();
  asm("; d5->f()" ::: "memory");
  d5->f();
  asm("; d5->g()" ::: "memory");
  d5->g();
  asm("; d5->h()" ::: "memory");
  d5->h();
}
// CHECK-LABEL: define{{.*}} void @cross_check_vtables(
// CHECK: "; b1->a()",
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_A_DISC]])
// CHECK: "; b2->b()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_B_DISC]])
// CHECK: "; d1->a()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_A_DISC]])
// CHECK: "; d1->c()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[DERIVED1_C_DISC]])
// CHECK: "; d2->a()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_A_DISC]])
// CHECK: "; d2->c()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[DERIVED2_C_DISC]])
// CHECK: "; d3->a()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_A_DISC]])
// CHECK: "; d3->b()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_B_DISC]])
// CHECK: "; d3->i()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[DERIVED3_I_DISC]])
// CHECK: "; vb1->a()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_A_DISC]])
// CHECK: "; vb1->f()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[VIRTUALBASE1_F_DISC]])
// CHECK: "; vb2->a()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_A_DISC]])
// CHECK: "; vb2->g()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[VIRTUALBASE2_G_DISC]])
// CHECK: "; d4->a()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_A_DISC]])
// CHECK: "; d4->b()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_B_DISC]])
// CHECK: "; d4->f()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[VIRTUALBASE1_F_DISC]])
// CHECK: "; d4->g()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[VIRTUALBASE2_G_DISC]])
// CHECK: "; d4->h()"
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[DERIVED4_H_DISC]])

// DARWIN-LABEL: define {{.*}} ptr @_ZN5Base1C2Ev
// ELF-LABEL:    define {{.*}} void @_ZN5Base1C2Ev
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])

// DARWIN-LABEL: define {{.*}} ptr @_ZN5Base2C2Ev
// ELF-LABEL:    define {{.*}} void @_ZN5Base2C2Ev
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])

// DARWIN-LABEL: define {{.*}} ptr @_ZN8Derived1C2Ev
// ELF-LABEL:    define {{.*}} void @_ZN8Derived1C2Ev
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])

// DARWIN-LABEL: define {{.*}} ptr @_ZN8Derived2C2Ev
// ELF-LABEL:    define {{.*}} void @_ZN8Derived2C2Ev
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])

// DARWIN-LABEL: define {{.*}} ptr @_ZN8Derived3C2Ev
// ELF-LABEL:    define {{.*}} void @_ZN8Derived3C2Ev
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE1_VTABLE_DISC]])
// CHECK: call i64 @llvm.ptrauth.blend(i64 {{%.*}}, i64 [[BASE2_VTABLE_DISC]])
