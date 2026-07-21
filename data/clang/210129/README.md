*Fusion-Fuzz Bug Report*

**ID:** `084d5e99` &nbsp;·&nbsp; **Signature:** `Assertion: Getter->isSynthesizedAccessorStub() && "autosynth stub expected"` &nbsp;·&nbsp; **RC:** `134`

The following code:

```m
// RUN: %clang_cc1 -triple x86_64-apple-darwin10  -fdiagnostics-parseable-fixits -x objective-c -fobjc-arc %s 2>&1 | FileCheck %s

@interface I
@property id prop;
@property (atomic) id atomic_prop;
@property (copy, readwrite) id prop2;
@property (  ) id prop1;
@end

@implementation I
@synthesize prop, prop1, prop2;
@property (copy, atomic, readwrite) id atomic_prop1;
@synthesize atomic_prop, atomic_prop1;
//--- t1.m
@import A;
- (id) prop;
- (id) prop { return 0; }
- (id) prop2 { return 0; }
- (id) prop1 { return 0; }
- (id) atomic_prop { return 0; }
- (id) atomic_prop1 { return 0; }
- (id) atomic_prop;
@end

// CHECK-DAG: {4:11-4:11}:"(nonatomic) "
// CHECK-DAG: {9:12-9:12}:"nonatomic"
// CHECK-DAG: {13:12-13:12}:"nonatomic, "
//--- modules/A/A.h

typedef int prop2;
]

//--- modules/A/module.modulemap

module A {
  umbrella header "A.h"
}
//--- t2.m
@import A;
// RUN: rm -rf %t
// RUN: split-file %s %t
// RUN: sed -e "s|DIR|%/t|g" %t/cdb1.json.template > %t/cdb1.json

// RUN: clang-scan-deps -compilation-database %t/cdb1.json -format experimental-full -mode preprocess-dependency-directives > %t/result1.txt

// RUN: FileCheck %s -input-file %t/result1.txt

// Verify that secondary actions get stripped, and that there's a single version
// of module A.

// CHECK:        "modules": [
// CHECK-NEXT:     {
// CHECK:            "name": "A"
// CHECK:          }
// CHECK-NOT:        "name": "A"
// CHECK:        "translation-units"

//--- cdb1.json.template
[
  {
    "directory": "DIR",
    "command": "clang -Imodules/A -fmodules -fmodules-cache-path=DIR/module-cache -fimplicit-modules -fimplicit-module-maps -fsyntax-only DIR/t1.m",
    "file": "DIR/t1.m"
  }
,
  {
    "directory": "DIR",
    "command": "clang -Imodules/A -fmodules -fmodules-cache-path=DIR/module-cache -fimplicit-modules -fimplicit-module-maps -fsyntax-only DIR/t2.m",
    "file": "DIR/t2.m"
  }
```

Resulted in this output:

```
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpm5noi83f/084d5e99.m:4:1: warning: no 'assign', 'retain', or 'copy' attribute is specified - 'assign' is assumed [-Wobjc-property-no-attribute]
    4 | @property id prop;
      | ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpm5noi83f/084d5e99.m:4:1: warning: default property attribute 'assign' not appropriate for object [-Wobjc-property-no-attribute]
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpm5noi83f/084d5e99.m:5:1: warning: no 'assign', 'retain', or 'copy' attribute is specified - 'assign' is assumed [-Wobjc-property-no-attribute]
    5 | @property (atomic) id atomic_prop;
      | ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpm5noi83f/084d5e99.m:5:1: warning: default property attribute 'assign' not appropriate for object [-Wobjc-property-no-attribute]
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpm5noi83f/084d5e99.m:7:1: warning: no 'assign', 'retain', or 'copy' attribute is specified - 'assign' is assumed [-Wobjc-property-no-attribute]
    7 | @property (  ) id prop1;
      | ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpm5noi83f/084d5e99.m:7:1: warning: default property attribute 'assign' not appropriate for object [-Wobjc-property-no-attribute]
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpm5noi83f/084d5e99.m:11:13: error: synthesized property 'prop' must either be named the same as a compatible instance variable or must explicitly name an instance variable
   11 | @synthesize prop, prop1, prop2;
      |             ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpm5noi83f/084d5e99.m:11:19: error: synthesized property 'prop1' must either be named the same as a compatible instance variable or must explicitly name an instance variable
   11 | @synthesize prop, prop1, prop2;
      |                   ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpm5noi83f/084d5e99.m:11:26: error: synthesized property 'prop2' must either be named the same as a compatible instance variable or must explicitly name an instance variable
   11 | @synthesize prop, prop1, prop2;
      |                          ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpm5noi83f/084d5e99.m:12:1: error: unexpected '@' in program
   12 | @property (copy, atomic, readwrite) id atomic_prop1;
      | ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpm5noi83f/084d5e99.m:13:13: error: synthesized property 'atomic_prop' must either be named the same as a compatible instance variable or must explicitly name an instance variable
   13 | @synthesize atomic_prop, atomic_prop1;
      |             ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpm5noi83f/084d5e99.m:13:26: error: property implementation must have its declaration in interface 'I' or one of its extensions
   13 | @synthesize atomic_prop, atomic_prop1;
      |                          ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpm5noi83f/084d5e99.m:15:1: error: use of '@import' when modules are disabled
   15 | @import A;
      | ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpm5noi83f/084d5e99.m:16:12: warning: semicolon before method body is ignored [-Wsemicolon-before-method-body]
   16 | - (id) prop;
      |            ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpm5noi83f/084d5e99.m:17:1: error: expected method body
   17 | - (id) prop { return 0; }
      | ^
clang: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-project/clang/lib/Sema/SemaDeclObjC.cpp:4884: clang::Decl* clang::SemaObjC::ActOnMethodDeclaration(clang::Scope*, clang::SourceLocation, clang::SourceLocation, clang::tok::TokenKind, clang::ObjCDeclSpec&, clang::ParsedType, llvm::ArrayRef<clang::SourceLocation>, clang::Selector, clang::ParmVarDecl**, clang::DeclaratorChunk::ParamInfo*, unsigned int, const clang::ParsedAttributesView&, clang::tok::ObjCKeywordKind, bool, bool): Assertion `Getter->isSynthesizedAccessorStub() && "autosynth stub expected"' failed.
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and dumped files.
Stack dump:
0.	Program arguments: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin/clang -fsyntax-only -O2 -fno-objc-arc -Wextra -ffp-contract=fast /home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpm5noi83f/084d5e99.m
1.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpm5noi83f/084d5e99.m:22:19: current parser token ';'
Stack dump without symbol names (ensure you have llvm-symbolizer in your PATH or set the environment var `LLVM_SYMBOLIZER_PATH` to point to it):
0  clang     0x0000563c226390f9 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) + 121
1  clang     0x0000563c22635dcc llvm::sys::RunSignalHandlers() + 76
2  clang     0x0000563c22636678 llvm::sys::CleanupOnSignal(unsigned long) + 216
3  clang     0x0000563c22578f88
4  libc.so.6 0x00007fd079ac6520
5  libc.so.6 0x00007fd079b1a9fc pthread_kill + 300
6  libc.so.6 0x00007fd079ac6476 raise + 22
7  libc.so.6 0x00007fd079aac7f3 abort + 211
8  libc.so.6 0x00007fd079aac71b
9  libc.so.6 0x00007fd079abde96
10 clang     0x0000563c252cda97 clang::SemaObjC::ActOnMethodDeclaration(clang::Scope*, clang::SourceLocation, clang::SourceLocation, clang::tok::TokenKind, clang::ObjCDeclSpec&, clang::OpaquePtr<clang::QualType>, llvm::ArrayRef<clang::SourceLocation>, clang::Selector, clang::ParmVarDecl**, clang::DeclaratorChunk::ParamInfo*, unsigned int, clang::ParsedAttributesView const&, clang::tok::ObjCKeywordKind, bool, bool) + 8039
11 clang     0x0000563c24e87fb7 clang::Parser::ParseObjCMethodDecl(clang::SourceLocation, clang::tok::TokenKind, clang::tok::ObjCKeywordKind, bool) + 1015
12 clang     0x0000563c24e89272 clang::Parser::ParseObjCMethodDefinition() + 130
13 clang     0x0000563c24dd8f4b clang::Parser::ParseExternalDeclaration(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec*) + 2939
14 clang     0x0000563c24e84091 clang::Parser::ParseObjCAtImplementationDeclaration(clang::SourceLocation, clang::ParsedAttributes&) + 785
15 clang     0x0000563c24dd8e70 clang::Parser::ParseExternalDeclaration(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec*) + 2720
16 clang     0x0000563c24dd97df clang::Parser::ParseTopLevelDecl(clang::OpaquePtr<clang::DeclGroupRef>&, clang::Sema::ModuleImportState&) + 575
17 clang     0x0000563c24db670a clang::ParseAST(clang::Sema&, bool, bool) + 586
18 clang     0x0000563c2332f071 clang::FrontendAction::Execute() + 65
19 clang     0x0000563c232b8c65 clang::CompilerInstance::ExecuteAction(clang::FrontendAction&) + 1589
20 clang     0x0000563c2340aea3 clang::ExecuteCompilerInvocation(clang::CompilerInstance*) + 467
21 clang     0x0000563c2100dc96 cc1_main(llvm::ArrayRef<char const*>, char const*, void*) + 7046
22 clang     0x0000563c21003a2a
23 clang     0x0000563c21003bbf
24 clang     0x0000563c2304035d
25 clang     0x0000563c225793a0 llvm::CrashRecoveryContext::RunSafely(llvm::function_ref<void ()>) + 160
26 clang     0x0000563c230411b3
27 clang     0x0000563c22ff6987 clang::driver::Compilation::ExecuteCommand(clang::driver::Command const&, clang::driver::Command const*&, bool) const + 167
28 clang     0x0000563c22ffb1e0 clang::driver::Compilation::ExecuteJobs(clang::driver::JobList const&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&, bool) const + 304
29 clang     0x0000563c23008e44 clang::driver::Driver::ExecuteCompilation(clang::driver::Compilation&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&) + 404
30 clang     0x0000563c210092d3 clang_main(int, char**, llvm::ToolContext const&) + 7267
31 clang     0x0000563c20f5b7a1 main + 113
32 libc.so.6 0x00007fd079aadd90
33 libc.so.6 0x00007fd079aade40 __libc_start_main + 128
34 clang     0x0000563c21003055 _start + 37
clang: error: clang frontend command failed due to signal (use -v to see invocation)
clang version 24.0.0git (https://github.com/llvm/llvm-project.git aefba88f46a6e55645c848f58f6ba56944d5ae62)
Target: x86_64-unknown-linux-gnu
Thread model: posix
InstalledDir: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin
Build config: +assertions
clang: note: diagnostic msg: 
********************

PLEASE ATTACH THE FOLLOWING CRASH REPRODUCER FILES TO THE BUG REPORT:
clang: note: diagnostic msg: /tmp/084d5e99-adf622.m
clang: note: diagnostic msg: /tmp/084d5e99-adf622.sh
clang: note: diagnostic msg: 

********************
Aborted (core dumped)
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ulimit -v 3145728; ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin/clang -fsyntax-only -O2 -fno-objc-arc -Wextra -ffp-contract=fast "$SCRIPT_DIR/test.m"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `52de4589` | Project seed |
| `b` | `a7214d1f` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
