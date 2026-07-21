*Fusion-Fuzz Bug Report*

**ID:** `eca37580` &nbsp;·&nbsp; **Signature:** `Assertion: (FD && FD->getInClassInitStyle() != ICIS_NoInit) && "must set init style when field is created"` &nbsp;·&nbsp; **RC:** `134`

The following code:

```cpp
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
struct NonPOD { NonPOD(int); }
struct FinalClass final {
}
struct HasAnonymousUnion {
  union {
    int i;
    float f;
  };
}
union Union { int i; float f; 
 // RUN: %clang_cc1 -triple x86_64-apple-darwin10 -fsyntax-only -verify -std=gnu++11 -fblocks -Wno-deprecated-builtins -fms-extensions -Wno-microsoft %s -Wno-c++17-extensions
// RUN: %clang_cc1 -triple x86_64-apple-darwin10 -fsyntax-only -verify -std=gnu++14 -fblocks -Wno-deprecated-builtins -fms-extensions -Wno-microsoft %s -Wno-c++17-extensions
// RUN: %clang_cc1 -triple x86_64-apple-darwin10 -fsyntax-only -verify -std=gnu++1z -fblocks -Wno-deprecated-builtins -fms-extensions -Wno-microsoft %s
// RUN: %clang_cc1 -x c -triple x86_64-apple-darwin10 -fsyntax-only -verify -std=gnu11 -fblocks -Wno-deprecated-builtins -fms-extensions -Wno-microsoft %s

#ifdef __cplusplus

// expected-no-diagnostics

using Int = int;
 template<>
struct PotentiallySealed<int> sealed { }
 ;}
// RUN: %clang -target i386-unknown-linux -fstack-clash-protection -### %s 2>&1 | FileCheck %s -check-prefix=SCP-i386
// RUN: %clang -target i386-unknown-linux -fno-stack-clash-protection -fstack-clash-protection -### %s 2>&1 | FileCheck %s -check-prefix=SCP-i386
// RUN: %clang -target i386-unknown-linux -fstack-clash-protection -fno-stack-clash-protection -### %s 2>&1 | FileCheck %s -check-prefix=SCP-i386-NO
// SCP-i386: "-fstack-clash-protection"
// SCP-i386-NO-NOT: "-fstack-clash-protection"

// RUN: %clang -target x86_64-scei-linux -fstack-clash-protection -### %s 2>&1 | FileCheck %s -check-prefix=SCP-x86
// RUN: %clang -target x86_64-unknown-freebsd -fstack-clash-protection -### %s 2>&1 | FileCheck %s -check-prefix=SCP-x86
// SCP-x86: "-fstack-clash-protection"

// RUN: %clang -target armv7k-apple-linux -fstack-clash-protection -### %s 2>&1 | FileCheck %s -check-prefix=SCP-armv7
// SCP-armv7-NOT: "-fstack-clash-protection"
// SCP-armv7: argument unused during compilation: '-fstack-clash-protection'

// RUN: %clang -target x86_64-unknown-linux -fstack-clash-protection -S -emit-llvm -o %t.ll %s 2>&1 | FileCheck %s -check-prefix=SCP-warn
// SCP-warn: warning: unable to protect inline asm that clobbers stack pointer against stack clash

// RUN: %clang -target x86_64-pc-unknown-linux -fstack-clash-protection -S -emit-llvm -o- %s | FileCheck %s -check-prefix=SCP-ll-linux64
// SCP-ll-linux64: attributes {{.*}} "probe-stack"="inline-asm"

// RUN: %clang -target x86_64-pc-windows-msvc -fstack-clash-protection -S -emit-llvm -o- %s 2>&1 | FileCheck %s -check-prefix=SCP-ll-win64
// SCP-ll-win64-NOT: attributes {{.*}} "probe-stack"="inline-asm"
// SCP-ll-win64: argument unused during compilation: '-fstack-clash-protection'

// RUN: %clang -target x86_64-unknown-fuchsia -fstack-clash-protection -### %s 2>&1 | FileCheck %s -check-prefix=SCP-FUCHSIA
// RUN: %clang -target aarch64-unknown-fuchsia -fstack-clash-protection -### %s 2>&1 | FileCheck %s -check-prefix=SCP-FUCHSIA
// RUN: %clang -target riscv64-unknown-fuchsia -fstack-clash-protection -### %s 2>&1 | FileCheck %s -check-prefix=SCP-FUCHSIA
// SCP-FUCHSIA: "-fstack-clash-protection"

int foo(int c) {
  int r;
  __asm__("sub %0, %%rsp"
          :
          : "rm"(c)
          : "rsp");
  __asm__("mov %%rsp, %0"
          : "=rm"(r)::);
  return r;
}
enum Enum { EV }
// RUN: %clang_cc1 -triple x86_64-apple-darwin10 -fsyntax-only -verify -std=gnu++11 -fblocks -Wno-deprecated-builtins -fms-extensions -Wno-microsoft %s -Wno-c++17-extensions
// RUN: %clang_cc1 -triple x86_64-apple-darwin10 -fsyntax-only -verify -std=gnu++14 -fblocks -Wno-deprecated-builtins -fms-extensions -Wno-microsoft %s -Wno-c++17-extensions
// RUN: %clang_cc1 -triple x86_64-apple-darwin10 -fsyntax-only -verify -std=gnu++1z -fblocks -Wno-deprecated-builtins -fms-extensions -Wno-microsoft %s
// RUN: %clang_cc1 -x c -triple x86_64-apple-darwin10 -fsyntax-only -verify -std=gnu11 -fblocks -Wno-deprecated-builtins -fms-extensions -Wno-microsoft %s

#ifdef __cplusplus

// expected-no-diagnostics

using Int = int;
#endif
struct POD { Enum e; int i; float f; NonPOD* p; }
#else
struct Derives : POD {}
using ClassType = Derives;
struct SealedClass sealed {
}
template<typename T>
struct PotentiallyFinal { }
template<typename T>
struct PotentiallyFinal<T*> final { }
template<>
struct PotentiallyFinal<int> final { }
template<typename T>
struct PotentiallySealed { }
template<typename T>
struct PotentiallySealed<T*> sealed { }
template<>
struct PotentiallySealed<int> sealed { }
void is_final() {
  static_assert(__is_final(SealedClass));
  static_assert(__is_final(PotentiallySealed<float*>));
  static_assert(__is_final(PotentiallySealed<int>));

  static_assert(!__is_final(PotentiallyFinal<float>));
  static_assert(!__is_final(PotentiallySealed<float>));
}
void is_sealed()
{
  static_assert(__is_sealed(SealedClass));
  static_assert(__is_sealed(PotentiallySealed<float*>));
  static_assert(__is_sealed(PotentiallySealed<int>));
  static_assert(__is_sealed(FinalClass));
  static_assert(__is_sealed(PotentiallyFinal<float*>));
  static_assert(__is_sealed(PotentiallyFinal<int>));

  static_assert(!__is_sealed(int));
  static_assert(!__is_sealed(Union));
  static_assert(!__is_sealed(Int));
  static_assert(!__is_sealed(Int[10]));
  static_assert(!foo(Union[10]));
  static_assert(!__is_sealed(Derives));
  static_assert(!__is_sealed(ClassType));
  static_assert(!__is_sealed(const void));
  static_assert(!__is_sealed(Int[]));
  static_assert(!__is_sealed(HasAnonymousUnion));
  static_assert(!__is_sealed(PotentiallyFinal<float>));
  static_assert(!__is_sealed(PotentiallySealed<float>));
}
struct s1 {}
void is_destructible()
{
  (void)__is_destructible(int);
  (void)__is_destructible(struct s1);
  (void)__is_destructible(struct s2); // expected-error{{incomplete type 'struct s2' used in type trait expression}}
  // expected-note@-1{{}}
}
```

Resulted in this output:

```
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpjwm1cex3/eca37580.cpp:16:31: error: expected ';' after struct
   16 | struct NonPOD { NonPOD(int); }
      |                               ^
      |                               ;
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpjwm1cex3/eca37580.cpp:18:2: error: expected ';' after struct
   18 | }
      |  ^
      |  ;
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpjwm1cex3/eca37580.cpp:24:2: error: expected ';' after struct
   24 | }
      |  ^
      |  ;
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpjwm1cex3/eca37580.cpp:37:8: error: explicit specialization of undeclared template struct 'PotentiallySealed'
   37 | struct PotentiallySealed<int> sealed { }
      |        ^                ~~~~~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpjwm1cex3/eca37580.cpp:36:2: error: extraneous 'template<>' in declaration of variable 'sealed'
   36 |  template<>
      |  ^~~~~~~~~~
clang++: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-project/clang/lib/Sema/SemaDeclCXX.cpp:4241: void clang::Sema::ActOnFinishCXXInClassMemberInitializer(clang::Decl*, clang::SourceLocation, clang::ExprResult): Assertion `(FD && FD->getInClassInitStyle() != ICIS_NoInit) && "must set init style when field is created"' failed.
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and dumped files.
Stack dump:
0.	Program arguments: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin/clang++ -fsyntax-only -O2 -std=gnu++17 -fsanitize=address -ffast-math /home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpjwm1cex3/eca37580.cpp
1.	<eof> parser at end of file
2.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpjwm1cex3/eca37580.cpp:25:1: parsing struct/union/class body 'Union'
Stack dump without symbol names (ensure you have llvm-symbolizer in your PATH or set the environment var `LLVM_SYMBOLIZER_PATH` to point to it):
0  clang++   0x00005612b3dbc0f9 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) + 121
1  clang++   0x00005612b3db8dcc llvm::sys::RunSignalHandlers() + 76
2  clang++   0x00005612b3db9678 llvm::sys::CleanupOnSignal(unsigned long) + 216
3  clang++   0x00005612b3cfbf88
4  libc.so.6 0x00007f0f2df9b520
5  libc.so.6 0x00007f0f2dfef9fc pthread_kill + 300
6  libc.so.6 0x00007f0f2df9b476 raise + 22
7  libc.so.6 0x00007f0f2df817f3 abort + 211
8  libc.so.6 0x00007f0f2df8171b
9  libc.so.6 0x00007f0f2df92e96
10 clang++   0x00005612b69ba637 clang::Sema::ActOnFinishCXXInClassMemberInitializer(clang::Decl*, clang::SourceLocation, clang::ActionResult<clang::Expr*, true>) + 263
11 clang++   0x00005612b656b75c
12 clang++   0x00005612b656af2d clang::Parser::ParseLexedMemberInitializers(clang::Parser::ParsingClass&) + 397
13 clang++   0x00005612b65c1a86 clang::Parser::ParseCXXMemberSpecification(clang::SourceLocation, clang::SourceLocation, clang::ParsedAttributes&, unsigned int, clang::Decl*) + 1542
14 clang++   0x00005612b65c44ff clang::Parser::ParseClassSpecifier(clang::tok::TokenKind, clang::SourceLocation, clang::DeclSpec&, clang::Parser::ParsedTemplateInfo&, clang::AccessSpecifier, bool, clang::Parser::DeclSpecContext, clang::ParsedAttributes&) + 8191
15 clang++   0x00005612b6593732 clang::Parser::ParseDeclarationSpecifiers(clang::DeclSpec&, clang::Parser::ParsedTemplateInfo&, clang::AccessSpecifier, clang::Parser::DeclSpecContext, clang::LateParsedAttrList*, clang::ImplicitTypenameContext) + 2994
16 clang++   0x00005612b654ee88 clang::Parser::ParseDeclOrFunctionDefInternal(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec&, clang::AccessSpecifier) + 200
17 clang++   0x00005612b654f92f clang::Parser::ParseDeclarationOrFunctionDefinition(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec*, clang::AccessSpecifier) + 959
18 clang++   0x00005612b655b7a1 clang::Parser::ParseExternalDeclaration(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec*) + 977
19 clang++   0x00005612b655c7df clang::Parser::ParseTopLevelDecl(clang::OpaquePtr<clang::DeclGroupRef>&, clang::Sema::ModuleImportState&) + 575
20 clang++   0x00005612b653970a clang::ParseAST(clang::Sema&, bool, bool) + 586
21 clang++   0x00005612b4ab2071 clang::FrontendAction::Execute() + 65
22 clang++   0x00005612b4a3bc65 clang::CompilerInstance::ExecuteAction(clang::FrontendAction&) + 1589
23 clang++   0x00005612b4b8dea3 clang::ExecuteCompilerInvocation(clang::CompilerInstance*) + 467
24 clang++   0x00005612b2790c96 cc1_main(llvm::ArrayRef<char const*>, char const*, void*) + 7046
25 clang++   0x00005612b2786a2a
26 clang++   0x00005612b2786bbf
27 clang++   0x00005612b47c335d
28 clang++   0x00005612b3cfc3a0 llvm::CrashRecoveryContext::RunSafely(llvm::function_ref<void ()>) + 160
29 clang++   0x00005612b47c41b3
30 clang++   0x00005612b4779987 clang::driver::Compilation::ExecuteCommand(clang::driver::Command const&, clang::driver::Command const*&, bool) const + 167
31 clang++   0x00005612b477e1e0 clang::driver::Compilation::ExecuteJobs(clang::driver::JobList const&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&, bool) const + 304
32 clang++   0x00005612b478be44 clang::driver::Driver::ExecuteCompilation(clang::driver::Compilation&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&) + 404
33 clang++   0x00005612b278c2d3 clang_main(int, char**, llvm::ToolContext const&) + 7267
34 clang++   0x00005612b26de7a1 main + 113
35 libc.so.6 0x00007f0f2df82d90
36 libc.so.6 0x00007f0f2df82e40 __libc_start_main + 128
37 clang++   0x00005612b2786055 _start + 37
clang++: error: clang frontend command failed due to signal (use -v to see invocation)
clang version 24.0.0git (https://github.com/llvm/llvm-project.git aefba88f46a6e55645c848f58f6ba56944d5ae62)
Target: x86_64-unknown-linux-gnu
Thread model: posix
InstalledDir: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin
Build config: +assertions
clang++: note: diagnostic msg: Error generating preprocessed source(s).
Aborted (core dumped)
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ulimit -v 3145728; ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin/clang++ -fsyntax-only -O2 -std=gnu++17 -fsanitize=address -ffast-math "$SCRIPT_DIR/test.cpp"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `eae637b1` | Project seed |
| `b` | `c615c566` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
