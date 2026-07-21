*Fusion-Fuzz Bug Report*

**ID:** `52ab13ea` &nbsp;·&nbsp; **Signature:** `Stack dump: Fortran::semantics::ScopeHandler::SayDerivedType > Fortran::semantics::InterfaceVisitor::CheckGenericProcedures > Fortran::semantics::ResolveNamesVisitor::FinishSpecificationPart` &nbsp;·&nbsp; **RC:** `254`

The following code:

```f90
module m1
type pair
  end type
interface pair
! RUN: not %flang_fc1 %s 2>%t.stderr
! RUN: FileCheck %s --input-file=%t.stderr --check-prefixes=PORTABILITY,ERROR,WARNING%if system-aix %{,AIX_WARNING%}
! C716 If both kind-param and exponent-letter appear, exponent-letter
! shall be E. (As an extension we also allow an exponent-letter which matches
! the kind-param)
! C717 The value of kind-param shall specify an approximation method that
! exists on the processor.
subroutine s(var)
  real :: realvar1 = 4.0E6_4
  real :: realvar2 = 4.0D6
  real :: realvar3 = 4.0Q6
  !PORTABILITY: Explicit kind parameter together with non-'E' exponent letter is not standard
  real :: realvar4 = 4.0D6_8
  !WARNING: Explicit kind parameter on real constant disagrees with exponent letter 'q'
  !AIX_WARNING: underflow on REAL(10) to REAL(4) conversion
  real :: realvar5 = 4.0Q6_10
  !PORTABILITY: Explicit kind parameter together with non-'E' exponent letter is not standard
  real :: realvar6 = 4.0Q6_16
  real :: realvar7 = 4.0E6_8
  !AIX_WARNING: underflow on REAL(10) to REAL(4) conversion
  real :: realvar8 = 4.0E6_10
  real :: realvar9 = 4.0E6_16
  !ERROR: Unsupported REAL(KIND=32)
  real :: realvar10 = 4.0E6_32
  double precision :: doublevar1 = 4.0E6_4
  double precision :: doublevar2 = 4.0D6
  double precision :: doublevar3 = 4.0Q6
  !PORTABILITY: Explicit kind parameter together with non-'E' exponent letter is not standard
  double precision :: doublevar4 = 4.0D6_8
  !PORTABILITY: Explicit kind parameter together with non-'E' exponent letter is not standard
  double precision :: doublevar5 = 4.0Q6_16
  double precision :: doublevar6 = 4.0E6_8
  !AIX_WARNING: underflow on REAL(10) to REAL(8) conversion
  double precision :: doublevar7 = 4.0E6_10
  double precision :: doublevar8 = 4.0E6_16
  !ERROR: Unsupported REAL(KIND=32)
  double precision :: doublevar9 = 4.0E6_32
end subroutine s
!RUN: %python %S/test_errors.py %s %flang_fc1
    module procedure f
end interface
 contains
  type(pair) function f(n)
    integer, intent(in) :: n
    f = pair()
  end
end
module m2
type pair
  end type
end
module REALVAR7
type pair
  end type
end
program main
  use m1
  use m2
  use m3
  !ERROR: Reference to 'pair' is ambiguous
  type(pair) error
end
```

Resulted in this output:

```
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and instructions to reproduce the bug.
Stack dump:
0.	Program arguments: /usr/lib/llvm-22/bin/flang -fc1 -triple x86_64-pc-linux-gnu -S -ffree-form -mrelocation-model pic -pic-level 2 -pic-is-pie -complex-range=basic -fcomplex-arithmetic=basic -ffast-math -target-cpu x86-64 -vectorize-loops -vectorize-slp -std=f2018 -resource-dir /usr/lib/llvm-22/lib/clang/22 -mframe-pointer=none -O2 -o /dev/null -x f95 /home/fuzz/WorkSpace/fusion-fuzz/.fused/flang/tmpruzfv489/52ab13ea.f90
 #0 0x00007f0c8d9a1d5f llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/lib/llvm-22/lib/libLLVM.so.22.1+0x4dc7d5f)
 #1 0x00007f0c8d99f5d7 llvm::sys::RunSignalHandlers() (/usr/lib/llvm-22/lib/libLLVM.so.22.1+0x4dc55d7)
 #2 0x00007f0c8d9a2b2a (/usr/lib/llvm-22/lib/libLLVM.so.22.1+0x4dc8b2a)
 #3 0x00007f0c88676330 (/lib/x86_64-linux-gnu/libc.so.6+0x45330)
 #4 0x0000562d88e99649 Fortran::semantics::ScopeHandler::SayDerivedType(Fortran::parser::CharBlock const&, Fortran::parser::MessageFixedText&&, Fortran::semantics::Scope const&) (/usr/lib/llvm-22/bin/flang+0x135e649)
 #5 0x0000562d88ea2458 Fortran::semantics::InterfaceVisitor::CheckGenericProcedures(Fortran::semantics::Symbol&) (/usr/lib/llvm-22/bin/flang+0x1367458)
 #6 0x0000562d88ec4347 Fortran::semantics::ResolveNamesVisitor::FinishSpecificationPart(std::__cxx11::list<Fortran::parser::DeclarationConstruct, std::allocator<Fortran::parser::DeclarationConstruct>> const&) (/usr/lib/llvm-22/bin/flang+0x1389347)
 #7 0x0000562d88ec3332 Fortran::semantics::ResolveNamesVisitor::Pre(Fortran::parser::SpecificationPart const&) (/usr/lib/llvm-22/bin/flang+0x1388332)
 #8 0x0000562d88ec6b14 Fortran::semantics::ResolveNamesVisitor::ResolveSpecificationParts(Fortran::semantics::ProgramTree&) (/usr/lib/llvm-22/bin/flang+0x138bb14)
 #9 0x0000562d88ec6989 Fortran::semantics::ResolveNamesVisitor::Pre(Fortran::parser::ProgramUnit const&) (/usr/lib/llvm-22/bin/flang+0x138b989)
#10 0x0000562d88f15dd8 (/usr/lib/llvm-22/bin/flang+0x13dadd8)
#11 0x0000562d88ec8b33 Fortran::semantics::ResolveNames(Fortran::semantics::SemanticsContext&, Fortran::parser::Program const&, Fortran::semantics::Scope&) (/usr/lib/llvm-22/bin/flang+0x138db33)
#12 0x0000562d88fb600f Fortran::semantics::Semantics::Perform() (/usr/lib/llvm-22/bin/flang+0x147b00f)
#13 0x0000562d8870591e Fortran::frontend::FrontendAction::runSemanticChecks() (/usr/lib/llvm-22/bin/flang+0xbca91e)
#14 0x0000562d8870a7da Fortran::frontend::CodeGenAction::beginSourceFileAction() (/usr/lib/llvm-22/bin/flang+0xbcf7da)
#15 0x0000562d88704f9e Fortran::frontend::FrontendAction::beginSourceFile(Fortran::frontend::CompilerInstance&, Fortran::frontend::FrontendInputFile const&) (/usr/lib/llvm-22/bin/flang+0xbc9f9e)
#16 0x0000562d886ece7f Fortran::frontend::CompilerInstance::executeAction(Fortran::frontend::FrontendAction&) (/usr/lib/llvm-22/bin/flang+0xbb1e7f)
#17 0x0000562d88709ba0 Fortran::frontend::executeCompilerInvocation(Fortran::frontend::CompilerInstance*) (/usr/lib/llvm-22/bin/flang+0xbceba0)
#18 0x0000562d886ead34 fc1_main(llvm::ArrayRef<char const*>, char const*) (/usr/lib/llvm-22/bin/flang+0xbafd34)
#19 0x0000562d886e9fa4 main (/usr/lib/llvm-22/bin/flang+0xbaefa4)
#20 0x00007f0c8865b1ca (/lib/x86_64-linux-gnu/libc.so.6+0x2a1ca)
#21 0x00007f0c8865b28b __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28b)
#22 0x0000562d886e8f45 _start (/usr/lib/llvm-22/bin/flang+0xbadf45)
flang-22: error: unable to execute command: Segmentation fault (core dumped)
flang-22: error: flang frontend command failed due to signal (use -v to see invocation)
Ubuntu flang version 22.1.8 (++20260613092238+e80beda6e255-1~exp1~20260613092253.78)
Target: x86_64-pc-linux-gnu
Thread model: posix
InstalledDir: /usr/lib/llvm-22/bin
flang-22: note: diagnostic msg: 
********************

PLEASE ATTACH THE FOLLOWING FILES TO THE BUG REPORT:
Preprocessed source(s) and associated run script(s) are located at:
flang-22: note: diagnostic msg: /tmp/52ab13ea-3a15d6
flang-22: note: diagnostic msg: /tmp/52ab13ea-3a15d6.sh
flang-22: note: diagnostic msg: 

********************
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ulimit -v 3145728; ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' flang -S -o /dev/null -O2 -ffree-form -std=f2018 -ffast-math "$SCRIPT_DIR/test.f90"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `d8aa3a9f` | Project seed |
| `b` | `c91a687a` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
