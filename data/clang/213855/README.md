*Fusion-Fuzz Bug Report*

**ID:** `42573076` &nbsp;·&nbsp; **Signature:** `Assertion: (Size == 0 || EltInfo.Width <= (uint64_t)(-1) / Size) && "Overflow in array type bit size evaluation"` &nbsp;·&nbsp; **RC:** `134`

The following code:

```cpp
// RUN: %clang_cc1 -std=c++11 %s -verify

using size_t = decltype(sizeof(int));
// expected-error {{template}}
template<typename T> T operator ""_b(const char *);
template<typename T> struct U {
  friend int operator ""_a(const char *, size_t);
  // FIXME: It's not entirely clear whether this is intended to be legal.
  friend U operator ""_a(const T *, size_t); // expected-error {{parameter}}
}
template<char...> struct V {
  friend void operator ""_b(); // expected-error {{parameters}}
}
template<char...> struct S {}
// expected-error {{template}}
template<typename T> int operator ""_b(const T *, size_t);
// expected-error {{template}}
// expected-error {{template}}
template<char, char...> void operator ""_b();
template<char...> void operator ""_a();
template<char... C> S<C...> operator ""_a();
;
;
;
;
;
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: getTypeInfoImpl
// EXPECT-CRASH-ASSERT: EltInfo.Width
// EXPECT-CRASH-ASSERT: Overflow

template <unsigned Size> struct S_ffl {
  double A[Size];
}
template <unsigned Size> struct SS {
  S_ffl<Size> A[Size];
}
void T() { SS<-123> ss; }
template<char... C, int N = 0> void operator ""_b();
// expected-error {{template}}
template<char... C> void operator ""_b(int N = 0);
```

Resulted in this output:

```
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpmmsjwtcp/42573076.cpp:5:24: error: literal operator template cannot have any parameters
    5 | template<typename T> T operator ""_b(const char *);
      |                        ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpmmsjwtcp/42573076.cpp:9:26: error: invalid literal operator parameter type 'const T *', did you mean 'const char *'?
    9 |   friend U operator ""_a(const T *, size_t); // expected-error {{parameter}}
      |                          ^~~~~~~~~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpmmsjwtcp/42573076.cpp:10:2: error: expected ';' after struct
   10 | }
      |  ^
      |  ;
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpmmsjwtcp/42573076.cpp:12:15: error: non-template literal operator must have one or two parameters
   12 |   friend void operator ""_b(); // expected-error {{parameters}}
      |               ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpmmsjwtcp/42573076.cpp:13:2: error: expected ';' after struct
   13 | }
      |  ^
      |  ;
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpmmsjwtcp/42573076.cpp:14:30: error: expected ';' after struct
   14 | template<char...> struct S {}
      |                              ^
      |                              ;
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpmmsjwtcp/42573076.cpp:16:26: error: literal operator template cannot have any parameters
   16 | template<typename T> int operator ""_b(const T *, size_t);
      |                          ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpmmsjwtcp/42573076.cpp:19:1: error: template parameter list for literal operator must be either 'char...' or 'typename T, T...'
   19 | template<char, char...> void operator ""_b();
      | ^~~~~~~~~~~~~~~~~~~~~~~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpmmsjwtcp/42573076.cpp:34:2: error: expected ';' after struct
   34 | }
      |  ^
      |  ;
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpmmsjwtcp/42573076.cpp:37:2: error: expected ';' after struct
   37 | }
      |  ^
      |  ;
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpmmsjwtcp/42573076.cpp:38:15: error: non-type template argument evaluates to -123, which cannot be narrowed to type 'unsigned int' [-Wc++11-narrowing]
   38 | void T() { SS<-123> ss; }
      |               ^
clang++: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-project/clang/lib/AST/ASTContext.cpp:2143: clang::TypeInfo clang::ASTContext::getTypeInfoImpl(const clang::Type*) const: Assertion `(Size == 0 || EltInfo.Width <= (uint64_t)(-1) / Size) && "Overflow in array type bit size evaluation"' failed.
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and dumped files.
Stack dump:
0.	Program arguments: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin/clang++ -fsyntax-only -O1 -ffp-contract=fast -fno-inline /home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpmmsjwtcp/42573076.cpp
1.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpmmsjwtcp/42573076.cpp:38:23: current parser token ';'
2.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpmmsjwtcp/42573076.cpp:38:10: parsing function body 'T'
3.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpmmsjwtcp/42573076.cpp:38:10: in compound statement ('{}')
Stack dump without symbol names (ensure you have llvm-symbolizer in your PATH or set the environment var `LLVM_SYMBOLIZER_PATH` to point to it):
0  clang++   0x00005644429620f9 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) + 121
1  clang++   0x000056444295edcc llvm::sys::RunSignalHandlers() + 76
2  clang++   0x000056444295f678 llvm::sys::CleanupOnSignal(unsigned long) + 216
3  clang++   0x00005644428a1f88
4  libc.so.6 0x00007fc8354f0520
5  libc.so.6 0x00007fc8355449fc pthread_kill + 300
6  libc.so.6 0x00007fc8354f0476 raise + 22
7  libc.so.6 0x00007fc8354d67f3 abort + 211
8  libc.so.6 0x00007fc8354d671b
9  libc.so.6 0x00007fc8354e7e96
10 clang++   0x000056444611c531 clang::ASTContext::getTypeInfoImpl(clang::Type const*) const + 4817
11 clang++   0x00005644461195e9 clang::ASTContext::getTypeInfo(clang::Type const*) const + 105
12 clang++   0x000056444611b1b2 clang::ASTContext::getTypeAlignInChars(clang::QualType) const + 34
13 clang++   0x000056444535a48b clang::Sema::CheckArgAlignment(clang::SourceLocation, clang::NamedDecl*, llvm::StringRef, clang::QualType, clang::QualType) + 443
14 clang++   0x0000564445389be0 clang::Sema::CheckConstructorCall(clang::FunctionDecl*, clang::QualType, llvm::ArrayRef<clang::Expr const*>, clang::FunctionProtoType const*, clang::SourceLocation) + 464
15 clang++   0x0000564445563080 clang::Sema::CompleteConstructorCall(clang::CXXConstructorDecl*, clang::QualType, llvm::MutableArrayRef<clang::Expr*>, clang::SourceLocation, llvm::SmallVectorImpl<clang::Expr*>&, bool, bool) + 448
16 clang++   0x00005644457eedac
17 clang++   0x00005644457ff10e clang::InitializationSequence::Perform(clang::Sema&, clang::InitializedEntity const&, clang::InitializationKind const&, llvm::MutableArrayRef<clang::Expr*>, clang::QualType*) + 6238
18 clang++   0x00005644455846d8
19 clang++   0x0000564445585194
20 clang++   0x00005644455b656b clang::Sema::SetCtorInitializers(clang::CXXConstructorDecl*, bool, llvm::ArrayRef<clang::CXXCtorInitializer*>) + 2779
21 clang++   0x00005644455cd806 clang::Sema::DefineImplicitDefaultConstructor(clang::SourceLocation, clang::CXXConstructorDecl*) + 630
22 clang++   0x0000564446cb2ce5 clang::StackExhaustionHandler::runWithSufficientStackSpace(clang::SourceLocation, llvm::function_ref<void ()>) + 69
23 clang++   0x00005644457ef288
24 clang++   0x00005644457ff10e clang::InitializationSequence::Perform(clang::Sema&, clang::InitializedEntity const&, clang::InitializationKind const&, llvm::MutableArrayRef<clang::Expr*>, clang::QualType*) + 6238
25 clang++   0x00005644454d6640
26 clang++   0x000056444512ad1c clang::Parser::ParseDeclarationAfterDeclaratorAndAttributes(clang::Declarator&, clang::Parser::ParsedTemplateInfo const&, clang::Parser::ForRangeInit*) + 380
27 clang++   0x00005644451455bc clang::Parser::ParseDeclGroup(clang::ParsingDeclSpec&, clang::DeclaratorContext, clang::ParsedAttributes&, clang::Parser::ParsedTemplateInfo&, clang::SourceLocation*, clang::Parser::ForRangeInit*) + 2844
28 clang++   0x000056444514879c clang::Parser::ParseSimpleDeclaration(clang::DeclaratorContext, clang::SourceLocation&, clang::ParsedAttributes&, clang::ParsedAttributes&, bool, clang::Parser::ForRangeInit*, clang::SourceLocation*) + 860
29 clang++   0x0000564445148ca3 clang::Parser::ParseDeclaration(clang::DeclaratorContext, clang::SourceLocation&, clang::ParsedAttributes&, clang::ParsedAttributes&, clang::SourceLocation*) + 307
30 clang++   0x00005644451ffbfa clang::Parser::ParseStatementOrDeclarationAfterAttributes(llvm::SmallVector<clang::Stmt*, 24u>&, clang::Parser::ParsedStmtContext, clang::SourceLocation*, clang::ParsedAttributes&, clang::ParsedAttributes&, clang::LabelDecl*) + 5674
31 clang++   0x000056444520054b clang::Parser::ParseStatementOrDeclaration(llvm::SmallVector<clang::Stmt*, 24u>&, clang::Parser::ParsedStmtContext, clang::SourceLocation*, clang::LabelDecl*) + 363
32 clang++   0x00005644452087f7 clang::Parser::ParseCompoundStatementBody(bool) + 1639
33 clang++   0x000056444520904f clang::Parser::ParseFunctionStatementBody(clang::Decl*, clang::Parser::ParseScope&) + 207
34 clang++   0x00005644450fc32f clang::Parser::ParseFunctionDefinition(clang::ParsingDeclarator&, clang::Parser::ParsedTemplateInfo const&, clang::LateParsedAttrList*) + 2559
35 clang++   0x0000564445145eb4 clang::Parser::ParseDeclGroup(clang::ParsingDeclSpec&, clang::DeclaratorContext, clang::ParsedAttributes&, clang::Parser::ParsedTemplateInfo&, clang::SourceLocation*, clang::Parser::ForRangeInit*) + 5140
36 clang++   0x00005644450f515c clang::Parser::ParseDeclOrFunctionDefInternal(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec&, clang::AccessSpecifier) + 924
37 clang++   0x00005644450f592f clang::Parser::ParseDeclarationOrFunctionDefinition(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec*, clang::AccessSpecifier) + 959
38 clang++   0x00005644451017a1 clang::Parser::ParseExternalDeclaration(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec*) + 977
39 clang++   0x00005644451027df clang::Parser::ParseTopLevelDecl(clang::OpaquePtr<clang::DeclGroupRef>&, clang::Sema::ModuleImportState&) + 575
40 clang++   0x00005644450df70a clang::ParseAST(clang::Sema&, bool, bool) + 586
41 clang++   0x0000564443658071 clang::FrontendAction::Execute() + 65
42 clang++   0x00005644435e1c65 clang::CompilerInstance::ExecuteAction(clang::FrontendAction&) + 1589
43 clang++   0x0000564443733ea3 clang::ExecuteCompilerInvocation(clang::CompilerInstance*) + 467
44 clang++   0x0000564441336c96 cc1_main(llvm::ArrayRef<char const*>, char const*, void*) + 7046
45 clang++   0x000056444132ca2a
46 clang++   0x000056444132cbbf
47 clang++   0x000056444336935d
48 clang++   0x00005644428a23a0 llvm::CrashRecoveryContext::RunSafely(llvm::function_ref<void ()>) + 160
49 clang++   0x000056444336a1b3
50 clang++   0x000056444331f987 clang::driver::Compilation::ExecuteCommand(clang::driver::Command const&, clang::driver::Command const*&, bool) const + 167
51 clang++   0x00005644433241e0 clang::driver::Compilation::ExecuteJobs(clang::driver::JobList const&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&, bool) const + 304
52 clang++   0x0000564443331e44 clang::driver::Driver::ExecuteCompilation(clang::driver::Compilation&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&) + 404
53 clang++   0x00005644413322d3 clang_main(int, char**, llvm::ToolContext const&) + 7267
54 clang++   0x00005644412847a1 main + 113
55 libc.so.6 0x00007fc8354d7d90
56 libc.so.6 0x00007fc8354d7e40 __libc_start_main + 128
57 clang++   0x000056444132c055 _start + 37
clang++: error: clang frontend command failed due to signal (use -v to see invocation)
clang version 24.0.0git (https://github.com/llvm/llvm-project.git aefba88f46a6e55645c848f58f6ba56944d5ae62)
Target: x86_64-unknown-linux-gnu
Thread model: posix
InstalledDir: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin
Build config: +assertions
clang++: note: diagnostic msg: 
********************

PLEASE ATTACH THE FOLLOWING CRASH REPRODUCER FILES TO THE BUG REPORT:
clang++: note: diagnostic msg: /tmp/42573076-3ebb71.cpp
clang++: note: diagnostic msg: /tmp/42573076-3ebb71.sh
clang++: note: diagnostic msg: 

********************
Aborted (core dumped)
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ulimit -v 3145728; ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin/clang++ -fsyntax-only -O1 -ffp-contract=fast -fno-inline "$SCRIPT_DIR/test.cpp"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `85ef21fc` | Project seed |
| `b` | `42f51267` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
