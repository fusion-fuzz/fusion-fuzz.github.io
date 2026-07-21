*Fusion-Fuzz Bug Report*

**ID:** `81647601` &nbsp;·&nbsp; **Signature:** `Stack dump: fir::factory::CharacterExprHelper::readLengthFromBox > Fortran::lower::mapSymbolAttributes > Fortran::lower::instantiateVariable` &nbsp;·&nbsp; **RC:** `254`

The following code:

```f90
end
! Test lowering of allocatable and pointer sub-part reference to HLFIR
! As opposed to whole reference, a pointer/allocatable dereference must
! be inserted and addressed in a following hlfir.designate to address
! the sub-part.

! RUN: bbc -emit-hlfir -o - %s -I nw | FileCheck %s
module m
! CHECK-LABEL:   fir.global internal @_QFEc : !fir.box<!fir.ptr<!fir.char<1,?>>> {
! CHECK:           %[[VAL_0:.*]] = fir.zero_bits !fir.ptr<!fir.char<1,?>>
! CHECK:           %[[VAL_1:.*]] = arith.constant 0 : index
! CHECK:           %[[VAL_2:.*]] = fir.embox %[[VAL_0]] typeparams %[[VAL_1]] : (!fir.ptr<!fir.char<1,?>>, index) -> !fir.box<!fir.ptr<!fir.char<1,?>>>
! CHECK:           fir.has_value %[[VAL_2]] : !fir.box<!fir.ptr<!fir.char<1,?>>>
! CHECK:         }

! CHECK-LABEL:   fir.global internal @_QFEc2 : !fir.box<!fir.ptr<!fir.char<1,2>>> {
! CHECK:           %[[VAL_0:.*]] = fir.zero_bits !fir.ptr<!fir.char<1,2>>
! CHECK:           %[[VAL_1:.*]] = fir.embox %[[VAL_0]] : (!fir.ptr<!fir.char<1,2>>) -> !fir.box<!fir.ptr<!fir.char<1,2>>>
! CHECK:           fir.has_value %[[VAL_1]] : !fir.box<!fir.ptr<!fir.char<1,2>>>
! CHECK:         }
! RUN: %flang_fc1 -emit-hlfir -fopenmp %s -o - | FileCheck %s

! Regression test for https://github.com/llvm/llvm-project/issues/108136

character(:), pointer :: TEST_COMPONENT_FOLLOWED_BY_REF
character(2), pointer :: c2
!$omp threadprivate(c, c2)
type t1
    real :: x
  end type
type t2
    type(t1), pointer :: p
  end type
type t3
    character(:), allocatable :: a(:)
  end type
end module
subroutine test_pointer_component_followed_by_component_ref(x)
  use m
  type(t2) :: x
  call takes_real(x%p%x)
end subroutine
! CHECK-LABEL: func.func @_QPtest_pointer_component_followed_by_component_ref(
! CHECK:  %[[VAL_1:.*]]:2 = hlfir.declare %{{.*}} {{.*}}Ex
! CHECK:  %[[VAL_2:.*]] = hlfir.designate %[[VAL_1]]#0{"p"}   {fortran_attrs = #fir.var_attrs<pointer>} : (!fir.ref<!fir.type<_QMmTt2{p:!fir.box<!fir.ptr<!fir.type<_QMmTt1{x:f32}>>>}>>) -> !fir.ref<!fir.box<!fir.ptr<!fir.type<_QMmTt1{x:f32}>>>>
! CHECK:  %[[VAL_3:.*]] = fir.load %[[VAL_2]] : !fir.ref<!fir.box<!fir.ptr<!fir.type<_QMmTt1{x:f32}>>>>
! CHECK:  %[[VAL_4:.*]] = fir.box_addr %[[VAL_3:.*]] : (!fir.box<!fir.ptr<!fir.type<_QMmTt1{x:f32}>>>) -> !fir.ptr<!fir.type<_QMmTt1{x:f32}>>
! CHECK:  hlfir.designate %[[VAL_4]]{"x"}   : (!fir.ptr<!fir.type<_QMmTt1{x:f32}>>) -> !fir.ref<f32>
subroutine test_symbol_followed_by_ref(x)
  character(:), allocatable :: x(:)
  call test_char(x(10))
end subroutine
! CHECK-LABEL: func.func @_QPtest_symbol_followed_by_ref(
! CHECK:  %[[VAL_1:.*]]:2 = hlfir.declare %{{.*}} {fortran_attrs = #fir.var_attrs<allocatable>, uniq_name = {{.*}}Ex"
! CHECK:  %[[VAL_2:.*]] = fir.load %[[VAL_1]]#0 : !fir.ref<!fir.box<!fir.heap<!fir.array<?x!fir.char<1,?>>>>>
! CHECK:  %[[VAL_3:.*]] = fir.box_elesize %[[VAL_2]] : (!fir.box<!fir.heap<!fir.array<?x!fir.char<1,?>>>>) -> index
! CHECK:  %[[VAL_4:.*]] = arith.constant 10 : index
! CHECK:  %[[VAL_5:.*]] = hlfir.designate %[[VAL_2]] (%[[VAL_4]])  typeparams %[[VAL_3]] : (!fir.box<!fir.heap<!fir.array<?x!fir.char<1,?>>>>, index, index) -> !fir.boxchar<1>
subroutine test_component_followed_by_ref(x)
  use m
  type(t3) :: x
  call test_char(x%a(10))
end subroutine
! CHECK-LABEL: func.func @_QPtest_component_followed_by_ref(
! CHECK:  %[[VAL_1:.*]]:2 = hlfir.declare %{{.*}} {{.*}}Ex
! CHECK:  %[[VAL_2:.*]] = hlfir.designate %[[VAL_1]]#0{"a"}   {fortran_attrs = #fir.var_attrs<allocatable>} : (!fir.ref<!fir.type<_QMmTt3{a:!fir.box<!fir.heap<!fir.array<?x!fir.char<1,?>>>>}>>) -> !fir.ref<!fir.box<!fir.heap<!fir.array<?x!fir.char<1,?>>>>>
! CHECK:  %[[VAL_3:.*]] = fir.load %[[VAL_2]] : !fir.ref<!fir.box<!fir.heap<!fir.array<?x!fir.char<1,?>>>>>
! CHECK:  %[[VAL_4:.*]] = fir.box_elesize %[[VAL_3]] : (!fir.box<!fir.heap<!fir.array<?x!fir.char<1,?>>>>) -> index
! CHECK:  %[[VAL_5:.*]] = arith.constant 10 : index
! CHECK:  %[[VAL_6:.*]] = hlfir.designate %[[VAL_3]] (%[[VAL_5]])  typeparams %[[VAL_4]] : (!fir.box<!fir.heap<!fir.array<?x!fir.char<1,?>>>>, index, index) -> !fir.boxchar<1>
```

Resulted in this output:

```
/home/fuzz/WorkSpace/fusion-fuzz/.fused/flang/tmp86xzry08/81647601.f90:60:7: portability: 'test_component_followed_by_ref' is use-associated into a subprogram of the same name [-Wuse-association-into-same-name-subprogram]
    use m
        ^
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and instructions to reproduce the bug.
Stack dump:
0.	Program arguments: /usr/lib/llvm-22/bin/flang -fc1 -triple x86_64-pc-linux-gnu -emit-llvm -ffree-form -fno-automatic -mrelocation-model pic -pic-level 2 -pic-is-pie -target-cpu x86-64 -vectorize-loops -vectorize-slp -std=f2018 -debug-info-kind=standalone -resource-dir /usr/lib/llvm-22/lib/clang/22 -mframe-pointer=none -O2 -o /dev/null -x f95 /home/fuzz/WorkSpace/fusion-fuzz/.fused/flang/tmp86xzry08/81647601.f90
 #0 0x00007ff8dbdc0d5f llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/lib/llvm-22/lib/libLLVM.so.22.1+0x4dc7d5f)
 #1 0x00007ff8dbdbe5d7 llvm::sys::RunSignalHandlers() (/usr/lib/llvm-22/lib/libLLVM.so.22.1+0x4dc55d7)
 #2 0x00007ff8dbdc1b2a (/usr/lib/llvm-22/lib/libLLVM.so.22.1+0x4dc8b2a)
 #3 0x00007ff8d6a95330 (/lib/x86_64-linux-gnu/libc.so.6+0x45330)
 #4 0x000055b080e98622 fir::factory::CharacterExprHelper::readLengthFromBox(mlir::Value) (/usr/lib/llvm-22/bin/flang+0x1d93622)
 #5 0x000055b0800fcb02 Fortran::lower::mapSymbolAttributes(Fortran::lower::AbstractConverter&, Fortran::lower::pft::Variable const&, Fortran::lower::SymMap&, Fortran::lower::StatementContext&, mlir::Value) (/usr/lib/llvm-22/bin/flang+0xff7b02)
 #6 0x000055b0800f6c7e Fortran::lower::instantiateVariable(Fortran::lower::AbstractConverter&, Fortran::lower::pft::Variable const&, Fortran::lower::SymMap&, llvm::DenseMap<std::tuple<Fortran::semantics::Scope const*, unsigned long>, mlir::Value, llvm::DenseMapInfo<std::tuple<Fortran::semantics::Scope const*, unsigned long>, void>, llvm::detail::DenseMapPair<std::tuple<Fortran::semantics::Scope const*, unsigned long>, mlir::Value>>&) (/usr/lib/llvm-22/bin/flang+0xff1c7e)
 #7 0x000055b07fe630e3 (/usr/lib/llvm-22/bin/flang+0xd5e0e3)
 #8 0x000055b07fe61405 (/usr/lib/llvm-22/bin/flang+0xd5c405)
 #9 0x000055b07fdfba46 Fortran::lower::LoweringBridge::lower(Fortran::parser::Program const&, Fortran::semantics::SemanticsContext const&) (/usr/lib/llvm-22/bin/flang+0xcf6a46)
#10 0x000055b07fcd4a38 Fortran::frontend::CodeGenAction::beginSourceFileAction() (/usr/lib/llvm-22/bin/flang+0xbcfa38)
#11 0x000055b07fccef9e Fortran::frontend::FrontendAction::beginSourceFile(Fortran::frontend::CompilerInstance&, Fortran::frontend::FrontendInputFile const&) (/usr/lib/llvm-22/bin/flang+0xbc9f9e)
#12 0x000055b07fcb6e7f Fortran::frontend::CompilerInstance::executeAction(Fortran::frontend::FrontendAction&) (/usr/lib/llvm-22/bin/flang+0xbb1e7f)
#13 0x000055b07fcd3ba0 Fortran::frontend::executeCompilerInvocation(Fortran::frontend::CompilerInstance*) (/usr/lib/llvm-22/bin/flang+0xbceba0)
#14 0x000055b07fcb4d34 fc1_main(llvm::ArrayRef<char const*>, char const*) (/usr/lib/llvm-22/bin/flang+0xbafd34)
#15 0x000055b07fcb3fa4 main (/usr/lib/llvm-22/bin/flang+0xbaefa4)
#16 0x00007ff8d6a7a1ca (/lib/x86_64-linux-gnu/libc.so.6+0x2a1ca)
#17 0x00007ff8d6a7a28b __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28b)
#18 0x000055b07fcb2f45 _start (/usr/lib/llvm-22/bin/flang+0xbadf45)
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
flang-22: note: diagnostic msg: /tmp/81647601-3ba84a
flang-22: note: diagnostic msg: /tmp/81647601-3ba84a.sh
flang-22: note: diagnostic msg: 

********************
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ulimit -v 3145728; ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' flang -emit-llvm -S -o /dev/null -O2 -ffree-form -std=f2018 -fno-automatic -g "$SCRIPT_DIR/test.f90"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `f2936e3a` | Project seed |
| `b` | `3df200ad` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
