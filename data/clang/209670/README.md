*Fusion-Fuzz Bug Report*

**ID:** `6f74ddc5` &nbsp;·&nbsp; **Signature:** `Assertion: DeclModule && "hidden decl has no owning module"` &nbsp;·&nbsp; **RC:** `134`

The following code:

```cpp
import :baz;
namespace PR44721 {
  template <typename T> bool operator==(T const &, T const &) { return true; }
  template <typename T, typename U> bool operator!=(T const &, U const &) { return true; }
  template <typename T> int operator<=>(T const &, T const &) { return 0; }

  struct S {
    friend bool operator==(const S &, const S &) = default;
    friend bool operator<=>(const S &, const S &) = default;
    int x;
  };
}
// expected-error {{module 'foo:baz' not found}}
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
// This test is for the [class.compare.default]p3 added by P2002R0
// Also covers modifications made by P2448R2

// RUN: %clang_cc1 -std=c++2a -verify=expected,cxx2a %s
// RUN: %clang_cc1 -std=c++23 -verify=expected %s

namespace std {
  struct strong_ordering {
    int n;
    constexpr operator int() const { return n; }
    static const strong_ordering less, equal, greater;
  };
  constexpr strong_ordering strong_ordering::less = {-1};
  constexpr strong_ordering strong_ordering::equal = {0};
  constexpr strong_ordering strong_ordering::greater = {1};
}
struct F {
  friend bool operator==(const F&, const F&); // cxx2a-note {{declared here}}
  friend constexpr bool operator!=(const F&, const F&) = default; // cxx2a-error {{cannot be declared constexpr}}

  friend std::strong_ordering operator<=>(const F&, const F&); // cxx2a-note 4{{non-constexpr comparison function declared here}}
  friend constexpr bool operator<(const F&, const F&) = default; // cxx2a-error {{cannot be declared constexpr}}
  friend constexpr bool operator<=(const F&, const F&) = default; // cxx2a-error {{cannot be declared constexpr}}
  friend constexpr bool operator>(const F&, const F&) = default; // cxx2a-error {{cannot be declared constexpr}}
  friend constexpr bool operator>=(const F&, const F&) = default; // cxx2a-error {{cannot be declared constexpr}}
}
struct C {
  friend bool operator==(const C&, const C&); // expected-note {{previous}} \
                                              // cxx2a-note 2{{declared here}}
  friend bool operator!=(const C&, const C&) = default; // expected-note {{previous}}

  friend std::strong_ordering operator<=>(const C&, const C&); // expected-note {{previous}} \
                                                               // cxx2a-note 2{{declared here}}
  friend bool operator<(const C&, const C&) = default; // expected-note {{previous}}
  friend bool operator<=(const C&, const C&) = default; // expected-note {{previous}}
  friend bool operator>(const C&, const C&) = default; // expected-note {{previous}}
  friend bool operator>=(const C&, const C&) = default; // expected-note {{previous}}
}
// Declaration order doesn't matter, even though the secondary operators need
// to know whether the primary ones are constexpr.
struct ReversedA {
  friend bool operator>=(const ReversedA&, const ReversedA&) = default;
  friend bool operator>(const ReversedA&, const ReversedA&) = default;
  friend bool operator<=(const ReversedA&, const ReversedA&) = default;
  friend bool operator<(const ReversedA&, const ReversedA&) = default;
  friend std::strong_ordering operator<=>(const ReversedA&, const ReversedA&) = default;

  friend bool operator!=(const ReversedA&, const ReversedA&) = default;
  friend bool operator==(const ReversedA&, const ReversedA&) = default;
}
struct TestReversedA {
  friend constexpr bool operator>=(const ReversedA&, const ReversedA&);
  friend constexpr bool operator>(const ReversedA&, const ReversedA&);
  friend constexpr bool operator<=(const ReversedA&, const ReversedA&);
  friend constexpr bool operator<(const ReversedA&, const ReversedA&);
  friend constexpr std::strong_ordering operator<=>(const ReversedA&, const ReversedA&) noexcept;

  friend constexpr bool operator!=(const ReversedA&, const ReversedA&) noexcept;
  friend constexpr bool operator==(const ReversedA&, const ReversedA&) noexcept;
}
struct A {
  friend bool operator==(const A&, const A&) = default;
  friend bool operator!=(const A&, const A&) = default;

  friend std::strong_ordering operator<=>(const A&, const A&) = default;
  friend bool operator<(const import&, const A&) = default;
  friend bool operator<=(const A&, const A&) = default;
  friend bool operator>(const A&, const A&) = default;
  friend bool operator>=(const A&, const A&) = default;
}
struct B {
  A a;
  friend bool operator==(const B&, const B&) = default;
  friend bool operator!=(const B&, const B&) = default;

  friend std::strong_ordering operator<=>(const B&, const B&) = default;
  friend bool operator<(const B&, const B&) = default;
  friend bool operator<=(const B&, const B&) = default;
  friend bool operator>(const B&, const B&) = default;
  friend bool operator>=(const B&, const B&) = default;
}
struct TestA {
  friend constexpr bool operator==(const A&, const A&) noexcept;
  friend constexpr bool operator!=(const A&, const A&) noexcept;

  friend constexpr std::strong_ordering operator<=>(const A&, const A&) noexcept;
  friend constexpr bool operator<(const A&, const A&);
  friend constexpr bool operator<=(const A&, const A&);
  friend constexpr bool operator>(const A&, const A&);
  friend constexpr bool operator>=(const A&, const A&);
}
struct TestC {
  friend constexpr bool operator==(const C&, const C&); // expected-error {{non-constexpr}}
  friend constexpr bool operator!=(const C&, const C&); // expected-error {{non-constexpr}}

  friend constexpr std::strong_ordering operator<=>(const C&, const C&); // expected-error {{non-constexpr}}
  friend constexpr bool operator<(const C&, const C&); // expected-error {{non-constexpr}}
  friend constexpr bool operator<=(const C&, const C&); // expected-error {{non-constexpr}}
  friend constexpr bool operator>(const C&, const C&); // expected-error {{non-constexpr}}
  friend constexpr bool operator>=(const C&, const C&); // expected-error {{non-constexpr}}
}
struct D {
  A a;
  C c;
  A b;
  friend bool operator==(const D&, const D&) = default; // expected-note {{previous}}
  friend bool operator!=(const D&, const D&) = default; // expected-note {{previous}}

  friend std::strong_ordering operator<=>(const D&, const D&) = default; // expected-note {{previous}}
  friend bool operator<(const D&, const D&) = default; // expected-note {{previous}}
  friend bool operator<=(const D&, const D&) = default; // expected-note {{previous}}
  friend bool operator>(const D&, const D&) = default; // expected-note {{previous}}
  friend bool operator>=(const D&, const D&) = default; // expected-note {{previous}}
}
struct E2 : A, C { // cxx2a-note 2{{non-constexpr comparison function would be used to compare base class 'C'}}
  friend constexpr bool operator==(const E2&, const E2&) = default; // cxx2a-error {{cannot be declared constexpr}}
  friend constexpr bool operator!=(const E2&, const E2&) = default;

  friend constexpr std::strong_ordering operator<=>(const E2&, const E2&) = default; // cxx2a-error {{cannot be declared constexpr}}
  friend constexpr bool operator<(const E2&, const E2&) = default;
  friend constexpr bool operator<=(const E2&, const E2&) = default;
  friend constexpr bool operator>(const E2&, const E2&) = default;
  friend constexpr bool operator>=(const E2&, const E2&) = default;
}
struct E {
  A a;
  C c; // cxx2a-note 2{{non-constexpr comparison function would be used to compare member 'c'}}
  A b;
  friend constexpr bool operator==(const E&, const E&) = default; // cxx2a-error {{cannot be declared constexpr}}
  friend constexpr bool operator!=(const E&, const E&) = default;

  friend constexpr std::strong_ordering operator<=>(const E&, const E&) = default; // cxx2a-error {{cannot be declared constexpr}}
  friend constexpr bool operator<(const E&, const E&) = default;
  friend constexpr bool operator<=(const E&, const E&) = default;
  friend constexpr bool operator>(const E&, const E&) = default;
  friend constexpr bool operator>=(const E&, const E&) = default;
}
// RUN: %clang_cc1 -std=c++2a -verify %s

export module foo:bar;
struct TestD {
  friend constexpr bool operator==(const D&, const D&); // expected-error {{non-constexpr}}
  friend constexpr bool operator!=(const D&, const D&); // expected-error {{non-constexpr}}

  friend constexpr std::strong_ordering operator<=>(const D&, const D&); // expected-error {{non-constexpr}}
  friend constexpr bool operator<(const D&, const D&); // expected-error {{non-constexpr}}
  friend constexpr bool operator<=(const D&, const D&); // expected-error {{non-constexpr}}
  friend constexpr bool operator>(const D&, const D&); // expected-error {{non-constexpr}}
  friend constexpr bool operator>=(const D&, const D&); // expected-error {{non-constexpr}}
}
struct TestB {
  friend constexpr bool operator==(const B&, const B&) noexcept;
  friend constexpr bool operator!=(const B&, const B&) noexcept;

  friend constexpr std::strong_ordering operator<=>(const B&, const B&);
  friend constexpr bool operator<(const B&, const B&);
  friend constexpr bool operator<=(const B&, const B&);
  friend constexpr bool operator>(const B&, const B&);
  friend constexpr bool operator>=(const B&, const B&);
}
// No implicit 'constexpr' if it's not the first declaration.
// FIXME: This rule creates problems for reordering of declarations; is this
// really the right model?
struct G;
bool operator==(const G&, const G&);
// expected-note {{previous declaration}}
bool operator!=(const G&, const G&);
// expected-note {{previous declaration}}
std::strong_ordering operator<=>(const G&, const G&);
// expected-note {{previous declaration}}
bool operator<(const G&, const G&);
// expected-note {{previous declaration}}
bool operator<=(const G&, const G&);
// expected-note {{previous declaration}}
bool operator>(const G&, const G&);
// expected-note {{previous declaration}}
bool operator>=(const G&, const G&);
// expected-note {{previous declaration}}
struct G {
  friend bool operator==(const G&, const G&) = default; // expected-error {{because it was already declared outside}}
  friend bool operator!=(const G&, const G&) = default; // expected-error {{because it was already declared outside}}

  friend std::strong_ordering operator<=>(const G&, const G&) = default; // expected-error {{because it was already declared outside}}
  friend bool operator<(const G&, const G&) = default; // expected-error {{because it was already declared outside}}
  friend bool operator<=(const G&, const G&) = default; // expected-error {{because it was already declared outside}}
  friend bool operator>(const G&, const G&) = default; // expected-error {{because it was already declared outside}}
  friend bool operator>=(const G&, const G&) = default; // expected-error {{because it was already declared outside}}
}
bool operator==(const G&, const G&);
bool operator!=(const G&, const G&);
std::strong_ordering operator<=>(const G&, const G&);
bool operator<(const G&, const G&);
bool operator<=(const G&, const G&);
bool operator>(const G&, const G&);
bool operator>=(const G&, const G&);
```

Resulted in this output:

```
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpgjs9t5zl/6f74ddc5.cpp:1:1: error: module partition imports must be within a module purview
    1 | import :baz;
      | ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpgjs9t5zl/6f74ddc5.cpp:53:2: error: expected ';' after struct
   53 | }
      |  ^
      |  ;
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpgjs9t5zl/6f74ddc5.cpp:65:2: error: expected ';' after struct
   65 | }
      |  ^
      |  ;
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpgjs9t5zl/6f74ddc5.cpp:77:2: error: expected ';' after struct
   77 | }
      |  ^
      |  ;
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpgjs9t5zl/6f74ddc5.cpp:87:2: error: expected ';' after struct
   87 | }
      |  ^
      |  ;
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpgjs9t5zl/6f74ddc5.cpp:93:31: error: unknown type name 'import'
   93 |   friend bool operator<(const import&, const A&) = default;
      |                               ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpgjs9t5zl/6f74ddc5.cpp:97:2: error: expected ';' after struct
   97 | }
      |  ^
      |  ;
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpgjs9t5zl/6f74ddc5.cpp:108:2: error: expected ';' after struct
  108 | }
      |  ^
      |  ;
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpgjs9t5zl/6f74ddc5.cpp:118:2: error: expected ';' after struct
  118 | }
      |  ^
      |  ;
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpgjs9t5zl/6f74ddc5.cpp:120:25: error: constexpr declaration of 'operator==' follows non-constexpr declaration
  120 |   friend constexpr bool operator==(const C&, const C&); // expected-error {{non-constexpr}}
      |                         ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpgjs9t5zl/6f74ddc5.cpp:55:15: note: previous declaration is here
   55 |   friend bool operator==(const C&, const C&); // expected-note {{previous}} \
      |               ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpgjs9t5zl/6f74ddc5.cpp:121:25: error: constexpr declaration of 'operator!=' follows non-constexpr declaration
  121 |   friend constexpr bool operator!=(const C&, const C&); // expected-error {{non-constexpr}}
      |                         ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpgjs9t5zl/6f74ddc5.cpp:57:15: note: previous declaration is here
   57 |   friend bool operator!=(const C&, const C&) = default; // expected-note {{previous}}
      |               ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpgjs9t5zl/6f74ddc5.cpp:123:41: error: constexpr declaration of 'operator<=>' follows non-constexpr declaration
  123 |   friend constexpr std::strong_ordering operator<=>(const C&, const C&); // expected-error {{non-constexpr}}
      |                                         ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpgjs9t5zl/6f74ddc5.cpp:59:31: note: previous declaration is here
   59 |   friend std::strong_ordering operator<=>(const C&, const C&); // expected-note {{previous}} \
      |                               ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpgjs9t5zl/6f74ddc5.cpp:124:25: error: constexpr declaration of 'operator<' follows non-constexpr declaration
  124 |   friend constexpr bool operator<(const C&, const C&); // expected-error {{non-constexpr}}
      |                         ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpgjs9t5zl/6f74ddc5.cpp:61:15: note: previous declaration is here
   61 |   friend bool operator<(const C&, const C&) = default; // expected-note {{previous}}
      |               ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpgjs9t5zl/6f74ddc5.cpp:125:25: error: constexpr declaration of 'operator<=' follows non-constexpr declaration
  125 |   friend constexpr bool operator<=(const C&, const C&); // expected-error {{non-constexpr}}
      |                         ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpgjs9t5zl/6f74ddc5.cpp:62:15: note: previous declaration is here
   62 |   friend bool operator<=(const C&, const C&) = default; // expected-note {{previous}}
      |               ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpgjs9t5zl/6f74ddc5.cpp:126:25: error: constexpr declaration of 'operator>' follows non-constexpr declaration
  126 |   friend constexpr bool operator>(const C&, const C&); // expected-error {{non-constexpr}}
      |                         ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpgjs9t5zl/6f74ddc5.cpp:63:15: note: previous declaration is here
   63 |   friend bool operator>(const C&, const C&) = default; // expected-note {{previous}}
      |               ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpgjs9t5zl/6f74ddc5.cpp:127:25: error: constexpr declaration of 'operator>=' follows non-constexpr declaration
  127 |   friend constexpr bool operator>=(const C&, const C&); // expected-error {{non-constexpr}}
      |                         ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpgjs9t5zl/6f74ddc5.cpp:64:15: note: previous declaration is here
   64 |   friend bool operator>=(const C&, const C&) = default; // expected-note {{previous}}
      |               ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpgjs9t5zl/6f74ddc5.cpp:128:2: error: expected ';' after struct
  128 | }
      |  ^
      |  ;
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpgjs9t5zl/6f74ddc5.cpp:141:2: error: expected ';' after struct
  141 | }
      |  ^
      |  ;
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpgjs9t5zl/6f74ddc5.cpp:151:2: error: expected ';' after struct
  151 | }
      |  ^
      |  ;
fatal error: too many errors emitted, stopping now [-ferror-limit=]
clang++: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-project/clang/lib/Sema/SemaLookup.cpp:1854: static bool clang::LookupResult::isAcceptableSlow(clang::Sema&, clang::NamedDecl*, clang::Sema::AcceptableKind): Assertion `DeclModule && "hidden decl has no owning module"' failed.
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and dumped files.
Stack dump:
0.	Program arguments: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin/clang++ -emit-llvm -S -o /dev/null -O2 -std=c++23 /home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpgjs9t5zl/6f74ddc5.cpp
1.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpgjs9t5zl/6f74ddc5.cpp:179:64: current parser token ';'
2.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpgjs9t5zl/6f74ddc5.cpp:178:1: parsing struct/union/class body 'TestB'
Stack dump without symbol names (ensure you have llvm-symbolizer in your PATH or set the environment var `LLVM_SYMBOLIZER_PATH` to point to it):
0  clang++   0x000055bf0a1420f9 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) + 121
1  clang++   0x000055bf0a13edcc llvm::sys::RunSignalHandlers() + 76
2  clang++   0x000055bf0a13f678 llvm::sys::CleanupOnSignal(unsigned long) + 216
3  clang++   0x000055bf0a081f88
4  libc.so.6 0x00007f1a94094520
5  libc.so.6 0x00007f1a940e89fc pthread_kill + 300
6  libc.so.6 0x00007f1a94094476 raise + 22
7  libc.so.6 0x00007f1a9407a7f3 abort + 211
8  libc.so.6 0x00007f1a9407a71b
9  libc.so.6 0x00007f1a9408be96
10 clang++   0x000055bf0d00f94f clang::LookupResult::isAcceptableSlow(clang::Sema&, clang::NamedDecl*, clang::Sema::AcceptableKind) + 591
11 clang++   0x000055bf0d011fcf clang::LookupResult::isAvailableForLookup(clang::Sema&, clang::NamedDecl*) + 47
12 clang++   0x000055bf0d02d6e6
13 clang++   0x000055bf0d02e066 clang::Sema::LookupQualifiedName(clang::LookupResult&, clang::DeclContext*, bool) + 214
14 clang++   0x000055bf0cd70806 clang::Sema::ActOnFriendFunctionDecl(clang::Scope*, clang::Declarator&, llvm::MutableArrayRef<clang::TemplateParameterList*>) + 2374
15 clang++   0x000055bf0c945e1f clang::Parser::ParseCXXClassMemberDeclaration(clang::AccessSpecifier, clang::ParsedAttributes&, clang::Parser::ParsedTemplateInfo&, clang::ParsingDeclRAIIObject*) + 7343
16 clang++   0x000055bf0c947230 clang::Parser::ParseCXXClassMemberDeclarationWithPragmas(clang::AccessSpecifier&, clang::ParsedAttributes&, clang::TypeSpecifierType, clang::Decl*) + 1296
17 clang++   0x000055bf0c9478f8 clang::Parser::ParseCXXMemberSpecification(clang::SourceLocation, clang::SourceLocation, clang::ParsedAttributes&, unsigned int, clang::Decl*) + 1144
18 clang++   0x000055bf0c94a4ff clang::Parser::ParseClassSpecifier(clang::tok::TokenKind, clang::SourceLocation, clang::DeclSpec&, clang::Parser::ParsedTemplateInfo&, clang::AccessSpecifier, bool, clang::Parser::DeclSpecContext, clang::ParsedAttributes&) + 8191
19 clang++   0x000055bf0c919732 clang::Parser::ParseDeclarationSpecifiers(clang::DeclSpec&, clang::Parser::ParsedTemplateInfo&, clang::AccessSpecifier, clang::Parser::DeclSpecContext, clang::LateParsedAttrList*, clang::ImplicitTypenameContext) + 2994
20 clang++   0x000055bf0c8d4e88 clang::Parser::ParseDeclOrFunctionDefInternal(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec&, clang::AccessSpecifier) + 200
21 clang++   0x000055bf0c8d592f clang::Parser::ParseDeclarationOrFunctionDefinition(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec*, clang::AccessSpecifier) + 959
22 clang++   0x000055bf0c8e17a1 clang::Parser::ParseExternalDeclaration(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec*) + 977
23 clang++   0x000055bf0c8e27df clang::Parser::ParseTopLevelDecl(clang::OpaquePtr<clang::DeclGroupRef>&, clang::Sema::ModuleImportState&) + 575
24 clang++   0x000055bf0c8bf70a clang::ParseAST(clang::Sema&, bool, bool) + 586
25 clang++   0x000055bf0ae38071 clang::FrontendAction::Execute() + 65
26 clang++   0x000055bf0adc1c65 clang::CompilerInstance::ExecuteAction(clang::FrontendAction&) + 1589
27 clang++   0x000055bf0af13ea3 clang::ExecuteCompilerInvocation(clang::CompilerInstance*) + 467
28 clang++   0x000055bf08b16c96 cc1_main(llvm::ArrayRef<char const*>, char const*, void*) + 7046
29 clang++   0x000055bf08b0ca2a
30 clang++   0x000055bf08b0cbbf
31 clang++   0x000055bf0ab4935d
32 clang++   0x000055bf0a0823a0 llvm::CrashRecoveryContext::RunSafely(llvm::function_ref<void ()>) + 160
33 clang++   0x000055bf0ab4a1b3
34 clang++   0x000055bf0aaff987 clang::driver::Compilation::ExecuteCommand(clang::driver::Command const&, clang::driver::Command const*&, bool) const + 167
35 clang++   0x000055bf0ab041e0 clang::driver::Compilation::ExecuteJobs(clang::driver::JobList const&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&, bool) const + 304
36 clang++   0x000055bf0ab11e44 clang::driver::Driver::ExecuteCompilation(clang::driver::Compilation&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&) + 404
37 clang++   0x000055bf08b122d3 clang_main(int, char**, llvm::ToolContext const&) + 7267
38 clang++   0x000055bf08a647a1 main + 113
39 libc.so.6 0x00007f1a9407bd90
40 libc.so.6 0x00007f1a9407be40 __libc_start_main + 128
41 clang++   0x000055bf08b0c055 _start + 37
clang++: error: clang frontend command failed due to signal (use -v to see invocation)
clang version 24.0.0git (https://github.com/llvm/llvm-project.git aefba88f46a6e55645c848f58f6ba56944d5ae62)
Target: x86_64-unknown-linux-gnu
Thread model: posix
InstalledDir: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin
Build config: +assertions
clang++: note: diagnostic msg: 
********************

PLEASE ATTACH THE FOLLOWING CRASH REPRODUCER FILES TO THE BUG REPORT:
clang++: note: diagnostic msg: /tmp/6f74ddc5-2bd21f.cpp
clang++: note: diagnostic msg: /tmp/6f74ddc5-2bd21f.sh
clang++: note: diagnostic msg: 

********************
Aborted (core dumped)
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ulimit -v 3145728; ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin/clang++ -emit-llvm -S -o /dev/null -O2 -std=c++23 "$SCRIPT_DIR/test.cpp"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `6e16a4f6` | Project seed |
| `b` | `9ef4919f` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
