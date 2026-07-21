*Fusion-Fuzz Bug Report*

**ID:** `c1686212` &nbsp;·&nbsp; **Signature:** `Stack dump: Fortran::semantics::ComputeOffsetsHelper::Compute > Fortran::semantics::ComputeOffsetsHelper::Compute > Fortran::semantics::ComputeOffsets` &nbsp;·&nbsp; **RC:** `254`

The following code:

```f90
! ALL-LABEL:   func.func @_QPtest3(
! ALL:           %[[VAL_1:.*]]:2 = hlfir.declare{{.*}}{fortran_attrs = #fir.var_attrs<allocatable>, uniq_name = "_QFtest3Ex"}
! ALL:           hlfir.assign %{{.*}} to %[[VAL_1]]#0 realloc : i32, !fir.ref<!fir.class<!fir.heap<none>>>
! Check that symbols without SAVE attribute from an EQUIVALENCE
! with at least one symbol being SAVEd (explicitly or implicitly)
! have implicit SAVE attribute.
!RUN: %flang_fc1 -fdebug-dump-symbols %s | FileCheck %s
! ALL-LABEL:   func.func @_QPtest1(
! ALL:           %[[VAL_3:.*]]:2 = hlfir.declare{{.*}}{fortran_attrs = #fir.var_attrs<allocatable>, uniq_name = "_QFtest1Ea"}
! REALLOCLHS:    hlfir.assign %{{.*}} to %[[VAL_3]]#0 realloc : !hlfir.expr<?xi32>, !fir.ref<!fir.box<!fir.heap<!fir.array<?xi32>>>>

! NOREALLOCLHS:  %[[VAL_20:.*]] = fir.load %[[VAL_3]]#0 : !fir.ref<!fir.box<!fir.heap<!fir.array<?xi32>>>>
! NOREALLOCLHS:  hlfir.assign %{{.*}} to %[[VAL_20]] : !hlfir.expr<?xi32>, !fir.box<!fir.heap<!fir.array<?xi32>>>
! RUN: bbc %s -o - -emit-hlfir | FileCheck %s --check-prefixes=ALL,REALLOCLHS
! RUN: bbc %s -o - -emit-hlfir -frealloc-lhs | FileCheck %s --check-prefixes=ALL,REALLOCLHS
! RUN: bbc %s -o - -emit-hlfir -frealloc-lhs=false | FileCheck %s --check-prefixes=ALL,NOREALLOCLHS
! RUN: %flang_fc1 %s -o - -emit-hlfir | FileCheck %s --check-prefixes=ALL,REALLOCLHS
! RUN: %flang_fc1 %s -o - -emit-hlfir -frealloc-lhs | FileCheck %s --check-prefixes=ALL,REALLOCLHS
! RUN: %flang_fc1 %s -o - -emit-hlfir -fno-realloc-lhs 2>&1 | FileCheck %s --check-prefixes=ALL,NOREALLOCLHS

! -fno-realloc-lhs must be ignored for polymorphic allocatable LHS (TEST3_ffl below).
subroutine TEST1_ffl(a, b)
  integer, allocatable :: a(:), b(:)
  a = b + 1
end
subroutine TEST2_ffl(a, b)
  character(len=*), allocatable :: a(:)
  character(len=*) :: b(:)
  a = b
end subroutine TEST2_ffl
! ALL-LABEL:   func.func @_QPtest2(
! ALL:           %[[VAL_3:.*]]:2 = hlfir.declare{{.*}}{fortran_attrs = #fir.var_attrs<allocatable>, uniq_name = "_QFtest2Ea"}
! REALLOCLHS:    hlfir.assign %{{.*}} to %[[VAL_3]]#0 realloc keep_lhs_len : !fir.box<!fir.array<?x!fir.char<1,?>>>, !fir.ref<!fir.box<!fir.heap<!fir.array<?x!fir.char<1,?>>>>>

! NOREALLOCLHS:  %[[VAL_7:.*]] = fir.load %[[VAL_3]]#0 : !fir.ref<!fir.box<!fir.heap<!fir.array<?x!fir.char<1,?>>>>>
! NOREALLOCLHS:  hlfir.assign %{{.*}} to %[[VAL_7]] : !fir.box<!fir.array<?x!fir.char<1,?>>>, !fir.box<!fir.heap<!fir.array<?x!fir.char<1,?>>>>

! Polymorphic allocatable LHS: reallocation semantics must be used regardless of
! -fno-realloc-lhs, because the Fortran standard requires dynamic type tracking
! for polymorphic assignments (a F2003+ feature that cannot be safely skipped).
subroutine TEST3_ffl(x)
  class(*), allocatable :: x
  x = 1
end subroutine TEST3_ffl
subroutine test1()
  ! CHECK-LABEL: Subprogram scope: test1
  ! CHECK: i1, SAVE size=4 offset=0: ObjectEntity type: INTEGER(4) init:1_4
  ! CHECK: j1, SAVE size=4 offset=0: ObjectEntity type: INTEGER(4)
  integer :: i1 = 1
  integer :: j1
  equivalence(i1,j1)
end subroutine test1
subroutine test2()
  ! CHECK-LABEL: Subprogram scope: test2
  ! CHECK: i1, SAVE size=4 offset=0: ObjectEntity type: INTEGER(4) init:1_4
  ! CHECK: j1, SAVE size=4 offset=0: ObjectEntity type: INTEGER(4)
  integer :: i1 = 1
  integer :: j1
  equivalence(j1,i1)
end subroutine test2
subroutine test3()
  ! CHECK-LABEL: Subprogram scope: test3
  ! CHECK: i1, SAVE size=4 offset=0: ObjectEntity type: INTEGER(4)
  ! CHECK: j1, SAVE size=4 offset=0: ObjectEntity type: INTEGER(4)
  ! CHECK: k1, SAVE (InCommonBlock) size=4 offset=0: ObjectEntity type: INTEGER(4)
  integer :: i1
  integer :: j1, k1
  common /blk/ k1
  save /blk/
  equivalence(i1,TEST3,k1)
end subroutine test3
subroutine test4()
  ! CHECK-LABEL: Subprogram scope: test4
  ! CHECK: i1, SAVE size=4 offset=0: ObjectEntity type: INTEGER(4) init:1_4
  ! CHECK: j1, SAVE size=4 offset=0: ObjectEntity type: INTEGER(4)
  ! CHECK: k1, SAVE (InCommonBlock) size=4 offset=0: ObjectEntity type: INTEGER(4)
  integer :: i1 = 1
  integer :: j1, k1
  common /blk/ k1
  equivalence(i1,j1,k1)
end subroutine test4
```

Resulted in this output:

```

fatal internal error: CHECK(p) failed at flang/include/flang/Semantics/symbol.h(902)
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and instructions to reproduce the bug.
Stack dump:
0.	Program arguments: /usr/lib/llvm-22/bin/flang -fc1 -triple x86_64-pc-linux-gnu -emit-obj -ffree-form -mrelocation-model pic -pic-level 2 -pic-is-pie -target-cpu x86-64 -vectorize-loops -vectorize-slp -fversion-loops-for-stride -resource-dir /usr/lib/llvm-22/lib/clang/22 -mframe-pointer=none -O3 -o /dev/null -x f95 /home/fuzz/WorkSpace/fusion-fuzz/.fused/flang/tmpbnp7n_f9/c1686212.f90
 #0 0x00007f6f3352ad5f llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/lib/llvm-22/lib/libLLVM.so.22.1+0x4dc7d5f)
 #1 0x00007f6f335285d7 llvm::sys::RunSignalHandlers() (/usr/lib/llvm-22/lib/libLLVM.so.22.1+0x4dc55d7)
 #2 0x00007f6f3352bb2a (/usr/lib/llvm-22/lib/libLLVM.so.22.1+0x4dc8b2a)
 #3 0x00007f6f2e1ff330 (/lib/x86_64-linux-gnu/libc.so.6+0x45330)
 #4 0x00007f6f2e258b2c pthread_kill (/lib/x86_64-linux-gnu/libc.so.6+0x9eb2c)
 #5 0x00007f6f2e1ff27e raise (/lib/x86_64-linux-gnu/libc.so.6+0x4527e)
 #6 0x00007f6f2e1e28ff abort (/lib/x86_64-linux-gnu/libc.so.6+0x288ff)
 #7 0x000055c1a39fe61c (/usr/lib/llvm-22/bin/flang+0x2b2061c)
 #8 0x000055c1a247fe8e Fortran::semantics::ComputeOffsetsHelper::Compute(Fortran::semantics::Scope&) (/usr/lib/llvm-22/bin/flang+0x15a1e8e)
 #9 0x000055c1a247f7a2 Fortran::semantics::ComputeOffsetsHelper::Compute(Fortran::semantics::Scope&) (/usr/lib/llvm-22/bin/flang+0x15a17a2)
#10 0x000055c1a247ff1f Fortran::semantics::ComputeOffsets(Fortran::semantics::SemanticsContext&, Fortran::semantics::Scope&) (/usr/lib/llvm-22/bin/flang+0x15a1f1f)
#11 0x000055c1a235902c Fortran::semantics::Semantics::Perform() (/usr/lib/llvm-22/bin/flang+0x147b02c)
#12 0x000055c1a1aa891e Fortran::frontend::FrontendAction::runSemanticChecks() (/usr/lib/llvm-22/bin/flang+0xbca91e)
#13 0x000055c1a1aad7da Fortran::frontend::CodeGenAction::beginSourceFileAction() (/usr/lib/llvm-22/bin/flang+0xbcf7da)
#14 0x000055c1a1aa7f9e Fortran::frontend::FrontendAction::beginSourceFile(Fortran::frontend::CompilerInstance&, Fortran::frontend::FrontendInputFile const&) (/usr/lib/llvm-22/bin/flang+0xbc9f9e)
#15 0x000055c1a1a8fe7f Fortran::frontend::CompilerInstance::executeAction(Fortran::frontend::FrontendAction&) (/usr/lib/llvm-22/bin/flang+0xbb1e7f)
#16 0x000055c1a1aacba0 Fortran::frontend::executeCompilerInvocation(Fortran::frontend::CompilerInstance*) (/usr/lib/llvm-22/bin/flang+0xbceba0)
#17 0x000055c1a1a8dd34 fc1_main(llvm::ArrayRef<char const*>, char const*) (/usr/lib/llvm-22/bin/flang+0xbafd34)
#18 0x000055c1a1a8cfa4 main (/usr/lib/llvm-22/bin/flang+0xbaefa4)
#19 0x00007f6f2e1e41ca (/lib/x86_64-linux-gnu/libc.so.6+0x2a1ca)
#20 0x00007f6f2e1e428b __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28b)
#21 0x000055c1a1a8bf45 _start (/usr/lib/llvm-22/bin/flang+0xbadf45)
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
flang-22: note: diagnostic msg: /tmp/c1686212-2109b5
flang-22: note: diagnostic msg: /tmp/c1686212-2109b5.sh
flang-22: note: diagnostic msg: 

********************
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ulimit -v 3145728; ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' flang -c -o /dev/null -O3 -ffree-form "$SCRIPT_DIR/test.f90"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `95f88337` | Project seed |
| `b` | `09e92efa` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
