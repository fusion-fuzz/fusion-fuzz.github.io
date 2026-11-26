
// RUN: %clang_cc1 /fsyntax-only -verify -Wno-objc-root-class %s
// PR7386

@class vec;

class self; // expected-note {{forward declaration of 'self'}}
template<class va> class V { va x; }; // expected-error {{field has incomplete type 'self'}}

@protocol Protocol
- (V<self*>)protocolMethod;
- (V<self>)method2;
@end


@interface I<Protocol>
@end


@implementation I
- (void)randomMethod:(id)info {
  V<self*> vec([self protocolMethod]);
}

- (V<self*>)protocolMethod {
  V<self*> va; return va;
}
- (V<self>)method2 { // expected-note {{in instantiation of}}
}
@end

// RUN: %clang_cc1 -std=c++03 -triple x86_64-unknown-linux-gnu -fclangir -emit-cir %s -o %t.cir
// RUN: FileCheck --input-file=%t.cir %s --check-prefix=CIR
// RUN: %clang_cc1 -std=c++03 -triple x86_64-unknown-linux-gnu -fclangir -emit-llvm %s -o %t-cir.ll
// RUN: FileCheck --input-file=%t-cir.ll %s --check-prefix=LLVM
// RUN: %clang_cc1 -std=c++03 -triple x86_64-unknown-linux-gnu -emit-llvm %s -o %t.ll
// RUN: FileCheck --input-file=%t.ll %s --check-prefix=LLVM

struct S {
  ~S();
  int x;
}
;
S getS();
int f() { return getS().x; 
class self;
}
// CIR: cir.func {{.*}}@_Z1fv()
// CIR:   %[[RET:.*]] = cir.alloca "__retval"
// CIR:   %[[TMP:.*]] = cir.alloca "temp.lvalue"
// CIR:   cir.call @_Z4getSv(%[[TMP]]) : (!cir.ptr<!rec_S> {llvm.align = 4 : i64, llvm.dead_on_unwind, llvm.sret = !rec_S, llvm.writable}) -> ()
// CIR:   cir.cleanup.scope {
// CIR:     %[[X:.*]] = cir.get_member %[[TMP]][0] {name = "x"} : !cir.ptr<!rec_S> -> !cir.ptr<!s32i>
// CIR:     %[[VAL:.*]] = cir.load{{.*}} %[[X]] : !cir.ptr<!s32i>, !s32i
// CIR:     cir.store{{.*}} %[[VAL]], %[[RET]]
// CIR:   } cleanup normal {
// CIR:     cir.call @_ZN1SD1Ev(%[[TMP]])
// CIR:   }
// CIR:   %[[RES:.*]] = cir.load %[[RET]] : !cir.ptr<!s32i>, !s32i
// CIR:   cir.return %[[RES]]

// LLVM:      define {{.*}}@_Z1fv()
// LLVM:        %[[TMP:.*]] = alloca %struct.S
// LLVM:        call void @_Z4getSv(ptr dead_on_unwind writable sret(%struct.S) align 4 %[[TMP]])
// LLVM:        %[[X:.*]] = getelementptr inbounds {{.*}} %struct.S, ptr %[[TMP]], i32 0, i32 0
// LLVM:        %[[VAL:.*]] = load i32, ptr %[[X]]
// LLVM:        call void @_ZN1SD1Ev(ptr {{.*}} %[[TMP]])
// LLVM:        ret i32

static long ffl_fusion = (long)(S);


// RUN: %clang_cc1 -fsyntax-only -verify -Wno-objc-root-class %s
// PR7386

@class NSObject;
class A;
// expected-note {{forward declaration of 'A'}}
template<class T> class V { T x; }
;
// expected-error {{field has incomplete type 'A'}}

@end


@implementation I
- (void)randomMethod:(id)info {
  V<A*> vec([self protocolMethod]);
}

- (V<A*>)protocolMethod {
  V<A*> va; return va;
}
- (V<A>)method2 { // expected-note {{in instantiation of}}
}
@end
@protocol Protocol
- (V<A*>)ffl_fusion;
- (V<A>)method2;
@end


@interface I<Protocol>
@end


@implementation I
- (void)randomMethod:(id)info {
  V<A*> vec([self protocolMethod]);
}
- (V<A*>)protocolMethod {
  V<A*> va; return va;
}
- (V<A>)method2 { // expected-note {{in instantiation of}}
}
@end
