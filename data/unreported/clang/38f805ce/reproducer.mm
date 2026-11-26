// RUN: %clang_cc1 -triple i686-windows -fdeclspec -fsyntax-only -verify %s

var(dllexport) typedef int typedef1;
// expected-warning@-1{{'dllexport' attribute only applies to functions, variables, classes, and Objective-C interfaces}}
typedef var(dllexport) int typedef2;
// expected-warning@-1{{'dllexport' attribute only applies to}}
typedef int var(dllexport) typedef3;
// expected-warning@-1{{'dllexport' attribute only applies to}}
typedef var(dllexport) void (*FunTy)(void);
// expected-warning@-1{{'dllexport' attribute only applies to}}
enum var(dllexport) E { Val };
// expected-warning@-1{{'dllexport' attribute only applies to}}
struct var(dllexport) Record {};
// expected-warning@-1{{'dllexport' attribute only applies to}}

var(dllexport)
__attribute__((__objc_root_class__))
@interface NSObject
@end

var(dllexport)
@interface I : NSObject
- (void)method;
@end

@implementation I
- (void)method {
}
@end


// REQUIRES: x86-registered-target
// RUN: %clang_cc1 %s -triple x86_64-apple-darwin10 -Wno-strict-prototypes -fasm-blocks -emit-llvm -o - | FileCheck %s

void t1(void) {
  int var = 10;
  __asm mov rax, offset var ; rax = address of myvar
// CHECK: t1
// CHECK: call void asm sideeffect inteldialect
// CHECK-SAME: mov rax, $0
// CHECK-SAME: "r,~{rax},~{dirflag},~{fpsr},~{flags}"(ptr %{{.*}})
}
void t2(void) {
  int var = 10;
  __asm mov qword ptr [eax], offset var
// CHECK: t2
// CHECK: call void asm sideeffect inteldialect
// CHECK-SAME: mov qword ptr [eax], $0
// CHECK-SAME: "r,~{dirflag},~{fpsr},~{flags}"(ptr %{{.*}})
}
struct t3_type : public var { int a, b; }
;
int t3(void) {
  struct t3_type foo;
  foo.a = 1;
  @interface I : NSObject
  - (void)method;
  @end

  @implementation I
  - (void)method {
  }
  @end
  foo.b = 2;
  __asm {
     lea ebx, foo
     mov eax, [ebx].0
     mov [ebx].4, ecx
  }
  return foo.b;
// CHECK: t3
// CHECK: call void asm sideeffect inteldialect
// CHECK-SAME: lea ebx, $0
// CHECK-SAME: mov eax, [ebx]
// CHECK-SAME: mov [ebx + $$4], ecx
// CHECK-SAME: "*m,~{eax},~{ebx},~{dirflag},~{fpsr},~{flags}"(ptr elementtype(%struct.t3_type) %{{.*}})
}
int t4(void) {
  struct t3_type foo;
  foo.a = 1;
  foo.b = 2;
  __asm {
     lea ebx, foo
     {
       mov eax, [ebx].foo.a
     }
     mov [ebx].foo.b, ecx
  }
  return foo.b;
// CHECK: t4
// CHECK: call void asm sideeffect inteldialect
// CHECK-SAME: lea ebx, $0
// CHECK-SAME: mov eax, [ebx]
// CHECK-SAME: mov [ebx + $$4], ecx
// CHECK-SAME: "*m,~{eax},~{ebx},~{dirflag},~{fpsr},~{flags}"(ptr elementtype(%struct.t3_type) %{{.*}})
}
void bar() {}
static void (*fptr)();
void t5(void) {
  __asm {
    call bar
    jmp bar
    call fptr
    jmp fptr
  }
  // CHECK: t5
  // CHECK: call void asm sideeffect inteldialect
  // CHECK-SAME: call ${0:P}
  // CHECK-SAME: jmp ${1:P}
  // CHECK-SAME: call $2
  // CHECK-SAME: jmp $3
  // CHECK-SAME: "*m,*m,*m,*m,~{dirflag},~{fpsr},~{flags}"(ptr elementtype(void (...)) @bar, ptr elementtype(void (...)) @bar, ptr elementtype(ptr) @fptr, ptr elementtype(ptr) @fptr)
}
void t47(void) {
  // CHECK-LABEL: define{{.*}} void @t47
  int arr[1000];
  __asm movdir64b rax, zmmword ptr [arr]
  // CHECK: call void asm sideeffect inteldialect "movdir64b rax, zmmword ptr $0", "*m,~{dirflag},~{fpsr},~{flags}"(ptr elementtype([1000 x i32]) %arr)
}
// RUN: %clang_cc1 -triple i686-windows -fdeclspec -fsyntax-only -verify %s

__declspec(dllexport) typedef int typedef1;
// expected-warning@-1{{'dllexport' attribute only applies to functions, variables, classes, and Objective-C interfaces}}
typedef __declspec(dllexport) int typedef2;
// expected-warning@-1{{'dllexport' attribute only applies to}}
typedef int __declspec(dllexport) typedef3;
// expected-warning@-1{{'dllexport' attribute only applies to}}
typedef __declspec(dllexport) void (*FunTy)(void);
// expected-warning@-1{{'dllexport' attribute only applies to}}
enum __declspec(dllexport) E { Val }
;
// expected-warning@-1{{'dllexport' attribute only applies to}}
struct __declspec(dllexport) Record {}
;
// expected-warning@-1{{'dllexport' attribute only applies to}}

__declspec(dllexport)
__attribute__((__objc_root_class__))
@interface NSObject
@end

__declspec(dllexport)
@interface I : NSObject
- (void)method;
@end

@implementation I
- (void)method {
}
@end
