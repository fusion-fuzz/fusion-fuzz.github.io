*Fusion-Fuzz Bug Report*

**ID:** `3f8b9a62` &nbsp;·&nbsp; **Signature:** `Assertion: !isCompoundAssignmentOp() && "Use CompoundAssignOperator for compound assignments"` &nbsp;·&nbsp; **RC:** `134`

The following code:

```mm
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

```

Resulted in this output:

```
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpp3cjjpq8/3f8b9a62.mm:109:13: error: synthesized property 'frame' must either be named the same as a compatible instance variable or must explicitly name an instance variable
  109 | @synthesize frame;
      |             ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpp3cjjpq8/3f8b9a62.mm:91:12: warning: class 'I' defined without specifying a base class [-Wobjc-root-class]
   91 | @interface I {
      |            ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpp3cjjpq8/3f8b9a62.mm:91:13: note: add a super class to fix this problem
   91 | @interface I {
      |             ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpp3cjjpq8/3f8b9a62.mm:181:2: error: expected an Objective-C directive after '@'
  181 | @ffl_fusion
      |  ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpp3cjjpq8/3f8b9a62.mm:187:6: warning: function definition inside an Objective-C container is deprecated [-Wfunction-def-in-objc-container]
  187 | void testB0(B *b) {
      |      ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpp3cjjpq8/3f8b9a62.mm:188:12: error: use of undeclared identifier 'b_makeInt'
  188 |   b.b0 = { b_makeInt() };
      |            ^~~~~~~~~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpp3cjjpq8/3f8b9a62.mm:190:6: warning: function definition inside an Objective-C container is deprecated [-Wfunction-def-in-objc-container]
  190 | void testB1(B *b) {
      |      ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpp3cjjpq8/3f8b9a62.mm:191:13: error: use of undeclared identifier 'b_makeInt'
  191 |   b.b1 += { b_makeInt() };
      |             ^~~~~~~~~
clang++: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-project/clang/lib/AST/Expr.cpp:5066: clang::BinaryOperator::BinaryOperator(const clang::ASTContext&, clang::Expr*, clang::Expr*, clang::BinaryOperator::Opcode, clang::QualType, clang::ExprValueKind, clang::ExprObjectKind, clang::SourceLocation, clang::FPOptionsOverride): Assertion `!isCompoundAssignmentOp() && "Use CompoundAssignOperator for compound assignments"' failed.
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and dumped files.
Stack dump:
0.	Program arguments: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin/clang++ -fsyntax-only -Oz -std=c++14 /home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpp3cjjpq8/3f8b9a62.mm
1.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpp3cjjpq8/3f8b9a62.mm:191:26: current parser token ';'
2.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpp3cjjpq8/3f8b9a62.mm:190:19: parsing function body 'testB1'
3.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpp3cjjpq8/3f8b9a62.mm:190:19: in compound statement ('{}')
Stack dump without symbol names (ensure you have llvm-symbolizer in your PATH or set the environment var `LLVM_SYMBOLIZER_PATH` to point to it):
0  clang++   0x000055ae397640f9 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) + 121
1  clang++   0x000055ae39760dcc llvm::sys::RunSignalHandlers() + 76
2  clang++   0x000055ae39761678 llvm::sys::CleanupOnSignal(unsigned long) + 216
3  clang++   0x000055ae396a3f88
4  libc.so.6 0x00007fbd306ed520
5  libc.so.6 0x00007fbd307419fc pthread_kill + 300
6  libc.so.6 0x00007fbd306ed476 raise + 22
7  libc.so.6 0x00007fbd306d37f3 abort + 211
8  libc.so.6 0x00007fbd306d371b
9  libc.so.6 0x00007fbd306e4e96
10 clang++   0x000055ae3d2bfb5b clang::BinaryOperator::BinaryOperator(clang::ASTContext const&, clang::Expr*, clang::Expr*, clang::BinaryOperatorKind, clang::QualType, clang::ExprValueKind, clang::ExprObjectKind, clang::SourceLocation, clang::FPOptionsOverride) + 795
11 clang++   0x000055ae3d2ca2ee clang::BinaryOperator::Create(clang::ASTContext const&, clang::Expr*, clang::Expr*, clang::BinaryOperatorKind, clang::QualType, clang::ExprValueKind, clang::ExprObjectKind, clang::SourceLocation, clang::FPOptionsOverride) + 126
12 clang++   0x000055ae3c88703a clang::SemaPseudoObject::checkAssignment(clang::Scope*, clang::SourceLocation, clang::BinaryOperatorKind, clang::Expr*, clang::Expr*) + 154
13 clang++   0x000055ae3c4ae111 clang::Sema::ActOnBinOp(clang::Scope*, clang::SourceLocation, clang::tok::TokenKind, clang::Expr*, clang::Expr*) + 209
14 clang++   0x000055ae3bf76dd4 clang::Parser::ParseRHSOfBinaryExpression(clang::ActionResult<clang::Expr*, true>, clang::prec::Level) + 772
15 clang++   0x000055ae3bf79d7d clang::Parser::ParseExpression(clang::TypoCorrectionTypeBehavior) + 13
16 clang++   0x000055ae3c009f81 clang::Parser::ParseExprStatement(clang::Parser::ParsedStmtContext) + 81
17 clang++   0x000055ae3c001b7b clang::Parser::ParseStatementOrDeclarationAfterAttributes(llvm::SmallVector<clang::Stmt*, 24u>&, clang::Parser::ParsedStmtContext, clang::SourceLocation*, clang::ParsedAttributes&, clang::ParsedAttributes&, clang::LabelDecl*) + 5547
18 clang++   0x000055ae3c00254b clang::Parser::ParseStatementOrDeclaration(llvm::SmallVector<clang::Stmt*, 24u>&, clang::Parser::ParsedStmtContext, clang::SourceLocation*, clang::LabelDecl*) + 363
19 clang++   0x000055ae3c00a7f7 clang::Parser::ParseCompoundStatementBody(bool) + 1639
20 clang++   0x000055ae3c00b04f clang::Parser::ParseFunctionStatementBody(clang::Decl*, clang::Parser::ParseScope&) + 207
21 clang++   0x000055ae3befe32f clang::Parser::ParseFunctionDefinition(clang::ParsingDeclarator&, clang::Parser::ParsedTemplateInfo const&, clang::LateParsedAttrList*) + 2559
22 clang++   0x000055ae3bf47eb4 clang::Parser::ParseDeclGroup(clang::ParsingDeclSpec&, clang::DeclaratorContext, clang::ParsedAttributes&, clang::Parser::ParsedTemplateInfo&, clang::SourceLocation*, clang::Parser::ForRangeInit*) + 5140
23 clang++   0x000055ae3bef715c clang::Parser::ParseDeclOrFunctionDefInternal(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec&, clang::AccessSpecifier) + 924
24 clang++   0x000055ae3bef7809 clang::Parser::ParseDeclarationOrFunctionDefinition(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec*, clang::AccessSpecifier) + 665
25 clang++   0x000055ae3bfb4ba0 clang::Parser::ParseObjCInterfaceDeclList(clang::tok::ObjCKeywordKind, clang::Decl*) + 480
26 clang++   0x000055ae3bfb6686 clang::Parser::ParseObjCAtInterfaceDeclaration(clang::SourceLocation, clang::ParsedAttributes&) + 1254
27 clang++   0x000055ae3bfb7445 clang::Parser::ParseObjCAtDirectives(clang::ParsedAttributes&, clang::ParsedAttributes&) + 1317
28 clang++   0x000055ae3bf03e70 clang::Parser::ParseExternalDeclaration(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec*) + 2720
29 clang++   0x000055ae3bf047df clang::Parser::ParseTopLevelDecl(clang::OpaquePtr<clang::DeclGroupRef>&, clang::Sema::ModuleImportState&) + 575
30 clang++   0x000055ae3bee170a clang::ParseAST(clang::Sema&, bool, bool) + 586
31 clang++   0x000055ae3a45a071 clang::FrontendAction::Execute() + 65
32 clang++   0x000055ae3a3e3c65 clang::CompilerInstance::ExecuteAction(clang::FrontendAction&) + 1589
33 clang++   0x000055ae3a535ea3 clang::ExecuteCompilerInvocation(clang::CompilerInstance*) + 467
34 clang++   0x000055ae38138c96 cc1_main(llvm::ArrayRef<char const*>, char const*, void*) + 7046
35 clang++   0x000055ae3812ea2a
36 clang++   0x000055ae3812ebbf
37 clang++   0x000055ae3a16b35d
38 clang++   0x000055ae396a43a0 llvm::CrashRecoveryContext::RunSafely(llvm::function_ref<void ()>) + 160
39 clang++   0x000055ae3a16c1b3
40 clang++   0x000055ae3a121987 clang::driver::Compilation::ExecuteCommand(clang::driver::Command const&, clang::driver::Command const*&, bool) const + 167
41 clang++   0x000055ae3a1261e0 clang::driver::Compilation::ExecuteJobs(clang::driver::JobList const&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&, bool) const + 304
42 clang++   0x000055ae3a133e44 clang::driver::Driver::ExecuteCompilation(clang::driver::Compilation&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&) + 404
43 clang++   0x000055ae381342d3 clang_main(int, char**, llvm::ToolContext const&) + 7267
44 clang++   0x000055ae380867a1 main + 113
45 libc.so.6 0x00007fbd306d4d90
46 libc.so.6 0x00007fbd306d4e40 __libc_start_main + 128
47 clang++   0x000055ae3812e055 _start + 37
clang++: error: clang frontend command failed due to signal (use -v to see invocation)
clang version 24.0.0git (https://github.com/llvm/llvm-project.git aefba88f46a6e55645c848f58f6ba56944d5ae62)
Target: x86_64-unknown-linux-gnu
Thread model: posix
InstalledDir: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin
Build config: +assertions
clang++: note: diagnostic msg: 
********************

PLEASE ATTACH THE FOLLOWING CRASH REPRODUCER FILES TO THE BUG REPORT:
clang++: note: diagnostic msg: /tmp/3f8b9a62-327326.mm
clang++: note: diagnostic msg: /tmp/3f8b9a62-327326.sh
clang++: note: diagnostic msg: 

********************
Aborted (core dumped)
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ulimit -v 3145728; ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin/clang++ -fsyntax-only -Oz -std=c++14 "$SCRIPT_DIR/test.mm"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `77447880` | Project seed |
| `b` | `d762c8a7` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
