*Fusion-Fuzz Bug Report*

**ID:** `c9508c6b` &nbsp;·&nbsp; **Signature:** `Stack dump: Fortran::semantics::SemanticsContext::FindScope > Fortran::semantics::AllocateChecker::Leave > Fortran::semantics::Semantics::Perform` &nbsp;·&nbsp; **RC:** `254`

The following code:

```f90
! RUN: %python %S/test_errors.py %s %flang_fc1 -pedantic
!ERROR: Some modules in this compilation unit form one or more cycles of dependence
module m1
  use m2
end

!PORTABILITY: A USE statement referencing module 'ffl_fusion' appears earlier in this compilation unit
module m2
  use m3
end

!PORTABILITY: A USE statement referencing module 'm3' appears earlier in this compilation unit
module m3
  use m1
end

! RUN: %flang_fc1 -emit-hlfir -O2 %s -o - | FileCheck %s

! Test lowering of allocatables for allocate statements with source.

! CHECK-LABEL: func.func @_QPtest_allocatable_scalar(
! CHECK-SAME:                                        %[[VAL_0:.*]]: !fir.ref<f32> {fir.bindc_name = "a"}) {
! CHECK-DAG:     %[[FALSE:.*]] = arith.constant false
! CHECK-DAG:     %[[ABSENT:.*]] = fir.absent !fir.box<none>
! CHECK-DAG:     %[[A_DECL:.*]]:2 = hlfir.declare %[[VAL_0]] {{.*}}
! CHECK-DAG:     %[[X1:.*]] = fir.address_of(@_QFtest_allocatable_scalarEx1) : !fir.ref<!fir.box<!fir.heap<f32>>>
! CHECK-DAG:     %[[X1_DECL:.*]]:2 = hlfir.declare %[[X1]] {{.*}}
! CHECK-DAG:     %[[X2:.*]] = fir.address_of(@_QFtest_allocatable_scalarEx2) : !fir.ref<!fir.box<!fir.heap<f32>>>
! CHECK-DAG:     %[[X2_DECL:.*]]:2 = hlfir.declare %[[X2]] {{.*}}
! CHECK:         %[[EMBOX_A:.*]] = fir.embox %[[A_DECL]]#0 : (!fir.ref<f32>) -> !fir.box<f32>
! CHECK:         %[[X1_BOX_NONE:.*]] = fir.convert %[[X1_DECL]]#0 : (!fir.ref<!fir.box<!fir.heap<f32>>>) -> !fir.ref<!fir.box<none>>
! CHECK:         %[[A_BOX_NONE:.*]] = fir.convert %[[EMBOX_A]] : (!fir.box<f32>) -> !fir.box<none>
! CHECK:         %[[RES1:.*]] = fir.call @_FortranAAllocatableAllocateSource(%[[X1_BOX_NONE]], %[[A_BOX_NONE]], %[[FALSE]], %[[ABSENT]], %{{.*}}: (!fir.ref<!fir.box<none>>, !fir.box<none>, i1, !fir.box<none>, !fir.ref<i8>, i32) -> i32
! CHECK:         %[[X2_BOX_NONE:.*]] = fir.convert %[[X2_DECL]]#0 : (!fir.ref<!fir.box<!fir.heap<f32>>>) -> !fir.ref<!fir.box<none>>
! CHECK:         %[[RES2:.*]] = fir.call @_FortranAAllocatableAllocateSource(%[[X2_BOX_NONE]], %{{.*}}, %[[FALSE]], %[[ABSENT]], %{{.*}}: (!fir.ref<!fir.box<none>>, !fir.box<none>, i1, !fir.box<none>, !fir.ref<i8>, i32) -> i32
! CHECK:         return
! CHECK:       }

subroutine test_allocatable_scalar(a)
  real, save, allocatable :: x1, x2
  real :: a

  allocate(x1, x2, source = a)
end

! CHECK-LABEL: func.func @_QPtest_allocatable_2d_array(
! CHECK-SAME:                                          %[[VAL_0:.*]]: !fir.ref<i32> {fir.bindc_name = "n"},
! CHECK-SAME:                                          %[[VAL_1:.*]]: !fir.ref<!fir.array<?x?xi32>> {fir.bindc_name = "a"}) {
! CHECK-DAG:     %[[FALSE:.*]] = arith.constant false
! CHECK-DAG:     %[[ABSENT:.*]] = fir.absent !fir.box<none>
! CHECK-DAG:     %[[X1:.*]] = fir.alloca !fir.box<!fir.heap<!fir.array<?x?xi32>>> {bindc_name = "x1", uniq_name = "_QFtest_allocatable_2d_arrayEx1"}
! CHECK-DAG:     %[[X1_DECL:.*]]:2 = hlfir.declare %[[X1]] {{.*}}
! CHECK-DAG:     %[[X2:.*]] = fir.alloca !fir.box<!fir.heap<!fir.array<?x?xi32>>> {bindc_name = "x2", uniq_name = "_QFtest_allocatable_2d_arrayEx2"}
! CHECK-DAG:     %[[X2_DECL:.*]]:2 = hlfir.declare %[[X2]] {{.*}}
! CHECK-DAG:     %[[X3:.*]] = fir.alloca !fir.box<!fir.heap<!fir.array<?x?xi32>>> {bindc_name = "x3", uniq_name = "_QFtest_allocatable_2d_arrayEx3"}
! CHECK-DAG:     %[[X3_DECL:.*]]:2 = hlfir.declare %[[X3]] {{.*}}
! CHECK-DAG:     %[[A_DECL:.*]]:2 = hlfir.declare %[[VAL_1]](%{{.*}}) {{.*}}
! CHECK:         fir.embox %[[A_DECL]]#1
! CHECK:         %[[X1_BOX_NONE:.*]] = fir.convert %[[X1_DECL]]#0 : (!fir.ref<!fir.box<!fir.heap<!fir.array<?x?xi32>>>>) -> !fir.ref<!fir.box<none>>
! CHECK:         fir.call @_FortranAAllocatableSetBounds(%[[X1_BOX_NONE]], {{.*}}) {{.*}}: (!fir.ref<!fir.box<none>>, i32, i64, i64) -> ()
! CHECK:         fir.call @_FortranAAllocatableSetBounds(%{{.*}}, {{.*}}) {{.*}}: (!fir.ref<!fir.box<none>>, i32, i64, i64) -> ()
! CHECK:         %[[A_BOX_NONE:.*]] = fir.convert %{{.*}} : (!fir.box<!fir.array<?x?xi32>>) -> !fir.box<none>
! CHECK:         fir.call @_FortranAAllocatableAllocateSource(%{{.*}}, %{{.*}}, %[[FALSE]], %[[ABSENT]], %{{.*}}, %{{.*}}) {{.*}}: (!fir.ref<!fir.box<none>>, !fir.box<none>, i1, !fir.box<none>, !fir.ref<i8>, i32) -> i32
! CHECK:         %[[X2_BOX_NONE:.*]] = fir.convert %[[X2_DECL]]#0 : (!fir.ref<!fir.box<!fir.heap<!fir.array<?x?xi32>>>>) -> !fir.ref<!fir.box<none>>
! CHECK:         fir.call @_FortranAAllocatableSetBounds(%[[X2_BOX_NONE]], {{.*}}) {{.*}}: (!fir.ref<!fir.box<none>>, i32, i64, i64) -> ()
! CHECK:         fir.call @_FortranAAllocatableSetBounds(%{{.*}}, {{.*}}) {{.*}}: (!fir.ref<!fir.box<none>>, i32, i64, i64) -> ()
! CHECK:         fir.call @_FortranAAllocatableAllocateSource(%{{.*}}, %{{.*}}, %[[FALSE]], %[[ABSENT]], %{{.*}}, %{{.*}}) {{.*}}: (!fir.ref<!fir.box<none>>, !fir.box<none>, i1, !fir.box<none>, !fir.ref<i8>, i32) -> i32
! CHECK:         %[[A_SLICE_BOX_NONE:.*]] = fir.convert %{{.*}} : (!fir.box<!fir.array<{{.*}}>>) -> !fir.box<none>
! CHECK:         fir.call @_FortranAAllocatableAllocateSource(%{{.*}}, %[[A_SLICE_BOX_NONE]], %{{.*}})

subroutine test_allocatable_2d_array(n, a)
  integer, allocatable :: x1(:,:), x2(:,:), x3(:,:)
  integer :: n, sss, a(n, n)

  allocate(x1, x2, source = a)
  allocate(x3, source = a(1:3:2, 2:3), stat=sss)
end

! CHECK-LABEL: func.func @_QPtest_allocatable_with_shapespec(
! CHECK-SAME:                                                %[[VAL_0:.*]]: !fir.ref<i32> {fir.bindc_name = "n"},
! CHECK-SAME:                                                %[[VAL_1:.*]]: !fir.ref<!fir.array<?xi32>> {fir.bindc_name = "a"},
! CHECK-SAME:                                                %[[VAL_2:.*]]: !fir.ref<i32> {fir.bindc_name = "m"}) {
! CHECK-DAG:     %[[X1:.*]] = fir.alloca !fir.box<!fir.heap<!fir.array<?xi32>>> {bindc_name = "x1", uniq_name = "_QFtest_allocatable_with_shapespecEx1"}
! CHECK-DAG:     %[[X1_DECL:.*]]:2 = hlfir.declare %[[X1]] {{.*}}
! CHECK-DAG:     %[[X2:.*]] = fir.alloca !fir.box<!fir.heap<!fir.array<?xi32>>> {bindc_name = "x2", uniq_name = "_QFtest_allocatable_with_shapespecEx2"}
! CHECK-DAG:     %[[X2_DECL:.*]]:2 = hlfir.declare %[[X2]] {{.*}}
! CHECK-DAG:     %[[A_DECL:.*]]:2 = hlfir.declare %[[VAL_1]](%{{.*}}) {{.*}}
! CHECK:         fir.embox %[[A_DECL]]#1
! CHECK:         %[[X1_BOX_NONE:.*]] = fir.convert %[[X1_DECL]]#0 : (!fir.ref<!fir.box<!fir.heap<!fir.array<?xi32>>>>) -> !fir.ref<!fir.box<none>>
! CHECK:         fir.call @_FortranAAllocatableSetBounds(%[[X1_BOX_NONE]], {{.*}}) {{.*}}: (!fir.ref<!fir.box<none>>, i32, i64, i64) -> ()
! CHECK:         %[[A_BOX_NONE:.*]] = fir.convert %{{.*}} : (!fir.box<!fir.array<?xi32>>) -> !fir.box<none>
! CHECK:         fir.call @_FortranAAllocatableAllocateSource(%{{.*}}, %[[A_BOX_NONE]], %{{.*}}) {{.*}}: (!fir.ref<!fir.box<none>>, !fir.box<none>, i1, !fir.box<none>, !fir.ref<i8>, i32) -> i32
! CHECK:         %[[X2_BOX_NONE:.*]] = fir.convert %[[X2_DECL]]#0 : (!fir.ref<!fir.box<!fir.heap<!fir.array<?xi32>>>>) -> !fir.ref<!fir.box<none>>
! CHECK:         fir.call @_FortranAAllocatableSetBounds(%[[X2_BOX_NONE]], {{.*}}) {{.*}}: (!fir.ref<!fir.box<none>>, i32, i64, i64) -> ()
! CHECK:         fir.call @_FortranAAllocatableAllocateSource(%{{.*}}, %{{.*}}, %{{.*}}) {{.*}}: (!fir.ref<!fir.box<none>>, !fir.box<none>, i1, !fir.box<none>, !fir.ref<i8>, i32) -> i32

subroutine test_allocatable_with_shapespec(n, a, m)
  integer, allocatable :: x1(:), x2(:)
  integer :: n, m, a(n)

  allocate(x1(2:m), x2(n), source = a)
end

! CHECK-LABEL: func.func @_QPtest_allocatable_from_const(
! CHECK-SAME:                                            %[[VAL_0:.*]]: !fir.ref<i32> {fir.bindc_name = "n"},
! CHECK-SAME:                                            %[[VAL_1:.*]]: !fir.ref<!fir.array<?xi32>> {fir.bindc_name = "a"}) {
! CHECK-DAG:     %[[X1:.*]] = fir.alloca !fir.box<!fir.heap<!fir.array<?xi32>>> {bindc_name = "x1", uniq_name = "_QFtest_allocatable_from_constEx1"}
! CHECK-DAG:     %[[X1_DECL:.*]]:2 = hlfir.declare %[[X1]] {{.*}}
! CHECK-DAG:     %[[CONST:.*]] = fir.address_of(@_QQro.5xi4.0) : !fir.ref<!fir.array<5xi32>>
! CHECK-DAG:     %[[CONST_DECL:.*]]:2 = hlfir.declare %[[CONST]](%{{.*}}) {{.*}}
! CHECK:         %[[EMBOX_CONST:.*]] = fir.embox %[[CONST_DECL]]#0(%{{.*}}) : (!fir.ref<!fir.array<5xi32>>, !fir.shape<1>) -> !fir.box<!fir.array<5xi32>>
! CHECK:         %[[X1_BOX_NONE:.*]] = fir.convert %[[X1_DECL]]#0 : (!fir.ref<!fir.box<!fir.heap<!fir.array<?xi32>>>>) -> !fir.ref<!fir.box<none>>
! CHECK:         fir.call @_FortranAAllocatableSetBounds(%[[X1_BOX_NONE]], {{.*}}) {{.*}}: (!fir.ref<!fir.box<none>>, i32, i64, i64) -> ()
! CHECK:         %[[CONST_BOX_NONE:.*]] = fir.convert %[[EMBOX_CONST]] : (!fir.box<!fir.array<5xi32>>) -> !fir.box<none>
! CHECK:         fir.call @_FortranAAllocatableAllocateSource(%{{.*}}, %[[CONST_BOX_NONE]], %{{.*}}) {{.*}}: (!fir.ref<!fir.box<none>>, !fir.box<none>, i1, !fir.box<none>, !fir.ref<i8>, i32) -> i32
! CHECK:         return
! CHECK:       }

subroutine test_allocatable_from_const(n, a)
  integer, allocatable :: x1(:)
  integer :: n, a(n)

  allocate(x1, source = [1, 2, 3, 4, 5])
end

! CHECK-LABEL: func.func @_QPtest_allocatable_chararray(
! CHECK-SAME:                                           %[[VAL_0:.*]]: !fir.ref<i32> {fir.bindc_name = "n"},
! CHECK-SAME:                                           %[[VAL_1:.*]]: !fir.boxchar<1> {fir.bindc_name = "a"}) {
! CHECK-DAG:     %[[X1:.*]] = fir.alloca !fir.box<!fir.heap<!fir.array<?x!fir.char<1,4>>>> {bindc_name = "x1", uniq_name = "_QFtest_allocatable_chararrayEx1"}
! CHECK-DAG:     %[[X1_DECL:.*]]:2 = hlfir.declare %[[X1]] {{.*}}
! CHECK-DAG:     %[[UNBOX:.*]]:2 = fir.unboxchar %[[VAL_1]] : (!fir.boxchar<1>) -> (!fir.ref<!fir.char<1,?>>, index)
! CHECK-DAG:     %[[A_CAST:.*]] = fir.convert %[[UNBOX]]#0 : (!fir.ref<!fir.char<1,?>>) -> !fir.ref<!fir.array<?x!fir.char<1,?>>>
! CHECK-DAG:     %[[A_DECL:.*]]:2 = hlfir.declare %[[A_CAST]](%{{.*}}) typeparams %[[UNBOX]]#1 {{.*}}
! CHECK:         fir.embox %[[A_DECL]]#1
! CHECK:         %[[X1_BOX_NONE:.*]] = fir.convert %[[X1_DECL]]#0 : (!fir.ref<!fir.box<!fir.heap<!fir.array<?x!fir.char<1,4>>>>>) -> !fir.ref<!fir.box<none>>
! CHECK:         fir.call @_FortranAAllocatableSetBounds(%[[X1_BOX_NONE]], {{.*}}) {{.*}}: (!fir.ref<!fir.box<none>>, i32, i64, i64) -> ()
! CHECK:         %[[A_BOX_NONE:.*]] = fir.convert %{{.*}} : (!fir.box<!fir.array<?x!fir.char<1,?>>>) -> !fir.box<none>
! CHECK:         fir.call @_FortranAAllocatableAllocateSource(%{{.*}}, %[[A_BOX_NONE]], %{{.*}}) {{.*}}: (!fir.ref<!fir.box<none>>, !fir.box<none>, i1, !fir.box<none>, !fir.ref<i8>, i32) -> i32

subroutine test_allocatable_chararray(n, a)
  character(4), allocatable :: x1(:)
  integer :: n
  character(*) :: a(n)

  allocate(x1, source = a)
end

! CHECK-LABEL: func.func @_QPtest_allocatable_char(
! CHECK-SAME:                                      %[[VAL_0:.*]]: !fir.ref<i32> {fir.bindc_name = "n"},
! CHECK-SAME:                                      %[[VAL_1:.*]]: !fir.boxchar<1> {fir.bindc_name = "a"}) {
! CHECK-DAG:     %[[X1:.*]] = fir.alloca !fir.box<!fir.heap<!fir.char<1,?>>> {bindc_name = "x1", uniq_name = "_QFtest_allocatable_charEx1"}
! CHECK-DAG:     %[[UNBOX:.*]]:2 = fir.unboxchar %[[VAL_1]] : (!fir.boxchar<1>) -> (!fir.ref<!fir.char<1,?>>, index)
! CHECK-DAG:     %[[A_DECL:.*]]:2 = hlfir.declare %[[UNBOX]]#0 typeparams %[[UNBOX]]#1 {{.*}}
! CHECK-DAG:     %[[X1_DECL:.*]]:2 = hlfir.declare %[[X1]] {{.*}}
! CHECK:         fir.embox %[[A_DECL]]#1
! CHECK:         %[[X1_BOX_NONE:.*]] = fir.convert %[[X1_DECL]]#0 : (!fir.ref<!fir.box<!fir.heap<!fir.char<1,?>>>>) -> !fir.ref<!fir.box<none>>
! CHECK:         fir.call @_FortranAAllocatableInitCharacterForAllocate(%[[X1_BOX_NONE]], %{{.*}}) {{.*}}: (!fir.ref<!fir.box<none>>, i64, i32, i32, i32) -> ()
! CHECK:         %[[A_BOX_NONE:.*]] = fir.convert %{{.*}} : (!fir.box<!fir.char<1,?>>) -> !fir.box<none>
! CHECK:         fir.call @_FortranAAllocatableAllocateSource(%{{.*}}, %[[A_BOX_NONE]], %{{.*}}) {{.*}}: (!fir.ref<!fir.box<none>>, !fir.box<none>, i1, !fir.box<none>, !fir.ref<i8>, i32) -> i32

subroutine test_allocatable_char(n, a)
  character(:), allocatable :: x1
  integer :: n
  character(*) :: a

  allocate(x1, source = a)
end

! CHECK-LABEL: func.func @_QPtest_allocatable_derived_type(
! CHECK-SAME:                                              %[[VAL_0:.*]]: !fir.ref<!fir.box<!fir.heap<!fir.array<?x!fir.type<_QFtest_allocatable_derived_typeTt{x:!fir.box<!fir.heap<!fir.array<?xi32>>>}>>>>> {fir.bindc_name = "y"}) {
! CHECK-DAG:     %[[Z:.*]] = fir.alloca !fir.box<!fir.heap<!fir.array<?x!fir.type<_QFtest_allocatable_derived_typeTt{x:!fir.box<!fir.heap<!fir.array<?xi32>>>}>>>> {bindc_name = "z", uniq_name = "_QFtest_allocatable_derived_typeEz"}
! CHECK-DAG:     %[[Z_DECL:.*]]:2 = hlfir.declare %[[Z]] {{.*}}
! CHECK-DAG:     %[[Y_DECL:.*]]:2 = hlfir.declare %[[VAL_0]] {{.*}}
! CHECK:         fir.load %[[Y_DECL]]#0
! CHECK:         %[[Z_BOX_NONE:.*]] = fir.convert %[[Z_DECL]]#0 : (!fir.ref<!fir.box<!fir.heap<!fir.array<?x!fir.type<_QFtest_allocatable_derived_typeTt{x:!fir.box<!fir.heap<!fir.array<?xi32>>>}>>>>>) -> !fir.ref<!fir.box<none>>
! CHECK:         fir.call @_FortranAAllocatableSetBounds(%[[Z_BOX_NONE]], {{.*}}) {{.*}}: (!fir.ref<!fir.box<none>>, i32, i64, i64) -> ()
! CHECK:         %[[Y_BOX_NONE:.*]] = fir.convert %{{.*}} : (!fir.box<!fir.heap<!fir.array<?x!fir.type<_QFtest_allocatable_derived_typeTt{x:!fir.box<!fir.heap<!fir.array<?xi32>>>}>>>>) -> !fir.box<none>
! CHECK:         fir.call @_FortranAAllocatableAllocateSource(%{{.*}}, %[[Y_BOX_NONE]], %{{.*}}) {{.*}}: (!fir.ref<!fir.box<none>>, !fir.box<none>, i1, !fir.box<none>, !fir.ref<i8>, i32) -> i32

subroutine test_allocatable_derived_type(y)
  type t
    integer, allocatable :: x(:)
  end type
  type(t), allocatable :: z(:), y(:)

  allocate(z, source=y)
ffl_fusion = (M)
end

```

Resulted in this output:

```

fatal internal error: SemanticsContext::FindScope(): invalid source location for '[1, 2, 3, 4, 5]'
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and instructions to reproduce the bug.
Stack dump:
0.	Program arguments: /usr/lib/llvm-22/bin/flang -fc1 -triple x86_64-pc-linux-gnu -fsyntax-only -ffree-form -mrelocation-model pic -pic-level 2 -pic-is-pie -target-cpu x86-64 -resource-dir /usr/lib/llvm-22/lib/clang/22 -mframe-pointer=all -O0 -x f95 /home/fuzz/WorkSpace/fusion-fuzz/.fused/flang/tmpkgatxcna/c9508c6b.f90
 #0 0x00007fbfd7270d5f llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/lib/llvm-22/lib/libLLVM.so.22.1+0x4dc7d5f)
 #1 0x00007fbfd726e5d7 llvm::sys::RunSignalHandlers() (/usr/lib/llvm-22/lib/libLLVM.so.22.1+0x4dc55d7)
 #2 0x00007fbfd7271b2a (/usr/lib/llvm-22/lib/libLLVM.so.22.1+0x4dc8b2a)
 #3 0x00007fbfd1f45330 (/lib/x86_64-linux-gnu/libc.so.6+0x45330)
 #4 0x00007fbfd1f9eb2c pthread_kill (/lib/x86_64-linux-gnu/libc.so.6+0x9eb2c)
 #5 0x00007fbfd1f4527e raise (/lib/x86_64-linux-gnu/libc.so.6+0x4527e)
 #6 0x00007fbfd1f288ff abort (/lib/x86_64-linux-gnu/libc.so.6+0x288ff)
 #7 0x0000556e77fa261c (/usr/lib/llvm-22/bin/flang+0x2b2061c)
 #8 0x0000556e768fb6fa Fortran::semantics::SemanticsContext::FindScope(Fortran::parser::CharBlock) (/usr/lib/llvm-22/bin/flang+0x14796fa)
 #9 0x0000556e76be6040 Fortran::semantics::AllocateChecker::Leave(Fortran::parser::AllocateStmt const&) (/usr/lib/llvm-22/bin/flang+0x1764040)
#10 0x0000556e76908337 (/usr/lib/llvm-22/bin/flang+0x1486337)
#11 0x0000556e76907ce7 (/usr/lib/llvm-22/bin/flang+0x1485ce7)
#12 0x0000556e76912545 (/usr/lib/llvm-22/bin/flang+0x1490545)
#13 0x0000556e76912439 (/usr/lib/llvm-22/bin/flang+0x1490439)
#14 0x0000556e768fd0b8 Fortran::semantics::Semantics::Perform() (/usr/lib/llvm-22/bin/flang+0x147b0b8)
#15 0x0000556e7604c91e Fortran::frontend::FrontendAction::runSemanticChecks() (/usr/lib/llvm-22/bin/flang+0xbca91e)
#16 0x0000556e760510cc Fortran::frontend::PrescanAndSemaAction::beginSourceFileAction() (/usr/lib/llvm-22/bin/flang+0xbcf0cc)
#17 0x0000556e7604bf9e Fortran::frontend::FrontendAction::beginSourceFile(Fortran::frontend::CompilerInstance&, Fortran::frontend::FrontendInputFile const&) (/usr/lib/llvm-22/bin/flang+0xbc9f9e)
#18 0x0000556e76033e7f Fortran::frontend::CompilerInstance::executeAction(Fortran::frontend::FrontendAction&) (/usr/lib/llvm-22/bin/flang+0xbb1e7f)
#19 0x0000556e76050ba0 Fortran::frontend::executeCompilerInvocation(Fortran::frontend::CompilerInstance*) (/usr/lib/llvm-22/bin/flang+0xbceba0)
#20 0x0000556e76031d34 fc1_main(llvm::ArrayRef<char const*>, char const*) (/usr/lib/llvm-22/bin/flang+0xbafd34)
#21 0x0000556e76030fa4 main (/usr/lib/llvm-22/bin/flang+0xbaefa4)
#22 0x00007fbfd1f2a1ca (/lib/x86_64-linux-gnu/libc.so.6+0x2a1ca)
#23 0x00007fbfd1f2a28b __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28b)
#24 0x0000556e7602ff45 _start (/usr/lib/llvm-22/bin/flang+0xbadf45)
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
flang-22: note: diagnostic msg: /tmp/c9508c6b-1dc4c6
flang-22: note: diagnostic msg: /tmp/c9508c6b-1dc4c6.sh
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
| `a` | `d92392ec` | Project seed |
| `b` | `23d88513` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
