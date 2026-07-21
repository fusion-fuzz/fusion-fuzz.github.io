*Fusion-Fuzz Bug Report*

**ID:** `f8bb158f` &nbsp;·&nbsp; **Signature:** `Stack dump: current parser token '(' [clang::CXXMethodDecl::isStatic > clang::UnresolvedMemberExpr::UnresolvedMemberExpr > clang::UnresolvedMemberExpr::Create]` &nbsp;·&nbsp; **RC:** `1`

The following code:

```cpp
// RUN: %clang_cc1 -fsyntax-only -std=c++11 -verify %s

template<typename T> struct A {
  void f() { }
  struct N { }; // expected-note{{target of using declaration}}
};

template<typename T> struct B : A<T> {
  using A<T>::f;
  using A<T>::N; // expected-error{{dependent using declaration resolved to type without 'typename'}}

  using A<T>::foo; // expected-error{{no member named 'foo'}}
  using A<double>::f; // expected-error{{using declaration refers into 'A<double>', which is not a base class of 'B<int>'}}
};

B<int> a; // expected-note{{in instantiation of template class 'B<int>' requested here}}

template<typename T> struct C : A<T> {
  using A<T>::f;

  void f() { };
};

template <typename T> struct D : A<T> {
  using A<T>::f;

  void f();
};

template<typename T> void D<T>::f() { }

template<typename T> struct E : A<T> {
  using A<T>::f;

  void g() { f(); }
};

namespace test0 {
  struct Base {
    int foo;
  };
  template<typename T> struct E : Base {
    using Base::foo;
  };

  template struct E<int>;
}

// PR7896
namespace PR7896 {
template <class T> struct Foo {
  int k (float);
};
struct ffl_fusion {
  int k (int);
};
template <class T> struct Bar : public Foo<T>, Baz {
  using Foo<T>::k;
  using Baz::k;
  int foo() {
    return k (1.0f);
  }
};
template int Bar<int>::foo();
}

// PR10883
namespace PR10883 {
  template <typename T>
  class Base {
   public:
    typedef long Container;
  };

  template <typename T>
  class Derived : public Base<T> {
   public:
    using Base<T>::Container;

    void foo(const Container& current); // expected-error {{unknown type name 'Container'}}
  };
}

template<typename T> class UsingTypenameNNS {
  using typename T::X;
  typename X::X x;
};

namespace aliastemplateinst {
  template<typename T> struct A { };
  template<typename T> using APtr = A<T*>; // expected-note{{previous use is here}}

  template struct APtr<int>; // expected-error{{alias template 'APtr' cannot be referenced with the 'struct' specifier}}
}

namespace DontDiagnoseInvalidTest {
template <bool Value> struct Base {
  static_assert(Value, ""); // expected-error {{static assertion failed}}
};
struct Derived : Base<false> { // expected-note {{requested here}}
  using Base<false>::Base; // OK. Don't diagnose that 'Base' isn't a base class of Derived.
};
} // namespace DontDiagnoseInvalidTest

namespace shadow_nested_operator {
template <typename T>
struct A {
  struct Nested {};
  operator Nested*() {return 0;};
};

template <typename T>
struct B : A<T> {
  using A<T>::operator typename A<T>::Nested*;
  operator typename A<T>::Nested *() {
    struct A<T> * thi = this;
    return *thi;
 };
};

int foo () {
  struct B<int> b;
  auto s = *b;
}
} // namespace shadow_nested_operator

namespace func_templ {
namespace sss {
double foo(int, double);
template <class T>
T foo(T);
} // namespace sss

namespace oad {
void foo();
}

namespace oad {
using sss::foo;
}

namespace sss {
using oad::foo;
}

namespace sss {
double foo(int, double) { return 0; }
// There used to be an error with the below declaration when the example should
// be accepted.
template <class T>
T foo(T t) { // OK
  return t;
}
} // namespace sss
} // namespace func_templ

namespace DependentName {
  template <typename T> struct S {
    using typename T::Ty;
    static Ty Val;
  };
  template <typename T> typename S<T>::Ty S<T>::Val;
} // DependentName

/* FIXME: This is a file containing various typos for which we can
   suggest corrections but are unable to actually recover from
   them. Ideally, we would eliminate all such cases and move these
   tests elsewhere. */

// RUN: %clang_cc1 -fsyntax-only -verify %s

float f_ffl(int y) {
  return static_cst<float>(y); // expected-error{{use of undeclared identifier 'static_cst'; did you mean 'static_cast'?}}
}

struct Foobar {}; // expected-note {{here}}
template<typename T> struct Goobar {}; // expected-note {{here}}
void use_foobar() {
  auto x = zoobar(); // expected-error {{did you mean 'Foobar'}}
  auto y = zoobar<int>(); // expected-error {{did you mean 'Goobar'}}
}

static long ffl_fusion = (long)(zoobar);

```

Resulted in this output:

```
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpzup4mx_g/f8bb158f.cpp:10:15: error: dependent using declaration resolved to type without 'typename'
   10 |   using A<T>::N; // expected-error{{dependent using declaration resolved to type without 'typename'}}
      |               ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpzup4mx_g/f8bb158f.cpp:16:8: note: in instantiation of template class 'B<int>' requested here
   16 | B<int> a; // expected-note{{in instantiation of template class 'B<int>' requested here}}
      |        ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpzup4mx_g/f8bb158f.cpp:5:10: note: target of using declaration
    5 |   struct N { }; // expected-note{{target of using declaration}}
      |          ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpzup4mx_g/f8bb158f.cpp:12:15: error: no member named 'foo' in 'A<int>'
   12 |   using A<T>::foo; // expected-error{{no member named 'foo'}}
      |         ~~~~~~^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpzup4mx_g/f8bb158f.cpp:13:9: error: using declaration refers into 'A<double>', which is not a base class of 'B<int>'
   13 |   using A<double>::f; // expected-error{{using declaration refers into 'A<double>', which is not a base class of 'B<int>'}}
      |         ^~~~~~~~~~~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpzup4mx_g/f8bb158f.cpp:57:48: error: expected class name
   57 | template <class T> struct Bar : public Foo<T>, Baz {
      |                                                ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpzup4mx_g/f8bb158f.cpp:59:9: error: use of undeclared identifier 'Baz'; did you mean 'Bar'?
   59 |   using Baz::k;
      |         ^~~
      |         Bar
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpzup4mx_g/f8bb158f.cpp:57:27: note: 'Bar' declared here
   57 | template <class T> struct Bar : public Foo<T>, Baz {
      |                           ^
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace, preprocessed source, and associated run script.
Stack dump:
0.	Program arguments: clang++ -fsyntax-only -O0 -std=c++03 -fno-elide-constructors -Wall /home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpzup4mx_g/f8bb158f.cpp
1.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpzup4mx_g/f8bb158f.cpp:61:14: current parser token '('
2.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpzup4mx_g/f8bb158f.cpp:50:1: parsing namespace 'PR7896'
3.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpzup4mx_g/f8bb158f.cpp:57:20: parsing struct/union/class body 'PR7896::Bar'
4.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpzup4mx_g/f8bb158f.cpp:60:13: parsing function body 'PR7896::Bar::foo'
5.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpzup4mx_g/f8bb158f.cpp:60:13: in compound statement ('{}')
 #0 0x00007f1911da15ea llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/lib/llvm-22/bin/../lib/libLLVM.so.22.1+0x4e9f5ea)
 #1 0x00007f1911d9edf7 llvm::sys::RunSignalHandlers() (/usr/lib/llvm-22/bin/../lib/libLLVM.so.22.1+0x4e9cdf7)
 #2 0x00007f1911ccfd04 (/usr/lib/llvm-22/bin/../lib/libLLVM.so.22.1+0x4dcdd04)
 #3 0x00007f190c973970 (/usr/lib/x86_64-linux-gnu/libc.so.6+0x40970)
 #4 0x00007f191786e5b8 clang::CXXMethodDecl::isStatic() const (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x19215b8)
 #5 0x00007f19179e3a71 clang::UnresolvedMemberExpr::UnresolvedMemberExpr(clang::ASTContext const&, bool, clang::Expr*, clang::QualType, bool, clang::SourceLocation, clang::NestedNameSpecifierLoc, clang::SourceLocation, clang::DeclarationNameInfo const&, clang::TemplateArgumentListInfo const*, clang::UnresolvedSetIterator, clang::UnresolvedSetIterator) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x1a96a71)
 #6 0x00007f19179e3c45 clang::UnresolvedMemberExpr::Create(clang::ASTContext const&, bool, clang::Expr*, clang::QualType, bool, clang::SourceLocation, clang::NestedNameSpecifierLoc, clang::SourceLocation, clang::DeclarationNameInfo const&, clang::TemplateArgumentListInfo const*, clang::UnresolvedSetIterator, clang::UnresolvedSetIterator) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x1a96c45)
 #7 0x00007f1918366ef2 clang::Sema::BuildMemberReferenceExpr(clang::Expr*, clang::QualType, clang::SourceLocation, bool, clang::CXXScopeSpec const&, clang::SourceLocation, clang::NamedDecl*, clang::LookupResult&, clang::TemplateArgumentListInfo const*, clang::Scope const*, bool, clang::Sema::ActOnMemberAccessExtraArgs*) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x2419ef2)
 #8 0x00007f1918363ef2 clang::Sema::BuildPossibleImplicitMemberExpr(clang::CXXScopeSpec const&, clang::SourceLocation, clang::LookupResult&, clang::TemplateArgumentListInfo const*, clang::Scope const*) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x2416ef2)
 #9 0x00007f191826a598 clang::Sema::ActOnIdExpression(clang::Scope*, clang::CXXScopeSpec&, clang::SourceLocation, clang::UnqualifiedId&, bool, bool, clang::CorrectionCandidateCallback*, bool, clang::Token*) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x231d598)
#10 0x00007f19175caf25 clang::Parser::ParseCastExpression(clang::CastParseKind, bool, bool&, clang::TypoCorrectionTypeBehavior, bool, bool*) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x167df25)
#11 0x00007f19175c574d clang::Parser::ParseAssignmentExpression(clang::TypoCorrectionTypeBehavior) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x167874d)
#12 0x00007f19175c561d clang::Parser::ParseExpression(clang::TypoCorrectionTypeBehavior) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x167861d)
#13 0x00007f191762c601 clang::Parser::ParseReturnStatement() (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x16df601)
#14 0x00007f19176270bb clang::Parser::ParseStatementOrDeclarationAfterAttributes(llvm::SmallVector<clang::Stmt*, 24u>&, clang::Parser::ParsedStmtContext, clang::SourceLocation*, clang::ParsedAttributes&, clang::ParsedAttributes&, clang::LabelDecl*) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x16da0bb)
#15 0x00007f1917625eda clang::Parser::ParseStatementOrDeclaration(llvm::SmallVector<clang::Stmt*, 24u>&, clang::Parser::ParsedStmtContext, clang::SourceLocation*, clang::LabelDecl*) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x16d8eda)
#16 0x00007f191762e736 clang::Parser::ParseCompoundStatementBody(bool) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x16e1736)
#17 0x00007f191762f3c9 clang::Parser::ParseFunctionStatementBody(clang::Decl*, clang::Parser::ParseScope&) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x16e23c9)
#18 0x00007f19175879da clang::Parser::ParseLexedMethodDef(clang::Parser::LexedMethod&) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x163a9da)
#19 0x00007f191758676a clang::Parser::ParseLexedMethodDefs(clang::Parser::ParsingClass&) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x163976a)
#20 0x00007f19175ba188 clang::Parser::ParseCXXMemberSpecification(clang::SourceLocation, clang::SourceLocation, clang::ParsedAttributes&, unsigned int, clang::Decl*) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x166d188)
#21 0x00007f19175b8050 clang::Parser::ParseClassSpecifier(clang::tok::TokenKind, clang::SourceLocation, clang::DeclSpec&, clang::Parser::ParsedTemplateInfo&, clang::AccessSpecifier, bool, clang::Parser::DeclSpecContext, clang::ParsedAttributes&) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x166b050)
#22 0x00007f191759aae6 clang::Parser::ParseDeclarationSpecifiers(clang::DeclSpec&, clang::Parser::ParsedTemplateInfo&, clang::AccessSpecifier, clang::Parser::DeclSpecContext, clang::Parser::LateParsedAttrList*, clang::ImplicitTypenameContext) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x164dae6)
#23 0x00007f1917636059 clang::Parser::ParseDeclarationAfterTemplate(clang::DeclaratorContext, clang::Parser::ParsedTemplateInfo&, clang::ParsingDeclRAIIObject&, clang::SourceLocation&, clang::ParsedAttributes&, clang::AccessSpecifier) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x16e9059)
#24 0x00007f19176356a8 clang::Parser::ParseTemplateDeclarationOrSpecialization(clang::DeclaratorContext, clang::SourceLocation&, clang::ParsedAttributes&, clang::AccessSpecifier) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x16e86a8)
#25 0x00007f1917635055 clang::Parser::ParseDeclarationStartingWithTemplate(clang::DeclaratorContext, clang::SourceLocation&, clang::ParsedAttributes&) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x16e8055)
#26 0x00007f1917595622 clang::Parser::ParseDeclaration(clang::DeclaratorContext, clang::SourceLocation&, clang::ParsedAttributes&, clang::ParsedAttributes&, clang::SourceLocation*) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x1648622)
#27 0x00007f19176449b4 clang::Parser::ParseExternalDeclaration(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec*) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x16f79b4)
#28 0x00007f19175b0f2f clang::Parser::ParseInnerNamespace(llvm::SmallVector<clang::Parser::InnerNamespaceInfo, 4u> const&, unsigned int, clang::SourceLocation&, clang::ParsedAttributes&, clang::BalancedDelimiterTracker&) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x1663f2f)
#29 0x00007f19175b08e9 clang::Parser::ParseNamespace(clang::DeclaratorContext, clang::SourceLocation&, clang::SourceLocation) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x16638e9)
#30 0x00007f191759574c clang::Parser::ParseDeclaration(clang::DeclaratorContext, clang::SourceLocation&, clang::ParsedAttributes&, clang::ParsedAttributes&, clang::SourceLocation*) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x164874c)
#31 0x00007f19176449b4 clang::Parser::ParseExternalDeclaration(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec*) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x16f79b4)
#32 0x00007f19176438f7 clang::Parser::ParseTopLevelDecl(clang::OpaquePtr<clang::DeclGroupRef>&, clang::Sema::ModuleImportState&) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x16f68f7)
#33 0x00007f191758267e clang::ParseAST(clang::Sema&, bool, bool) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x163567e)
#34 0x00007f19192bcbef clang::FrontendAction::Execute() (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x336fbef)
#35 0x00007f1919230044 clang::CompilerInstance::ExecuteAction(clang::FrontendAction&) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x32e3044)
#36 0x00007f191934af9a clang::ExecuteCompilerInvocation(clang::CompilerInstance*) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x33fdf9a)
#37 0x0000557c8a265cdd cc1_main(llvm::ArrayRef<char const*>, char const*, void*) (/usr/lib/llvm-22/bin/clang+0x13cdd)
#38 0x0000557c8a26253b (/usr/lib/llvm-22/bin/clang+0x1053b)
#39 0x0000557c8a263fcc (/usr/lib/llvm-22/bin/clang+0x11fcc)
#40 0x00007f1918ee4afd (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x2f97afd)
#41 0x00007f1911ccf9d0 llvm::CrashRecoveryContext::RunSafely(llvm::function_ref<void ()>) (/usr/lib/llvm-22/bin/../lib/libLLVM.so.22.1+0x4dcd9d0)
#42 0x00007f1918ee45b1 clang::driver::CC1Command::Execute(llvm::ArrayRef<std::optional<llvm::StringRef>>, std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char>>*, bool*) const (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x2f975b1)
#43 0x00007f1918ea3732 clang::driver::Compilation::ExecuteCommand(clang::driver::Command const&, clang::driver::Command const*&, bool) const (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x2f56732)
#44 0x00007f1918ea38fe clang::driver::Compilation::ExecuteJobs(clang::driver::JobList const&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&, bool) const (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x2f568fe)
#45 0x00007f1918ec51ff clang::driver::Driver::ExecuteCompilation(clang::driver::Compilation&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x2f781ff)
#46 0x0000557c8a26202d clang_main(int, char**, llvm::ToolContext const&) (/usr/lib/llvm-22/bin/clang+0x1002d)
#47 0x0000557c8a2709aa main (/usr/lib/llvm-22/bin/clang+0x1e9aa)
#48 0x00007f190c95cf77 (/usr/lib/x86_64-linux-gnu/libc.so.6+0x29f77)
#49 0x00007f190c95d027 __libc_start_main (/usr/lib/x86_64-linux-gnu/libc.so.6+0x2a027)
#50 0x0000557c8a2601d1 _start (/usr/lib/llvm-22/bin/clang+0xe1d1)
clang++: error: clang frontend command failed with exit code 139 (use -v to see invocation)
Debian clang version 22.1.8 (1+b1)
Target: x86_64-pc-linux-gnu
Thread model: posix
InstalledDir: /usr/lib/llvm-22/bin
clang++: note: diagnostic msg: 
********************

PLEASE ATTACH THE FOLLOWING FILES TO THE BUG REPORT:
Preprocessed source(s) and associated run script(s) are located at:
clang++: note: diagnostic msg: /tmp/f8bb158f-ae69f7.cpp
clang++: note: diagnostic msg: /tmp/f8bb158f-ae69f7.sh
clang++: note: diagnostic msg: 

********************
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ulimit -v 3145728; ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' clang++ -fsyntax-only -O0 -std=c++03 -fno-elide-constructors -Wall "$SCRIPT_DIR/test.cpp"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `0af366bb` | Project seed |
| `b` | `e5122458` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
