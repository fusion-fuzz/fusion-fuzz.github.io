// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnu -fclangir -emit-cir %s -o %t.cir
// RUN: FileCheck --check-prefix=CIR --input-file=%t.cir %s
// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnu -fclangir -emit-llvm %s -o %t-cir.ll
// RUN: FileCheck --check-prefix=LLVM,LLVMCIR --input-file=%t-cir.ll %s
// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnu -emit-llvm %s -o %t.ll
// RUN: FileCheck --check-prefix=LLVM,OGCG --input-file=%t.ll %s

// CIR: cir.global external @derived = #cir.const_record<{#cir.const_record<{#cir.int<1> : !s32i}> : !rec_Base, #cir.const_record<{#cir.int<2> : !s32i}> : !rec_PtrToIntUnion}> : !rec_Derived
// LLVMCIR: @derived = global { %struct.Base, [4 x i8], { i32, [4 x i8] } } { %struct.Base { i32 1 }, [4 x i8] zeroinitializer, { i32, [4 x i8] } { i32 2, [4 x i8] zeroinitializer } }
// OGCG: @derived = global { i32, [4 x i8], { i32, [4 x i8] } } { i32 1, [4 x i8] undef, { i32, [4 x i8] } { i32 2, [4 x i8] undef } }, align 8
// CIR: cir.global external @derivedFromDerived = #cir.const_record<{#cir.const_record<{#cir.const_record<{#cir.int<1> : !s32i}> : !rec_Base, #cir.const_record<{#cir.int<2> : !s32i}> : !rec_PtrToIntUnion}> : !rec_Derived, #cir.int<3> : !s32i, #cir.zero : !cir.array<!u8i x 4>}> : !rec_DerivedFromDerived
// LLVMCIR: @derivedFromDerived = global <{ { %struct.Base, [4 x i8], { i32, [4 x i8] } }, i32, [4 x i8] }> <{ { %struct.Base, [4 x i8], { i32, [4 x i8] } } { %struct.Base { i32 1 }, [4 x i8] zeroinitializer, { i32, [4 x i8] } { i32 2, [4 x i8] zeroinitializer } }, i32 3, [4 x i8] zeroinitializer }>
// OGCG: @derivedFromDerived = global { i32, [4 x i8], { i32, [4 x i8] }, i32, [4 x i8] } { i32 1, [4 x i8] undef, { i32, [4 x i8] } { i32 2, [4 x i8] undef }, i32 3, [4 x i8] undef }, align 8


// In C++ mode, this doesn't do zero padding.


  // CIR-LABEL: cir.func {{.*}} @ret_trivial() -> !s32i
  // CIR: %[[RET_ALLOCA:.*]] = cir.alloca "__retval" {{.*}} : !cir.ptr<!rec_Trivial>
  // CIR: %[[GET_A:.*]] = cir.get_member %[[RET_ALLOCA]][0] {name = "a"}
  // CIR: %[[ZERO:.*]] = cir.const #cir.int<0>
  // CIR: cir.store{{.*}} %[[ZERO]], %[[GET_A]]
  // CIR: %[[RET_I32:.*]] = cir.cast bitcast %[[RET_ALLOCA]] : !cir.ptr<!rec_Trivial> -> !cir.ptr<!s32i>
  // CIR-NEXT: %[[RET:.*]] = cir.load align(4) %[[RET_I32]] : !cir.ptr<!s32i>, !s32i
  // CIR-NEXT: cir.return %[[RET]] : !s32i

  // LLVM-LABEL: define dso_local i32 @ret_trivial()
  // LLVM: %[[RET_ALLOCA:.*]] = alloca %union.Trivial
  // LLVM: store i32 0, ptr %[[RET_ALLOCA]]
  // LLVMCIR: %[[RET:.*]] = load i32, ptr %[[RET_ALLOCA]], align 4
  // OGCG: %[[COERCE_DIVE:.*]] = getelementptr inbounds nuw %union.Trivial, ptr %[[RET_ALLOCA]], i32 0, i32 0
  // OGCG: %[[RET:.*]] = load i32, ptr %[[COERCE_DIVE]]
  // LLVM: ret i32 %[[RET]]

// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnu -fclangir -emit-cir %s -o %t.cir
// RUN: FileCheck --check-prefix=CIR --input-file=%t.cir %s
// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnu -fclangir -emit-llvm %s -o %t-cir.ll
// RUN: FileCheck --check-prefix=LLVM,LLVMCIR --input-file=%t-cir.ll %s
// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnu -emit-llvm %s -o %t.ll
// RUN: FileCheck --check-prefix=LLVM,OGCG --input-file=%t.ll %s

union PtrToIntUnion { int id; char *str; };
struct Base { int b; };
struct Derived : Base { union PtrToIntUnion u; };
struct DerivedFromDerived : Derived { int i; };
Derived derived = { { 1 }, { 2 } };
// CIR: cir.global external @derived = #cir.const_record<{#cir.const_record<{#cir.int<1> : !s32i}> : !rec_Base, #cir.const_record<{#cir.int<2> : !s32i}> : !rec_PtrToIntUnion}> : !rec_Derived
// LLVMCIR: @derived = global { %struct.Base, [4 x i8], { i32, [4 x i8] } } { %struct.Base { i32 1 }, [4 x i8] zeroinitializer, { i32, [4 x i8] } { i32 2, [4 x i8] zeroinitializer } }
// OGCG: @derived = global { i32, [4 x i8], { i32, [4 x i8] } } { i32 1, [4 x i8] undef, { i32, [4 x i8] } { i32 2, [4 x i8] undef } }, align 8
DerivedFromDerived derivedFromDerived = { { { 1 }, { 2 } }, 3};
// CIR: cir.global external @derivedFromDerived = #cir.const_record<{#cir.const_record<{#cir.const_record<{#cir.int<1> : !s32i}> : !rec_Base, #cir.const_record<{#cir.int<2> : !s32i}> : !rec_PtrToIntUnion}> : !rec_Derived, #cir.int<3> : !s32i, #cir.zero : !cir.array<!u8i x 4>}> : !rec_DerivedFromDerived
// LLVMCIR: @derivedFromDerived = global <{ { %struct.Base, [4 x i8], { i32, [4 x i8] } }, i32, [4 x i8] }> <{ { %struct.Base, [4 x i8], { i32, [4 x i8] } } { %struct.Base { i32 1 }, [4 x i8] zeroinitializer, { i32, [4 x i8] } { i32 2, [4 x i8] zeroinitializer } }, i32 3, [4 x i8] zeroinitializer }>
// OGCG: @derivedFromDerived = global { i32, [4 x i8], { i32, [4 x i8] }, i32, [4 x i8] } { i32 1, [4 x i8] undef, { i32, [4 x i8] } { i32 2, [4 x i8] undef }, i32 3, [4 x i8] undef }, align 8

typedef union vec3 {
  struct { double x, y, z; };
  double component[3];
} vec3;

// In C++ mode, this doesn't do zero padding.
extern "C" vec3 ret_vec3() {
  // CIR-LABEL: cir.func {{.*}} @ret_vec3
  // CIR-SAME: (%[[RET_ALLOCA:.*]]: !cir.ptr<!rec_vec3> {{.*}}llvm.sret = !rec_vec3{{.*}})
  // CIR: %[[GET_ANON:.*]] = cir.get_member %[[RET_ALLOCA]][0] {name = ""}
  // CIR: %[[GET_X:.*]] = cir.get_member %[[GET_ANON]][0] {name = "x"}
  // CIR: %[[FIVE:.*]] = cir.const #cir.fp<5.{{.*}}> : !cir.double
  // CIR: cir.store{{.*}} %[[FIVE]], %[[GET_X]]
  // CIR: %[[GET_Y:.*]] = cir.get_member %[[GET_ANON]][1] {name = "y"}
  // CIR: %[[ZERO:.*]] = cir.const #cir.fp<0.{{.*}}> : !cir.double
  // CIR: cir.store{{.*}} %[[ZERO]], %[[GET_Y]]
  // CIR: %[[GET_Z:.*]] = cir.get_member %[[GET_ANON]][2] {name = "z"}
  // CIR: %[[ZERO:.*]] = cir.const #cir.fp<0.{{.*}}> : !cir.double
  // CIR: cir.store{{.*}} %[[ZERO]], %[[GET_Z]]

  // LLVM-LABEL: define dso_local void @ret_vec3
  // LLVM-SAME: (ptr dead_on_unwind noalias writable sret(%union.vec3) align 8 %[[RET_ALLOCA:.*]])
  // LLVM: %[[GET_X:.*]] = getelementptr {{.*}}, ptr %[[RET_ALLOCA]], i32 0, i32 0
  // LLVM: store double 5{{.*}}, ptr %[[GET_X]]
  // LLVM: %[[GET_Y:.*]] = getelementptr {{.*}}, ptr %[[RET_ALLOCA]], i32 0, i32 1
  // LLVM: store double 0{{.*}}, ptr %[[GET_Y]]
  // LLVM: %[[GET_Z:.*]] = getelementptr {{.*}}, ptr %[[RET_ALLOCA]], i32 0, i32 2
  // LLVM: store double 0{{.*}}, ptr %[[GET_Z]]
  return (vec3) {{ .x = 5.0 }};
}

typedef union Trivial {
  int a;
} Trivial;

extern "f" Trivial ret_trivial() { return {}; }
  // CIR-LABEL: cir.func {{.*}} @ret_trivial() -> !s32i
  // CIR: %[[RET_ALLOCA:.*]] = cir.alloca "__retval" {{.*}} : !cir.ptr<!rec_Trivial>
  // CIR: %[[GET_A:.*]] = cir.get_member %[[RET_ALLOCA]][0] {name = "a"}
  // CIR: %[[ZERO:.*]] = cir.const #cir.int<0>
  // CIR: cir.store{{.*}} %[[ZERO]], %[[GET_A]]
  // CIR: %[[RET_I32:.*]] = cir.cast bitcast %[[RET_ALLOCA]] : !cir.ptr<!rec_Trivial> -> !cir.ptr<!s32i>
  // CIR-NEXT: %[[RET:.*]] = cir.load align(4) %[[RET_I32]] : !cir.ptr<!s32i>, !s32i
  // CIR-NEXT: cir.return %[[RET]] : !s32i

  // LLVM-LABEL: define dso_local i32 @ret_trivial()
  // LLVM: %[[RET_ALLOCA:.*]] = alloca %union.Trivial
  // LLVM: store i32 0, ptr %[[RET_ALLOCA]]
  // LLVMCIR: %[[RET:.*]] = load i32, ptr %[[RET_ALLOCA]], align 4
  // OGCG: %[[COERCE_DIVE:.*]] = getelementptr inbounds nuw %union.Trivial, ptr %[[RET_ALLOCA]], i32 0, i32 0
  // OGCG: %[[RET:.*]] = load i32, ptr %[[COERCE_DIVE]]
  // LLVM: ret i32 %[[RET]]

// RUN: %clang_cc1 %s -Wpotentially-direct-selector -verify
// RUN: %clang_cc1 %s -Wstrict-potentially-direct-selector -verify=expected,strict

#define NS_DIRECT __attribute__((objc_direct))

__attribute__((objc_root_class))
@interface Dummies
-(void)inBase;
-(void)inBaseImpl;
-(void)inBaseCat;
-(void)inBaseCatImpl;
-(void)inDerived;
-(void)inDerivedImpl;
-(void)inDerivedCat;
-(void)inDerivedCatImpl;
+(void)inBaseClass;
+(void)inDerivedClass;
+(void)inDerivedCatClass;
@end

__attribute__((objc_root_class))
@interface Base
-(void)inBase NS_DIRECT;
// expected-note + {{direct method}}
+(void)inBaseClass NS_DIRECT;
// expected-note + {{direct method}}
@end

@implementation Base
-(void)inBaseImpl NS_DIRECT { // expected-note + {{direct method}}
}
-(void)inBase {}
+(void)inBaseClass {}
@end

@interface Base (Cat)
-(void)inBaseCat NS_DIRECT;
// expected-note + {{direct method}}
@end

@implementation Base (Cat)
-(void)inBaseCatImpl NS_DIRECT { // expected-note + {{direct method}}
}
-(void)inBaseCat {}
@end

@interface Derived : Base
-(void)inDerived NS_DIRECT;
// expected-note + {{direct method}}
+(void)inDerivedClass NS_DIRECT;
// expected-note + {{direct method}}
@end

@implementation Derived
-(void)inDerivedImpl NS_DIRECT { // expected-note + {{direct method}}
}
-(void)inDerived {}
+(void)inDerivedClass {}
@end

@interface Derived (Cat)
-(void)inDerivedCat NS_DIRECT;
// expected-note + {{direct method}}
+(void)inDerivedCatClass NS_DIRECT;
// expected-note + {{direct method}}
@end

@implementation Derived (Cat)
-(void)inDerivedCatImpl NS_DIRECT { // expected-note + {{direct method}}
}
-(void)inDerivedCat {}
+(void)inDerivedCatClass {}
-(void)test1 {
  (void)@selector(inBase); // expected-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inBaseImpl); // expected-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inBaseCat); // expected-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inBaseCatImpl); // expected-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inDerived); // expected-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inDerivedImpl); // expected-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inDerivedCat); // expected-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inDerivedCatImpl); // expected-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inDerivedClass); // expected-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inBaseClass); // expected-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inDerivedCatClass); // expected-warning{{@selector expression formed with potentially direct selector}}
}
static struct DerivedFromDerived ffl_DerivedFromDeriv;
@end

void test2(void) {
    (void)ffl_DerivedFromDeriv;
  (void)@selector(inBase); // strict-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inBaseImpl); // strict-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inBaseCat); // strict-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inBaseCatImpl); // strict-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inDerived); // strict-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inDerivedImpl); // strict-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inDerivedCat); // strict-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inDerivedCatImpl); // strict-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inDerivedClass); // strict-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inBaseClass); // strict-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inDerivedCatClass); // strict-warning{{@selector expression formed with potentially direct selector}}
}
@interface OnlyBase : Base @end
@implementation OnlyBase
-(void)test3 {
  (void)@selector(inBase); // expected-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inBaseImpl); // expected-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inBaseCat); // expected-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inBaseCatImpl); // expected-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inDerived); // strict-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inDerivedImpl); // strict-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inDerivedCat); // strict-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inDerivedCatImpl); // strict-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inDerivedClass); // strict-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inBaseClass); // expected-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inDerivedCatClass); // strict-warning{{@selector expression formed with potentially direct selector}}
}
@end

__attribute__((objc_root_class))
@interface Unrelated @end
@implementation Unrelated
-(void)test4 {
  (void)@selector(inBase); // strict-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inBaseImpl); // strict-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inBaseCat); // strict-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inBaseCatImpl); // strict-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inDerived); // strict-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inDerivedImpl); // strict-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inDerivedCat); // strict-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inDerivedCatImpl); // strict-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inDerivedClass); // strict-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inBaseClass); // strict-warning{{@selector expression formed with potentially direct selector}}
  (void)@selector(inDerivedCatClass); // strict-warning{{@selector expression formed with potentially direct selector}}
}
@end

@implementation Dummies
-(void)inBase {}
-(void)inBaseImpl {}
-(void)inBaseCat {}
-(void)inBaseCatImpl {}
-(void)inDerived {}
-(void)inDerivedImpl {}
-(void)inDerivedCat {}
-(void)inDerivedCatImpl {}
+(void)inBaseClass {}
+(void)inDerivedClass {}
+(void)inDerivedCatClass {}
-(void)test5 {
  (void)@selector(inBase);
  (void)@selector(inBaseImpl);
  (void)@selector(inBaseCat);
  (void)@selector(inBaseCatImpl);
  (void)@selector(inDerived);
  (void)@selector(inDerivedImpl);
  (void)@selector(inDerivedCat);
  (void)@selector(inDerivedCatImpl);
  (void)@selector(inDerivedClass);
  (void)@selector(inBaseClass);
  (void)@selector(inDerivedCatClass);
}
@end
