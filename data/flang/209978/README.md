*Fusion-Fuzz Bug Report*

**ID:** `5a95cf6e` &nbsp;·&nbsp; **Signature:** `Stack dump: Fortran::evaluate::IntrinsicInterface::Match > Fortran::evaluate::IntrinsicProcTable::Implementation::Probe > Fortran::evaluate::IntrinsicProcTable::Probe` &nbsp;·&nbsp; **RC:** `254`

The following code:

```f90
end
!RUN: %flang -c %s -### 2>&1
function s(x) result(i)
!CHECK-WARNING: Function result is never defined
integer::x
procedure():: i
end function
!RUN: %flang_fc1 -fdebug-unparse %s 2>&1 | FileCheck %s
subroutine sub(dd)
  type(*)::dd(..)
  !CHECK: PRINT *, size(lbound(dd))
  print *, size(S(dd)) ! do not fold
end
```

Resulted in this output:

```

fatal internal error: CHECK(IsProcedure(expr) || IsProcedurePointer(expr)) failed at flang/lib/Evaluate/intrinsics.cpp(2116)
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and instructions to reproduce the bug.
Stack dump:
0.	Program arguments: /usr/lib/llvm-22/bin/flang -fc1 -triple x86_64-pc-linux-gnu -fsyntax-only -ffree-form -fbackslash -mrelocation-model pic -pic-level 2 -pic-is-pie -target-cpu x86-64 -finit-global-zero -resource-dir /usr/lib/llvm-22/lib/clang/22 -mframe-pointer=all -O0 -x f95 /home/fuzz/WorkSpace/fusion-fuzz/.fused/flang/tmp76_weakx/5a95cf6e.f90
 #0 0x00007f68a57d1d5f llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/lib/llvm-22/lib/libLLVM.so.22.1+0x4dc7d5f)
 #1 0x00007f68a57cf5d7 llvm::sys::RunSignalHandlers() (/usr/lib/llvm-22/lib/libLLVM.so.22.1+0x4dc55d7)
 #2 0x00007f68a57d2b2a (/usr/lib/llvm-22/lib/libLLVM.so.22.1+0x4dc8b2a)
 #3 0x00007f68a04a6330 (/lib/x86_64-linux-gnu/libc.so.6+0x45330)
 #4 0x00007f68a04ffb2c pthread_kill (/lib/x86_64-linux-gnu/libc.so.6+0x9eb2c)
 #5 0x00007f68a04a627e raise (/lib/x86_64-linux-gnu/libc.so.6+0x4527e)
 #6 0x00007f68a04898ff abort (/lib/x86_64-linux-gnu/libc.so.6+0x288ff)
 #7 0x000055c6f63dc61c (/usr/lib/llvm-22/bin/flang+0x2b2061c)
 #8 0x000055c6f5e5b0b6 Fortran::evaluate::IntrinsicInterface::Match(Fortran::evaluate::CallCharacteristics const&, Fortran::common::IntrinsicTypeDefaultKinds const&, std::vector<std::optional<Fortran::evaluate::ActualArgument>, std::allocator<std::optional<Fortran::evaluate::ActualArgument>>>&, Fortran::evaluate::FoldingContext&, Fortran::semantics::Scope const*) const (/usr/lib/llvm-22/bin/flang+0x259f0b6)
 #9 0x000055c6f5e6162c (/usr/lib/llvm-22/bin/flang+0x25a562c)
#10 0x000055c6f5e60912 Fortran::evaluate::IntrinsicProcTable::Implementation::Probe(Fortran::evaluate::CallCharacteristics const&, std::vector<std::optional<Fortran::evaluate::ActualArgument>, std::allocator<std::optional<Fortran::evaluate::ActualArgument>>>&, Fortran::evaluate::FoldingContext&) const (/usr/lib/llvm-22/bin/flang+0x25a4912)
#11 0x000055c6f5e626ea Fortran::evaluate::IntrinsicProcTable::Probe(Fortran::evaluate::CallCharacteristics const&, std::vector<std::optional<Fortran::evaluate::ActualArgument>, std::allocator<std::optional<Fortran::evaluate::ActualArgument>>>&, Fortran::evaluate::FoldingContext&) const (/usr/lib/llvm-22/bin/flang+0x25a66ea)
#12 0x000055c6f4aed0db Fortran::evaluate::ExpressionAnalyzer::ResolveGeneric(Fortran::semantics::Symbol const&, std::vector<std::optional<Fortran::evaluate::ActualArgument>, std::allocator<std::optional<Fortran::evaluate::ActualArgument>>> const&, std::optional<std::function<bool (Fortran::semantics::Symbol const&, std::vector<std::optional<Fortran::evaluate::ActualArgument>, std::allocator<std::optional<Fortran::evaluate::ActualArgument>>>&)>> const&, bool, std::vector<Fortran::common::Reference<Fortran::semantics::Symbol const>, std::allocator<Fortran::common::Reference<Fortran::semantics::Symbol const>>>&&, bool) (/usr/lib/llvm-22/bin/flang+0x12310db)
#13 0x000055c6f4aef3e2 Fortran::evaluate::ExpressionAnalyzer::GetCalleeAndArguments(Fortran::parser::Name const&, std::vector<std::optional<Fortran::evaluate::ActualArgument>, std::allocator<std::optional<Fortran::evaluate::ActualArgument>>>&&, bool, bool) (/usr/lib/llvm-22/bin/flang+0x12333e2)
#14 0x000055c6f4af093f Fortran::evaluate::ExpressionAnalyzer::Analyze(Fortran::parser::FunctionReference const&, std::optional<Fortran::parser::StructureConstructor>*) (/usr/lib/llvm-22/bin/flang+0x123493f)
#15 0x000055c6f4afa388 std::optional<Fortran::evaluate::Expr<Fortran::evaluate::SomeType>> Fortran::evaluate::ExpressionAnalyzer::ExprOrVariable<Fortran::parser::Expr>(Fortran::parser::Expr const&, Fortran::parser::CharBlock) (/usr/lib/llvm-22/bin/flang+0x123e388)
#16 0x000055c6f4af9db5 Fortran::evaluate::ExpressionAnalyzer::IterativelyAnalyzeSubexpressions(Fortran::parser::Expr const&) (/usr/lib/llvm-22/bin/flang+0x123ddb5)
#17 0x000055c6f4adff93 Fortran::evaluate::ExpressionAnalyzer::Analyze(Fortran::parser::Expr const&) (/usr/lib/llvm-22/bin/flang+0x1223f93)
#18 0x000055c6f4b067c9 (/usr/lib/llvm-22/bin/flang+0x124a7c9)
#19 0x000055c6f4b15428 (/usr/lib/llvm-22/bin/flang+0x1259428)
#20 0x000055c6f4b09426 (/usr/lib/llvm-22/bin/flang+0x124d426)
#21 0x000055c6f4b05c7e (/usr/lib/llvm-22/bin/flang+0x1249c7e)
#22 0x000055c6f4b61a75 (/usr/lib/llvm-22/bin/flang+0x12a5a75)
#23 0x000055c6f4b033b7 Fortran::semantics::ExprChecker::Walk(Fortran::parser::Program const&) (/usr/lib/llvm-22/bin/flang+0x12473b7)
#24 0x000055c6f4d37051 Fortran::semantics::Semantics::Perform() (/usr/lib/llvm-22/bin/flang+0x147b051)
#25 0x000055c6f448691e Fortran::frontend::FrontendAction::runSemanticChecks() (/usr/lib/llvm-22/bin/flang+0xbca91e)
#26 0x000055c6f448b0cc Fortran::frontend::PrescanAndSemaAction::beginSourceFileAction() (/usr/lib/llvm-22/bin/flang+0xbcf0cc)
#27 0x000055c6f4485f9e Fortran::frontend::FrontendAction::beginSourceFile(Fortran::frontend::CompilerInstance&, Fortran::frontend::FrontendInputFile const&) (/usr/lib/llvm-22/bin/flang+0xbc9f9e)
#28 0x000055c6f446de7f Fortran::frontend::CompilerInstance::executeAction(Fortran::frontend::FrontendAction&) (/usr/lib/llvm-22/bin/flang+0xbb1e7f)
#29 0x000055c6f448aba0 Fortran::frontend::executeCompilerInvocation(Fortran::frontend::CompilerInstance*) (/usr/lib/llvm-22/bin/flang+0xbceba0)
#30 0x000055c6f446bd34 fc1_main(llvm::ArrayRef<char const*>, char const*) (/usr/lib/llvm-22/bin/flang+0xbafd34)
#31 0x000055c6f446afa4 main (/usr/lib/llvm-22/bin/flang+0xbaefa4)
#32 0x00007f68a048b1ca (/lib/x86_64-linux-gnu/libc.so.6+0x2a1ca)
#33 0x00007f68a048b28b __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28b)
#34 0x000055c6f4469f45 _start (/usr/lib/llvm-22/bin/flang+0xbadf45)
flang-22: error: unable to execute command: Aborted (core dumped)
flang-22: error: flang frontend command failed due to signal (use -v to see invocation)
Ubuntu flang version 22.1.8 (++20260613092238+e80beda6e255-1~exp1~20260613092253.78)
Target: x86_64-pc-linux-gnu
Thread model: posix
InstalledDir: /usr/lib/llvm-22/bin
flang-22: note: diagnostic msg: 
********************

PLEASE ATTACH THE FOLLOWING FILES TO THE BUG REPORT:
Preprocessed source(s) and associated run script(s) are located at:
flang-22: note: diagnostic msg: /tmp/5a95cf6e-7d52a6
flang-22: note: diagnostic msg: /tmp/5a95cf6e-7d52a6.sh
flang-22: note: diagnostic msg: 

********************
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ulimit -v 3145728; ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' flang -fsyntax-only -O0 -ffree-form -finit-global-zero -fbackslash "$SCRIPT_DIR/test.f90"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `3af975ff` | Project seed |
| `b` | `1bccc984` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
