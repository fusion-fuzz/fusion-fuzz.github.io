*Fusion-Fuzz Bug Report*

**ID:** `3dffa9b2` &nbsp;·&nbsp; **Signature:** `Stack dump: Fortran::semantics::Symbol::SetType > Fortran::semantics::ResolveNamesVisitor::EarlyDummyTypeDeclaration > Fortran::semantics::ResolveNamesVisitor::Pre` &nbsp;·&nbsp; **RC:** `254`

The following code:

```f90
subroutine s(a,n)
! RUN: %python %S/test_errors.py %s %flang_fc1
  real a(n)
!RUN: %flang_fc1 -fdebug-unparse %s 2>&1 | FileCheck %s
!CHECK: INTEGER(KIND=8_4) n
  integer(N()) n
end
SUBROUTINE sub00(a,b,n,m)
  complex(2) n,m
! ERROR: Must have INTEGER type, but is COMPLEX(2)
! ERROR: Must have INTEGER type, but is COMPLEX(2)
! ERROR: The type of 'b' has already been implicitly declared as REAL(4)
  complex(3) a(n,m), b(size((LOG ((x * (a) - a + b / a - a))+1 - x)))
  a = a ** n
! ERROR: DO controls should be INTEGER
DO 10 j = 1,m
    a = n ** a
    10   PRINT *, g
END SUBROUTINE sub00
```

Resulted in this output:

```

fatal internal error: CHECK(!type_) failed at flang/lib/Semantics/symbol.cpp(224)
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and instructions to reproduce the bug.
Stack dump:
0.	Program arguments: /usr/lib/llvm-22/bin/flang -fc1 -triple x86_64-pc-linux-gnu -fsyntax-only -ffree-form -mrelocation-model pic -pic-level 2 -pic-is-pie -target-cpu x86-64 -resource-dir /usr/lib/llvm-22/lib/clang/22 -mframe-pointer=all -O0 -x f95 /home/fuzz/WorkSpace/fusion-fuzz/.fused/flang/tmpn6n0adsj/3dffa9b2.f90
 #0 0x00007fa658e7dd5f llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/lib/llvm-22/lib/libLLVM.so.22.1+0x4dc7d5f)
 #1 0x00007fa658e7b5d7 llvm::sys::RunSignalHandlers() (/usr/lib/llvm-22/lib/libLLVM.so.22.1+0x4dc55d7)
 #2 0x00007fa658e7eb2a (/usr/lib/llvm-22/lib/libLLVM.so.22.1+0x4dc8b2a)
 #3 0x00007fa653b52330 (/lib/x86_64-linux-gnu/libc.so.6+0x45330)
 #4 0x00007fa653babb2c pthread_kill (/lib/x86_64-linux-gnu/libc.so.6+0x9eb2c)
 #5 0x00007fa653b5227e raise (/lib/x86_64-linux-gnu/libc.so.6+0x4527e)
 #6 0x00007fa653b358ff abort (/lib/x86_64-linux-gnu/libc.so.6+0x288ff)
 #7 0x0000563fad66261c (/usr/lib/llvm-22/bin/flang+0x2b2061c)
 #8 0x0000563fac6f62fa Fortran::semantics::Symbol::SetType(Fortran::semantics::DeclTypeSpec const&) (/usr/lib/llvm-22/bin/flang+0x1bb42fa)
 #9 0x0000563fabecb818 Fortran::semantics::ResolveNamesVisitor::EarlyDummyTypeDeclaration(Fortran::parser::Statement<Fortran::common::Indirection<Fortran::parser::TypeDeclarationStmt, false>> const&) (/usr/lib/llvm-22/bin/flang+0x1389818)
#10 0x0000563fabeca2db Fortran::semantics::ResolveNamesVisitor::Pre(Fortran::parser::SpecificationPart const&) (/usr/lib/llvm-22/bin/flang+0x13882db)
#11 0x0000563fabecdb14 Fortran::semantics::ResolveNamesVisitor::ResolveSpecificationParts(Fortran::semantics::ProgramTree&) (/usr/lib/llvm-22/bin/flang+0x138bb14)
#12 0x0000563fabecd989 Fortran::semantics::ResolveNamesVisitor::Pre(Fortran::parser::ProgramUnit const&) (/usr/lib/llvm-22/bin/flang+0x138b989)
#13 0x0000563fabf1cdd8 (/usr/lib/llvm-22/bin/flang+0x13dadd8)
#14 0x0000563fabecfb33 Fortran::semantics::ResolveNames(Fortran::semantics::SemanticsContext&, Fortran::parser::Program const&, Fortran::semantics::Scope&) (/usr/lib/llvm-22/bin/flang+0x138db33)
#15 0x0000563fabfbd00f Fortran::semantics::Semantics::Perform() (/usr/lib/llvm-22/bin/flang+0x147b00f)
#16 0x0000563fab70c91e Fortran::frontend::FrontendAction::runSemanticChecks() (/usr/lib/llvm-22/bin/flang+0xbca91e)
#17 0x0000563fab7110cc Fortran::frontend::PrescanAndSemaAction::beginSourceFileAction() (/usr/lib/llvm-22/bin/flang+0xbcf0cc)
#18 0x0000563fab70bf9e Fortran::frontend::FrontendAction::beginSourceFile(Fortran::frontend::CompilerInstance&, Fortran::frontend::FrontendInputFile const&) (/usr/lib/llvm-22/bin/flang+0xbc9f9e)
#19 0x0000563fab6f3e7f Fortran::frontend::CompilerInstance::executeAction(Fortran::frontend::FrontendAction&) (/usr/lib/llvm-22/bin/flang+0xbb1e7f)
#20 0x0000563fab710ba0 Fortran::frontend::executeCompilerInvocation(Fortran::frontend::CompilerInstance*) (/usr/lib/llvm-22/bin/flang+0xbceba0)
#21 0x0000563fab6f1d34 fc1_main(llvm::ArrayRef<char const*>, char const*) (/usr/lib/llvm-22/bin/flang+0xbafd34)
#22 0x0000563fab6f0fa4 main (/usr/lib/llvm-22/bin/flang+0xbaefa4)
#23 0x00007fa653b371ca (/lib/x86_64-linux-gnu/libc.so.6+0x2a1ca)
#24 0x00007fa653b3728b __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28b)
#25 0x0000563fab6eff45 _start (/usr/lib/llvm-22/bin/flang+0xbadf45)
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
flang-22: note: diagnostic msg: /tmp/3dffa9b2-faf0bc
flang-22: note: diagnostic msg: /tmp/3dffa9b2-faf0bc.sh
flang-22: note: diagnostic msg: 

********************
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ulimit -v 3145728; ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' flang -fsyntax-only -O0 -ffree-form "$SCRIPT_DIR/test.f90"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `9fa3f731` | Project seed |
| `b` | `6a09e164` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
