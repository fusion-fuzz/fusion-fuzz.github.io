*Fusion-Fuzz Bug Report*

**ID:** `a06f9cc6` &nbsp;·&nbsp; **Signature:** `Stack dump: <eof> parser at end of file [clang::CXXRecordDecl::hasConstexprDestructor > clang::Sema::CheckConstexprFunctionDefinition > clang::Sema::ActOnFinishFunctionBody]` &nbsp;·&nbsp; **RC:** `1`

The following code:

```cpp
//--- k.h
namespace base {
namespace internal {
struct LiteralTag ;
}  
}
//--- d.cppmap
module "//d" {
}
//--- b.cppmap
module "//b" {
    header "b.h"
}
//--- e.cppmap
module "//e" {
}
//--- c.cppmap
module "//c" {
}
//--- f.cppmap
module "//f" {
}
//--- i.cppmap
module "//i" {
}
//--- g.cppmap
module "//g" {
}
//--- h.cppmap
module "//h" {
}
//--- k.cppmap
module "//k" {
    header "k.h"
}
//--- l.cppmap
module "//l" {
}
//--- m.cppmap
module "//m" {
}
//--- j.cppmap
module "//j" {
}
//--- o.cppmap
module "//o" {
}
//--- b.h
namespace base {}
//--- n.cppmap
module "//n" {
    header "n.h"
}
//--- n.h
namespace _View {}
// RUN: rm -rf %t
// RUN: mkdir %t
// RUN: split-file %s %t
// RUN: cd %t
//
// RUN: %clang -fmodule-name=//b -Xclang=-fno-cxx-modules -Xclang=-fmodule-map-file-home-is-cwd -xc++ -Xclang=-emit-module -fmodules -fno-implicit-modules -fno-implicit-module-maps -c b.cppmap -o b.pic.pcm
// RUN: %clang -fmodule-name=//c -Xclang=-fno-cxx-modules -Xclang=-fmodule-map-file-home-is-cwd -xc++ -Xclang=-emit-module -fmodules -fno-implicit-modules -fno-implicit-module-maps -Xclang=-fmodule-file=b.pic.pcm -c c.cppmap -o c.pic.pcm
// RUN: %clang -fmodule-name=//d -Xclang=-fno-cxx-modules -Xclang=-fmodule-map-file-home-is-cwd -xc++ -Xclang=-emit-module -fmodules -fno-implicit-modules -fno-implicit-module-maps -Xclang=-fmodule-file=c.pic.pcm -c d.cppmap -o d.pic.pcm
// RUN: %clang -fmodule-name=//e -Xclang=-fno-cxx-modules -Xclang=-fmodule-map-file-home-is-cwd -xc++ -Xclang=-emit-module -fmodules -fno-implicit-modules -fno-implicit-module-maps -Xclang=-fmodule-file=d.pic.pcm -c e.cppmap -o e.pic.pcm
// RUN: %clang -fmodule-name=//f -Xclang=-fno-cxx-modules -Xclang=-fmodule-map-file-home-is-cwd -xc++ -Xclang=-emit-module -fmodules -fno-implicit-modules -fno-implicit-module-maps -Xclang=-fmodule-file=e.pic.pcm -c f.cppmap -o f.pic.pcm
// RUN: %clang -fmodule-name=//g -Xclang=-fno-cxx-modules -Xclang=-fmodule-map-file-home-is-cwd -xc++ -Xclang=-emit-module -fmodules -fno-implicit-modules -fno-implicit-module-maps -Xclang=-fmodule-file=f.pic.pcm -c g.cppmap -o g.pic.pcm
// RUN: %clang -fmodule-name=//h -Xclang=-fno-cxx-modules -Xclang=-fmodule-map-file-home-is-cwd -xc++ -Xclang=-emit-module -fmodules -fno-implicit-modules -fno-implicit-module-maps -Xclang=-fmodule-file=g.pic.pcm -c h.cppmap -o h.pic.pcm
// RUN: %clang -fmodule-name=//i -Xclang=-fno-cxx-modules -Xclang=-fmodule-map-file-home-is-cwd -xc++ -Xclang=-emit-module -fmodules -fno-implicit-modules -fno-implicit-module-maps -Xclang=-fmodule-file=h.pic.pcm -c i.cppmap -o i.pic.pcm
// RUN: %clang -fmodule-name=//j -Xclang=-fno-cxx-modules -Xclang=-fmodule-map-file-home-is-cwd -xc++ -Xclang=-emit-module -fmodules -fno-implicit-modules -fno-implicit-module-maps -Xclang=-fmodule-file=i.pic.pcm -c j.cppmap -o j.pic.pcm
// RUN: %clang -fmodule-name=//k -Xclang=-fno-cxx-modules -Xclang=-fmodule-map-file-home-is-cwd -xc++ -Xclang=-emit-module -fmodules -fno-implicit-modules -fno-implicit-module-maps -c k.cppmap -o k.pic.pcm
// RUN: %clang -fmodule-name=//l -Xclang=-fno-cxx-modules -Xclang=-fmodule-map-file-home-is-cwd -xc++ -Xclang=-emit-module -fmodules -fno-implicit-modules -fno-implicit-module-maps -Xclang=-fmodule-file=j.pic.pcm -c l.cppmap -o l.pic.pcm
// RUN: %clang -fmodule-name=//m -Xclang=-fno-cxx-modules -Xclang=-fmodule-map-file-home-is-cwd -xc++ -Xclang=-emit-module -fmodules -fno-implicit-modules -fno-implicit-module-maps -Xclang=-fmodule-file=k.pic.pcm -c m.cppmap -o m.pic.pcm
// RUN: %clang -fmodule-name=//n -Xclang=-fno-cxx-modules -Xclang=-fmodule-map-file-home-is-cwd -xc++ -Xclang=-emit-module -fmodules -fno-implicit-modules -fno-implicit-module-maps -Xclang=-fmodule-file=l.pic.pcm -Xclang=-fmodule-file=m.pic.pcm -c n.cppmap -o n.pic.pcm
// RUN: %clang -fmodule-name=//o -Xclang=-fno-cxx-modules -Xclang=-fmodule-map-file-home-is-cwd -xc++ -Xclang=-emit-module -fmodules -fno-implicit-modules -fno-implicit-module-maps -Xclang=-fmodule-file=n.pic.pcm -c o.cppmap -o o.pic.pcm
// RUN: %clang -Xclang=-fno-cxx-modules -Xclang=-fmodule-map-file-home-is-cwd -fmodules -fno-implicit-modules -fno-implicit-module-maps -Xclang=-fmodule-file=o.pic.pcm -c a.cc -o a.o

//--- a.cc
#include "k.h"
namespace base {
namespace internal {}  
}
#define REGISTER_MODULE_INITIALIZER(name, body) REGISTER_INITIALIZER(, , )
class FooInitializer ;
REGISTER_MODULE_INITIALIZER(, );
// RUN: %clang_cc1 -std=c++2c -fexperimental-new-constant-interpreter -verify=expected,both %s
// RUN: %clang_cc1 -std=c++2c  -verify=ref,both %s

// both-no-diagnostics

namespace std {
inline namespace {
template <bool, class _IfRes, class> using conditional_t = _IfRes;
template <class _Ip>
concept input_iterator = requires { typename _Ip; };
auto end = int{};
namespace ranges {
template <class>
concept range = requires { end; };
template <class _Tp>
concept input_range = input_iterator<_Tp>;
template <class>
concept forward_range = false;
template <range _Rp> struct owning_view {
  _Rp __r_;
};
} // namespace ranges
template <int _Size> struct array {
  int __elems_[_Size];
};
template <class> struct allocator {
  constexpr array<2> *allocate(decltype(sizeof(int))) {
    return static_cast<array<2> *>(operator new(sizeof(array<2>)));
  }
};
namespace ranges {
template <input_range _View, forward_range _Pattern> struct join_with_view {
  join_with_view(_View, _Pattern);
};
} // namespace ranges
template <class> struct vector {
  constexpr ~vector() {
    (__end_ - 1)->~array<2>();
  }
  constexpr vector() {
    __end_ = __alloc_.allocate(0);
    _ConstructTransaction __tx(*this);
    ++__tx.__pos_;
  }
  array<2>* __end_;
  allocator<array<2>> __alloc_;
  struct _ConstructTransaction {
    constexpr _ConstructTransaction(vector &__v)
        : __v_(__v), __pos_(__v.__end_) {}
    constexpr ~_ConstructTransaction() { __v_.__end_ = __pos_; }
    vector __v_;
    array<2>* __pos_;
  };
};
} // namespace
}
// namespace std
template <bool RefIsGlvalue, class Inner>
using VRange = std::conditional_t<RefIsGlvalue, std::vector<Inner>, Inner>;
#define REGISTER_INITIALIZER(type, name, body)              void foo_init__() ;   FooInitializer initializer_name( base::internal::LiteralTag\
      foo_init__)
template <int RefIsGlvalue> void test_pre_increment() {
  using V = VRange<RefIsGlvalue, std::array<2>>;
  using Pattern = std::array<2>;
  using JWV = std::ranges::join_with_view<std::ranges::owning_view<V>,
                                          std::ranges::owning_view<Pattern>>;
  JWV jwv({}, {});
}
```

Resulted in this output:

```
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpt03x0624/a06f9cc6.cpp:8:1: error: unknown type name 'module'
    8 | module "//d" {
      | ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpt03x0624/a06f9cc6.cpp:8:8: error: expected unqualified-id
    8 | module "//d" {
      |        ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpt03x0624/a06f9cc6.cpp:11:1: error: unknown type name 'module'
   11 | module "//b" {
      | ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpt03x0624/a06f9cc6.cpp:11:8: error: expected unqualified-id
   11 | module "//b" {
      |        ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpt03x0624/a06f9cc6.cpp:15:1: error: unknown type name 'module'
   15 | module "//e" {
      | ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpt03x0624/a06f9cc6.cpp:15:8: error: expected unqualified-id
   15 | module "//e" {
      |        ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpt03x0624/a06f9cc6.cpp:18:1: error: unknown type name 'module'
   18 | module "//c" {
      | ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpt03x0624/a06f9cc6.cpp:18:8: error: expected unqualified-id
   18 | module "//c" {
      |        ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpt03x0624/a06f9cc6.cpp:21:1: error: unknown type name 'module'
   21 | module "//f" {
      | ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpt03x0624/a06f9cc6.cpp:21:8: error: expected unqualified-id
   21 | module "//f" {
      |        ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpt03x0624/a06f9cc6.cpp:24:1: error: unknown type name 'module'
   24 | module "//i" {
      | ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpt03x0624/a06f9cc6.cpp:24:8: error: expected unqualified-id
   24 | module "//i" {
      |        ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpt03x0624/a06f9cc6.cpp:27:1: error: unknown type name 'module'
   27 | module "//g" {
      | ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpt03x0624/a06f9cc6.cpp:27:8: error: expected unqualified-id
   27 | module "//g" {
      |        ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpt03x0624/a06f9cc6.cpp:30:1: error: unknown type name 'module'
   30 | module "//h" {
      | ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpt03x0624/a06f9cc6.cpp:30:8: error: expected unqualified-id
   30 | module "//h" {
      |        ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpt03x0624/a06f9cc6.cpp:33:1: error: unknown type name 'module'
   33 | module "//k" {
      | ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpt03x0624/a06f9cc6.cpp:33:8: error: expected unqualified-id
   33 | module "//k" {
      |        ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpt03x0624/a06f9cc6.cpp:37:1: error: unknown type name 'module'
   37 | module "//l" {
      | ^
fatal error: too many errors emitted, stopping now [-ferror-limit=]
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace, preprocessed source, and associated run script.
Stack dump:
0.	Program arguments: clang++ -fsyntax-only -O3 -Wall -fsanitize=address /home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpt03x0624/a06f9cc6.cpp
1.	<eof> parser at end of file
2.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpt03x0624/a06f9cc6.cpp:90:1: parsing namespace 'std'
3.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpt03x0624/a06f9cc6.cpp:91:8: parsing namespace 'std::(anonymous)'
4.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpt03x0624/a06f9cc6.cpp:120:18: parsing struct/union/class body 'std::vector'
5.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpt03x0624/a06f9cc6.cpp:121:23: parsing function body 'std::vector::~vector<type-parameter-0-0>'
 #0 0x00007ff4c92c55ea llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/lib/llvm-22/bin/../lib/libLLVM.so.22.1+0x4e9f5ea)
 #1 0x00007ff4c92c2df7 llvm::sys::RunSignalHandlers() (/usr/lib/llvm-22/bin/../lib/libLLVM.so.22.1+0x4e9cdf7)
 #2 0x00007ff4c91f3d04 (/usr/lib/llvm-22/bin/../lib/libLLVM.so.22.1+0x4dcdd04)
 #3 0x00007ff4c3e97970 (/usr/lib/x86_64-linux-gnu/libc.so.6+0x40970)
 #4 0x00007ff4ced8c5ef clang::CXXRecordDecl::hasConstexprDestructor() const (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x191b5ef)
 #5 0x00007ff4cf759a50 (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x22e8a50)
 #6 0x00007ff4cf720778 clang::Sema::CheckConstexprFunctionDefinition(clang::FunctionDecl const*, clang::Sema::CheckConstexprKind) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x22af778)
 #7 0x00007ff4cf6cbec7 clang::Sema::ActOnFinishFunctionBody(clang::Decl*, clang::Stmt*, bool, bool) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x225aec7)
 #8 0x00007ff4ceb5342c clang::Parser::ParseFunctionStatementBody(clang::Decl*, clang::Parser::ParseScope&) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x16e242c)
 #9 0x00007ff4ceaab9da clang::Parser::ParseLexedMethodDef(clang::Parser::LexedMethod&) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x163a9da)
#10 0x00007ff4ceaaa76a clang::Parser::ParseLexedMethodDefs(clang::Parser::ParsingClass&) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x163976a)
#11 0x00007ff4ceade188 clang::Parser::ParseCXXMemberSpecification(clang::SourceLocation, clang::SourceLocation, clang::ParsedAttributes&, unsigned int, clang::Decl*) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x166d188)
#12 0x00007ff4ceadc050 clang::Parser::ParseClassSpecifier(clang::tok::TokenKind, clang::SourceLocation, clang::DeclSpec&, clang::Parser::ParsedTemplateInfo&, clang::AccessSpecifier, bool, clang::Parser::DeclSpecContext, clang::ParsedAttributes&) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x166b050)
#13 0x00007ff4ceabeae6 clang::Parser::ParseDeclarationSpecifiers(clang::DeclSpec&, clang::Parser::ParsedTemplateInfo&, clang::AccessSpecifier, clang::Parser::DeclSpecContext, clang::Parser::LateParsedAttrList*, clang::ImplicitTypenameContext) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x164dae6)
#14 0x00007ff4ceb5a059 clang::Parser::ParseDeclarationAfterTemplate(clang::DeclaratorContext, clang::Parser::ParsedTemplateInfo&, clang::ParsingDeclRAIIObject&, clang::SourceLocation&, clang::ParsedAttributes&, clang::AccessSpecifier) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x16e9059)
#15 0x00007ff4ceb596a8 clang::Parser::ParseTemplateDeclarationOrSpecialization(clang::DeclaratorContext, clang::SourceLocation&, clang::ParsedAttributes&, clang::AccessSpecifier) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x16e86a8)
#16 0x00007ff4ceb59055 clang::Parser::ParseDeclarationStartingWithTemplate(clang::DeclaratorContext, clang::SourceLocation&, clang::ParsedAttributes&) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x16e8055)
#17 0x00007ff4ceab9622 clang::Parser::ParseDeclaration(clang::DeclaratorContext, clang::SourceLocation&, clang::ParsedAttributes&, clang::ParsedAttributes&, clang::SourceLocation*) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x1648622)
#18 0x00007ff4ceb689b4 clang::Parser::ParseExternalDeclaration(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec*) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x16f79b4)
#19 0x00007ff4cead4f2f clang::Parser::ParseInnerNamespace(llvm::SmallVector<clang::Parser::InnerNamespaceInfo, 4u> const&, unsigned int, clang::SourceLocation&, clang::ParsedAttributes&, clang::BalancedDelimiterTracker&) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x1663f2f)
#20 0x00007ff4cead48e9 clang::Parser::ParseNamespace(clang::DeclaratorContext, clang::SourceLocation&, clang::SourceLocation) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x16638e9)
#21 0x00007ff4ceab974c clang::Parser::ParseDeclaration(clang::DeclaratorContext, clang::SourceLocation&, clang::ParsedAttributes&, clang::ParsedAttributes&, clang::SourceLocation*) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x164874c)
#22 0x00007ff4ceb689b4 clang::Parser::ParseExternalDeclaration(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec*) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x16f79b4)
#23 0x00007ff4cead4f2f clang::Parser::ParseInnerNamespace(llvm::SmallVector<clang::Parser::InnerNamespaceInfo, 4u> const&, unsigned int, clang::SourceLocation&, clang::ParsedAttributes&, clang::BalancedDelimiterTracker&) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x1663f2f)
#24 0x00007ff4cead48e9 clang::Parser::ParseNamespace(clang::DeclaratorContext, clang::SourceLocation&, clang::SourceLocation) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x16638e9)
#25 0x00007ff4ceab974c clang::Parser::ParseDeclaration(clang::DeclaratorContext, clang::SourceLocation&, clang::ParsedAttributes&, clang::ParsedAttributes&, clang::SourceLocation*) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x164874c)
#26 0x00007ff4ceb689b4 clang::Parser::ParseExternalDeclaration(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec*) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x16f79b4)
#27 0x00007ff4ceb678f7 clang::Parser::ParseTopLevelDecl(clang::OpaquePtr<clang::DeclGroupRef>&, clang::Sema::ModuleImportState&) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x16f68f7)
#28 0x00007ff4ceaa667e clang::ParseAST(clang::Sema&, bool, bool) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x163567e)
#29 0x00007ff4d07e0bef clang::FrontendAction::Execute() (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x336fbef)
#30 0x00007ff4d0754044 clang::CompilerInstance::ExecuteAction(clang::FrontendAction&) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x32e3044)
#31 0x00007ff4d086ef9a clang::ExecuteCompilerInvocation(clang::CompilerInstance*) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x33fdf9a)
#32 0x00005629e3af7cdd cc1_main(llvm::ArrayRef<char const*>, char const*, void*) (/usr/lib/llvm-22/bin/clang+0x13cdd)
#33 0x00005629e3af453b (/usr/lib/llvm-22/bin/clang+0x1053b)
#34 0x00005629e3af5fcc (/usr/lib/llvm-22/bin/clang+0x11fcc)
#35 0x00007ff4d0408afd (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x2f97afd)
#36 0x00007ff4c91f39d0 llvm::CrashRecoveryContext::RunSafely(llvm::function_ref<void ()>) (/usr/lib/llvm-22/bin/../lib/libLLVM.so.22.1+0x4dcd9d0)
#37 0x00007ff4d04085b1 clang::driver::CC1Command::Execute(llvm::ArrayRef<std::optional<llvm::StringRef>>, std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char>>*, bool*) const (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x2f975b1)
#38 0x00007ff4d03c7732 clang::driver::Compilation::ExecuteCommand(clang::driver::Command const&, clang::driver::Command const*&, bool) const (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x2f56732)
#39 0x00007ff4d03c78fe clang::driver::Compilation::ExecuteJobs(clang::driver::JobList const&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&, bool) const (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x2f568fe)
#40 0x00007ff4d03e91ff clang::driver::Driver::ExecuteCompilation(clang::driver::Compilation&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x2f781ff)
#41 0x00005629e3af402d clang_main(int, char**, llvm::ToolContext const&) (/usr/lib/llvm-22/bin/clang+0x1002d)
#42 0x00005629e3b029aa main (/usr/lib/llvm-22/bin/clang+0x1e9aa)
#43 0x00007ff4c3e80f77 (/usr/lib/x86_64-linux-gnu/libc.so.6+0x29f77)
#44 0x00007ff4c3e81027 __libc_start_main (/usr/lib/x86_64-linux-gnu/libc.so.6+0x2a027)
#45 0x00005629e3af21d1 _start (/usr/lib/llvm-22/bin/clang+0xe1d1)
clang++: error: clang frontend command failed with exit code 139 (use -v to see invocation)
Debian clang version 22.1.8 (1+b1)
Target: x86_64-pc-linux-gnu
Thread model: posix
InstalledDir: /usr/lib/llvm-22/bin
clang++: note: diagnostic msg: Error generating preprocessed source(s).
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ulimit -v 3145728; ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' clang++ -fsyntax-only -O3 -Wall -fsanitize=address "$SCRIPT_DIR/test.cpp"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `e922ded6` | Project seed |
| `b` | `fb1dcc65` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
