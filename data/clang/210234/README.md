*Fusion-Fuzz Bug Report*

**ID:** `e9f43a8f` &nbsp;·&nbsp; **Signature:** `Assertion: NameInfo.getName().getNameKind() == DeclarationName::CXXDestructorName && "Name must refer to a destructor"` &nbsp;·&nbsp; **RC:** `134`

The following code:

```cpp
// RUN: %clang_cc1 -I%S/Inputs %s -triple x86_64-unknown-linux-gnu -fclangir -emit-cir -mmlir --mlir-print-ir-before=cir-lowering-prepare -o %t.cir 2> %t-before.cir
// RUN: FileCheck %s --input-file=%t-before.cir --check-prefixes=CIR
// RUN: FileCheck %s --input-file=%t.cir --check-prefixes=CIR
// RUN: %clang_cc1 -I%S/Inputs %s -triple x86_64-apple-darwin10 -fclangir -emit-llvm -std=c++11 -o - | FileCheck %s --check-prefixes=LLVM
// RUN: %clang_cc1 -I%S/Inputs %s -triple x86_64-apple-darwin10 -emit-llvm -std=c++11 -o - | FileCheck %s --check-prefixes=LLVM

#include <typeinfo>

namespace Test1 {

struct Item {
  const std::type_info &ti;
  const char *name;
  void *(*make)();
};

template<typename T> void *make_impl() { return new T; }
template<typename T> constexpr Item item(const char *name) {
  return { typeid(T), name, make_impl<T> };
}

struct A { virtual ~A(); };
struct B : virtual A {};
struct C { int n; };

// CIR: cir.global constant external @_ZN5Test15itemsE = #cir.const_array<[
// CIR-SAME: #cir.const_record<{#cir.global_view<@_ZTIN5Test11AE> : !cir.ptr<!rec_std3A3Atype_info>, #cir.global_view<@".str"> : !cir.ptr<!s8i>, #cir.global_view<@_ZN5Test19make_implINS_1AEEEPvv> : !cir.ptr<!cir.func<() -> !cir.ptr<!void>>>}> : !rec_Test13A3AItem
// CIR-SAME: #cir.const_record<{#cir.global_view<@_ZTIN5Test11BE> : !cir.ptr<!rec_std3A3Atype_info>, #cir.global_view<@".str.1"> : !cir.ptr<!s8i>, #cir.global_view<@_ZN5Test19make_implINS_1BEEEPvv> : !cir.ptr<!cir.func<() -> !cir.ptr<!void>>>}> : !rec_Test13A3AItem
// CIR-SAME: #cir.const_record<{#cir.global_view<@_ZTIN5Test11CE> : !cir.ptr<!rec_std3A3Atype_info>, #cir.global_view<@".str.2"> : !cir.ptr<!s8i>, #cir.global_view<@_ZN5Test19make_implINS_1CEEEPvv> : !cir.ptr<!cir.func<() -> !cir.ptr<!void>>>}> : !rec_Test13A3AItem
// CIR-SAME: #cir.const_record<{#cir.global_view<@_ZTIi> : !cir.ptr<!rec_std3A3Atype_info>, #cir.global_view<@".str.3"> : !cir.ptr<!s8i>, #cir.global_view<@_ZN5Test19make_implIiEEPvv> : !cir.ptr<!cir.func<() -> !cir.ptr<!void>>>}> : !rec_Test13A3AItem
// CIR-SAME: ]> : !cir.array<!rec_Test13A3AItem x 4>
//
// LLVM: @_ZN5Test15itemsE ={{.*}} constant [4 x {{.*}}] [{{.*}} @_ZTIN5Test11AE, {{.*}} @_ZN5Test19make_implINS_1AEEEPvv {{.*}} @_ZTIN5Test11BE, {{.*}} @_ZN5Test19make_implINS_1BEEEPvv {{.*}} @_ZTIN5Test11CE, {{.*}} @_ZN5Test19make_implINS_1CEEEPvv {{.*}} @_ZTIi, {{.*}} @_ZN5Test19make_implIiEEPvv }]
extern constexpr Item items[] = {
  item<A>("A"), item<B>("B"), item<C>("C"), item<int>("int")
};

// CIR: cir.global constant external @_ZN5Test11xE = #cir.global_view<@_ZTIN5Test11AE>
// LLVM: @_ZN5Test11xE ={{.*}} constant ptr @_ZTIN5Test11AE, align 8
constexpr auto &x = items[0].ti;

// CIR: cir.global constant external @_ZN5Test11yE = #cir.global_view<@_ZTIN5Test11BE>
// LLVM: @_ZN5Test11yE ={{.*}} constant ptr @_ZTIN5Test11BE, align 8
constexpr auto &y = typeid(B{});

}

static long ffl_fusion = (long)(C);

// RUN: %clang_cc1 -std=c++11 -fsyntax-only -verify %s
// RUN: %clang_cc1 -std=c++17 -fsyntax-only -verify %s
// RUN: %clang_cc1 -std=c++20 -fsyntax-only -verify %s

struct rdar9677163 {
  struct Y { ~Y(); };
  struct Z { ~Z(); };
  Y::~Y() { } // expected-error{{non-friend class member '~Y' cannot have a qualified name}}
  ~Z(); // expected-error{{expected the class name after '~' to name the enclosing class}}
};

namespace GH56772 {

template<class T>
struct A_ffl {
  ~A_ffl<T>();
};
#if __cplusplus >= 202002L
// FIXME: This isn't valid in C_ffl++20 and later.
#endif

struct B_ffl;

template<class T>
struct C_ffl {
  ~B_ffl(); // expected-error {{expected the class name after '~' to name the enclosing class}}
};

template <typename T>
struct D {
  friend T::S::~ffl_fusion();
private:
  static constexpr int secret = 42;
};

template <typename T>
struct E {
  friend T::S::~V();
};

struct BadInstantiation {
  struct S {
    struct V {};
  };
};

struct GoodInstantiation {
  struct V {
    ~V();
  };
  using S = V;
};

// FIXME: We should diagnose this while instantiating.
E<BadInstantiation> x;
E<GoodInstantiation> y;

struct Q {
  struct S { ~S(); };
};

Q::S::~S() {
  void foo(int);
  foo(D<Q>::secret);
}

struct X {
  ~X();
};
struct Y;

struct Z1 {
  friend X::~Y(); // expected-error {{expected the class name after '~' to name the enclosing class}}
};

template <class T>
struct Z2 {
  friend X::~Y(); // expected-error {{expected the class name after '~' to name the enclosing class}}
};

}

```

Resulted in this output:

```
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp7nuesbjl/e9f43a8f.cpp:48:33: error: unknown type name 'C'; did you mean 'Test1::C'?
   48 | static long ffl_fusion = (long)(C);
      |                                 ^
      |                                 Test1::C
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp7nuesbjl/e9f43a8f.cpp:24:8: note: 'Test1::C' declared here
   24 | struct C { int n; };
      |        ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp7nuesbjl/e9f43a8f.cpp:48:35: error: expected expression
   48 | static long ffl_fusion = (long)(C);
      |                                   ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp7nuesbjl/e9f43a8f.cpp:57:6: error: non-friend class member '~Y' cannot have a qualified name
   57 |   Y::~Y() { } // expected-error{{non-friend class member '~Y' cannot have a qualified name}}
      |   ~~~^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp7nuesbjl/e9f43a8f.cpp:58:3: error: expected the class name after '~' to name the enclosing class
   58 |   ~Z(); // expected-error{{expected the class name after '~' to name the enclosing class}}
      |   ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp7nuesbjl/e9f43a8f.cpp:75:3: error: expected the class name after '~' to name the enclosing class
   75 |   ~B_ffl(); // expected-error {{expected the class name after '~' to name the enclosing class}}
      |   ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp7nuesbjl/e9f43a8f.cpp:80:17: error: no type named 'ffl_fusion' in 'GH56772::Q::S'
   80 |   friend T::S::~ffl_fusion();
      |          ~~~~~~~^~~~~~~~~~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp7nuesbjl/e9f43a8f.cpp:113:7: note: in instantiation of template class 'GH56772::D<GH56772::Q>' requested here
  113 |   foo(D<Q>::secret);
      |       ^
clang++: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-project/clang/lib/AST/DeclCXX.cpp:3197: static clang::CXXDestructorDecl* clang::CXXDestructorDecl::Create(clang::ASTContext&, clang::CXXRecordDecl*, clang::SourceLocation, const clang::DeclarationNameInfo&, clang::QualType, clang::TypeSourceInfo*, bool, bool, bool, clang::ConstexprSpecKind, const clang::AssociatedConstraint&): Assertion `NameInfo.getName().getNameKind() == DeclarationName::CXXDestructorName && "Name must refer to a destructor"' failed.
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and dumped files.
Stack dump:
0.	Program arguments: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin/clang++ -fsyntax-only -O1 -std=c++14 /home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp7nuesbjl/e9f43a8f.cpp
1.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp7nuesbjl/e9f43a8f.cpp:113:13: current parser token 'secret'
2.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp7nuesbjl/e9f43a8f.cpp:61:1: parsing namespace 'GH56772'
3.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp7nuesbjl/e9f43a8f.cpp:111:12: parsing function body 'GH56772::Q::S::~S'
4.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp7nuesbjl/e9f43a8f.cpp:111:12: in compound statement ('{}')
5.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmp7nuesbjl/e9f43a8f.cpp:79:8: instantiating class definition 'GH56772::D<GH56772::Q>'
Stack dump without symbol names (ensure you have llvm-symbolizer in your PATH or set the environment var `LLVM_SYMBOLIZER_PATH` to point to it):
0  clang++   0x00005579590b80f9 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) + 121
1  clang++   0x00005579590b4dcc llvm::sys::RunSignalHandlers() + 76
2  clang++   0x00005579590b5678 llvm::sys::CleanupOnSignal(unsigned long) + 216
3  clang++   0x0000557958ff7f88
4  libc.so.6 0x00007fba4feb5520
5  libc.so.6 0x00007fba4ff099fc pthread_kill + 300
6  libc.so.6 0x00007fba4feb5476 raise + 22
7  libc.so.6 0x00007fba4fe9b7f3 abort + 211
8  libc.so.6 0x00007fba4fe9b71b
9  libc.so.6 0x00007fba4feace96
10 clang++   0x000055795cae338b clang::CXXDestructorDecl::Create(clang::ASTContext&, clang::CXXRecordDecl*, clang::SourceLocation, clang::DeclarationNameInfo const&, clang::QualType, clang::TypeSourceInfo*, bool, bool, bool, clang::ConstexprSpecKind, clang::AssociatedConstraint const&) + 75
11 clang++   0x000055795c4fcd58 clang::TemplateDeclInstantiator::VisitCXXMethodDecl(clang::CXXMethodDecl*, clang::TemplateParameterList*, clang::TemplateDeclInstantiator::RewriteKind) + 4872
12 clang++   0x000055795c4fdaf0 clang::TemplateDeclInstantiator::VisitFriendDecl(clang::FriendDecl*) + 720
13 clang++   0x000055795c457a16 clang::Sema::InstantiateClassImpl(clang::SourceLocation, clang::CXXRecordDecl*, clang::CXXRecordDecl*, clang::MultiLevelTemplateArgumentList const&, clang::TemplateSpecializationKind, bool) + 1558
14 clang++   0x000055795c484174 clang::Sema::InstantiateClassTemplateSpecialization(clang::SourceLocation, clang::ClassTemplateSpecializationDecl*, clang::TemplateSpecializationKind, bool, bool) + 500
15 clang++   0x000055795c50d402
16 clang++   0x000055795d408ce5 clang::StackExhaustionHandler::runWithSufficientStackSpace(clang::SourceLocation, llvm::function_ref<void ()>) + 69
17 clang++   0x000055795c51e2e9 clang::Sema::RequireCompleteTypeImpl(clang::SourceLocation, clang::QualType, clang::Sema::CompleteTypeKind, clang::Sema::TypeDiagnoser*) + 1753
18 clang++   0x000055795c51e673 clang::Sema::RequireCompleteType(clang::SourceLocation, clang::QualType, clang::Sema::CompleteTypeKind, clang::Sema::TypeDiagnoser&) + 19
19 clang++   0x000055795ba65ce9 clang::Sema::RequireCompleteDeclContext(clang::CXXScopeSpec&, clang::DeclContext*) + 249
20 clang++   0x000055795bc6238e clang::Sema::getTypeName(clang::IdentifierInfo const&, clang::SourceLocation, clang::Scope*, clang::CXXScopeSpec*, bool, bool, clang::OpaquePtr<clang::QualType>, bool, bool, bool, clang::ImplicitTypenameContext, clang::IdentifierInfo**) + 734
21 clang++   0x000055795b855231 clang::Parser::TryAnnotateTypeOrScopeTokenAfterScopeSpec(clang::CXXScopeSpec&, bool, clang::ImplicitTypenameContext) + 353
22 clang++   0x000055795b855726 clang::Parser::TryAnnotateTypeOrScopeToken(clang::ImplicitTypenameContext, bool) + 198
23 clang++   0x000055795b8c7d4a clang::Parser::ParseCastExpression(clang::CastParseKind, bool, bool&, clang::TypoCorrectionTypeBehavior, bool, bool*) + 1578
24 clang++   0x000055795b8c9a7b clang::Parser::ParseCastExpression(clang::CastParseKind, bool, clang::TypoCorrectionTypeBehavior, bool, bool*) + 59
25 clang++   0x000055795b8c9b1d clang::Parser::ParseAssignmentExpression(clang::TypoCorrectionTypeBehavior) + 61
26 clang++   0x000055795b8c9ede clang::Parser::ParseExpressionList(llvm::SmallVectorImpl<clang::Expr*>&, llvm::function_ref<void ()>, bool, bool) + 142
27 clang++   0x000055795b8ce978 clang::Parser::ParsePostfixExpressionSuffix(clang::ActionResult<clang::Expr*, true>) + 3048
28 clang++   0x000055795b8c79d3 clang::Parser::ParseCastExpression(clang::CastParseKind, bool, bool&, clang::TypoCorrectionTypeBehavior, bool, bool*) + 691
29 clang++   0x000055795b8c9a7b clang::Parser::ParseCastExpression(clang::CastParseKind, bool, clang::TypoCorrectionTypeBehavior, bool, bool*) + 59
30 clang++   0x000055795b8c9b1d clang::Parser::ParseAssignmentExpression(clang::TypoCorrectionTypeBehavior) + 61
31 clang++   0x000055795b8cdd7d clang::Parser::ParseExpression(clang::TypoCorrectionTypeBehavior) + 13
32 clang++   0x000055795b95df81 clang::Parser::ParseExprStatement(clang::Parser::ParsedStmtContext) + 81
33 clang++   0x000055795b955b7b clang::Parser::ParseStatementOrDeclarationAfterAttributes(llvm::SmallVector<clang::Stmt*, 24u>&, clang::Parser::ParsedStmtContext, clang::SourceLocation*, clang::ParsedAttributes&, clang::ParsedAttributes&, clang::LabelDecl*) + 5547
34 clang++   0x000055795b95654b clang::Parser::ParseStatementOrDeclaration(llvm::SmallVector<clang::Stmt*, 24u>&, clang::Parser::ParsedStmtContext, clang::SourceLocation*, clang::LabelDecl*) + 363
35 clang++   0x000055795b95e7f7 clang::Parser::ParseCompoundStatementBody(bool) + 1639
36 clang++   0x000055795b95f04f clang::Parser::ParseFunctionStatementBody(clang::Decl*, clang::Parser::ParseScope&) + 207
37 clang++   0x000055795b85232f clang::Parser::ParseFunctionDefinition(clang::ParsingDeclarator&, clang::Parser::ParsedTemplateInfo const&, clang::LateParsedAttrList*) + 2559
38 clang++   0x000055795b89beb4 clang::Parser::ParseDeclGroup(clang::ParsingDeclSpec&, clang::DeclaratorContext, clang::ParsedAttributes&, clang::Parser::ParsedTemplateInfo&, clang::SourceLocation*, clang::Parser::ForRangeInit*) + 5140
39 clang++   0x000055795b84b15c clang::Parser::ParseDeclOrFunctionDefInternal(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec&, clang::AccessSpecifier) + 924
40 clang++   0x000055795b84b92f clang::Parser::ParseDeclarationOrFunctionDefinition(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec*, clang::AccessSpecifier) + 959
41 clang++   0x000055795b8577a1 clang::Parser::ParseExternalDeclaration(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec*) + 977
42 clang++   0x000055795b8b585b clang::Parser::ParseInnerNamespace(llvm::SmallVector<clang::Parser::InnerNamespaceInfo, 4u> const&, unsigned int, clang::SourceLocation&, clang::ParsedAttributes&, clang::BalancedDelimiterTracker&) + 507
43 clang++   0x000055795b8b6604 clang::Parser::ParseNamespace(clang::DeclaratorContext, clang::SourceLocation&, clang::SourceLocation) + 3188
44 clang++   0x000055795b89eeab clang::Parser::ParseDeclaration(clang::DeclaratorContext, clang::SourceLocation&, clang::ParsedAttributes&, clang::ParsedAttributes&, clang::SourceLocation*) + 827
45 clang++   0x000055795b8578d8 clang::Parser::ParseExternalDeclaration(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec*) + 1288
46 clang++   0x000055795b8587df clang::Parser::ParseTopLevelDecl(clang::OpaquePtr<clang::DeclGroupRef>&, clang::Sema::ModuleImportState&) + 575
47 clang++   0x000055795b83570a clang::ParseAST(clang::Sema&, bool, bool) + 586
48 clang++   0x0000557959dae071 clang::FrontendAction::Execute() + 65
49 clang++   0x0000557959d37c65 clang::CompilerInstance::ExecuteAction(clang::FrontendAction&) + 1589
50 clang++   0x0000557959e89ea3 clang::ExecuteCompilerInvocation(clang::CompilerInstance*) + 467
51 clang++   0x0000557957a8cc96 cc1_main(llvm::ArrayRef<char const*>, char const*, void*) + 7046
52 clang++   0x0000557957a82a2a
53 clang++   0x0000557957a82bbf
54 clang++   0x0000557959abf35d
55 clang++   0x0000557958ff83a0 llvm::CrashRecoveryContext::RunSafely(llvm::function_ref<void ()>) + 160
56 clang++   0x0000557959ac01b3
57 clang++   0x0000557959a75987 clang::driver::Compilation::ExecuteCommand(clang::driver::Command const&, clang::driver::Command const*&, bool) const + 167
58 clang++   0x0000557959a7a1e0 clang::driver::Compilation::ExecuteJobs(clang::driver::JobList const&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&, bool) const + 304
59 clang++   0x0000557959a87e44 clang::driver::Driver::ExecuteCompilation(clang::driver::Compilation&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&) + 404
60 clang++   0x0000557957a882d3 clang_main(int, char**, llvm::ToolContext const&) + 7267
61 clang++   0x00005579579da7a1 main + 113
62 libc.so.6 0x00007fba4fe9cd90
63 libc.so.6 0x00007fba4fe9ce40 __libc_start_main + 128
64 clang++   0x0000557957a82055 _start + 37
clang++: error: clang frontend command failed due to signal (use -v to see invocation)
clang version 24.0.0git (https://github.com/llvm/llvm-project.git aefba88f46a6e55645c848f58f6ba56944d5ae62)
Target: x86_64-unknown-linux-gnu
Thread model: posix
InstalledDir: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin
Build config: +assertions
clang++: note: diagnostic msg: 
********************

PLEASE ATTACH THE FOLLOWING CRASH REPRODUCER FILES TO THE BUG REPORT:
clang++: note: diagnostic msg: /tmp/e9f43a8f-92ab2c.cpp
clang++: note: diagnostic msg: /tmp/e9f43a8f-92ab2c.sh
clang++: note: diagnostic msg: 

********************
Aborted (core dumped)
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ulimit -v 3145728; ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin/clang++ -fsyntax-only -O1 -std=c++14 "$SCRIPT_DIR/test.cpp"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `5980a317` | Project seed |
| `b` | `80ff1adc` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
