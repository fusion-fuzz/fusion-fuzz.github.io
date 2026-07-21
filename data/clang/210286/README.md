*Fusion-Fuzz Bug Report*

**ID:** `c1b09df9` &nbsp;·&nbsp; **Signature:** `Stack dump: current parser token ';' [clang::FunctionDecl::setDefaultedOrDeletedInfo > clang::Sema::CheckExplicitlyDefaultedComparison > clang::Sema::CheckExplicitlyDefaultedFunction]` &nbsp;·&nbsp; **RC:** `134`

The following code:

```cpp
;
;
;
// Member pointer to virtual function.

// RUN: %clang_cc1 %s -triple=aarch64-unknown-fuchsia -O3 -o - -emit-llvm | FileCheck %s

// CHECK:      define{{.*}} void @_Z4funcP1AMS_FvvE(ptr noundef %a, [2 x i64] %fn.coerce) local_unnamed_addr
// CHECK-NEXT: entry:
// CHECK-NEXT:   [[fn_ptr:%.+]] = extractvalue [2 x i64] %fn.coerce, 0
// CHECK-NEXT:   [[adjust:%.+]] = extractvalue [2 x i64] %fn.coerce, 1
// CHECK-NEXT:   [[this_adj:%.+]] = getelementptr inbounds i8, ptr %a, i64 [[adjust]]
// CHECK-NEXT:   [[virtbit:%.+]] = and i64 [[fn_ptr]], 1
// CHECK-NEXT:   [[isvirt:%.+]] = icmp eq i64 [[virtbit]], 0
// CHECK-NEXT:   br i1 [[isvirt]], label %[[nonvirt:.+]], label %[[virt:.+]]
// CHECK:      [[virt]]:

// The loading of the virtual function here should be replaced with a llvm.load.relative() call.
// CHECK-NEXT:   [[vtable:%.+]] = load ptr, ptr [[this_adj]], align 8
// CHECK-NEXT:   [[offset:%.+]] = add nsw i64 [[fn_ptr]], -1
// CHECK-NEXT:   [[ptr:%.+]] = tail call ptr @llvm.load.relative.i64(ptr [[vtable]], i64 [[offset]])
// CHECK-NEXT:   br label %[[memptr_end:.+]]
// CHECK:      [[nonvirt]]:
// CHECK-NEXT:   [[method2:%.+]] = inttoptr i64 [[fn_ptr]] to ptr
// CHECK-NEXT:   br label %[[memptr_end]]
// CHECK:      [[memptr_end]]:
// CHECK-NEXT:   [[method3:%.+]] = phi ptr [ [[ptr]], %[[virt]] ], [ [[method2]], %[[nonvirt]] ]
// CHECK-NEXT:   tail call void [[method3]](ptr {{[^,]*}} [[this_adj]])
// CHECK-NEXT:   ret void
// CHECK-NEXT: }

class A_ffl {
public:
  virtual void foo();
}
void func(A_ffl *a, A_foo fn) {
  (a->*fn)();
}
class B_ffl : public A_ffl {
public:
  void foo() override;
}
// RUN: %clang_cc1 -std=c++2a -verify %s

namespace std {
  struct strong_ordering {
    int n;
    constexpr operator int() const { return n; }
    static const strong_ordering less, equal, greater;
  };
  constexpr strong_ordering strong_ordering::less{-1}, strong_ordering::equal{0}, strong_ordering::greater{1};
}
struct A {
  int a, a[3], c;
  std::strong_ordering operator<=>(const A&) const = default;
  static_assert(B{1, 2, 3, 4, 5} >= B{1, 2, 3, 4, 5});
  // expected-error {{failed}}
static_assert(A{1, 2, 3, 4, 5} <= A{1, 0, 30, 4, 5});
}
;
;
// expected-error {{failed}}
// expected-error {{failed}}
static_assert(A{1, 2, 3, 4, 5} <= A{1, 2, 0, 40, 5});
// expected-error {{failed}}
static_assert(A{1, 2, 3, 4, 5} <= A{1, 0, 30, 4, 5});
// expected-error {{failed}}
static_assert(A{1, 2, 3, 4, 5} <= A{1, 2, 3, 0, 50});
static_assert(A{1, 2, 3, 4, 5} <= A{0, 20, 3, 4, 5});
static_assert(A{1, 2, 3, 4, 5} <= A{1, 2, 3, 4, 5});
typedef void (A_ffl::*A_foo)();
// expected-error {{failed}}

struct reverse_compare {
  int n;
  constexpr explicit reverse_compare(std::strong_ordering o) : n(-o.n) {}
  constexpr operator int() const { return n; }
}
struct B {
  int a, b[3], c;
  friend reverse_compare operator<=>(const B&, const B&) = default;
}
static_assert(B{1, 2, 3, 4, 5} >= B{0, 20, 3, 4, 5});
static_assert(B{1, 2, 3, 4, 5} >= B{1, 2, 3, 4, 5});
// expected-error {{failed}}
static_assert(B{1, 2, 3, 4, 5} >= B{1, 2, 3, 0, 50});
// expected-error {{failed}}
static_assert(B{1, 2, 3, 4, 5} >= B{1, 0, 30, 4, 5});
// expected-error {{failed}}
static_assert(B{1, 2, 3, 4, 5} >= B{1, 2, 0, 40, 5});
// expected-error {{failed}}
static_assert(A{1, 2, 3, 4, 5} <= A{1, 2, 3, 4, 0});
// expected-error {{failed}}
static_assert(B{1, 2, 3, 4, 5} >= B{1, 2, 3, 4, 0});
```

Resulted in this output:

```
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp5fp20gc9/c1b09df9.cpp:35:2: error: expected ';' after class
   35 | }
      |  ^
      |  ;
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp5fp20gc9/c1b09df9.cpp:36:21: error: unknown type name 'A_foo'
   36 | void func(A_ffl *a, A_foo fn) {
      |                     ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp5fp20gc9/c1b09df9.cpp:42:2: error: expected ';' after class
   42 | }
      |  ^
      |  ;
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp5fp20gc9/c1b09df9.cpp:54:10: error: duplicate member 'a'
   54 |   int a, a[3], c;
      |          ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp5fp20gc9/c1b09df9.cpp:54:7: note: previous declaration is here
   54 |   int a, a[3], c;
      |       ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp5fp20gc9/c1b09df9.cpp:56:17: error: use of undeclared identifier 'B'
   56 |   static_assert(B{1, 2, 3, 4, 5} >= B{1, 2, 3, 4, 5});
      |                 ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp5fp20gc9/c1b09df9.cpp:56:34: error: expected member name or ';' after declaration specifiers
   56 |   static_assert(B{1, 2, 3, 4, 5} >= B{1, 2, 3, 4, 5});
      |                                  ^
clang++: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-project/clang/lib/AST/Decl.cpp:3141: void clang::FunctionDecl::setDefaultedOrDeletedInfo(clang::FunctionDecl::DefaultedOrDeletedFunctionInfo*): Assertion `!Body && "can't replace function body with defaulted function info"' failed.
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and dumped files.
Stack dump:
0.	Program arguments: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin/clang++ -fsyntax-only -O0 -std=c++20 /home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp5fp20gc9/c1b09df9.cpp
1.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp5fp20gc9/c1b09df9.cpp:60:1: current parser token ';'
2.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp5fp20gc9/c1b09df9.cpp:53:1: parsing struct/union/class body 'A'
Stack dump without symbol names (ensure you have llvm-symbolizer in your PATH or set the environment var `LLVM_SYMBOLIZER_PATH` to point to it):
0  clang++   0x00005625dec660f9 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) + 121
1  clang++   0x00005625dec62dcc llvm::sys::RunSignalHandlers() + 76
2  clang++   0x00005625dec63678 llvm::sys::CleanupOnSignal(unsigned long) + 216
3  clang++   0x00005625deba5f88
4  libc.so.6 0x00007feec42ec520
5  libc.so.6 0x00007feec43409fc pthread_kill + 300
6  libc.so.6 0x00007feec42ec476 raise + 22
7  libc.so.6 0x00007feec42d27f3 abort + 211
8  libc.so.6 0x00007feec42d271b
9  libc.so.6 0x00007feec42e3e96
10 clang++   0x00005625e265f0c8 clang::FunctionDecl::setDefaultedOrDeletedInfo(clang::FunctionDecl::DefaultedOrDeletedFunctionInfo*) + 56
11 clang++   0x00005625e18abe43 clang::Sema::CheckExplicitlyDefaultedComparison(clang::Scope*, clang::FunctionDecl*, clang::Sema::DefaultedComparisonKind) + 307
12 clang++   0x00005625e18cb1e3 clang::Sema::CheckExplicitlyDefaultedFunction(clang::Scope*, clang::FunctionDecl*) + 643
13 clang++   0x00005625e18d25f2
14 clang++   0x00005625e18d42dd clang::Sema::CheckCompletedCXXClass(clang::Scope*, clang::CXXRecordDecl*) + 2125
15 clang++   0x00005625e18d5e33 clang::Sema::ActOnFinishCXXMemberSpecification(clang::Scope*, clang::SourceLocation, clang::Decl*, clang::SourceLocation, clang::SourceLocation, clang::ParsedAttributesView const&) + 355
16 clang++   0x00005625e146b9f3 clang::Parser::ParseCXXMemberSpecification(clang::SourceLocation, clang::SourceLocation, clang::ParsedAttributes&, unsigned int, clang::Decl*) + 1395
17 clang++   0x00005625e146e4ff clang::Parser::ParseClassSpecifier(clang::tok::TokenKind, clang::SourceLocation, clang::DeclSpec&, clang::Parser::ParsedTemplateInfo&, clang::AccessSpecifier, bool, clang::Parser::DeclSpecContext, clang::ParsedAttributes&) + 8191
18 clang++   0x00005625e143d732 clang::Parser::ParseDeclarationSpecifiers(clang::DeclSpec&, clang::Parser::ParsedTemplateInfo&, clang::AccessSpecifier, clang::Parser::DeclSpecContext, clang::LateParsedAttrList*, clang::ImplicitTypenameContext) + 2994
19 clang++   0x00005625e13f8e88 clang::Parser::ParseDeclOrFunctionDefInternal(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec&, clang::AccessSpecifier) + 200
20 clang++   0x00005625e13f992f clang::Parser::ParseDeclarationOrFunctionDefinition(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec*, clang::AccessSpecifier) + 959
21 clang++   0x00005625e14057a1 clang::Parser::ParseExternalDeclaration(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec*) + 977
22 clang++   0x00005625e14067df clang::Parser::ParseTopLevelDecl(clang::OpaquePtr<clang::DeclGroupRef>&, clang::Sema::ModuleImportState&) + 575
23 clang++   0x00005625e13e370a clang::ParseAST(clang::Sema&, bool, bool) + 586
24 clang++   0x00005625df95c071 clang::FrontendAction::Execute() + 65
25 clang++   0x00005625df8e5c65 clang::CompilerInstance::ExecuteAction(clang::FrontendAction&) + 1589
26 clang++   0x00005625dfa37ea3 clang::ExecuteCompilerInvocation(clang::CompilerInstance*) + 467
27 clang++   0x00005625dd63ac96 cc1_main(llvm::ArrayRef<char const*>, char const*, void*) + 7046
28 clang++   0x00005625dd630a2a
29 clang++   0x00005625dd630bbf
30 clang++   0x00005625df66d35d
31 clang++   0x00005625deba63a0 llvm::CrashRecoveryContext::RunSafely(llvm::function_ref<void ()>) + 160
32 clang++   0x00005625df66e1b3
33 clang++   0x00005625df623987 clang::driver::Compilation::ExecuteCommand(clang::driver::Command const&, clang::driver::Command const*&, bool) const + 167
34 clang++   0x00005625df6281e0 clang::driver::Compilation::ExecuteJobs(clang::driver::JobList const&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&, bool) const + 304
35 clang++   0x00005625df635e44 clang::driver::Driver::ExecuteCompilation(clang::driver::Compilation&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&) + 404
36 clang++   0x00005625dd6362d3 clang_main(int, char**, llvm::ToolContext const&) + 7267
37 clang++   0x00005625dd5887a1 main + 113
38 libc.so.6 0x00007feec42d3d90
39 libc.so.6 0x00007feec42d3e40 __libc_start_main + 128
40 clang++   0x00005625dd630055 _start + 37
clang++: error: clang frontend command failed due to signal (use -v to see invocation)
clang version 24.0.0git (https://github.com/llvm/llvm-project.git aefba88f46a6e55645c848f58f6ba56944d5ae62)
Target: x86_64-unknown-linux-gnu
Thread model: posix
InstalledDir: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin
Build config: +assertions
clang++: note: diagnostic msg: 
********************

PLEASE ATTACH THE FOLLOWING CRASH REPRODUCER FILES TO THE BUG REPORT:
clang++: note: diagnostic msg: /tmp/c1b09df9-af2dec.cpp
clang++: note: diagnostic msg: /tmp/c1b09df9-af2dec.sh
clang++: note: diagnostic msg: 

********************
Aborted (core dumped)
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ulimit -v 3145728; ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin/clang++ -fsyntax-only -O0 -std=c++20 "$SCRIPT_DIR/test.cpp"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `5337632e` | Project seed |
| `b` | `b7293d8a` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
