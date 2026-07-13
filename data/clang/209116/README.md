*Fusion-Fuzz Bug Report*

**ID:** `c49590ee` &nbsp;·&nbsp; **Signature:** `Stack dump: current parser token 'my_const' [clang::Decl::getASTContext > clang::VarTemplateDecl::findPartialSpecInstantiatedFromMember > clang::TemplateDeclInstantiator::VisitVarTemplatePartialSpecializationDecl]` &nbsp;·&nbsp; **RC:** `1`

The following code:

```cpp
// RUN: %clang_cc1 -x c++ -std=c++11 -fblocks -emit-llvm %s -o - | FileCheck %s

// CHECK: %struct.__block_byref_baz = type { ptr, ptr, i32, i32, i32 }
// CHECK: [[baz:%[0-9a-z_]*]] = alloca %struct.__block_byref_baz
// CHECK: [[bazref:%[0-9a-z_\.]*]] = getelementptr inbounds nuw %struct.__block_byref_baz, ptr [[baz]], i32 0, i32 1
// CHECK: store ptr [[baz]], ptr [[bazref]]
// CHECK: call void @_Block_object_dispose(ptr [[baz]]

int main() {
  __block int baz = [&]() { return 0; }();
  ^{ (void)baz; };
  return 0;
}
// variable template specialization

template <typename T>
struct Wrapper {
  template <typename U> static constexpr baz my_const = U(1);
   // Variable template partial specialization with member variable.
  template <typename U> static constexpr U *my_const<const U *> = (U *)(0);
}
template <typename T>
constexpr T my_pi = T(3.1415926535897932385L);
// variable template

template <> constexpr char my_pi<char> = '3';
template <> template <>
constexpr const char *Wrapper<float>::my_const<const char *> = a;
constexpr char a[] = "hello";
;
```

Resulted in this output:

```
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmps20ohq6x/c49590ee.cpp:10:3: error: unknown type name '__block'
   10 |   __block int baz = [&]() { return 0; }();
      |   ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmps20ohq6x/c49590ee.cpp:11:3: error: blocks support disabled - compile with -fblocks or pick a deployment target that supports them
   11 |   ^{ (void)baz; };
      |   ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmps20ohq6x/c49590ee.cpp:11:3: warning: expression result unused [-Wunused-value]
   11 |   ^{ (void)baz; };
      |   ^~~~~~~~~~~~~~~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmps20ohq6x/c49590ee.cpp:18:42: error: unknown type name 'baz'
   18 |   template <typename U> static constexpr baz my_const = U(1);
      |                                          ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmps20ohq6x/c49590ee.cpp:18:46: warning: variable templates are a C++14 extension [-Wc++14-extensions]
   18 |   template <typename U> static constexpr baz my_const = U(1);
      |                                              ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmps20ohq6x/c49590ee.cpp:21:2: error: expected ';' after struct
   21 | }
      |  ^
      |  ;
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmps20ohq6x/c49590ee.cpp:23:13: warning: variable templates are a C++14 extension [-Wc++14-extensions]
   23 | constexpr T my_pi = T(3.1415926535897932385L);
      |             ^
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace, preprocessed source, and associated run script.
Stack dump:
0.	Program arguments: clang++ -c -o /dev/null -Os -std=c++11 -fsanitize=address -fsanitize=undefined -Wextra /home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmps20ohq6x/c49590ee.cpp
1.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmps20ohq6x/c49590ee.cpp:28:39: current parser token 'my_const'
2.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmps20ohq6x/c49590ee.cpp:17:8: instantiating class definition 'Wrapper<float>'
 #0 0x00007fc3c0c015ea llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/lib/llvm-22/bin/../lib/libLLVM.so.22.1+0x4e9f5ea)
 #1 0x00007fc3c0bfedf7 llvm::sys::RunSignalHandlers() (/usr/lib/llvm-22/bin/../lib/libLLVM.so.22.1+0x4e9cdf7)
 #2 0x00007fc3c0b2fd04 (/usr/lib/llvm-22/bin/../lib/libLLVM.so.22.1+0x4dcdd04)
 #3 0x00007fc3bb7d3970 (/usr/lib/x86_64-linux-gnu/libc.so.6+0x40970)
 #4 0x00007fc3c66b6395 clang::Decl::getASTContext() const (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x1909395)
 #5 0x00007fc3c66f2d14 clang::VarTemplateDecl::findPartialSpecInstantiatedFromMember(clang::VarTemplatePartialSpecializationDecl*) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x1945d14)
 #6 0x00007fc3c756f9c2 clang::TemplateDeclInstantiator::VisitVarTemplatePartialSpecializationDecl(clang::VarTemplatePartialSpecializationDecl*) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x27c29c2)
 #7 0x00007fc3c74f8461 clang::Sema::InstantiateClassImpl(clang::SourceLocation, clang::CXXRecordDecl*, clang::CXXRecordDecl*, clang::MultiLevelTemplateArgumentList const&, clang::TemplateSpecializationKind, bool) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x274b461)
 #8 0x00007fc3c74fa55d clang::Sema::InstantiateClassTemplateSpecialization(clang::SourceLocation, clang::ClassTemplateSpecializationDecl*, clang::TemplateSpecializationKind, bool, bool) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x274d55d)
 #9 0x00007fc3c75d63e2 (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x28293e2)
#10 0x00007fc3c627da41 clang::StackExhaustionHandler::runWithSufficientStackSpace(clang::SourceLocation, llvm::function_ref<void ()>) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x14d0a41)
#11 0x00007fc3c75c5acd clang::Sema::RequireCompleteTypeImpl(clang::SourceLocation, clang::QualType, clang::Sema::CompleteTypeKind, clang::Sema::TypeDiagnoser*) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x2818acd)
#12 0x00007fc3c75c52a3 clang::Sema::RequireCompleteType(clang::SourceLocation, clang::QualType, clang::Sema::CompleteTypeKind, clang::Sema::TypeDiagnoser&) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x28182a3)
#13 0x00007fc3c6ea4259 clang::Sema::RequireCompleteDeclContext(clang::CXXScopeSpec&, clang::DeclContext*) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x20f7259)
#14 0x00007fc3c741a0b2 clang::Sema::LookupTemplateName(clang::LookupResult&, clang::Scope*, clang::CXXScopeSpec&, clang::QualType, bool, clang::Sema::RequiredTemplateKind, clang::Sema::AssumedTemplateKind*, bool) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x266d0b2)
#15 0x00007fc3c7419cc4 clang::Sema::isTemplateName(clang::Scope*, clang::CXXScopeSpec&, bool, clang::UnqualifiedId const&, clang::OpaquePtr<clang::QualType>, bool, clang::OpaquePtr<clang::TemplateName>&, bool&, bool) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x266ccc4)
#16 0x00007fc3c6434094 clang::Parser::ParseOptionalCXXScopeSpecifier(clang::CXXScopeSpec&, clang::OpaquePtr<clang::QualType>, bool, bool, bool*, bool, clang::IdentifierInfo const**, bool, bool, bool) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x1687094)
#17 0x00007fc3c6404aea clang::Parser::ParseDeclaratorInternal(clang::Declarator&, void (clang::Parser::*)(clang::Declarator&)) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x1657aea)
#18 0x00007fc3c627da41 clang::StackExhaustionHandler::runWithSufficientStackSpace(clang::SourceLocation, llvm::function_ref<void ()>) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x14d0a41)
#19 0x00007fc3c64055f4 clang::Parser::ParseDeclaratorInternal(clang::Declarator&, void (clang::Parser::*)(clang::Declarator&)) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x16585f4)
#20 0x00007fc3c627da41 clang::StackExhaustionHandler::runWithSufficientStackSpace(clang::SourceLocation, llvm::function_ref<void ()>) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x14d0a41)
#21 0x00007fc3c63f6446 clang::Parser::ParseDeclGroup(clang::ParsingDeclSpec&, clang::DeclaratorContext, clang::ParsedAttributes&, clang::Parser::ParsedTemplateInfo&, clang::SourceLocation*, clang::Parser::ForRangeInit*) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x1649446)
#22 0x00007fc3c64961d3 clang::Parser::ParseDeclarationAfterTemplate(clang::DeclaratorContext, clang::Parser::ParsedTemplateInfo&, clang::ParsingDeclRAIIObject&, clang::SourceLocation&, clang::ParsedAttributes&, clang::AccessSpecifier) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x16e91d3)
#23 0x00007fc3c64956a8 clang::Parser::ParseTemplateDeclarationOrSpecialization(clang::DeclaratorContext, clang::SourceLocation&, clang::ParsedAttributes&, clang::AccessSpecifier) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x16e86a8)
#24 0x00007fc3c6495055 clang::Parser::ParseDeclarationStartingWithTemplate(clang::DeclaratorContext, clang::SourceLocation&, clang::ParsedAttributes&) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x16e8055)
#25 0x00007fc3c63f5622 clang::Parser::ParseDeclaration(clang::DeclaratorContext, clang::SourceLocation&, clang::ParsedAttributes&, clang::ParsedAttributes&, clang::SourceLocation*) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x1648622)
#26 0x00007fc3c64a49b4 clang::Parser::ParseExternalDeclaration(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec*) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x16f79b4)
#27 0x00007fc3c64a38f7 clang::Parser::ParseTopLevelDecl(clang::OpaquePtr<clang::DeclGroupRef>&, clang::Sema::ModuleImportState&) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x16f68f7)
#28 0x00007fc3c63e267e clang::ParseAST(clang::Sema&, bool, bool) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x163567e)
#29 0x00007fc3c811cbef clang::FrontendAction::Execute() (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x336fbef)
#30 0x00007fc3c8090044 clang::CompilerInstance::ExecuteAction(clang::FrontendAction&) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x32e3044)
#31 0x00007fc3c81aaf9a clang::ExecuteCompilerInvocation(clang::CompilerInstance*) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x33fdf9a)
#32 0x000056049882ecdd cc1_main(llvm::ArrayRef<char const*>, char const*, void*) (/usr/lib/llvm-22/bin/clang+0x13cdd)
#33 0x000056049882b53b (/usr/lib/llvm-22/bin/clang+0x1053b)
#34 0x000056049882cfcc (/usr/lib/llvm-22/bin/clang+0x11fcc)
#35 0x00007fc3c7d44afd (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x2f97afd)
#36 0x00007fc3c0b2f9d0 llvm::CrashRecoveryContext::RunSafely(llvm::function_ref<void ()>) (/usr/lib/llvm-22/bin/../lib/libLLVM.so.22.1+0x4dcd9d0)
#37 0x00007fc3c7d445b1 clang::driver::CC1Command::Execute(llvm::ArrayRef<std::optional<llvm::StringRef>>, std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char>>*, bool*) const (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x2f975b1)
#38 0x00007fc3c7d03732 clang::driver::Compilation::ExecuteCommand(clang::driver::Command const&, clang::driver::Command const*&, bool) const (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x2f56732)
#39 0x00007fc3c7d038fe clang::driver::Compilation::ExecuteJobs(clang::driver::JobList const&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&, bool) const (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x2f568fe)
#40 0x00007fc3c7d251ff clang::driver::Driver::ExecuteCompilation(clang::driver::Compilation&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&) (/usr/lib/llvm-22/bin/../lib/libclang-cpp.so.22.1+0x2f781ff)
#41 0x000056049882b02d clang_main(int, char**, llvm::ToolContext const&) (/usr/lib/llvm-22/bin/clang+0x1002d)
#42 0x00005604988399aa main (/usr/lib/llvm-22/bin/clang+0x1e9aa)
#43 0x00007fc3bb7bcf77 (/usr/lib/x86_64-linux-gnu/libc.so.6+0x29f77)
#44 0x00007fc3bb7bd027 __libc_start_main (/usr/lib/x86_64-linux-gnu/libc.so.6+0x2a027)
#45 0x00005604988291d1 _start (/usr/lib/llvm-22/bin/clang+0xe1d1)
clang++: error: clang frontend command failed with exit code 139 (use -v to see invocation)
Debian clang version 22.1.8 (1+b1)
Target: x86_64-pc-linux-gnu
Thread model: posix
InstalledDir: /usr/lib/llvm-22/bin
clang++: note: diagnostic msg: 
********************

PLEASE ATTACH THE FOLLOWING FILES TO THE BUG REPORT:
Preprocessed source(s) and associated run script(s) are located at:
clang++: note: diagnostic msg: /tmp/c49590ee-61d998.cpp
clang++: note: diagnostic msg: /tmp/c49590ee-61d998.sh
clang++: note: diagnostic msg: 

********************
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ulimit -v 3145728; ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' clang++ -c -o /dev/null -Os -std=c++11 -fsanitize=address -fsanitize=undefined -Wextra "$SCRIPT_DIR/test.cpp"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `d5c26dd2` | Project seed |
| `b` | `73e77c9b` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
