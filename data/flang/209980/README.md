*Fusion-Fuzz Bug Report*

**ID:** `a93530bf` &nbsp;·&nbsp; **Signature:** `Stack dump: Fortran::semantics::DeclarationVisitor::PointerInitialization > Fortran::semantics::ResolveNamesVisitor::FinishSpecificationParts > Fortran::semantics::ResolveNamesVisitor::Pre` &nbsp;·&nbsp; **RC:** `254`

The following code:

```f90
end program
subroutine foo
! RUN: not %flang_fc1 -triple x86_64-apple-macos10.13 -flto -ffat-lto-objects -emit-llvm-bc %s 2>&1 | FileCheck %s --check-prefix=ERROR
! ERROR: error: unsupported option '-ffat-lto-objects' for target 'x86_64-apple-macos10.13'

parameter(i=1)
integer :: j
! RUN: %flang_fc1 -fsyntax-only -fno-automatic %s 2>&1 | FileCheck %s --allow-empty
! Checks that -fno-automatic implies the SAVE attribute.
! This same subroutine appears in test save01.f90 where it is an
! error case due to the absence of both SAVE and -fno-automatic.
  integer, target :: t
  !CHECK-NOT: error:
  integer, pointer :: I => t
end
```

Resulted in this output:

```

fatal internal error: CHECK(!details->init()) failed at flang/lib/Semantics/resolve-names.cpp(9155)
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and instructions to reproduce the bug.
Stack dump:
0.	Program arguments: /usr/lib/llvm-22/bin/flang -fc1 -triple x86_64-pc-linux-gnu -S -ffree-form -mrelocation-model pic -pic-level 2 -pic-is-pie -target-cpu x86-64 -std=f2018 -resource-dir /usr/lib/llvm-22/lib/clang/22 -mframe-pointer=none -O1 -o /dev/null -x f95 /home/fuzz/WorkSpace/fusion-fuzz/.fused/flang/tmp6h525cy3/a93530bf.f90
 #0 0x00007f1f86b80d5f llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/lib/llvm-22/lib/libLLVM.so.22.1+0x4dc7d5f)
 #1 0x00007f1f86b7e5d7 llvm::sys::RunSignalHandlers() (/usr/lib/llvm-22/lib/libLLVM.so.22.1+0x4dc55d7)
 #2 0x00007f1f86b81b2a (/usr/lib/llvm-22/lib/libLLVM.so.22.1+0x4dc8b2a)
 #3 0x00007f1f81855330 (/lib/x86_64-linux-gnu/libc.so.6+0x45330)
 #4 0x00007f1f818aeb2c pthread_kill (/lib/x86_64-linux-gnu/libc.so.6+0x9eb2c)
 #5 0x00007f1f8185527e raise (/lib/x86_64-linux-gnu/libc.so.6+0x4527e)
 #6 0x00007f1f818388ff abort (/lib/x86_64-linux-gnu/libc.so.6+0x288ff)
 #7 0x000055fbb783861c (/usr/lib/llvm-22/bin/flang+0x2b2061c)
 #8 0x000055fbb609d85b Fortran::semantics::DeclarationVisitor::PointerInitialization(Fortran::parser::Name const&, Fortran::common::Indirection<Fortran::parser::Designator, false> const&) (/usr/lib/llvm-22/bin/flang+0x138585b)
 #9 0x000055fbb60f1563 (/usr/lib/llvm-22/bin/flang+0x13d9563)
#10 0x000055fbb60f1037 (/usr/lib/llvm-22/bin/flang+0x13d9037)
#11 0x000055fbb60e78f7 (/usr/lib/llvm-22/bin/flang+0x13cf8f7)
#12 0x000055fbb60a4121 Fortran::semantics::ResolveNamesVisitor::FinishSpecificationParts(Fortran::semantics::ProgramTree const&) (/usr/lib/llvm-22/bin/flang+0x138c121)
#13 0x000055fbb60a3994 Fortran::semantics::ResolveNamesVisitor::Pre(Fortran::parser::ProgramUnit const&) (/usr/lib/llvm-22/bin/flang+0x138b994)
#14 0x000055fbb60f2dd8 (/usr/lib/llvm-22/bin/flang+0x13dadd8)
#15 0x000055fbb60a5b33 Fortran::semantics::ResolveNames(Fortran::semantics::SemanticsContext&, Fortran::parser::Program const&, Fortran::semantics::Scope&) (/usr/lib/llvm-22/bin/flang+0x138db33)
#16 0x000055fbb619300f Fortran::semantics::Semantics::Perform() (/usr/lib/llvm-22/bin/flang+0x147b00f)
#17 0x000055fbb58e291e Fortran::frontend::FrontendAction::runSemanticChecks() (/usr/lib/llvm-22/bin/flang+0xbca91e)
#18 0x000055fbb58e77da Fortran::frontend::CodeGenAction::beginSourceFileAction() (/usr/lib/llvm-22/bin/flang+0xbcf7da)
#19 0x000055fbb58e1f9e Fortran::frontend::FrontendAction::beginSourceFile(Fortran::frontend::CompilerInstance&, Fortran::frontend::FrontendInputFile const&) (/usr/lib/llvm-22/bin/flang+0xbc9f9e)
#20 0x000055fbb58c9e7f Fortran::frontend::CompilerInstance::executeAction(Fortran::frontend::FrontendAction&) (/usr/lib/llvm-22/bin/flang+0xbb1e7f)
#21 0x000055fbb58e6ba0 Fortran::frontend::executeCompilerInvocation(Fortran::frontend::CompilerInstance*) (/usr/lib/llvm-22/bin/flang+0xbceba0)
#22 0x000055fbb58c7d34 fc1_main(llvm::ArrayRef<char const*>, char const*) (/usr/lib/llvm-22/bin/flang+0xbafd34)
#23 0x000055fbb58c6fa4 main (/usr/lib/llvm-22/bin/flang+0xbaefa4)
#24 0x00007f1f8183a1ca (/lib/x86_64-linux-gnu/libc.so.6+0x2a1ca)
#25 0x00007f1f8183a28b __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28b)
#26 0x000055fbb58c5f45 _start (/usr/lib/llvm-22/bin/flang+0xbadf45)
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
flang-22: note: diagnostic msg: /tmp/a93530bf-baba83
flang-22: note: diagnostic msg: /tmp/a93530bf-baba83.sh
flang-22: note: diagnostic msg: 

********************
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ulimit -v 3145728; ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' flang -S -o /dev/null -O1 -ffree-form -std=f2018 "$SCRIPT_DIR/test.f90"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `b874e4c0` | Project seed |
| `b` | `1b9fb0a3` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
