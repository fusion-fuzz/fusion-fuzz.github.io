*Fusion-Fuzz Bug Report*

**ID:** `ba03a256` &nbsp;·&nbsp; **Signature:** `Assertion: (NewAttr == "error" || NewAttr == "warning") && "unexpected normalized full name"` &nbsp;·&nbsp; **RC:** `134`

The following code:

```cpp
__attribute__((always_inline))
void always_inline_wrapper() {
    always_inline_target();
}
void always_inline_caller() {
    __attribute__((always_inline))
void always_inline_wrapper() {
    always_inline_target();
}
    // RUN: %clang_cc1 -O2 -emit-obj -fdiagnostics-show-inlining-chain %s -o /dev/null 2>&1 | FileCheck %s --check-prefix=HEURISTIC
// RUN: %clang_cc1 -O2 -emit-obj -fdiagnostics-show-inlining-chain -debug-info-kind=line-directives-only %s -o /dev/null 2>&1 | FileCheck %s --check-prefix=DEBUG

// Verify auto-selection works between debug info and heuristic fallback. When
// we have at least -gline-directives-only we can use DILocation for accurate
// inline locations.

// Without that debug info we fall back to a heuristic approach using srcloc
// metadata.

[[gnu::warning("dangerous function")]]
void dangerous();
    always_inline_wrapper();
}
// RUN: %clang_cc1 -O2 -emit-obj -fdiagnostics-show-inlining-chain %s -o /dev/null 2>&1 | FileCheck %s --check-prefix=HEURISTIC
// RUN: %clang_cc1 -O2 -emit-obj -fdiagnostics-show-inlining-chain -debug-info-kind=line-directives-only %s -o /dev/null 2>&1 | FileCheck %s --check-prefix=DEBUG

// Verify auto-selection works between debug info and heuristic fallback. When
// we have at least -gline-directives-only we can use DILocation for accurate
// inline locations.

// Without that debug info we fall back to a heuristic approach using srcloc
// metadata.

[[gnu::warning("dangerous function")]]
void dangerous();
// RUN: %clang_cc1 -verify=ref,both -std=c++2a -fsyntax-only -triple x86_64-apple-macosx10.14.0 %s
// RUN: %clang_cc1 -verify=ref,both -std=c++2a -fsyntax-only -triple x86_64-apple-macosx10.14.0 %s -fno-signed-char
// RUN: %clang_cc1 -verify=ref,both -std=c++2a -fsyntax-only -triple aarch64_be-linux-gnu %s

// RUN: %clang_cc1 -verify=expected,both -std=c++2a -fsyntax-only -triple x86_64-apple-macosx10.14.0 %s -fexperimental-new-constant-interpreter
// RUN: %clang_cc1 -verify=expected,both -std=c++2a -fsyntax-only -triple x86_64-apple-macosx10.14.0 %s -fno-signed-char -fexperimental-new-constant-interpreter
// RUN: %clang_cc1 -verify=expected,both -std=c++2a -fsyntax-only -triple aarch64_be-linux-gnu %s -fexperimental-new-constant-interpreter

#if !__x86_64
// both-no-diagnostics
#endif


typedef decltype(nullptr) nullptr_t;
template <class To, class From>
constexpr To bit_cast(const From &from) {
  static_assert(sizeof(To) == sizeof(From));
  return __builtin_bit_cast(To, from);
#if __x86_64
  // both-note@-2 {{indeterminate value can only initialize an object of type}}
#endif
}
namespace {
void anon_helper() {
    bad_func();
}

void anon_middle() {
    anon_helper();
}
}
typedef __INTPTR_TYPE__ intptr_t;
static_assert(sizeof(int) == 4);
// HEURISTIC: :79:{{.*}}: warning: call to '{{.*}}always_inline_target{{.*}}'
// HEURISTIC: :79:{{.*}}: note: called by function '{{.*}}always_inline_wrapper{{.*}}'
// HEURISTIC: :83:{{.*}}: note: inlined by function '{{.*}}always_inline_caller{{.*}}'

// DEBUG: :79:{{.*}}: warning: call to '{{.*}}always_inline_target{{.*}}'
// DEBUG: :79:{{.*}}: note: called by function '{{.*}}always_inline_wrapper{{.*}}'
// DEBUG: :83:{{.*}}: note: inlined by function '{{.*}}always_inline_caller{{.*}}'
// Non-static, non-inline functions that get inlined at -O2.
void wrapper() {
    dangerous();
}
static_assert(sizeof(long long) == 8);
void middle() {
    wrapper();
}
// namespace

void public_caller() {
    anon_middle();
}
// HEURISTIC: :49:{{.*}}: warning: call to '{{.*}}bad_func{{.*}}'
// HEURISTIC: :49:{{.*}}: note: called by function '{{.*}}anon_helper{{.*}}'
// HEURISTIC: :53:{{.*}}: note: inlined by function '{{.*}}anon_middle{{.*}}'
// HEURISTIC: :58:{{.*}}: note: inlined by function '{{.*}}public_caller{{.*}}'

// DEBUG: :49:{{.*}}: warning: call to '{{.*}}bad_func{{.*}}'
// DEBUG: :49:{{.*}}: note: called by function '{{.*}}anon_helper{{.*}}'
// DEBUG: :53:{{.*}}: note: inlined by function '{{.*}}anon_middle{{.*}}'
// DEBUG: :58:{{.*}}: note: inlined by function '{{.*}}public_caller{{.*}}'

// always_inline forces inlining but doesn't imply
// isInlined() in the language sense.

[[from::warning("always inline warning")]]
void always_inline_target();
void caller() {
    middle();
}
// HEURISTIC: :16:{{.*}}: warning: call to '{{.*}}dangerous{{.*}}'
// HEURISTIC: :16:{{.*}}: note: called by function '{{.*}}wrapper{{.*}}'
// HEURISTIC: :16:{{.*}}: note: inlined by function '{{.*}}middle{{.*}}'
// HEURISTIC: :16:{{.*}}: note: inlined by function '{{.*}}caller{{.*}}'
// HEURISTIC: note: use '-gline-directives-only' (implied by '-g1') or higher for more accurate inlining chain locations

// DEBUG: :16:{{.*}}: warning: call to '{{.*}}dangerous{{.*}}'
// DEBUG: :16:{{.*}}: note: called by function '{{.*}}wrapper{{.*}}'
// DEBUG: :20:{{.*}}: note: inlined by function '{{.*}}middle{{.*}}'
// DEBUG: :24:{{.*}}: note: inlined by function '{{.*}}caller{{.*}}'
// DEBUG-NOT: note: use '-gline-directives-only'

// Test that functions in anonymous namespaces are properly tracked for
// inlining chain diagnostics. Anonymous namespace functions have internal
// linkage and are prime candidates for inlining.

[[gnu::warning("do not call")]]
void bad_func();
template <class Intermediate, class Init>
constexpr bool check_round_trip(const Init &init) {
  return bit_cast<Init>(bit_cast<Intermediate>(init)) == init;
}
template <class Intermediate, class Init>
constexpr Init round_trip(const Init &init) {
  return bit_cast<Init>(bit_cast<Intermediate>(init));
}
namespace test_long_double {
#if __x86_64
constexpr __int128_t test_cast_to_int128 = bit_cast<__int128_t>((long double)0); // both-error{{must be initialized by a constant expression}}\
                                                                                 // both-note{{in call}}
constexpr long double ld = 3.1425926539;

struct bytes {
  unsigned char d[16];
};

static_assert(round_trip<bytes>(ld), "");

static_assert(round_trip<long double>(10.0L));

constexpr long double foo() {
  bytes A = __builtin_bit_cast(bytes, ld);
  long double ld = __builtin_bit_cast(long double, A);
  return ld;
}
static_assert(foo() == ld);

constexpr bool f(bool read_uninit) {
  bytes b = bit_cast<bytes>(ld); // both-note {{declared here}}
  unsigned char ld_bytes[10] = {
    0x0,  0x48, 0x9f, 0x49, 0xf0,
    0x3c, 0x20, 0xc9, 0x0,  0x40,
  };

  for (int i = 0; i != 10; ++i)
    if (ld_bytes[i] != b.d[i])
      return false;

  if (read_uninit && b.d[10]) // both-note{{read of uninitialized object is not allowed in a constant expression}}
    return false;

  return true;
}

static_assert(f(/*read_uninit=*/false), "");
static_assert(f(/*read_uninit=*/true), ""); // both-error{{static assertion expression is not an integral constant expression}} \
                                            // both-note{{in call to 'f(true)'}}
constexpr bytes ld539 = {
  0x0, 0x0,  0x0,  0x0,
  0x0, 0x0,  0xc0, 0x86,
  0x8, 0x40, 0x0,  0x0,
  0x0, 0x0,  0x0,  0x0,
};
constexpr long double fivehundredandthirtynine = 539.0;
static_assert(bit_cast<long double>(ld539) == fivehundredandthirtynine, "");

struct LD {
  long double v;
};

constexpr LD ld2 = __builtin_bit_cast(LD, ld539.d);
constexpr long double five39 = __builtin_bit_cast(long double, ld539.d);
static_assert(ld2.v == five39);

#else
static_assert(round_trip<__int128_t>(34.0L));
#endif
}
```

Resulted in this output:

```
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpl2zm6fmt/ba03a256.cpp:3:5: error: use of undeclared identifier 'always_inline_target'; did you mean 'always_inline_wrapper'?
    3 |     always_inline_target();
      |     ^~~~~~~~~~~~~~~~~~~~
      |     always_inline_wrapper
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpl2zm6fmt/ba03a256.cpp:2:6: note: 'always_inline_wrapper' declared here
    2 | void always_inline_wrapper() {
      |      ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpl2zm6fmt/ba03a256.cpp:7:30: error: function definition is not allowed here
    7 | void always_inline_wrapper() {
      |                              ^
clang++: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-project/clang/lib/Sema/SemaDeclAttr.cpp:4059: clang::ErrorAttr* clang::Sema::mergeErrorAttr(clang::Decl*, const clang::AttributeCommonInfo&, llvm::StringRef): Assertion `(NewAttr == "error" || NewAttr == "warning") && "unexpected normalized full name"' failed.
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and dumped files.
Stack dump:
0.	Program arguments: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin/clang++ -fsyntax-only -O0 -std=c++20 -fno-elide-constructors -ffast-math -Wextra /home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpl2zm6fmt/ba03a256.cpp
1.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpl2zm6fmt/ba03a256.cpp:35:17: current parser token ';'
Stack dump without symbol names (ensure you have llvm-symbolizer in your PATH or set the environment var `LLVM_SYMBOLIZER_PATH` to point to it):
0  clang++   0x0000565224e3e0f9 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) + 121
1  clang++   0x0000565224e3adcc llvm::sys::RunSignalHandlers() + 76
2  clang++   0x0000565224e3b678 llvm::sys::CleanupOnSignal(unsigned long) + 216
3  clang++   0x0000565224d7df88
4  libc.so.6 0x00007f02219a9520
5  libc.so.6 0x00007f02219fd9fc pthread_kill + 300
6  libc.so.6 0x00007f02219a9476 raise + 22
7  libc.so.6 0x00007f022198f7f3 abort + 211
8  libc.so.6 0x00007f022198f71b
9  libc.so.6 0x00007f02219a0e96
10 clang++   0x0000565227a09e52 clang::Sema::mergeErrorAttr(clang::Decl*, clang::AttributeCommonInfo const&, llvm::StringRef) + 306
11 clang++   0x000056522799968c
12 clang++   0x000056522799abd6 clang::Sema::mergeDeclAttributes(clang::NamedDecl*, clang::Decl*, clang::AvailabilityMergeKind) + 3942
13 clang++   0x000056522799bf2f clang::Sema::MergeCompatibleFunctionDecls(clang::FunctionDecl*, clang::FunctionDecl*, clang::Scope*, bool) + 47
14 clang++   0x00005652279ccc17 clang::Sema::MergeFunctionDecl(clang::FunctionDecl*, clang::NamedDecl*&, clang::Scope*, bool, bool) + 9191
15 clang++   0x00005652279d99b1 clang::Sema::CheckFunctionDeclaration(clang::Scope*, clang::FunctionDecl*, clang::LookupResult&, bool, bool) + 1265
16 clang++   0x00005652279e0247 clang::Sema::ActOnFunctionDeclarator(clang::Scope*, clang::Declarator&, clang::DeclContext*, clang::TypeSourceInfo*, clang::LookupResult&, llvm::MutableArrayRef<clang::TemplateParameterList*>, bool&) + 12583
17 clang++   0x00005652279e49bb clang::Sema::HandleDeclarator(clang::Scope*, clang::Declarator&, llvm::MutableArrayRef<clang::TemplateParameterList*>) + 1387
18 clang++   0x00005652279e589b clang::Sema::ActOnDeclarator(clang::Scope*, clang::Declarator&) + 123
19 clang++   0x0000565227606c8b clang::Parser::ParseDeclarationAfterDeclaratorAndAttributes(clang::Declarator&, clang::Parser::ParsedTemplateInfo const&, clang::Parser::ForRangeInit*) + 235
20 clang++   0x00005652276215bc clang::Parser::ParseDeclGroup(clang::ParsingDeclSpec&, clang::DeclaratorContext, clang::ParsedAttributes&, clang::Parser::ParsedTemplateInfo&, clang::SourceLocation*, clang::Parser::ForRangeInit*) + 2844
21 clang++   0x00005652275d115c clang::Parser::ParseDeclOrFunctionDefInternal(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec&, clang::AccessSpecifier) + 924
22 clang++   0x00005652275d192f clang::Parser::ParseDeclarationOrFunctionDefinition(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec*, clang::AccessSpecifier) + 959
23 clang++   0x00005652275dd7a1 clang::Parser::ParseExternalDeclaration(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec*) + 977
24 clang++   0x00005652275de7df clang::Parser::ParseTopLevelDecl(clang::OpaquePtr<clang::DeclGroupRef>&, clang::Sema::ModuleImportState&) + 575
25 clang++   0x00005652275bb70a clang::ParseAST(clang::Sema&, bool, bool) + 586
26 clang++   0x0000565225b34071 clang::FrontendAction::Execute() + 65
27 clang++   0x0000565225abdc65 clang::CompilerInstance::ExecuteAction(clang::FrontendAction&) + 1589
28 clang++   0x0000565225c0fea3 clang::ExecuteCompilerInvocation(clang::CompilerInstance*) + 467
29 clang++   0x0000565223812c96 cc1_main(llvm::ArrayRef<char const*>, char const*, void*) + 7046
30 clang++   0x0000565223808a2a
31 clang++   0x0000565223808bbf
32 clang++   0x000056522584535d
33 clang++   0x0000565224d7e3a0 llvm::CrashRecoveryContext::RunSafely(llvm::function_ref<void ()>) + 160
34 clang++   0x00005652258461b3
35 clang++   0x00005652257fb987 clang::driver::Compilation::ExecuteCommand(clang::driver::Command const&, clang::driver::Command const*&, bool) const + 167
36 clang++   0x00005652258001e0 clang::driver::Compilation::ExecuteJobs(clang::driver::JobList const&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&, bool) const + 304
37 clang++   0x000056522580de44 clang::driver::Driver::ExecuteCompilation(clang::driver::Compilation&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&) + 404
38 clang++   0x000056522380e2d3 clang_main(int, char**, llvm::ToolContext const&) + 7267
39 clang++   0x00005652237607a1 main + 113
40 libc.so.6 0x00007f0221990d90
41 libc.so.6 0x00007f0221990e40 __libc_start_main + 128
42 clang++   0x0000565223808055 _start + 37
clang++: error: clang frontend command failed due to signal (use -v to see invocation)
clang version 24.0.0git (https://github.com/llvm/llvm-project.git aefba88f46a6e55645c848f58f6ba56944d5ae62)
Target: x86_64-unknown-linux-gnu
Thread model: posix
InstalledDir: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin
Build config: +assertions
clang++: note: diagnostic msg: 
********************

PLEASE ATTACH THE FOLLOWING CRASH REPRODUCER FILES TO THE BUG REPORT:
clang++: note: diagnostic msg: /tmp/ba03a256-892992.cpp
clang++: note: diagnostic msg: /tmp/ba03a256-892992.sh
clang++: note: diagnostic msg: 

********************
Aborted (core dumped)
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ulimit -v 3145728; ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin/clang++ -fsyntax-only -O0 -std=c++20 -fno-elide-constructors -ffast-math -Wextra "$SCRIPT_DIR/test.cpp"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `6bda08bc` | Project seed |
| `b` | `69bc11c3` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
