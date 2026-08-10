*Fusion-Fuzz Bug Report*

**ID:** `c728b658` &nbsp;·&nbsp; **Signature:** `Assertion: Builder.Packed == BaseBuilder.Packed && "Non-virtual and complete types must agree on packedness"` &nbsp;·&nbsp; **RC:** `134`

The following code:

```cpp
// RUN: %clang_cc1 %s -triple=i686-apple-darwin10 -emit-llvm -o - | FileCheck %s

struct Base {
  char a;
};

struct Derived_1 : virtual Base
{
  char b;
};

#pragma pack(1)
struct Derived_2 : Derived_1 {
  // CHECK: %struct.Derived_2 = type { %struct.Derived_1.base, %struct.Base }
  // CHECK: %struct.Derived_1.base = type <{ ptr, i8 }>
};

Derived_2 x;

// Check we use tail padding if it is known to be safe

// Configs that have cheap unaligned access
// Little Endian
// RUN: %clang_cc1 -triple=aarch64-apple-darwin %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT,LAYOUT64 %s
// RUN: %clang_cc1 -triple=aarch64-linux-gnu %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT,LAYOUT64 %s
// RUN: %clang_cc1 -triple=arm-apple-darwin %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT-DWN32 %s
// RUN: %clang_cc1 -triple=arm-none-eabi %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT,LAYOUT32 %s
// RUN: %clang_cc1 -triple=i686-linux-gnu %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT,LAYOUT32 %s
// RUN: %clang_cc1 -triple=loongarch64-elf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT,LAYOUT64 %s
// RUN: %clang_cc1 -triple=powerpcle-linux-gnu %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT,LAYOUT32 %s
// RUN: %clang_cc1 -triple=ve-elf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT,LAYOUT64 %s
// RUN: %clang_cc1 -triple=wasm32 %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT,LAYOUT32 %s
// RUN: %clang_cc1 -triple=wasm64 %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT,LAYOUT64 %s
// RUN: %clang_cc1 -triple=x86_64-linux-gnu %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT,LAYOUT64 %s

// Big Endian
// RUN: %clang_cc1 -triple=powerpc-linux-gnu %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT,LAYOUT32 %s
// RUN: %clang_cc1 -triple=powerpc64-linux-gnu %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT,LAYOUT64 %s
// RUN: %clang_cc1 -triple=systemz %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT,LAYOUT64 %s

// Configs that have expensive unaligned access
// Little Endian
// RUN: %clang_cc1 -triple=amdgcn-elf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT,LAYOUT64 %s
// RUN: %clang_cc1 -triple=arc-elf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT,LAYOUT32 %s
// RUN: %clang_cc1 -triple=bpf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT,LAYOUT64 %s
// RUN: %clang_cc1 -triple=csky %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT,LAYOUT32 %s
// RUN: %clang_cc1 -triple=hexagon-elf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT,LAYOUT32 %s
// RUN: %clang_cc1 -triple=loongarch32-elf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT,LAYOUT32 %s
// RUN: %clang_cc1 -triple=nvptx-elf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT,LAYOUT32 %s
// RUN: %clang_cc1 -triple=riscv32 %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT,LAYOUT32 %s
// RUN: %clang_cc1 -triple=riscv64 %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT,LAYOUT64 %s
// RUN: %clang_cc1 -triple=spir-elf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT,LAYOUT32 %s
// RUN: %clang_cc1 -triple=xcore-none-elf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT,LAYOUT32 %s

// Big endian
// RUN: %clang_cc1 -triple=lanai-elf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT,LAYOUT32 %s
// RUN: %clang_cc1 -triple=m68k-elf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT,LAYOUT32 %s
// RUN: %clang_cc1 -triple=mips-elf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT,LAYOUT32 %s
// RUN: %clang_cc1 -triple=mips64-elf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT,LAYOUT64 %s
// RUN: %clang_cc1 -triple=sparc-elf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT,LAYOUT32 %s
// RUN: %clang_cc1 -triple=tce-elf %s -emit-llvm -o /dev/null -fdump-record-layouts-simple | FileCheck --check-prefixes CHECK,LAYOUT,LAYOUT32 %s

// Can use tail padding
struct Pod {
  int a : 16;
  int b : 8;
}
P;
// CHECK-LABEL: LLVMType:%struct.Pod =
// LAYOUT-SAME: type { i32 }
// LAYOUT-DWN32-SAME: type <{ i16, i8 }>
// CHECK-NEXT: NonVirtualBaseLLVMType:%struct.Pod =
// CHECK: BitFields:[
// LAYOUT-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:16 IsSigned:1 StorageSize:32 StorageOffset:0
// LAYOUT-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:8 IsSigned:1 StorageSize:32 StorageOffset:0

// LAYOUT-DWN32-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:16 IsSigned:1 StorageSize:16 StorageOffset:0
// LAYOUT-DWN32-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:8 IsSigned:1 StorageSize:8 StorageOffset:2
// CHECK-NEXT: ]>

// No tail padding
struct __attribute__((packed)) PPod {
  int a : 16;
  int b : 8;
}
PP;
// CHECK-LABEL: LLVMType:%struct.PPod =
// LAYOUT-SAME: type <{ i16, i8 }>
// LAYOUT-DWN32-SAME: type <{ i16, i8 }>
// CHECK-NEXT: NonVirtualBaseLLVMType:%struct.PPod =
// CHECK: BitFields:[
// LAYOUT-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:16 IsSigned:1 StorageSize:16 StorageOffset:0
// LAYOUT-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:8 IsSigned:1 StorageSize:8 StorageOffset:2

// LAYOUT-DWN32-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:16 IsSigned:1 StorageSize:16 StorageOffset:0
// LAYOUT-DWN32-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:8 IsSigned:1 StorageSize:8 StorageOffset:2
// CHECK-NEXT: ]>

// Cannot use tail padding
struct NonPod {
  ~NonPod();
  int a : 16;
  int b : 8;
}
NP;
// CHECK-LABEL: LLVMType:%struct.NonPod =
// LAYOUT-SAME: type <{ i16, i8, i8 }>
// LAYOUT-DWN32-SAME: type <{ i16, i8 }>
// CHECK-NEXT: NonVirtualBaseLLVMType:%struct.
// LAYOUT-SAME: NonPod.base = type <{ i16, i8 }>
// LAYOUT-DWN32-SAME: NonPod = type <{ i16, i8 }>
// CHECK: BitFields:[
// LAYOUT-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:16 IsSigned:1 StorageSize:16 StorageOffset:0
// LAYOUT-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:8 IsSigned:1 StorageSize:8 StorageOffset:2

// LAYOUT-DWN32-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:16 IsSigned:1 StorageSize:16 StorageOffset:0
// LAYOUT-DWN32-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:8 IsSigned:1 StorageSize:8 StorageOffset:2
// CHECK-NEXT: ]>

// No tail padding
struct __attribute__((packed)) PNonPod {
  ~PNonPod();
  int a : 16;
  int b : 8;
}
PNP;
// CHECK-LABEL: LLVMType:%struct.PNonPod =
// LAYOUT-SAME: type <{ i16, i8 }>
// LAYOUT-DWN32-SAME: type <{ i16, i8 }>
// CHECK-NEXT: NonVirtualBaseLLVMType:%struct.PNonPod =
// CHECK: BitFields:[
// LAYOUT-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:16 IsSigned:1 StorageSize:16 StorageOffset:0
// LAYOUT-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:8 IsSigned:1 StorageSize:8 StorageOffset:2

// LAYOUT-DWN32-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:16 IsSigned:1 StorageSize:16 StorageOffset:0
// LAYOUT-DWN32-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:8 IsSigned:1 StorageSize:8 StorageOffset:2
// CHECK-NEXT: ]>

struct __attribute__((aligned(4))) Empty {}
empty;
struct Char { char a; }
cbase;
struct D : virtual Char, public Derived_2 {
  [[no_unique_address]] Empty e0;
  [[no_unique_address]] Empty e1;
  unsigned a : 24; // keep as 24bits
}
d;
// CHECK-LABEL: LLVMType:%struct.D =
// LAYOUT64-SAME: type <{ ptr, [3 x i8], %struct.Char, [4 x i8] }>
// LAYOUT32-SAME: type { ptr, [3 x i8], %struct.Char }
// LAYOUT-DWN32-SAME: type { ptr, [3 x i8], %struct.Char }
// CHECK-NEXT: NonVirtualBaseLLVMType:
// LAYOUT64-SAME: %struct.D.base = type <{ ptr, i32 }>
// LAYOUT32-SAME: %struct.D = type { ptr, [3 x i8], %struct.Char }
// LAYOUT-DWN32-SAME: %struct.D = type { ptr, [3 x i8], %struct.Char }
// CHECK: BitFields:[
// LAYOUT-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:24 IsSigned:0 StorageSize:24 StorageOffset:{{(4|8)}}

// LAYOUT-DWN32-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:24 IsSigned:0 StorageSize:24 StorageOffset:{{(4|8)}}
// CHECK-NEXT: ]>

struct Int { int a; }
ibase;
struct E : virtual Int {
  [[no_unique_address]] Empty e0;
  [[no_unique_address]] Empty e1;
  unsigned a : 24; // expand to 32
}
e;
// CHECK-LABEL: LLVMType:%struct.E =
// LAYOUT64-SAME: type <{ ptr, i32, %struct.Int }>
// LAYOUT32-SAME: type { ptr, i32, %struct.Int }
// LAYOUT-DWN32-SAME: type { ptr, i32, %struct.Int }
// CHECK-NEXT: NonVirtualBaseLLVMType:%struct.E.base =
// LAYOUT64-SAME: type <{ ptr, i32 }>
// LAYOUT32-SAME: type { ptr, i32 }
// LAYOUT-DWN32-SAME: type { ptr, i32 }
// CHECK: BitFields:[
// LAYOUT-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:24 IsSigned:0 StorageSize:32 StorageOffset:{{(4|8)}}

// LAYOUT-DWN32-NEXT: <CGBitFieldInfo Offset:{{[0-9]+}} Size:24 IsSigned:0 StorageSize:32 StorageOffset:{{(4|8)}}
// CHECK-NEXT: ]>
```

Resulted in this output:

```
clang++: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-project/clang/lib/CodeGen/CGRecordLayoutBuilder.cpp:1099: std::unique_ptr<clang::CodeGen::CGRecordLayout> clang::CodeGen::CodeGenTypes::ComputeRecordLayout(const clang::RecordDecl*, llvm::StructType*): Assertion `Builder.Packed == BaseBuilder.Packed && "Non-virtual and complete types must agree on packedness"' failed.
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and dumped files.
Stack dump:
0.	Program arguments: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin/clang++ -S -o /dev/null -Os -fsanitize=address /home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp1ruq_010/c728b658.cpp
1.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp1ruq_010/c728b658.cpp:163:1: current parser token 'struct'
2.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp1ruq_010/c728b658.cpp:143:8: LLVM IR generation of declaration 'D'
3.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp1ruq_010/c728b658.cpp:148:1: Generating code for declaration 'd'
Stack dump without symbol names (ensure you have llvm-symbolizer in your PATH or set the environment var `LLVM_SYMBOLIZER_PATH` to point to it):
0  clang++   0x0000558039a2e0f9 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) + 121
1  clang++   0x0000558039a2adcc llvm::sys::RunSignalHandlers() + 76
2  clang++   0x0000558039a2b678 llvm::sys::CleanupOnSignal(unsigned long) + 216
3  clang++   0x000055803996df88
4  libc.so.6 0x00007f9b091f1520
5  libc.so.6 0x00007f9b092459fc pthread_kill + 300
6  libc.so.6 0x00007f9b091f1476 raise + 22
7  libc.so.6 0x00007f9b091d77f3 abort + 211
8  libc.so.6 0x00007f9b091d771b
9  libc.so.6 0x00007f9b091e8e96
10 clang++   0x0000558039f0ae9d clang::CodeGen::CodeGenTypes::ComputeRecordLayout(clang::RecordDecl const*, llvm::StructType*) + 3533
11 clang++   0x000055803a063014 clang::CodeGen::CodeGenTypes::ConvertRecordDeclType(clang::RecordDecl const*) + 1124
12 clang++   0x000055803a063a30 clang::CodeGen::CodeGenTypes::getCGRecordLayout(clang::RecordDecl const*) + 128
13 clang++   0x000055803a063d1d clang::CodeGen::CodeGenTypes::isZeroInitializable(clang::QualType) + 429
14 clang++   0x0000558039dc0015 clang::CodeGen::CodeGenModule::EmitNullConstant(clang::QualType) + 309
15 clang++   0x0000558039fee06d clang::CodeGen::CodeGenModule::EmitGlobalVarDefinition(clang::VarDecl const*, bool) + 5773
16 clang++   0x000055803a00a8e1 clang::CodeGen::CodeGenModule::EmitGlobalDefinition(clang::GlobalDecl, llvm::GlobalValue*) + 481
17 clang++   0x000055803a00b343 clang::CodeGen::CodeGenModule::EmitGlobal(clang::GlobalDecl) + 2403
18 clang++   0x000055803a0176ab
19 clang++   0x000055803a3bacb1
20 clang++   0x000055803a3aa481 clang::BackendConsumer::HandleTopLevelDecl(clang::DeclGroupRef) + 209
21 clang++   0x000055803c1ab6f4 clang::ParseAST(clang::Sema&, bool, bool) + 564
22 clang++   0x000055803a724071 clang::FrontendAction::Execute() + 65
23 clang++   0x000055803a6adc65 clang::CompilerInstance::ExecuteAction(clang::FrontendAction&) + 1589
24 clang++   0x000055803a7ffea3 clang::ExecuteCompilerInvocation(clang::CompilerInstance*) + 467
25 clang++   0x0000558038402c96 cc1_main(llvm::ArrayRef<char const*>, char const*, void*) + 7046
26 clang++   0x00005580383f8a2a
27 clang++   0x00005580383f8bbf
28 clang++   0x000055803a43535d
29 clang++   0x000055803996e3a0 llvm::CrashRecoveryContext::RunSafely(llvm::function_ref<void ()>) + 160
30 clang++   0x000055803a4361b3
31 clang++   0x000055803a3eb987 clang::driver::Compilation::ExecuteCommand(clang::driver::Command const&, clang::driver::Command const*&, bool) const + 167
32 clang++   0x000055803a3f01e0 clang::driver::Compilation::ExecuteJobs(clang::driver::JobList const&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&, bool) const + 304
33 clang++   0x000055803a3fde44 clang::driver::Driver::ExecuteCompilation(clang::driver::Compilation&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&) + 404
34 clang++   0x00005580383fe2d3 clang_main(int, char**, llvm::ToolContext const&) + 7267
35 clang++   0x00005580383507a1 main + 113
36 libc.so.6 0x00007f9b091d8d90
37 libc.so.6 0x00007f9b091d8e40 __libc_start_main + 128
38 clang++   0x00005580383f8055 _start + 37
clang++: error: clang frontend command failed due to signal (use -v to see invocation)
clang version 24.0.0git (https://github.com/llvm/llvm-project.git aefba88f46a6e55645c848f58f6ba56944d5ae62)
Target: x86_64-unknown-linux-gnu
Thread model: posix
InstalledDir: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin
Build config: +assertions
clang++: note: diagnostic msg: 
********************

PLEASE ATTACH THE FOLLOWING CRASH REPRODUCER FILES TO THE BUG REPORT:
clang++: note: diagnostic msg: /tmp/c728b658-53fb17.cpp
clang++: note: diagnostic msg: /tmp/c728b658-53fb17.sh
clang++: note: diagnostic msg: 

********************
Aborted (core dumped)
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ulimit -v 3145728; ulimit -c 0; ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin/clang++ -S -o /dev/null -Os -fsanitize=address "$SCRIPT_DIR/test.cpp"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `13f506bb` | Project seed |
| `b` | `d01262bd` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
