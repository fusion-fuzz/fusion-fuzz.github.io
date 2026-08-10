*Fusion-Fuzz Bug Report*

**ID:** `098f7f73` &nbsp;·&nbsp; **Signature:** `Assertion: !E->isFileScope() && "file-scope compound literal did not have constant initializer!"` &nbsp;·&nbsp; **RC:** `134`

The following code:

```cpp
// FIXME: These test cases currently crash during codegen, despite initializers
// for CLEs being constant.
// RUN: not --crash %clang_cc1 -verify -std=c++20 -emit-llvm %s -o -
// expected-no-diagnostics
namespace case1 {
struct RR { int&& r; };
struct Z { RR* x; };
constinit Z z = { (RR[1]){1} };
}


namespace case2 {
struct RR { int r; };
struct Z { int x; const RR* y; int z; };
inline int f() { return 0; }
Z z2 = { 10, (const RR[1]){__builtin_constant_p(z2.x)}, z2.y->r+f() };
}

static long ffl_fusion = (long)(r);

// RUN: %clang_cc1 %s -verify -fsyntax-only -Wvector-conversion -triple x86_64-apple-darwin10
typedef unsigned int v2u __attribute__ ((vector_size (8)));
typedef int v2s __attribute__ ((vector_size (8)));
typedef float v2f __attribute__ ((vector_size(8)));

void test1(v2u v2ua, v2s v2sa, v2f v2fa) {
  // Bitwise binary operators
  (void)(v2ua & v2ua);
  (void)(v2fa & v2fa); // expected-error{{invalid operands to binary expression}}

  // Unary operators
  (void)(~v2ua);
  (void)(~v2fa); // expected-error{{invalid argument type 'v2f' (vector of 2 'float' values) to unary}}

  // Comparison operators
  v2ua = (v2ua==v2sa); // expected-warning{{incompatible vector types assigning to 'v2u' (vector of 2 'unsigned int' values) from '__attribute__((__vector_size__(2 * sizeof(int)))) int' (vector of 2 'int' values}}
  v2sa = (v2ua==v2sa);

  // Arrays
  int array1[v2ua]; // expected-error{{size of array has non-integer type 'v2u' (vector of 2 'unsigned int' values}}
  int array2[17];
  // FIXME: error message below needs type!
  (void)(array2[v2ua]); // expected-error{{array subscript is not an integer}}

  v2u *v2u_ptr = 0;
  v2s *v2s_ptr;
  v2s_ptr = v2u_ptr; // expected-warning{{converts between pointers to integer types with different sign}}
}

void testLogicalVecVec(v2u v2ua, v2s v2sa, v2f v2fa) {
  // Logical operators
  v2ua = v2ua && v2ua; // expected-error {{logical expression with vector types 'v2u' (vector of 2 'unsigned int' values) and 'v2u'}}
  v2ua = v2ua || v2ua; // expected-error {{logical expression with vector types 'v2u' (vector of 2 'unsigned int' values) and 'v2u'}}

  v2ua = v2sa && v2ua; // expected-error {{logical expression with vector types 'v2s' (vector of 2 'int' values) and 'v2u' (vector of 2 'unsigned int' values)}}
  v2ua = v2sa || v2ua; // expected-error {{logical expression with vector types 'v2s' (vector of 2 'int' values) and 'v2u' (vector of 2 'unsigned int' values)}}

  v2ua = v2ua && v2fa; // expected-error {{logical expression with vector types 'v2u' (vector of 2 'unsigned int' values) and 'v2f' (vector of 2 'float' values)}}
  v2ua = v2ua || v2fa; // expected-error {{logical expression with vector types 'v2u' (vector of 2 'unsigned int' values) and 'v2f' (vector of 2 'float' values)}}

  v2ua = v2sa && v2fa; // expected-error {{logical expression with vector types 'v2s' (vector of 2 'int' values) and 'v2f' (vector of 2 'float' values)}}
  v2ua = v2sa || v2fa; // expected-error {{logical expression with vector types 'v2s' (vector of 2 'int' values) and 'v2f' (vector of 2 'float' values)}}

  v2sa = v2sa && v2sa; // expected-error {{logical expression with vector types 'v2s' (vector of 2 'int' values) and 'v2s'}}
  v2sa = v2sa || v2sa; // expected-error {{logical expression with vector types 'v2s' (vector of 2 'int' values) and 'v2s'}}

  v2sa = v2ua && v2ua; // expected-error {{logical expression with vector types 'v2u' (vector of 2 'unsigned int' values) and 'v2u'}}
  v2sa = v2ua || v2ua; // expected-error {{logical expression with vector types 'v2u' (vector of 2 'unsigned int' values) and 'v2u'}}

  v2sa = v2sa && v2ua; // expected-error {{logical expression with vector types 'v2s' (vector of 2 'int' values) and 'v2u' (vector of 2 'unsigned int' values)}}
  v2sa = v2sa || v2ua; // expected-error {{logical expression with vector types 'v2s' (vector of 2 'int' values) and 'v2u' (vector of 2 'unsigned int' values)}}

  v2sa = v2sa && v2fa; // expected-error {{logical expression with vector types 'v2s' (vector of 2 'int' values) and 'v2f' (vector of 2 'float' values)}}
  v2sa = v2sa || v2fa; // expected-error {{logical expression with vector types 'v2s' (vector of 2 'int' values) and 'v2f' (vector of 2 'float' values)}}

  v2sa = v2ua && v2fa; // expected-error {{logical expression with vector types 'v2u' (vector of 2 'unsigned int' values) and 'v2f' (vector of 2 'float' values)}}
  v2sa = v2ua || v2fa; // expected-error {{logical expression with vector types 'v2u' (vector of 2 'unsigned int' values) and 'v2f' (vector of 2 'float' values)}}

  v2fa = v2fa && v2fa; // expected-error {{logical expression with vector types 'v2f' (vector of 2 'float' values) and 'v2f'}}
  v2fa = v2fa || v2fa; // expected-error {{logical expression with vector types 'v2f' (vector of 2 'float' values) and 'v2f'}}

  v2fa = v2sa && v2fa; // expected-error {{logical expression with vector types 'v2s' (vector of 2 'int' values) and 'v2f' (vector of 2 'float' values)}}
  v2fa = v2sa || v2fa; // expected-error {{logical expression with vector types 'v2s' (vector of 2 'int' values) and 'v2f' (vector of 2 'float' values)}}

  v2fa = v2ua && v2fa; // expected-error {{logical expression with vector types 'v2u' (vector of 2 'unsigned int' values) and 'v2f' (vector of 2 'float' values)}}
  v2fa = v2ua || v2fa; // expected-error {{logical expression with vector types 'v2u' (vector of 2 'unsigned int' values) and 'v2f' (vector of 2 'float' values)}}

  v2fa = v2ua && v2ua; // expected-error {{logical expression with vector types 'v2u' (vector of 2 'unsigned int' values) and 'v2u'}}
  v2fa = v2ua || v2ua; // expected-error {{logical expression with vector types 'v2u' (vector of 2 'unsigned int' values) and 'v2u'}}

  v2fa = v2sa && v2sa; // expected-error {{logical expression with vector types 'v2s' (vector of 2 'int' values) and 'v2s'}}
  v2fa = v2sa || v2sa; // expected-error {{logical expression with vector types 'v2s' (vector of 2 'int' values) and 'v2s'}}

  v2fa = v2sa && v2ua; // expected-error {{logical expression with vector types 'v2s' (vector of 2 'int' values) and 'v2u' (vector of 2 'unsigned int' values)}}
  v2fa = v2sa || v2ua; // expected-error {{logical expression with vector types 'v2s' (vector of 2 'int' values) and 'v2u' (vector of 2 'unsigned int' values)}}
}

void testLogicalVecScalar(v2u v2ua, v2s v2sa, v2f v2fa) {
  unsigned u1;
  v2ua = v2ua && u1; // expected-error {{logical expression with vector type 'v2u' (vector of 2 'unsigned int' values) and non-vector type 'unsigned int' is only supported in C++}} 
  v2ua = v2ua || u1; // expected-error {{logical expression with vector type 'v2u' (vector of 2 'unsigned int' values) and non-vector type 'unsigned int' is only supported in C++}} 

  v2sa = v2sa && u1; // expected-error {{cannot convert between scalar type 'unsigned int' and vector type 'v2s' (vector of 2 'int' values) as implicit conversion would cause truncation}} expected-error {{invalid operands to binary expression ('v2s' (vector of 2 'int' values) and 'unsigned int')}}
  v2sa = v2sa || u1; // expected-error {{cannot convert between scalar type 'unsigned int' and vector type 'v2s' (vector of 2 'int' values) as implicit conversion would cause truncation}} expected-error {{invalid operands to binary expression ('v2s' (vector of 2 'int' values) and 'unsigned int')}}

  v2ua = v2sa && u1; // expected-error {{cannot convert between scalar type 'unsigned int' and vector type 'v2s' (vector of 2 'int' values) as implicit conversion would cause truncation}} expected-error {{invalid operands to binary expression ('v2s' (vector of 2 'int' values) and 'unsigned int')}}
  v2ua = v2sa || u1; // expected-error {{cannot convert between scalar type 'unsigned int' and vector type 'v2s' (vector of 2 'int' values) as implicit conversion would cause truncation}} expected-error {{invalid operands to binary expression ('v2s' (vector of 2 'int' values) and 'unsigned int')}}
  v2sa = v2ua && u1; // expected-error {{logical expression with vector type 'v2u' (vector of 2 'unsigned int' values) and non-vector type 'unsigned int' is only supported in C++}}
  v2sa = v2ua || u1; // expected-error {{logical expression with vector type 'v2u' (vector of 2 'unsigned int' values) and non-vector type 'unsigned int' is only supported in C++}}

  v2ua = v2fa && u1; // expected-error {{cannot convert between scalar type 'unsigned int' and vector type 'v2f' (vector of 2 'float' values) as implicit conversion would cause truncation}} expected-error {{invalid operands to binary expression ('v2f' (vector of 2 'float' values) and 'unsigned int')}}
  v2ua = v2fa || u1; // expected-error {{cannot convert between scalar type 'unsigned int' and vector type 'v2f' (vector of 2 'float' values) as implicit conversion would cause truncation}} expected-error {{invalid operands to binary expression ('v2f' (vector of 2 'float' values) and 'unsigned int')}}

  v2sa = v2fa && u1; // expected-error {{cannot convert between scalar type 'unsigned int' and vector type 'v2f' (vector of 2 'float' values) as implicit conversion would cause truncation}} expected-error {{invalid operands to binary expression ('v2f' (vector of 2 'float' values) and 'unsigned int')}}
  v2sa = v2fa || u1; // expected-error {{cannot convert between scalar type 'unsigned int' and vector type 'v2f' (vector of 2 'float' values) as implicit conversion would cause truncation}} expected-error {{invalid operands to binary expression ('v2f' (vector of 2 'float' values) and 'unsigned int')}}

  int s1;
  v2ua = v2ua && s1; // expected-error {{logical expression with vector type 'v2u' (vector of 2 'unsigned int' values) and non-vector type 'int' is only supported in C++}}
  v2ua = v2ua || s1; // expected-error {{logical expression with vector type 'v2u' (vector of 2 'unsigned int' values) and non-vector type 'int' is only supported in C++}}

  v2sa = v2sa && s1; // expected-error {{logical expression with vector type 'v2s' (vector of 2 'int' values) and non-vector type 'int' is only supported in C++}}
  v2sa = v2sa || s1; // expected-error {{logical expression with vector type 'v2s' (vector of 2 'int' values) and non-vector type 'int' is only supported in C++}}

  v2ua = v2sa && s1; // expected-error {{logical expression with vector type 'v2s' (vector of 2 'int' values) and non-vector type 'int' is only supported in C++}}
  v2ua = v2sa || s1; // expected-error {{logical expression with vector type 'v2s' (vector of 2 'int' values) and non-vector type 'int' is only supported in C++}}

  v2sa = v2ua && ffl_fusion; // expected-error {{logical expression with vector type 'v2u' (vector of 2 'unsigned int' values) and non-vector type 'int' is only supported in C++}}
  v2sa = v2ua || s1; // expected-error {{logical expression with vector type 'v2u' (vector of 2 'unsigned int' values) and non-vector type 'int' is only supported in C++}}

  v2ua = v2fa && s1; // expected-error {{cannot convert between scalar type 'int' and vector type 'v2f' (vector of 2 'float' values) as implicit conversion would cause truncation}} expected-error {{invalid operands to binary expression ('v2f' (vector of 2 'float' values) and 'int'}}
  v2ua = v2fa || s1; // expected-error {{cannot convert between scalar type 'int' and vector type 'v2f' (vector of 2 'float' values) as implicit conversion would cause truncation}} expected-error {{invalid operands to binary expression ('v2f' (vector of 2 'float' values) and 'int'}}

  v2sa = v2fa && s1; // expected-error {{cannot convert between scalar type 'int' and vector type 'v2f' (vector of 2 'float' values) as implicit conversion would cause truncation}} expected-error {{invalid operands to binary expression ('v2f' (vector of 2 'float' values) and 'int'}}
  v2sa = v2fa || s1; // expected-error {{cannot convert between scalar type 'int' and vector type 'v2f' (vector of 2 'float' values) as implicit conversion would cause truncation}} expected-error {{invalid operands to binary expression ('v2f' (vector of 2 'float' values) and 'int'}}

  float f1;
  v2ua = v2ua && f1; // expected-error {{logical expression with vector type 'v2u' (vector of 2 'unsigned int' values) and non-vector type 'float' is only supported in C++}}
  v2ua = v2ua || f1; // expected-error {{logical expression with vector type 'v2u' (vector of 2 'unsigned int' values) and non-vector type 'float' is only supported in C++}}

  v2sa = v2sa && f1; // expected-error {{logical expression with vector type 'v2s' (vector of 2 'int' values) and non-vector type 'float' is only supported in C++}}
  v2sa = v2sa || f1; // expected-error {{logical expression with vector type 'v2s' (vector of 2 'int' values) and non-vector type 'float' is only supported in C++}}

  v2ua = v2sa && f1; // expected-error {{logical expression with vector type 'v2s' (vector of 2 'int' values) and non-vector type 'float' is only supported in C++}}
  v2ua = v2sa || f1; // expected-error {{logical expression with vector type 'v2s' (vector of 2 'int' values) and non-vector type 'float' is only supported in C++}}

  v2sa = v2ua && f1; // expected-error {{logical expression with vector type 'v2u' (vector of 2 'unsigned int' values) and non-vector type 'float' is only supported in C++}}
  v2sa = v2ua || f1; // expected-error {{logical expression with vector type 'v2u' (vector of 2 'unsigned int' values) and non-vector type 'float' is only supported in C++}}

  v2ua = v2fa && f1; // expected-error {{logical expression with vector type 'v2f' (vector of 2 'float' values) and non-vector type 'float' is only supported in C++}}
  v2ua = v2fa || f1; // expected-error {{logical expression with vector type 'v2f' (vector of 2 'float' values) and non-vector type 'float' is only supported in C++}}

  v2sa = v2fa && f1; // expected-error {{logical expression with vector type 'v2f' (vector of 2 'float' values) and non-vector type 'float' is only supported in C++}}
  v2sa = v2fa || f1; // expected-error {{logical expression with vector type 'v2f' (vector of 2 'float' values) and non-vector type 'float' is only supported in C++}}

}

```

Resulted in this output:

```
clang++: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-project/clang/lib/CodeGen/CGExprConstant.cpp:1066: clang::CodeGen::ConstantAddress {anonymous}::tryEmitGlobalCompoundLiteral(clang::CodeGen::ConstantEmitter&, const clang::CompoundLiteralExpr*): Assertion `!E->isFileScope() && "file-scope compound literal did not have constant initializer!"' failed.
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and dumped files.
Stack dump:
0.	Program arguments: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin/clang++ -emit-llvm -S -o /dev/null -O3 -std=c++20 -fno-elide-constructors -ffp-contract=fast -fsanitize=undefined /home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp627c01po/098f7f73.cpp
1.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp627c01po/098f7f73.cpp:12:1: current parser token 'namespace'
2.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp627c01po/098f7f73.cpp:5:11: LLVM IR generation of declaration 'case1'
3.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp627c01po/098f7f73.cpp:8:13: Generating code for declaration 'case1::z'
Stack dump without symbol names (ensure you have llvm-symbolizer in your PATH or set the environment var `LLVM_SYMBOLIZER_PATH` to point to it):
0  clang++   0x00005630819b30f9 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) + 121
1  clang++   0x00005630819afdcc llvm::sys::RunSignalHandlers() + 76
2  clang++   0x00005630819b0678 llvm::sys::CleanupOnSignal(unsigned long) + 216
3  clang++   0x00005630818f2f88
4  libc.so.6 0x00007f1f102dc520
5  libc.so.6 0x00007f1f103309fc pthread_kill + 300
6  libc.so.6 0x00007f1f102dc476 raise + 22
7  libc.so.6 0x00007f1f102c27f3 abort + 211
8  libc.so.6 0x00007f1f102c271b
9  libc.so.6 0x00007f1f102d3e96
10 clang++   0x0000563081d472e7
11 clang++   0x0000563081d475cb
12 clang++   0x0000563081d49315 clang::CodeGen::ConstantEmitter::tryEmitPrivate(clang::APValue const&, clang::QualType, bool) + 5829
13 clang++   0x0000563081d4d515 clang::CodeGen::ConstantEmitter::tryEmitPrivate(clang::Expr const*, clang::QualType) + 453
14 clang++   0x0000563081d4d5ca clang::CodeGen::ConstantEmitter::tryEmitPrivateForMemory(clang::Expr const*, clang::QualType) + 42
15 clang++   0x0000563081d4e671
16 clang++   0x0000563081d4ee42
17 clang++   0x0000563081d4ff8a clang::CodeGen::ConstantEmitter::tryEmitPrivateForVarInit(clang::VarDecl const&) + 234
18 clang++   0x0000563081d50372 clang::CodeGen::ConstantEmitter::tryEmitForInitializer(clang::VarDecl const&) + 82
19 clang++   0x0000563081f720b7 clang::CodeGen::CodeGenModule::EmitGlobalVarDefinition(clang::VarDecl const*, bool) + 1751
20 clang++   0x0000563081f8f8e1 clang::CodeGen::CodeGenModule::EmitGlobalDefinition(clang::GlobalDecl, llvm::GlobalValue*) + 481
21 clang++   0x0000563081f90343 clang::CodeGen::CodeGenModule::EmitGlobal(clang::GlobalDecl) + 2403
22 clang++   0x0000563081f9c6ab
23 clang++   0x0000563081f9d0e0 clang::CodeGen::CodeGenModule::EmitDeclContext(clang::DeclContext const*) + 144
24 clang++   0x000056308233fcb1
25 clang++   0x000056308232f481 clang::BackendConsumer::HandleTopLevelDecl(clang::DeclGroupRef) + 209
26 clang++   0x00005630841306f4 clang::ParseAST(clang::Sema&, bool, bool) + 564
27 clang++   0x00005630826a9071 clang::FrontendAction::Execute() + 65
28 clang++   0x0000563082632c65 clang::CompilerInstance::ExecuteAction(clang::FrontendAction&) + 1589
29 clang++   0x0000563082784ea3 clang::ExecuteCompilerInvocation(clang::CompilerInstance*) + 467
30 clang++   0x0000563080387c96 cc1_main(llvm::ArrayRef<char const*>, char const*, void*) + 7046
31 clang++   0x000056308037da2a
32 clang++   0x000056308037dbbf
33 clang++   0x00005630823ba35d
34 clang++   0x00005630818f33a0 llvm::CrashRecoveryContext::RunSafely(llvm::function_ref<void ()>) + 160
35 clang++   0x00005630823bb1b3
36 clang++   0x0000563082370987 clang::driver::Compilation::ExecuteCommand(clang::driver::Command const&, clang::driver::Command const*&, bool) const + 167
37 clang++   0x00005630823751e0 clang::driver::Compilation::ExecuteJobs(clang::driver::JobList const&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&, bool) const + 304
38 clang++   0x0000563082382e44 clang::driver::Driver::ExecuteCompilation(clang::driver::Compilation&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&) + 404
39 clang++   0x00005630803832d3 clang_main(int, char**, llvm::ToolContext const&) + 7267
40 clang++   0x00005630802d57a1 main + 113
41 libc.so.6 0x00007f1f102c3d90
42 libc.so.6 0x00007f1f102c3e40 __libc_start_main + 128
43 clang++   0x000056308037d055 _start + 37
clang++: error: clang frontend command failed due to signal (use -v to see invocation)
clang version 24.0.0git (https://github.com/llvm/llvm-project.git aefba88f46a6e55645c848f58f6ba56944d5ae62)
Target: x86_64-unknown-linux-gnu
Thread model: posix
InstalledDir: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin
Build config: +assertions
clang++: note: diagnostic msg: 
********************

PLEASE ATTACH THE FOLLOWING CRASH REPRODUCER FILES TO THE BUG REPORT:
clang++: note: diagnostic msg: /tmp/098f7f73-6aa6e1.cpp
clang++: note: diagnostic msg: /tmp/098f7f73-6aa6e1.sh
clang++: note: diagnostic msg: 

********************
Aborted (core dumped)
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ulimit -v 3145728; ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin/clang++ -emit-llvm -S -o /dev/null -O3 -std=c++20 -fno-elide-constructors -ffp-contract=fast -fsanitize=undefined "$SCRIPT_DIR/test.cpp"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `f8661269` | Project seed |
| `b` | `cfdf2b70` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
